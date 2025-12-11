{pkgs, ...}: let
  # Minimal-HA Pixel-like theme colors
  colors = {
    # Grayscale (dark mode)
    contrast0 = "#1b1b1f"; # Darkest background
    contrast1 = "#303034"; # Card background
    contrast2 = "#111318";
    contrast3 = "#171A21";
    contrast4 = "#1C1F27";
    contrast5 = "#262A35";
    contrast6 = "#353946";
    contrast7 = "#434856";
    contrast8 = "#535865";
    contrast9 = "#636774";
    contrast10 = "#777A83";
    contrast11 = "#898C94";
    contrast12 = "#969AA6";
    contrast13 = "#A4A9B6";
    contrast14 = "#B3B8C6"; # Muted text
    contrast15 = "#C3C8D5";
    contrast16 = "#D4D8E2";
    contrast17 = "#E1E5EF";
    contrast18 = "#FFFFFF"; # Primary text

    # Accent colors
    purple = "#EFB1FF";
    yellow = "#FFDA78";
    orange = "#FFB581";
    red = "#FF918A";
    green = "#CEF595";
    watergreen = "#95F5A5";
    blue = "#90BFFF";
    pink = "#D683AA";
    brown = "#7D6E68";

    # RGB versions for gradients/tints
    purpleRgb = "239, 177, 255";
    yellowRgb = "255, 218, 120";
    orangeRgb = "255, 181, 129";
    redRgb = "255, 145, 138";
    greenRgb = "206, 245, 149";
    blueRgb = "144, 191, 255";
  };

  # Design tokens
  design = {
    borderRadius = "18px";
    cardGap = "12px";
    shadow = "0px 4px 4px 0px rgba(0,0,0,0.16)";
    fontFamily = "sans-serif";
    tintOpacity = "0.15";
  };

  buttonCardTemplatesContent = ''
    button_card_templates:
      # ==================== BASE TEMPLATES ====================

      minimal_base:
        styles:
          card:
            - background: ${colors.contrast1}
            - border-radius: 20px
            - box-shadow: none
            - padding: 12px
            - transition: all 0.3s ease
            - "-webkit-tap-highlight-color": transparent
          name:
            - font-family: ${design.fontFamily}
            - color: ${colors.contrast18}
            - font-weight: 500
          label:
            - font-family: ${design.fontFamily}
            - color: ${colors.contrast14}
          state:
            - font-family: ${design.fontFamily}
            - color: ${colors.contrast18}
        tap_action:
          action: toggle
          haptic: light
        extra_styles: |
          ha-card:active {
            transform: scale(0.98);
          }

      # ==================== HEADER / TITLE ====================

      minimal_header:
        show_name: true
        show_icon: false
        show_label: true
        show_state: false
        styles:
          card:
            - background: transparent
            - box-shadow: none
            - padding: 16px 4px 8px 4px
          grid:
            - grid-template-areas: '"n" "l"'
          name:
            - font-family: ${design.fontFamily}
            - font-size: 28px
            - font-weight: 600
            - color: ${colors.contrast18}
            - justify-self: start
          label:
            - font-family: ${design.fontFamily}
            - font-size: 14px
            - color: ${colors.contrast14}
            - justify-self: start

      minimal_title:
        show_name: true
        show_icon: false
        show_label: false
        styles:
          card:
            - background: transparent
            - box-shadow: none
            - padding: 16px 4px 8px 4px
          name:
            - font-family: ${design.fontFamily}
            - font-size: 18px
            - font-weight: 600
            - color: ${colors.contrast18}
            - justify-self: start

      # ==================== ROOM CARD ====================

      minimal_room:
        template: minimal_base
        show_name: true
        show_icon: true
        show_label: true
        show_state: false
        variables:
          room_icon: mdi:home
          accent_color: ${colors.blue}
        styles:
          card:
            - background: ${colors.contrast1}
            - border-radius: 20px
            - padding: 14px
            - height: 100px
          grid:
            - grid-template-areas: '"i s" "n n" "l l"'
            - grid-template-columns: 1fr auto
            - grid-template-rows: auto 1fr auto
          icon:
            - width: 38px
            - height: 38px
            - color: ${colors.contrast10}
            - background: "rgba(255,255,255,0.05)"
            - border-radius: 50%
            - padding: 8px
            - justify-self: start
          name:
            - font-family: ${design.fontFamily}
            - font-size: 14px
            - font-weight: 600
            - color: ${colors.contrast18}
            - justify-self: start
            - align-self: end
          label:
            - font-family: ${design.fontFamily}
            - font-size: 12px
            - color: ${colors.contrast14}
            - justify-self: start
            - align-self: start
            - opacity: "0.6"
          custom_fields:
            s:
              - justify-self: end
              - align-self: start
        state:
          - value: "on"
            styles:
              icon:
                - color: "[[[ return variables.accent_color ]]]"
                - background: "[[[ return variables.accent_color + '20' ]]]"

      # ==================== LIGHT CARD ====================

      minimal_light:
        template: minimal_base
        show_name: true
        show_icon: true
        show_label: true
        show_state: false
        icon: mdi:lightbulb-outline
        variables:
          accent_color: ${colors.yellow}
        hold_action:
          action: more-info
        label: |
          [[[
            const state = states[entity.entity_id];
            if (!state) return 'Unknown';
            if (state.state === 'on' && state.attributes.brightness) {
              return Math.round(state.attributes.brightness / 2.55) + '%';
            }
            return state.state === 'on' ? 'On' : 'Off';
          ]]]
        styles:
          card:
            - height: 100px
            - padding: 14px
          grid:
            - grid-template-areas: '"i ." "n n" "l l"'
            - grid-template-rows: auto 1fr auto
          icon:
            - width: 38px
            - height: 38px
            - color: ${colors.contrast10}
            - justify-self: start
            - background: "rgba(255,255,255,0.05)"
            - border-radius: 50%
            - padding: 8px
          name:
            - font-size: 13px
            - font-weight: 600
            - justify-self: start
            - align-self: end
          label:
            - font-size: 12px
            - justify-self: start
            - align-self: start
            - opacity: "0.6"
        state:
          - value: "on"
            icon: mdi:lightbulb
            styles:
              icon:
                - color: "[[[ return variables.accent_color ]]]"
                - background: "[[[ return variables.accent_color + '20' ]]]"
          - value: "unavailable"
            styles:
              card:
                - opacity: 0.4

      # ==================== SWITCH CARD ====================

      minimal_switch:
        template: minimal_light
        icon: mdi:power-plug-outline
        variables:
          accent_color: ${colors.green}
        state:
          - value: "on"
            icon: mdi:power-plug
            styles:
              icon:
                - color: "[[[ return variables.accent_color ]]]"
                - background: "[[[ return variables.accent_color + '20' ]]]"

      # ==================== SENSOR / STAT CARD ====================

      minimal_sensor:
        template: minimal_base
        show_name: true
        show_icon: true
        show_label: true
        show_state: false
        variables:
          accent_color: ${colors.blue}
        label: |
          [[[
            const state = states[entity.entity_id];
            if (!state) return '--';
            const unit = state.attributes?.unit_of_measurement || "";
            return state.state + unit;
          ]]]
        styles:
          card:
            - height: 80px
            - padding: 14px
          grid:
            - grid-template-areas: '"i l" "i n"'
            - grid-template-columns: 50px 1fr
          icon:
            - width: 36px
            - height: 36px
            - color: "[[[ return variables.accent_color ]]]"
            - background: "[[[ return variables.accent_color + '15' ]]]"
            - border-radius: 50%
            - padding: 6px
          name:
            - font-size: 11px
            - font-weight: 500
            - color: ${colors.contrast14}
            - justify-self: start
            - align-self: start
            - text-transform: uppercase
            - letter-spacing: 0.5px
          label:
            - font-size: 24px
            - font-weight: 700
            - color: ${colors.contrast18}
            - justify-self: start
            - align-self: end

      minimal_stat:
        template: minimal_sensor
        tap_action:
          action: none
        styles:
          card:
            - height: 76px
            - padding: 12px 14px

      # ==================== PERSON CARD ====================

      minimal_person:
        template: minimal_base
        show_name: true
        show_icon: true
        show_label: true
        show_state: false
        icon: mdi:account
        label: "[[[ return states[entity.entity_id]?.state || 'Unknown' ]]]"
        tap_action:
          action: more-info
        styles:
          card:
            - height: 72px
            - padding: 12px 14px
          grid:
            - grid-template-areas: '"i n" "i l"'
            - grid-template-columns: 50px 1fr
          icon:
            - width: 36px
            - height: 36px
            - color: ${colors.purple}
            - background: "${colors.purple}15"
            - border-radius: 50%
            - padding: 6px
          name:
            - font-size: 14px
            - font-weight: 600
            - justify-self: start
            - align-self: end
          label:
            - font-size: 12px
            - justify-self: start
            - align-self: start
            - text-transform: capitalize
            - opacity: "0.6"
        state:
          - value: "home"
            styles:
              icon:
                - color: ${colors.green}
                - background: "${colors.green}20"
              label:
                - color: ${colors.green}
                - opacity: "1"
          - value: "not_home"
            styles:
              label:
                - color: ${colors.contrast14}

      # ==================== SCENE CARD ====================

      minimal_scene:
        template: minimal_base
        show_name: true
        show_icon: true
        show_label: false
        variables:
          accent_color: ${colors.purple}
        styles:
          card:
            - height: 80px
            - padding: 12px 8px
          grid:
            - grid-template-areas: '"i" "n"'
            - grid-template-rows: 1fr auto
          icon:
            - width: 38px
            - height: 38px
            - color: "[[[ return variables.accent_color ]]]"
            - background: "[[[ return variables.accent_color + '15' ]]]"
            - border-radius: 50%
            - padding: 8px
            - justify-self: center
          name:
            - font-size: 11px
            - font-weight: 500
            - color: ${colors.contrast14}
            - justify-self: center
        state:
          - value: "on"
            styles:
              icon:
                - background: "[[[ return variables.accent_color ]]]"
                - color: ${colors.contrast0}

      # ==================== MEDIA CARD ====================

      minimal_media:
        template: minimal_base
        show_name: true
        show_icon: true
        show_label: true
        icon: mdi:television
        variables:
          accent_color: ${colors.blue}
        hold_action:
          action: more-info
        label: |
          [[[
            const state = states[entity.entity_id];
            if (!state) return 'Unknown';
            if (state.state === 'playing') {
              return state.attributes?.media_title || 'Playing';
            }
            return state.state;
          ]]]
        styles:
          card:
            - height: 100px
            - padding: 14px
          grid:
            - grid-template-areas: '"i ." "n n" "l l"'
            - grid-template-rows: auto 1fr auto
          icon:
            - width: 38px
            - height: 38px
            - color: ${colors.contrast10}
            - background: "rgba(255,255,255,0.05)"
            - border-radius: 50%
            - padding: 8px
            - justify-self: start
          name:
            - font-size: 13px
            - font-weight: 600
            - justify-self: start
            - align-self: end
          label:
            - font-size: 12px
            - justify-self: start
            - align-self: start
            - text-transform: capitalize
            - opacity: "0.6"
        state:
          - value: "playing"
            icon: mdi:play-circle
            styles:
              icon:
                - color: ${colors.green}
                - background: "${colors.green}20"
              label:
                - color: ${colors.green}
                - opacity: "1"
          - value: "paused"
            icon: mdi:pause-circle
            styles:
              icon:
                - color: ${colors.yellow}
                - background: "${colors.yellow}20"
          - value: "on"
            styles:
              icon:
                - color: ${colors.blue}
                - background: "${colors.blue}20"

      # ==================== FAN CARD ====================

      minimal_fan:
        template: minimal_light
        icon: mdi:fan
        variables:
          accent_color: ${colors.blue}
        label: |
          [[[
            const state = states[entity.entity_id];
            if (!state) return 'Unknown';
            if (state.state === 'on') {
              return (state.attributes?.percentage || 0) + '%';
            }
            return 'Off';
          ]]]
        state:
          - value: "on"
            styles:
              icon:
                - color: "[[[ return variables.accent_color ]]]"
                - background: "[[[ return variables.accent_color + '20' ]]]"
                - animation: spin 1s linear infinite
        extra_styles: |
          @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
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
            - background: ${colors.contrast1}
            - border-radius: ${design.borderRadius}
            - box-shadow: ${design.shadow}
            - padding: 14px 16px
        custom_fields:
          weather: |
            [[[
              const weather = states['weather.forecast_home'];
              if (!weather) return '<div style="color:${colors.contrast14};">Weather unavailable</div>';
              const state = weather.state || 'unknown';
              const attr = weather.attributes || {};
              const temp = attr.temperature ?? '--';

              const weatherIcons = {
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
              const icon = weatherIcons[state] || 'mdi:weather-cloudy';

              const weatherColors = {
                'sunny': '${colors.yellow}',
                'clear-night': '${colors.blue}',
                'partlycloudy': '${colors.orange}',
                'cloudy': '${colors.contrast14}',
                'rainy': '${colors.blue}',
                'pouring': '${colors.blue}',
                'snowy': '${colors.contrast18}',
                'fog': '${colors.contrast14}',
                'windy': '${colors.purple}',
                'lightning': '${colors.yellow}'
              };
              const color = weatherColors[state] || '${colors.contrast14}';

              const stateText = state.replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase());

              return '<div style="display:flex;align-items:center;gap:14px;">' +
                '<ha-icon icon="' + icon + '" style="--mdc-icon-size:32px;color:' + color + ';"></ha-icon>' +
                '<span style="font-size:28px;font-weight:700;color:${colors.contrast18};">' + temp + '°</span>' +
                '<span style="font-size:14px;color:${colors.contrast14};margin-left:auto;">' + stateText + '</span>' +
              '</div>';
            ]]]

      # ==================== FOOTBALL CARD ====================

      minimal_football:
        show_name: false
        show_icon: false
        show_label: false
        show_state: false
        show_entity_picture: false
        styles:
          card:
            - background: ${colors.contrast1}
            - border-radius: ${design.borderRadius}
            - box-shadow: ${design.shadow}
            - padding: 16px
        custom_fields:
          content: |
            [[[
              var sensors = ["sensor.liverpool", "sensor.liverpool_cl", "sensor.liverpool_fa", "sensor.liverpool_lc"];
              var liveMatch = null;
              var nextMatch = null;
              var nextMatchDate = null;

              for (var i = 0; i < sensors.length; i++) {
                var s = states[sensors[i]];
                if (!s || !s.attributes) continue;

                if (s.state === "IN") {
                  liveMatch = s;
                  break;
                }

                if (s.state === "PRE" && s.attributes.date) {
                  var matchDate = new Date(s.attributes.date);
                  if (!nextMatchDate || matchDate < nextMatchDate) {
                    nextMatchDate = matchDate;
                    nextMatch = s;
                  }
                }
              }

              var match = liveMatch ? liveMatch : nextMatch;
              if (!match) {
                return '<div style="text-align:center;color:${colors.contrast14};padding:20px;">No upcoming matches</div>';
              }

              var attr = match.attributes;
              var state = match.state;
              var isHome = attr.team_homeaway === "home";
              var teamLogo = attr.team_logo || "";
              var oppLogo = attr.opponent_logo || "";
              var teamAbbr = attr.team_abbr || "HOME";
              var oppAbbr = attr.opponent_abbr || "AWAY";
              var homeLogo = isHome ? teamLogo : oppLogo;
              var awayLogo = isHome ? oppLogo : teamLogo;
              var homeName = isHome ? teamAbbr : oppAbbr;
              var awayName = isHome ? oppAbbr : teamAbbr;
              var teamScore = attr.team_score || 0;
              var oppScore = attr.opponent_score || 0;
              var homeScore = isHome ? teamScore : oppScore;
              var awayScore = isHome ? oppScore : teamScore;
              var kickoff = attr.kickoff_in || "--";
              var clock = attr.clock || "";
              var venue = attr.venue || "TBD";
              var league = attr.league || "";

              var scoreHtml = "";
              if (state === "PRE") {
                var kickoffDate = attr.date ? new Date(attr.date) : null;
                var kickoffStr = kickoff;
                if (kickoffDate && !isNaN(kickoffDate)) {
                  var opts = { weekday: 'short', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' };
                  kickoffStr = kickoffDate.toLocaleString('en-GB', opts);
                }
                scoreHtml = '<div style="display:flex;flex-direction:column;align-items:center;"><span style="font-size:11px;color:${colors.contrast14};text-transform:uppercase;">Next Match</span><span style="font-size:14px;font-weight:600;color:${colors.purple};">' + kickoffStr + '</span></div>';
              } else if (state === "IN") {
                scoreHtml = '<div style="display:flex;flex-direction:column;align-items:center;"><span style="font-size:11px;color:${colors.green};text-transform:uppercase;font-weight:600;">LIVE ' + clock + '</span><span style="font-size:28px;font-weight:700;color:${colors.contrast18};">' + homeScore + ' - ' + awayScore + '</span></div>';
              } else {
                scoreHtml = '<div style="display:flex;flex-direction:column;align-items:center;"><span style="font-size:11px;color:${colors.contrast14};text-transform:uppercase;">Final</span><span style="font-size:28px;font-weight:700;color:${colors.contrast18};">' + homeScore + ' - ' + awayScore + '</span></div>';
              }

              return '<div style="display:flex;flex-direction:column;gap:12px;">' +
                '<div style="display:flex;align-items:center;justify-content:space-between;">' +
                  '<div style="display:flex;flex-direction:column;align-items:center;gap:8px;flex:1;">' +
                    '<img src="' + homeLogo + '" style="width:48px;height:48px;object-fit:contain;">' +
                    '<span style="font-size:12px;font-weight:600;color:${colors.contrast18};">' + homeName + '</span>' +
                  '</div>' +
                  '<div style="flex:1;">' + scoreHtml + '</div>' +
                  '<div style="display:flex;flex-direction:column;align-items:center;gap:8px;flex:1;">' +
                    '<img src="' + awayLogo + '" style="width:48px;height:48px;object-fit:contain;">' +
                    '<span style="font-size:12px;font-weight:600;color:${colors.contrast18};">' + awayName + '</span>' +
                  '</div>' +
                '</div>' +
                '<div style="text-align:center;padding-top:8px;border-top:1px solid ${colors.contrast5};"><span style="font-size:11px;color:${colors.contrast14};">' + league + (venue ? ' • ' + venue : "") + '</span></div>' +
              '</div>';
            ]]]

      # ==================== VACUUM CARD ====================

      minimal_vacuum:
        show_name: false
        show_icon: false
        show_label: false
        show_state: false
        styles:
          card:
            - background: ${colors.contrast1}
            - border-radius: ${design.borderRadius}
            - box-shadow: ${design.shadow}
            - padding: 16px
        custom_fields:
          vacuum: |
            [[[
              const vacuumEntity = states['vacuum.robovac'];
              const batteryEntity = states['sensor.robovac_battery'];
              const state = vacuumEntity ? vacuumEntity.state : 'unavailable';
              const battery = batteryEntity ? batteryEntity.state : '0';
              const batteryNum = parseInt(battery) || 0;

              var stateColor = '${colors.contrast14}';
              if (state === 'cleaning') stateColor = '${colors.green}';
              else if (state === 'docked') stateColor = '${colors.blue}';
              else if (state === 'paused') stateColor = '${colors.yellow}';
              else if (state === 'returning') stateColor = '${colors.orange}';
              else if (state === 'unavailable') stateColor = '${colors.red}';

              var batteryIcon = 'mdi:battery-alert';
              if (batteryNum > 80) batteryIcon = 'mdi:battery';
              else if (batteryNum > 60) batteryIcon = 'mdi:battery-80';
              else if (batteryNum > 40) batteryIcon = 'mdi:battery-60';
              else if (batteryNum > 20) batteryIcon = 'mdi:battery-40';
              else if (batteryNum > 10) batteryIcon = 'mdi:battery-20';
              var batteryColor = batteryNum > 20 ? '${colors.green}' : '${colors.red}';

              return '<div style="display:flex;align-items:center;justify-content:space-between;">' +
                '<div style="display:flex;align-items:center;gap:12px;">' +
                  '<ha-icon icon="mdi:robot-vacuum" style="--mdc-icon-size:32px;color:' + stateColor + ';"></ha-icon>' +
                  '<div style="display:flex;flex-direction:column;">' +
                    '<span style="font-size:15px;font-weight:600;color:${colors.contrast18};">RoboVac</span>' +
                    '<span style="font-size:12px;color:' + stateColor + ';text-transform:capitalize;">' + state + '</span>' +
                  '</div>' +
                '</div>' +
                '<div style="display:flex;align-items:center;gap:4px;">' +
                  '<ha-icon icon="' + batteryIcon + '" style="--mdc-icon-size:18px;color:' + batteryColor + ';"></ha-icon>' +
                  '<span style="font-size:14px;font-weight:600;color:${colors.contrast18};">' + battery + '%</span>' +
                '</div>' +
              '</div>';
            ]]]
          controls: |
            [[[
              return '<div style="display:flex;justify-content:space-around;padding-top:12px;margin-top:12px;border-top:1px solid ${colors.contrast5};">' +
                '<div style="display:flex;flex-direction:column;align-items:center;cursor:pointer;padding:8px;">' +
                  '<ha-icon icon="mdi:play" style="--mdc-icon-size:22px;color:${colors.green};"></ha-icon>' +
                  '<span style="font-size:10px;color:${colors.contrast14};margin-top:4px;">Start</span>' +
                '</div>' +
                '<div style="display:flex;flex-direction:column;align-items:center;cursor:pointer;padding:8px;">' +
                  '<ha-icon icon="mdi:pause" style="--mdc-icon-size:22px;color:${colors.yellow};"></ha-icon>' +
                  '<span style="font-size:10px;color:${colors.contrast14};margin-top:4px;">Pause</span>' +
                '</div>' +
                '<div style="display:flex;flex-direction:column;align-items:center;cursor:pointer;padding:8px;">' +
                  '<ha-icon icon="mdi:home" style="--mdc-icon-size:22px;color:${colors.blue};"></ha-icon>' +
                  '<span style="font-size:10px;color:${colors.contrast14};margin-top:4px;">Dock</span>' +
                '</div>' +
                '<div style="display:flex;flex-direction:column;align-items:center;cursor:pointer;padding:8px;">' +
                  '<ha-icon icon="mdi:map-marker" style="--mdc-icon-size:22px;color:${colors.orange};"></ha-icon>' +
                  '<span style="font-size:10px;color:${colors.contrast14};margin-top:4px;">Find</span>' +
                '</div>' +
              '</div>';
            ]]]
        styles:
          grid:
            - grid-template-areas: '"vacuum" "controls"'
  '';

  dashboardYaml = pkgs.writeText "hacasa.yaml" ''
    title: Home
    ${buttonCardTemplatesContent}
    views:
      # ==================== HOME VIEW ====================
      - title: Home
        path: home
        icon: mdi:home
        type: custom:vertical-layout
        cards:
          # Header
          - type: custom:button-card
            template: minimal_header
            name: |
              [[[
                var hour = new Date().getHours();
                var greeting = hour < 12 ? 'Good Morning' : hour < 18 ? 'Good Afternoon' : 'Good Evening';
                return greeting;
              ]]]
            label: |
              [[[
                var date = new Date();
                var options = { weekday: 'long', day: 'numeric', month: 'long' };
                return date.toLocaleDateString('en-GB', options);
              ]]]

          # Presence Chips
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

          # Weather + Stats Row
          - type: custom:button-card
            template: minimal_weather
            entity: weather.forecast_home

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_stat
                name: Lights
                icon: mdi:lightbulb-group
                entity: sensor.total_turned_on_lights_count_template
                variables:
                  accent_color: ${colors.yellow}

              - type: custom:button-card
                template: minimal_stat
                name: Motion
                icon: mdi:motion-sensor
                entity: sensor.total_active_motion_sensors_count_template
                variables:
                  accent_color: ${colors.blue}

              - type: custom:button-card
                template: minimal_stat
                name: Avg Temp
                icon: mdi:thermometer
                variables:
                  accent_color: ${colors.red}
                label: |
                  [[[
                    const sensors = [
                      states['sensor.hallway_sensor_temperature'],
                      states['sensor.bathroom_sensor_temperature'],
                      states['sensor.dyson_temperature'],
                      states['sensor.aarlo_temperature_nursery']
                    ].filter(s => s && s.state !== 'unavailable' && s.state !== 'unknown');

                    if (sensors.length === 0) return '--';

                    const sum = sensors.reduce((acc, s) => acc + parseFloat(s.state), 0);
                    return (sum / sensors.length).toFixed(1) + '°';
                  ]]]

          # Liverpool FC
          - type: custom:button-card
            template: minimal_football
            entity: sensor.liverpool

          # Rooms Title
          - type: custom:button-card
            template: minimal_title
            name: Rooms

          # Room Cards Grid
          - type: grid
            columns: 2
            square: false
            cards:
              - type: custom:button-card
                template: minimal_room
                name: Living Room
                icon: mdi:sofa
                entity: group.living_room_lights
                variables:
                  accent_color: ${colors.orange}
                label: |
                  [[[
                    var entities = states['group.living_room_lights']?.attributes?.entity_id || [];
                    var count = entities.filter(e => states[e]?.state === 'on').length;
                    return count + ' lights on';
                  ]]]
                custom_fields:
                  s: |
                    [[[
                      const tv = states['media_player.living_room_tv'];
                      if (tv && (tv.state === 'playing' || tv.state === 'on')) {
                        return '<ha-icon icon="mdi:television" style="--mdc-icon-size:16px;color:${colors.green};"></ha-icon>';
                      }
                      return "";
                    ]]]
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/living-room

              - type: custom:button-card
                template: minimal_room
                name: Bedroom
                icon: mdi:bed
                entity: group.bedroom_lights
                variables:
                  accent_color: ${colors.purple}
                label: |
                  [[[
                    var entities = states['group.bedroom_lights']?.attributes?.entity_id || [];
                    var count = entities.filter(e => states[e]?.state === 'on').length;
                    return count + ' lights on';
                  ]]]
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/bedroom

              - type: custom:button-card
                template: minimal_room
                name: Bathroom
                icon: mdi:shower
                entity: group.bathroom_lights
                variables:
                  accent_color: ${colors.blue}
                label: |
                  [[[
                    var temp = states['sensor.bathroom_sensor_temperature']?.state || '--';
                    var hum = states['sensor.bathroom_sensor_humidity']?.state || '--';
                    return temp + '°C • ' + Math.round(hum) + '%';
                  ]]]
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/bathroom

              - type: custom:button-card
                template: minimal_room
                name: Kitchen
                icon: mdi:silverware-fork-knife
                entity: group.kitchen_lights
                variables:
                  accent_color: ${colors.yellow}
                label: |
                  [[[
                    var entities = states['group.kitchen_lights']?.attributes?.entity_id || [];
                    var count = entities.filter(e => states[e]?.state === 'on').length;
                    return count + ' lights on';
                  ]]]
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/kitchen

              - type: custom:button-card
                template: minimal_room
                name: Hallway
                icon: mdi:door
                entity: group.hallway_lights
                variables:
                  accent_color: ${colors.green}
                label: |
                  [[[
                    var temp = states['sensor.hallway_sensor_temperature']?.state || '--';
                    return temp + '°C';
                  ]]]
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/hallway

              - type: custom:button-card
                template: minimal_room
                name: Robynne's Room
                icon: mdi:teddy-bear
                entity: group.robynne_lights
                variables:
                  accent_color: ${colors.pink}
                label: |
                  [[[
                    var yoto = states['media_player.yoto_player']?.state;
                    if (yoto === 'playing' || yoto === 'idle') {
                      return 'Yoto ' + yoto;
                    }
                    var entities = states['group.robynne_lights']?.attributes?.entity_id || [];
                    var count = entities.filter(e => states[e]?.state === 'on').length;
                    return count + ' lights on';
                  ]]]
                custom_fields:
                  s: |
                    [[[
                      const yoto = states['media_player.yoto_player'];
                      if (yoto && yoto.state === 'playing') {
                        return '<ha-icon icon="mdi:music" style="--mdc-icon-size:16px;color:${colors.green};"></ha-icon>';
                      }
                      return "";
                    ]]]
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/robynne

          # Scenes Title
          - type: custom:button-card
            template: minimal_title
            name: Scenes

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_scene
                name: All Off
                icon: mdi:power
                variables:
                  accent_color: ${colors.red}
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
                  accent_color: ${colors.purple}

              - type: custom:button-card
                template: minimal_scene
                name: Movie
                icon: mdi:movie
                variables:
                  accent_color: ${colors.blue}
                tap_action:
                  action: call-service
                  service: light.turn_off
                  service_data:
                    entity_id: all

              - type: custom:button-card
                template: minimal_scene
                name: Bright
                icon: mdi:brightness-7
                variables:
                  accent_color: ${colors.yellow}
                tap_action:
                  action: call-service
                  service: light.turn_on
                  service_data:
                    entity_id: group.living_room_lights
                    brightness: 255

          # RoboVac
          - type: custom:button-card
            template: minimal_title
            name: RoboVac

          - type: custom:button-card
            template: minimal_vacuum
            entity: vacuum.robovac

          # Media Title
          - type: custom:button-card
            template: minimal_title
            name: Media

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

      # ==================== LIVING ROOM VIEW ====================
      - title: Living Room
        path: living-room
        icon: mdi:sofa
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: minimal_header
            name: Living Room
            label: Lights & Media

          - type: custom:button-card
            template: minimal_title
            name: Lights

          - type: grid
            columns: 2
            square: false
            cards:
              - type: custom:button-card
                template: minimal_light
                entity: light.living_room_light
                name: Main Light
                variables:
                  accent_color: ${colors.yellow}

              - type: custom:button-card
                template: minimal_light
                entity: light.dining_room_light_3
                name: Dining Light
                variables:
                  accent_color: ${colors.yellow}

              - type: custom:button-card
                template: minimal_light
                entity: light.sofa_light_switch
                name: Sofa Light
                variables:
                  accent_color: ${colors.orange}

              - type: custom:button-card
                template: minimal_light
                entity: light.tv_light
                name: TV Light
                variables:
                  accent_color: ${colors.blue}

          - type: custom:button-card
            template: minimal_title
            name: Climate

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_fan
                entity: fan.dyson
                name: Dyson

              - type: custom:button-card
                template: minimal_sensor
                entity: sensor.dyson_temperature
                name: Temperature
                icon: mdi:thermometer
                variables:
                  accent_color: ${colors.red}

              - type: custom:button-card
                template: minimal_sensor
                entity: sensor.dyson_humidity
                name: Humidity
                icon: mdi:water-percent
                variables:
                  accent_color: ${colors.blue}

          - type: custom:button-card
            template: minimal_title
            name: Air Quality

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_sensor
                entity: sensor.dyson_pm_2_5
                name: PM 2.5
                icon: mdi:blur
                variables:
                  accent_color: ${colors.green}

              - type: custom:button-card
                template: minimal_sensor
                entity: sensor.dyson_pm_10
                name: PM 10
                icon: mdi:blur-linear
                variables:
                  accent_color: ${colors.blue}

              - type: custom:button-card
                template: minimal_sensor
                entity: sensor.dyson_volatile_organic_compounds_index
                name: VOC
                icon: mdi:molecule
                variables:
                  accent_color: ${colors.orange}

          - type: custom:button-card
            template: minimal_title
            name: Media

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_media
                entity: media_player.lg_webos_smart_tv
                name: LG TV

              - type: custom:button-card
                template: minimal_media
                entity: media_player.living_room_tv
                name: Apple TV

      # ==================== BEDROOM VIEW ====================
      - title: Bedroom
        path: bedroom
        icon: mdi:bed
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: minimal_header
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
                variables:
                  accent_color: ${colors.purple}

              - type: custom:button-card
                template: minimal_light
                entity: light.bedroom_light_2
                name: Main Light
                variables:
                  accent_color: ${colors.purple}

              - type: custom:button-card
                template: minimal_light
                entity: light.darren_switch
                name: Darren's Light
                variables:
                  accent_color: ${colors.blue}

              - type: custom:button-card
                template: minimal_light
                entity: light.lorraine_switch
                name: Lorraine's Light
                variables:
                  accent_color: ${colors.orange}

          - type: custom:button-card
            template: minimal_title
            name: Media

          - type: custom:button-card
            template: minimal_media
            entity: media_player.apple_tv
            name: Apple TV

      # ==================== BATHROOM VIEW ====================
      - title: Bathroom
        path: bathroom
        icon: mdi:shower
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: minimal_header
            name: Bathroom
            label: Lights & Climate

          - type: custom:button-card
            template: minimal_title
            name: Lights

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_light
                entity: light.bath_light
                name: Bath
                variables:
                  accent_color: ${colors.blue}

              - type: custom:button-card
                template: minimal_light
                entity: light.sink_light
                name: Sink
                variables:
                  accent_color: ${colors.blue}

              - type: custom:button-card
                template: minimal_light
                entity: light.toilet_light
                name: Toilet
                variables:
                  accent_color: ${colors.blue}

          - type: custom:button-card
            template: minimal_title
            name: Climate

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_sensor
                entity: sensor.bathroom_sensor_temperature
                name: Temperature
                icon: mdi:thermometer
                variables:
                  accent_color: ${colors.red}

              - type: custom:button-card
                template: minimal_sensor
                entity: sensor.bathroom_sensor_humidity
                name: Humidity
                icon: mdi:water-percent
                variables:
                  accent_color: ${colors.blue}

              - type: custom:button-card
                template: minimal_switch
                entity: switch.fingerbot_extractor_switch
                name: Extractor
                icon: mdi:fan

      # ==================== KITCHEN VIEW ====================
      - title: Kitchen
        path: kitchen
        icon: mdi:silverware-fork-knife
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: minimal_header
            name: Kitchen
            label: Lights

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_light
                entity: light.kitchen_microwave
                name: Main
                variables:
                  accent_color: ${colors.yellow}

              - type: custom:button-card
                template: minimal_light
                entity: light.kitchen_sink
                name: Sink
                variables:
                  accent_color: ${colors.yellow}

              - type: custom:button-card
                template: minimal_light
                entity: light.kitchen_random
                name: Other
                variables:
                  accent_color: ${colors.yellow}

      # ==================== HALLWAY VIEW ====================
      - title: Hallway
        path: hallway
        icon: mdi:door
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: minimal_header
            name: Hallway
            label: Lights & Sensors

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_light
                entity: light.hallway
                name: Hallway
                variables:
                  accent_color: ${colors.green}

              - type: custom:button-card
                template: minimal_light
                entity: light.doorway
                name: Doorway
                variables:
                  accent_color: ${colors.green}

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_sensor
                entity: sensor.hallway_sensor_temperature
                name: Temperature
                icon: mdi:thermometer
                variables:
                  accent_color: ${colors.red}

              - type: custom:button-card
                template: minimal_sensor
                entity: sensor.hallway_sensor_humidity
                name: Humidity
                icon: mdi:water-percent
                variables:
                  accent_color: ${colors.blue}

      # ==================== ROBYNNE'S ROOM VIEW ====================
      - title: Robynne's Room
        path: robynne
        icon: mdi:teddy-bear
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: minimal_header
            name: Robynne's Room
            label: Lights & Media

          - type: custom:button-card
            template: minimal_title
            name: Lights

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_light
                entity: light.robynne_light
                name: Main Light
                variables:
                  accent_color: ${colors.pink}

              - type: custom:button-card
                template: minimal_light
                entity: light.fairy_lights_switch
                name: Fairy Lights
                variables:
                  accent_color: ${colors.purple}

              - type: custom:button-card
                template: minimal_light
                entity: light.aarlo_nursery
                name: Night Light
                variables:
                  accent_color: ${colors.orange}

          - type: custom:button-card
            template: minimal_title
            name: Yoto Player

          - type: custom:button-card
            template: minimal_media
            entity: media_player.yoto_player
            name: Yoto Player
            icon: mdi:speaker
            variables:
              accent_color: ${colors.green}

      # ==================== CAR VIEW ====================
      - title: Car
        path: car
        icon: mdi:car
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: minimal_header
            name: Ford
            label: Vehicle Status

          - type: custom:button-card
            show_name: false
            show_icon: false
            show_label: false
            styles:
              card:
                - background: ${colors.contrast1}
                - border-radius: ${design.borderRadius}
                - box-shadow: ${design.shadow}
                - padding: 20px
            custom_fields:
              status: |
                [[[
                  const door = states['sensor.fordpass_wf02xxerk2la80437_doorstatus']?.state || 'Unknown';
                  const window = states['sensor.fordpass_wf02xxerk2la80437_windowposition']?.state || 'Unknown';
                  const lastRefresh = states['sensor.fordpass_wf02xxerk2la80437_lastrefresh']?.state;
                  const messages = states['sensor.fordpass_wf02xxerk2la80437_messages']?.state || '0';

                  const refreshDate = lastRefresh ? new Date(lastRefresh) : null;
                  const isStale = !refreshDate || refreshDate.getFullYear() < 2020;
                  const refreshStr = isStale ? 'Not synced' : refreshDate.toLocaleString('en-GB');

                  const doorColor = door === 'Closed' ? '${colors.green}' : '${colors.red}';
                  const doorIcon = door === 'Closed' ? 'mdi:car-door-lock' : 'mdi:car-door';
                  const windowColor = window === 'Closed' ? '${colors.green}' : '${colors.yellow}';

                  return '<div style="display:flex;flex-direction:column;gap:16px;">' +
                    '<div style="display:flex;align-items:center;justify-content:center;">' +
                      '<ha-icon icon="mdi:car" style="--mdc-icon-size:48px;color:${colors.blue};"></ha-icon>' +
                    '</div>' +
                    '<div style="display:flex;justify-content:space-around;text-align:center;">' +
                      '<div style="display:flex;flex-direction:column;align-items:center;gap:4px;">' +
                        '<ha-icon icon="' + doorIcon + '" style="--mdc-icon-size:24px;color:' + doorColor + ';"></ha-icon>' +
                        '<span style="font-size:11px;color:${colors.contrast14};">Doors</span>' +
                        '<span style="font-size:14px;font-weight:600;color:${colors.contrast18};">' + door + '</span>' +
                      '</div>' +
                      '<div style="display:flex;flex-direction:column;align-items:center;gap:4px;">' +
                        '<ha-icon icon="mdi:car-door" style="--mdc-icon-size:24px;color:' + windowColor + ';"></ha-icon>' +
                        '<span style="font-size:11px;color:${colors.contrast14};">Windows</span>' +
                        '<span style="font-size:14px;font-weight:600;color:${colors.contrast18};">' + window + '</span>' +
                      '</div>' +
                      '<div style="display:flex;flex-direction:column;align-items:center;gap:4px;">' +
                        '<ha-icon icon="mdi:message-badge" style="--mdc-icon-size:24px;color:' + (parseInt(messages) > 0 ? '${colors.orange}' : '${colors.contrast14}') + ';"></ha-icon>' +
                        '<span style="font-size:11px;color:${colors.contrast14};">Messages</span>' +
                        '<span style="font-size:14px;font-weight:600;color:${colors.contrast18};">' + messages + '</span>' +
                      '</div>' +
                    '</div>' +
                    '<div style="display:flex;justify-content:center;padding-top:12px;border-top:1px solid ${colors.contrast5};">' +
                      '<span style="font-size:11px;color:' + (isStale ? '${colors.red}' : '${colors.contrast14}') + ';">' +
                        '<ha-icon icon="mdi:sync" style="--mdc-icon-size:14px;margin-right:4px;"></ha-icon>' +
                        refreshStr +
                      '</span>' +
                    '</div>' +
                  '</div>';
                ]]]

          - type: custom:button-card
            template: minimal_title
            name: Controls

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_scene
                name: Lock
                icon: mdi:car-door-lock
                variables:
                  accent_color: ${colors.green}
                tap_action:
                  action: call-service
                  service: button.press
                  service_data:
                    entity_id: button.fordpass_wf02xxerk2la80437_doorlock

              - type: custom:button-card
                template: minimal_scene
                name: Unlock
                icon: mdi:lock-open-variant
                variables:
                  accent_color: ${colors.orange}
                tap_action:
                  action: call-service
                  service: button.press
                  service_data:
                    entity_id: button.fordpass_wf02xxerk2la80437_doorunlock

              - type: custom:button-card
                template: minimal_scene
                name: Sync
                icon: mdi:sync
                variables:
                  accent_color: ${colors.blue}
                tap_action:
                  action: call-service
                  service: button.press
                  service_data:
                    entity_id: button.fordpass_wf02xxerk2la80437_request_refresh

          - type: custom:button-card
            template: minimal_title
            name: Vehicle Stats

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_sensor
                name: Fuel
                icon: mdi:gas-station
                entity: sensor.fordpass_wf02xxerk2la80437_fuel
                variables:
                  accent_color: ${colors.green}
                label: |
                  [[[
                    const val = states['sensor.fordpass_wf02xxerk2la80437_fuel']?.state;
                    return val === 'unknown' ? '--' : val + '%';
                  ]]]

              - type: custom:button-card
                template: minimal_sensor
                name: Oil Life
                icon: mdi:oil
                entity: sensor.fordpass_wf02xxerk2la80437_oil
                variables:
                  accent_color: ${colors.yellow}
                label: |
                  [[[
                    const val = states['sensor.fordpass_wf02xxerk2la80437_oil']?.state;
                    return val === 'unknown' ? '--' : val + '%';
                  ]]]

              - type: custom:button-card
                template: minimal_sensor
                name: Battery
                icon: mdi:car-battery
                entity: sensor.fordpass_wf02xxerk2la80437_battery
                variables:
                  accent_color: ${colors.blue}
                label: |
                  [[[
                    const val = states['sensor.fordpass_wf02xxerk2la80437_battery']?.state;
                    return val === 'unknown' ? '--' : val + '%';
                  ]]]

      # ==================== FISH TANK VIEW ====================
      - title: Fish Tank
        path: fish-tank
        icon: mdi:fish
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: minimal_header
            name: Fish Tank
            label: Water Parameters

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_sensor
                entity: sensor.current_temperature
                name: Temperature
                icon: mdi:thermometer
                variables:
                  accent_color: ${colors.blue}

              - type: custom:button-card
                template: minimal_sensor
                entity: sensor.ph_value
                name: pH Level
                icon: mdi:ph
                variables:
                  accent_color: ${colors.green}

              - type: custom:button-card
                template: minimal_sensor
                entity: sensor.salinity_value
                name: Salinity
                icon: mdi:shaker-outline
                variables:
                  accent_color: ${colors.orange}

          - type: custom:button-card
            template: minimal_title
            name: Water Quality

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: minimal_sensor
                entity: sensor.tds_value
                name: TDS
                icon: mdi:water-opacity
                variables:
                  accent_color: ${colors.purple}

              - type: custom:button-card
                template: minimal_sensor
                entity: sensor.ec_value
                name: EC
                icon: mdi:flash
                variables:
                  accent_color: ${colors.yellow}

              - type: custom:button-card
                template: minimal_sensor
                entity: sensor.orp_value
                name: ORP
                icon: mdi:molecule
                variables:
                  accent_color: ${colors.green}
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
