#!/usr/bin/env bash

# Install command tools for git
if ! xcode-select -p >/dev/null 2>&1; then
	echo "Command Line Tools not found. Installing..."
	touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
	PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
	softwareupdate -i "$PROD" --verbose
fi
echo "Command Line Tools have been installed."

# Install nix
if ! command -v nix >/dev/null 2>&1; then
	echo "Nix not found. Installing Nix..."
	if [ "$(uname -s)" = "Darwin" ]; then
		sh <(curl -L https://nixos.org/nix/install)
	else
		sh <(curl -L https://nixos.org/nix/install) --daemon
	fi
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
echo "Nix has been installed."
nixconfig=~/.config/nix/nix.conf
if [[ ! -f $nixconfig ]]; then
	mkdir -p ~/.config/nix
	echo "experimental-features = nix-command flakes" >$nixconfig
fi

# Clone the repo to a default location
configrepo=~/Developer/config
if [[ ! -e $configrepo ]]; then
	mkdir -p ~/Developer
	git clone https://github.com/dmjgilbert/.config $configrepo
fi
cd $configrepo || exit

nix --extra-experimental-features "nix-command flakes" flake update
nix --extra-experimental-features "nix-command flakes" build .#darwinConfigurations.macbook.system

sudo echo -e "run\tprivate/var/run" >>/etc/synthetic.conf
/System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -B
/System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t
./result/sw/bin/darwin-rebuild switch --flake .#macbook
. /etc/static/bashrc
