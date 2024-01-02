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
      "docker"
      "displaylink"
      "figma"
      "librewolf"
      "teamviewer"
      "qmk-toolbox"
      "vlc"
    ];
  };
}
