{
  config,
  lib,
  pkgs,
  isLinux,
  ...
}: let
  cfg = config.local.services.technitiumDnsServer;

  recordType = lib.types.submodule {
    options = {
      domain = lib.mkOption {
        type = lib.types.str;
        description = "Record domain, e.g. \"*.gilberts.one\" or \"@\" for zone apex.";
      };
      type = lib.mkOption {
        type = lib.types.enum ["A" "AAAA" "CNAME" "TXT" "MX" "PTR"];
        default = "A";
      };
      value = lib.mkOption {
        type = lib.types.str;
        description = "Record value — IP address for A/AAAA, hostname for CNAME/MX/PTR, text for TXT.";
      };
      ttl = lib.mkOption {
        type = lib.types.int;
        default = 3600;
      };
    };
  };

  # A records use ipAddress=, CNAME/PTR use cname=, TXT uses text=, MX uses exchange=
  valueParam = r:
    if r.type == "A" || r.type == "AAAA"
    then "ipAddress=${r.value}"
    else if r.type == "CNAME" || r.type == "PTR"
    then "cname=${r.value}"
    else if r.type == "TXT"
    then "text=${r.value}"
    else if r.type == "MX"
    then "exchange=${r.value}"
    else "value=${r.value}";

  curl = "${pkgs.curl}/bin/curl";

  # Generate curl calls for a zone and its records
  mkZoneScript = zone: records: ''
    # Zone: ${zone}
    ${curl} -sf "http://localhost:5380/api/zones/create" \
      -d "token=$TOKEN" \
      -d "zone=${zone}" \
      -d "type=Primary" > /dev/null || true
    ${lib.concatMapStrings (r: ''
        ${curl} -sf "http://localhost:5380/api/zones/records/add" \
          -d "token=$TOKEN" \
          --data-urlencode "domain=${r.domain}" \
          -d "zone=${zone}" \
          -d "type=${r.type}" \
          -d "${valueParam r}" \
          -d "ttl=${toString r.ttl}" \
          -d "overwrite=true" > /dev/null
        echo "Record configured: ${r.type} ${r.domain} -> ${r.value}"
      '')
      records}
  '';
in
  {
    options.local.services.technitiumDnsServer = {
      enable = lib.mkEnableOption "Technitium DNS Server";

      blockLists = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
        description = "Block list URLs to configure in Technitium DNS Server.";
      };

      zones = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf recordType);
        default = {};
        example = {
          "gilberts.one" = [
            {
              domain = "*.gilberts.one";
              type = "A";
              value = "192.168.68.101";
            }
          ];
        };
        description = "DNS zones to create and records to manage. Attr key is the zone name.";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.technitiumDnsServer is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      services.technitium-dns-server.enable = true;

      systemd.services = {
        # nixpkgs module sets ProtectSystem=strict but omits LogsDirectory,
        # so /var/log is read-only and the service crashes on first write
        technitium-dns-server.serviceConfig.LogsDirectory = "technitium";

        technitium-dns-server-blocklist = lib.mkIf (cfg.blockLists != []) {
          description = "Configure Technitium DNS block lists";
          after = ["technitium-dns-server.service"];
          wants = ["technitium-dns-server.service"];
          wantedBy = ["multi-user.target"];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            TimeoutStartSec = 60;
          };

          script = let
            blockListUrls = lib.concatStringsSep "," cfg.blockLists;
            keyFile = config.sops.secrets."TECHNITIUM_API_KEY".path;
          in ''
            TOKEN=$(cat ${keyFile})
            until ${curl} -sf http://localhost:5380/ > /dev/null; do
              sleep 2
            done
            ${curl} -sf "http://localhost:5380/api/settings/set" \
              -d "token=$TOKEN&blockListUrls=${blockListUrls}" > /dev/null
            echo "Block lists configured: ${blockListUrls}"
          '';
        };

        technitium-dns-server-zones = lib.mkIf (cfg.zones != {}) {
          description = "Configure Technitium DNS zones and records";
          after = ["technitium-dns-server.service"];
          wants = ["technitium-dns-server.service"];
          wantedBy = ["multi-user.target"];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            TimeoutStartSec = 60;
          };

          script = let
            keyFile = config.sops.secrets."TECHNITIUM_API_KEY".path;
          in ''
            TOKEN=$(cat ${keyFile})
            until ${curl} -sf http://localhost:5380/ > /dev/null; do
              sleep 2
            done
            ${lib.concatStrings (lib.mapAttrsToList mkZoneScript cfg.zones)}
          '';
        };
      };
    };
  }
