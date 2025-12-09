_: {
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "Catppuccin Frappe";
    };
  };

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
      core.editor = "nvim";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rerere.enabled = true;
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        ca = "commit --amend";
        cp = "cherry-pick";
        df = "diff";
        lg = "log --oneline --graph --decorate";
        lga = "log --oneline --graph --decorate --all";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        wip = "commit -am 'WIP'";
      };
    };
  };
}
