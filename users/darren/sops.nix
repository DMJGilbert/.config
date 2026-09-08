{
  config,
  isDarwin,
  ...
}: {
  sops = {
    defaultSopsFile = ../../secrets/claude.yaml;

    # Darwin has no usable SSH host key for sops, so it decrypts with darren's
    # personal age key. NixOS uses its own SSH host key instead — that key is a
    # recipient of both secret files (see .sops.yaml), so the server decrypts
    # without reaching into /home.
    #
    # Keeping keyFile set on NixOS would reintroduce that dependency: secrets
    # activate before /home is necessarily available on an impermanent host, and
    # DARREN_PASSWORD backs users.users.darren.hashedPasswordFile — losing it
    # means losing login.
    age.keyFile =
      if isDarwin
      then "${config.users.users.darren.home}/.config/sops/age/keys.txt"
      else null;

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
