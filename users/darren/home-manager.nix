{pkgs, ...}: let
  treefmtIncludes = import ../../lib/treefmt-includes.nix;
  prettierIncludes = builtins.concatStringsSep ", " (map (s: ''"${s}"'') treefmtIncludes.prettier);
in {
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
      includes = [${prettierIncludes}]

      [formatter.rustfmt]
      command = "rustfmt"
      includes = ["*.rs"]
    '';
    packages = with pkgs;
      [
        # Run any nixpkgs binary without installing it: `, cowsay hello`.
        # Needs the nix-index database (see programs.nix-index below).
        comma
        # neovim
        tree-sitter
        luarocks
        nixd # Nix LSP with flake evaluation + option-name completion
        taplo # TOML LSP — Cargo.toml has no language server without it
        alejandra
        # Reads the global treefmt.toml written above (found by walk-up in any
        # project) and is what quality-gate.sh shells out to. Without it on
        # PATH both were silently no-ops.
        treefmt
        shellcheck
        shfmt
        statix
        deadnix
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

        # PDF extraction. Without these the Read tool cannot open a PDF at all,
        # which previously led to hand-rolling a zlib stream decompressor to
        # scrape a spec document.
        poppler-utils # pdftoppm, pdftotext
        mupdf # mutool

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
        obsidian
        librewolf
        flutter

        tuist
        fastlane
        swiftformat
        swiftlint
        sourcekit-lsp

        jankyborders
        cocoapods

        # diagnostic / dev tools — moved off rubecula (system closure) into
        # ryukyu's user profile where they're actually used day-to-day
        nmap
      ]);
  };

  manual.manpages.enable = false;
  programs = {
    bat.enable = true;
    # Shell history in SQLite, searchable across sessions.
    atuin = {
      enable = true;
      enableZshIntegration = true;
      # zsh.nix binds Up/Down to up-line-or-beginning-search; atuin would
      # otherwise take the Up arrow for itself.
      flags = ["--disable-up-arrow"];
      settings = {
        style = "compact";
        inline_height = 20;
        # Nix owns the version; don't nag about upstream releases.
        update_check = false;
      };
    };
    # `nix-index` answers "which package provides this file"; `comma` (,) runs
    # a binary straight from nixpkgs without installing it. Build the index
    # once with `nix-index`, then refresh it occasionally.
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    eza.enable = true;
    ripgrep.enable = true;
    # Required by the fzf widgets below, which reference `fd` directly.
    fd = {
      enable = true;
      hidden = true;
      ignores = [".git/" "node_modules/"];
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = ["--height 40%" "--border"];
      fileWidget.command = "fd --type f --hidden --follow --exclude .git";
      changeDirWidget.command = "fd --type d --hidden --follow --exclude .git";
      # Atuin owns Ctrl-R: it searches a SQLite history with directory, exit
      # code and duration, where fzf's widget only fuzzy-matches .zsh_history.
      # fzf keeps Ctrl-T (files) and Alt-C (cd).
      historyWidget.zsh.command = "";
    };
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          AddKeysToAgent = "yes";
        };
        "github.com" = {
          IdentityFile = "~/.ssh/id_ed25519";
        };
        "rubecula" = {
          HostName = "rubecula";
          User = "darren";
        };
      };
    };
    wezterm = {
      enable = true;
      package = pkgs.wezterm;
      enableBashIntegration = true;
      enableZshIntegration = true;
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
