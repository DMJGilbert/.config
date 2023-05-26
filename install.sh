sudo xcode-select --install
sudo xcodebuild -license

curl -sL https://nixos.org/nix/install | bash -
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
