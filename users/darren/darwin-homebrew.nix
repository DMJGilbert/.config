_: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      extraFlags = ["--force-cleanup"];
    };
    global.brewfile = true;
    brews = [
      "xcode-build-server" # sourcekit-lsp outside of xcode
      "ifstat"
    ];
    casks = [
      "claude-code"
      "displaylink"
      "docker-desktop"
      "figma"
      "swiftformat-for-xcode"
      "teamviewer"
      "qmk-toolbox"
      "vlc"
    ];
  };
}
