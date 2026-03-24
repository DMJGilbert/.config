{
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
  homeDir =
    if isDarwin
    then "/Users/darren"
    else "/home/darren";
in {
  sops = {
    defaultSopsFile = ../../secrets/claude.yaml;
    age.keyFile = "${homeDir}/.config/sops/age/keys.txt";

    # On darwin, SSH host keys aren't available; on NixOS, use them as fallback
    age.sshKeyPaths =
      if isDarwin
      then []
      else ["/etc/ssh/ssh_host_ed25519_key"];

    secrets = {
      "GITHUB_PERSONAL_ACCESS_TOKEN" = {
        owner = "darren";
      };
      "HASS_HOST" = {
        owner = "darren";
      };
      "HASS_TOKEN" = {
        owner = "darren";
      };
      "OBSIDIAN_API_KEY" = {
        owner = "darren";
      };
      "OBSIDIAN_HOST" = {
        owner = "darren";
      };
      "OBSIDIAN_PORT" = {
        owner = "darren";
      };
    };
  };
}
