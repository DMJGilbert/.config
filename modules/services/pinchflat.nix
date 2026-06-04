{
  config,
  lib,
  isLinux,
  ...
}: let
  cfg = config.local.services.pinchflat;
  mediaGroup = config.local.services.mediaStorage.group;
in
  {
    options.local.services.pinchflat = {
      enable = lib.mkEnableOption "Pinchflat YouTube channel archiver";

      port = lib.mkOption {
        type = lib.types.port;
        default = 8945;
        description = "Port for the Pinchflat web interface";
      };

      mediaDir = lib.mkOption {
        type = lib.types.path;
        default = "${config.local.services.mediaStorage.root}/youtube";
        defaultText = lib.literalExpression ''"''${config.local.services.mediaStorage.root}/youtube"'';
        description = "Directory where downloaded media is stored";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.pinchflat is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = config.local.services.mediaStorage.enable;
          message = "local.services.pinchflat requires local.services.mediaStorage.enable = true.";
        }
      ];

      systemd.tmpfiles.rules = [
        "d ${cfg.mediaDir} 2775 pinchflat ${mediaGroup} -"
      ];

      users.users.pinchflat = {
        extraGroups = [mediaGroup];
      };

      systemd.services.pinchflat.serviceConfig.UMask = "0002";

      services.pinchflat = {
        enable = true;
        selfhosted = true;
        openFirewall = false;
        inherit (cfg) port mediaDir;
      };
    };
  }
