{
  config,
  lib,
  isLinux,
  ...
}: let
  cfg = config.local.features.docker;
in
  {
    options.local.features.docker = {
      enable = lib.mkEnableOption "Docker container runtime";
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.features.docker is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      virtualisation.docker.enable = true;
    };
  }
