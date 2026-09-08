# Home Manager backup command, shared by mkdarwin.nix and mknixos.nix.
#
# Home Manager invokes this as `<command> <targetPath>` whenever a real file
# sits where it wants to create a symlink. The command must move that file
# aside; Home Manager then creates the link.
#
# This replaces `backupFileExtension = "bak"`, which can only ever hold ONE
# backup per path. Tools that rewrite their own config behind Home Manager's
# back — Claude Code rewrites ~/.claude/settings.json when you change a
# setting — hit that limit the second time round, and activation aborts with
# "Existing file '<path>.bak' would be clobbered by backing up '<path>'".
# Timestamping makes the collision impossible.
pkgs:
pkgs.writeShellApplication {
  name = "hm-backup-file";
  runtimeInputs = [pkgs.coreutils];
  text = ''
    target="''${1:?hm-backup-file: no target path given}"

    # Nothing to do if it vanished between the check and now.
    [ -e "$target" ] || exit 0

    backup="$target.backup-$(date +%Y%m%d-%H%M%S)"

    # Two files backed up within the same second would still collide.
    suffix=0
    while [ -e "$backup" ]; do
      suffix=$((suffix + 1))
      backup="$target.backup-$(date +%Y%m%d-%H%M%S)-$suffix"
    done

    mv "$target" "$backup"
    echo "hm-backup: moved '$target' -> '$backup'" >&2
  '';
}
