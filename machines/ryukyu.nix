{...}: {
  imports = [./shared.nix];

  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    primaryUser = "darren";
    stateVersion = 5;
    keyboard = {
      enableKeyMapping = true;
      # use caps lock as ctrl instead of YELLING
      remapCapsLockToControl = true;
    };
    defaults = {
      loginwindow = {
        GuestEnabled = false;
        DisableConsoleAccess = true;
      };
      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        _FXShowPosixPathInTitle = true;
      };
      menuExtraClock = {
        ShowSeconds = true;
        Show24Hour = true;
        ShowAMPM = false;
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
        AppleFontSmoothing = 2;

        # Finder: show all filename extensions
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "Automatic";
      };

      CustomUserPreferences = {
        "com.apple.screensaver" = {
          "askForPassword" = true;
          "askForPasswordDelay" = 0;
        };
        "com.apple.trackpad" = {"scaling" = 2;};
        "com.apple.mouse" = {"scaling" = 2.5;};
        "com.apple.desktopservices" = {"DSDontWriteNetworkStores" = false;};
        "com.apple.finder" = {
          "ShowExternalHardDrivesOnDesktop" = false;
          "ShowRemovableMediaOnDesktop" = false;
          "WarnOnEmptyTrash" = false;
        };
        "com.apple.LaunchServices" = {
          "LSQuarantine" = false;
        };
        "NSGlobalDomain" = {
          "NSTableViewDefaultSizeMode" = 1;
          "WebKitDeveloperExtras" = true;
          "NSAutomaticWindowAnimationsEnabled" = false;
          "NSDisableAutomaticTermination" = true;
          "NSWindowResizeTime" = 0.001;
          "NSUseAnimatedFocusRing" = false;
        };
        "com.apple.ImageCapture" = {"disableHotPlug" = true;};
        "com.apple.Safari" = {
          "IncludeInternalDebugMenu" = true;
          "IncludeDevelopMenu" = true;
          "WebKitDeveloperExtrasEnabledPreferenceKey" = true;
          "AutoOpenSafeDownloads" = false;
          "ShowFullURLInSmartSearchField" = true;
          "UniversalSearchEnabled" = false;
          "SuppressSearchSuggestions" = true;
          "FindOnPageMatchesWordStartsOnly" = false;
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
  };

  services = {
    yabai = {
      enable = true;
      enableScriptingAddition = true;
      config = {
        mouse_follows_focus = "off";
        focus_follows_mouse = "off";
        window_shadow = "off";
        window_opacity = "on";
        window_opacity_duration = "0.0";
        active_window_opacity = "1.0";
        normal_window_opacity = "1.0";
        split_ratio = "0.60";
        auto_balance = "off";
        mouse_modifier = "fn";
        mouse_action1 = "move";
        mouse_action2 = "resize";
        mouse_drop_action = "swap";
        layout = "bsp";
        top_padding = 5;
        bottom_padding = 5;
        left_padding = 5;
        right_padding = 5;
        window_gap = 5;
      };
      extraConfig = ''
        borders active_color=0xff00c1ad inactive_color=0x00000000 width=10.0 &

        yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
        sudo yabai --load-sa

        # ===== Rules ==================================

        yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
        yabai -m rule --add label="Safari" app="^Safari$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance)$" manage=off
        yabai -m rule --add label="System Preferences" app="^System Preferences$" title=".*" manage=off
        yabai -m rule --add label="App Store" app="^App Store$" manage=off
        yabai -m rule --add label="Activity Monitor" app="^Activity Monitor$" manage=off
        yabai -m rule --add label="KeePassXC" app="^KeePassXC$" manage=off
        yabai -m rule --add label="Calculator" app="^Calculator$" manage=off
        yabai -m rule --add label="Dictionary" app="^Dictionary$" manage=off
        yabai -m rule --add label="Software Update" title="Software Update" manage=off
        yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off

        yabai -m signal --add event=window_destroyed active=yes action="yabai -m query --windows --window &> /dev/null || yabai -m window --focus mouse &> /dev/null || yabai -m window --focus \$(yabai -m query --windows --space | jq .[0].id) &> /dev/null"
      '';
    };
    skhd = {
      enable = true;
      skhdConfig = ''
        :: default : borders active_color=0xff81c8be
        :: resize_win @ : borders active_color=0xffe5c890
        :: move_win @ : borders active_color=0xffef9f76
        :: switch_win @ : borders active_color=0xffe78284

        default     < hyper - m     ; move_win
        default     < hyper - r     ; resize_win
        default     < hyper - c     ; switch_win
        resize_win  < hyper - m     ; move_win
        resize_win  < hyper - c     ; switch_win
        switch_win  < hyper - m     ; move_win
        switch_win  < hyper - r     ; resize_win
        move_win    < hyper - r     ; resize_win
        move_win    < hyper - c     ; switch_win

        resize_win  < escape        ; default
        move_win    < escape        ; default
        switch_win  < escape        ; default
        resize_win  < return        ; default
        move_win    < return        ; default
        switch_win  < return        ; default
        resize_win  < ctrl - c      ; default
        move_win    < ctrl - c      ; default
        switch_win  < ctrl - c      ; default

        hyper - q : yabai -m display --focus west
        hyper - w : yabai -m display --focus east

        hyper - a : yabai -m space --focus prev
        hyper - s : yabai -m space --focus next

        hyper - f : yabai -m window --toggle zoom-fullscreen
        hyper - x : yabai -m space --destroy
        hyper - t : yabai -m space --create;\
                    id="$(yabai -m query --spaces --display | jq 'map(select(."is-native-fullscreen" == false))[-1].index')";\
                    yabai -m window --space "$id";\
                    yabai -m space --focus "$id"

        hyper - space : yabai -m space --balance

        move_win < left : yabai -m window --warp west
        move_win < right : yabai -m window --warp east
        move_win < up : yabai -m window --warp north
        move_win < down : yabai -m window --warp south

        resize_win < left : yabai -m window --resize left:-50:0 || yabai -m window --resize right:-50:0
        resize_win < right : yabai -m window --resize right:50:0 || yabai -m window --resize left:50:0
        resize_win < down : yabai -m window --resize bottom:0:50 || yabai -m window --resize top:0:50
        resize_win < up : yabai -m window --resize top:0:-50 || yabai -m window --resize bottom:0:-50

        switch_win < left : yabai -m window --focus west
        switch_win < right : yabai -m window --focus east
        switch_win < up : yabai -m window --focus north
        switch_win < down : yabai -m window --focus south

        ctrl - return : /opt/homebrew/bin/wezterm start --always-new-process
        cmd - q : echo ""
      '';
    };
  };
}
