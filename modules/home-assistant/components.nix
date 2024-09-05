{pkgs, ...}: {
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
    "bluetooth"
    "automation"
    "tplink"
    "hue"
    "apple_tv"
    "itunes"
    "weatherkit"
    "webostv"
    "homekit"
    "homekit_controller"
    "zeroconf"
    "zha"
  ];
  services.home-assistant.customComponents = [
    pkgs.home-assistant-custom-components.spook
    pkgs.home-assistant-custom-components.localtuya
    # (pkgs.buildHomeAssistantComponent rec {
    #   owner = "amosyuen";
    #   domain = "tplink_deco";
    #   version = "3.6.2";
    #   src = pkgs.fetchFromGitHub {
    #     owner = "amosyuen";
    #     repo = "ha-tplink-deco";
    #     rev = "v${version}";
    #     sha256 = "sha256-RYj06jkkauzZsVQtDZ9VBWheRU25qwC7NaSzgOlwppA=";
    #   };
    #   propagatedBuildInputs = [
    #     pkgs.python312Packages.pycryptodome
    #   ];
    # })
    (pkgs.buildHomeAssistantComponent rec {
      owner = "AlexandrErohin";
      domain = "tplink_router";
      version = "1.15.1";
      src = pkgs.fetchFromGitHub {
        owner = "AlexandrErohin";
        repo = "home-assistant-tplink-router";
        rev = "v${version}";
        sha256 = "sha256-kvNNWOILoByaQNeU0tcPCJPXJxS+Eo6cbmTJ9D2Y+AY=";
      };
      propagatedBuildInputs = [
        pkgs.python312Packages.pycryptodome
        (
          pkgs.python3.pkgs.buildPythonPackage rec {
            pname = "tplinkrouterc6u";
            version = "4.1.1";
            pyproject = true;
            src = pkgs.fetchPypi {
              inherit pname version;
              hash = "sha256-KEtHCVHlvau49xJ2l6gpAOD/CQv/r9eKSoWWTaabW2g=";
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
      version = "12.1.0";
      src = pkgs.fetchFromGitHub {
        owner = "BottlecapDave";
        repo = "HomeAssistant-OctopusEnergy";
        rev = "v${version}";
        sha256 = "sha256-LCYj3ik+qop/A6KtqWg5PL5/lxu/wRgsO5dcl5yZpXg=";
      };
    })
    (pkgs.buildHomeAssistantComponent rec {
      owner = "itchannel";
      domain = "fordpass";
      version = "1.70";
      src = pkgs.fetchFromGitHub {
        owner = "itchannel";
        repo = "fordpass-ha";
        rev = "${version}";
        sha256 = "sha256-Xs6Mlw2k1irZlRLG6dj1S963ufU28amVT3PaJ+lPJN8=";
      };
    })
    (pkgs.buildHomeAssistantComponent rec {
      owner = "libdyson-wg";
      domain = "dyson_local";
      version = "1.3.11";
      src = pkgs.fetchFromGitHub {
        owner = "libdyson-wg";
        repo = "ha-dyson";
        rev = "v${version}";
        sha256 = "sha256-NWHMc70TA2QYmMHf8skY6aIkRs4iP+1NDURQDhi2yGc=";
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
