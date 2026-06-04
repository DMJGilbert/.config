{
  config,
  lib,
  isLinux,
  ...
}: let
  cfg = config.local.profiles.server;
in
  {
    options.local.profiles.server = {
      enable = lib.mkEnableOption "Server profile (enables common server features)";
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.profiles.server is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      # Server profile enables these features by default
      # Individual features can be overridden: local.features.docker.enable = false;
      local.services.tailscale.enable = lib.mkDefault true;
      local.features.docker.enable = lib.mkDefault true;
    };
  }
