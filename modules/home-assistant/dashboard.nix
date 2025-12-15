{pkgs, ...}: let
  floorplanSvg = ./floorplan.svg;
  dashboardYaml = pkgs.writeText "hacasa.yaml" (builtins.readFile ./dashboard.yaml);
in {
  # Copy the dashboard YAML to Home Assistant config directory
  systemd.tmpfiles.rules = [
    "L+ /var/lib/hass/home.yaml - - - - ${dashboardYaml}"
    "L+ /var/lib/hass/floorplan.svg - - - - ${floorplanSvg}"
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
