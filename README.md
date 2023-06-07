# .config

Install
```sh
curl https://raw.githubusercontent.com/DMJGilbert/.config/feature/nix/bootstrap.sh -sSf | bash
```

Rebuild
```sh
darwin-rebuild switch  --flake .
```

Update
```sh
nix flake update .
```

Nix update:
```
sudo -i sh -c 'nix-channel --update && nix-env --install --attr nixpkgs.nix && launchctl remove org.nixos.nix-daemon && launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist'
```

Formatting:
```
nix run nixpkgs#alejandra -- --check ./
```
