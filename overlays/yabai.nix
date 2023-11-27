final: prev: {
  yabai = prev.yabai.overrideAttrs (old: {
    prePatch = ''
      substituteInPlace makefile \
        --replace "-std=c99" "-std=c99 -Wno-error=implicit-function-declaration"
    '';
  });
}
