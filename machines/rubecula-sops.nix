{config, ...}: {
  sops = {
    secrets = {
      "DARREN_PASSWORD" = {
        sopsFile = ../secrets/rubecula.yaml;
        mode = "0400";
        owner = "root";
      };
      "NAMECHEAP_API_USER" = {sopsFile = ../secrets/rubecula.yaml;};
      "NAMECHEAP_API_KEY" = {sopsFile = ../secrets/rubecula.yaml;};
      "MULLVAD_WG_PRIVATE_KEY" = {
        sopsFile = ../secrets/rubecula.yaml;
        mode = "0400";
        owner = "root";
      };
      "MULLVAD_WG_ADDRESS" = {sopsFile = ../secrets/rubecula.yaml;};
      "MULLVAD_WG_PEER_PUBKEY" = {sopsFile = ../secrets/rubecula.yaml;};
      "MULLVAD_WG_PEER_ENDPOINT" = {sopsFile = ../secrets/rubecula.yaml;};
      "MULLVAD_WG_DNS" = {sopsFile = ../secrets/rubecula.yaml;};
      "IPLAYARR_API_KEY" = {sopsFile = ../secrets/rubecula.yaml;};
      # Homepage widget API keys — add values via: sops secrets/rubecula.yaml
      "JELLYFIN_API_KEY" = {sopsFile = ../secrets/rubecula.yaml;};
      "JELLYSEERR_API_KEY" = {sopsFile = ../secrets/rubecula.yaml;};
      "SONARR_API_KEY" = {sopsFile = ../secrets/rubecula.yaml;};
      "RADARR_API_KEY" = {sopsFile = ../secrets/rubecula.yaml;};
      "PROWLARR_API_KEY" = {sopsFile = ../secrets/rubecula.yaml;};
      "QBITTORRENT_USERNAME" = {sopsFile = ../secrets/rubecula.yaml;};
      "QBITTORRENT_PASSWORD" = {sopsFile = ../secrets/rubecula.yaml;};
      "ADGUARD_USERNAME" = {sopsFile = ../secrets/rubecula.yaml;};
      "ADGUARD_PASSWORD" = {sopsFile = ../secrets/rubecula.yaml;};
      # System-level HASS_TOKEN for homepage template — uses key= to avoid name collision
      # with the user-level "HASS_TOKEN" declared in users/darren/sops.nix
      "HASS_TOKEN_SYSTEM" = {
        sopsFile = ../secrets/claude.yaml;
        key = "HASS_TOKEN";
      };
    };
    templates = {
      "iplayarr-env" = {
        content = ''
          API_KEY=${config.sops.placeholder."IPLAYARR_API_KEY"}
        '';
        owner = "iplayarr";
      };
      "homepage-env" = {
        content = ''
          HOMEPAGE_VAR_JELLYFIN_API_KEY=${config.sops.placeholder."JELLYFIN_API_KEY"}
          HOMEPAGE_VAR_JELLYSEERR_API_KEY=${config.sops.placeholder."JELLYSEERR_API_KEY"}
          HOMEPAGE_VAR_SONARR_API_KEY=${config.sops.placeholder."SONARR_API_KEY"}
          HOMEPAGE_VAR_RADARR_API_KEY=${config.sops.placeholder."RADARR_API_KEY"}
          HOMEPAGE_VAR_PROWLARR_API_KEY=${config.sops.placeholder."PROWLARR_API_KEY"}
          HOMEPAGE_VAR_QBITTORRENT_USERNAME=${config.sops.placeholder."QBITTORRENT_USERNAME"}
          HOMEPAGE_VAR_QBITTORRENT_PASSWORD=${config.sops.placeholder."QBITTORRENT_PASSWORD"}
          HOMEPAGE_VAR_ADGUARD_USERNAME=${config.sops.placeholder."ADGUARD_USERNAME"}
          HOMEPAGE_VAR_ADGUARD_PASSWORD=${config.sops.placeholder."ADGUARD_PASSWORD"}
          HOMEPAGE_VAR_HASS_TOKEN=${config.sops.placeholder."HASS_TOKEN_SYSTEM"}
        '';
        mode = "0400";
      };
      "cross-seed-secrets" = {
        content = ''
          {
            "torznab": [
              "http://localhost:9696/1/api?apikey=${config.sops.placeholder."PROWLARR_API_KEY"}",
              "http://localhost:9696/2/api?apikey=${config.sops.placeholder."PROWLARR_API_KEY"}",
              "http://localhost:9696/3/api?apikey=${config.sops.placeholder."PROWLARR_API_KEY"}",
              "http://localhost:9696/4/api?apikey=${config.sops.placeholder."PROWLARR_API_KEY"}",
              "http://localhost:9696/5/api?apikey=${config.sops.placeholder."PROWLARR_API_KEY"}",
              "http://localhost:9696/6/api?apikey=${config.sops.placeholder."PROWLARR_API_KEY"}",
              "http://localhost:9696/7/api?apikey=${config.sops.placeholder."PROWLARR_API_KEY"}",
              "http://localhost:9696/8/api?apikey=${config.sops.placeholder."PROWLARR_API_KEY"}"
            ],
            "torrentClients": ["qbittorrent:http://${config.sops.placeholder."QBITTORRENT_USERNAME"}:${config.sops.placeholder."QBITTORRENT_PASSWORD"}@10.200.200.2:8081"]
          }
        '';
        owner = "cross-seed";
        mode = "0400";
      };
      "namecheap-acme-env" = {
        content = ''
          NAMECHEAP_API_USER=${config.sops.placeholder."NAMECHEAP_API_USER"}
          NAMECHEAP_API_KEY=${config.sops.placeholder."NAMECHEAP_API_KEY"}
        '';
        owner = "acme";
      };
      "wg-mullvad.conf" = {
        content = ''
          [Interface]
          PrivateKey = ${config.sops.placeholder."MULLVAD_WG_PRIVATE_KEY"}

          [Peer]
          PublicKey  = ${config.sops.placeholder."MULLVAD_WG_PEER_PUBKEY"}
          Endpoint   = ${config.sops.placeholder."MULLVAD_WG_PEER_ENDPOINT"}
          AllowedIPs = 0.0.0.0/0
          PersistentKeepalive = 25
        '';
        mode = "0400";
        owner = "root";
      };
    };
  };
}
