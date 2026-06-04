# Helper for the *arr family of media services (sonarr/radarr/prowlarr style).
# Each service is a thin wrapper around an upstream NixOS service module:
#   - exposes `local.services.<name>.enable`
#   - warns on Darwin
#   - on Linux, enables `services.<name>` with openFirewall = false
#   - if `mediaWriter`, joins the shared media group and sets UMask=0002 so
#     downloaded files inherit group write
#
# Usage (inside modules/services/<name>.nix):
#   import ../../lib/mkMediaService.nix {
#     name = "sonarr";
#     description = "Sonarr TV show automation";
#   }
{
  name,
  description,
  mediaWriter ? true,
}: {
  config,
  lib,
  isLinux,
  ...
}: let
  cfg = config.local.services.${name};
in
  {
    options.local.services.${name} = {
      enable = lib.mkEnableOption description;
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.${name} is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable (
      {
        services.${name} = {
          enable = true;
          openFirewall = false;
        };
      }
      // lib.optionalAttrs mediaWriter {
        systemd.services.${name}.serviceConfig.UMask = lib.mkForce "0002";
        users.users.${name}.extraGroups =
          lib.optional config.local.services.mediaStorage.enable
          config.local.services.mediaStorage.group;
      }
    );
  }
