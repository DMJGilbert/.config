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
    brews = ["fdk-aac" "opus" "openssl@1.1" "zeromq"];
    casks = [
      "alfred"
      "balenaetcher"
      "docker"
      "displaylink"
      "figma"
      "librewolf"
      "teamviewer"
      "qmk-toolbox"
      "wezterm"
    ];
  };
}
