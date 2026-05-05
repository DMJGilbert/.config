{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      # Core plugins
      plenary-nvim

      # Colorscheme
      {
        plugin = catppuccin-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/catppuccin.lua;
      }

      # Treesitter
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = builtins.readFile ./plugins/treesitter.lua;
      }
      nvim-treesitter-context
      nvim-ts-autotag
      vim-matchup

      # LSP UI enhancements
      {
        plugin = lspsaga-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/lspsaga.lua;
      }

      # Snippets (consumed by blink.cmp)
      luasnip
      friendly-snippets

      # AI completion source — must load before blink.cmp so the provider is ready
      {
        plugin = minuet-ai-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/minuet.lua;
      }

      # Completion — blink.cmp replaces the entire nvim-cmp ecosystem
      {
        plugin = blink-cmp;
        type = "lua";
        config = builtins.readFile ./plugins/blink.lua;
      }
      blink-compat

      # Rust Cargo.toml completions (wired into blink via blink-compat)
      crates-nvim

      # LSP — native Neovim 0.11 API; lazydev enhances Lua completions
      # Loaded after blink so capabilities include blink's additions
      {
        plugin = lazydev-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/lazydev.lua + builtins.readFile ./plugins/lsp.lua;
      }

      # Linting — wires up eslint_d, statix, shellcheck
      {
        plugin = nvim-lint;
        type = "lua";
        config = builtins.readFile ./plugins/lint.lua;
      }

      # Telescope
      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/telescope.lua;
      }
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      telescope-file-browser-nvim
      lazygit-nvim
      todo-comments-nvim

      # Formatter
      {
        plugin = conform-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/conform.lua;
      }

      # Git integration
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/gitsigns.lua;
      }

      # UI plugins
      {
        plugin = noice-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/noice.lua;
      }
      nui-nvim
      nvim-notify
      {
        plugin = neo-tree-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/neotree.lua;
      }
      nvim-web-devicons
      barbecue-nvim
      nvim-navic

      # Fast motion
      {
        plugin = flash-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/flash.lua;
      }

      # LSP progress notifications
      {
        plugin = fidget-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/fidget.lua;
      }

      # Test runner
      nvim-nio
      {
        plugin = neotest;
        type = "lua";
        config = builtins.readFile ./plugins/neotest.lua;
      }
      neotest-rust
      neotest-jest
      neotest-vitest

      # Keybinding discoverability
      {
        plugin = which-key-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/whichkey.lua;
      }

      # Utility plugins
      undotree
      nvim-autopairs
      nvim-surround
      mini-nvim
      vim-commentary
      vim-repeat
      editorconfig-vim
      nvim-colorizer-lua
      hardtime-nvim
      {
        plugin = persistence-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/persistence.lua;
      }
      nvim-coverage

      # Simple plugin configurations
      {
        plugin = pkgs.vimUtils.buildVimPlugin {
          name = "simple-configs";
          src = pkgs.writeTextDir "plugin/simple.lua" "";
        };
        type = "lua";
        config = builtins.readFile ./plugins/simple.lua;
      }
    ];

    initLua =
      builtins.readFile ./core/options.lua
      + builtins.readFile ./core/mappings.lua
      + builtins.readFile ./core/auto.lua;
  };
}
