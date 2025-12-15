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

      # LSP
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./plugins/lsp.lua;
      }

      # LSP UI enhancements
      {
        plugin = lspsaga-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/lspsaga.lua;
      }

      # Snippets (LuaSnip)
      luasnip
      friendly-snippets
      cmp_luasnip

      # Completion
      {
        plugin = nvim-cmp;
        type = "lua";
        config = builtins.readFile ./plugins/cmp.lua;
      }
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      cmp-nvim-lua
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp-spell
      cmp-treesitter
      crates-nvim

      # Telescope
      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/telescope.lua;
      }
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

    extraLuaConfig =
      builtins.readFile ./core/options.lua
      + builtins.readFile ./core/mappings.lua
      + builtins.readFile ./core/auto.lua;
  };
}
