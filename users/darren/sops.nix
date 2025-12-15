_: {
  sops = {
    # Path to the encrypted secrets file (relative to flake root)
    defaultSopsFile = ../../secrets/claude.yaml;

    # Age key location (where you generated your key)
    age.keyFile = "/Users/darren/.config/sops/age/keys.txt";

    # Disable SSH host key fallback (not available on macOS)
    age.sshKeyPaths = [];

    # Define secrets to decrypt
    # These will be available at /run/secrets/<name>
    secrets = {
      "GITHUB_PERSONAL_ACCESS_TOKEN" = {
        owner = "darren";
      };
      "FIGMA_ACCESS_TOKEN" = {
        owner = "darren";
      };
      "HASS_HOST" = {
        owner = "darren";
      };
      "HASS_TOKEN" = {
        owner = "darren";
      };
    };
  };
}
