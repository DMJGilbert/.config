{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.tailscale;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.tailscale = {
      enable = lib.mkEnableOption "Tailscale VPN mesh network";
    };
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      services.tailscale.enable = true;
    };
  }
