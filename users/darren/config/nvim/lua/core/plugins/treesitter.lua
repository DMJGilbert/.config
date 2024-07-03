return {
	{
		"nvim-treesitter/nvim-treesitter-context",
		config = true,
	},
	{
		"nvim-treesitter/nvim-treesitter",
        lazy = false,
		version = false,
		opts = {
			ensure_installed = {
				"css",
				"scss",
				"typescript",
				"lua",
				"html",
				"javascript",
				"json",
				"c",
				"cpp",
				"go",
				"rust",
				"yaml",
				"vim",
				"bash",
				"toml",
				"nix",
				"dart",
			},
			highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
			rainbow = {
				enable = false,
			},
			autotag = {
				enable = true,
				filetypes = {
					"html",
					"javascript",
					"typescript",
					"markdown",
				},
			},
			incremental_selection = {
				enable = false,
				keymaps = {
					init_selection = "<CR>",
					scope_incremental = "<CR>",
					node_incremental = "<CR>",
					node_decremental = "<TAB>",
				},
			},
			matchup = { enable = true },
		},
		---@param opts TSConfig
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
		dependencies = {
			"windwp/nvim-ts-autotag", -- Automatically end & rename tags
			"andymass/vim-matchup",
		},
	},
}
