# Home Assistant custom components (HACS-style)
# Extracted from default.nix for maintainability
{pkgs}: let
  haPython = pkgs.home-assistant.python.pkgs;
in [
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
      haPython.pycryptodome
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
      haPython.pycryptodome
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
    propagatedBuildInputs = with haPython; [
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
    propagatedBuildInputs = with haPython; [
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
  # UK Carbon Intensity - same developer as OctopusEnergy, pairs well with it
  (pkgs.buildHomeAssistantComponent rec {
    owner = "BottlecapDave";
    domain = "carbon_intensity";
    version = "4.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "BottlecapDave";
      repo = "HomeAssistant-CarbonIntensity";
      rev = "v${version}";
      sha256 = "sha256-n8BEdd94wUhvFe3TUJNhOSLFcHZroAs7JibgHQXQzE8=";
    };
  })
  # Waste Collection Schedule - UK bin day reminders (configure council via UI)
  (pkgs.buildHomeAssistantComponent rec {
    owner = "mampfes";
    domain = "waste_collection_schedule";
    version = "2.22.0";
    src = pkgs.fetchFromGitHub {
      owner = "mampfes";
      repo = "hacs_waste_collection_schedule";
      rev = "v${version}";
      sha256 = "sha256-eUpfeWfMHsBBlDJpq0lBo1aQ7VF3THTXQTXDaXL5+tQ=";
    };
    propagatedBuildInputs =
      (with haPython; [
        beautifulsoup4
        icalendar
        icalevents
        lxml
        pycryptodome
        pypdf
        pdfminer-six
      ])
      ++ [haPython."curl-cffi"];
  })
  # National Rail UK - departure boards (needs free Darwin API key, configure via UI)
  (pkgs.buildHomeAssistantComponent rec {
    owner = "darrenparkinson";
    domain = "nationalrailuk";
    version = "1.0.2";
    src = pkgs.fetchFromGitHub {
      owner = "darrenparkinson";
      repo = "homeassistant_nationalrail";
      rev = "v${version}";
      sha256 = "sha256-pqcl7cpszTJn5REEKc+mXrO20kIQQDAMpm35IQjnKlM=";
    };
    # aiohttp is provided by HA's Python environment
  })
  # London TfL - departure boards for tube/bus/overground (configure station via UI)
  (pkgs.buildHomeAssistantComponent rec {
    owner = "morosanmihail";
    domain = "london_tfl";
    version = "0.8.6";
    src = pkgs.fetchFromGitHub {
      owner = "morosanmihail";
      repo = "HA-LondonTfL";
      rev = "v${version}";
      sha256 = "sha256-d2FlW2DMzkGUlOOtshKCR+9eROIDW3WAE5hCeTyLaUU=";
    };
    propagatedBuildInputs = with haPython; [
      zeep
    ];
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
      haPython.unidecode
      haPython.aiofiles
      (
        haPython.buildPythonPackage rec {
          pname = "pyaarlo";
          version = "0.8.0.17";
          pyproject = true;
          src = pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-a7/MnUfzatdNY4RolJd2EsEucDwVoFIXnsYOGtJSGZU=";
          };
          propagatedBuildInputs = with haPython; [
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
