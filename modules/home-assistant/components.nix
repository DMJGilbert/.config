{pkgs, ...}: {
  systemd.tmpfiles.rules = [
    "f /var/lib/hass/custom_components/fordpass/dmjgilbert@me.com_fordpass_token.txt 0777 hass hass"
  ];
  services.home-assistant.extraComponents = [
    "esphome"
    "met"
    "google_translate"
    "calendar"
    "caldav"
    "tradfri"
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
  ];
  services.home-assistant.customComponents = [
    pkgs.home-assistant-custom-components.spook
    pkgs.home-assistant-custom-components.localtuya
    (pkgs.buildHomeAssistantComponent rec {
      owner = "AlexxIT";
      domain = "sonoff";
      version = "3.8.1";
      src = pkgs.fetchFromGitHub {
        owner = "AlexxIT";
        repo = "SonoffLAN";
        rev = "v${version}";
        sha256 = "sha256-dxwrJeAo5DsLC14GGI4MJ+cY5pXVD9M1gi0TW2eQtb0=";
      };
      propagatedBuildInputs = [
        pkgs.python312Packages.pycryptodome
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
        pkgs.python312Packages.pycryptodome
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
        pkgs.python312Packages.pycryptodome
      ];
    })
    (pkgs.buildHomeAssistantComponent rec {
      owner = "AlexandrErohin";
      domain = "tplink_router";
      version = "1.19.0";
      src = pkgs.fetchFromGitHub {
        owner = "AlexandrErohin";
        repo = "home-assistant-tplink-router";
        rev = "v${version}";
        sha256 = "sha256-UEsgDELff5xH4kefnM1hV1g9uheXRWRGcMaj+wjuzl0=";
      };
      propagatedBuildInputs = [
        pkgs.python312Packages.pycryptodome
        (
          pkgs.python3.pkgs.buildPythonPackage rec {
            pname = "tplinkrouterc6u";
            version = "4.2.3";
            pyproject = true;
            src = pkgs.fetchPypi {
              inherit pname version;
              hash = "sha256-+M7OHSR+bqti9uWAIsclYHmbZr4A7KA8+daCk//WXtE=";
            };
            propagatedBuildInputs = with pkgs.python3Packages; [
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
      version = "13.0.3";
      src = pkgs.fetchFromGitHub {
        owner = "BottlecapDave";
        repo = "HomeAssistant-OctopusEnergy";
        rev = "v${version}";
        sha256 = "sha256-uKApToM80IZM+nQqN1qn1sFNLznY92Bf0aoR3oE0siA=";
      };
    })
    (pkgs.buildHomeAssistantComponent {
      owner = "itchannel";
      domain = "fordpass";
      version = "1.70";
      src = pkgs.fetchFromGitHub {
        owner = "TheLizard";
        repo = "fordpass-ha";
        rev = "82471007394e6961627929ab004216807726ad1f";
        sha256 = "sha256-MB9d0Wl7cSamZbe7Te6/4C9Xebo3vsp3PDQUnK0aqks=";
      };
      postInstall = ''
        ln -s /tmp/dmjgilbert@me.com_fordpass_token.txt $out/custom_components/fordpass/dmjgilbert@me.com_fordpass_token.txt
      '';
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
        pkgs.python312Packages.unidecode
        (
          pkgs.python3.pkgs.buildPythonPackage rec {
            pname = "pyaarlo";
            version = "0.8.0.7";
            pyproject = true;
            src = pkgs.fetchPypi {
              inherit pname version;
              hash = "sha256-mhlSdFNznDj9WqDr6o71f0EBUThZUSXsJH259mSBzrM=";
            };
            propagatedBuildInputs = with pkgs.python3Packages; [
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
