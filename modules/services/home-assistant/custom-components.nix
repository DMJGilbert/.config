# Home Assistant custom components (HACS-style)
# Extracted from default.nix for maintainability
{pkgs}: let
  haPython = pkgs.home-assistant.python3Packages;
in [
  pkgs.home-assistant-custom-components.spook
  pkgs.home-assistant-custom-components.localtuya
  pkgs.home-assistant-custom-components.octopus_energy
  pkgs.home-assistant-custom-components.waste_collection_schedule
  (pkgs.buildHomeAssistantComponent rec {
    owner = "AlexxIT";
    domain = "sonoff";
    version = "3.13.1";
    src = pkgs.fetchFromGitHub {
      owner = "AlexxIT";
      repo = "SonoffLAN";
      rev = "v${version}";
      sha256 = "sha256-ECQKv2WZ8/2+trmfg6fFFNhwkEWIwBzEWIJSpoFm5aM=";
    };
  })
  # Maintained fork: the original CodeFoodPixels repo and the maximoei fork
  # (T2266 support) are both archived and break on HA 2026.9.
  (pkgs.buildHomeAssistantComponent rec {
    owner = "damacus";
    domain = "robovac";
    version = "2.5.0";
    src = pkgs.fetchFromGitHub {
      owner = "damacus";
      repo = "robovac";
      rev = "v${version}";
      sha256 = "sha256-0D5FzJsRIzo41FujFLbaOzgnBTRO3vOdFRM4aPcq8uc=";
    };
    propagatedBuildInputs = with haPython; [
      cryptography
      requests
    ];
  })
  (pkgs.buildHomeAssistantComponent rec {
    owner = "marq24";
    domain = "fordpass";
    version = "2026.9.3";
    src = pkgs.fetchFromGitHub {
      owner = "marq24";
      repo = "ha-fordpass";
      rev = version;
      sha256 = "sha256-wYqrfYmCmofnSG8DYuVfBdUPA8vvN/ry85ceuZpMoKQ=";
    };
  })
  (pkgs.buildHomeAssistantComponent rec {
    owner = "vasqued2";
    domain = "teamtracker";
    version = "0.18.4";
    src = pkgs.fetchFromGitHub {
      owner = "vasqued2";
      repo = "ha-teamtracker";
      rev = "v${version}";
      sha256 = "sha256-B7XszI5Ge4avnbKEk1HZaVWaxexfqTLadd5B5vLLa8w=";
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
    propagatedBuildInputs = with haPython; [
      aiohttp
    ];
  })
  (pkgs.buildHomeAssistantComponent rec {
    owner = "gcobb321";
    domain = "icloud3";
    version = "3.7.5";
    src = pkgs.fetchFromGitHub {
      owner = "gcobb321";
      repo = "icloud3";
      rev = "v${version}";
      sha256 = "sha256-zAEMgcrz5NB+lHCz6zY0OxwbW1LebRdNCrcYoc+93Zc=";
    };
    propagatedBuildInputs = with haPython; [
      srp
      fido2
    ];
  })
]
