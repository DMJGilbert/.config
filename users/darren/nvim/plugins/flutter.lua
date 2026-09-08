require("flutter-tools").setup({
	ui = {
		border = "none",
		notification_style = "native",
	},
	decorations = {
		statusline = {
			app_version = false,
			device = false,
		},
	},
	-- flutter CLI resolved from PATH (installed via Homebrew cask)
	flutter_path = nil,
	flutter_lookup_cmd = nil,
	fvm = false,

	widget_guides = { enabled = false },

	closing_tags = { enabled = false },

	dev_log = {
		enabled = true,
		notify_errors = true,
		open_cmd = "tabedit",
	},

	dev_tools = {
		autostart = false,
		auto_open_browser = false,
	},

	outline = {
		open_cmd = "30vnew",
		auto_open = false,
	},

	lsp = {
		-- flutter-tools manages the Dart LSP (which is why dartls is absent from
		-- lsp.lua's server list) for Flutter SDK extensions and widget guides.
		--
		-- Colour decorations are NOT configured here: Neovim 0.12 enables
		-- document colours natively for every server, and flutter-tools' own
		-- `color` option is deprecated against it. The ■ style is set once,
		-- LSP-wide, in plugins/lsp.lua.
		capabilities = require("blink.cmp").get_lsp_capabilities(),
		settings = {
			showTodos = true,
			completeFunctionCalls = true,
			renameFilesWithClasses = "prompt",
			enableSnippets = true,
			updateImportsOnRename = true,
		},
	},
})

-- Hot reload on every dart save (silent if no app is running)
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.dart",
	callback = function()
		pcall(vim.cmd, "FlutterReload")
	end,
	desc = "Flutter hot reload on save",
})

-- <leader>F namespace for Flutter commands
vim.keymap.set("n", "<leader>Fr", "<cmd>FlutterRun<cr>", { desc = "Flutter run" })
vim.keymap.set("n", "<leader>Fq", "<cmd>FlutterQuit<cr>", { desc = "Flutter quit" })
vim.keymap.set("n", "<leader>Fh", "<cmd>FlutterReload<cr>", { desc = "Flutter hot reload" })
vim.keymap.set("n", "<leader>FR", "<cmd>FlutterRestart<cr>", { desc = "Flutter hot restart" })
vim.keymap.set("n", "<leader>Fd", "<cmd>FlutterDevices<cr>", { desc = "Flutter devices" })
vim.keymap.set("n", "<leader>Fe", "<cmd>FlutterEmulators<cr>", { desc = "Flutter emulators" })
vim.keymap.set("n", "<leader>Fl", "<cmd>FlutterLogToggle<cr>", { desc = "Flutter log" })
vim.keymap.set("n", "<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", { desc = "Flutter outline" })
vim.keymap.set("n", "<leader>Fp", "<cmd>FlutterCopyProfilerUrl<cr>", { desc = "Flutter profiler URL" })
