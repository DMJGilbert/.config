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
                  navigation_path: /lovelace-home/living-room
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
                  navigation_path: /lovelace-home/bedroom

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
                  navigation_path: /lovelace-home/bathroom
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
                  navigation_path: /lovelace-home/kitchen

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
                  navigation_path: /lovelace-home/hallway

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
                  navigation_path: /lovelace-home/robynne
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
                icon_color: amber
                content: "{{ states('sensor.fordpass_wf02xxerk2la80437_fuel') }}%"
              - type: template
                entity: sensor.fordpass_wf02xxerk2la80437_battery
                icon: mdi:car-battery
                icon_color: green
                content: "{{ states('sensor.fordpass_wf02xxerk2la80437_battery') }}%"
              - type: template
                entity: sensor.fordpass_wf02xxerk2la80437_oil
                icon: mdi:oil
                icon_color: orange
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

          - type: custom:mushroom-chips-card
            chips:
              - type: template
                entity: sensor.current_temperature
                icon: mdi:thermometer
                icon_color: >
                  {% set temp = states('sensor.current_temperature') | float %}
                  {% if temp < 22 or temp > 28 %}red{% elif temp < 24 or temp > 26 %}orange{% else %}green{% endif %}
                content: "{{ states('sensor.current_temperature') }}°C"
              - type: template
                entity: sensor.ph_value
                icon: mdi:ph
                icon_color: >
                  {% set ph = states('sensor.ph_value') | float %}
                  {% if ph < 6.5 or ph > 8.5 %}red{% elif ph < 7 or ph > 8 %}orange{% else %}green{% endif %}
                content: "pH {{ states('sensor.ph_value') }}"
            alignment: center

          - type: grid
            columns: 2
            square: false
            cards:
              - type: custom:mushroom-entity-card
                entity: sensor.current_temperature
                name: Temperature
                icon: mdi:thermometer-water
                icon_color: blue

              - type: custom:mushroom-entity-card
                entity: sensor.ph_value
                name: pH Level
                icon: mdi:ph
                icon_color: purple

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

          # History Graphs
          - type: custom:mushroom-title-card
            title: History
            subtitle: Last 24 hours

          - type: history-graph
            hours_to_show: 24
            entities:
              - entity: sensor.current_temperature
                name: Temperature

          - type: history-graph
            hours_to_show: 24
            entities:
              - entity: sensor.ph_value
                name: pH

          - type: history-graph
            hours_to_show: 24
            entities:
              - entity: sensor.tds_value
                name: TDS
              - entity: sensor.ec_value
                name: EC

      # ==================== SYSTEM ====================
      - title: System
        path: system
        icon: mdi:cog
        type: custom:vertical-layout
        cards:
          - type: custom:mushroom-title-card
            title: System
            subtitle: Monitoring & Status

          # System Load
          - type: custom:mushroom-chips-card
            chips:
              - type: template
                entity: sensor.system_monitor_load_1m
                icon: mdi:chip
                icon_color: >
                  {% set load = states('sensor.system_monitor_load_1m') | float %}
                  {% if load > 2 %}red{% elif load > 1 %}orange{% else %}green{% endif %}
                content: "Load: {{ states('sensor.system_monitor_load_1m') }}"
              - type: template
                entity: sensor.system_monitor_disk_free
                icon: mdi:harddisk
                icon_color: >
                  {% set free = states('sensor.system_monitor_disk_free') | float %}
                  {% if free < 10 %}red{% elif free < 50 %}orange{% else %}green{% endif %}
                content: "{{ states('sensor.system_monitor_disk_free') | round(0) }} GB free"
              - type: template
                entity: sensor.entities
                icon: mdi:format-list-bulleted
                icon_color: blue
                content: "{{ states('sensor.entities') }} entities"
            alignment: center

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

          # Updates Available
          - type: custom:mushroom-title-card
            title: Updates
            subtitle: Available updates

          - type: custom:mushroom-entity-card
            entity: sensor.update
            name: Pending Updates
            icon: mdi:update
            icon_color: >
              {% if states('sensor.update') | int > 0 %}orange{% else %}green{% endif %}

          # History Graphs
          - type: custom:mushroom-title-card
            title: History
            subtitle: System load over time

          - type: history-graph
            hours_to_show: 24
            entities:
              - entity: sensor.system_monitor_load_1m
                name: Load (1m)
              - entity: sensor.system_monitor_load_5m
                name: Load (5m)
              - entity: sensor.system_monitor_load_15m
                name: Load (15m)

          - type: history-graph
            hours_to_show: 168
            entities:
              - entity: sensor.system_monitor_disk_free
                name: Disk Free

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
