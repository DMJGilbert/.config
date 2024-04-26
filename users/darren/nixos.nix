{pkgs, ...}: {
  programs.zsh.enable = true;
  users.users.darren = {
    isNormalUser = true;
    home = "/home/darren";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.zsh;
    initialPassword = "darren";
  };
}
