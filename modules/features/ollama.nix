{
  config,
  lib,
  pkgs,
  currentSystem,
  ...
}: let
  cfg = config.local.features.ollama;
  isDarwin = builtins.match ".*-darwin" currentSystem != null;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.features.ollama = {
      enable = lib.mkEnableOption "Ollama local LLM server";

      models = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Models to ensure are downloaded on startup.";
        example = ["qwen2.5-coder:7b-base"];
      };
    };
  }
  # Darwin: launchd agents for ollama serve and model pulling
  // lib.optionalAttrs isDarwin {
    config = lib.mkIf cfg.enable (let
      userHome = "/Users/${config.system.primaryUser}";
      modelLoaderScript = pkgs.writeShellApplication {
        name = "ollama-model-loader";
        runtimeInputs = [pkgs.ollama];
        text = ''
          # Wait for ollama to be ready
          until ollama list > /dev/null 2>&1; do
            sleep 2
          done

          # Pull each declared model (generated at build time by Nix)
          ${lib.concatMapStringsSep "\n" (model: "ollama pull ${lib.escapeShellArg model}") cfg.models}
        '';
      };
    in {
      environment.systemPackages = [pkgs.ollama];

      launchd.agents.ollama = {
        serviceConfig = {
          ProgramArguments = ["${pkgs.ollama}/bin/ollama" "serve"];
          KeepAlive = true;
          RunAtLoad = true;
          StandardOutPath = "/tmp/ollama.log";
          StandardErrorPath = "/tmp/ollama.log";
          EnvironmentVariables = {
            HOME = userHome;
            OLLAMA_HOST = "127.0.0.1:11434";
          };
        };
      };

      launchd.agents.ollama-model-loader = lib.mkIf (cfg.models != []) {
        serviceConfig = {
          ProgramArguments = ["${modelLoaderScript}/bin/ollama-model-loader"];
          RunAtLoad = true;
          StandardOutPath = "/tmp/ollama-model-loader.log";
          StandardErrorPath = "/tmp/ollama-model-loader.log";
          EnvironmentVariables = {
            HOME = userHome;
          };
        };
      };
    });
  }
  # NixOS: native services.ollama module
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      services.ollama = {
        enable = true;
        loadModels = cfg.models;
      };
    };
  }
