{
  config,
  lib,
  pkgs,
  ...
}: let
  # LaunchServices registers every Nix-managed .app it sees (store paths,
  # Home Manager's app copies) and never forgets one after it is deleted. A
  # stale bundle keeps claiming URL schemes and file types, so links open
  # apps that are no longer installed.
  prune = pkgs.writeShellApplication {
    name = "prune-launchservices";
    runtimeInputs = with pkgs; [coreutils gawk python3];
    text = ''
      lsregister=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
      domain=com.apple.LaunchServices/com.apple.launchservices.secure

      dump=$(mktemp)
      handlers=$(mktemp)
      trap 'rm -f "$dump" "$handlers"' EXIT
      "$lsregister" -dump >"$dump" 2>/dev/null || true

      # One "<path>\t<bundle id>" line per registered bundle.
      bundles() {
        awk '
          /^path: +\// { path = $0; sub(/^path: +/, "", path); sub(/ \(0x[0-9a-f]+\)$/, "", path) }
          /^identifier: +/ { if (path != "") print path "\t" $2; path = "" }
        ' "$dump" | sort -u
      }

      # Live ids span every existing bundle, not just store ones: an app whose
      # only surviving copy is outside the store still owns its handlers.
      stale_ids=()
      live_ids=" "
      while IFS=$'\t' read -r app id; do
        if [ -e "$app" ]; then
          live_ids+="$id "
        elif [[ "$app" == /nix/store/*.app || "$app" == "$HOME/Applications/Home Manager Apps/"*.app ]]; then
          echo "unregistering $app"
          "$lsregister" -u "$app" >/dev/null 2>&1 || true
          stale_ids+=("$id")
        fi
      done < <(bundles)

      # A bundle id that only ever came from deleted store paths has no app
      # left to open; drop any URL/file handler still pointing at it so
      # LaunchServices falls back to an installed claimant.
      orphaned=()
      for id in "''${stale_ids[@]}"; do
        [[ "$live_ids" == *" $id "* ]] || orphaned+=("$id")
      done
      [ "''${#orphaned[@]}" -gt 0 ] || exit 0

      /usr/bin/defaults export "$domain" "$handlers"
      removed=$(python3 - "$handlers" "''${orphaned[@]}" <<'EOF'
      import plistlib, sys
      path, orphaned = sys.argv[1], {i.lower() for i in sys.argv[2:]}
      with open(path, "rb") as f:
          prefs = plistlib.load(f)
      kept, removed = [], 0
      for h in prefs.get("LSHandlers", []):
          roles = {str(v).lower() for k, v in h.items() if k.startswith("LSHandlerRole")}
          if roles & orphaned:
              removed += 1
          else:
              kept.append(h)
      prefs["LSHandlers"] = kept
      with open(path, "wb") as f:
          plistlib.dump(prefs, f)
      print(removed)
      EOF
      )
      if [ "$removed" -gt 0 ]; then
        echo "removing $removed handler(s) for ''${orphaned[*]}"
        /usr/bin/defaults import "$domain" "$handlers"
        /usr/bin/killall lsd 2>/dev/null || true
      fi
    '';
  };
in
  lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    home = {
      packages = [prune];
      activation.pruneLaunchServices = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD ${lib.getExe prune}
      '';
    };

    # nix.gc runs weekly as root, after the last switch; this catches the
    # bundles it deletes.
    launchd.agents.prune-launchservices = {
      enable = true;
      config = {
        ProgramArguments = [(lib.getExe prune)];
        StartCalendarInterval = [
          {
            Hour = 12;
            Minute = 0;
          }
        ];
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/prune-launchservices.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/prune-launchservices.log";
      };
    };
  }
