{
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  # Install AeroSpace, JankyBorders, and SketchyBar
  home = {
    packages = with pkgs; [
      aerospace
      jankyborders
      sketchybar
    ];

    file = {
      # Link the AeroSpace config file
      ".aerospace.toml".source = ./aerospace.toml;

      # SketchyBar configuration
      ".config/sketchybar/sketchybarrc" = {
        source = ./config/sketchybar/sketchybarrc;
        executable = true;
      };

      ".config/sketchybar/plugins/aerospace.sh" = {
        source = ./config/sketchybar/plugins/aerospace.sh;
        executable = true;
      };

      ".config/sketchybar/plugins/aerospace_refresh.sh" = {
        source = ./config/sketchybar/plugins/aerospace_refresh.sh;
        executable = true;
      };

      ".config/sketchybar/plugins/aerospace_update_all.sh" = {
        source = ./config/sketchybar/plugins/aerospace_update_all.sh;
        executable = true;
      };

      ".config/sketchybar/plugins/clock.sh" = {
        source = ./config/sketchybar/plugins/clock.sh;
        executable = true;
      };

      ".config/sketchybar/plugins/battery.sh" = {
        source = ./config/sketchybar/plugins/battery.sh;
        executable = true;
      };

      ".config/sketchybar/plugins/ram.sh" = {
        source = ./config/sketchybar/plugins/ram.sh;
        executable = true;
      };

      ".config/sketchybar/plugins/cpu.sh" = {
        source = ./config/sketchybar/plugins/cpu.sh;
        executable = true;
      };

      ".config/sketchybar/plugins/network.sh" = {
        source = ./config/sketchybar/plugins/network.sh;
        executable = true;
      };

      # Workspace cycling script - next
      ".local/bin/aerospace-workspace-next" = {
        text = ''
          #!/usr/bin/env bash
          # Cycle to next workspace in order: W -> R -> C -> P -> F -> W
          CURRENT=$(/etc/profiles/per-user/darren/bin/aerospace list-workspaces --focused)
          case "$CURRENT" in
            W) /etc/profiles/per-user/darren/bin/aerospace workspace R ;;
            R) /etc/profiles/per-user/darren/bin/aerospace workspace C ;;
            C) /etc/profiles/per-user/darren/bin/aerospace workspace P ;;
            P) /etc/profiles/per-user/darren/bin/aerospace workspace F ;;
            F) /etc/profiles/per-user/darren/bin/aerospace workspace W ;;
            *) /etc/profiles/per-user/darren/bin/aerospace workspace W ;;
          esac
        '';
        executable = true;
      };

      # Workspace cycling script - previous
      ".local/bin/aerospace-workspace-prev" = {
        text = ''
          #!/usr/bin/env bash
          # Cycle to previous workspace in order: W <- R <- C <- P <- F <- W
          CURRENT=$(/etc/profiles/per-user/darren/bin/aerospace list-workspaces --focused)
          case "$CURRENT" in
            W) /etc/profiles/per-user/darren/bin/aerospace workspace F ;;
            R) /etc/profiles/per-user/darren/bin/aerospace workspace W ;;
            C) /etc/profiles/per-user/darren/bin/aerospace workspace R ;;
            P) /etc/profiles/per-user/darren/bin/aerospace workspace C ;;
            F) /etc/profiles/per-user/darren/bin/aerospace workspace P ;;
            *) /etc/profiles/per-user/darren/bin/aerospace workspace W ;;
          esac
        '';
        executable = true;
      };
    };
  };

  # Launch JankyBorders at login
  launchd.agents.jankyborders = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.jankyborders}/bin/borders"
        "active_color=0xff00c1ad"
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

  # Launch SketchyBar at login
  launchd.agents.sketchybar = {
    enable = true;
    config = {
      ProgramArguments = ["${pkgs.sketchybar}/bin/sketchybar"];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive";
      StandardOutPath = "/tmp/sketchybar.log";
      StandardErrorPath = "/tmp/sketchybar.error.log";
      EnvironmentVariables = {
        PATH = "/etc/profiles/per-user/darren/bin:/run/current-system/sw/bin:${pkgs.sketchybar}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
    };
  };
}
