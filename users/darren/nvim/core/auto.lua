local fn = vim.fn

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- General Settings
local general = augroup("General Settings", { clear = true })

autocmd("BufReadPost", {
	callback = function()
		if fn.line("'\"") > 1 and fn.line("'\"") <= fn.line("$") then
			vim.cmd('normal! g`"')
		end
	end,
	group = general,
	desc = "Go To The Last Cursor Position",
})

vim.api.nvim_create_autocmd("FocusGained", {
	desc = "Reload files from disk when we focus vim",
	pattern = "*",
	command = "if getcmdwintype() == '' | checktime | endif",
	group = general,
})

vim.api.nvim_create_autocmd("BufEnter", {
	desc = "Every time we enter an unmodified buffer, check if it changed on disk",
	pattern = "*",
	command = "if &buftype == '' && !&modified && expand('%') != '' | exec 'checktime ' . expand('<abuf>') | endif",
	group = general,
})

autocmd("ModeChanged", {
	callback = function()
		if fn.getcmdtype() == "/" or fn.getcmdtype() == "?" then
			vim.opt.hlsearch = true
		else
			vim.opt.hlsearch = false
		end
	end,
	group = general,
	desc = "Highlighting matched words when searching",
})

-- Hot reload potential flutter applications
autocmd("BufWritePost", {
	pattern = "*.dart",
	callback = function()
		vim.cmd("!kill -SIGUSR1 $(pgrep -f '[f]lutter_tool.*run')")
	end,
})
