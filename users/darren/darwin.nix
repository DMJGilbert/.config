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
    brews = [
      "xcode-build-server" # sourcekit-lsp outside of xcode
      "ifstat"
    ];
    casks = [
      "claude-code"
      "displaylink"
      "docker-desktop"
      "flutter"
      "swiftformat-for-xcode"
      "librewolf"
      "microsoft-teams"
      "obsidian"
      "teamviewer"
      "qmk-toolbox"
      "vlc"
      "vmware-fusion"
      "wezterm"
    ];
  };
}
