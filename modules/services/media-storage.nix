{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.mediaStorage;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.mediaStorage = {
      enable = lib.mkEnableOption "Shared media storage directories and group";

      root = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/media";
        description = "Root directory for media storage";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "media";
        description = "Shared group name for cross-service media access";
      };

      gid = lib.mkOption {
        type = lib.types.int;
        default = 994;
        description = "GID for the shared media group";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.mediaStorage is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      users.groups.${cfg.group} = {
        inherit (cfg) gid;
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.root}                       2775 root ${cfg.group} -"
        "d ${cfg.root}/movies                2775 root ${cfg.group} -"
        "d ${cfg.root}/tv                    2775 root ${cfg.group} -"
        "d ${cfg.root}/downloads             2775 root ${cfg.group} -"
        "d ${cfg.root}/downloads/incomplete  2775 root ${cfg.group} -"
        "d ${cfg.root}/downloads/complete    2775 root ${cfg.group} -"
      ];
    };
  }
