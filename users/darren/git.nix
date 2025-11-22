_: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    signing = {
      key = "~/.ssh/id_ed25519";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "DMJGilbert";
        email = "dmjgilbert@me.com";
      };
      init.defaultBranch = "main";
      gpg.format = "ssh";
      github.user = "DMJGilbert";
    };
  };
}
