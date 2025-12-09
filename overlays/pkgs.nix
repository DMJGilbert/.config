final: prev: {
  hass-catppuccin = final.callPackage ./hass-catppuccin.nix {};
  hass-bubble-card = final.callPackage ./hass-bubble-card.nix {};
  lovelace-auto-entities = final.callPackage ./lovelace-auto-entities.nix {};
  lovelace-tabbed-card = final.callPackage ./lovelace-tabbed-card.nix {};
  lovelace-layout-card = final.callPackage ./lovelace-layout-card.nix {};
}
