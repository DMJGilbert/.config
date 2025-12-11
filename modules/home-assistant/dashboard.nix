{pkgs, ...}: let
  dashboardYaml = pkgs.writeText "hacasa.yaml" ''
    title: Home
    views:
      # ==================== HOME ====================
      - title: Home
        path: home
        icon: mdi:home
        type: custom:vertical-layout
        cards:
          # Header
          - type: custom:mushroom-title-card
            title: |
              {% set h = now().hour %}
              {% if h < 12 %}Good Morning{% elif h < 18 %}Good Afternoon{% else %}Good Evening{% endif %}
            subtitle: "{{ now().strftime('%A %d %B') }}"

          # People
          - type: horizontal-stack
            cards:
              - type: custom:mushroom-person-card
                entity: person.darren_gilbert
                icon_type: entity-picture
                layout: horizontal
                primary_info: name
                secondary_info: state
              - type: custom:mushroom-person-card
                entity: person.lorraine
                icon_type: entity-picture
                layout: horizontal
                primary_info: name
                secondary_info: state

          # Stats chips
          - type: custom:mushroom-chips-card
            chips:
              - type: weather
                entity: weather.forecast_home
                show_conditions: true
                show_temperature: true
              - type: template
                icon: mdi:lightbulb-group
                icon_color: amber
                content: "{{ states('sensor.total_turned_on_lights_count_template') }} lights"
              - type: template
                icon: mdi:motion-sensor
                icon_color: blue
                content: "{{ states('sensor.total_active_motion_sensors_count_template') }} motion"
              - type: template
                icon: mdi:thermometer
                icon_color: red
                content: >
                  {% set temps = [
                    states('sensor.hallway_sensor_temperature'),
                    states('sensor.bathroom_sensor_temperature'),
                    states('sensor.dyson_temperature'),
                    states('sensor.aarlo_temperature_nursery')
                  ] | reject('in', ['unavailable', 'unknown']) | map('float') | list %}
                  {% if temps %}{{ (temps | sum / temps | length) | round(1) }}°{% else %}--{% endif %}
            alignment: center

          # Football Match
          - type: custom:mushroom-template-card
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
                  {{ a.team_abbr }} {{ a.team_score }} - {{ a.opponent_score }} {{ a.opponent_abbr }}
                {% else %}
                  {{ a.team_abbr }} vs {{ a.opponent_abbr }}
                {% endif %}
              {% else %}
                No upcoming matches
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
                {% if ns.match.state == 'IN' %}
                  LIVE - {{ a.league }}
                {% else %}
                  {{ a.date | as_datetime | as_local | as_timestamp | timestamp_custom('%a %d %b, %H:%M') }} - {{ a.league }}
                {% endif %}
              {% else %}
              {% endif %}
            icon: mdi:soccer
            icon_color: >
              {% if is_state('sensor.liverpool', 'IN') %}green{% else %}deep-purple{% endif %}
            tap_action:
              action: more-info

          # Rooms Section
          - type: custom:mushroom-title-card
            title: Rooms

          - type: grid
            columns: 2
            square: false
            cards:
              - type: custom:mushroom-template-card
                entity: group.living_room_lights
                primary: Living Room
                secondary: >
                  {% set entities = state_attr('group.living_room_lights', 'entity_id') | default([]) %}
                  {% set on = entities | select('is_state', 'on') | list | count %}
                  {{ on }} lights on
                icon: mdi:sofa
                icon_color: >
                  {% set entities = state_attr('group.living_room_lights', 'entity_id') | default([]) %}
                  {% set on = entities | select('is_state', 'on') | list | count %}
                  {% if on > 0 %}amber{% else %}grey{% endif %}
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/living-room
                badge_icon: >
                  {% if is_state('media_player.living_room_tv', 'playing') or is_state('media_player.living_room_tv', 'on') %}
                    mdi:television
                  {% endif %}
                badge_color: green

              - type: custom:mushroom-template-card
                entity: group.bedroom_lights
                primary: Bedroom
                secondary: >
                  {% set entities = state_attr('group.bedroom_lights', 'entity_id') | default([]) %}
                  {% set on = entities | select('is_state', 'on') | list | count %}
                  {{ on }} lights on
                icon: mdi:bed
                icon_color: >
                  {% set entities = state_attr('group.bedroom_lights', 'entity_id') | default([]) %}
                  {% set on = entities | select('is_state', 'on') | list | count %}
                  {% if on > 0 %}deep-purple{% else %}grey{% endif %}
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/bedroom

              - type: custom:mushroom-template-card
                entity: group.bathroom_lights
                primary: Bathroom
                secondary: >
                  {{ states('sensor.bathroom_sensor_temperature') | round(1) }}°C • {{ states('sensor.bathroom_sensor_humidity') | round(0) }}%
                icon: mdi:shower
                icon_color: >
                  {% if is_state('binary_sensor.motion_sensor_motion', 'on') %}blue{% else %}grey{% endif %}
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/bathroom
                badge_icon: >
                  {% if is_state('binary_sensor.motion_sensor_motion', 'on') %}mdi:motion-sensor{% endif %}
                badge_color: blue

              - type: custom:mushroom-template-card
                entity: group.kitchen_lights
                primary: Kitchen
                secondary: >
                  {% set entities = state_attr('group.kitchen_lights', 'entity_id') | default([]) %}
                  {% set on = entities | select('is_state', 'on') | list | count %}
                  {{ on }} lights on
                icon: mdi:silverware-fork-knife
                icon_color: >
                  {% set entities = state_attr('group.kitchen_lights', 'entity_id') | default([]) %}
                  {% set on = entities | select('is_state', 'on') | list | count %}
                  {% if on > 0 %}amber{% else %}grey{% endif %}
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/kitchen

              - type: custom:mushroom-template-card
                entity: group.hallway_lights
                primary: Hallway
                secondary: "{{ states('sensor.hallway_sensor_temperature') | round(1) }}°C"
                icon: mdi:door
                icon_color: >
                  {% set entities = state_attr('group.hallway_lights', 'entity_id') | default([]) %}
                  {% set on = entities | select('is_state', 'on') | list | count %}
                  {% if on > 0 %}amber{% else %}grey{% endif %}
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/hallway

              - type: custom:mushroom-template-card
                entity: group.robynne_lights
                primary: Robynne's Room
                secondary: >
                  {% if is_state('media_player.yoto_player', 'playing') %}
                    Yoto playing
                  {% else %}
                    {% set entities = state_attr('group.robynne_lights', 'entity_id') | default([]) %}
                    {% set on = entities | select('is_state', 'on') | list | count %}
                    {{ on }} lights on
                  {% endif %}
                icon: mdi:teddy-bear
                icon_color: >
                  {% if is_state('media_player.yoto_player', 'playing') %}green{% else %}pink{% endif %}
                tap_action:
                  action: navigate
                  navigation_path: /lovelace-hacasa/robynne
                badge_icon: >
                  {% if is_state('media_player.yoto_player', 'playing') %}mdi:music{% endif %}
                badge_color: green

          # Scenes Section
          - type: custom:mushroom-title-card
            title: Scenes

          - type: horizontal-stack
            cards:
              - type: custom:mushroom-template-card
                primary: All Off
                icon: mdi:power
                icon_color: red
                tap_action:
                  action: call-service
                  service: light.turn_off
                  target:
                    entity_id: all
              - type: custom:mushroom-template-card
                entity: input_boolean.party_mode
                primary: Party
                icon: mdi:party-popper
                icon_color: "{% if is_state('input_boolean.party_mode', 'on') %}deep-purple{% else %}grey{% endif %}"
                tap_action:
                  action: toggle
              - type: custom:mushroom-template-card
                primary: Movie
                icon: mdi:movie
                icon_color: blue
                tap_action:
                  action: call-service
                  service: scene.turn_on
                  target:
                    entity_id: scene.movie
              - type: custom:mushroom-template-card
                primary: Bright
                icon: mdi:brightness-7
                icon_color: amber
                tap_action:
                  action: call-service
                  service: light.turn_on
                  target:
                    entity_id: all
                  data:
                    brightness: 255

          # RoboVac Section
          - type: custom:mushroom-title-card
            title: RoboVac

          - type: custom:mushroom-vacuum-card
            entity: vacuum.robovac
            icon_animation: true
            commands:
              - start_pause
              - stop
              - return_home
              - locate

          # Media Section
          - type: custom:mushroom-title-card
            title: Media

          - type: horizontal-stack
            cards:
              - type: custom:mushroom-media-player-card
                entity: media_player.living_room_tv
                icon_type: entity-picture
                use_media_info: true
                show_volume_level: false
                collapsible_controls: true
              - type: custom:mushroom-media-player-card
                entity: media_player.apple_tv
                icon_type: entity-picture
                use_media_info: true
                show_volume_level: false
                collapsible_controls: true

      # ==================== LIVING ROOM ====================
      - title: Living Room
        path: living-room
        icon: mdi:sofa
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: Living Room
            subtitle: Lights & Climate

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

          - type: custom:mushroom-title-card
            title: Climate

          - type: custom:mushroom-chips-card
            chips:
              - type: template
                entity: fan.dyson
                icon: mdi:fan
                icon_color: "{% if is_state('fan.dyson', 'on') %}blue{% else %}grey{% endif %}"
                content: >
                  {% if is_state('fan.dyson', 'on') %}
                    {{ state_attr('fan.dyson', 'percentage') | default(0) }}%
                  {% else %}
                    Off
                  {% endif %}
                tap_action:
                  action: toggle
              - type: template
                entity: sensor.dyson_temperature
                icon: mdi:thermometer
                icon_color: red
                content: "{{ states('sensor.dyson_temperature') }}°"

      # ==================== BEDROOM ====================
      - title: Bedroom
        path: bedroom
        icon: mdi:bed
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: Bedroom
            subtitle: Lights & Media

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

      # ==================== BATHROOM ====================
      - title: Bathroom
        path: bathroom
        icon: mdi:shower
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: Bathroom
            subtitle: Lights & Climate

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
                icon_color: blue
                content: "{{ states('sensor.bathroom_sensor_humidity') | round(0) }}%"

      # ==================== KITCHEN ====================
      - title: Kitchen
        path: kitchen
        icon: mdi:silverware-fork-knife
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: Kitchen
            subtitle: Lights

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

      # ==================== ROBYNNE'S ROOM ====================
      - title: Robynne's Room
        path: robynne
        icon: mdi:teddy-bear
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: Robynne's Room
            subtitle: Lights & Media

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
