# Cross-platform module: works on both NixOS and nix-darwin
# Both platforms support services.tailscale.enable
{
  config,
  lib,
  ...
}: let
  cfg = config.local.services.tailscale;
in {
  options.local.services.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN mesh network";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;
  };
}
