{pkgs, ...}: {
  users.users.darren = {
    name = "darren";
    home = "/Users/darren";
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap";
    global.brewfile = true;
    casks = [
      "alfred"
      "displaylink"
      "docker"
      "figma"
      "flutter"
      "librewolf"
      "microsoft-teams"
      "teamviewer"
      "qmk-toolbox"
      "vlc"
      "vmware-fusion"
      "wezterm"
    ];
  };
}
