{ pkgs, ... }: {
  imports = [ ./shared.nix ];

  security.pam.enableSudoTouchIdAuth = true;

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

    CustomUserPreferences = {
      "com.apple.screensaver" = {
        "askForPassword" = true;
        "askForPasswordDelay" = 0;
      };
      "com.apple.trackpad" = { "scaling" = 2; };
      "com.apple.mouse" = { "scaling" = 2.5; };
      "com.apple.desktopservices" = { "DSDontWriteNetworkStores" = false; };
      "com.apple.finder" = {
        "ShowExternalHardDrivesOnDesktop" = false;
        "ShowRemovableMediaOnDesktop" = false;
        "WarnOnEmptyTrash" = false;
      };
      "NSGlobalDomain" = {
        "NSTableViewDefaultSizeMode" = 1;
        "WebKitDeveloperExtras" = true;
      };
      "com.apple.ImageCapture" = { "disableHotPlug" = true; };
      "com.apple.Safari" = {
        "IncludeInternalDebugMenu" = true;
        "IncludeDevelopMenu" = true;
        "WebKitDeveloperExtrasEnabledPreferenceKey" = true;
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" =
          true;
      };
    };

    screencapture.location = "/Users/darren/Downloads";
    LaunchServices = {
      # Disable the "Are you sure you want to open this application?" dialog
      LSQuarantine = false;
    };
  };

  nix.configureBuildUsers = true;
  nix.useDaemon = true;
  services.nix-daemon.enable = true;
  services.yabai.enable = true;
  services.skhd.enable = true;
}
