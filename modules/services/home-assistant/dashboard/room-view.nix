# Builds the room views of the YAML-mode dashboard. Every room shares the
# frame built here (a floorplan header with reading tiles where the room has
# one, else a hero image and light chip; tab bar; Lights tab); each room
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
      icon ? "fp:speaker",
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
              icon = "fp:thermostat";
            })
          slugs
          ++ map (slug:
            itemRule {
              domain = "fan";
              match = "*${slug}*";
              icon = "fp:fan";
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
              icon = "fp:thermometer";
            })
            (sensorRule {
              match = "*${slug}*humidity*";
              icon = "fp:water";
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
            icon = "fp:motion";
          })
          (itemRule {
            domain = "binary_sensor";
            match = "*${slug}*occupancy*";
            icon = "fp:motion";
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
        background: transparent;
        box-shadow: none;
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

  heroFrame = contents:
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
    } (stack contents);

  # Readings outside these bands are coloured: cold or damp in blue, warm or
  # dry in orange.
  comfort = {
    temperature = {
      label = "Temperature";
      icon = "fp:thermometer";
      text = "v.toFixed(1) + '°'";
      below = 18;
      low = "blue";
      above = 23;
      high = "orange";
    };
    humidity = {
      label = "Humidity";
      icon = "fp:water";
      text = "v.toFixed(0) + '%'";
      below = 40;
      low = "orange";
      above = 60;
      high = "blue";
    };
  };

  # A reading laid over a floorplan header: icon, value, and what it is.
  headerTile = {
    entity,
    icon,
    label,
    value,
    colour ? "var(--primary-text-color)",
  }: {
    type = "custom:button-card";
    inherit entity icon label;
    show_name = false;
    show_label = true;
    show_state = true;
    state_display = "[[[ ${value} ]]]";
    tap_action.action = "more-info";
    styles = {
      card = [
        {padding = "8px 10px";}
        {border-radius = "14px";}
        {background = "var(--card-background-color)";}
        {box-shadow = "0 2px 8px rgba(0,0,0,0.15)";}
      ];
      grid = [
        {grid-template-areas = "\"i s\" \"i l\"";}
        {grid-template-columns = "24px 1fr";}
        {column-gap = "8px";}
      ];
      icon = [
        {width = "20px";}
        {color = "var(--secondary-text-color)";}
      ];
      state = [
        {justify-self = "start";}
        {font-size = "15px";}
        {font-weight = 600;}
        {color = colour;}
      ];
      label = [
        {justify-self = "start";}
        {font-size = "11px";}
        {color = "var(--secondary-text-color)";}
      ];
    };
  };

  readingTile = kind: entity: let
    band = comfort.${kind};
  in
    headerTile {
      inherit entity;
      inherit (band) icon label;
      value = "const v = parseFloat(entity.state); return isNaN(v) ? '–' : ${band.text};";
      colour = "[[[ const v = parseFloat(entity.state); return v < ${toString band.below} ? 'var(--${band.low}-color)' : v > ${toString band.above} ? 'var(--${band.high}-color)' : 'var(--primary-text-color)'; ]]]";
    };

  # "Now" while the sensor detects someone, else when it last did: the time
  # today, with the weekday before that. An offline sensor's last change is
  # when it dropped out, not motion, so it reads as unavailable.
  motionTile = entity:
    headerTile {
      inherit entity;
      icon = "fp:motion";
      label = "Last motion";
      value = "if (entity.state === 'on') return 'Now'; if (entity.state !== 'off') return 'Unavailable'; const t = new Date(entity.last_changed); const time = t.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'}); return t.toDateString() === new Date().toDateString() ? time : t.toLocaleDateString([], {weekday: 'short'}) + ' ' + time;";
    };

  # A room with a floorplan header (dashboard/floorplan) shows it in place
  # of the photo, with its readings as tiles under it on the drawing's
  # background. Under, not over: the drawing scales with the card's width,
  # so no fixed overlap is sure to stay clear of its markers.
  floorplanHero = header: let
    tiles =
      lib.optionals (header ? climate) [
        (readingTile "temperature" header.climate.temperature)
        (readingTile "humidity" header.climate.humidity)
      ]
      ++ lib.optional (header ? motion) (motionTile header.motion);
  in
    heroFrame ([header.card]
      ++ lib.optional (tiles != []) (panel ''
          ha-card {
            background: var(--primary-background-color);
            border: none;
            border-radius: 0;
            box-shadow: none;
            padding: 0 12px 12px 12px;
          }
        '' {
          type = "horizontal-stack";
          cards = tiles;
        }));

  hero = room:
    heroFrame [
      {
        type = "custom:button-card";
        template = "room_hero";
        variables.room_name = room.name;
        card_mod.style = ''
          ha-card {
            height: 200px !important;
            border-radius: 0;
            box-shadow: none;
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
        # The chip row overlays the photo's bottom edge and takes no height
        # of its own (the margins cancel), so the header ends at the photo.
        card_mod.style = ''
          ha-card {
            --chip-background: var(--card-background-color);
            --chip-box-shadow: 0 2px 8px rgba(0,0,0,0.15);
            --chip-border-radius: 24px;
            --chip-padding: 0 12px;
            --chip-height: 36px;
            background: transparent;
            height: 0;
            margin-top: -50px;
            margin-bottom: 50px;
            overflow: visible;
            position: relative;
            z-index: 1;
          }
        '';
        chips = [
          {
            type = "template";
            entity = room.lightGroup;
            icon = "fp:lamp";
            icon_color = "{{ 'amber' if is_state('${room.lightGroup}', 'on') else 'grey' }}";
            content = "{{ expand('${room.lightGroup}') | selectattr('state', 'eq', 'on') | list | count }}";
          }
        ];
      }
    ];

  lightsTab = room: [
    (cards.auto {
      include = [
        {
          group = room.lightGroup;
          options = cards.item {
            entity = "this.entity_id";
            icon = "fp:lamp";
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

  # `headers` are the floorplan headers by view path (dashboard/floorplan
  # roomHeaders). Room views are subviews, reached from the home view: they
  # stay out of the top bar, which shows a back arrow home instead of tabs.
  mkView = headers: room: {
    title = room.name;
    path = "room-${room.path}";
    inherit (room) icon;
    subview = true;
    back_path = "/lovelace-home/home";
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
          (
            if headers ? ${room.path}
            then floorplanHero headers.${room.path}
            else hero room
          )
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
