{
  config,
  pkgs,
  ...
}: let
  homeDir =
    if pkgs.stdenv.isDarwin
    then "/Users/darren"
    else "/home/darren";
in {
  sops = {
    # Path to the encrypted secrets file (relative to flake root)
    defaultSopsFile = ../../secrets/claude.yaml;

    # Age key location
    age.keyFile = "${homeDir}/.config/sops/age/keys.txt";

    # On darwin, SSH host keys aren't available; on NixOS, use them as fallback
    age.sshKeyPaths =
      if pkgs.stdenv.isDarwin
      then []
      else ["/etc/ssh/ssh_host_ed25519_key"];

    # Define secrets to decrypt
    # These will be available at /run/secrets/<name>
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
