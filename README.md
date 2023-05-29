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
