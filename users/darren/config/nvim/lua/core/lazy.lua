-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
	{ import = "core.plugins" },
}

-- Setup lazy.nvim
require("lazy").setup({
	spec = plugins,
	install = { colorscheme = { "catppuccin" } },
	checker = { enabled = true },
	performance = {
		rtp = {
			disabled_plugins = {
				"2html_plugin",
				"getscript",
				"getscriptPlugin",
				"gzip",
				"logiPat",
				"man",
				"matchit",
				"netrw",
				"netrwPlugin",
				"netrwSettings",
				"netrwFileHandlers",
				"remote_plugins",
				"rplugin",
				"rrhelper",
				"shada",
				"spellfile",
				"tar",
				"tarPlugin",
				"tohtml",
				"tutor",
				"vimball",
				"vimballPlugin",
				"zipPlugin",
			},
		},
	},
})
