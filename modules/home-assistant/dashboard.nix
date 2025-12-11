{pkgs, ...}: let
  # Minimal-HA style CSS variables (defined in theme)
  # Using inline colors since we don't have the theme installed
  colors = {
    contrast0 = "#1a1a1a";   # Card background
    contrast5 = "#2a2a2a";   # Slightly lighter
    contrast10 = "#666666";  # Muted text
    contrast15 = "#999999";  # Secondary text/icons
    contrast18 = "#cccccc";  # Primary text
    contrast20 = "#ffffff";  # Bright text

    # Accent colors
    yellow = "#FFDA78";
    orange = "#FFB581";
    red = "#FF918A";
    green = "#CEF595";
    blue = "#90BFFF";
    purple = "#EFB1FF";
    pink = "#D683AA";
  };

  buttonCardTemplatesContent = ''
    button_card_templates:

      # ==================== SECTION HEADER ====================
      minimal_section:
        show_name: true
        show_label: true
        show_icon: false
        styles:
          card:
            - background: none
            - padding: 0px 12px
            - margin-bottom: "-5px"
            - margin-top: 15px
            - "--mdc-ripple-press-opacity": 0
            - box-shadow: none
          name:
            - justify-self: start
            - font-size: 20px
            - font-weight: 500
            - color: ${colors.contrast20}
          label:
            - justify-self: start
            - font-size: 14px
            - color: ${colors.contrast10}

      # ==================== ROOM CARD ====================
      minimal_room:
        show_name: true
        show_icon: true
        show_label: false
        tap_action:
          haptic: light
        styles:
          grid:
            - grid-template-areas: '"i badge" "n n"'
            - grid-template-columns: 1fr auto
            - grid-template-rows: 1fr min-content
          card:
            - background: ${colors.contrast0}
            - padding: 12px
            - "--mdc-ripple-press-opacity": 0
            - box-shadow: none
            - border-radius: 18px
            - height: 96px
          img_cell:
            - justify-self: start
            - width: 24px
          icon:
            - width: 24px
            - height: 24px
            - color: ${colors.contrast15}
          name:
            - justify-self: start
            - font-size: 14px
            - font-weight: 500
            - color: ${colors.contrast15}
            - padding-top: 8px
          custom_fields:
            badge:
              - align-self: start
              - justify-self: end
            label:
              - justify-self: start
              - font-size: 12px
              - color: ${colors.contrast10}
              - padding-top: 2px
        card_mod:
          style: |
            ha-card:active {
              transform: scale(0.96);
              transition: 200ms !important;
            }

      # ==================== STATUS BADGE ====================
      minimal_badge:
        show_name: false
        show_icon: true
        show_state: false
        styles:
          card:
            - background: ${colors.contrast5}
            - border-radius: 100px
            - padding: 6px
            - box-shadow: none
            - "--mdc-ripple-press-opacity": 0
          icon:
            - width: 18px
            - height: 18px
            - color: ${colors.contrast10}

      # ==================== CHIP CARD ====================
      minimal_chip:
        show_name: true
        show_icon: true
        show_label: true
        show_state: false
        styles:
          grid:
            - grid-template-areas: '"i n" "i l"'
            - grid-template-columns: auto 1fr
            - grid-template-rows: min-content min-content
          card:
            - background: ${colors.contrast0}
            - padding: 12px 16px
            - "--mdc-ripple-press-opacity": 0
            - box-shadow: none
            - border-radius: 18px
            - height: 70px
          icon:
            - width: 28px
            - height: 28px
            - color: ${colors.contrast15}
            - padding-right: 12px
          name:
            - justify-self: start
            - font-size: 22px
            - font-weight: 600
            - color: ${colors.contrast20}
            - align-self: end
          label:
            - justify-self: start
            - font-size: 11px
            - font-weight: 500
            - color: ${colors.contrast10}
            - text-transform: uppercase
            - letter-spacing: 0.5px
            - align-self: start
        card_mod:
          style: |
            ha-card:active {
              transform: scale(0.96);
              transition: 200ms !important;
            }

      # ==================== PERSON CHIP ====================
      minimal_person:
        show_name: true
        show_icon: true
        show_label: true
        show_state: false
        icon: mdi:account
        tap_action:
          action: more-info
          haptic: light
        label: "[[[ return states[entity.entity_id]?.state || 'Unknown' ]]]"
        styles:
          grid:
            - grid-template-areas: '"i n" "i l"'
            - grid-template-columns: auto 1fr
          card:
            - background: ${colors.contrast0}
            - padding: 12px 16px
            - "--mdc-ripple-press-opacity": 0
            - box-shadow: none
            - border-radius: 18px
            - height: 60px
          icon:
            - width: 32px
            - height: 32px
            - color: ${colors.contrast15}
            - padding-right: 12px
          name:
            - justify-self: start
            - font-size: 14px
            - font-weight: 500
            - color: ${colors.contrast18}
            - align-self: end
          label:
            - justify-self: start
            - font-size: 12px
            - color: ${colors.contrast10}
            - text-transform: capitalize
            - align-self: start
        state:
          - value: "home"
            styles:
              icon:
                - color: ${colors.green}
              label:
                - color: ${colors.green}
        card_mod:
          style: |
            ha-card:active {
              transform: scale(0.96);
              transition: 200ms !important;
            }

      # ==================== WEATHER COMPACT ====================
      minimal_weather:
        show_name: false
        show_icon: false
        show_label: false
        show_state: false
        entity: weather.forecast_home
        styles:
          card:
            - background: ${colors.contrast0}
            - border-radius: 18px
            - box-shadow: none
            - padding: 12px 16px
            - height: 50px
        custom_fields:
          weather: |
            [[[
              const weather = states['weather.forecast_home'];
              if (!weather) return '';
              const state = weather.state || 'unknown';
              const temp = weather.attributes.temperature ?? '--';

              const icons = {
                'sunny': 'mdi:weather-sunny',
                'clear-night': 'mdi:weather-night',
                'partlycloudy': 'mdi:weather-partly-cloudy',
                'cloudy': 'mdi:weather-cloudy',
                'rainy': 'mdi:weather-rainy',
                'pouring': 'mdi:weather-pouring',
                'snowy': 'mdi:weather-snowy',
                'fog': 'mdi:weather-fog',
                'windy': 'mdi:weather-windy',
                'lightning': 'mdi:weather-lightning'
              };
              const icon = icons[state] || 'mdi:weather-cloudy';
              const stateText = state.charAt(0).toUpperCase() + state.slice(1).replace(/-/g, ' ');

              return '<div style="display:flex;align-items:center;justify-content:flex-end;gap:12px;">' +
                '<ha-icon icon="' + icon + '" style="--mdc-icon-size:24px;color:${colors.contrast15};"></ha-icon>' +
                '<span style="font-size:22px;font-weight:600;color:${colors.contrast20};">' + temp + '°</span>' +
                '<span style="font-size:13px;color:${colors.contrast10};">' + stateText + '</span>' +
              '</div>';
            ]]]

      # ==================== SCENE BUTTON ====================
      minimal_scene:
        show_name: true
        show_icon: true
        show_label: false
        tap_action:
          haptic: light
        variables:
          color: ${colors.contrast15}
        styles:
          grid:
            - grid-template-areas: '"i" "n"'
            - grid-template-rows: 1fr min-content
          card:
            - background: ${colors.contrast0}
            - padding: 12px 8px
            - "--mdc-ripple-press-opacity": 0
            - box-shadow: none
            - border-radius: 18px
            - height: 80px
          icon:
            - width: 28px
            - height: 28px
            - color: "[[[ return variables.color ]]]"
          name:
            - justify-self: center
            - font-size: 11px
            - font-weight: 500
            - color: ${colors.contrast10}
            - padding-top: 6px
        state:
          - value: "on"
            styles:
              icon:
                - color: ${colors.contrast20}
        card_mod:
          style: |
            ha-card:active {
              transform: scale(0.96);
              transition: 200ms !important;
            }

      # ==================== LIGHT CARD ====================
      minimal_light:
        show_name: true
        show_icon: true
        show_label: true
        show_state: false
        icon: mdi:lightbulb-outline
        tap_action:
          action: toggle
          haptic: light
        hold_action:
          action: more-info
        label: |
          [[[
            if (entity.state === 'on' && entity.attributes.brightness) {
              return Math.round(entity.attributes.brightness / 2.55) + '%';
            }
            return entity.state === 'on' ? 'On' : 'Off';
          ]]]
        styles:
          grid:
            - grid-template-areas: '"i badge" "n n" "l l"'
            - grid-template-columns: 1fr auto
            - grid-template-rows: auto 1fr min-content
          card:
            - background: ${colors.contrast0}
            - padding: 12px
            - "--mdc-ripple-press-opacity": 0
            - box-shadow: none
            - border-radius: 18px
            - height: 96px
          icon:
            - width: 24px
            - height: 24px
            - color: ${colors.contrast15}
            - justify-self: start
          name:
            - justify-self: start
            - font-size: 13px
            - font-weight: 500
            - color: ${colors.contrast15}
          label:
            - justify-self: start
            - font-size: 12px
            - color: ${colors.contrast10}
          custom_fields:
            badge:
              - align-self: start
              - justify-self: end
        state:
          - value: "on"
            icon: mdi:lightbulb
            styles:
              icon:
                - color: ${colors.yellow}
          - value: "unavailable"
            styles:
              card:
                - opacity: 0.4
        card_mod:
          style: |
            ha-card:active {
              transform: scale(0.96);
              transition: 200ms !important;
            }

      # ==================== MEDIA CARD ====================
      minimal_media:
        show_name: true
        show_icon: true
        show_label: true
        show_state: false
        icon: mdi:television
        tap_action:
          action: more-info
          haptic: light
        label: |
          [[[
            if (!entity) return 'Unknown';
            if (entity.state === 'playing') {
              return entity.attributes?.media_title || 'Playing';
            }
            return entity.state;
          ]]]
        styles:
          grid:
            - grid-template-areas: '"i badge" "n n" "l l"'
            - grid-template-columns: 1fr auto
            - grid-template-rows: auto 1fr min-content
          card:
            - background: ${colors.contrast0}
            - padding: 12px
            - "--mdc-ripple-press-opacity": 0
            - box-shadow: none
            - border-radius: 18px
            - height: 96px
          icon:
            - width: 24px
            - height: 24px
            - color: ${colors.contrast15}
          name:
            - justify-self: start
            - font-size: 13px
            - font-weight: 500
            - color: ${colors.contrast15}
          label:
            - justify-self: start
            - font-size: 12px
            - color: ${colors.contrast10}
            - text-transform: capitalize
            - max-width: 120px
            - overflow: hidden
            - text-overflow: ellipsis
            - white-space: nowrap
        state:
          - value: "playing"
            icon: mdi:play-circle
            styles:
              icon:
                - color: ${colors.green}
          - value: "paused"
            icon: mdi:pause-circle
            styles:
              icon:
                - color: ${colors.yellow}
          - value: "on"
            styles:
              icon:
                - color: ${colors.blue}
        card_mod:
          style: |
            ha-card:active {
              transform: scale(0.96);
              transition: 200ms !important;
            }

      # ==================== FOOTBALL CARD ====================
      minimal_football:
        show_name: false
        show_icon: false
        show_label: false
        show_state: false
        styles:
          card:
            - background: ${colors.contrast0}
            - border-radius: 18px
            - box-shadow: none
            - padding: 16px
        custom_fields:
          match: |
            [[[
              var sensors = ["sensor.liverpool", "sensor.liverpool_cl", "sensor.liverpool_fa", "sensor.liverpool_lc"];
              var match = null;
              var nextDate = null;

              for (var i = 0; i < sensors.length; i++) {
                var s = states[sensors[i]];
                if (!s || !s.attributes) continue;
                if (s.state === "IN") { match = s; break; }
                if (s.state === "PRE" && s.attributes.date) {
                  var d = new Date(s.attributes.date);
                  if (!nextDate || d < nextDate) { nextDate = d; match = s; }
                }
              }

              if (!match) return '<div style="text-align:center;color:${colors.contrast10};padding:16px;">No upcoming matches</div>';

              var a = match.attributes;
              var isHome = a.team_homeaway === "home";
              var homeLogo = isHome ? a.team_logo : a.opponent_logo;
              var awayLogo = isHome ? a.opponent_logo : a.team_logo;
              var homeName = isHome ? a.team_abbr : a.opponent_abbr;
              var awayName = isHome ? a.opponent_abbr : a.team_abbr;
              var homeScore = isHome ? (a.team_score||0) : (a.opponent_score||0);
              var awayScore = isHome ? (a.opponent_score||0) : (a.team_score||0);

              var center = '';
              if (match.state === "IN") {
                center = '<div style="text-align:center;"><div style="font-size:10px;color:${colors.green};text-transform:uppercase;font-weight:600;">LIVE</div><div style="font-size:24px;font-weight:700;color:${colors.contrast20};">' + homeScore + ' - ' + awayScore + '</div></div>';
              } else {
                var kickoff = a.date ? new Date(a.date) : null;
                var timeStr = kickoff ? kickoff.toLocaleString('en-GB', {weekday:'short',day:'numeric',month:'short',hour:'2-digit',minute:'2-digit'}) : '--';
                center = '<div style="text-align:center;"><div style="font-size:10px;color:${colors.contrast10};text-transform:uppercase;">Next Match</div><div style="font-size:13px;font-weight:600;color:${colors.purple};">' + timeStr + '</div></div>';
              }

              return '<div style="display:flex;align-items:center;justify-content:space-between;gap:8px;">' +
                '<div style="text-align:center;flex:1;"><img src="' + (homeLogo||'') + '" style="width:40px;height:40px;object-fit:contain;"><div style="font-size:11px;font-weight:600;color:${colors.contrast18};margin-top:4px;">' + (homeName||'HOME') + '</div></div>' +
                '<div style="flex:1.2;">' + center + '</div>' +
                '<div style="text-align:center;flex:1;"><img src="' + (awayLogo||'') + '" style="width:40px;height:40px;object-fit:contain;"><div style="font-size:11px;font-weight:600;color:${colors.contrast18};margin-top:4px;">' + (awayName||'AWAY') + '</div></div>' +
              '</div>' +
              '<div style="text-align:center;margin-top:12px;padding-top:10px;border-top:1px solid ${colors.contrast5};font-size:11px;color:${colors.contrast10};">' + (a.league||'') + (a.venue ? ' • ' + a.venue : '') + '</div>';
            ]]]

      # ==================== VACUUM CARD ====================
      minimal_vacuum:
        show_name: false
        show_icon: false
        show_label: false
        show_state: false
        styles:
          card:
            - background: ${colors.contrast0}
            - border-radius: 18px
            - box-shadow: none
            - padding: 14px
        custom_fields:
          info: |
            [[[
              const vac = states['vacuum.robovac'];
              const bat = states['sensor.robovac_battery'];
              const state = vac ? vac.state : 'unavailable';
              const battery = bat ? bat.state : '0';

              var stateColor = '${colors.contrast10}';
              if (state === 'cleaning') stateColor = '${colors.green}';
              else if (state === 'docked') stateColor = '${colors.blue}';
              else if (state === 'returning') stateColor = '${colors.orange}';
              else if (state === 'unavailable') stateColor = '${colors.red}';

              return '<div style="display:flex;align-items:center;justify-content:space-between;">' +
                '<div style="display:flex;align-items:center;gap:12px;">' +
                  '<ha-icon icon="mdi:robot-vacuum" style="--mdc-icon-size:28px;color:' + stateColor + ';"></ha-icon>' +
                  '<div><div style="font-size:14px;font-weight:500;color:${colors.contrast18};">RoboVac</div>' +
                  '<div style="font-size:12px;color:' + stateColor + ';text-transform:capitalize;">' + state + '</div></div>' +
                '</div>' +
                '<div style="display:flex;align-items:center;gap:4px;color:${colors.contrast15};">' +
                  '<ha-icon icon="mdi:battery" style="--mdc-icon-size:16px;"></ha-icon>' +
                  '<span style="font-size:13px;font-weight:500;">' + battery + '%</span>' +
                '</div>' +
              '</div>';
            ]]]
          controls: |
            [[[
              return '<div style="display:flex;justify-content:space-around;margin-top:12px;padding-top:10px;border-top:1px solid ${colors.contrast5};">' +
                '<div style="text-align:center;padding:8px;cursor:pointer;"><ha-icon icon="mdi:play" style="--mdc-icon-size:20px;color:${colors.green};"></ha-icon><div style="font-size:10px;color:${colors.contrast10};margin-top:2px;">Start</div></div>' +
                '<div style="text-align:center;padding:8px;cursor:pointer;"><ha-icon icon="mdi:pause" style="--mdc-icon-size:20px;color:${colors.yellow};"></ha-icon><div style="font-size:10px;color:${colors.contrast10};margin-top:2px;">Pause</div></div>' +
                '<div style="text-align:center;padding:8px;cursor:pointer;"><ha-icon icon="mdi:home" style="--mdc-icon-size:20px;color:${colors.blue};"></ha-icon><div style="font-size:10px;color:${colors.contrast10};margin-top:2px;">Dock</div></div>' +
                '<div style="text-align:center;padding:8px;cursor:pointer;"><ha-icon icon="mdi:map-marker" style="--mdc-icon-size:20px;color:${colors.orange};"></ha-icon><div style="font-size:10px;color:${colors.contrast10};margin-top:2px;">Find</div></div>' +
              '</div>';
            ]]]
        styles:
          grid:
            - grid-template-areas: '"info" "controls"'
  '';

  dashboardYaml = pkgs.writeText "hacasa.yaml" ''
    title: Home
    ${buttonCardTemplatesContent}
    views:
      # ==================== HOME ====================
      - title: Home
        path: home
        icon: mdi:home
        type: custom:vertical-layout
        cards:
          # Header
          - type: custom:button-card
            template: minimal_section
            name: |
              [[[
                var h = new Date().getHours();
                return h < 12 ? 'Good Morning' : h < 18 ? 'Good Afternoon' : 'Good Evening';
              ]]]
            label: |
              [[[
                return new Date().toLocaleDateString('en-GB', {weekday:'long',day:'numeric',month:'long'});
              ]]]

          # People
          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_person
                entity: person.darren_gilbert
                name: Darren
              - type: custom:button-card
                template: minimal_person
                entity: person.lorraine
                name: Lorraine

          # Weather
          - type: custom:button-card
            template: minimal_weather
            entity: weather.forecast_home

          # Stats
          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_chip
                icon: mdi:lightbulb-group
                entity: sensor.total_turned_on_lights_count_template
                name: "[[[ return states['sensor.total_turned_on_lights_count_template']?.state || '0' ]]]"
                label: Lights
                styles:
                  icon:
                    - color: ${colors.yellow}
              - type: custom:button-card
                template: minimal_chip
                icon: mdi:motion-sensor
                entity: sensor.total_active_motion_sensors_count_template
                name: "[[[ return states['sensor.total_active_motion_sensors_count_template']?.state || '0' ]]]"
                label: Motion
                styles:
                  icon:
                    - color: ${colors.blue}
              - type: custom:button-card
                template: minimal_chip
                icon: mdi:thermometer
                name: |
                  [[[
                    const sensors = [
                      states['sensor.hallway_sensor_temperature'],
                      states['sensor.bathroom_sensor_temperature'],
                      states['sensor.dyson_temperature'],
                      states['sensor.aarlo_temperature_nursery']
                    ].filter(s => s && s.state !== 'unavailable' && s.state !== 'unknown');
                    if (!sensors.length) return '--';
                    const avg = sensors.reduce((a,s) => a + parseFloat(s.state), 0) / sensors.length;
                    return avg.toFixed(1) + '°';
                  ]]]
                label: Avg Temp
                styles:
                  icon:
                    - color: ${colors.red}

          # Football
          - type: custom:button-card
            template: minimal_football
            entity: sensor.liverpool

          # Rooms Section
          - type: custom:button-card
            template: minimal_section
            name: Rooms
            label: ""

          - type: grid
            columns: 2
            square: false
            cards:
              - type: custom:button-card
                template: minimal_room
                name: Living Room
                icon: mdi:sofa
                entity: group.living_room_lights
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/living-room
                custom_fields:
                  badge: |
                    [[[
                      const tv = states['media_player.living_room_tv'];
                      if (tv && (tv.state === 'playing' || tv.state === 'on')) {
                        return '<div style="background:${colors.contrast5};border-radius:100px;padding:6px;"><ha-icon icon="mdi:television" style="--mdc-icon-size:18px;color:${colors.green};"></ha-icon></div>';
                      }
                      var entities = states['group.living_room_lights']?.attributes?.entity_id || [];
                      var on = entities.filter(e => states[e]?.state === 'on').length;
                      if (on > 0) {
                        return '<div style="background:${colors.yellow};border-radius:100px;padding:6px 10px;font-size:12px;font-weight:600;color:${colors.contrast0};">' + on + '</div>';
                      }
                      return '';
                    ]]]
                  label: |
                    [[[
                      var entities = states['group.living_room_lights']?.attributes?.entity_id || [];
                      var on = entities.filter(e => states[e]?.state === 'on').length;
                      return '<div style="font-size:12px;color:${colors.contrast10};padding-top:4px;">' + on + ' lights on</div>';
                    ]]]
                styles:
                  custom_fields:
                    label:
                      - justify-self: start

              - type: custom:button-card
                template: minimal_room
                name: Bedroom
                icon: mdi:bed
                entity: group.bedroom_lights
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/bedroom
                custom_fields:
                  badge: |
                    [[[
                      var entities = states['group.bedroom_lights']?.attributes?.entity_id || [];
                      var on = entities.filter(e => states[e]?.state === 'on').length;
                      if (on > 0) {
                        return '<div style="background:${colors.purple};border-radius:100px;padding:6px 10px;font-size:12px;font-weight:600;color:${colors.contrast0};">' + on + '</div>';
                      }
                      return '';
                    ]]]
                  label: |
                    [[[
                      var entities = states['group.bedroom_lights']?.attributes?.entity_id || [];
                      var on = entities.filter(e => states[e]?.state === 'on').length;
                      return '<div style="font-size:12px;color:${colors.contrast10};padding-top:4px;">' + on + ' lights on</div>';
                    ]]]
                styles:
                  custom_fields:
                    label:
                      - justify-self: start

              - type: custom:button-card
                template: minimal_room
                name: Bathroom
                icon: mdi:shower
                entity: group.bathroom_lights
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/bathroom
                custom_fields:
                  badge: |
                    [[[
                      const motion = states['binary_sensor.motion_sensor_motion'];
                      if (motion && motion.state === 'on') {
                        return '<div style="background:${colors.blue};border-radius:100px;padding:6px;"><ha-icon icon="mdi:motion-sensor" style="--mdc-icon-size:18px;color:${colors.contrast0};"></ha-icon></div>';
                      }
                      return '';
                    ]]]
                  label: |
                    [[[
                      var temp = states['sensor.bathroom_sensor_temperature']?.state || '--';
                      var hum = states['sensor.bathroom_sensor_humidity']?.state || '--';
                      return '<div style="font-size:12px;color:${colors.contrast10};padding-top:4px;">' + parseFloat(temp).toFixed(1) + '°C • ' + Math.round(hum) + '%</div>';
                    ]]]
                styles:
                  custom_fields:
                    label:
                      - justify-self: start

              - type: custom:button-card
                template: minimal_room
                name: Kitchen
                icon: mdi:silverware-fork-knife
                entity: group.kitchen_lights
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/kitchen
                custom_fields:
                  badge: |
                    [[[
                      var entities = states['group.kitchen_lights']?.attributes?.entity_id || [];
                      var on = entities.filter(e => states[e]?.state === 'on').length;
                      if (on > 0) {
                        return '<div style="background:${colors.yellow};border-radius:100px;padding:6px 10px;font-size:12px;font-weight:600;color:${colors.contrast0};">' + on + '</div>';
                      }
                      return '';
                    ]]]
                  label: |
                    [[[
                      var entities = states['group.kitchen_lights']?.attributes?.entity_id || [];
                      var on = entities.filter(e => states[e]?.state === 'on').length;
                      return '<div style="font-size:12px;color:${colors.contrast10};padding-top:4px;">' + on + ' lights on</div>';
                    ]]]
                styles:
                  custom_fields:
                    label:
                      - justify-self: start

              - type: custom:button-card
                template: minimal_room
                name: Hallway
                icon: mdi:door
                entity: group.hallway_lights
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/hallway
                custom_fields:
                  label: |
                    [[[
                      var temp = states['sensor.hallway_sensor_temperature']?.state || '--';
                      return '<div style="font-size:12px;color:${colors.contrast10};padding-top:4px;">' + parseFloat(temp).toFixed(1) + '°C</div>';
                    ]]]
                styles:
                  custom_fields:
                    label:
                      - justify-self: start

              - type: custom:button-card
                template: minimal_room
                name: Robynne's Room
                icon: mdi:teddy-bear
                entity: group.robynne_lights
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/robynne
                custom_fields:
                  badge: |
                    [[[
                      const yoto = states['media_player.yoto_player'];
                      if (yoto && yoto.state === 'playing') {
                        return '<div style="background:${colors.green};border-radius:100px;padding:6px;"><ha-icon icon="mdi:music" style="--mdc-icon-size:18px;color:${colors.contrast0};"></ha-icon></div>';
                      }
                      return '';
                    ]]]
                  label: |
                    [[[
                      const yoto = states['media_player.yoto_player'];
                      if (yoto && (yoto.state === 'playing' || yoto.state === 'idle')) {
                        return '<div style="font-size:12px;color:${colors.contrast10};padding-top:4px;">Yoto ' + yoto.state + '</div>';
                      }
                      var entities = states['group.robynne_lights']?.attributes?.entity_id || [];
                      var on = entities.filter(e => states[e]?.state === 'on').length;
                      return '<div style="font-size:12px;color:${colors.contrast10};padding-top:4px;">' + on + ' lights on</div>';
                    ]]]
                styles:
                  custom_fields:
                    label:
                      - justify-self: start

          # Scenes Section
          - type: custom:button-card
            template: minimal_section
            name: Scenes
            label: ""

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_scene
                name: All Off
                icon: mdi:power
                variables:
                  color: ${colors.red}
                tap_action:
                  action: call-service
                  service: light.turn_off
                  service_data:
                    entity_id: all
              - type: custom:button-card
                template: minimal_scene
                entity: input_boolean.party_mode
                name: Party
                icon: mdi:party-popper
                variables:
                  color: ${colors.purple}
              - type: custom:button-card
                template: minimal_scene
                name: Movie
                icon: mdi:movie
                variables:
                  color: ${colors.blue}
                tap_action:
                  action: call-service
                  service: scene.turn_on
                  service_data:
                    entity_id: scene.movie
              - type: custom:button-card
                template: minimal_scene
                name: Bright
                icon: mdi:brightness-7
                variables:
                  color: ${colors.yellow}
                tap_action:
                  action: call-service
                  service: light.turn_on
                  service_data:
                    entity_id: all
                    brightness: 255

          # RoboVac Section
          - type: custom:button-card
            template: minimal_section
            name: RoboVac
            label: ""

          - type: custom:button-card
            template: minimal_vacuum
            entity: vacuum.robovac

          # Media Section
          - type: custom:button-card
            template: minimal_section
            name: Media
            label: ""

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_media
                entity: media_player.living_room_tv
                name: Living Room
              - type: custom:button-card
                template: minimal_media
                entity: media_player.apple_tv
                name: Bedroom

      # ==================== LIVING ROOM ====================
      - title: Living Room
        path: living-room
        icon: mdi:sofa
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: minimal_section
            name: Living Room
            label: Lights & Climate

          - type: grid
            columns: 2
            square: false
            cards:
              - type: custom:button-card
                template: minimal_light
                entity: light.living_room_light
                name: Main Light
              - type: custom:button-card
                template: minimal_light
                entity: light.dining_room_light_3
                name: Dining Light
              - type: custom:button-card
                template: minimal_light
                entity: light.sofa_light_switch
                name: Sofa Light
              - type: custom:button-card
                template: minimal_light
                entity: light.tv_light
                name: TV Light

          - type: custom:button-card
            template: minimal_section
            name: Climate
            label: ""

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_chip
                entity: fan.dyson
                icon: mdi:fan
                name: "[[[ return entity.state === 'on' ? (entity.attributes?.percentage || 0) + '%' : 'Off' ]]]"
                label: Dyson Fan
                tap_action:
                  action: toggle
                styles:
                  icon:
                    - color: "[[[ return entity.state === 'on' ? '${colors.blue}' : '${colors.contrast15}' ]]]"
              - type: custom:button-card
                template: minimal_chip
                entity: sensor.dyson_temperature
                icon: mdi:thermometer
                name: "[[[ return entity.state + '°' ]]]"
                label: Temp
                styles:
                  icon:
                    - color: ${colors.red}

      # ==================== BEDROOM ====================
      - title: Bedroom
        path: bedroom
        icon: mdi:bed
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: minimal_section
            name: Bedroom
            label: Lights & Media

          - type: grid
            columns: 2
            square: false
            cards:
              - type: custom:button-card
                template: minimal_light
                entity: light.above_bed_light
                name: Above Bed
              - type: custom:button-card
                template: minimal_light
                entity: light.bedroom_light_2
                name: Main Light
              - type: custom:button-card
                template: minimal_light
                entity: light.darren_switch
                name: Darren's Light
              - type: custom:button-card
                template: minimal_light
                entity: light.lorraine_switch
                name: Lorraine's Light

      # ==================== BATHROOM ====================
      - title: Bathroom
        path: bathroom
        icon: mdi:shower
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: minimal_section
            name: Bathroom
            label: Lights & Climate

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_light
                entity: light.bath_light
                name: Bath
              - type: custom:button-card
                template: minimal_light
                entity: light.sink_light
                name: Sink
              - type: custom:button-card
                template: minimal_light
                entity: light.toilet_light
                name: Toilet

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_chip
                entity: sensor.bathroom_sensor_temperature
                icon: mdi:thermometer
                name: "[[[ return entity.state + '°' ]]]"
                label: Temp
                styles:
                  icon:
                    - color: ${colors.red}
              - type: custom:button-card
                template: minimal_chip
                entity: sensor.bathroom_sensor_humidity
                icon: mdi:water-percent
                name: "[[[ return Math.round(entity.state) + '%' ]]]"
                label: Humidity
                styles:
                  icon:
                    - color: ${colors.blue}

      # ==================== KITCHEN ====================
      - title: Kitchen
        path: kitchen
        icon: mdi:silverware-fork-knife
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: minimal_section
            name: Kitchen
            label: Lights

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_light
                entity: light.kitchen_microwave
                name: Main
              - type: custom:button-card
                template: minimal_light
                entity: light.kitchen_sink
                name: Sink
              - type: custom:button-card
                template: minimal_light
                entity: light.kitchen_random
                name: Other

      # ==================== HALLWAY ====================
      - title: Hallway
        path: hallway
        icon: mdi:door
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: minimal_section
            name: Hallway
            label: Lights & Sensors

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_light
                entity: light.hallway
                name: Hallway
              - type: custom:button-card
                template: minimal_light
                entity: light.doorway
                name: Doorway

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_chip
                entity: sensor.hallway_sensor_temperature
                icon: mdi:thermometer
                name: "[[[ return entity.state + '°' ]]]"
                label: Temp
                styles:
                  icon:
                    - color: ${colors.red}
              - type: custom:button-card
                template: minimal_chip
                entity: sensor.hallway_sensor_humidity
                icon: mdi:water-percent
                name: "[[[ return Math.round(entity.state) + '%' ]]]"
                label: Humidity
                styles:
                  icon:
                    - color: ${colors.blue}

      # ==================== ROBYNNE'S ROOM ====================
      - title: Robynne's Room
        path: robynne
        icon: mdi:teddy-bear
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: minimal_section
            name: Robynne's Room
            label: Lights & Media

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_light
                entity: light.robynne_light
                name: Main Light
              - type: custom:button-card
                template: minimal_light
                entity: light.fairy_lights_switch
                name: Fairy Lights

          - type: custom:button-card
            template: minimal_media
            entity: media_player.yoto_player
            name: Yoto Player
            icon: mdi:speaker
  '';
in {
  systemd.tmpfiles.rules = [
    "L+ /var/lib/hass/hacasa.yaml - - - - ${dashboardYaml}"
  ];

  services.home-assistant.config = {
    lovelace = {
      dashboards = {
        lovelace-hacasa = {
          mode = "yaml";
          filename = "hacasa.yaml";
          title = "HaCasa";
          icon = "mdi:home-assistant";
          show_in_sidebar = true;
          require_admin = false;
        };
      };
    };
  };
}
