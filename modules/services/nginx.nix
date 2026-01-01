{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.nginx;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.nginx = {
      enable = lib.mkEnableOption "Nginx reverse proxy";

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
              description = "Enable ACME certificate provisioning";
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
      security.acme = lib.mkIf cfg.acme.acceptTerms {
        acceptTerms = true;
        defaults.email = cfg.acme.email;
      };

      services.nginx = {
        enable = true;
        recommendedProxySettings = true;

        virtualHosts =
          lib.mapAttrs (_name: vhost: {
            inherit (vhost) forceSSL enableACME extraConfig;
            locations."/" = lib.mkIf (vhost.proxyPass != null) {
              inherit (vhost) proxyPass proxyWebsockets;
            };
          })
          cfg.virtualHosts;
      };
    };
  }
