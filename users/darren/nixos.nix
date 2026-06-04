{
  config,
  pkgs,
  ...
}: {
  programs.zsh.enable = true;
  users.users.darren = {
    isNormalUser = true;
    home = "/home/darren";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets."DARREN_PASSWORD".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFH8IIyjwbibIv0rnDE3SJ/StlKjcQG1NuKeEuBwTH5+ dmjgilbert@me.com"
    ];
  };
}
