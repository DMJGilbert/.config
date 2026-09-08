# Push a notification when any systemd service fails.
#
# This exists because failures here are silent by default. The ACME renewal
# unit for the wildcard certificate failed every night for 27 days and nothing
# surfaced it — the certificate simply expired. Uptime Kuma cannot see this
# class of fault: it polls endpoints, and a unit can fail while the endpoint it
# serves keeps answering with stale data.
#
# A global drop-in adds OnFailure to every .service on the system, so new
# services are covered automatically rather than needing to be remembered.
{
  config,
  lib,
  pkgs,
  isLinux,
  ...
}: let
  cfg = config.local.services.failureNotify;

  notify = pkgs.writeShellApplication {
    name = "notify-failure";
    runtimeInputs = [pkgs.curl pkgs.systemd pkgs.coreutils pkgs.jq];
    text = ''
      unit="''${1:?notify-failure: no unit name given}"

      # Recent journal lines give the notification enough context to be
      # actionable without opening a laptop.
      detail=$(journalctl -u "$unit" -n 12 --no-pager -o cat 2>/dev/null | tail -c 900 || true)
      state=$(systemctl show -p Result --value "$unit" 2>/dev/null || echo unknown)

      payload=$(jq -n \
        --arg title "${cfg.hostLabel}: $unit failed" \
        --arg message "result=$state"$'\n'"$detail" \
        '{message: $message, title: $title}')

      # Never let a notification failure mask the original fault.
      curl -fsS -m 15 -X POST \
        -H "Authorization: Bearer $HASS_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "${cfg.homeAssistantUrl}/api/services/${cfg.notifyService}" \
        >/dev/null || echo "notify-failure: could not reach Home Assistant" >&2
    '';
  };
in
  {
    options.local.services.failureNotify = {
      enable = lib.mkEnableOption "Home Assistant notification on systemd unit failure";

      homeAssistantUrl = lib.mkOption {
        type = lib.types.str;
        default = "http://127.0.0.1:8123";
        description = "Base URL of the Home Assistant instance to notify.";
      };

      notifyService = lib.mkOption {
        type = lib.types.str;
        default = "notify/notify";
        example = "notify/mobile_app_hatchling";
        description = ''
          Home Assistant notify service to call, as `domain/service`.
          `notify/notify` fans out to every configured target.
        '';
      };

      tokenFile = lib.mkOption {
        type = lib.types.path;
        description = ''
          File containing `HASS_TOKEN=<long-lived access token>`, passed to the
          notifier as an EnvironmentFile. Keep this out of the Nix store —
          point it at a sops template.
        '';
      };

      hostLabel = lib.mkOption {
        type = lib.types.str;
        default = config.networking.hostName or "host";
        description = "Name used in the notification title.";
      };

      excludeUnits = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["borgbackup-job-foo.service"];
        description = ''
          Units that should not trigger a notification, for services that fail
          routinely and expectedly.
        '';
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.failureNotify is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      systemd.services =
        {
          "notify-failure@" = {
            description = "Notify Home Assistant that %i failed";
            # Without this the template inherits the global drop-in below and a
            # failing notifier would retrigger itself indefinitely.
            unitConfig.OnFailure = [""];
            serviceConfig = {
              Type = "oneshot";
              EnvironmentFile = cfg.tokenFile;
              ExecStart = "${notify}/bin/notify-failure %i";
              # This handles secrets and talks to the network; give it nothing else.
              DynamicUser = true;
              NoNewPrivileges = true;
              PrivateTmp = true;
              PrivateDevices = true;
              ProtectSystem = "strict";
              ProtectHome = true;
              ProtectKernelTunables = true;
              ProtectKernelModules = true;
              ProtectControlGroups = true;
              RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
              RestrictNamespaces = true;
              LockPersonality = true;
              MemoryDenyWriteExecute = true;
              SystemCallArchitectures = "native";
              CapabilityBoundingSet = "";
            };
          };
        }
        // lib.genAttrs
        (map (lib.removeSuffix ".service") cfg.excludeUnits)
        (_: {unitConfig.OnFailure = lib.mkForce [""];});

      # Top-level drop-in: systemd applies /etc/systemd/system/service.d/*.conf
      # to every .service unit, so this covers services added later without
      # anyone having to remember.
      #
      # It has to arrive via systemd.packages, NOT environment.etc: NixOS already
      # owns /etc/systemd/system as a single symlink into the store, so writing a
      # nested path under it fails the etc build with "Permission denied".
      # generateUnits lndir's any directory found under a package's
      # etc/systemd/system, which is what places service.d/ correctly.
      systemd.packages = [
        (pkgs.writeTextDir "etc/systemd/system/service.d/10-notify-failure.conf" ''
          [Unit]
          OnFailure=notify-failure@%N.service
        '')
      ];
    };
  }
