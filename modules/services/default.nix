{lib, ...}: {
  imports = [
    ./adguard-home.nix
    ./home-assistant
    ./matter-server.nix
    ./nginx.nix
    ./tailscale.nix
  ];
}
