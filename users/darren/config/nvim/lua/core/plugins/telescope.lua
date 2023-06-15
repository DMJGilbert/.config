return {
	"nvim-telescope/telescope.nvim",
	event = "VeryLazy",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-telescope/telescope-ui-select.nvim" },
		{ "nvim-telescope/telescope-file-browser.nvim" },
		{ "kdheepak/lazygit.nvim" },
		{
			"folke/todo-comments.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			keys = {
				{
					"<leader>t",
					":TodoTelescope keywords=TODO,FIX<cr>",
					desc = "Open TODO list",
				},
			},
			opts = {},
		},
	},
	keys = {
		{ "<leader><leader>", "<cmd>Telescope resume<CR>", desc = "Resume telescope" },
		{ "<leader>gg", "<cmd>LazyGit<cr>" },
		{
			"<leader>o",
			function()
				require("telescope.builtin").find_files({
					hidden = true,
					find_command = { "rg", "--files", "--hidden" },
					file_ignore_patterns = {
						".git/",
						"aurora%-toolkit",
						"amppstreamingsdk",
						"target/",
						"node%_modules/.*",
					},
				})
			end,
			desc = "Find Files",
		},
		{
			"<leader>O",
			function()
				require("telescope.builtin").find_files({
					hidden = true,
					find_command = { "rg", "--no-ignore", "--files", "--hidden" },
				})
			end,
			desc = "Find all files",
		},
		{
			"<leader>i",
			function()
				require("telescope.builtin").lsp_document_symbols()
			end,
			desc = "Find document symbols",
		},
		{
			"<leader>e",
			function()
				require("telescope.builtin").live_grep()
			end,
			desc = "Find in workspace",
		},
		{
			"<leader>x",
			function()
				require("telescope.builtin").diagnostics()
			end,
			desc = "Find issues",
		},
		{
			"<leader>n",
			function()
				require("telescope").extensions.file_browser.file_browser()
			end,
			desc = "Open file browser",
		},
		{
			"<leader>b",
			function()
				require("telescope.builtin").buffers()
			end,
			desc = "Find open buffer",
		},
		-- LSP
		{
			"gr",
			function()
				require("telescope.builtin").lsp_references()
			end,
			desc = "Find LSP references",
		},
		{
			"gr",
			function()
				require("telescope.builtin").lsp_definitions()
			end,
			desc = "Find LSP definitions",
		},
	},
	config = function()
		local scope = require("telescope")
		local actions = require("telescope.actions")
		scope.setup({
			extensions_list = { "themes", "terms" },
			defaults = {
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({
							border = {},
							borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
						}),
					},
					file_browser = {
						theme = "ivy",
					},
				},
				mappings = {
					i = {
						["<esc>"] = actions.close,
					},
					n = {},
				},
				prompt_prefix = "  ",
				selection_caret = "",
				entry_prefix = "",
				initial_mode = "insert",
				selection_strategy = "reset",
				sorting_strategy = "ascending",
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.5,
						results_width = 0.9,
					},
					vertical = {
						mirror = false,
					},
					width = 0.9,
					height = 0.7,
					preview_cutoff = 120,
				},
				file_sorter = require("telescope.sorters").get_fuzzy_file,
				file_ignore_patterns = { "node_modules" },
				generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
				path_display = { "truncate" },
				winblend = 0,
				border = {},
				-- borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
				borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
				color_devicons = true,
				set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
				file_previewer = require("telescope.previewers").vim_buffer_cat.new,
				grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
				qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
			},
		})
		scope.load_extension("file_browser")
		scope.load_extension("ui-select")
		scope.load_extension("lazygit")

		local colors = require("catppuccin.palettes").get_palette()
		vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = colors.base })
		vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = colors.base })
		vim.api.nvim_set_hl(0, "TelescopeTitle", { bg = colors.teal, fg = colors.mantle })
		vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = colors.teal, fg = colors.mantle })
		vim.api.nvim_set_hl(0, "TelescopePrompt", { bg = colors.teal, fg = colors.mantle })
		vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = colors.teal, fg = colors.mantle })
		vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { bg = colors.teal, fg = colors.mantle })
	end,
}
