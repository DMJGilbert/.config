{
  config,
  lib,
  pkgs,
  ...
}: {
  # Install AeroSpace, JankyBorders, and SketchyBar
  home.packages = with pkgs; [
    aerospace
    jankyborders
    sketchybar
  ];

  # Link the AeroSpace config file
  home.file.".aerospace.toml".source = ./aerospace.toml;

  # SketchyBar configuration
  home.file.".config/sketchybar/sketchybarrc" = {
    source = ./sketchybarrc;
    executable = true;
  };

  home.file.".config/sketchybar/plugins/aerospace.sh" = {
    source = ./sketchybar-plugin-aerospace.sh;
    executable = true;
  };

  # Create border color switcher script
  home.file.".local/bin/aerospace-set-border-color" = {
    text = ''
      #!/usr/bin/env bash
      # Script to change JankyBorders color
      # Usage: aerospace-set-border-color <color_hex>

      killall borders 2>/dev/null
      exec borders active_color="$1" inactive_color=0x00000000 width=10.0 &
    '';
    executable = true;
  };

  # Workspace cycling script - next
  home.file.".local/bin/aerospace-workspace-next" = {
    text = ''
      #!/usr/bin/env bash
      # Cycle to next workspace in order: W -> C -> P -> F -> W
      CURRENT=$(aerospace list-workspaces --focused)
      case "$CURRENT" in
        W) aerospace workspace C ;;
        C) aerospace workspace P ;;
        P) aerospace workspace F ;;
        F) aerospace workspace W ;;
        *) aerospace workspace W ;;
      esac
    '';
    executable = true;
  };

  # Workspace cycling script - previous
  home.file.".local/bin/aerospace-workspace-prev" = {
    text = ''
      #!/usr/bin/env bash
      # Cycle to previous workspace in order: W <- C <- P <- F <- W
      CURRENT=$(aerospace list-workspaces --focused)
      case "$CURRENT" in
        W) aerospace workspace F ;;
        C) aerospace workspace W ;;
        P) aerospace workspace C ;;
        F) aerospace workspace P ;;
        *) aerospace workspace W ;;
      esac
    '';
    executable = true;
  };

  # Launch JankyBorders at login
  launchd.agents.jankyborders = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.jankyborders}/bin/borders"
        "active_color=0xff81c8be"
        "inactive_color=0x00000000"
        "width=10.0"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive";
      StandardOutPath = "/tmp/jankyborders.log";
      StandardErrorPath = "/tmp/jankyborders.error.log";
    };
  };

  # Note: SketchyBar is started by AeroSpace via after-startup-command
  # See .aerospace.toml for the configuration

  # Optional: Create a helper script for manual border control
  # Useful for debugging or custom automations
  home.file.".local/bin/aerospace-border-mode" = {
    text = ''
      #!/usr/bin/env bash
      # Helper script to manually change border colors
      # Usage: aerospace-border-mode [default|move|resize|switch]

      case "$1" in
        default|main)
          borders active_color=0xff81c8be inactive_color=0x00000000 width=10.0
          ;;
        move)
          borders active_color=0xffef9f76 inactive_color=0x00000000 width=10.0
          ;;
        resize)
          borders active_color=0xffe5c890 inactive_color=0x00000000 width=10.0
          ;;
        switch)
          borders active_color=0xffe78284 inactive_color=0x00000000 width=10.0
          ;;
        *)
          echo "Usage: aerospace-border-mode [default|move|resize|switch]"
          exit 1
          ;;
      esac
    '';
    executable = true;
  };
}
