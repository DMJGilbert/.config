{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.radarr;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.radarr = {
      enable = lib.mkEnableOption "Radarr movie automation";
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.radarr is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      services.radarr = {
        enable = true;
        openFirewall = false;
      };

      systemd.services.radarr.serviceConfig.UMask = "0002";

      users.users.radarr.extraGroups =
        lib.optional config.local.services.mediaStorage.enable
        config.local.services.mediaStorage.group;
    };
  }
