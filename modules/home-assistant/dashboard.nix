{pkgs, ...}: let
  # Catppuccin Mocha colors
  colors = {
    # Accent colors
    mauve = "#cba6f7";
    peach = "#fab387";
    blue = "#89b4fa";
    green = "#a6e3a1";
    red = "#f38ba8";
    yellow = "#f9e2af";
    # Text colors
    text = "#cdd6f4"; # Primary text
    subtext = "#a6adc8"; # Secondary/muted text
    # Surface colors
    surface0 = "#313244"; # Card backgrounds
    base = "#1e1e2e"; # Page background
    mantle = "#181825"; # Darker background
  };

  # Opacity values for RGBA backgrounds
  opacity = {
    subtle = "0.1"; # Inactive/off states
    light = "0.2"; # Default icon backgrounds
    medium = "0.3"; # Active state overlays
  };

  # Button card templates YAML content (as a string for inlining)
  # Note: This includes the button_card_templates key itself to avoid indentation issues
  buttonCardTemplatesContent = ''
    button_card_templates:
      # HaCasa-style Button Card Templates with Catppuccin Mocha colors

      hc_base_card:
        variables:
          card_color: "${colors.mauve}"
          custom_label: ""
        show_name: true
        show_icon: true
        show_label: true
        show_state: false
        styles:
          grid:
            - grid-template-areas: |
                ". i" "n n" "l l"
            - grid-template-rows: min-content min-content 1fr
          card:
            - padding: 12px
            - height: 100px
            - background: ${colors.surface0}
            - border-radius: 20px
          name:
            - text-align: left
            - font-size: 14px
            - font-weight: 600
            - justify-self: start
            - align-self: end
            - color: ${colors.text}
          label:
            - text-align: left
            - font-size: 12px
            - font-weight: 400
            - justify-self: start
            - align-self: center
            - color: ${colors.subtext}
          icon:
            - width: 50%
            - color: ${colors.subtext}
          img_cell:
            - background: rgba(203, 166, 247, 0.2)
            - border-radius: 50%
            - width: 35px
            - height: 35px
            - align-self: start
            - margin-bottom: 10px
            - justify-self: end
        state:
          - value: "on"
            styles:
              card:
                - background: "[[[ return variables.card_color ]]]"
              name:
                - color: "#11111b"
              label:
                - color: "#11111b"
              icon:
                - color: "#11111b"
              img_cell:
                - background: rgba(17, 17, 27, 0.25)
          - value: "off"
            styles:
              icon:
                - color: ${colors.subtext}
              img_cell:
                - background: rgba(166, 173, 200, 0.1)
          - value: "unavailable"
            styles:
              name:
                - text-decoration: line-through
              card:
                - opacity: 0.5
            label: Unavailable

      hc_light_card:
        template: hc_base_card
        icon: mdi:lightbulb
        hold_action:
          action: more-info
        label: |
          [[[
            const state = states[entity.entity_id];
            if (!state) return 'Unknown';
            if (state.attributes && state.attributes.brightness) {
              var bri = Math.round(state.attributes.brightness / 2.55);
              return bri + '%';
            }
            return state.state;
          ]]]
        state:
          - value: "on"
            icon: mdi:lightbulb-on
            styles:
              card:
                - background: "[[[ return variables.card_color ]]]"
              name:
                - color: "#11111b"
              label:
                - color: "#11111b"
              icon:
                - color: "#11111b"
          - value: "off"
            icon: mdi:lightbulb-outline

      hc_switch_card:
        template: hc_base_card
        icon: mdi:power-plug
        hold_action:
          action: more-info
        label: "[[[ return states[entity.entity_id]?.state || 'Unknown' ]]]"

      hc_navigation_card:
        show_name: true
        show_icon: true
        show_label: true
        variables:
          hc_color: "${colors.blue}"
          hc_label_prefix: ""
        styles:
          grid:
            - grid-template-areas: '"n n" "l l"'
            - grid-template-rows: 1fr 1fr
          card:
            - padding: 20px
            - height: 120px
            - background: ${colors.surface0}
            - border-radius: 20px
          name:
            - text-align: left
            - font-size: 16px
            - font-weight: 700
            - justify-self: start
            - align-self: start
            - color: ${colors.text}
          label:
            - justify-self: start
            - align-self: end
            - font-size: 12px
            - font-weight: 500
            - color: ${colors.subtext}
          img_cell:
            - position: absolute
            - top: 10%
            - right: -10%
            - overflow: visible
          icon:
            - position: absolute
            - width: 8em
            - opacity: 0.15
            - color: "[[[ return variables.hc_color ]]]"

      hc_scene_card:
        show_name: true
        show_icon: true
        show_label: false
        variables:
          hc_color: "${colors.peach}"
        styles:
          card:
            - padding: 15px
            - height: 80px
            - background: ${colors.surface0}
            - border-radius: 20px
          grid:
            - grid-template-areas: '"i" "n"'
            - grid-template-rows: 1fr min-content
          name:
            - font-size: 12px
            - font-weight: 600
            - color: ${colors.text}
            - justify-self: center
          icon:
            - color: "[[[ return variables.hc_color ]]]"
            - width: 30px
        state:
          - value: "on"
            styles:
              card:
                - background: "[[[ return variables.hc_color ]]]"
              name:
                - color: ${colors.base}
              icon:
                - color: ${colors.base}

      hc_media_card:
        template: hc_base_card
        icon: mdi:television
        variables:
          card_color: "${colors.blue}"
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
            - height: 120px
        state:
          - value: "on"
            icon: mdi:television
            styles:
              card:
                - background: ${colors.blue}
              name:
                - color: ${colors.base}
              label:
                - color: ${colors.base}
              icon:
                - color: ${colors.base}
          - value: "playing"
            icon: mdi:play-circle
            styles:
              card:
                - background: ${colors.green}
              name:
                - color: ${colors.base}
              label:
                - color: ${colors.base}
              icon:
                - color: ${colors.base}
          - value: "paused"
            icon: mdi:pause-circle
            styles:
              card:
                - background: ${colors.yellow}
              name:
                - color: ${colors.base}
              label:
                - color: ${colors.base}
              icon:
                - color: ${colors.base}

      hc_sensor_card:
        show_name: true
        show_icon: true
        show_label: true
        show_state: false
        label: |
          [[[
            const state = states[entity.entity_id];
            if (!state) return 'Unknown';
            return state.state + (state.attributes?.unit_of_measurement || "");
          ]]]
        styles:
          card:
            - padding: 12px
            - height: 80px
            - background: ${colors.surface0}
            - border-radius: 20px
          grid:
            - grid-template-areas: '"i n" "i l"'
            - grid-template-columns: 40px 1fr
          name:
            - font-size: 12px
            - color: ${colors.subtext}
            - justify-self: start
            - align-self: end
          label:
            - font-size: 18px
            - font-weight: 700
            - color: ${colors.text}
            - justify-self: start
            - align-self: start
          icon:
            - color: ${colors.mauve}
            - width: 24px

      hc_header_card:
        show_name: true
        show_icon: false
        show_label: true
        show_state: false
        styles:
          card:
            - background: transparent
            - box-shadow: none
            - padding: 20px 5px
          grid:
            - grid-template-areas: '"n" "l"'
          name:
            - font-size: 28px
            - font-weight: 700
            - color: ${colors.text}
            - justify-self: start
          label:
            - font-size: 14px
            - color: ${colors.subtext}
            - justify-self: start

      hc_title_card:
        show_name: true
        show_icon: false
        show_label: false
        styles:
          card:
            - background: transparent
            - box-shadow: none
            - padding: 10px 5px
          name:
            - font-size: 20px
            - font-weight: 600
            - color: ${colors.text}
            - justify-self: start

      hc_fan_card:
        template: hc_base_card
        icon: mdi:fan
        variables:
          card_color: "${colors.blue}"
        hold_action:
          action: more-info
        label: |
          [[[
            const state = states[entity.entity_id];
            if (!state) return 'Unknown';
            if (state.state === 'on') {
              return (state.attributes?.percentage || 0) + '%';
            }
            return state.state;
          ]]]
        state:
          - value: "on"
            icon: mdi:fan
            styles:
              card:
                - background: "[[[ return variables.card_color ]]]"
              name:
                - color: ${colors.base}
              label:
                - color: ${colors.base}
              icon:
                - color: ${colors.base}
                - animation: spin 1s linear infinite
        extra_styles: |
          @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
          }

      hc_person_card:
        show_name: true
        show_icon: true
        show_label: true
        show_state: false
        label: "[[[ return states[entity.entity_id]?.state || 'Unknown' ]]]"
        styles:
          card:
            - padding: 12px
            - height: 80px
            - background: ${colors.surface0}
            - border-radius: 20px
          grid:
            - grid-template-areas: '"i n" "i l"'
            - grid-template-columns: 50px 1fr
          name:
            - font-size: 14px
            - font-weight: 600
            - color: ${colors.text}
            - justify-self: start
            - align-self: end
          label:
            - font-size: 12px
            - color: ${colors.subtext}
            - justify-self: start
            - align-self: start
          icon:
            - color: ${colors.mauve}
            - width: 30px
        state:
          - value: "home"
            icon: mdi:home-account
            styles:
              label:
                - color: ${colors.green}
          - value: "not_home"
            icon: mdi:account-arrow-right
            styles:
              label:
                - color: ${colors.subtext}

      hc_vacuum_card:
        show_name: false
        show_icon: false
        show_label: false
        show_state: false
        styles:
          card:
            - padding: 16px
            - background: ${colors.surface0}
            - border-radius: 20px
          grid:
            - grid-template-areas: '"vacuum" "controls"'
            - grid-template-rows: auto auto
          custom_fields:
            vacuum:
              - justify-self: stretch
            controls:
              - justify-self: stretch
        custom_fields:
          vacuum: |
            [[[
              const vacuumEntity = states['vacuum.robovac'];
              const batteryEntity = states['sensor.robovac_battery'];
              const state = vacuumEntity ? vacuumEntity.state : 'unavailable';
              const battery = batteryEntity ? batteryEntity.state : '0';
              const batteryNum = parseInt(battery) ? parseInt(battery) : 0;

              var stateColor = '${colors.subtext}';
              if (state === 'cleaning') stateColor = '${colors.green}';
              else if (state === 'docked') stateColor = '${colors.blue}';
              else if (state === 'paused') stateColor = '${colors.yellow}';
              else if (state === 'returning') stateColor = '${colors.peach}';
              else if (state === 'idle') stateColor = '${colors.subtext}';
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
                  '<ha-icon icon="mdi:robot-vacuum" style="--mdc-icon-size:36px;color:' + stateColor + ';"></ha-icon>' +
                  '<div style="display:flex;flex-direction:column;">' +
                    '<span style="font-size:16px;font-weight:600;color:${colors.text};">RoboVac</span>' +
                    '<span style="font-size:12px;color:' + stateColor + ';text-transform:capitalize;">' + state + '</span>' +
                  '</div>' +
                '</div>' +
                '<div style="display:flex;align-items:center;gap:4px;">' +
                  '<ha-icon icon="' + batteryIcon + '" style="--mdc-icon-size:20px;color:' + batteryColor + ';"></ha-icon>' +
                  '<span style="font-size:14px;font-weight:600;color:${colors.text};">' + battery + '%</span>' +
                '</div>' +
              '</div>';
            ]]]
          controls: |
            [[[
              return '<div style="display:flex;justify-content:space-around;padding-top:12px;border-top:1px solid ${colors.base};">' +
                '<div style="display:flex;flex-direction:column;align-items:center;cursor:pointer;padding:8px;">' +
                  '<ha-icon icon="mdi:play" style="--mdc-icon-size:24px;color:${colors.green};"></ha-icon>' +
                  '<span style="font-size:11px;color:${colors.subtext};margin-top:4px;">Start</span>' +
                '</div>' +
                '<div style="display:flex;flex-direction:column;align-items:center;cursor:pointer;padding:8px;">' +
                  '<ha-icon icon="mdi:pause" style="--mdc-icon-size:24px;color:${colors.yellow};"></ha-icon>' +
                  '<span style="font-size:11px;color:${colors.subtext};margin-top:4px;">Pause</span>' +
                '</div>' +
                '<div style="display:flex;flex-direction:column;align-items:center;cursor:pointer;padding:8px;">' +
                  '<ha-icon icon="mdi:home" style="--mdc-icon-size:24px;color:${colors.blue};"></ha-icon>' +
                  '<span style="font-size:11px;color:${colors.subtext};margin-top:4px;">Dock</span>' +
                '</div>' +
                '<div style="display:flex;flex-direction:column;align-items:center;cursor:pointer;padding:8px;">' +
                  '<ha-icon icon="mdi:map-marker" style="--mdc-icon-size:24px;color:${colors.peach};"></ha-icon>' +
                  '<span style="font-size:11px;color:${colors.subtext};margin-top:4px;">Find</span>' +
                '</div>' +
              '</div>';
            ]]]

      hc_weather_detailed_card:
        show_name: false
        show_icon: false
        show_label: false
        show_state: false
        entity: weather.forecast_home
        styles:
          card:
            - padding: 16px
            - background: ${colors.surface0}
            - border-radius: 20px
        custom_fields:
          weather: |
            [[[
              const weather = states['weather.forecast_home'];
              if (!weather) return '<div style="color:${colors.subtext};">Weather unavailable</div>';
              const state = weather.state || 'unknown';
              const attr = weather.attributes || {};
              const temp = attr.temperature ?? '--';
              const humidity = attr.humidity ?? '--';
              const wind = attr.wind_speed ?? '--';
              const pressure = attr.pressure ?? '--';
              const uv = attr.uv_index ?? 0;
              const feelsLike = attr.apparent_temperature ?? temp;

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
                'partlycloudy': '${colors.peach}',
                'cloudy': '${colors.subtext}',
                'rainy': '${colors.blue}',
                'pouring': '${colors.blue}',
                'snowy': '${colors.text}',
                'fog': '${colors.subtext}',
                'windy': '${colors.mauve}',
                'lightning': '${colors.yellow}'
              };
              const color = weatherColors[state] || '${colors.subtext}';

              const stateText = state.replace(/-/g, ' ').replace(/\b\w/g, function(l){ return l.toUpperCase(); });

              return '<div style="display:flex;align-items:center;gap:16px;">' +
                '<ha-icon icon="' + icon + '" style="--mdc-icon-size:52px;color:' + color + ';flex-shrink:0;"></ha-icon>' +
                '<div style="display:flex;flex-direction:column;gap:2px;">' +
                  '<div style="display:flex;align-items:baseline;gap:8px;">' +
                    '<span style="font-size:36px;font-weight:700;color:${colors.text};">' + temp + '°</span>' +
                    '<span style="font-size:14px;color:${colors.subtext};">Feels ' + feelsLike + '°</span>' +
                  '</div>' +
                  '<span style="font-size:13px;color:${colors.subtext};">' + stateText + '</span>' +
                '</div>' +
                '<div style="margin-left:auto;display:grid;grid-template-columns:1fr 1fr;gap:8px 16px;">' +
                  '<div style="display:flex;align-items:center;gap:6px;">' +
                    '<ha-icon icon="mdi:water-percent" style="--mdc-icon-size:16px;color:${colors.blue};"></ha-icon>' +
                    '<span style="font-size:13px;color:${colors.text};">' + humidity + '%</span>' +
                  '</div>' +
                  '<div style="display:flex;align-items:center;gap:6px;">' +
                    '<ha-icon icon="mdi:weather-windy" style="--mdc-icon-size:16px;color:${colors.mauve};"></ha-icon>' +
                    '<span style="font-size:13px;color:${colors.text};">' + wind + ' km/h</span>' +
                  '</div>' +
                  '<div style="display:flex;align-items:center;gap:6px;">' +
                    '<ha-icon icon="mdi:gauge" style="--mdc-icon-size:16px;color:${colors.peach};"></ha-icon>' +
                    '<span style="font-size:13px;color:${colors.text};">' + pressure + ' hPa</span>' +
                  '</div>' +
                  '<div style="display:flex;align-items:center;gap:6px;">' +
                    '<ha-icon icon="mdi:white-balance-sunny" style="--mdc-icon-size:16px;color:${colors.yellow};"></ha-icon>' +
                    '<span style="font-size:13px;color:${colors.text};">UV ' + uv + '</span>' +
                  '</div>' +
                '</div>' +
              '</div>';
            ]]]

      hc_weather_compact_card:
        show_name: false
        show_icon: false
        show_label: false
        show_state: false
        entity: weather.forecast_home
        styles:
          card:
            - padding: 12px 16px
            - background: ${colors.surface0}
            - border-radius: 20px
        custom_fields:
          weather: |
            [[[
              const weather = states['weather.forecast_home'];
              if (!weather) return '<div style="color:${colors.subtext};">Weather unavailable</div>';
              const state = weather.state || 'unknown';
              const attr = weather.attributes || {};
              const temp = attr.temperature ?? '--';
              const feelsLike = attr.apparent_temperature ?? temp;

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
                'partlycloudy': '${colors.peach}',
                'cloudy': '${colors.subtext}',
                'rainy': '${colors.blue}',
                'pouring': '${colors.blue}',
                'snowy': '${colors.text}',
                'fog': '${colors.subtext}',
                'windy': '${colors.mauve}',
                'lightning': '${colors.yellow}'
              };
              const color = weatherColors[state] || '${colors.subtext}';

              const stateText = state.replace(/-/g, ' ').replace(/\b\w/g, function(l){ return l.toUpperCase(); });

              return '<div style="display:flex;align-items:center;gap:12px;">' +
                '<ha-icon icon="' + icon + '" style="--mdc-icon-size:28px;color:' + color + ';"></ha-icon>' +
                '<span style="font-size:24px;font-weight:700;color:${colors.text};">' + temp + '°</span>' +
                '<span style="font-size:13px;color:${colors.subtext};">Feels ' + feelsLike + '°</span>' +
                '<span style="font-size:13px;color:${colors.subtext};margin-left:auto;text-transform:capitalize;">' + stateText + '</span>' +
              '</div>';
            ]]]

      hc_stat_card:
        show_name: true
        show_icon: true
        show_label: false
        show_state: true
        styles:
          card:
            - padding: 16px
            - background: ${colors.surface0}
            - border-radius: 20px
          grid:
            - grid-template-areas: '"i s" "i n"'
            - grid-template-columns: 40px 1fr
            - grid-template-rows: 1fr auto
          icon:
            - width: 28px
            - justify-self: start
          state:
            - font-size: 28px
            - font-weight: 700
            - color: ${colors.text}
            - justify-self: start
            - align-self: end
          name:
            - font-size: 11px
            - font-weight: 500
            - color: ${colors.subtext}
            - text-transform: uppercase
            - letter-spacing: 0.5px
            - justify-self: start
            - align-self: start

      hc_appliance_card:
        show_name: true
        show_icon: true
        show_label: true
        show_state: false
        styles:
          card:
            - padding: 12px
            - background: ${colors.surface0}
            - border-radius: 20px
          grid:
            - grid-template-areas: '"i n" "i l"'
            - grid-template-columns: 40px 1fr
          name:
            - font-size: 12px
            - color: ${colors.subtext}
            - justify-self: start
            - align-self: end
          label:
            - font-size: 16px
            - font-weight: 600
            - justify-self: start
            - align-self: start
          icon:
            - width: 24px

      hc_server_stats_card:
        show_name: false
        show_icon: false
        show_label: false
        show_state: false
        styles:
          card:
            - padding: 16px
            - background: ${colors.surface0}
            - border-radius: 20px
          grid:
            - grid-template-areas: '"stats stats stats" "uptime uptime uptime"'
            - grid-template-columns: 1fr 1fr 1fr
        custom_fields:
          stats: |
            [[[
              const load1 = parseFloat(states['sensor.system_monitor_load_1m']?.state || 0).toFixed(1);
              const load5 = parseFloat(states['sensor.system_monitor_load_5m']?.state || 0).toFixed(1);
              const load15 = parseFloat(states['sensor.system_monitor_load_15m']?.state || 0).toFixed(1);
              const disk = parseFloat(states['sensor.system_monitor_disk_free']?.state || 0).toFixed(0);
              const updates = states['update.home_assistant_core']?.state === 'on' ? '1' : '0';

              return `<div style="display:flex;justify-content:space-around;width:100%;">
                <div style="display:flex;flex-direction:column;align-items:center;">
                  <span style="font-size:11px;color:${colors.subtext};text-transform:uppercase;">Load</span>
                  <span style="font-size:18px;font-weight:600;color:${colors.text};">''${load1}</span>
                  <span style="font-size:10px;color:${colors.subtext};">''${load5} / ''${load15}</span>
                </div>
                <div style="display:flex;flex-direction:column;align-items:center;">
                  <span style="font-size:11px;color:${colors.subtext};text-transform:uppercase;">Disk</span>
                  <span style="font-size:18px;font-weight:600;color:${colors.text};">''${disk}</span>
                  <span style="font-size:10px;color:${colors.subtext};">GiB free</span>
                </div>
                <div style="display:flex;flex-direction:column;align-items:center;">
                  <span style="font-size:11px;color:${colors.subtext};text-transform:uppercase;">Updates</span>
                  <span style="font-size:18px;font-weight:600;color:''${updates > 0 ? '${colors.peach}' : '${colors.green}'};">''${updates}</span>
                  <span style="font-size:10px;color:${colors.subtext};">pending</span>
                </div>
              </div>`;
            ]]]
          uptime: |
            [[[
              const bootState = states['sensor.system_monitor_last_boot']?.state;
              const lastBoot = bootState ? new Date(bootState) : new Date();
              const now = new Date();
              const diff = now - lastBoot;
              const days = Math.floor(diff / (1000 * 60 * 60 * 24));
              const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));

              return `<div style="display:flex;justify-content:center;margin-top:12px;padding-top:12px;border-top:1px solid ${colors.base};">
                <span style="font-size:12px;color:${colors.subtext};">
                  <span style="color:${colors.green};">●</span> Uptime: ''${days}d ''${hours}h
                </span>
              </div>`;
            ]]]

      hc_battery_alerts_card:
        entity: sensor.processor_use
        show_name: false
        show_icon: false
        show_label: false
        show_state: false
        show_entity_picture: false
        styles:
          card:
            - padding: 16px
            - background: ${colors.surface0}
            - border-radius: 20px
        custom_fields:
          alerts: |
            [[[
              return '<div style="display:flex;align-items:center;justify-content:center;padding:8px;"><ha-icon icon="mdi:battery-check" style="color:${colors.green};--mdc-icon-size:20px;margin-right:8px;"></ha-icon><span style="font-size:14px;color:${colors.text};">All batteries OK</span></div>';
            ]]]

      hc_football_card:
        show_name: false
        show_icon: false
        show_label: false
        show_state: false
        show_entity_picture: false
        variables:
          sensors: |
            [[[
              return ["sensor.liverpool", "sensor.liverpool_cl", "sensor.liverpool_fa", "sensor.liverpool_lc"];
            ]]]
        styles:
          card:
            - padding: 16px
            - background: ${colors.surface0}
            - border-radius: 20px
          grid:
            - grid-template-areas: '"content"'
            - grid-template-columns: 1fr
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
                return '<div style="text-align:center;color:${colors.subtext};padding:20px;">No upcoming matches</div>';
              }

              var attr = match.attributes;
              var state = match.state;
              var isHome = attr.team_homeaway === "home";
              var teamLogo = attr.team_logo ? attr.team_logo : "";
              var oppLogo = attr.opponent_logo ? attr.opponent_logo : "";
              var teamAbbr = attr.team_abbr ? attr.team_abbr : "HOME";
              var oppAbbr = attr.opponent_abbr ? attr.opponent_abbr : "AWAY";
              var homeLogo = isHome ? teamLogo : oppLogo;
              var awayLogo = isHome ? oppLogo : teamLogo;
              var homeName = isHome ? teamAbbr : oppAbbr;
              var awayName = isHome ? oppAbbr : teamAbbr;
              var teamScore = attr.team_score ? attr.team_score : 0;
              var oppScore = attr.opponent_score ? attr.opponent_score : 0;
              var homeScore = isHome ? teamScore : oppScore;
              var awayScore = isHome ? oppScore : teamScore;
              var kickoff = attr.kickoff_in ? attr.kickoff_in : "--";
              var clock = attr.clock ? attr.clock : "";
              var venue = attr.venue ? attr.venue : "TBD";
              var league = attr.league ? attr.league : "";

              var scoreHtml = "";
              if (state === "PRE") {
                var kickoffDate = attr.date ? new Date(attr.date) : null;
                var kickoffStr = kickoff;
                if (kickoffDate && !isNaN(kickoffDate)) {
                  var opts = { weekday: 'short', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' };
                  kickoffStr = kickoffDate.toLocaleString('en-GB', opts);
                }
                scoreHtml = '<div style="display:flex;flex-direction:column;align-items:center;"><span style="font-size:11px;color:${colors.subtext};text-transform:uppercase;">Next Match</span><span style="font-size:14px;font-weight:600;color:${colors.mauve};">' + kickoffStr + '</span></div>';
              } else if (state === "IN") {
                scoreHtml = '<div style="display:flex;flex-direction:column;align-items:center;"><span style="font-size:11px;color:${colors.green};text-transform:uppercase;font-weight:600;">LIVE ' + clock + '</span><span style="font-size:28px;font-weight:700;color:${colors.text};">' + homeScore + ' - ' + awayScore + '</span></div>';
              } else {
                scoreHtml = '<div style="display:flex;flex-direction:column;align-items:center;"><span style="font-size:11px;color:${colors.subtext};text-transform:uppercase;">Final</span><span style="font-size:28px;font-weight:700;color:${colors.text};">' + homeScore + ' - ' + awayScore + '</span></div>';
              }

              return '<div style="display:flex;flex-direction:column;gap:12px;">' +
                '<div style="display:flex;align-items:center;justify-content:space-between;">' +
                  '<div style="display:flex;flex-direction:column;align-items:center;gap:8px;flex:1;">' +
                    '<img src="' + homeLogo + '" style="width:50px;height:50px;object-fit:contain;">' +
                    '<span style="font-size:12px;font-weight:600;color:${colors.text};">' + homeName + '</span>' +
                  '</div>' +
                  '<div style="flex:1;">' + scoreHtml + '</div>' +
                  '<div style="display:flex;flex-direction:column;align-items:center;gap:8px;flex:1;">' +
                    '<img src="' + awayLogo + '" style="width:50px;height:50px;object-fit:contain;">' +
                    '<span style="font-size:12px;font-weight:600;color:${colors.text};">' + awayName + '</span>' +
                  '</div>' +
                '</div>' +
                '<div style="text-align:center;padding-top:8px;border-top:1px solid ${colors.base};"><span style="font-size:11px;color:${colors.subtext};">' + league + (venue ? ' • ' + venue : "") + '</span></div>' +
              '</div>';
            ]]]
  '';

  # Dashboard YAML content
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
            template: hc_header_card
            name: |
              [[[
                var hour = new Date().getHours();
                var greeting = hour < 12 ? 'Good Morning' : hour < 18 ? 'Good Afternoon' : 'Good Evening';
                return greeting;
              ]]]
            label: |
              [[[
                var date = new Date();
                var options = { weekday: 'long', month: 'long', day: 'numeric' };
                return date.toLocaleDateString('en-GB', options);
              ]]]

          # Weather (Compact)
          - type: custom:button-card
            template: hc_weather_compact_card
            entity: weather.forecast_home

          # Stats Row
          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: hc_stat_card
                name: Lights
                icon: mdi:lightbulb-group
                show_state: false
                custom_fields:
                  s: |
                    [[[
                      const lights = Object.values(states).filter(e =>
                        e.entity_id.startsWith('light.') && e.state === 'on'
                      );
                      return lights.length;
                    ]]]
                styles:
                  grid:
                    - grid-template-areas: '"i s" "i n"'
                    - grid-template-columns: 40px 1fr
                  custom_fields:
                    s:
                      - font-size: 28px
                      - font-weight: 700
                      - color: ${colors.text}
                      - justify-self: start
                      - align-self: end
                  icon:
                    - color: ${colors.yellow}

              - type: custom:button-card
                template: hc_stat_card
                name: Motion
                icon: mdi:motion-sensor
                entity: sensor.total_active_motion_sensors_count_template
                styles:
                  icon:
                    - color: ${colors.blue}

              - type: custom:button-card
                template: hc_stat_card
                name: Avg Temp
                icon: mdi:thermometer
                show_state: false
                custom_fields:
                  s: |
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
                styles:
                  grid:
                    - grid-template-areas: '"i s" "i n"'
                    - grid-template-columns: 40px 1fr
                  custom_fields:
                    s:
                      - font-size: 28px
                      - font-weight: 700
                      - color: ${colors.text}
                      - justify-self: start
                      - align-self: end
                  icon:
                    - color: ${colors.red}

          # Liverpool FC - Shows next match from Premier League, Champions League, FA Cup, or League Cup
          - type: custom:button-card
            template: hc_football_card
            entity: sensor.liverpool

          # People
          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: hc_person_card
                entity: person.darren_gilbert
                name: Darren
              - type: custom:button-card
                template: hc_person_card
                entity: person.lorraine
                name: Lorraine

          # Room Navigation Cards
          - type: custom:button-card
            template: hc_title_card
            name: Rooms

          - type: grid
            columns: 2
            square: false
            cards:
              - type: custom:button-card
                template: hc_navigation_card
                name: Living Room
                icon: mdi:sofa
                entity: group.living_room_lights
                label: |
                  [[[
                    var entities = states['group.living_room_lights']?.attributes?.entity_id || [];
                    var count = entities.filter(e => states[e]?.state === 'on').length;
                    return count + ' lights on';
                  ]]]
                variables:
                  hc_color: "${colors.peach}"
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/living-room

              - type: custom:button-card
                template: hc_navigation_card
                name: Bedroom
                icon: mdi:bed
                entity: group.bedroom_lights
                label: |
                  [[[
                    var entities = states['group.bedroom_lights']?.attributes?.entity_id || [];
                    var count = entities.filter(e => states[e]?.state === 'on').length;
                    return count + ' lights on';
                  ]]]
                variables:
                  hc_color: "${colors.mauve}"
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/bedroom

              - type: custom:button-card
                template: hc_navigation_card
                name: Bathroom
                icon: mdi:shower
                entity: group.bathroom_lights
                label: |
                  [[[
                    var temp = states['sensor.bathroom_sensor_temperature']?.state || '--';
                    var hum = states['sensor.bathroom_sensor_humidity']?.state || '--';
                    return temp + '°C • ' + Math.round(hum) + '%';
                  ]]]
                variables:
                  hc_color: "${colors.blue}"
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/bathroom

              - type: custom:button-card
                template: hc_navigation_card
                name: Kitchen
                icon: mdi:silverware-fork-knife
                entity: group.kitchen_lights
                label: |
                  [[[
                    var entities = states['group.kitchen_lights']?.attributes?.entity_id || [];
                    var count = entities.filter(e => states[e]?.state === 'on').length;
                    return count + ' lights on';
                  ]]]
                variables:
                  hc_color: "${colors.yellow}"
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/kitchen

              - type: custom:button-card
                template: hc_navigation_card
                name: Hallway
                icon: mdi:door
                entity: group.hallway_lights
                label: |
                  [[[
                    var entities = states['group.hallway_lights']?.attributes?.entity_id || [];
                    var count = entities.filter(e => states[e]?.state === 'on').length;
                    return count + ' lights on';
                  ]]]
                variables:
                  hc_color: "${colors.green}"
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/hallway

              - type: custom:button-card
                template: hc_navigation_card
                name: Robynne's Room
                icon: mdi:teddy-bear
                entity: group.robynne_lights
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
                variables:
                  hc_color: "${colors.red}"
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/robynne

          # Quick Actions / Scenes
          - type: custom:button-card
            template: hc_title_card
            name: Scenes

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: hc_scene_card
                name: All Off
                icon: mdi:power
                variables:
                  hc_color: "${colors.red}"
                tap_action:
                  action: call-service
                  service: light.turn_off
                  service_data:
                    entity_id: all

              - type: custom:button-card
                template: hc_scene_card
                entity: input_boolean.party_mode
                name: Party
                icon: mdi:party-popper
                variables:
                  hc_color: "${colors.mauve}"

              - type: custom:button-card
                template: hc_scene_card
                name: Movie
                icon: mdi:movie
                variables:
                  hc_color: "${colors.blue}"
                tap_action:
                  action: call-service
                  service: light.turn_off
                  service_data:
                    entity_id: all
                  confirmation:
                    text: "Start Movie Mode?"

              - type: custom:button-card
                template: hc_scene_card
                name: Leave
                icon: mdi:home-export-outline
                variables:
                  hc_color: "${colors.peach}"
                tap_action:
                  action: call-service
                  service: automation.trigger
                  service_data:
                    entity_id: automation.leave_home

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: hc_scene_card
                name: Bedtime
                icon: mdi:bed
                variables:
                  hc_color: "${colors.mauve}"
                tap_action:
                  action: call-service
                  service: light.turn_off
                  service_data:
                    entity_id: group.living_room_lights

              - type: custom:button-card
                template: hc_scene_card
                name: Bright
                icon: mdi:brightness-7
                variables:
                  hc_color: "${colors.yellow}"
                tap_action:
                  action: call-service
                  service: light.turn_on
                  service_data:
                    entity_id: group.living_room_lights
                    brightness: 255

              - type: custom:button-card
                template: hc_scene_card
                name: Dim
                icon: mdi:brightness-4
                variables:
                  hc_color: "${colors.peach}"
                tap_action:
                  action: call-service
                  service: light.turn_on
                  service_data:
                    entity_id: group.living_room_lights
                    brightness: 77

              - type: custom:button-card
                template: hc_scene_card
                name: Robynne
                icon: mdi:music
                variables:
                  hc_color: "${colors.green}"
                tap_action:
                  action: call-service
                  service: script.turn_on
                  service_data:
                    entity_id: script.robynnes_playlist

          # RoboVac
          - type: custom:button-card
            template: hc_title_card
            name: RoboVac

          - type: custom:button-card
            template: hc_vacuum_card
            entity: vacuum.robovac

          # Appliances (Conditional)
          - type: conditional
            conditions:
              - condition: numeric_state
                entity: sensor.sonoff_10022b2169_power
                above: 5
            card:
              type: custom:button-card
              show_name: false
              show_icon: false
              styles:
                card:
                  - padding: 16px
                  - background: linear-gradient(135deg, ${colors.blue}22, ${colors.surface0})
                  - border-radius: 20px
                  - border-left: 4px solid ${colors.blue}
              custom_fields:
                appliance: |
                  [[[
                    const power = states['sensor.sonoff_10022b2169_power'].state;
                    return `<div style="display:flex;align-items:center;gap:12px;">
                      <ha-icon icon="mdi:washing-machine" style="--mdc-icon-size:32px;color:${colors.blue};animation:pulse 2s infinite;"></ha-icon>
                      <div style="display:flex;flex-direction:column;">
                        <span style="font-size:14px;font-weight:600;color:${colors.text};">Washing Machine Running</span>
                        <span style="font-size:12px;color:${colors.subtext};">''${power}W</span>
                      </div>
                    </div>`;
                  ]]]
              extra_styles: |
                @keyframes pulse {
                  0%, 100% { opacity: 1; }
                  50% { opacity: 0.6; }
                }

          # Media
          - type: custom:button-card
            template: hc_title_card
            name: Media

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: hc_media_card
                entity: media_player.living_room_tv
                name: Living Room

              - type: custom:button-card
                template: hc_media_card
                entity: media_player.apple_tv
                name: Bedroom

          # System
          - type: custom:button-card
            template: hc_title_card
            name: System

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: hc_server_stats_card

              - type: custom:button-card
                template: hc_battery_alerts_card

      # ==================== LIVING ROOM VIEW ====================
      - title: Living Room
        path: living-room
        icon: mdi:sofa
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: hc_header_card
            name: Living Room
            label: Lights & Media

          - type: custom:button-card
            template: hc_title_card
            name: Lights

          - type: grid
            columns: 2
            square: false
            cards:
              - type: custom:button-card
                template: hc_light_card
                entity: light.living_room_light
                name: Main Light
                variables:
                  card_color: "${colors.yellow}"

              - type: custom:button-card
                template: hc_light_card
                entity: light.dining_room_light_3
                name: Dining Light
                variables:
                  card_color: "${colors.yellow}"

              - type: custom:button-card
                template: hc_light_card
                entity: light.sofa_light_switch
                name: Sofa Light
                variables:
                  card_color: "${colors.peach}"

              - type: custom:button-card
                template: hc_light_card
                entity: light.tv_light
                name: TV Light
                variables:
                  card_color: "${colors.blue}"

          - type: custom:button-card
            template: hc_title_card
            name: Climate

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: hc_fan_card
                entity: fan.dyson
                name: Dyson

              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.dyson_temperature
                name: Temperature
                icon: mdi:thermometer

              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.dyson_humidity
                name: Humidity
                icon: mdi:water-percent

          - type: custom:button-card
            template: hc_title_card
            name: Air Quality

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.dyson_pm_2_5
                name: PM 2.5
                icon: mdi:blur
                styles:
                  icon:
                    - color: ${colors.green}

              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.dyson_pm_10
                name: PM 10
                icon: mdi:blur-linear
                styles:
                  icon:
                    - color: ${colors.blue}

              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.dyson_volatile_organic_compounds_index
                name: VOC
                icon: mdi:molecule
                styles:
                  icon:
                    - color: ${colors.peach}

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                show_name: true
                show_icon: true
                show_label: true
                name: HEPA Filter
                icon: mdi:air-filter
                label: |
                  [[[
                    return states['sensor.dyson_hepa_filter_life'].state + '%';
                  ]]]
                styles:
                  card:
                    - padding: 12px
                    - height: 70px
                    - background: ${colors.surface0}
                    - border-radius: 20px
                  grid:
                    - grid-template-areas: '"i n" "i l"'
                    - grid-template-columns: 40px 1fr
                  name:
                    - font-size: 11px
                    - color: ${colors.subtext}
                    - justify-self: start
                  label:
                    - font-size: 16px
                    - font-weight: 600
                    - color: |
                        [[[
                          const val = parseInt(states['sensor.dyson_hepa_filter_life'].state);
                          return val > 20 ? '${colors.text}' : '${colors.red}';
                        ]]]
                    - justify-self: start
                  icon:
                    - color: ${colors.blue}
                    - width: 22px

              - type: custom:button-card
                show_name: true
                show_icon: true
                show_label: true
                name: Carbon Filter
                icon: mdi:air-filter
                label: |
                  [[[
                    return states['sensor.dyson_carbon_filter_life'].state + '%';
                  ]]]
                styles:
                  card:
                    - padding: 12px
                    - height: 70px
                    - background: ${colors.surface0}
                    - border-radius: 20px
                  grid:
                    - grid-template-areas: '"i n" "i l"'
                    - grid-template-columns: 40px 1fr
                  name:
                    - font-size: 11px
                    - color: ${colors.subtext}
                    - justify-self: start
                  label:
                    - font-size: 16px
                    - font-weight: 600
                    - color: |
                        [[[
                          const val = parseInt(states['sensor.dyson_carbon_filter_life'].state);
                          return val > 20 ? '${colors.text}' : '${colors.red}';
                        ]]]
                    - justify-self: start
                  icon:
                    - color: ${colors.peach}
                    - width: 22px

          - type: custom:button-card
            template: hc_title_card
            name: Media

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: hc_media_card
                entity: media_player.lg_webos_smart_tv
                name: LG TV

              - type: custom:button-card
                template: hc_media_card
                entity: media_player.living_room_tv
                name: Apple TV

      # ==================== BEDROOM VIEW ====================
      - title: Bedroom
        path: bedroom
        icon: mdi:bed
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: hc_header_card
            name: Bedroom
            label: Lights

          - type: grid
            columns: 2
            square: false
            cards:
              - type: custom:button-card
                template: hc_light_card
                entity: light.above_bed_light
                name: Above Bed
                variables:
                  card_color: "${colors.mauve}"

              - type: custom:button-card
                template: hc_light_card
                entity: light.bedroom_light_2
                name: Bedroom Light
                variables:
                  card_color: "${colors.mauve}"

              - type: custom:button-card
                template: hc_light_card
                entity: light.darren_switch
                name: Darren's Light
                variables:
                  card_color: "${colors.blue}"

              - type: custom:button-card
                template: hc_light_card
                entity: light.lorraine_switch
                name: Lorraine's Light
                variables:
                  card_color: "${colors.peach}"

          - type: custom:button-card
            template: hc_title_card
            name: Media

          - type: custom:button-card
            template: hc_media_card
            entity: media_player.apple_tv
            name: Apple TV

      # ==================== BATHROOM VIEW ====================
      - title: Bathroom
        path: bathroom
        icon: mdi:shower
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: hc_header_card
            name: Bathroom
            label: Lights & Climate

          - type: custom:button-card
            template: hc_title_card
            name: Lights

          - type: grid
            columns: 3
            square: false
            cards:
              - type: custom:button-card
                template: hc_light_card
                entity: light.bath_light
                name: Bath
                variables:
                  card_color: "${colors.blue}"

              - type: custom:button-card
                template: hc_light_card
                entity: light.sink_light
                name: Sink
                variables:
                  card_color: "${colors.blue}"

              - type: custom:button-card
                template: hc_light_card
                entity: light.toilet_light
                name: Toilet
                variables:
                  card_color: "${colors.blue}"

          - type: custom:button-card
            template: hc_title_card
            name: Climate

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.bathroom_sensor_temperature
                name: Temperature
                icon: mdi:thermometer

              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.bathroom_sensor_humidity
                name: Humidity
                icon: mdi:water-percent

              - type: custom:button-card
                template: hc_switch_card
                entity: switch.fingerbot_extractor_switch
                name: Extractor
                icon: mdi:fan
                variables:
                  card_color: "${colors.green}"

      # ==================== KITCHEN VIEW ====================
      - title: Kitchen
        path: kitchen
        icon: mdi:silverware-fork-knife
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: hc_header_card
            name: Kitchen
            label: Lights

          - type: grid
            columns: 3
            square: false
            cards:
              - type: custom:button-card
                template: hc_light_card
                entity: light.kitchen_microwave
                name: Kitchen
                variables:
                  card_color: "${colors.yellow}"

              - type: custom:button-card
                template: hc_light_card
                entity: light.kitchen_sink
                name: Sink
                variables:
                  card_color: "${colors.yellow}"

              - type: custom:button-card
                template: hc_light_card
                entity: light.kitchen_random
                name: Other
                variables:
                  card_color: "${colors.yellow}"

      # ==================== HALLWAY VIEW ====================
      - title: Hallway
        path: hallway
        icon: mdi:door
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: hc_header_card
            name: Hallway
            label: Lights & Sensors

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: hc_light_card
                entity: light.hallway
                name: Hallway
                variables:
                  card_color: "${colors.green}"

              - type: custom:button-card
                template: hc_light_card
                entity: light.doorway
                name: Doorway
                variables:
                  card_color: "${colors.green}"

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.hallway_sensor_temperature
                name: Temperature
                icon: mdi:thermometer

              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.hallway_sensor_humidity
                name: Humidity
                icon: mdi:water-percent

      # ==================== ROBYNNE'S ROOM VIEW ====================
      - title: Robynne's Room
        path: robynne
        icon: mdi:teddy-bear
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: hc_header_card
            name: Robynne's Room
            label: Lights & Media

          - type: custom:button-card
            template: hc_title_card
            name: Lights

          - type: grid
            columns: 3
            square: false
            cards:
              - type: custom:button-card
                template: hc_light_card
                entity: light.robynne_light
                name: Main Light
                variables:
                  card_color: "${colors.red}"

              - type: custom:button-card
                template: hc_light_card
                entity: light.fairy_lights_switch
                name: Fairy Lights
                variables:
                  card_color: "${colors.mauve}"

              - type: custom:button-card
                template: hc_light_card
                entity: light.aarlo_nursery
                name: Night Light
                variables:
                  card_color: "${colors.peach}"

          - type: custom:button-card
            template: hc_title_card
            name: Yoto Player

          - type: custom:button-card
            template: hc_media_card
            entity: media_player.yoto_player
            name: Yoto Player
            icon: mdi:speaker
            variables:
              card_color: "${colors.green}"

      # ==================== CAR VIEW ====================
      - title: Car
        path: car
        icon: mdi:car
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: hc_header_card
            name: Ford
            label: Vehicle Status

          # Status Overview Card
          - type: custom:button-card
            show_name: false
            show_icon: false
            show_label: false
            styles:
              card:
                - padding: 20px
                - background: ${colors.surface0}
                - border-radius: 20px
            custom_fields:
              status: |
                [[[
                  const door = states['sensor.fordpass_wf02xxerk2la80437_doorstatus'].state;
                  const window = states['sensor.fordpass_wf02xxerk2la80437_windowposition'].state;
                  const lastRefresh = states['sensor.fordpass_wf02xxerk2la80437_lastrefresh'].state;
                  const messages = states['sensor.fordpass_wf02xxerk2la80437_messages'].state;

                  const refreshDate = new Date(lastRefresh);
                  const isStale = refreshDate.getFullYear() < 2020;
                  const refreshStr = isStale ? 'Not synced' : refreshDate.toLocaleString('en-GB');

                  const doorColor = door === 'Closed' ? '${colors.green}' : '${colors.red}';
                  const doorIcon = door === 'Closed' ? 'mdi:car-door-lock' : 'mdi:car-door';
                  const windowColor = window === 'Closed' ? '${colors.green}' : '${colors.yellow}';

                  return `<div style="display:flex;flex-direction:column;gap:16px;">
                    <div style="display:flex;align-items:center;justify-content:center;gap:12px;">
                      <ha-icon icon="mdi:car" style="--mdc-icon-size:48px;color:${colors.blue};"></ha-icon>
                    </div>

                    <div style="display:flex;justify-content:space-around;text-align:center;">
                      <div style="display:flex;flex-direction:column;align-items:center;gap:4px;">
                        <ha-icon icon="''${doorIcon}" style="--mdc-icon-size:24px;color:''${doorColor};"></ha-icon>
                        <span style="font-size:12px;color:${colors.subtext};">Doors</span>
                        <span style="font-size:14px;font-weight:600;color:${colors.text};">''${door}</span>
                      </div>
                      <div style="display:flex;flex-direction:column;align-items:center;gap:4px;">
                        <ha-icon icon="mdi:car-door" style="--mdc-icon-size:24px;color:''${windowColor};"></ha-icon>
                        <span style="font-size:12px;color:${colors.subtext};">Windows</span>
                        <span style="font-size:14px;font-weight:600;color:${colors.text};">''${window}</span>
                      </div>
                      <div style="display:flex;flex-direction:column;align-items:center;gap:4px;">
                        <ha-icon icon="mdi:message-badge" style="--mdc-icon-size:24px;color:''${messages > 0 ? '${colors.peach}' : '${colors.subtext}'};"></ha-icon>
                        <span style="font-size:12px;color:${colors.subtext};">Messages</span>
                        <span style="font-size:14px;font-weight:600;color:${colors.text};">''${messages}</span>
                      </div>
                    </div>

                    <div style="display:flex;justify-content:center;padding-top:12px;border-top:1px solid ${colors.base};">
                      <span style="font-size:11px;color:''${isStale ? '${colors.red}' : '${colors.subtext}'};">
                        <ha-icon icon="mdi:sync" style="--mdc-icon-size:14px;margin-right:4px;"></ha-icon>
                        ''${refreshStr}
                      </span>
                    </div>
                  </div>`;
                ]]]

          - type: custom:button-card
            template: hc_title_card
            name: Controls

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: hc_scene_card
                name: Lock
                icon: mdi:car-door-lock
                variables:
                  hc_color: "${colors.green}"
                tap_action:
                  action: call-service
                  service: button.press
                  service_data:
                    entity_id: button.fordpass_wf02xxerk2la80437_doorlock

              - type: custom:button-card
                template: hc_scene_card
                name: Unlock
                icon: mdi:lock-open-variant
                variables:
                  hc_color: "${colors.peach}"
                tap_action:
                  action: call-service
                  service: button.press
                  service_data:
                    entity_id: button.fordpass_wf02xxerk2la80437_doorunlock

              - type: custom:button-card
                template: hc_scene_card
                name: Sync
                icon: mdi:sync
                variables:
                  hc_color: "${colors.blue}"
                tap_action:
                  action: call-service
                  service: button.press
                  service_data:
                    entity_id: button.fordpass_wf02xxerk2la80437_request_refresh

          - type: custom:button-card
            template: hc_title_card
            name: Vehicle Stats

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                show_name: true
                show_icon: true
                show_label: true
                name: Fuel
                icon: mdi:gas-station
                entity: sensor.fordpass_wf02xxerk2la80437_fuel
                label: |
                  [[[
                    const val = states['sensor.fordpass_wf02xxerk2la80437_fuel'].state;
                    return val === 'unknown' ? '--' : val + '%';
                  ]]]
                styles:
                  card:
                    - padding: 12px
                    - height: 80px
                    - background: ${colors.surface0}
                    - border-radius: 20px
                  grid:
                    - grid-template-areas: '"i n" "i l"'
                    - grid-template-columns: 40px 1fr
                  name:
                    - font-size: 12px
                    - color: ${colors.subtext}
                    - justify-self: start
                    - align-self: end
                  label:
                    - font-size: 18px
                    - font-weight: 700
                    - color: ${colors.text}
                    - justify-self: start
                    - align-self: start
                  icon:
                    - color: ${colors.green}
                    - width: 24px

              - type: custom:button-card
                show_name: true
                show_icon: true
                show_label: true
                name: Oil Life
                icon: mdi:oil
                entity: sensor.fordpass_wf02xxerk2la80437_oil
                label: |
                  [[[
                    const val = states['sensor.fordpass_wf02xxerk2la80437_oil'].state;
                    return val === 'unknown' ? '--' : val + '%';
                  ]]]
                styles:
                  card:
                    - padding: 12px
                    - height: 80px
                    - background: ${colors.surface0}
                    - border-radius: 20px
                  grid:
                    - grid-template-areas: '"i n" "i l"'
                    - grid-template-columns: 40px 1fr
                  name:
                    - font-size: 12px
                    - color: ${colors.subtext}
                    - justify-self: start
                    - align-self: end
                  label:
                    - font-size: 18px
                    - font-weight: 700
                    - color: ${colors.text}
                    - justify-self: start
                    - align-self: start
                  icon:
                    - color: ${colors.yellow}
                    - width: 24px

              - type: custom:button-card
                show_name: true
                show_icon: true
                show_label: true
                name: Battery
                icon: mdi:car-battery
                entity: sensor.fordpass_wf02xxerk2la80437_battery
                label: |
                  [[[
                    const val = states['sensor.fordpass_wf02xxerk2la80437_battery'].state;
                    return val === 'unknown' ? '--' : val + '%';
                  ]]]
                styles:
                  card:
                    - padding: 12px
                    - height: 80px
                    - background: ${colors.surface0}
                    - border-radius: 20px
                  grid:
                    - grid-template-areas: '"i n" "i l"'
                    - grid-template-columns: 40px 1fr
                  name:
                    - font-size: 12px
                    - color: ${colors.subtext}
                    - justify-self: start
                    - align-self: end
                  label:
                    - font-size: 18px
                    - font-weight: 700
                    - color: ${colors.text}
                    - justify-self: start
                    - align-self: start
                  icon:
                    - color: ${colors.blue}
                    - width: 24px

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                show_name: true
                show_icon: true
                show_label: true
                name: Outside Temp
                icon: mdi:thermometer
                entity: sensor.fordpass_wf02xxerk2la80437_outsidetemp
                label: |
                  [[[
                    const val = states['sensor.fordpass_wf02xxerk2la80437_outsidetemp'].state;
                    return val === 'unknown' ? '--' : val + '°C';
                  ]]]
                styles:
                  card:
                    - padding: 12px
                    - height: 80px
                    - background: ${colors.surface0}
                    - border-radius: 20px
                  grid:
                    - grid-template-areas: '"i n" "i l"'
                    - grid-template-columns: 40px 1fr
                  name:
                    - font-size: 12px
                    - color: ${colors.subtext}
                    - justify-self: start
                    - align-self: end
                  label:
                    - font-size: 18px
                    - font-weight: 700
                    - color: ${colors.text}
                    - justify-self: start
                    - align-self: start
                  icon:
                    - color: ${colors.peach}
                    - width: 24px

              - type: custom:button-card
                show_name: true
                show_icon: true
                show_label: true
                name: Cabin Temp
                icon: mdi:car-seat-heater
                entity: sensor.fordpass_wf02xxerk2la80437_cabintemperature
                label: |
                  [[[
                    const val = states['sensor.fordpass_wf02xxerk2la80437_cabintemperature'].state;
                    return val === 'unknown' ? '--' : val + '°C';
                  ]]]
                styles:
                  card:
                    - padding: 12px
                    - height: 80px
                    - background: ${colors.surface0}
                    - border-radius: 20px
                  grid:
                    - grid-template-areas: '"i n" "i l"'
                    - grid-template-columns: 40px 1fr
                  name:
                    - font-size: 12px
                    - color: ${colors.subtext}
                    - justify-self: start
                    - align-self: end
                  label:
                    - font-size: 18px
                    - font-weight: 700
                    - color: ${colors.text}
                    - justify-self: start
                    - align-self: start
                  icon:
                    - color: ${colors.red}
                    - width: 24px

              - type: custom:button-card
                show_name: true
                show_icon: true
                show_label: true
                name: AdBlue
                icon: mdi:water
                entity: sensor.fordpass_wf02xxerk2la80437_exhaustfluidlevel
                label: |
                  [[[
                    const val = states['sensor.fordpass_wf02xxerk2la80437_exhaustfluidlevel'].state;
                    return val === 'unknown' ? '--' : val + '%';
                  ]]]
                styles:
                  card:
                    - padding: 12px
                    - height: 80px
                    - background: ${colors.surface0}
                    - border-radius: 20px
                  grid:
                    - grid-template-areas: '"i n" "i l"'
                    - grid-template-columns: 40px 1fr
                  name:
                    - font-size: 12px
                    - color: ${colors.subtext}
                    - justify-self: start
                    - align-self: end
                  label:
                    - font-size: 18px
                    - font-weight: 700
                    - color: ${colors.text}
                    - justify-self: start
                    - align-self: start
                  icon:
                    - color: ${colors.blue}
                    - width: 24px

      # ==================== FISH TANK VIEW ====================
      - title: Fish Tank
        path: fish-tank
        icon: mdi:fish
        type: custom:vertical-layout
        cards:
          - type: custom:button-card
            template: hc_header_card
            name: Fish Tank
            label: Water Parameters

          # Main Stats Row
          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.current_temperature
                name: Temperature
                icon: mdi:thermometer
                styles:
                  icon:
                    - color: ${colors.blue}

              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.ph_value
                name: pH Level
                icon: mdi:ph
                styles:
                  icon:
                    - color: ${colors.green}

              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.salinity_value
                name: Salinity
                icon: mdi:shaker-outline
                styles:
                  icon:
                    - color: ${colors.peach}

          - type: custom:button-card
            template: hc_title_card
            name: Water Quality

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.tds_value
                name: TDS
                icon: mdi:water-opacity
                styles:
                  icon:
                    - color: ${colors.mauve}

              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.ec_value
                name: EC
                icon: mdi:flash
                styles:
                  icon:
                    - color: ${colors.yellow}

              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.orp_value
                name: ORP
                icon: mdi:molecule
                styles:
                  icon:
                    - color: ${colors.green}

          - type: custom:button-card
            template: hc_title_card
            name: Additional

          - type: horizontal-stack
            cards:
              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.proportion_value
                name: Specific Gravity
                icon: mdi:scale-balance
                styles:
                  icon:
                    - color: ${colors.blue}

              - type: custom:button-card
                template: hc_sensor_card
                entity: sensor.cf
                name: CF
                icon: mdi:water-check
                styles:
                  icon:
                    - color: ${colors.peach}

          # Water Parameters Overview Card
          - type: custom:button-card
            show_name: false
            show_icon: false
            show_label: false
            styles:
              card:
                - padding: 20px
                - background: ${colors.surface0}
                - border-radius: 20px
                - margin-top: 16px
            custom_fields:
              overview: |
                [[[
                  const temp = states['sensor.current_temperature'].state;
                  const ph = states['sensor.ph_value'].state;
                  const salinity = states['sensor.salinity_value'].state;
                  const tds = states['sensor.tds_value'].state;
                  const ec = states['sensor.ec_value'].state;
                  const orp = states['sensor.orp_value'].state;
                  const sg = states['sensor.proportion_value'].state;

                  // pH status (ideal range 7.8-8.4 for saltwater)
                  const phVal = parseFloat(ph);
                  const phStatus = phVal >= 7.8 && phVal <= 8.5 ? '${colors.green}' : (phVal >= 7.5 && phVal <= 8.8 ? '${colors.yellow}' : '${colors.red}');
                  const phIcon = phVal >= 7.8 && phVal <= 8.5 ? 'mdi:check-circle' : 'mdi:alert-circle';

                  // Temperature status (ideal 23-26°C for tropical)
                  const tempVal = parseFloat(temp);
                  const tempStatus = tempVal >= 23 && tempVal <= 26 ? '${colors.green}' : (tempVal >= 21 && tempVal <= 28 ? '${colors.yellow}' : '${colors.red}');
                  const tempIcon = tempVal >= 23 && tempVal <= 26 ? 'mdi:check-circle' : 'mdi:alert-circle';

                  return `<div style="display:flex;flex-direction:column;gap:12px;">
                    <div style="font-size:14px;font-weight:600;color:${colors.text};margin-bottom:8px;">
                      <ha-icon icon="mdi:clipboard-check-outline" style="--mdc-icon-size:18px;color:${colors.mauve};margin-right:8px;"></ha-icon>
                      Status Overview
                    </div>
                    <div style="display:flex;justify-content:space-between;align-items:center;">
                      <span style="color:${colors.subtext};">Temperature</span>
                      <span style="display:flex;align-items:center;gap:6px;">
                        <span style="color:${colors.text};">''${temp}°C</span>
                        <ha-icon icon="''${tempIcon}" style="--mdc-icon-size:16px;color:''${tempStatus};"></ha-icon>
                      </span>
                    </div>
                    <div style="display:flex;justify-content:space-between;align-items:center;">
                      <span style="color:${colors.subtext};">pH Level</span>
                      <span style="display:flex;align-items:center;gap:6px;">
                        <span style="color:${colors.text};">''${ph}</span>
                        <ha-icon icon="''${phIcon}" style="--mdc-icon-size:16px;color:''${phStatus};"></ha-icon>
                      </span>
                    </div>
                    <div style="display:flex;justify-content:space-between;align-items:center;">
                      <span style="color:${colors.subtext};">Salinity</span>
                      <span style="color:${colors.text};">''${salinity} PPM</span>
                    </div>
                    <div style="display:flex;justify-content:space-between;align-items:center;">
                      <span style="color:${colors.subtext};">Specific Gravity</span>
                      <span style="color:${colors.text};">''${sg} S.G</span>
                    </div>
                  </div>`;
                ]]]

          # History Graphs
          - type: custom:button-card
            template: hc_title_card
            name: History (24h)

          - type: history-graph
            entities:
              - entity: sensor.current_temperature
                name: Temperature
              - entity: sensor.ph_value
                name: pH
            hours_to_show: 24
            refresh_interval: 300
            card_mod:
              style: |
                ha-card {
                  background: ${colors.surface0};
                  border-radius: 20px;
                  padding: 12px;
                }

          - type: history-graph
            entities:
              - entity: sensor.salinity_value
                name: Salinity
              - entity: sensor.tds_value
                name: TDS
            hours_to_show: 24
            refresh_interval: 300
            card_mod:
              style: |
                ha-card {
                  background: ${colors.surface0};
                  border-radius: 20px;
                  padding: 12px;
                }
  '';
in {
  # Copy dashboard file to HA config (templates are inlined)
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
