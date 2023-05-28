# .config

```sh
curl https://raw.githubusercontent.com/DMJGilbert/.config/feature/nix/bootstrap.sh -sSf | bash
# Optional homebrew install: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Rebuild
```sh
darwin-rebuild switch  --flake .
```
