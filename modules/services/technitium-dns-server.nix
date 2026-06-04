{
  config,
  lib,
  isLinux,
  ...
}: let
  cfg = config.local.services.technitiumDnsServer;
in
  {
    options.local.services.technitiumDnsServer = {
      enable = lib.mkEnableOption "Technitium DNS Server";
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.technitiumDnsServer is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      services.technitium-dns-server.enable = true;
      # nixpkgs module sets ProtectSystem=strict but omits LogsDirectory,
      # so /var/log is read-only and the service crashes on first write
      systemd.services.technitium-dns-server.serviceConfig.LogsDirectory = "technitium";
    };
  }
