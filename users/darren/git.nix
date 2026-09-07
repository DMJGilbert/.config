_: {
  programs = {
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "Catppuccin Frappe";
      };
    };

    git = {
      enable = true;
      lfs.enable = true;
      signing = {
        format = "ssh";
        key = "~/.ssh/id_ed25519";
        signByDefault = true;
      };
      settings = {
        user = {
          name = "DMJGilbert";
          email = "dmjgilbert@me.com";
        };
        init.defaultBranch = "main";
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

    # lazygit is installed via environment.systemPackages (machines/shared.nix),
    # so this module supplies config only.
    lazygit = {
      enable = true;
      package = null;
      settings = {
        keybinding.universal = {
          # ":" is lazygit's executeShellCommand prompt, which swallows a
          # reflexive ":q". Disabled so ":q" falls through to "q" and simply
          # closes lazygit, returning to neovim.
          executeShellCommand = "<disabled>";
        };
      };
    };
  };
}
