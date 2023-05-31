{ pkgs, ... }:

{
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
    brews = [ "openssl@1.1" "zeromq" ];
    casks =
      [ "alfred" "docker" "displaylink" "figma" "teamviewer" "qmk-toolbox" ];
  };
}
