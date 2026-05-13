{
  config,
  lib,
  pkgs,
  currentSystem,
  ...
}: let
  cfg = config.local.services.jellyfin;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.jellyfin = {
      enable = lib.mkEnableOption "Jellyfin media server";

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open Jellyfin ports in the firewall (not needed when behind nginx)";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.jellyfin is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      services.jellyfin = {
        enable = true;
        inherit (cfg) openFirewall;
      };

      users.users.jellyfin.extraGroups =
        ["video" "render"]
        ++ lib.optional config.local.services.mediaStorage.enable
        config.local.services.mediaStorage.group;

      environment.systemPackages = [pkgs.libva-utils];
    };
  }
