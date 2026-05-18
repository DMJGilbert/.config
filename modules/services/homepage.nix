{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.homepage;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.homepage = {
      enable = lib.mkEnableOption "Homepage dashboard";

      listenPort = lib.mkOption {
        type = lib.types.port;
        default = 8082;
        description = "Port for Homepage to bind to";
      };

      allowedHost = lib.mkOption {
        type = lib.types.str;
        default = "homepage.gilberts.one";
        description = "External hostname for Homepage (used in allowedHosts)";
      };

      secretsFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to an env file with HOMEPAGE_VAR_* values (e.g. a sops template). Systemd reads this before starting the service.";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.homepage is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      systemd.services.homepage-dashboard.serviceConfig = lib.mkIf (cfg.secretsFile != null) {
        EnvironmentFile = cfg.secretsFile;
      };

      services.homepage-dashboard = {
        enable = true;
        openFirewall = false;
        inherit (cfg) listenPort;
        allowedHosts = "${cfg.allowedHost},localhost:${toString cfg.listenPort},127.0.0.1:${toString cfg.listenPort}";

        settings = {
          title = "Gilbert's Homelab";
          theme = "dark";
          color = "slate";
          headerStyle = "clean";
          layout = {
            Media = {icon = "mdi-television-play";};
            Downloads = {icon = "mdi-download";};
            Network = {icon = "mdi-network";};
            System = {icon = "mdi-server";};
          };
        };

        widgets = [
          {
            resources = {
              cpu = true;
              memory = true;
              disk = "/";
              uptime = true;
              cputemp = true;
              network = true;
            };
          }
          {
            search = {
              provider = "google";
              target = "_blank";
            };
          }
        ];

        services = [
          {
            Media = [
              {
                Jellyfin = {
                  href = "https://jellyfin.gilberts.one";
                  description = "Media Server";
                  icon = "jellyfin.svg";
                  widget = {
                    type = "jellyfin";
                    url = "http://127.0.0.1:8096";
                    key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
                    enableBlocks = true;
                    enableNowPlaying = true;
                  };
                };
              }
              {
                Jellyseerr = {
                  href = "https://jellyseerr.gilberts.one";
                  description = "Media Requests";
                  icon = "jellyseerr.svg";
                  widget = {
                    type = "jellyseerr";
                    url = "http://127.0.0.1:5055";
                    key = "{{HOMEPAGE_VAR_JELLYSEERR_API_KEY}}";
                  };
                };
              }
            ];
          }
          {
            Downloads = [
              {
                iPlayarr = {
                  href = "https://iplayarr.gilberts.one";
                  description = "BBC iPlayer Bridge";
                  icon = "bbc-iplayer.png";
                };
              }
              {
                Pinchflat = {
                  href = "https://pinchflat.gilberts.one";
                  description = "YouTube Archiver";
                  icon = "pinchflat.png";
                };
              }
              {
                Sonarr = {
                  href = "https://sonarr.gilberts.one";
                  description = "TV Series";
                  icon = "sonarr.svg";
                  widget = {
                    type = "sonarr";
                    url = "http://127.0.0.1:8989";
                    key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
                  };
                };
              }
              {
                Radarr = {
                  href = "https://radarr.gilberts.one";
                  description = "Movies";
                  icon = "radarr.svg";
                  widget = {
                    type = "radarr";
                    url = "http://127.0.0.1:7878";
                    key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
                  };
                };
              }
              {
                Prowlarr = {
                  href = "https://prowlarr.gilberts.one";
                  description = "Indexer Manager";
                  icon = "prowlarr.svg";
                  widget = {
                    type = "prowlarr";
                    url = "http://127.0.0.1:9696";
                    key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
                  };
                };
              }
              {
                qBittorrent = {
                  href = "https://qbittorrent.gilberts.one";
                  description = "Torrent Client (VPN)";
                  icon = "qbittorrent.svg";
                  widget = {
                    type = "qbittorrent";
                    url = "http://10.200.200.2:8081";
                    username = "{{HOMEPAGE_VAR_QBITTORRENT_USERNAME}}";
                    password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
                  };
                };
              }
            ];
          }
          {
            Network = [
              {
                "AdGuard Home" = {
                  href = "https://adguard.gilberts.one";
                  description = "DNS & Ad Blocking";
                  icon = "adguard-home.svg";
                  widget = {
                    type = "adguard";
                    url = "http://127.0.0.1:3000";
                    username = "{{HOMEPAGE_VAR_ADGUARD_USERNAME}}";
                    password = "{{HOMEPAGE_VAR_ADGUARD_PASSWORD}}";
                  };
                };
              }
              {
                "Uptime Kuma" = {
                  href = "https://kuma.gilberts.one";
                  description = "Uptime Monitoring";
                  icon = "uptime-kuma.svg";
                  widget = {
                    type = "uptimekuma";
                    url = "http://127.0.0.1:3001";
                    slug = "home";
                  };
                };
              }
              {
                Tailscale = {
                  description = "VPN Mesh";
                  icon = "tailscale.svg";
                  widget = {
                    type = "tailscale";
                    deviceid = "{{HOMEPAGE_VAR_TAILSCALE_DEVICE_ID}}";
                    key = "{{HOMEPAGE_VAR_TAILSCALE_API_KEY}}";
                  };
                };
              }
            ];
          }
          {
            System = [
              {
                "Home Assistant" = {
                  href = "https://home.gilberts.one";
                  description = "Home Automation";
                  icon = "home-assistant.svg";
                  widget = {
                    type = "homeassistant";
                    url = "http://127.0.0.1:8123";
                    key = "{{HOMEPAGE_VAR_HASS_TOKEN}}";
                  };
                };
              }
              {
                Glances = {
                  href = "https://glances.gilberts.one";
                  description = "System Monitor";
                  icon = "glances.svg";
                  widget = {
                    type = "glances";
                    url = "http://127.0.0.1:61208";
                    version = 4;
                    metric = "fs:/";
                  };
                };
              }
              {
                "Zigbee2MQTT" = {
                  description = "Zigbee Gateway";
                  icon = "zigbee2mqtt.png";
                };
              }
            ];
          }
        ];
      };
    };
  }
