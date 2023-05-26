#!/usr/bin/env bash

# Install command tools for git
if ! xcode-select -p >/dev/null 2>&1; then
    echo "Command Line Tools not found. Installing..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
    softwareupdate -i "$PROD" --verbose;
fi
echo "Command Line Tools have been installed."

# Install nix
if ! command -v nix >/dev/null 2>&1; then
  echo "Nix not found. Installing Nix..."
  if [ "$(uname -s)" == "Darwin" ]; then
    sh <(curl -L https://nixos.org/nix/install)
  else
    sh <(curl -L https://nixos.org/nix/install) --daemon
  fi
fi
echo "Nix has been installed."
nixconfig=~/.config/nix/nix.conf
if [[ ! -f $nixconfig ]]; then
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" > $nixconfig
fi

# Clone the repo to a default location
configrepo=~/Developer/config
if [[ ! -e $configrepo ]]; then
    mkdir -p ~/Developer
    git clone https://github.com/dmjgilbert/.config $configrepo
fi
cd $configrepo || exit
