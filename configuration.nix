{ pkgs, inputs, ... }:

{
  services.nix-daemon.enable = true;
  services.yabai.enable = true;
  services.skhd.enable = true;

  nix.configureBuildUsers = true;

  users.users.darren = {
    name = "darren";
    home = "/Users/darren";
  };
  programs.zsh.enable = true;

  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    settings.experimental-features = [ "nix-command" "flakes" ];
    settings.trusted-users = [ "root" "@admin" ];
  };

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs;
    [ (nerdfonts.override { fonts = [ "SourceCodePro" ]; }) ];

  security.pam.enableSudoTouchIdAuth = true;

  nixpkgs.config.permittedInsecurePackages =
    [ "nodejs-16.20.0" "python-2.7.18.6" ];
  environment.systemPackages = with pkgs; [
    skhd
    lazygit
    ripgrep
    fzf
    fd
    wezterm
    qmk
    zellij
    bat
    exa

    # neovim
    tree-sitter
    nil
    nixfmt
    shellcheck
    shfmt
    luajitPackages.lua-lsp
    sumneko-lua-language-server
    nodePackages.typescript-language-server
    nodePackages.prettier
    nodePackages.eslint_d

    # tools
    discord
    teams
    zoom-us
    slack
    obsidian
    openconnect

    pkgconf
    cmake
    openssl
    # nodejs
    nodejs-16_x
    python2
    # rust
    cargo
    rustc
    rust-analyzer
    rustfmt
    clippy
  ];
  environment.variables.EDITOR = "nvim";

  # system.activationScripts.postUserActivation.text = ''
  #  # Install homebrew if it isn't there
  #  if [[ ! -d "/usr/local/bin/brew" ]]; then
  #    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  #  fi
  #'';
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap";
    global.brewfile = true;
    brews = [ "openssl@1.1" "zeromq" ];
    # TODO: Look into raycast
    casks = [ "alfred" "docker" "displaylink" "figma" "qmk-toolbox" ];
  };

  system.keyboard = {
    enableKeyMapping = true;
    # use caps lock as ctrl instead of YELLING
    remapCapsLockToControl = true;
  };

  system.defaults = {
    loginwindow = {
      GuestEnabled = false;
      DisableConsoleAccess = true;
    };
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      _FXShowPosixPathInTitle = true;
    };
    dock = {
      # auto show and hide dock
      autohide = true;
      # remove delay for showing dock
      autohide-delay = 0.0;
      # how fast is the dock showing animation
      autohide-time-modifier = 1.0;
      # set the icon size of all dock items
      tilesize = 30;
      static-only = false;
      # show hidden applications as translucent
      showhidden = true;
      show-recents = false;
      show-process-indicators = true;
      orientation = "bottom";
      # don't automatically rearrange spaces based on the most recent one
      mru-spaces = false;
      launchanim = false;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
    };
    spaces.spans-displays = false;
    NSGlobalDomain = {
      _HIHideMenuBar = true;

      "com.apple.sound.beep.feedback" = 0;
      "com.apple.sound.beep.volume" = 0.0;

      # expand the save panel by default
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;

      # Disable automatic typography options I find annoying while typing code
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;

      # enable tap-to-click (mode 1)
      "com.apple.mouse.tapBehavior" = 1;

      # Enable full keyboard access for all controls
      # (e.g. enable Tab in modal dialogs)
      AppleKeyboardUIMode = 3;

      # Disable press-and-hold for keys in favor of key repeat
      ApplePressAndHoldEnabled = false;

      # Set a very fast keyboard repeat rate
      KeyRepeat = 3;
      InitialKeyRepeat = 15;

      # Enable subpixel font rendering on non-Apple LCDs
      # Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
      AppleFontSmoothing = 1;

      # Finder: show all filename extensions
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "Automatic";
    };
    screencapture.location = "/Users/darren/Downloads";
    LaunchServices = {
      # Disable the "Are you sure you want to open this application?" dialog
      LSQuarantine = false;
    };
  };
}
