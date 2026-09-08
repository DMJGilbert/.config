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
    # keyFile stays set on BOTH platforms as a fallback. sops-nix tries every
    # configured key, so NixOS normally decrypts with the host key above and
    # never touches /home — but if the host key is ever regenerated, or is not
    # yet a recipient after a re-key, darren's personal key still works.
    #
    # Making the host key the ONLY path once locked the server out of its own
    # secrets: DARREN_PASSWORD backs users.users.darren.hashedPasswordFile, so
    # a failed decrypt means a failed login.
    #
    # BEFORE ENABLING IMPERMANENCE: drop this on NixOS, since /home may not be
    # restored when secrets activate. Confirm the host key decrypts on its own
    # first — the activation log line "Imported /etc/ssh/ssh_host_ed25519_key
    # as age key with fingerprint ..." must match the &rubecula key in .sops.yaml.
    age.keyFile = "${config.users.users.darren.home}/.config/sops/age/keys.txt";

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
