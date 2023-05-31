{ ... }: {
  enable = true;
  userName = "DMJGilbert";
  userEmail = "dmjgilbert@me.com";
  extraConfig = {
    init.defaultBranch = "main";
    gpg.format = "ssh";
    user.signingkey = "~/.ssh/id_ed25519";
    commit.gpgsign = true;
    github = { user = "DMJGilbert"; };
  };
  lfs.enable = true;
}
