_: {
  enable = true;
  settings = {
    user = {
      name = "DMJGilbert";
      email = "dmjgilbert@me.com";
      signingkey = "~/.ssh/id_ed25519";
    };
    init.defaultBranch = "main";
    gpg.format = "ssh";
    commit.gpgsign = true;
    github = {user = "DMJGilbert";};
  };
  lfs.enable = true;
}
