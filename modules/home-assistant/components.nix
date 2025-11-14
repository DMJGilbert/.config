{pkgs, ...}: {
  # Token file no longer needed with marq24's ha-fordpass integration
  # systemd.tmpfiles.rules = [
  #   "f /var/lib/hass/custom_components/fordpass/dmjgilbert@me.com_fordpass_token.txt 0777 hass hass"
  # ];
  services.home-assistant.extraComponents = [
    "esphome"
    "met"
    "google_translate"
    "calendar"
    "caldav"
    # "tradfri"
    "radio_browser"
    "light"
    "blueprint"
    "lovelace"
    "tailscale"
    "adguard"
    "bluetooth"
    "automation"
    "tplink"
    "onvif"
    "hue"
    "apple_tv"
    "itunes"
    "weatherkit"
    "webostv"
    "homekit"
    "homekit_controller"
    "zeroconf"
    "tuya"
    "twinkly"
    "zha"
    "icloud"
    "systemmonitor"
    "energy"
  ];
  services.home-assistant.customComponents = [
    pkgs.home-assistant-custom-components.spook
    pkgs.home-assistant-custom-components.localtuya
    pkgs.home-assistant-custom-components.yoto_ha
    pkgs.home-assistant-custom-components.adaptive_lighting
    (pkgs.buildHomeAssistantComponent rec {
      owner = "AlexxIT";
      domain = "sonoff";
      version = "3.8.2";
      src = pkgs.fetchFromGitHub {
        owner = "AlexxIT";
        repo = "SonoffLAN";
        rev = "v${version}";
        sha256 = "sha256-U5fFuG4KZNenfKoDBe7GV1IbV8XRtUtuTWEQks+Lo+Q=";
      };
      propagatedBuildInputs = [
        pkgs.python313Packages.pycryptodome
      ];
    })
    (pkgs.buildHomeAssistantComponent rec {
      owner = "amosyuen";
      domain = "tplink_deco";
      version = "3.6.2";
      src = pkgs.fetchFromGitHub {
        owner = "amosyuen";
        repo = "ha-tplink-deco";
        rev = "v${version}";
        sha256 = "sha256-RYj06jkkauzZsVQtDZ9VBWheRU25qwC7NaSzgOlwppA=";
      };
      propagatedBuildInputs = [
        pkgs.python313Packages.pycryptodome
      ];
    })
    (pkgs.buildHomeAssistantComponent {
      owner = "maximoei";
      domain = "robovac";
      version = "1.0.0";
      src = pkgs.fetchFromGitHub {
        owner = "maximoei";
        repo = "robovac";
        rev = "ca5ce8b5f65664899f0dc184d131b68021c2737b";
        sha256 = "sha256-xUha26YiSKY+5aRmZviHFqyPLUqOdN6/L/Ikcpe/YH0=";
      };
      propagatedBuildInputs = [
        pkgs.python313Packages.pycryptodome
      ];
    })
    (pkgs.buildHomeAssistantComponent rec {
      owner = "AlexandrErohin";
      domain = "tplink_router";
      version = "2.2.0";
      src = pkgs.fetchFromGitHub {
        owner = "AlexandrErohin";
        repo = "home-assistant-tplink-router";
        rev = "v${version}";
        sha256 = "sha256-wn5bZG4zHi9VbB6vXMOr+rRLMliOMbY4XgAB/NPjhb8=";
      };
      propagatedBuildInputs = [
        pkgs.python313Packages.pycryptodome
        (
          pkgs.python313.pkgs.buildPythonPackage rec {
            pname = "tplinkrouterc6u";
            version = "5.3.0";
            pyproject = true;
            src = pkgs.fetchPypi {
              inherit pname version;
              hash = "sha256-hB0ItV9pgwfWj+XyJ+FZKay8Qrja4EMTQJdJmi4bsto=";
            };
            propagatedBuildInputs = with pkgs.python313Packages; [
              setuptools
              pycryptodome
              requests
              macaddress
            ];
          }
        )
      ];
    })
    (pkgs.buildHomeAssistantComponent rec {
      owner = "BottlecapDave";
      domain = "octopus_energy";
      version = "13.5.3";
      src = pkgs.fetchFromGitHub {
        owner = "BottlecapDave";
        repo = "HomeAssistant-OctopusEnergy";
        rev = "v${version}";
        sha256 = "sha256-qkPHb4o6rwXvifT+1L/pmpmJy3Qv4+ZYlhMn/cDnYDA=";
      };
      propagatedBuildInputs = with pkgs.python313Packages; [
        pydantic
      ];
    })
    (pkgs.buildHomeAssistantComponent rec {
      owner = "marq24";
      domain = "fordpass";
      version = "2025.11.2";
      src = pkgs.fetchFromGitHub {
        owner = "marq24";
        repo = "ha-fordpass";
        rev = version;
        sha256 = "sha256-sjDy1okRD4ESwHAYiaQZQx7WVldm/7lsk/7zIIKVXpo=";
      };
    })
    (pkgs.buildHomeAssistantComponent rec {
      owner = "vasqued2";
      domain = "teamtracker";
      version = "0.14.9";
      src = pkgs.fetchFromGitHub {
        owner = "vasqued2";
        repo = "ha-teamtracker";
        rev = "v${version}";
        sha256 = "sha256-UCWsprFkoEtBnoiemegmqPMawJ1/j0bpWaz4qNVTt9k=";
      };
      propagatedBuildInputs = with pkgs.python313Packages; [
        arrow
        aiofiles
      ];
    })
    (pkgs.buildHomeAssistantComponent rec {
      owner = "libdyson-wg";
      domain = "dyson_local";
      version = "1.4.2";
      src = pkgs.fetchFromGitHub {
        owner = "libdyson-wg";
        repo = "ha-dyson";
        rev = "v${version}";
        sha256 = "sha256-JMtT4ZZleb3kMifXxrOVzBJpftp1B/eghhBujyRT3EM=";
      };
    })
    (pkgs.buildHomeAssistantComponent rec {
      owner = "twrecked";
      domain = "aarlo";
      version = "0.8.1.4";
      src = pkgs.fetchFromGitHub {
        owner = "twrecked";
        repo = "hass-aarlo";
        rev = "v${version}";
        sha256 = "sha256-IkHtTnDpAJhuRA+IHzqCgRcferKAmQJLKWHq6+r3SrE=";
      };
      propagatedBuildInputs = [
        pkgs.python313Packages.unidecode
        (
          pkgs.python313.pkgs.buildPythonPackage rec {
            pname = "pyaarlo";
            version = "0.8.0.7";
            pyproject = true;
            src = pkgs.fetchPypi {
              inherit pname version;
              hash = "sha256-mhlSdFNznDj9WqDr6o71f0EBUThZUSXsJH259mSBzrM=";
            };
            propagatedBuildInputs = with pkgs.python313Packages; [
              setuptools
              requests
              click
              pycryptodome
              unidecode
              cloudscraper
              paho-mqtt
              cryptography
            ];
          }
        )
      ];
    })
  ];
}
