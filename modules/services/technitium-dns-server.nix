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
    };
  }
