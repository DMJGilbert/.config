{pkgs, ...}: let
  floorplanSvg = ./floorplan.svg;
  dashboardYaml = pkgs.writeText "hacasa.yaml" ''
    title: Home
    views:
      # ==================== HOME ====================
      - title: Home
        path: home
        icon: mdi:home
        type: custom:vertical-layout
        cards:
          # Compact header - weather + status in one row
          - type: custom:mushroom-chips-card
            chips:
              - type: weather
                entity: weather.forecast_home
                show_conditions: true
                show_temperature: true
              - type: template
                entity: person.darren_gilbert
                icon: >
                  {% if is_state('person.darren_gilbert', 'home') %}mdi:home-account{% else %}mdi:account-arrow-right{% endif %}
                icon_color: >
                  {% if is_state('person.darren_gilbert', 'home') %}green{% else %}blue{% endif %}
                content: D
                tap_action:
                  action: more-info
              - type: template
                entity: person.lorraine
                icon: >
                  {% if is_state('person.lorraine', 'home') %}mdi:home-account{% else %}mdi:account-arrow-right{% endif %}
                icon_color: >
                  {% if is_state('person.lorraine', 'home') %}green{% else %}blue{% endif %}
                content: L
                tap_action:
                  action: more-info
              - type: template
                icon: mdi:lightbulb-group
                icon_color: "{% if states('sensor.total_turned_on_lights_count_template') | int > 0 %}amber{% else %}disabled{% endif %}"
                content: "{{ states('sensor.total_turned_on_lights_count_template') }}"
              - type: template
                icon: mdi:thermometer
                icon_color: cyan
                content: >
                  {% set temps = [
                    states('sensor.hallway_sensor_temperature'),
                    states('sensor.bathroom_sensor_temperature'),
                    states('sensor.dyson_temperature')
                  ] | reject('in', ['unavailable', 'unknown']) | map('float') | list %}
                  {% if temps %}{{ (temps | sum / temps | length) | round(0) }}°{% else %}--{% endif %}
            alignment: center

          # Active/Playing section - only shows if something is active
          - type: conditional
            conditions:
              - condition: or
                conditions:
                  - condition: state
                    entity: media_player.living_room_tv
                    state_not: "off"
                  - condition: state
                    entity: media_player.living_room_tv
                    state_not: unavailable
                  - condition: state
                    entity: media_player.apple_tv
                    state_not: "off"
                  - condition: state
                    entity: media_player.yoto_player
                    state: playing
            card:
              type: custom:mushroom-chips-card
              chips:
                - type: conditional
                  conditions:
                    - condition: state
                      entity: media_player.living_room_tv
                      state_not: "off"
                  chip:
                    type: template
                    entity: media_player.living_room_tv
                    icon: mdi:television
                    icon_color: green
                    content: TV
                    tap_action:
                      action: more-info
                - type: conditional
                  conditions:
                    - condition: state
                      entity: media_player.yoto_player
                      state: playing
                  chip:
                    type: template
                    entity: media_player.yoto_player
                    icon: mdi:music-box
                    icon_color: pink
                    content: Yoto
                    tap_action:
                      action: more-info
              alignment: center

          # Quick Actions - compact chip row
          - type: custom:mushroom-chips-card
            chips:
              - type: template
                icon: mdi:power
                icon_color: red
                tap_action:
                  action: call-service
                  service: light.turn_off
                  target:
                    entity_id: all
              - type: template
                entity: input_boolean.party_mode
                icon: mdi:party-popper
                icon_color: "{% if is_state('input_boolean.party_mode', 'on') %}deep-purple{% else %}disabled{% endif %}"
                tap_action:
                  action: toggle
              - type: template
                icon: mdi:movie-open
                icon_color: blue
                tap_action:
                  action: call-service
                  service: scene.turn_on
                  target:
                    entity_id: scene.movie
              - type: template
                icon: mdi:brightness-7
                icon_color: amber
                tap_action:
                  action: call-service
                  service: light.turn_on
                  target:
                    entity_id: all
                  data:
                    brightness: 255
              - type: template
                entity: vacuum.robovac
                icon: mdi:robot-vacuum
                icon_color: >
                  {% if is_state('vacuum.robovac', 'cleaning') %}green
                  {% elif is_state('vacuum.robovac', 'returning') %}blue
                  {% else %}disabled{% endif %}
                tap_action:
                  action: more-info
            alignment: center

          # Football - conditional, only shows if match upcoming/live
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
              type: custom:mushroom-template-card
              entity: sensor.liverpool
              primary: >
                {% set sensors = ['sensor.liverpool', 'sensor.liverpool_cl', 'sensor.liverpool_fa', 'sensor.liverpool_lc'] %}
                {% set ns = namespace(match=none, next_date=none) %}
                {% for s in sensors %}
                  {% set sensor = states[s] %}
                  {% if sensor and sensor.state == 'IN' %}
                    {% set ns.match = sensor %}
                  {% elif sensor and sensor.state == 'PRE' and sensor.attributes.date %}
                    {% set d = sensor.attributes.date | as_datetime %}
                    {% if not ns.next_date or d < ns.next_date %}
                      {% set ns.next_date = d %}
                      {% set ns.match = sensor %}
                    {% endif %}
                  {% endif %}
                {% endfor %}
                {% if ns.match %}
                  {% set a = ns.match.attributes %}
                  {% if ns.match.state == 'IN' %}
                    {{ a.team_abbr }} {{ a.team_score }}-{{ a.opponent_score }} {{ a.opponent_abbr }}
                  {% else %}
                    {{ a.team_abbr }} v {{ a.opponent_abbr }}
                  {% endif %}
                {% endif %}
              secondary: >
                {% set sensors = ['sensor.liverpool', 'sensor.liverpool_cl', 'sensor.liverpool_fa', 'sensor.liverpool_lc'] %}
                {% set ns = namespace(match=none, next_date=none) %}
                {% for s in sensors %}
                  {% set sensor = states[s] %}
                  {% if sensor and sensor.state == 'IN' %}
                    {% set ns.match = sensor %}
                  {% elif sensor and sensor.state == 'PRE' and sensor.attributes.date %}
                    {% set d = sensor.attributes.date | as_datetime %}
                    {% if not ns.next_date or d < ns.next_date %}
                      {% set ns.next_date = d %}
                      {% set ns.match = sensor %}
                    {% endif %}
                  {% endif %}
                {% endfor %}
                {% if ns.match %}
                  {% set a = ns.match.attributes %}
                  {% if ns.match.state == 'IN' %}LIVE{% else %}{{ a.date | as_datetime | as_local | as_timestamp | timestamp_custom('%a %H:%M') }}{% endif %}
                {% endif %}
              icon: mdi:soccer
              icon_color: >
                {% if is_state('sensor.liverpool', 'IN') %}green{% else %}deep-purple{% endif %}
              layout: horizontal
              tap_action:
                action: more-info

          # Room Grid - 3 columns for density
          - type: grid
            columns: 3
            square: true
            cards:
              # Living Room
              - type: custom:mushroom-template-card
                entity: group.living_room_lights
                primary: Living
                secondary: >
                  {% set temp = states('sensor.dyson_temperature') %}
                  {% if temp not in ['unavailable', 'unknown'] %}{{ temp | round(0) }}°{% endif %}
                icon: mdi:sofa
                icon_color: >
                  {% set entities = state_attr('group.living_room_lights', 'entity_id') | default([]) %}
                  {% if entities | select('is_state', 'on') | list | count > 0 %}amber{% else %}disabled{% endif %}
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-home/living-room
                hold_action:
                  action: toggle
                layout: vertical
                badge_icon: >
                  {% if is_state('media_player.living_room_tv', 'playing') or is_state('media_player.living_room_tv', 'on') %}mdi:television{% endif %}
                badge_color: green

              # Bedroom
              - type: custom:mushroom-template-card
                entity: group.bedroom_lights
                primary: Bedroom
                secondary: >
                  {% set entities = state_attr('group.bedroom_lights', 'entity_id') | default([]) %}
                  {% set on = entities | select('is_state', 'on') | list | count %}
                  {% if on > 0 %}{{ on }} on{% endif %}
                icon: mdi:bed
                icon_color: >
                  {% set entities = state_attr('group.bedroom_lights', 'entity_id') | default([]) %}
                  {% if entities | select('is_state', 'on') | list | count > 0 %}deep-purple{% else %}disabled{% endif %}
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-home/bedroom
                hold_action:
                  action: toggle
                layout: vertical

              # Bathroom
              - type: custom:mushroom-template-card
                entity: group.bathroom_lights
                primary: Bath
                secondary: >
                  {% set temp = states('sensor.bathroom_sensor_temperature') %}
                  {% if temp not in ['unavailable', 'unknown'] %}{{ temp | round(0) }}°{% endif %}
                icon: mdi:shower
                icon_color: >
                  {% if is_state('binary_sensor.motion_sensor_motion', 'on') %}blue
                  {% elif is_state('group.bathroom_lights', 'on') %}amber
                  {% else %}disabled{% endif %}
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-home/bathroom
                hold_action:
                  action: toggle
                layout: vertical

              # Kitchen
              - type: custom:mushroom-template-card
                entity: group.kitchen_lights
                primary: Kitchen
                secondary: >
                  {% set entities = state_attr('group.kitchen_lights', 'entity_id') | default([]) %}
                  {% set on = entities | select('is_state', 'on') | list | count %}
                  {% if on > 0 %}{{ on }} on{% endif %}
                icon: mdi:silverware-fork-knife
                icon_color: >
                  {% set entities = state_attr('group.kitchen_lights', 'entity_id') | default([]) %}
                  {% if entities | select('is_state', 'on') | list | count > 0 %}amber{% else %}disabled{% endif %}
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-home/kitchen
                hold_action:
                  action: toggle
                layout: vertical

              # Hallway
              - type: custom:mushroom-template-card
                entity: group.hallway_lights
                primary: Hallway
                secondary: >
                  {% set temp = states('sensor.hallway_sensor_temperature') %}
                  {% if temp not in ['unavailable', 'unknown'] %}{{ temp | round(0) }}°{% endif %}
                icon: mdi:door
                icon_color: >
                  {% if is_state('binary_sensor.hallway_motion_sensor_occupancy', 'on') %}blue
                  {% elif is_state('group.hallway_lights', 'on') %}amber
                  {% else %}disabled{% endif %}
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-home/hallway
                hold_action:
                  action: toggle
                layout: vertical

              # Robynne's Room
              - type: custom:mushroom-template-card
                entity: group.robynne_lights
                primary: Robynne
                secondary: >
                  {% if is_state('media_player.yoto_player', 'playing') %}Playing{% endif %}
                icon: mdi:teddy-bear
                icon_color: >
                  {% if is_state('media_player.yoto_player', 'playing') %}green{% else %}pink{% endif %}
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-home/robynne
                hold_action:
                  action: toggle
                layout: vertical
                badge_icon: >
                  {% if is_state('media_player.yoto_player', 'playing') %}mdi:music{% endif %}
                badge_color: green

          # Active Media - only if playing
          - type: conditional
            conditions:
              - condition: or
                conditions:
                  - condition: state
                    entity: media_player.living_room_tv
                    state: playing
                  - condition: state
                    entity: media_player.apple_tv
                    state: playing
            card:
              type: custom:mushroom-media-player-card
              entity: >
                {% if is_state('media_player.living_room_tv', 'playing') %}media_player.living_room_tv
                {% else %}media_player.apple_tv{% endif %}
              icon_type: entity-picture
              use_media_info: true
              show_volume_level: false
              collapsible_controls: true
              fill_container: true

          # Energy rate - compact
          - type: custom:mushroom-chips-card
            chips:
              - type: template
                entity: sensor.octopus_energy_electricity_16k0150212_2500001111806_current_rate
                icon: mdi:lightning-bolt
                icon_color: >
                  {% set rate = states('sensor.octopus_energy_electricity_16k0150212_2500001111806_current_rate') | float(0) %}
                  {% if rate < 15 %}green{% elif rate < 25 %}amber{% else %}red{% endif %}
                content: "{{ states('sensor.octopus_energy_electricity_16k0150212_2500001111806_current_rate') | round(1) }}p"
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-home/energy
              - type: template
                entity: sensor.fordpass_wf02xxerk2la80437_fuel
                icon: mdi:car
                icon_color: >
                  {% set fuel = states('sensor.fordpass_wf02xxerk2la80437_fuel') | float(0) %}
                  {% if fuel > 50 %}green{% elif fuel > 25 %}amber{% else %}red{% endif %}
                content: "{{ states('sensor.fordpass_wf02xxerk2la80437_fuel') }}%"
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-home/car
              - type: template
                entity: sensor.current_temperature
                icon: mdi:fish
                icon_color: >
                  {% set temp = states('sensor.current_temperature') | float(0) %}
                  {% if temp < 22 or temp > 28 %}red{% elif temp < 24 or temp > 26 %}orange{% else %}green{% endif %}
                content: "{{ states('sensor.current_temperature') | round(0) }}°"
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-home/fish
            alignment: center

      # ==================== FLOORPLAN ====================
      - title: Floorplan
        path: floorplan
        icon: mdi:floor-plan
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: Floor Plan
            subtitle: Interactive Home View

          - type: custom:floorplan-card
            full_height: true
            config:
              image: /local/floorplan.svg
              stylesheet: |
                .room { cursor: pointer; }
                .room:hover { filter: brightness(1.15); }
                .light-icon { cursor: pointer; }
                .light-icon.on { fill: #f9e2af !important; filter: drop-shadow(0 0 8px #f9e2af); }
                .motion-icon.detected { fill: #89b4fa !important; filter: drop-shadow(0 0 6px #89b4fa); }
              defaults:
                hover_action: hover-info
                tap_action: more-info
              rules:
                # Living Room
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
                - element: temp.living_room
                  entity: sensor.dyson_temperature
                  state_action:
                    action: call-service
                    service: floorplan.text_set
                    service_data:
                      text: >-
                        ''${entity.state}°C

                # Bedroom
                - element: room.bedroom
                  entity: group.bedroom_lights
                  tap_action: toggle
                - element: light.bedroom
                  entity: group.bedroom_lights
                  state_action:
                    action: call-service
                    service: floorplan.class_set
                    service_data:
                      class: >-
                        ''${entity.state === "on" ? "light-icon on" : "light-icon"}
                  tap_action: toggle
                - element: motion.bedroom
                  entity: binary_sensor.bedroom_motion_sensor_occupancy
                  state_action:
                    action: call-service
                    service: floorplan.class_set
                    service_data:
                      class: >-
                        ''${entity.state === "on" ? "motion-icon detected" : "motion-icon"}

                # Kitchen
                - element: room.kitchen
                  entity: group.kitchen_lights
                  tap_action: toggle
                - element: light.kitchen
                  entity: group.kitchen_lights
                  state_action:
                    action: call-service
                    service: floorplan.class_set
                    service_data:
                      class: >-
                        ''${entity.state === "on" ? "light-icon on" : "light-icon"}
                  tap_action: toggle

                # Hallway
                - element: room.hallway
                  entity: group.hallway_lights
                  tap_action: toggle
                - element: light.hallway
                  entity: group.hallway_lights
                  state_action:
                    action: call-service
                    service: floorplan.class_set
                    service_data:
                      class: >-
                        ''${entity.state === "on" ? "light-icon on" : "light-icon"}
                  tap_action: toggle
                - element: motion.hallway
                  entity: binary_sensor.hallway_motion_sensor_occupancy
                  state_action:
                    action: call-service
                    service: floorplan.class_set
                    service_data:
                      class: >-
                        ''${entity.state === "on" ? "motion-icon detected" : "motion-icon"}
                - element: temp.hallway
                  entity: sensor.hallway_sensor_temperature
                  state_action:
                    action: call-service
                    service: floorplan.text_set
                    service_data:
                      text: >-
                        ''${entity.state}°C

                # Bathroom
                - element: room.bathroom
                  entity: group.bathroom_lights
                  tap_action: toggle
                - element: light.bathroom
                  entity: group.bathroom_lights
                  state_action:
                    action: call-service
                    service: floorplan.class_set
                    service_data:
                      class: >-
                        ''${entity.state === "on" ? "light-icon on" : "light-icon"}
                  tap_action: toggle
                - element: motion.bathroom
                  entity: binary_sensor.motion_sensor_motion
                  state_action:
                    action: call-service
                    service: floorplan.class_set
                    service_data:
                      class: >-
                        ''${entity.state === "on" ? "motion-icon detected" : "motion-icon"}
                - element: temp.bathroom
                  entity: sensor.bathroom_sensor_temperature
                  state_action:
                    action: call-service
                    service: floorplan.text_set
                    service_data:
                      text: >-
                        ''${entity.state}°C

                # Dining Room
                - element: room.dining
                  entity: light.dining_room_light_3
                  tap_action: toggle
                - element: light.dining
                  entity: light.dining_room_light_3
                  state_action:
                    action: call-service
                    service: floorplan.class_set
                    service_data:
                      class: >-
                        ''${entity.state === "on" ? "light-icon on" : "light-icon"}
                  tap_action: toggle

                # Robynne's Room
                - element: room.robynne
                  entity: group.robynne_lights
                  tap_action: toggle
                - element: light.robynne
                  entity: group.robynne_lights
                  state_action:
                    action: call-service
                    service: floorplan.class_set
                    service_data:
                      class: >-
                        ''${entity.state === "on" ? "light-icon on" : "light-icon"}
                  tap_action: toggle
                - element: motion.robynne
                  entity: binary_sensor.robynne_motion_sensor_occupancy
                  state_action:
                    action: call-service
                    service: floorplan.class_set
                    service_data:
                      class: >-
                        ''${entity.state === "on" ? "motion-icon detected" : "motion-icon"}
                - element: media.yoto
                  entity: media_player.yoto_player
                  state_action:
                    action: call-service
                    service: floorplan.style_set
                    service_data:
                      style: >-
                        fill: ''${entity.state === "playing" ? "#a6e3a1" : "#45475a"};

      # ==================== LIVING ROOM ====================
      - title: Living Room
        path: living-room
        icon: mdi:sofa
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: Living Room
            subtitle: Lights & Climate

          # Status chips
          - type: custom:mushroom-chips-card
            chips:
              - type: template
                entity: group.living_room_lights
                icon: mdi:lightbulb
                icon_color: "{% if is_state('group.living_room_lights', 'on') %}amber{% else %}disabled{% endif %}"
                content: >
                  {% set entities = state_attr('group.living_room_lights', 'entity_id') | default([]) %}
                  {% set on = entities | select('is_state', 'on') | list | count %}
                  {{ on }} on
              - type: template
                entity: sensor.dyson_temperature
                icon: mdi:thermometer
                icon_color: red
                content: "{{ states('sensor.dyson_temperature') }}°"
              - type: template
                entity: fan.dyson
                icon: mdi:fan
                icon_color: "{% if is_state('fan.dyson', 'on') %}blue{% else %}disabled{% endif %}"
                content: "{% if is_state('fan.dyson', 'on') %}{{ state_attr('fan.dyson', 'percentage') | default(0) }}%{% else %}Off{% endif %}"
                tap_action:
                  action: toggle
            alignment: center

          - type: grid
            columns: 2
            square: false
            cards:
              - type: custom:mushroom-light-card
                entity: light.living_room_light
                name: Main Light
                use_light_color: true
                show_brightness_control: true
                collapsible_controls: true
              - type: custom:mushroom-light-card
                entity: light.dining_room_light_3
                name: Dining Light
                use_light_color: true
                show_brightness_control: true
                collapsible_controls: true
              - type: custom:mushroom-light-card
                entity: light.sofa_light_switch
                name: Sofa Light
                use_light_color: true
              - type: custom:mushroom-light-card
                entity: light.tv_light
                name: TV Light
                use_light_color: true
                show_brightness_control: true
                show_color_control: true
                collapsible_controls: true

          - type: custom:mushroom-title-card
            title: Climate

          - type: custom:mushroom-fan-card
            entity: fan.dyson
            name: Dyson Fan
            show_percentage_control: true
            collapsible_controls: true

          - type: custom:mushroom-title-card
            title: Climate History

          - type: custom:mini-graph-card
            entities:
              - entity: sensor.dyson_temperature
                name: Temperature
                color: "#f44336"
            hours_to_show: 24
            points_per_hour: 4
            line_width: 2
            show:
              labels: true
              legend: true

          - type: custom:mushroom-title-card
            title: Media

          - type: custom:mushroom-media-player-card
            entity: media_player.living_room_tv
            name: Apple TV
            icon_type: entity-picture
            use_media_info: true
            show_volume_level: true
            collapsible_controls: true

      # ==================== BEDROOM ====================
      - title: Bedroom
        path: bedroom
        icon: mdi:bed
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: Bedroom
            subtitle: Lights & Media

          # Status chips
          - type: custom:mushroom-chips-card
            chips:
              - type: template
                entity: group.bedroom_lights
                icon: mdi:lightbulb
                icon_color: "{% if is_state('group.bedroom_lights', 'on') %}deep-purple{% else %}disabled{% endif %}"
                content: >
                  {% set entities = state_attr('group.bedroom_lights', 'entity_id') | default([]) %}
                  {% set on = entities | select('is_state', 'on') | list | count %}
                  {{ on }} on
              - type: template
                entity: binary_sensor.bedroom_motion_sensor_occupancy
                icon: mdi:motion-sensor
                icon_color: "{% if is_state('binary_sensor.bedroom_motion_sensor_occupancy', 'on') %}blue{% else %}disabled{% endif %}"
                content: "{% if is_state('binary_sensor.bedroom_motion_sensor_occupancy', 'on') %}Motion{% else %}Clear{% endif %}"
            alignment: center

          - type: grid
            columns: 2
            square: false
            cards:
              - type: custom:mushroom-light-card
                entity: light.above_bed_light
                name: Above Bed
                use_light_color: true
                show_brightness_control: true
                collapsible_controls: true
              - type: custom:mushroom-light-card
                entity: light.bedroom_light_2
                name: Main Light
                use_light_color: true
                show_brightness_control: true
                collapsible_controls: true
              - type: custom:mushroom-light-card
                entity: light.darren_switch
                name: Darren's Light
                use_light_color: true
              - type: custom:mushroom-light-card
                entity: light.lorraine_switch
                name: Lorraine's Light
                use_light_color: true

          - type: custom:mushroom-title-card
            title: Media

          - type: custom:mushroom-media-player-card
            entity: media_player.apple_tv
            name: Bedroom TV
            use_media_info: true
            show_volume_level: true
            collapsible_controls: true

      # ==================== BATHROOM ====================
      - title: Bathroom
        path: bathroom
        icon: mdi:shower
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: Bathroom
            subtitle: Lights & Climate

          # Status chips
          - type: custom:mushroom-chips-card
            chips:
              - type: template
                entity: sensor.bathroom_sensor_temperature
                icon: mdi:thermometer
                icon_color: red
                content: "{{ states('sensor.bathroom_sensor_temperature') | round(1) }}°"
              - type: template
                entity: sensor.bathroom_sensor_humidity
                icon: mdi:water-percent
                icon_color: >
                  {% set h = states('sensor.bathroom_sensor_humidity') | float(0) %}
                  {% if h > 70 %}orange{% else %}blue{% endif %}
                content: "{{ states('sensor.bathroom_sensor_humidity') | round(0) }}%"
              - type: template
                entity: binary_sensor.motion_sensor_motion
                icon: mdi:motion-sensor
                icon_color: "{% if is_state('binary_sensor.motion_sensor_motion', 'on') %}blue{% else %}disabled{% endif %}"
                content: "{% if is_state('binary_sensor.motion_sensor_motion', 'on') %}Motion{% else %}Clear{% endif %}"
            alignment: center

          - type: horizontal-stack
            cards:
              - type: custom:mushroom-light-card
                entity: light.bath_light
                name: Bath
                use_light_color: true
              - type: custom:mushroom-light-card
                entity: light.sink_light
                name: Sink
                use_light_color: true
              - type: custom:mushroom-light-card
                entity: light.toilet_light
                name: Toilet
                use_light_color: true

          - type: custom:mushroom-title-card
            title: Climate History

          - type: custom:mini-graph-card
            entities:
              - entity: sensor.bathroom_sensor_temperature
                name: Temperature
                color: "#f44336"
              - entity: sensor.bathroom_sensor_humidity
                name: Humidity
                color: "#2196f3"
                y_axis: secondary
            hours_to_show: 24
            points_per_hour: 4
            line_width: 2
            show:
              labels: true
              legend: true

      # ==================== KITCHEN ====================
      - title: Kitchen
        path: kitchen
        icon: mdi:silverware-fork-knife
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: Kitchen
            subtitle: Lights

          # Status chips
          - type: custom:mushroom-chips-card
            chips:
              - type: template
                entity: group.kitchen_lights
                icon: mdi:lightbulb
                icon_color: "{% if is_state('group.kitchen_lights', 'on') %}amber{% else %}disabled{% endif %}"
                content: >
                  {% set entities = state_attr('group.kitchen_lights', 'entity_id') | default([]) %}
                  {% set on = entities | select('is_state', 'on') | list | count %}
                  {{ on }} on
            alignment: center

          - type: horizontal-stack
            cards:
              - type: custom:mushroom-light-card
                entity: light.kitchen_microwave
                name: Main
                use_light_color: true
              - type: custom:mushroom-light-card
                entity: light.kitchen_sink
                name: Sink
                use_light_color: true
              - type: custom:mushroom-light-card
                entity: light.kitchen_random
                name: Other
                use_light_color: true

      # ==================== HALLWAY ====================
      - title: Hallway
        path: hallway
        icon: mdi:door
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: Hallway
            subtitle: Lights & Sensors

          # Status chips
          - type: custom:mushroom-chips-card
            chips:
              - type: template
                entity: sensor.hallway_sensor_temperature
                icon: mdi:thermometer
                icon_color: red
                content: "{{ states('sensor.hallway_sensor_temperature') | round(1) }}°"
              - type: template
                entity: sensor.hallway_sensor_humidity
                icon: mdi:water-percent
                icon_color: blue
                content: "{{ states('sensor.hallway_sensor_humidity') | round(0) }}%"
              - type: template
                entity: binary_sensor.hallway_motion_sensor_occupancy
                icon: mdi:motion-sensor
                icon_color: "{% if is_state('binary_sensor.hallway_motion_sensor_occupancy', 'on') %}blue{% else %}disabled{% endif %}"
                content: "{% if is_state('binary_sensor.hallway_motion_sensor_occupancy', 'on') %}Motion{% else %}Clear{% endif %}"
            alignment: center

          - type: horizontal-stack
            cards:
              - type: custom:mushroom-light-card
                entity: light.hallway
                name: Hallway
                use_light_color: true
              - type: custom:mushroom-light-card
                entity: light.doorway
                name: Doorway
                use_light_color: true

          - type: custom:mushroom-title-card
            title: Climate History

          - type: custom:mini-graph-card
            entities:
              - entity: sensor.hallway_sensor_temperature
                name: Temperature
                color: "#f44336"
              - entity: sensor.hallway_sensor_humidity
                name: Humidity
                color: "#2196f3"
                y_axis: secondary
            hours_to_show: 24
            points_per_hour: 4
            line_width: 2
            show:
              labels: true
              legend: true

      # ==================== ROBYNNE'S ROOM ====================
      - title: Robynne's Room
        path: robynne
        icon: mdi:teddy-bear
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: Robynne's Room
            subtitle: Lights & Media

          # Status chips
          - type: custom:mushroom-chips-card
            chips:
              - type: template
                entity: group.robynne_lights
                icon: mdi:lightbulb
                icon_color: "{% if is_state('group.robynne_lights', 'on') %}pink{% else %}disabled{% endif %}"
                content: >
                  {% set entities = state_attr('group.robynne_lights', 'entity_id') | default([]) %}
                  {% set on = entities | select('is_state', 'on') | list | count %}
                  {{ on }} on
              - type: template
                entity: media_player.yoto_player
                icon: mdi:music
                icon_color: "{% if is_state('media_player.yoto_player', 'playing') %}green{% else %}disabled{% endif %}"
                content: "{% if is_state('media_player.yoto_player', 'playing') %}Playing{% else %}Idle{% endif %}"
            alignment: center

          - type: horizontal-stack
            cards:
              - type: custom:mushroom-light-card
                entity: light.robynne_light
                name: Main Light
                use_light_color: true
              - type: custom:mushroom-light-card
                entity: light.fairy_lights_switch
                name: Fairy Lights
                use_light_color: true

          - type: custom:mushroom-title-card
            title: Yoto Player

          - type: custom:mushroom-media-player-card
            entity: media_player.yoto_player
            name: Yoto Player
            icon_type: icon
            use_media_info: true
            media_controls:
              - play_pause_stop
              - previous
              - next
            volume_controls:
              - volume_buttons

      # ==================== CAR ====================
      - title: Car
        path: car
        icon: mdi:car
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: Ford Puma
            subtitle: Vehicle Status

          - type: custom:mushroom-chips-card
            chips:
              - type: template
                entity: sensor.fordpass_wf02xxerk2la80437_fuel
                icon: mdi:gas-station
                icon_color: >
                  {% set fuel = states('sensor.fordpass_wf02xxerk2la80437_fuel') | float(0) %}
                  {% if fuel > 50 %}green{% elif fuel > 25 %}amber{% else %}red{% endif %}
                content: "{{ states('sensor.fordpass_wf02xxerk2la80437_fuel') }}%"
              - type: template
                entity: sensor.fordpass_wf02xxerk2la80437_battery
                icon: mdi:car-battery
                icon_color: >
                  {% set batt = states('sensor.fordpass_wf02xxerk2la80437_battery') | float(0) %}
                  {% if batt > 50 %}green{% elif batt > 25 %}amber{% else %}red{% endif %}
                content: "{{ states('sensor.fordpass_wf02xxerk2la80437_battery') }}%"
              - type: template
                entity: sensor.fordpass_wf02xxerk2la80437_oil
                icon: mdi:oil
                icon_color: >
                  {% set oil = states('sensor.fordpass_wf02xxerk2la80437_oil') | float(0) %}
                  {% if oil > 50 %}green{% elif oil > 25 %}amber{% else %}red{% endif %}
                content: "{{ states('sensor.fordpass_wf02xxerk2la80437_oil') }}%"
            alignment: center

          - type: custom:mushroom-template-card
            entity: sensor.fordpass_wf02xxerk2la80437_doorstatus
            primary: Doors
            secondary: "{{ states('sensor.fordpass_wf02xxerk2la80437_doorstatus') }}"
            icon: mdi:car-door
            icon_color: >
              {% if is_state('sensor.fordpass_wf02xxerk2la80437_doorstatus', 'Closed') %}green{% else %}red{% endif %}

          - type: custom:mushroom-template-card
            entity: sensor.fordpass_wf02xxerk2la80437_windowposition
            primary: Windows
            secondary: "{{ states('sensor.fordpass_wf02xxerk2la80437_windowposition') }}"
            icon: mdi:car-door
            icon_color: >
              {% if is_state('sensor.fordpass_wf02xxerk2la80437_windowposition', 'Closed') %}green{% else %}red{% endif %}

          - type: custom:mushroom-template-card
            entity: device_tracker.fordpass_wf02xxerk2la80437_tracker
            primary: Location
            secondary: "{{ states('device_tracker.fordpass_wf02xxerk2la80437_tracker') }}"
            icon: mdi:map-marker
            icon_color: blue
            tap_action:
              action: more-info

          - type: custom:mushroom-title-card
            title: Controls

          - type: horizontal-stack
            cards:
              - type: custom:mushroom-template-card
                primary: Lock
                icon: mdi:car-door-lock
                icon_color: green
                tap_action:
                  action: call-service
                  service: button.press
                  target:
                    entity_id: button.fordpass_wf02xxerk2la80437_doorlock
              - type: custom:mushroom-template-card
                primary: Unlock
                icon: mdi:car-door-lock-open
                icon_color: red
                tap_action:
                  action: call-service
                  service: button.press
                  target:
                    entity_id: button.fordpass_wf02xxerk2la80437_doorunlock
              - type: custom:mushroom-template-card
                primary: Refresh
                icon: mdi:refresh
                icon_color: blue
                tap_action:
                  action: call-service
                  service: button.press
                  target:
                    entity_id: button.fordpass_wf02xxerk2la80437_request_refresh

      # ==================== FISH ====================
      - title: Fish
        path: fish
        icon: mdi:fish
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: Aquarium
            subtitle: Water Parameters

          # Key metrics as chips
          - type: custom:mushroom-chips-card
            chips:
              - type: template
                entity: sensor.current_temperature
                icon: mdi:thermometer
                icon_color: >
                  {% set temp = states('sensor.current_temperature') | float(0) %}
                  {% if temp < 22 or temp > 28 %}red{% elif temp < 24 or temp > 26 %}orange{% else %}green{% endif %}
                content: "{{ states('sensor.current_temperature') }}°C"
              - type: template
                entity: sensor.ph_value
                icon: mdi:ph
                icon_color: >
                  {% set ph = states('sensor.ph_value') | float(0) %}
                  {% if ph < 6.5 or ph > 8.5 %}red{% elif ph < 7 or ph > 8 %}orange{% else %}green{% endif %}
                content: "pH {{ states('sensor.ph_value') }}"
            alignment: center

          # Modern circular gauges for key parameters
          - type: horizontal-stack
            cards:
              - type: custom:modern-circular-gauge
                entity: sensor.current_temperature
                name: Temperature
                min: 20
                max: 30
                inner:
                  color_stops:
                    "20": "#2196f3"
                    "24": "#4caf50"
                    "26": "#ff9800"
                    "28": "#f44336"
              - type: custom:modern-circular-gauge
                entity: sensor.ph_value
                name: pH
                min: 6
                max: 9
                inner:
                  color_stops:
                    "6": "#f44336"
                    "6.5": "#ff9800"
                    "7": "#4caf50"
                    "8": "#ff9800"
                    "8.5": "#f44336"

          # Other parameters grid
          - type: grid
            columns: 2
            square: false
            cards:
              - type: custom:mushroom-entity-card
                entity: sensor.tds_value
                name: TDS
                icon: mdi:water-opacity
                icon_color: teal

              - type: custom:mushroom-entity-card
                entity: sensor.ec_value
                name: Conductivity
                icon: mdi:flash
                icon_color: amber

              - type: custom:mushroom-entity-card
                entity: sensor.salinity_value
                name: Salinity
                icon: mdi:shaker-outline
                icon_color: cyan

              - type: custom:mushroom-entity-card
                entity: sensor.orp_value
                name: ORP
                icon: mdi:molecule
                icon_color: green

              - type: custom:mushroom-entity-card
                entity: sensor.proportion_value
                name: Specific Gravity
                icon: mdi:weight
                icon_color: indigo

              - type: custom:mushroom-entity-card
                entity: sensor.cf
                name: CF
                icon: mdi:water-percent
                icon_color: light-blue

          # History Graphs with ApexCharts
          - type: custom:mushroom-title-card
            title: History
            subtitle: Last 24 hours

          - type: custom:apexcharts-card
            header:
              show: true
              title: Temperature
              show_states: true
              colorize_states: true
            graph_span: 24h
            series:
              - entity: sensor.current_temperature
                name: Temperature
                stroke_width: 2
                color: "#2196f3"
            apex_config:
              chart:
                height: 180
              yaxis:
                min: 22
                max: 28

          - type: custom:apexcharts-card
            header:
              show: true
              title: Water Quality
              show_states: true
            graph_span: 24h
            series:
              - entity: sensor.ph_value
                name: pH
                stroke_width: 2
                color: "#9c27b0"
              - entity: sensor.tds_value
                name: TDS
                stroke_width: 2
                color: "#009688"
            apex_config:
              chart:
                height: 180

      # ==================== ENERGY ====================
      - title: Energy
        path: energy
        icon: mdi:lightning-bolt
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: Energy
            subtitle: Octopus Energy

          # Current rate chips
          - type: custom:mushroom-chips-card
            chips:
              - type: template
                entity: sensor.octopus_energy_electricity_16k0150212_2500001111806_current_rate
                icon: mdi:currency-gbp
                icon_color: >
                  {% set rate = states('sensor.octopus_energy_electricity_16k0150212_2500001111806_current_rate') | float(0) %}
                  {% if rate < 15 %}green{% elif rate < 25 %}amber{% else %}red{% endif %}
                content: "{{ states('sensor.octopus_energy_electricity_16k0150212_2500001111806_current_rate') | round(2) }}p/kWh"
            alignment: center

          - type: custom:apexcharts-card
            header:
              show: true
              title: Electricity Rate (Today)
              show_states: true
              colorize_states: true
            graph_span: 24h
            span:
              start: day
            series:
              - entity: sensor.octopus_energy_electricity_16k0150212_2500001111806_current_rate
                name: Rate
                type: area
                stroke_width: 2
                color: "#4caf50"
                opacity: 0.3
            apex_config:
              chart:
                height: 200
              yaxis:
                decimalsInFloat: 1

      # ==================== SYSTEM ====================
      - title: System
        path: system
        icon: mdi:cog
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: System
            subtitle: Monitoring & Status

          # System Load chips
          - type: custom:mushroom-chips-card
            chips:
              - type: template
                entity: sensor.system_monitor_load_1m
                icon: mdi:chip
                icon_color: >
                  {% set load = states('sensor.system_monitor_load_1m') | float(0) %}
                  {% if load > 2 %}red{% elif load > 1 %}orange{% else %}green{% endif %}
                content: "Load: {{ states('sensor.system_monitor_load_1m') }}"
              - type: template
                entity: sensor.system_monitor_disk_free
                icon: mdi:harddisk
                icon_color: >
                  {% set free = states('sensor.system_monitor_disk_free') | float(0) %}
                  {% if free < 10 %}red{% elif free < 50 %}orange{% else %}green{% endif %}
                content: "{{ states('sensor.system_monitor_disk_free') | round(0) }} GB free"
              - type: template
                entity: sensor.entities
                icon: mdi:format-list-bulleted
                icon_color: blue
                content: "{{ states('sensor.entities') }} entities"
            alignment: center

          # System gauges
          - type: horizontal-stack
            cards:
              - type: custom:modern-circular-gauge
                entity: sensor.system_monitor_load_1m
                name: Load (1m)
                min: 0
                max: 4
                inner:
                  color_stops:
                    "0": "#4caf50"
                    "1": "#ff9800"
                    "2": "#f44336"
              - type: custom:modern-circular-gauge
                entity: sensor.system_monitor_disk_use_percent
                name: Disk
                min: 0
                max: 100
                inner:
                  color_stops:
                    "0": "#4caf50"
                    "70": "#ff9800"
                    "90": "#f44336"

          # Home Assistant Stats
          - type: custom:mushroom-title-card
            title: Home Assistant

          - type: horizontal-stack
            cards:
              - type: custom:mushroom-entity-card
                entity: sensor.integrations
                name: Integrations
                icon: mdi:puzzle
                icon_color: purple
              - type: custom:mushroom-entity-card
                entity: sensor.automations
                name: Automations
                icon: mdi:robot
                icon_color: blue
              - type: custom:mushroom-entity-card
                entity: sensor.devices
                name: Devices
                icon: mdi:devices
                icon_color: teal

          # Low Battery Section
          - type: custom:mushroom-title-card
            title: Low Battery
            subtitle: Devices below 30%

          - type: custom:auto-entities
            card:
              type: grid
              columns: 2
              square: false
            card_param: cards
            filter:
              include:
                - entity_id: "sensor.*battery*"
                  state: "< 30"
                  not:
                    state: unavailable
                  options:
                    type: custom:mushroom-entity-card
                    icon_color: >
                      {% set batt = states(config.entity) | float(0) %}
                      {% if batt < 10 %}red{% elif batt < 20 %}orange{% else %}amber{% endif %}
              exclude:
                - state: unavailable
                - state: unknown
            sort:
              method: state
              numeric: true
            show_empty: true
            unique: true

          # Unavailable Devices
          - type: custom:mushroom-title-card
            title: Unavailable
            subtitle: Offline devices

          - type: custom:auto-entities
            card:
              type: grid
              columns: 2
              square: false
            card_param: cards
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
                - state: unavailable
                  domain: binary_sensor
                  entity_id: "*door*"
                  options:
                    type: custom:mushroom-entity-card
                    icon_color: red
                - state: unavailable
                  domain: binary_sensor
                  entity_id: "*motion*"
                  options:
                    type: custom:mushroom-entity-card
                    icon_color: red
            sort:
              method: friendly_name
            show_empty: true
            unique: true

          # History Graphs
          - type: custom:mushroom-title-card
            title: History
            subtitle: System load over time

          - type: custom:apexcharts-card
            header:
              show: true
              title: System Load
              show_states: true
            graph_span: 24h
            series:
              - entity: sensor.system_monitor_load_1m
                name: 1m
                stroke_width: 2
                color: "#f44336"
              - entity: sensor.system_monitor_load_5m
                name: 5m
                stroke_width: 2
                color: "#ff9800"
              - entity: sensor.system_monitor_load_15m
                name: 15m
                stroke_width: 2
                color: "#4caf50"
            apex_config:
              chart:
                height: 200

          # Quick Actions
          - type: custom:mushroom-title-card
            title: Actions

          - type: horizontal-stack
            cards:
              - type: custom:mushroom-template-card
                primary: Restart HA
                icon: mdi:restart
                icon_color: red
                tap_action:
                  action: call-service
                  service: button.press
                  target:
                    entity_id: button.homeassistant_restart
                  confirmation:
                    text: Are you sure you want to restart Home Assistant?
              - type: custom:mushroom-template-card
                primary: Reload
                icon: mdi:reload
                icon_color: orange
                tap_action:
                  action: call-service
                  service: button.press
                  target:
                    entity_id: button.homeassistant_reload
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
          title = "Home";
          icon = "mdi:home-assistant";
          show_in_sidebar = true;
          require_admin = false;
        };
      };
    };
  };
}
