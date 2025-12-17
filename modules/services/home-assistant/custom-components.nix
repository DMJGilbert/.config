# Home Assistant custom components (HACS-style)
# Extracted from default.nix for maintainability
{pkgs}: [
  pkgs.home-assistant-custom-components.spook
  pkgs.home-assistant-custom-components.localtuya
  pkgs.home-assistant-custom-components.yoto_ha
  pkgs.home-assistant-custom-components.adaptive_lighting
  (pkgs.buildHomeAssistantComponent rec {
    owner = "AlexxIT";
    domain = "sonoff";
    version = "3.9.3";
    src = pkgs.fetchFromGitHub {
      owner = "AlexxIT";
      repo = "SonoffLAN";
      rev = "v${version}";
      sha256 = "sha256-QqJIPyITFYGD8OkbRTh//F0PWY9BFyhBbJaNtSIQ9tA=";
    };
    propagatedBuildInputs = [
      pkgs.python313Packages.pycryptodome
    ];
  })
  (pkgs.buildHomeAssistantComponent rec {
    owner = "amosyuen";
    domain = "tplink_deco";
    version = "3.7.0";
    src = pkgs.fetchFromGitHub {
      owner = "amosyuen";
      repo = "ha-tplink-deco";
      rev = "v${version}";
      sha256 = "sha256-D0IuB0tbHW/KlYpwug01g0vq+Kpigm8urbpbxpFCUN0=";
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
    version = "2.14.1";
    src = pkgs.fetchFromGitHub {
      owner = "AlexandrErohin";
      repo = "home-assistant-tplink-router";
      rev = "v${version}";
      sha256 = "sha256-5lcyg/WjgXZ/abL50CT0FFpcvozSYIa79Vj/cYQe+aU=";
    };
    propagatedBuildInputs = [
      pkgs.python313Packages.pycryptodome
      (
        pkgs.python313.pkgs.buildPythonPackage rec {
          pname = "tplinkrouterc6u";
          version = "5.12.1";
          pyproject = true;
          src = pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-xcr7W1X2nSZQT1/dz4aMxEr+27d5JFdsBGsCCdxki6U=";
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
    version = "17.1.1";
    src = pkgs.fetchFromGitHub {
      owner = "BottlecapDave";
      repo = "HomeAssistant-OctopusEnergy";
      rev = "v${version}";
      sha256 = "sha256-L1LqH9QMasVCZdsnHpKdxYGpsc/2vaIPAbiYc6vVshM=";
    };
    propagatedBuildInputs = with pkgs.python313Packages; [
      pydantic
    ];
  })
  (pkgs.buildHomeAssistantComponent rec {
    owner = "marq24";
    domain = "fordpass";
    version = "2025.11.4";
    src = pkgs.fetchFromGitHub {
      owner = "marq24";
      repo = "ha-fordpass";
      rev = version;
      sha256 = "sha256-FdGPNfdA/x3bv3a1yaOlRdI8+EdXI1LoJFYWW4l/Dvg=";
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
    version = "1.5.7";
    src = pkgs.fetchFromGitHub {
      owner = "libdyson-wg";
      repo = "ha-dyson";
      rev = "v${version}";
      sha256 = "sha256-V5RCepikTDrjZwi6MfRislpV2F9jR1MqwWxTq0GPBp4=";
    };
  })
  (pkgs.buildHomeAssistantComponent rec {
    owner = "twrecked";
    domain = "aarlo";
    version = "0.8.1.19";
    src = pkgs.fetchFromGitHub {
      owner = "twrecked";
      repo = "hass-aarlo";
      rev = "v${version}";
      sha256 = "sha256-M5M/kNUzplv+PuVQAWy0wdw4XXgho67zcvmW9QAXxTk=";
    };
    propagatedBuildInputs = [
      pkgs.python313Packages.unidecode
      pkgs.python313Packages.aiofiles
      (
        pkgs.python313.pkgs.buildPythonPackage rec {
          pname = "pyaarlo";
          version = "0.8.0.17";
          pyproject = true;
          src = pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-a7/MnUfzatdNY4RolJd2EsEucDwVoFIXnsYOGtJSGZU=";
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
            aiofiles
            python-slugify
          ];
        }
      )
    ];
  })
]
