{pkgs, ...}: let
  # Main files
  dashboardYaml = pkgs.writeText "home.yaml" (builtins.readFile ./dashboard.yaml);
  floorplanSvg = ./floorplan.svg;

  # Directories (automatically includes all files)
  viewsDir = ./views;
  templatesDir = ./templates;
  popupsDir = ./popups;
in {
  # Symlink dashboard files to Home Assistant config directory
  systemd.tmpfiles.rules = [
    # Main files
    "L+ /var/lib/hass/home.yaml - - - - ${dashboardYaml}"
    "L+ /var/lib/hass/floorplan.svg - - - - ${floorplanSvg}"

    # Directories
    "L+ /var/lib/hass/views - - - - ${viewsDir}"
    "L+ /var/lib/hass/templates - - - - ${templatesDir}"
    "L+ /var/lib/hass/popups - - - - ${popupsDir}"
  ];

  # Configure Home Assistant to use the dashboard
  services.home-assistant.config = {
    lovelace = {
      dashboards = {
        lovelace-home = {
          mode = "yaml";
          filename = "home.yaml";
          title = "Fleming Place";
          icon = "mdi:home-assistant";
          show_in_sidebar = true;
          require_admin = false;
        };
      };
    };
  };
}
