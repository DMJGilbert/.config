{pkgs, ...}: {
  imports = [
    ./nvim
    ./aerospace.nix
    ./zsh.nix
    ./git.nix
    ./claude-code.nix
  ];

  home = {
    stateVersion = "26.05";
    sessionVariables = {
      SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
    };
    # Global treefmt config — discovered by walk-up in any project under ~/
    file."treefmt.toml".text = ''
      [formatter.alejandra]
      command = "alejandra"
      includes = ["*.nix"]

      [formatter.stylua]
      command = "stylua"
      includes = ["*.lua"]

      [formatter.prettier]
      command = "prettier"
      options = ["--write"]
      includes = ["*.json", "*.yaml", "*.yml", "*.md", "*.ts", "*.tsx", "*.js", "*.css", "*.html"]

      [formatter.rustfmt]
      command = "rustfmt"
      includes = ["*.rs"]
    '';
    packages = with pkgs;
      [
        # neovim
        # tree-sitter
        luarocks
        nil
        alejandra
        shellcheck
        shfmt
        statix
        biome
        lua-language-server
        vscode-langservers-extracted
        typescript-language-server
        yaml-language-server
        bash-language-server
        prettier
        eslint_d

        # development
        pkgconf
        cmake
        stylua
        uv # Python package manager (provides uvx)

        # nodejs
        nodejs_24
        # rust
        cargo
        rustc
        rust-analyzer
        rustfmt
        clippy
        cargo-nextest

        # CLI tools
        jq # JSON processing
        yq # YAML processing
        gh # GitHub CLI
        btop # System monitoring
        wget # Downloads
        httpie # Better HTTP client
        dust # Better du
        duf # Better df
        procs # Better ps

        # Secrets management
        age # Encryption tool for sops
        sops # Encrypted secrets

        # Nix tooling
        nh # Better nixos-rebuild/darwin-rebuild wrapper with diff output
        nvd # Show package version diffs between Nix generations
      ]
      ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
        # tools
        zoom-us
        slack
        openconnect

        tuist
        fastlane
        swiftformat
        swiftlint
        sourcekit-lsp

        jankyborders
        cocoapods
      ]);
  };

  manual.manpages.enable = false;
  programs = {
    bat.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    eza.enable = true;
    ripgrep.enable = true;
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = ["--height 40%" "--border"];
      fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
      changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    };
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          addKeysToAgent = "yes";
        };
        "github.com" = {
          identityFile = "~/.ssh/id_ed25519";
        };
        "rubecula" = {
          hostname = "rubecula";
          user = "darren";
        };
      };
    };
    wezterm = {
      enable = true;
      package =
        if pkgs.stdenv.isLinux
        then pkgs.wezterm
        else pkgs.emptyDirectory;
      enableBashIntegration = pkgs.stdenv.isLinux;
      enableZshIntegration = pkgs.stdenv.isLinux;
      extraConfig = ''
        ${builtins.readFile ./config/wezterm/wezterm.lua}
      '';
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        command_timeout = 1000;
        format = "[](#232634)$os$directory[](fg:#232634 bg:#303446)$git_status[](fg:#303446 bg:#86BBD8)[](fg:#86BBD8 bg:#06969A)[](fg:#06969A bg:#33658A)$time[ ](fg:#33658A)";
        directory = {
          style = "bg:#232634";
          format = "[$path ]($style)";
          truncation_length = 0;
          truncation_symbol = "";
          substitutions = {
            "Documents" = " ";
            "Downloads" = " ";
            "Music" = " ";
            "Pictures" = " ";
            "~/Developer" = " ";
          };
        };

        docker_context.disabled = true;
        git_branch.disabled = true;

        git_status = {
          disabled = true;
          style = "bg:#303446";
          format = "[  $all_status$ahead_behind ]($style)";
          conflicted = "🏳";
          up_to_date = "";
          untracked = "";
          ahead = "⇡\${count}";
          diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
          behind = "⇣\${count}";
          stashed = " ";
          modified = "";
          staged = "";
          renamed = "";
          deleted = "";
        };

        package.disabled = true;

        time = {
          disabled = false;
          time_format = "%R";
          style = "bg:#33658A";
          format = "[ $time ]($style)";
        };

        os = {
          format = "[($name | )]($style)";
          style = "bg:#232634";
          disabled = false;
        };
      };
    };
    zellij = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        simplified_ui = true;
        pane_frames = false;
        theme = "catppuccin-frappe";
        default_layout = "compact";
        themes.catppuccin-frappe = {
          fg = [198 208 245];
          bg = [98 104 128];
          black = [41 44 60];
          red = [231 130 132];
          green = [166 209 137];
          yellow = [229 200 144];
          blue = [140 170 238];
          magenta = [244 184 228];
          cyan = [153 209 219];
          white = [198 208 245];
          orange = [239 159 118];
        };
        show_startup_tips = false;
        ui.pane_frames.hide_session_name = true;
      };
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    yazi = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
          sort_by = "natural";
          sort_dir_first = true;
        };
      };
    };
  };
}
