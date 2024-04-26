{
  config,
  pkgs,
  modulesPath,
  ...
}: {
  # Be careful updating this.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  imports = [
    ./shared.nix
  ];

  networking.hostName = "passerine";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # VMware, Parallels both only support this being 0 otherwise you see
  # "error switching console mode" on boot.
  boot.loader.systemd-boot.consoleMode = "0";

  # Qemu
  services.spice-vdagentd.enable = true;

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  # For now, we need this since hardware acceleration does not work.
  environment.variables.LIBGL_ALWAYS_SOFTWARE = "1";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "no";

  # Disable the firewall since we're in a VM and we want to make it
  # easy to visit stuff in here. We only use NAT networking anyways.
  networking.firewall.enable = false;

  # Virtualization settings
  virtualisation.docker.enable = true;

  virtualisation.vmware.guest.enable = true;

  # Shared folder to host works on Intel
  fileSystems."/host" = {
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    device = ".host:/";
    options = [
      "umask=22"
      "uid=1000"
      "gid=1000"
      "allow_other"
      "auto_unmount"
      "defaults"
    ];
  };

  system.stateVersion = "23.04";
}
