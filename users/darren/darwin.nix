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
      "figma"
      "librewolf"
      "teamviewer"
      "wezterm"
      "qmk-toolbox"
      "vlc"
      "vmware-fusion"
    ];
  };
}
