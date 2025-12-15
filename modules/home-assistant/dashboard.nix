{pkgs, ...}: let
  floorplanSvg = ./floorplan.svg;

  # Unsplash placeholder images
  images = {
    building = "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=780&h=360&fit=crop";
    livingRoom = "https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?w=780&h=240&fit=crop";
    bedroom = "https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=780&h=240&fit=crop";
    bathroom = "https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=780&h=240&fit=crop";
    kitchen = "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=780&h=240&fit=crop";
    hallway = "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=780&h=240&fit=crop";
    childRoom = "https://images.unsplash.com/photo-1617104678098-de229db51175?w=780&h=240&fit=crop";
    # Thumbnails
    livingRoomThumb = "https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?w=96&h=96&fit=crop";
    bedroomThumb = "https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=96&h=96&fit=crop";
    bathroomThumb = "https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=96&h=96&fit=crop";
    kitchenThumb = "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=96&h=96&fit=crop";
    hallwayThumb = "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=96&h=96&fit=crop";
    childRoomThumb = "https://images.unsplash.com/photo-1617104678098-de229db51175?w=96&h=96&fit=crop";
  };

  dashboardYaml = pkgs.writeText "hacasa.yaml" ''
    title: Fleming Place
    views:
      # ==================== HOME ====================
      - title: Home
        path: home
        icon: mdi:home
        type: custom:vertical-layout
        layout:
          max_width: 500
        cards:
          # Header - Title
          - type: custom:button-card
            name: Fleming Place
            styles:
              card:
                - background: none
                - border: none
                - box-shadow: none
                - padding: 16px 16px 8px 16px
              name:
                - font-size: 28px
                - font-weight: 400
                - color: "#FC691C"
                - justify-self: start

          # Hero Image with floating chips
          - type: picture-elements
            image: ${images.building}
            card_mod:
              style: |
                ha-card {
                  border-radius: 16px;
                  margin: 0 16px;
                  overflow: hidden;
                }
            elements:
              # Floating chips container
              - type: custom:button-card
                styles:
                  card:
                    - background: none
                    - border: none
                    - box-shadow: none
                    - position: absolute
                    - bottom: 12px
                    - left: 50%
                    - transform: translateX(-50%)
                    - display: flex
                    - gap: 8px
                custom_fields:
                  lights:
                    card:
                      type: custom:button-card
                      entity: sensor.total_turned_on_lights_count_template
                      icon: mdi:lightbulb
                      show_state: true
                      show_name: false
                      styles:
                        card:
                          - background: rgba(255,255,255,0.95)
                          - border-radius: 50px
                          - padding: 6px 12px
                          - box-shadow: 0 2px 8px rgba(0,0,0,0.15)
                          - height: 32px
                        icon:
                          - width: 16px
                          - color: "#FC691C"
                        state:
                          - font-size: 12px
                          - font-weight: 500
                  media:
                    card:
                      type: custom:button-card
                      icon: mdi:television
                      show_name: false
                      show_state: false
                      state:
                        - value: "off"
                          styles:
                            icon:
                              - color: gray
                        - operator: default
                          styles:
                            icon:
                              - color: "#22C55E"
                      styles:
                        card:
                          - background: rgba(255,255,255,0.95)
                          - border-radius: 50px
                          - padding: 6px 12px
                          - box-shadow: 0 2px 8px rgba(0,0,0,0.15)
                          - height: 32px
                        icon:
                          - width: 16px
                  motion:
                    card:
                      type: custom:button-card
                      icon: mdi:motion-sensor
                      show_name: false
                      show_state: false
                      styles:
                        card:
                          - background: rgba(255,255,255,0.95)
                          - border-radius: 50px
                          - padding: 6px 12px
                          - box-shadow: 0 2px 8px rgba(0,0,0,0.15)
                          - height: 32px
                        icon:
                          - width: 16px
                          - color: |
                              [[[
                                const sensors = [
                                  'binary_sensor.living_room_motion_sensor_occupancy',
                                  'binary_sensor.bedroom_motion_sensor_occupancy',
                                  'binary_sensor.hallway_motion_sensor_occupancy',
                                  'binary_sensor.motion_sensor_motion'
                                ];
                                const active = sensors.filter(s => hass.states[s]?.state === 'on').length;
                                return active > 0 ? '#3B82F6' : 'gray';
                              ]]]
                template:
                  - chips_row
                style:
                  top: 85%
                  left: 50%

          # Status Info Section
          - type: custom:button-card
            styles:
              card:
                - background: none
                - border: none
                - box-shadow: none
                - padding: 12px 16px
              grid:
                - grid-template-columns: 1fr
                - gap: 8px
            custom_fields:
              weather:
                card:
                  type: custom:button-card
                  entity: weather.forecast_home
                  show_icon: true
                  show_name: false
                  show_state: true
                  icon: mdi:map-marker
                  styles:
                    card:
                      - background: none
                      - border: none
                      - box-shadow: none
                      - padding: 0
                      - justify-content: start
                    grid:
                      - grid-template-areas: '"i s"'
                      - grid-template-columns: auto 1fr
                    icon:
                      - width: 14px
                      - color: "#6B7280"
                    state:
                      - font-size: 13px
                      - color: "#6B7280"
                      - justify-self: start
                  state_display: |
                    [[[
                      const w = entity;
                      const temp = w.attributes.temperature;
                      const condition = w.state.replace(/_/g, ' ');
                      return condition.charAt(0).toUpperCase() + condition.slice(1) + ' (' + temp + '°C)';
                    ]]]
              calendar:
                card:
                  type: custom:button-card
                  entity: calendar.family
                  show_icon: true
                  show_name: false
                  show_state: true
                  icon: mdi:calendar
                  styles:
                    card:
                      - background: none
                      - border: none
                      - box-shadow: none
                      - padding: 0
                      - justify-content: start
                    grid:
                      - grid-template-areas: '"i s"'
                      - grid-template-columns: auto 1fr
                    icon:
                      - width: 14px
                      - color: "#6B7280"
                    state:
                      - font-size: 13px
                      - color: "#6B7280"
                      - justify-self: start
                  state_display: |
                    [[[
                      if (entity.state === 'on' && entity.attributes.message) {
                        return entity.attributes.message;
                      }
                      return 'No upcoming events';
                    ]]]
              football:
                card:
                  type: conditional
                  conditions:
                    - condition: or
                      conditions:
                        - condition: state
                          entity: sensor.liverpool
                          state: IN
                        - condition: state
                          entity: sensor.liverpool
                          state: PRE
                  card:
                    type: custom:button-card
                    entity: sensor.liverpool
                    show_icon: true
                    show_name: false
                    show_state: true
                    icon: mdi:soccer
                    styles:
                      card:
                        - background: none
                        - border: none
                        - box-shadow: none
                        - padding: 0
                        - justify-content: start
                      grid:
                        - grid-template-areas: '"i s"'
                        - grid-template-columns: auto 1fr
                      icon:
                        - width: 14px
                        - color: "#6B7280"
                      state:
                        - font-size: 13px
                        - color: "#6B7280"
                        - justify-self: start
                    state_display: |
                      [[[
                        const a = entity.attributes;
                        const date = new Date(a.date);
                        const day = date.toLocaleDateString('en-GB', { weekday: 'short' });
                        const time = date.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
                        return a.team_abbr + ' v ' + a.opponent_abbr + ': ' + day + ' ' + time;
                      ]]]

          # Tabbed Navigation
          - type: custom:tabbed-card
            styles:
              "--mdc-tab-text-label-color-default": "#9CA3AF"
              "--mdc-theme-primary": "#FC691C"
            tabs:
              # ===== ROOMS TAB =====
              - attributes:
                  label: Rooms
                card:
                  type: custom:vertical-layout
                  cards:
                    # Living Room
                    - type: custom:button-card
                      entity: group.living_room_lights
                      tap_action:
                        action: navigate
                        navigation_path: /lovelace-home/living-room
                      styles:
                        card:
                          - background: none
                          - border: none
                          - box-shadow: none
                          - padding: 12px 16px
                        grid:
                          - grid-template-areas: '"img info badges"'
                          - grid-template-columns: 48px 1fr auto
                          - gap: 12px
                        custom_fields:
                          img:
                            - border-radius: 50%
                            - width: 48px
                            - height: 48px
                            - object-fit: cover
                          info:
                            - display: flex
                            - flex-direction: column
                            - justify-content: center
                            - align-items: start
                          badges:
                            - display: flex
                            - flex-direction: column
                            - align-items: end
                            - justify-content: center
                            - gap: 2px
                      custom_fields:
                        img: '<img src="${images.livingRoomThumb}" style="border-radius:50%;width:48px;height:48px;object-fit:cover;">'
                        info: |
                          [[[
                            const entities = entity.attributes.entity_id || [];
                            const on = entities.filter(e => hass.states[e]?.state === 'on').length;
                            const motion = hass.states['binary_sensor.living_room_motion_sensor_occupancy'];
                            let secondary = 'Clear';
                            if (motion?.state === 'on') {
                              secondary = 'Motion detected';
                            } else if (motion?.last_changed) {
                              const ago = Math.floor((Date.now() - new Date(motion.last_changed)) / 60000);
                              if (ago < 60) secondary = 'Clear - ' + ago + ' min ago';
                            }
                            return '<div style="font-size:16px;font-weight:500;color:#1A1A1A;">Living Room</div>' +
                                   '<div style="font-size:13px;color:#6B7280;">' + secondary + '</div>';
                          ]]]
                        badges: |
                          [[[
                            const entities = entity.attributes.entity_id || [];
                            const on = entities.filter(e => hass.states[e]?.state === "on").length;
                            let html = "";
                            if (on > 0) html += "<div style=\"font-size:11px;color:#6B7280;\">" + on + " Light" + (on > 1 ? "s" : "") + "</div>";
                            const tv = hass.states["media_player.living_room_tv"];
                            if (tv?.state === "playing" || tv?.state === "on") {
                              html += "<div style=\"font-size:11px;color:#6B7280;\">1 Media</div>";
                            }
                            return html || "<div style=\"font-size:11px;color:#6B7280;\">All off</div>";
                          ]]]

                    # Bedroom
                    - type: custom:button-card
                      entity: group.bedroom_lights
                      tap_action:
                        action: navigate
                        navigation_path: /lovelace-home/bedroom
                      styles:
                        card:
                          - background: none
                          - border: none
                          - box-shadow: none
                          - padding: 12px 16px
                        grid:
                          - grid-template-areas: '"img info badges"'
                          - grid-template-columns: 48px 1fr auto
                          - gap: 12px
                        custom_fields:
                          img:
                            - border-radius: 50%
                          info:
                            - display: flex
                            - flex-direction: column
                            - justify-content: center
                            - align-items: start
                          badges:
                            - display: flex
                            - flex-direction: column
                            - align-items: end
                            - justify-content: center
                      custom_fields:
                        img: '<img src="${images.bedroomThumb}" style="border-radius:50%;width:48px;height:48px;object-fit:cover;">'
                        info: |
                          [[[
                            const motion = hass.states['binary_sensor.bedroom_motion_sensor_occupancy'];
                            let secondary = 'Clear';
                            if (motion?.state === 'on') {
                              secondary = 'Motion detected';
                            } else if (motion?.last_changed) {
                              const ago = Math.floor((Date.now() - new Date(motion.last_changed)) / 60000);
                              if (ago < 60) secondary = 'Clear - ' + ago + ' min ago';
                            }
                            return '<div style="font-size:16px;font-weight:500;color:#1A1A1A;">Bedroom</div>' +
                                   '<div style="font-size:13px;color:#6B7280;">' + secondary + '</div>';
                          ]]]
                        badges: |
                          [[[
                            const entities = entity.attributes.entity_id || [];
                            const on = entities.filter(e => hass.states[e]?.state === "on").length;
                            let html = "";
                            if (on > 0) html += "<div style=\"font-size:11px;color:#6B7280;\">" + on + " Light" + (on > 1 ? "s" : "") + "</div>";
                            const tv = hass.states["media_player.apple_tv"];
                            if (tv?.state === "playing") {
                              html += "<div style=\"font-size:11px;color:#6B7280;\">1 Media</div>";
                            }
                            return html || "<div style=\"font-size:11px;color:#6B7280;\">All off</div>";
                          ]]]

                    # Bathroom
                    - type: custom:button-card
                      entity: group.bathroom_lights
                      tap_action:
                        action: navigate
                        navigation_path: /lovelace-home/bathroom
                      styles:
                        card:
                          - background: none
                          - border: none
                          - box-shadow: none
                          - padding: 12px 16px
                        grid:
                          - grid-template-areas: '"img info badges"'
                          - grid-template-columns: 48px 1fr auto
                          - gap: 12px
                        custom_fields:
                          info:
                            - display: flex
                            - flex-direction: column
                            - justify-content: center
                            - align-items: start
                          badges:
                            - display: flex
                            - flex-direction: column
                            - align-items: end
                            - justify-content: center
                      custom_fields:
                        img: '<img src="${images.bathroomThumb}" style="border-radius:50%;width:48px;height:48px;object-fit:cover;">'
                        info: |
                          [[[
                            const temp = hass.states['sensor.bathroom_sensor_temperature']?.state;
                            const humidity = hass.states['sensor.bathroom_sensor_humidity']?.state;
                            let secondary = "";
                            if (temp && temp !== "unavailable") secondary += Math.round(temp) + "°";
                            if (humidity && humidity !== "unavailable") secondary += " · " + Math.round(humidity) + "% humidity";
                            return '<div style="font-size:16px;font-weight:500;color:#1A1A1A;">Bathroom</div>' +
                                   '<div style="font-size:13px;color:#6B7280;">' + (secondary || 'All off') + '</div>';
                          ]]]
                        badges: |
                          [[[
                            const entities = entity.attributes.entity_id || [];
                            const on = entities.filter(e => hass.states[e]?.state === "on").length;
                            if (on > 0) return "<div style=\"font-size:11px;color:#6B7280;\">" + on + " Light" + (on > 1 ? "s" : "") + "</div>";
                            return "";
                          ]]]

                    # Kitchen
                    - type: custom:button-card
                      entity: group.kitchen_lights
                      tap_action:
                        action: navigate
                        navigation_path: /lovelace-home/kitchen
                      styles:
                        card:
                          - background: none
                          - border: none
                          - box-shadow: none
                          - padding: 12px 16px
                        grid:
                          - grid-template-areas: '"img info badges"'
                          - grid-template-columns: 48px 1fr auto
                          - gap: 12px
                        custom_fields:
                          info:
                            - display: flex
                            - flex-direction: column
                            - justify-content: center
                            - align-items: start
                          badges:
                            - display: flex
                            - flex-direction: column
                            - align-items: end
                            - justify-content: center
                      custom_fields:
                        img: '<img src="${images.kitchenThumb}" style="border-radius:50%;width:48px;height:48px;object-fit:cover;">'
                        info: |
                          [[[
                            const entities = entity.attributes.entity_id || [];
                            const on = entities.filter(e => hass.states[e]?.state === 'on').length;
                            return '<div style="font-size:16px;font-weight:500;color:#1A1A1A;">Kitchen</div>' +
                                   '<div style="font-size:13px;color:#6B7280;">' + (on > 0 ? on + ' lights on' : 'All off') + '</div>';
                          ]]]
                        badges: |
                          [[[
                            const entities = entity.attributes.entity_id || [];
                            const on = entities.filter(e => hass.states[e]?.state === "on").length;
                            if (on > 0) return "<div style=\"font-size:11px;color:#6B7280;\">" + on + " Light" + (on > 1 ? "s" : "") + "</div>";
                            return "";
                          ]]]

                    # Hallway
                    - type: custom:button-card
                      entity: group.hallway_lights
                      tap_action:
                        action: navigate
                        navigation_path: /lovelace-home/hallway
                      styles:
                        card:
                          - background: none
                          - border: none
                          - box-shadow: none
                          - padding: 12px 16px
                        grid:
                          - grid-template-areas: '"img info badges"'
                          - grid-template-columns: 48px 1fr auto
                          - gap: 12px
                        custom_fields:
                          info:
                            - display: flex
                            - flex-direction: column
                            - justify-content: center
                            - align-items: start
                          badges:
                            - display: flex
                            - flex-direction: column
                            - align-items: end
                            - justify-content: center
                      custom_fields:
                        img: '<img src="${images.hallwayThumb}" style="border-radius:50%;width:48px;height:48px;object-fit:cover;">'
                        info: |
                          [[[
                            const temp = hass.states['sensor.hallway_sensor_temperature']?.state;
                            const motion = hass.states['binary_sensor.hallway_motion_sensor_occupancy'];
                            let secondary = "";
                            if (temp && temp !== "unavailable") secondary += Math.round(temp) + "°";
                            if (motion?.state === "on") {
                              secondary += " · Motion";
                            }
                            return '<div style="font-size:16px;font-weight:500;color:#1A1A1A;">Hallway</div>' +
                                   '<div style="font-size:13px;color:#6B7280;">' + (secondary || 'All off') + '</div>';
                          ]]]
                        badges: |
                          [[[
                            const entities = entity.attributes.entity_id || [];
                            const on = entities.filter(e => hass.states[e]?.state === "on").length;
                            if (on > 0) return "<div style=\"font-size:11px;color:#6B7280;\">" + on + " Light" + (on > 1 ? "s" : "") + "</div>";
                            return "";
                          ]]]

                    # Robynne's Room
                    - type: custom:button-card
                      entity: group.robynne_lights
                      tap_action:
                        action: navigate
                        navigation_path: /lovelace-home/robynne
                      styles:
                        card:
                          - background: none
                          - border: none
                          - box-shadow: none
                          - padding: 12px 16px
                        grid:
                          - grid-template-areas: '"img info badges"'
                          - grid-template-columns: 48px 1fr auto
                          - gap: 12px
                        custom_fields:
                          info:
                            - display: flex
                            - flex-direction: column
                            - justify-content: center
                            - align-items: start
                          badges:
                            - display: flex
                            - flex-direction: column
                            - align-items: end
                            - justify-content: center
                      custom_fields:
                        img: '<img src="${images.childRoomThumb}" style="border-radius:50%;width:48px;height:48px;object-fit:cover;">'
                        info: |
                          [[[
                            const yoto = hass.states['media_player.yoto_player'];
                            let secondary = 'All off';
                            if (yoto?.state === 'playing') secondary = 'Yoto playing';
                            return "<div style=\"font-size:16px;font-weight:500;color:#1A1A1A;\">Robynne's Room</div>" +
                                   '<div style="font-size:13px;color:#6B7280;">' + secondary + '</div>';
                          ]]]
                        badges: |
                          [[[
                            const entities = entity.attributes.entity_id || [];
                            const on = entities.filter(e => hass.states[e]?.state === "on").length;
                            let html = "";
                            if (on > 0) html += "<div style=\"font-size:11px;color:#6B7280;\">" + on + " Light" + (on > 1 ? "s" : "") + "</div>";
                            const yoto = hass.states["media_player.yoto_player"];
                            if (yoto?.state === "playing") html += "<div style=\"font-size:11px;color:#6B7280;\">1 Media</div>";
                            return html;
                          ]]]

              # ===== PEOPLES TAB =====
              - attributes:
                  label: Peoples
                card:
                  type: grid
                  columns: 2
                  square: false
                  cards:
                    # Darren
                    - type: custom:button-card
                      entity: person.darren_gilbert
                      tap_action:
                        action: more-info
                      styles:
                        card:
                          - background: white
                          - border: 1px solid "#E5E5E5"
                          - border-radius: 16px
                          - padding: 16px
                          - box-shadow: 0 1px 3px rgba(0,0,0,0.06)
                        grid:
                          - grid-template-areas: '"img" "name" "state"'
                          - justify-items: center
                        custom_fields:
                          img:
                            - margin-bottom: 8px
                      custom_fields:
                        img: |
                          [[[
                            const pic = entity.attributes.entity_picture || "";
                            if (pic) {
                              return "<img src=\"" + pic + "\" style=\"border-radius:50%;width:48px;height:48px;object-fit:cover;\">";
                            }
                            return "<ha-icon icon=\"mdi:account\" style=\"width:48px;height:48px;\"></ha-icon>";
                          ]]]
                        name: '<div style="font-size:16px;font-weight:500;color:#1A1A1A;">Darren</div>'
                        state: |
                          [[[
                            const state = entity.state;
                            if (state === 'home') return '<div style="font-size:13px;color:#6B7280;">Home</div>';
                            return '<div style="font-size:13px;color:#6B7280;">' + state + '</div>';
                          ]]]

                    # Lorraine
                    - type: custom:button-card
                      entity: person.lorraine
                      tap_action:
                        action: more-info
                      styles:
                        card:
                          - background: white
                          - border: 1px solid "#E5E5E5"
                          - border-radius: 16px
                          - padding: 16px
                          - box-shadow: 0 1px 3px rgba(0,0,0,0.06)
                        grid:
                          - grid-template-areas: '"img" "name" "state"'
                          - justify-items: center
                        custom_fields:
                          img:
                            - margin-bottom: 8px
                      custom_fields:
                        img: |
                          [[[
                            const pic = entity.attributes.entity_picture || "";
                            if (pic) {
                              return "<img src=\"" + pic + "\" style=\"border-radius:50%;width:48px;height:48px;object-fit:cover;\">";
                            }
                            return "<ha-icon icon=\"mdi:account\" style=\"width:48px;height:48px;\"></ha-icon>";
                          ]]]
                        name: '<div style="font-size:16px;font-weight:500;color:#1A1A1A;">Lorraine</div>'
                        state: |
                          [[[
                            const state = entity.state;
                            if (state === 'home') return '<div style="font-size:13px;color:#6B7280;">Home</div>';
                            return '<div style="font-size:13px;color:#6B7280;">' + state + '</div>';
                          ]]]

              # ===== CALENDAR TAB =====
              - attributes:
                  label: Calendar
                card:
                  type: custom:vertical-layout
                  cards:
                    - type: custom:button-card
                      name: Upcoming Events
                      styles:
                        card:
                          - background: none
                          - border: none
                          - box-shadow: none
                          - padding: 16px
                        name:
                          - font-size: 14px
                          - font-weight: 600
                          - color: "#1A1A1A"
                          - justify-self: start

                    # Calendar entity card
                    - type: custom:button-card
                      entity: calendar.family
                      show_icon: true
                      icon: mdi:calendar
                      styles:
                        card:
                          - background: white
                          - border: 1px solid "#E5E5E5"
                          - border-radius: 16px
                          - padding: 16px
                          - margin: 0 16px
                          - box-shadow: 0 1px 3px rgba(0,0,0,0.06)
                        grid:
                          - grid-template-areas: '"i info"'
                          - grid-template-columns: auto 1fr
                          - gap: 12px
                        icon:
                          - width: 24px
                          - color: "#FC691C"
                        custom_fields:
                          info:
                            - justify-self: start
                      custom_fields:
                        info: |
                          [[[
                            if (entity.state === 'on' && entity.attributes.message) {
                              const start = entity.attributes.start_time;
                              return '<div style="font-size:16px;font-weight:500;color:#1A1A1A;">' + entity.attributes.message + '</div>' +
                                     '<div style="font-size:13px;color:#6B7280;">' + start + '</div>';
                            }
                            return '<div style="font-size:16px;font-weight:500;color:#1A1A1A;">No upcoming events</div>';
                          ]]]

                    # Football match
                    - type: conditional
                      conditions:
                        - condition: or
                          conditions:
                            - condition: state
                              entity: sensor.liverpool
                              state: IN
                            - condition: state
                              entity: sensor.liverpool
                              state: PRE
                      card:
                        type: custom:button-card
                        entity: sensor.liverpool
                        show_icon: true
                        icon: mdi:soccer
                        tap_action:
                          action: more-info
                        styles:
                          card:
                            - background: white
                            - border: 1px solid "#E5E5E5"
                            - border-radius: 16px
                            - padding: 16px
                            - margin: 8px 16px
                            - box-shadow: 0 1px 3px rgba(0,0,0,0.06)
                          grid:
                            - grid-template-areas: '"i info"'
                            - grid-template-columns: auto 1fr
                            - gap: 12px
                          icon:
                            - width: 24px
                            - color: "#FC691C"
                          custom_fields:
                            info:
                              - justify-self: start
                        custom_fields:
                          info: |
                            [[[
                              const a = entity.attributes;
                              const date = new Date(a.date);
                              const formatted = date.toLocaleDateString('en-GB', { weekday: 'long', day: 'numeric', month: 'short' }) +
                                               ' at ' + date.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
                              return '<div style="font-size:16px;font-weight:500;color:#1A1A1A;">' + a.team_name + ' v ' + a.opponent_long_name + '</div>' +
                                     '<div style="font-size:13px;color:#6B7280;">' + formatted + ' · ' + a.league + '</div>';
                            ]]]

              # ===== OTHER TAB =====
              - attributes:
                  label: Other
                card:
                  type: custom:vertical-layout
                  cards:
                    # Quick links
                    - type: grid
                      columns: 2
                      square: false
                      cards:
                        - type: custom:button-card
                          name: Energy
                          icon: mdi:lightning-bolt
                          tap_action:
                            action: navigate
                            navigation_path: /lovelace-home/energy
                          styles:
                            card:
                              - background: white
                              - border: 1px solid "#E5E5E5"
                              - border-radius: 16px
                              - padding: 16px
                            icon:
                              - width: 24px
                              - color: "#FC691C"
                            name:
                              - font-size: 14px
                              - color: "#1A1A1A"

                        - type: custom:button-card
                          name: Car
                          icon: mdi:car
                          tap_action:
                            action: navigate
                            navigation_path: /lovelace-home/car
                          styles:
                            card:
                              - background: white
                              - border: 1px solid "#E5E5E5"
                              - border-radius: 16px
                              - padding: 16px
                            icon:
                              - width: 24px
                              - color: "#FC691C"
                            name:
                              - font-size: 14px
                              - color: "#1A1A1A"

                        - type: custom:button-card
                          name: Fish Tank
                          icon: mdi:fish
                          tap_action:
                            action: navigate
                            navigation_path: /lovelace-home/fish
                          styles:
                            card:
                              - background: white
                              - border: 1px solid "#E5E5E5"
                              - border-radius: 16px
                              - padding: 16px
                            icon:
                              - width: 24px
                              - color: "#FC691C"
                            name:
                              - font-size: 14px
                              - color: "#1A1A1A"

                        - type: custom:button-card
                          name: System
                          icon: mdi:cog
                          tap_action:
                            action: navigate
                            navigation_path: /lovelace-home/system
                          styles:
                            card:
                              - background: white
                              - border: 1px solid "#E5E5E5"
                              - border-radius: 16px
                              - padding: 16px
                            icon:
                              - width: 24px
                              - color: "#FC691C"
                            name:
                              - font-size: 14px
                              - color: "#1A1A1A"

                        - type: custom:button-card
                          name: Floorplan
                          icon: mdi:floor-plan
                          tap_action:
                            action: navigate
                            navigation_path: /lovelace-home/floorplan
                          styles:
                            card:
                              - background: white
                              - border: 1px solid "#E5E5E5"
                              - border-radius: 16px
                              - padding: 16px
                            icon:
                              - width: 24px
                              - color: "#FC691C"
                            name:
                              - font-size: 14px
                              - color: "#1A1A1A"

          # Scenes Button (floating)
          - type: custom:button-card
            name: Scenes
            icon: mdi:palette
            tap_action:
              action: fire-dom-event
              browser_mod:
                service: browser_mod.popup
                data:
                  title: Scenes
                  content:
                    type: custom:vertical-layout
                    cards:
                      - type: custom:mushroom-chips-card
                        chips:
                          - type: template
                            icon: mdi:movie-open
                            icon_color: blue
                            content: Movie
                            tap_action:
                              action: call-service
                              service: scene.turn_on
                              target:
                                entity_id: scene.movie
                          - type: template
                            icon: mdi:brightness-7
                            icon_color: amber
                            content: Bright
                            tap_action:
                              action: call-service
                              service: light.turn_on
                              target:
                                entity_id: all
                              data:
                                brightness: 255
                          - type: template
                            icon: mdi:power
                            icon_color: red
                            content: All Off
                            tap_action:
                              action: call-service
                              service: light.turn_off
                              target:
                                entity_id: all
                        alignment: center
            styles:
              card:
                - position: fixed
                - bottom: 80px
                - right: 16px
                - background: "#FC691C"
                - border-radius: 50px
                - padding: 12px 20px
                - box-shadow: 0 4px 12px rgba(252,105,28,0.4)
                - z-index: 100
              icon:
                - color: white
                - width: 20px
              name:
                - color: white
                - font-size: 14px
                - font-weight: 500

      # ==================== LIVING ROOM ====================
      - title: Living Room
        path: living-room
        icon: mdi:sofa
        type: custom:vertical-layout
        layout:
          max_width: 500
        cards:
          # Header with back button
          - type: custom:button-card
            styles:
              card:
                - background: none
                - border: none
                - box-shadow: none
                - padding: 16px
                - display: flex
                - justify-content: space-between
                - align-items: center
            custom_fields:
              title: '<div style="font-size:28px;font-weight:400;color:#FC691C;">Living Room</div>'
              back:
                card:
                  type: custom:button-card
                  icon: mdi:chevron-left
                  tap_action:
                    action: navigate
                    navigation_path: /lovelace-home/home
                  styles:
                    card:
                      - background: none
                      - border: 1px solid "#E5E5E5"
                      - border-radius: 50%
                      - width: 40px
                      - height: 40px
                    icon:
                      - width: 20px
                      - color: "#6B7280"

          # Hero Image
          - type: picture-elements
            image: ${images.livingRoom}
            card_mod:
              style: |
                ha-card {
                  border-radius: 16px;
                  margin: 0 16px;
                  overflow: hidden;
                }
            elements:
              - type: custom:button-card
                entity: sensor.total_turned_on_lights_count_template
                icon: mdi:lightbulb
                show_state: true
                show_name: false
                styles:
                  card:
                    - background: rgba(255,255,255,0.95)
                    - border-radius: 50px
                    - padding: 6px 12px
                    - box-shadow: 0 2px 8px rgba(0,0,0,0.15)
                    - height: 32px
                  icon:
                    - width: 16px
                    - color: "#FC691C"
                  state:
                    - font-size: 12px
                    - font-weight: 500
                style:
                  top: 85%
                  left: 50%
                  transform: translate(-50%, -50%)

          # Sub-tabs
          - type: custom:tabbed-card
            styles:
              "--mdc-tab-text-label-color-default": "#9CA3AF"
              "--mdc-theme-primary": "#FC691C"
            tabs:
              # Media Tab
              - attributes:
                  label: Media
                card:
                  type: custom:vertical-layout
                  cards:
                    # LG TV
                    - type: custom:button-card
                      entity: media_player.living_room_tv
                      tap_action:
                        action: more-info
                      styles:
                        card:
                          - background: white
                          - border: 1px solid "#E5E5E5"
                          - border-radius: 16px
                          - padding: 16px
                          - margin: 8px 16px
                          - box-shadow: 0 1px 3px rgba(0,0,0,0.06)
                        grid:
                          - grid-template-areas: '"info icon"'
                          - grid-template-columns: 1fr auto
                        custom_fields:
                          icon:
                            - width: 40px
                            - height: 40px
                      custom_fields:
                        info: |
                          [[[
                            const state = entity.state;
                            const source = entity.attributes.source || 'Off';
                            return '<div style="font-size:16px;font-weight:500;color:#1A1A1A;">LG Smart TV</div>' +
                                   '<div style="font-size:13px;color:#6B7280;">' + (state === 'off' ? 'Off' : source) + '</div>';
                          ]]]
                        icon: '<ha-icon icon="mdi:television" style="width:40px;height:40px;color:#6B7280;"></ha-icon>'

                    # Apple TV
                    - type: custom:button-card
                      entity: media_player.apple_tv
                      tap_action:
                        action: more-info
                      styles:
                        card:
                          - background: white
                          - border: 1px solid "#E5E5E5"
                          - border-radius: 16px
                          - padding: 16px
                          - margin: 8px 16px
                          - box-shadow: 0 1px 3px rgba(0,0,0,0.06)
                        grid:
                          - grid-template-areas: '"info icon"'
                          - grid-template-columns: 1fr auto
                        custom_fields:
                          icon:
                            - width: 40px
                            - height: 40px
                      custom_fields:
                        info: |
                          [[[
                            const state = entity.state;
                            const title = entity.attributes.media_title || "";
                            return "<div style=\"font-size:16px;font-weight:500;color:#1A1A1A;\">Apple TV</div>" +
                                   "<div style=\"font-size:13px;color:#6B7280;\">" + (state === "playing" ? "Playing: " + title : state) + "</div>";
                          ]]]
                        icon: '<ha-icon icon="mdi:apple" style="width:40px;height:40px;color:#1A1A1A;"></ha-icon>'

                    # HomePod
                    - type: custom:button-card
                      entity: media_player.homepod
                      tap_action:
                        action: more-info
                      styles:
                        card:
                          - background: white
                          - border: 1px solid "#E5E5E5"
                          - border-radius: 16px
                          - padding: 16px
                          - margin: 8px 16px
                          - box-shadow: 0 1px 3px rgba(0,0,0,0.06)
                        grid:
                          - grid-template-areas: '"info icon"'
                          - grid-template-columns: 1fr auto
                        custom_fields:
                          icon:
                            - width: 40px
                            - height: 40px
                      custom_fields:
                        info: |
                          [[[
                            const state = entity?.state || "unavailable";
                            const title = entity?.attributes?.media_title || "";
                            return "<div style=\"font-size:16px;font-weight:500;color:#1A1A1A;\">HomePod</div>" +
                                   "<div style=\"font-size:13px;color:#6B7280;\">" + (state === "playing" ? "Playing: " + title : state) + "</div>";
                          ]]]
                        icon: '<div style="width:40px;height:40px;background:#FC691C;border-radius:50%;"></div>'

              # Lights Tab
              - attributes:
                  label: Lights
                card:
                  type: custom:vertical-layout
                  cards:
                    - type: custom:mushroom-light-card
                      entity: light.living_room_light
                      name: Main Light
                      use_light_color: true
                      show_brightness_control: true
                      card_mod:
                        style: |
                          ha-card {
                            border: 1px solid #E5E5E5;
                            border-radius: 16px;
                            margin: 8px 16px;
                          }
                    - type: custom:mushroom-light-card
                      entity: light.dining_room_light_3
                      name: Dining Light
                      use_light_color: true
                      show_brightness_control: true
                      card_mod:
                        style: |
                          ha-card {
                            border: 1px solid #E5E5E5;
                            border-radius: 16px;
                            margin: 8px 16px;
                          }
                    - type: custom:mushroom-light-card
                      entity: light.sofa_light_switch
                      name: Sofa Light
                      use_light_color: true
                      card_mod:
                        style: |
                          ha-card {
                            border: 1px solid #E5E5E5;
                            border-radius: 16px;
                            margin: 8px 16px;
                          }
                    - type: custom:mushroom-light-card
                      entity: light.tv_light
                      name: TV Light
                      use_light_color: true
                      show_brightness_control: true
                      card_mod:
                        style: |
                          ha-card {
                            border: 1px solid #E5E5E5;
                            border-radius: 16px;
                            margin: 8px 16px;
                          }

              # Climate Tab
              - attributes:
                  label: Climate
                card:
                  type: custom:vertical-layout
                  cards:
                    - type: custom:mushroom-fan-card
                      entity: fan.dyson
                      name: Dyson Fan
                      show_percentage_control: true
                      card_mod:
                        style: |
                          ha-card {
                            border: 1px solid #E5E5E5;
                            border-radius: 16px;
                            margin: 8px 16px;
                          }
                    - type: custom:mini-graph-card
                      entities:
                        - entity: sensor.dyson_temperature
                          name: Temperature
                          color: "#FC691C"
                      hours_to_show: 24
                      points_per_hour: 2
                      line_width: 2
                      height: 100
                      show:
                        labels: false
                        name: true
                        icon: false
                        state: true
                        legend: false
                      card_mod:
                        style: |
                          ha-card {
                            border: 1px solid #E5E5E5;
                            border-radius: 16px;
                            margin: 8px 16px;
                          }

              # Other Tab
              - attributes:
                  label: Other
                card:
                  type: custom:vertical-layout
                  cards:
                    - type: custom:mushroom-entity-card
                      entity: binary_sensor.living_room_motion_sensor_occupancy
                      name: Motion Sensor
                      card_mod:
                        style: |
                          ha-card {
                            border: 1px solid #E5E5E5;
                            border-radius: 16px;
                            margin: 8px 16px;
                          }

      # ==================== BEDROOM ====================
      - title: Bedroom
        path: bedroom
        icon: mdi:bed
        type: custom:vertical-layout
        layout:
          max_width: 500
        cards:
          # Header
          - type: custom:button-card
            styles:
              card:
                - background: none
                - border: none
                - box-shadow: none
                - padding: 16px
                - display: flex
                - justify-content: space-between
                - align-items: center
            custom_fields:
              title: '<div style="font-size:28px;font-weight:400;color:#FC691C;">Bedroom</div>'
              back:
                card:
                  type: custom:button-card
                  icon: mdi:chevron-left
                  tap_action:
                    action: navigate
                    navigation_path: /lovelace-home/home
                  styles:
                    card:
                      - background: none
                      - border: 1px solid "#E5E5E5"
                      - border-radius: 50%
                      - width: 40px
                      - height: 40px
                    icon:
                      - width: 20px
                      - color: "#6B7280"

          # Hero
          - type: picture-elements
            image: ${images.bedroom}
            card_mod:
              style: |
                ha-card {
                  border-radius: 16px;
                  margin: 0 16px;
                  overflow: hidden;
                }
            elements: []

          # Sub-tabs
          - type: custom:tabbed-card
            styles:
              "--mdc-tab-text-label-color-default": "#9CA3AF"
              "--mdc-theme-primary": "#FC691C"
            tabs:
              - attributes:
                  label: Lights
                card:
                  type: custom:vertical-layout
                  cards:
                    - type: custom:mushroom-light-card
                      entity: light.above_bed_light
                      name: Above Bed
                      use_light_color: true
                      show_brightness_control: true
                      card_mod:
                        style: |
                          ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }
                    - type: custom:mushroom-light-card
                      entity: light.bedroom_light_2
                      name: Main Light
                      use_light_color: true
                      show_brightness_control: true
                      card_mod:
                        style: |
                          ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }
                    - type: custom:mushroom-light-card
                      entity: light.darren_switch
                      name: "Darren's Side"
                      use_light_color: true
                      card_mod:
                        style: |
                          ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }
                    - type: custom:mushroom-light-card
                      entity: light.lorraine_switch
                      name: "Lorraine's Side"
                      use_light_color: true
                      card_mod:
                        style: |
                          ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }
              - attributes:
                  label: Media
                card:
                  type: custom:vertical-layout
                  cards:
                    - type: custom:mushroom-media-player-card
                      entity: media_player.apple_tv
                      name: Apple TV
                      use_media_info: true
                      show_volume_level: true
                      card_mod:
                        style: |
                          ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }

      # ==================== BATHROOM ====================
      - title: Bathroom
        path: bathroom
        icon: mdi:shower
        type: custom:vertical-layout
        layout:
          max_width: 500
        cards:
          - type: custom:button-card
            styles:
              card:
                - background: none
                - border: none
                - box-shadow: none
                - padding: 16px
                - display: flex
                - justify-content: space-between
            custom_fields:
              title: '<div style="font-size:28px;font-weight:400;color:#FC691C;">Bathroom</div>'
              back:
                card:
                  type: custom:button-card
                  icon: mdi:chevron-left
                  tap_action:
                    action: navigate
                    navigation_path: /lovelace-home/home
                  styles:
                    card:
                      - background: none
                      - border: 1px solid "#E5E5E5"
                      - border-radius: 50%
                      - width: 40px
                      - height: 40px
                    icon:
                      - width: 20px
                      - color: "#6B7280"

          - type: picture-elements
            image: ${images.bathroom}
            card_mod:
              style: |
                ha-card { border-radius: 16px; margin: 0 16px; overflow: hidden; }
            elements: []

          - type: custom:tabbed-card
            styles:
              "--mdc-tab-text-label-color-default": "#9CA3AF"
              "--mdc-theme-primary": "#FC691C"
            tabs:
              - attributes:
                  label: Lights
                card:
                  type: custom:vertical-layout
                  cards:
                    - type: custom:mushroom-light-card
                      entity: light.bath_light
                      name: Bath Light
                      use_light_color: true
                      card_mod:
                        style: |
                          ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }
                    - type: custom:mushroom-light-card
                      entity: light.sink_light
                      name: Sink Light
                      use_light_color: true
                      card_mod:
                        style: |
                          ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }
                    - type: custom:mushroom-light-card
                      entity: light.toilet_light
                      name: Toilet Light
                      use_light_color: true
                      card_mod:
                        style: |
                          ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }
              - attributes:
                  label: Climate
                card:
                  type: custom:vertical-layout
                  cards:
                    - type: custom:mini-graph-card
                      entities:
                        - entity: sensor.bathroom_sensor_temperature
                          name: Temperature
                          color: "#FC691C"
                        - entity: sensor.bathroom_sensor_humidity
                          name: Humidity
                          color: "#3B82F6"
                          y_axis: secondary
                      hours_to_show: 24
                      points_per_hour: 2
                      line_width: 2
                      height: 100
                      show:
                        labels: false
                        name: true
                        icon: false
                        state: true
                        legend: true
                      card_mod:
                        style: |
                          ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }

      # ==================== KITCHEN ====================
      - title: Kitchen
        path: kitchen
        icon: mdi:silverware-fork-knife
        type: custom:vertical-layout
        layout:
          max_width: 500
        cards:
          - type: custom:button-card
            styles:
              card:
                - background: none
                - border: none
                - box-shadow: none
                - padding: 16px
                - display: flex
                - justify-content: space-between
            custom_fields:
              title: '<div style="font-size:28px;font-weight:400;color:#FC691C;">Kitchen</div>'
              back:
                card:
                  type: custom:button-card
                  icon: mdi:chevron-left
                  tap_action:
                    action: navigate
                    navigation_path: /lovelace-home/home
                  styles:
                    card:
                      - background: none
                      - border: 1px solid "#E5E5E5"
                      - border-radius: 50%
                      - width: 40px
                      - height: 40px
                    icon:
                      - width: 20px
                      - color: "#6B7280"

          - type: picture-elements
            image: ${images.kitchen}
            card_mod:
              style: |
                ha-card { border-radius: 16px; margin: 0 16px; overflow: hidden; }
            elements: []

          - type: custom:tabbed-card
            styles:
              "--mdc-tab-text-label-color-default": "#9CA3AF"
              "--mdc-theme-primary": "#FC691C"
            tabs:
              - attributes:
                  label: Lights
                card:
                  type: custom:vertical-layout
                  cards:
                    - type: custom:mushroom-light-card
                      entity: light.kitchen_microwave
                      name: Main Light
                      use_light_color: true
                      card_mod:
                        style: |
                          ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }
                    - type: custom:mushroom-light-card
                      entity: light.kitchen_sink
                      name: Sink Light
                      use_light_color: true
                      card_mod:
                        style: |
                          ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }
                    - type: custom:mushroom-light-card
                      entity: light.kitchen_random
                      name: Other Light
                      use_light_color: true
                      card_mod:
                        style: |
                          ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }

      # ==================== HALLWAY ====================
      - title: Hallway
        path: hallway
        icon: mdi:door
        type: custom:vertical-layout
        layout:
          max_width: 500
        cards:
          - type: custom:button-card
            styles:
              card:
                - background: none
                - border: none
                - box-shadow: none
                - padding: 16px
                - display: flex
                - justify-content: space-between
            custom_fields:
              title: '<div style="font-size:28px;font-weight:400;color:#FC691C;">Hallway</div>'
              back:
                card:
                  type: custom:button-card
                  icon: mdi:chevron-left
                  tap_action:
                    action: navigate
                    navigation_path: /lovelace-home/home
                  styles:
                    card:
                      - background: none
                      - border: 1px solid "#E5E5E5"
                      - border-radius: 50%
                      - width: 40px
                      - height: 40px
                    icon:
                      - width: 20px
                      - color: "#6B7280"

          - type: picture-elements
            image: ${images.hallway}
            card_mod:
              style: |
                ha-card { border-radius: 16px; margin: 0 16px; overflow: hidden; }
            elements: []

          - type: custom:tabbed-card
            styles:
              "--mdc-tab-text-label-color-default": "#9CA3AF"
              "--mdc-theme-primary": "#FC691C"
            tabs:
              - attributes:
                  label: Lights
                card:
                  type: custom:vertical-layout
                  cards:
                    - type: custom:mushroom-light-card
                      entity: light.hallway
                      name: Hallway Light
                      use_light_color: true
                      card_mod:
                        style: |
                          ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }
              - attributes:
                  label: Climate
                card:
                  type: custom:vertical-layout
                  cards:
                    - type: custom:mini-graph-card
                      entities:
                        - entity: sensor.hallway_sensor_temperature
                          name: Temperature
                          color: "#FC691C"
                        - entity: sensor.hallway_sensor_humidity
                          name: Humidity
                          color: "#3B82F6"
                          y_axis: secondary
                      hours_to_show: 24
                      points_per_hour: 2
                      line_width: 2
                      height: 100
                      show:
                        labels: false
                        name: true
                        icon: false
                        state: true
                        legend: true
                      card_mod:
                        style: |
                          ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }

      # ==================== ROBYNNE'S ROOM ====================
      - title: "Robynne's Room"
        path: robynne
        icon: mdi:teddy-bear
        type: custom:vertical-layout
        layout:
          max_width: 500
        cards:
          - type: custom:button-card
            styles:
              card:
                - background: none
                - border: none
                - box-shadow: none
                - padding: 16px
                - display: flex
                - justify-content: space-between
            custom_fields:
              title: "<div style=\"font-size:28px;font-weight:400;color:#FC691C;\">Robynne's Room</div>"
              back:
                card:
                  type: custom:button-card
                  icon: mdi:chevron-left
                  tap_action:
                    action: navigate
                    navigation_path: /lovelace-home/home
                  styles:
                    card:
                      - background: none
                      - border: 1px solid "#E5E5E5"
                      - border-radius: 50%
                      - width: 40px
                      - height: 40px
                    icon:
                      - width: 20px
                      - color: "#6B7280"

          - type: picture-elements
            image: ${images.childRoom}
            card_mod:
              style: |
                ha-card { border-radius: 16px; margin: 0 16px; overflow: hidden; }
            elements: []

          - type: custom:tabbed-card
            styles:
              "--mdc-tab-text-label-color-default": "#9CA3AF"
              "--mdc-theme-primary": "#FC691C"
            tabs:
              - attributes:
                  label: Media
                card:
                  type: custom:vertical-layout
                  cards:
                    - type: custom:mushroom-media-player-card
                      entity: media_player.yoto_player
                      name: Yoto Player
                      use_media_info: true
                      show_volume_level: true
                      card_mod:
                        style: |
                          ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }
              - attributes:
                  label: Lights
                card:
                  type: custom:vertical-layout
                  cards:
                    - type: custom:auto-entities
                      card:
                        type: custom:vertical-layout
                      filter:
                        include:
                          - group: group.robynne_lights
                            options:
                              type: custom:mushroom-light-card
                              use_light_color: true
                              card_mod:
                                style: |
                                  ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }

      # ==================== FLOORPLAN ====================
      - title: Floorplan
        path: floorplan
        icon: mdi:floor-plan
        type: custom:vertical-layout
        layout:
          max_width: 500
        cards:
          - type: custom:button-card
            styles:
              card:
                - background: none
                - border: none
                - box-shadow: none
                - padding: 16px
                - display: flex
                - justify-content: space-between
            custom_fields:
              title: '<div style="font-size:28px;font-weight:400;color:#FC691C;">Floorplan</div>'
              back:
                card:
                  type: custom:button-card
                  icon: mdi:chevron-left
                  tap_action:
                    action: navigate
                    navigation_path: /lovelace-home/home
                  styles:
                    card:
                      - background: none
                      - border: 1px solid "#E5E5E5"
                      - border-radius: 50%
                      - width: 40px
                      - height: 40px
                    icon:
                      - width: 20px
                      - color: "#6B7280"

          - type: custom:floorplan-card
            full_height: true
            config:
              image: /local/floorplan.svg
              stylesheet: |
                .room { cursor: pointer; }
                .room:hover { filter: brightness(1.15); }
                .light-icon { cursor: pointer; }
                .light-icon.on { fill: #FC691C !important; filter: drop-shadow(0 0 8px #FC691C); }
                .motion-icon.detected { fill: #3B82F6 !important; filter: drop-shadow(0 0 6px #3B82F6); }
              defaults:
                hover_action: hover-info
                tap_action: more-info
              rules:
                - element: room.living_room
                  entity: group.living_room_lights
                  tap_action: toggle
                - element: light.living_room
                  entity: group.living_room_lights
                  state_action:
                    action: call-service
                    service: floorplan.class_set
                    service_data:
                      class: >-
                        ''${entity.state === "on" ? "light-icon on" : "light-icon"}
                  tap_action: toggle
                - element: motion.living_room
                  entity: binary_sensor.living_room_motion_sensor_occupancy
                  state_action:
                    action: call-service
                    service: floorplan.class_set
                    service_data:
                      class: >-
                        ''${entity.state === "on" ? "motion-icon detected" : "motion-icon"}

      # ==================== ENERGY ====================
      - title: Energy
        path: energy
        icon: mdi:lightning-bolt
        type: custom:vertical-layout
        layout:
          max_width: 500
        cards:
          - type: custom:button-card
            styles:
              card:
                - background: none
                - border: none
                - box-shadow: none
                - padding: 16px
                - display: flex
                - justify-content: space-between
            custom_fields:
              title: '<div style="font-size:28px;font-weight:400;color:#FC691C;">Energy</div>'
              back:
                card:
                  type: custom:button-card
                  icon: mdi:chevron-left
                  tap_action:
                    action: navigate
                    navigation_path: /lovelace-home/home
                  styles:
                    card:
                      - background: none
                      - border: 1px solid "#E5E5E5"
                      - border-radius: 50%
                      - width: 40px
                      - height: 40px
                    icon:
                      - width: 20px
                      - color: "#6B7280"

          - type: custom:mushroom-entity-card
            entity: sensor.octopus_energy_electricity_16k0150212_2500001111806_current_rate
            name: Current Rate
            card_mod:
              style: |
                ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }

      # ==================== CAR ====================
      - title: Car
        path: car
        icon: mdi:car
        type: custom:vertical-layout
        layout:
          max_width: 500
        cards:
          - type: custom:button-card
            styles:
              card:
                - background: none
                - border: none
                - box-shadow: none
                - padding: 16px
                - display: flex
                - justify-content: space-between
            custom_fields:
              title: '<div style="font-size:28px;font-weight:400;color:#FC691C;">Car</div>'
              back:
                card:
                  type: custom:button-card
                  icon: mdi:chevron-left
                  tap_action:
                    action: navigate
                    navigation_path: /lovelace-home/home
                  styles:
                    card:
                      - background: none
                      - border: 1px solid "#E5E5E5"
                      - border-radius: 50%
                      - width: 40px
                      - height: 40px
                    icon:
                      - width: 20px
                      - color: "#6B7280"

          - type: custom:mushroom-entity-card
            entity: sensor.fordpass_wf02xxerk2la80437_fuel
            name: Fuel Level
            card_mod:
              style: |
                ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }

      # ==================== FISH ====================
      - title: Fish
        path: fish
        icon: mdi:fish
        type: custom:vertical-layout
        layout:
          max_width: 500
        cards:
          - type: custom:button-card
            styles:
              card:
                - background: none
                - border: none
                - box-shadow: none
                - padding: 16px
                - display: flex
                - justify-content: space-between
            custom_fields:
              title: '<div style="font-size:28px;font-weight:400;color:#FC691C;">Fish Tank</div>'
              back:
                card:
                  type: custom:button-card
                  icon: mdi:chevron-left
                  tap_action:
                    action: navigate
                    navigation_path: /lovelace-home/home
                  styles:
                    card:
                      - background: none
                      - border: 1px solid "#E5E5E5"
                      - border-radius: 50%
                      - width: 40px
                      - height: 40px
                    icon:
                      - width: 20px
                      - color: "#6B7280"

          - type: custom:mushroom-entity-card
            entity: sensor.current_temperature
            name: Water Temperature
            card_mod:
              style: |
                ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }

      # ==================== SYSTEM ====================
      - title: System
        path: system
        icon: mdi:cog
        type: custom:vertical-layout
        layout:
          max_width: 500
        cards:
          - type: custom:button-card
            styles:
              card:
                - background: none
                - border: none
                - box-shadow: none
                - padding: 16px
                - display: flex
                - justify-content: space-between
            custom_fields:
              title: '<div style="font-size:28px;font-weight:400;color:#FC691C;">System</div>'
              back:
                card:
                  type: custom:button-card
                  icon: mdi:chevron-left
                  tap_action:
                    action: navigate
                    navigation_path: /lovelace-home/home
                  styles:
                    card:
                      - background: none
                      - border: 1px solid "#E5E5E5"
                      - border-radius: 50%
                      - width: 40px
                      - height: 40px
                    icon:
                      - width: 20px
                      - color: "#6B7280"

          # System Stats
          - type: custom:button-card
            name: System Statistics
            styles:
              card:
                - background: none
                - border: none
                - padding: 0 16px
              name:
                - font-size: 14px
                - font-weight: 600
                - color: "#1A1A1A"
                - justify-self: start

          - type: entities
            card_mod:
              style: |
                ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }
            entities:
              - entity: sensor.system_monitor_load_1m
                name: System Load (1m)
              - entity: sensor.system_monitor_disk_usage
                name: Disk Usage

          # Low Battery
          - type: custom:button-card
            name: Low Battery
            styles:
              card:
                - background: none
                - border: none
                - padding: 16px 16px 0 16px
              name:
                - font-size: 14px
                - font-weight: 600
                - color: "#1A1A1A"
                - justify-self: start

          - type: custom:auto-entities
            card:
              type: entities
              card_mod:
                style: |
                  ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }
            filter:
              include:
                - attributes:
                    device_class: battery
                  state: "< 30"
                  options:
                    type: custom:mushroom-entity-card
                    icon_color: orange
            sort:
              method: state
              numeric: true
            show_empty: false

          # Unavailable
          - type: custom:button-card
            name: Unavailable Devices
            styles:
              card:
                - background: none
                - border: none
                - padding: 16px 16px 0 16px
              name:
                - font-size: 14px
                - font-weight: 600
                - color: "#1A1A1A"
                - justify-self: start

          - type: custom:auto-entities
            card:
              type: entities
              card_mod:
                style: |
                  ha-card { border: 1px solid #E5E5E5; border-radius: 16px; margin: 8px 16px; }
            filter:
              include:
                - state: unavailable
                  domain: light
                  options:
                    type: custom:mushroom-entity-card
                    icon_color: red
                - state: unavailable
                  domain: switch
                  options:
                    type: custom:mushroom-entity-card
                    icon_color: red
            sort:
              method: friendly_name
            show_empty: false

          # Actions
          - type: custom:mushroom-chips-card
            chips:
              - type: template
                icon: mdi:restart
                icon_color: red
                content: Restart
                tap_action:
                  action: call-service
                  service: button.press
                  target:
                    entity_id: button.homeassistant_restart
                  confirmation:
                    text: Restart Home Assistant?
              - type: template
                icon: mdi:reload
                icon_color: orange
                content: Reload
                tap_action:
                  action: call-service
                  service: button.press
                  target:
                    entity_id: button.homeassistant_reload
            alignment: center
            card_mod:
              style: |
                ha-card { margin: 16px; }
  '';
in {
  systemd.tmpfiles.rules = [
    "L+ /var/lib/hass/home.yaml - - - - ${dashboardYaml}"
    "d /var/lib/hass/www 0755 hass hass -"
    "L+ /var/lib/hass/www/floorplan.svg - - - - ${floorplanSvg}"
  ];

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
