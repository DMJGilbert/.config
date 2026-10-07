# Builds the room views of the YAML-mode dashboard. Every room shares the
# frame built here (hero image, light chip, tab bar, Lights tab); each room
# supplies its own Media, Climate and Other tab contents from the card
# helpers below. The button-card templates referenced by name (room_hero,
# room_item_card, …) live in dashboard.yaml.
#
# Stacks are HA's native vertical-stack, which builds its children in one
# pass; wrappers that build them asynchronously (stack-in-card) leave tab
# contents blank for seconds on first load.
{lib}: let
  stack = cards: {
    type = "vertical-stack";
    inherit cards;
  };

  # card-mod only styles cards that render an ha-card, which a vertical-stack
  # does not; card-mod's own mod-card supplies one around the wrapped card.
  panel = style: card: {
    type = "custom:mod-card";
    card_mod.style = style;
    inherit card;
  };

  # Card and filter-rule builders for room tab contents.
  cards = rec {
    item = {
      entity,
      icon,
      toggle ? false,
      name ? null,
    }: {
      type = "custom:button-card";
      template = "room_item_card";
      inherit entity;
      variables =
        {
          item_icon = icon;
          item_entity = entity;
          show_toggle = toggle;
        }
        // lib.optionalAttrs (name != null) {item_name = name;};
    };

    sensor = {
      entity,
      icon,
      name ? null,
    }: {
      type = "custom:button-card";
      template = "room_sensor_card";
      inherit entity;
      variables =
        {
          sensor_icon = icon;
          sensor_entity = entity;
        }
        // lib.optionalAttrs (name != null) {sensor_name = name;};
    };

    # auto-entities rules: each matched entity is rendered as item or sensor.
    itemRule = {
      domain,
      match,
      attributes ? null,
      ...
    } @ args:
      {
        inherit domain;
        entity_id = match;
        options = item ({entity = "this.entity_id";} // removeAttrs args ["domain" "match" "attributes"]);
      }
      // lib.optionalAttrs (attributes != null) {inherit attributes;};

    sensorRule = {match, ...} @ args: {
      domain = "sensor";
      entity_id = match;
      options = sensor ({entity = "this.entity_id";} // removeAttrs args ["match"]);
    };

    auto = {
      include,
      exclude ? [{state = "unavailable";}],
      showEmpty ? false,
      unique ? false,
    }:
      {
        type = "custom:auto-entities";
        card.type = "vertical-stack";
        filter = {inherit include exclude;};
        sort.method = "friendly_name";
        show_empty = showEmpty;
        card_param = "cards";
      }
      // lib.optionalAttrs unique {inherit unique;};

    # A tab's first heading sits closer to the tab bar than later ones.
    headingWith = padding: name: {
      type = "custom:button-card";
      template = "transparent";
      inherit name;
      styles = {
        card = [{inherit padding;}];
        name = [
          {"font-size" = "14px";}
          {"font-weight" = 600;}
          {color = "var(--secondary-text-color)";}
          {"text-transform" = "uppercase";}
          {"letter-spacing" = "0.5px";}
          {"justify-self" = "start";}
        ];
      };
      tap_action.action = "none";
    };
    firstHeading = headingWith "8px 0 4px 0";
    heading = headingWith "16px 0 4px 0";

    # Filters shared by most rooms, keyed by the entity_id fragments that
    # identify the room's devices.
    mediaAuto = {
      slugs,
      icon ? "mdi:speaker",
      showEmpty ? true,
    }:
      auto {
        include = map (slug:
          itemRule {
            domain = "media_player";
            match = "*${slug}*";
            inherit icon;
          })
        slugs;
        inherit showEmpty;
      };

    climateAuto = {
      slugs,
      showEmpty ? true,
    }:
      auto {
        include =
          map (slug:
            itemRule {
              domain = "climate";
              match = "*${slug}*";
              icon = "mdi:thermostat";
            })
          slugs
          ++ map (slug:
            itemRule {
              domain = "fan";
              match = "*${slug}*";
              icon = "mdi:fan";
              toggle = true;
            })
          slugs;
        inherit showEmpty;
      };

    climateSensorsAuto = slugs:
      auto {
        include =
          lib.concatMap (slug: [
            (sensorRule {
              match = "*${slug}*temperature*";
              icon = "mdi:thermometer";
            })
            (sensorRule {
              match = "*${slug}*humidity*";
              icon = "mdi:water-percent";
            })
          ])
          slugs;
      };

    motionAuto = {
      slug,
      motionAttributes ? null,
    }:
      auto {
        include = [
          (itemRule {
            domain = "binary_sensor";
            match = "*${slug}*motion*";
            attributes = motionAttributes;
            icon = "mdi:motion-sensor";
          })
          (itemRule {
            domain = "binary_sensor";
            match = "*${slug}*occupancy*";
            icon = "mdi:motion-sensor";
          })
        ];
        unique = true;
      };

    roomSensorsAuto = rules:
      auto {
        include = map sensorRule rules;
        exclude = [
          {state = "unavailable";}
          {entity_id = "*signal*";}
        ];
      };
  };

  tabs = ["lights" "media" "climate" "other"];

  tabButton = active: tab: {
    type = "custom:button-card";
    template =
      if tab == active
      then "tab_button_active"
      else "tab_button_inactive";
    name = lib.toUpper (lib.substring 0 1 tab) + lib.substring 1 (-1) tab;
    tap_action = {
      action = "navigate";
      navigation_path = "#tab-${tab}";
    };
  };

  tabState = active: content:
    panel ''
      ha-card {
        margin: 0 16px 16px 16px;
        border: none;
        border-radius: 24px;
        box-shadow: 0 4px 24px rgba(0,0,0,0.15);
        overflow: hidden;
        background: var(--card-background-color, #fff);
      }
      @media (min-width: 768px) {
        ha-card { margin: 0 0 16px 0; }
      }
    '' (stack [
      {
        type = "horizontal-stack";
        cards = map (tabButton active) tabs;
      }
      (panel ''
        ha-card {
          padding: 12px 16px 8px 16px;
          border: none;
          background: transparent;
          box-shadow: none;
        }
      '' (stack content))
    ]);

  hero = room:
    panel {
      "hui-vertical-stack-card $" = ''
        #root { gap: 0 !important; }
      '';
      "." = ''
        ha-card {
          border: none;
          border-radius: 24px;
          margin: 16px 16px 16px 16px;
          box-shadow: 0 4px 24px rgba(0,0,0,0.15);
          overflow: hidden;
          background: var(--card-background-color, #fff);
        }
        @media (min-width: 768px) {
          ha-card { margin: 16px 0 16px 0; }
        }
      '';
    } (stack [
      {
        type = "custom:button-card";
        template = "room_hero";
        variables.room_name = room.name;
        card_mod.style = ''
          ha-card {
            height: 200px !important;
            border-radius: 0;
            box-shadow: none;
            margin-bottom: 8px;
            background-image: linear-gradient(to bottom, rgba(0,0,0,0.4) 0%, rgba(0,0,0,0.2) 40%, rgba(0,0,0,0.1) 60%, rgba(0,0,0,0.3) 100%), url("${room.image}") !important;
            background-size: cover !important;
            background-position: center !important;
          }
          @media (min-width: 768px) {
            ha-card { height: 240px !important; }
          }
          @media (min-width: 1200px) {
            ha-card { height: 280px !important; }
          }
        '';
      }
      {
        type = "custom:mushroom-chips-card";
        alignment = "center";
        card_mod.style = ''
          ha-card {
            --chip-background: var(--card-background-color);
            --chip-box-shadow: 0 2px 8px rgba(0,0,0,0.15);
            --chip-border-radius: 24px;
            --chip-padding: 0 12px;
            --chip-height: 36px;
            background: transparent;
            margin-top: -50px;
            position: relative;
            z-index: 1;
          }
        '';
        chips = [
          {
            type = "template";
            entity = room.lightGroup;
            icon = "mdi:lightbulb";
            icon_color = "{{ 'amber' if is_state('${room.lightGroup}', 'on') else 'grey' }}";
            content = "{{ expand('${room.lightGroup}') | selectattr('state', 'eq', 'on') | list | count }}";
          }
        ];
      }
    ]);

  lightsTab = room: [
    (cards.auto {
      include = [
        {
          group = room.lightGroup;
          options = cards.item {
            entity = "this.entity_id";
            icon = "mdi:lightbulb";
            toggle = true;
          };
        }
      ];
      exclude = [
        {entity_id = "*coordinator*";}
        {state = "unavailable";}
      ];
      showEmpty = true;
    })
  ];

  mkView = room: {
    title = room.name;
    path = "room-${room.path}";
    inherit (room) icon;
    panel = true;
    cards = [
      {
        type = "custom:layout-card";
        layout_type = "custom:grid-layout";
        layout = {
          "grid-template-columns" = "1fr";
          margin = "0 auto";
        };
        card_mod.style = ''
          :host {
            max-width: 600px !important;
            margin: 0 auto !important;
            display: block !important;
          }
          @media (min-width: 768px) {
            :host { max-width: 800px !important; }
          }
          @media (min-width: 1200px) {
            :host { max-width: 1200px !important; }
          }
        '';
        cards = [
          (hero room)
          {
            type = "custom:state-switch";
            entity = "hash";
            default = "tab-lights";
            states = {
              tab-lights = tabState "lights" (lightsTab room);
              tab-media = tabState "media" room.media;
              tab-climate = tabState "climate" room.climate;
              tab-other = tabState "other" room.other;
            };
          }
        ];
      }
    ];
  };
in {
  inherit cards mkView;
}
