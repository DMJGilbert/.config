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
        config = builtins.readFile ./config/nvim-nix/plugins/catppuccin.lua;
      }

      # Treesitter
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = builtins.readFile ./config/nvim-nix/plugins/treesitter.lua;
      }
      nvim-treesitter-context
      nvim-ts-autotag
      vim-matchup

      # LSP
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./config/nvim-nix/plugins/lsp.lua;
      }

      # LSP UI enhancements
      {
        plugin = lspsaga-nvim;
        type = "lua";
        config = builtins.readFile ./config/nvim-nix/plugins/lspsaga.lua;
      }

      # Completion
      {
        plugin = nvim-cmp;
        type = "lua";
        config = builtins.readFile ./config/nvim-nix/plugins/cmp.lua;
      }
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      vim-vsnip
      cmp-spell
      cmp-treesitter
      crates-nvim

      # Telescope
      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ./config/nvim-nix/plugins/telescope.lua;
      }
      telescope-ui-select-nvim
      telescope-file-browser-nvim
      lazygit-nvim
      todo-comments-nvim

      # Formatter
      {
        plugin = conform-nvim;
        type = "lua";
        config = builtins.readFile ./config/nvim-nix/plugins/conform.lua;
      }

      # Git integration
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = builtins.readFile ./config/nvim-nix/plugins/gitsigns.lua;
      }

      # UI plugins
      {
        plugin = alpha-nvim;
        type = "lua";
        config = builtins.readFile ./config/nvim-nix/plugins/alpha.lua;
      }
      {
        plugin = noice-nvim;
        type = "lua";
        config = builtins.readFile ./config/nvim-nix/plugins/noice.lua;
      }
      nui-nvim
      nvim-notify
      {
        plugin = neo-tree-nvim;
        type = "lua";
        config = builtins.readFile ./config/nvim-nix/plugins/neotree.lua;
      }
      nvim-web-devicons
      barbecue-nvim
      nvim-navic

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
        config = builtins.readFile ./config/nvim-nix/plugins/persistence.lua;
      }
      nvim-coverage

      # Simple plugin configurations
      {
        plugin = pkgs.vimUtils.buildVimPlugin {
          name = "simple-configs";
          src = pkgs.writeTextDir "plugin/simple.lua" "";
        };
        type = "lua";
        config = builtins.readFile ./config/nvim-nix/plugins/simple.lua;
      }
    ];

    extraLuaConfig = ''
      -- Map leader to space
      vim.g.mapleader = " "

      ${builtins.readFile ./config/nvim-nix/core/options.lua}
      ${builtins.readFile ./config/nvim-nix/core/mappings.lua}
      ${builtins.readFile ./config/nvim-nix/core/auto.lua}
    '';
  };
}
