# Disko declarative disk layout for rubecula (AMD Ryzen 8845HS mini PC)
#
# This config is for fresh installs via nixos-anywhere. It replaces the
# UUID-based fileSystems in hardware/rubecula.nix with a reproducible btrfs
# layout that supports impermanence (local.services.impermanence).
#
# To install from scratch:
#   nix run github:nix-community/nixos-anywhere -- --flake .#rubecula root@<ip>
#
# Disk layout:
#   /boot    512 MiB  FAT32 (EFI)
#   /        rest     btrfs, subvolumes:
#              @      → /        (ephemeral: wipe-on-boot via systemd service)
#              @nix   → /nix     (persistent: Nix store)
#              @persist → /persist (persistent: impermanence state)
#              @log   → /var/log (persistent: logs survive reboots)
#   swap     16 GiB  swap partition
#
# Verify the disk device before running:
#   lsblk -d -o NAME,SIZE,MODEL
{
  disko.devices.disk.main = {
    type = "disk";
    # Adjust to the actual device — check with: lsblk -d -o NAME,SIZE,MODEL
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          name = "ESP";
          start = "1MiB";
          end = "512MiB";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["fmask=0077" "dmask=0077"];
          };
        };
        swap = {
          size = "16GiB";
          content = {
            type = "swap";
            discardPolicy = "both";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = ["-f" "-L" "nixos"];
            subvolumes = {
              "@" = {
                mountpoint = "/";
                mountOptions = ["compress=zstd" "noatime"];
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = ["compress=zstd" "noatime"];
              };
              "@persist" = {
                mountpoint = "/persist";
                mountOptions = ["compress=zstd" "noatime"];
              };
              "@log" = {
                mountpoint = "/var/log";
                mountOptions = ["compress=zstd" "noatime"];
              };
            };
          };
        };
      };
    };
  };
}
