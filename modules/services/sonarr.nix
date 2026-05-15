{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.sonarr;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.sonarr = {
      enable = lib.mkEnableOption "Sonarr TV show automation";
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.sonarr is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      services.sonarr = {
        enable = true;
        openFirewall = false;
      };

      systemd.services.sonarr.serviceConfig.UMask = "0002";

      users.users.sonarr.extraGroups =
        lib.optional config.local.services.mediaStorage.enable
        config.local.services.mediaStorage.group;
    };
  }
