{
  config,
  lib,
  isLinux,
  ...
}: let
  cfg = config.local.services.nginx;

  # Render an nginx source allowlist. Emitted at server level so it guards every
  # location in the vhost, including any added later. Order matters: nginx
  # evaluates allow/deny top-down and stops at the first match, so `deny all`
  # must come last.
  mkAccessControl = sources:
    lib.optionalString (sources != []) ''
      ${lib.concatMapStringsSep "\n" (cidr: "allow ${cidr};") sources}
      deny all;
    '';
in
  {
    options.local.services.nginx = {
      enable = lib.mkEnableOption "Nginx reverse proxy";

      internalSources = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["100.64.0.0/10" "192.168.1.0/24"];
        description = ''
          CIDR ranges treated as internal, used by any virtual host with
          `internalOnly = true`. Typically the Tailscale CGNAT range
          (100.64.0.0/10) plus the LAN subnet.
        '';
      };

      acme = {
        acceptTerms = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Accept ACME terms of service for Let's Encrypt certificates";
        };

        email = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Email address for ACME account registration";
        };
      };

      virtualHosts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            forceSSL = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Force SSL/HTTPS";
            };

            enableACME = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable ACME certificate provisioning (ignored when useACMEHost is set)";
            };

            useACMEHost = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Use an existing ACME certificate by cert name (e.g. \"gilberts.one\" for the wildcard cert)";
            };

            extraConfig = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "Extra nginx configuration for this virtual host";
            };

            proxyPass = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Backend URL to proxy requests to";
            };

            proxyWebsockets = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Enable WebSocket proxying";
            };

            internalOnly = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = ''
                Restrict this virtual host to `internalSources`, rejecting every
                other client with 403. The vhost still resolves publicly and
                still serves TLS — only the request is refused — so this does
                not interfere with DNS-01 certificate issuance.
              '';
            };
          };
        });
        default = {};
        description = "Nginx virtual host configurations";
      };
    };

    # Warn if enabled on unsupported platform
    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.nginx is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      # An internalOnly vhost with no internalSources would emit a bare
      # `deny all;` and lock out every client, including you. Fail at build
      # time rather than after the switch.
      assertions = [
        {
          assertion =
            (cfg.internalSources != [])
            || !(lib.any (v: v.internalOnly) (lib.attrValues cfg.virtualHosts));
          message = ''
            local.services.nginx: one or more virtual hosts set `internalOnly = true`
            but `local.services.nginx.internalSources` is empty, which would deny all
            traffic to them. Set internalSources to your Tailscale/LAN ranges.
          '';
        }
      ];

      security.acme = lib.mkIf cfg.acme.acceptTerms {
        acceptTerms = true;
        defaults.email = cfg.acme.email;
      };

      services.nginx = {
        enable = true;
        recommendedProxySettings = true;

        virtualHosts = lib.mapAttrs (_name: vhost:
          {
            inherit (vhost) forceSSL;
            extraConfig =
              lib.optionalString vhost.internalOnly (mkAccessControl cfg.internalSources)
              + vhost.extraConfig;
            enableACME = vhost.enableACME && vhost.useACMEHost == null;
            locations."/" = lib.mkIf (vhost.proxyPass != null) {
              inherit (vhost) proxyPass proxyWebsockets;
            };
          }
          // lib.optionalAttrs (vhost.useACMEHost != null) {
            inherit (vhost) useACMEHost;
          })
        cfg.virtualHosts;
      };
    };
  }
