{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.impermanence;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.impermanence = {
      enable = lib.mkEnableOption "Ephemeral root with impermanence (requires disko migration)";

      persistentStoragePath = lib.mkOption {
        type = lib.types.str;
        default = "/persist";
        description = "Mount point of the persistent storage volume";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.impermanence is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      environment.persistence.${cfg.persistentStoragePath} = {
        hideMounts = true;

        # System identity — loss of these causes Tailscale re-auth and journal gaps
        files = [
          "/etc/machine-id"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ];

        directories = [
          # Infrastructure
          "/var/lib/acme"
          "/var/lib/tailscale"
          "/var/lib/adguardhome"
          "/var/lib/uptime-kuma"

          # Home automation
          "/var/lib/hass"
          "/var/lib/matter-server"
          "/var/lib/zigbee2mqtt"

          # Media services
          "/var/lib/media"
          "/var/lib/jellyfin"
          "/var/lib/sonarr"
          "/var/lib/radarr"
          "/var/lib/prowlarr"
          "/var/lib/qbittorrent"
          "/var/lib/pinchflat"
          "/var/lib/iplayarr"
          "/var/lib/tdarr"
          "/var/lib/cross-seed"
          "/var/lib/recyclarr"

          # Network services
          "/var/lib/mosquitto"

          # User home
          {
            directory = "/home/darren";
            user = "darren";
            group = "users";
            mode = "0700";
          }

          # Persistent logs
          "/var/log"
        ];
      };
    };
  }
