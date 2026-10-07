# Home Assistant custom components (HACS-style)
# Extracted from default.nix for maintainability
{pkgs}: let
  haPython = pkgs.home-assistant.python3Packages;

  # Dyson cloud and device-credential client used by hass-dyson; not in nixpkgs.
  libdyson-rest = haPython.buildPythonPackage rec {
    pname = "libdyson-rest";
    version = "0.16.1";
    pyproject = true;
    src = pkgs.fetchPypi {
      pname = "libdyson_rest";
      inherit version;
      hash = "sha256-1PxbfyL7U8gi11aciF0t7IQ1bf8H9NCRFpJkMiTcmVs=";
    };
    build-system = with haPython; [setuptools wheel];
    dependencies = with haPython; [
      cryptography
      httpx
      typing-extensions
    ];
    pythonImportsCheck = ["libdyson_rest"];
  };
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
  # Maintained successor to libdyson-wg/ha-dyson (dyson_local), which has been
  # inactive since 2025-08 and uses constants HA removes in 2027.8.
  (pkgs.buildHomeAssistantComponent rec {
    owner = "cmgrayb";
    domain = "hass_dyson";
    version = "0.38.0";
    src = pkgs.fetchFromGitHub {
      owner = "cmgrayb";
      repo = "hass-dyson";
      rev = "v${version}";
      hash = "sha256-wnUBdWVlrJCwzQW1zAAEsYu5F3b4jX8l5FR7Qksb34g=";
    };
    propagatedBuildInputs = [
      libdyson-rest
      haPython.paho-mqtt
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
