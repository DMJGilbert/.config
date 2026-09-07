-- Buffers that must never be written into a session
local function is_ephemeral(buf)
	local buftype = vim.bo[buf].buftype
	local filetype = vim.bo[buf].filetype
	local name = vim.api.nvim_buf_get_name(buf)

	if buftype == "terminal" or buftype == "nofile" or buftype == "quickfix" or buftype == "prompt" then
		return true
	end
	if
		filetype == "lazy"
		or filetype == "lazygit"
		or filetype == "neo-tree"
		or filetype == "neotest-summary"
		or filetype == "neotest-output-panel"
	then
		return true
	end
	if name:match("^term://") then
		return true
	end
	return false
end

-- persistence.nvim 3.x accepts only dir/need/branch. `options` and `pre_save`
-- are NOT config keys -- they are silently ignored. sessionoptions must be set
-- directly, and the save hook is the User PersistenceSavePre autocmd below.
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }

require("persistence").setup({
	dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
})

-- Runs immediately before persistence calls :mksession!
vim.api.nvim_create_autocmd("User", {
	pattern = "PersistenceSavePre",
	group = vim.api.nvim_create_augroup("persistence_clean", { clear = true }),
	callback = function()
		pcall(vim.cmd, "Neotree close")

		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			if is_ephemeral(buf) then
				pcall(vim.api.nvim_win_close, win, true)
			end
		end

		-- Wipe the buffers themselves; closing the window alone leaves them
		-- in the buffer list, and "buffers" in sessionoptions restores them.
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_valid(buf) and is_ephemeral(buf) then
				pcall(vim.api.nvim_buf_delete, buf, { force = true })
			end
		end
	end,
})

local term_group = vim.api.nvim_create_augroup("persistence_no_term", { clear = true })

-- Belt and braces: keep terminal buffers unlisted so they never reach a session
vim.api.nvim_create_autocmd("TermOpen", {
	group = term_group,
	callback = function(args)
		vim.bo[args.buf].buflisted = false
	end,
})

local function is_lazygit(buf)
	return vim.api.nvim_buf_get_name(buf):match("lazygit") ~= nil
end

-- A hidden lazygit is a live job: it blocks :qa with E89 long before
-- VimLeavePre (and therefore the save hook) ever runs. Kill it when it loses
-- its window. Scoped to lazygit so long-running terminals are untouched.
vim.api.nvim_create_autocmd("BufWinLeave", {
	group = term_group,
	callback = function(args)
		if vim.bo[args.buf].buftype == "terminal" and is_lazygit(args.buf) then
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(args.buf) and #vim.fn.win_findbuf(args.buf) == 0 then
					pcall(vim.api.nvim_buf_delete, args.buf, { force = true })
				end
			end)
		end
	end,
})

-- Last line of defence: sweep live terminal jobs before the quit check runs.
vim.api.nvim_create_autocmd("QuitPre", {
	group = term_group,
	callback = function()
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" and is_lazygit(buf) then
				pcall(vim.api.nvim_buf_delete, buf, { force = true })
			end
		end
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("persistence_autoload", { clear = true }),
	once = true,
	nested = true,
	callback = function()
		if vim.fn.argc(-1) == 0 then
			local cwd = vim.fn.getcwd()
			local suppress_dirs = {
				vim.fn.expand("~") .. "$",
				vim.fn.expand("~/Downloads"),
				vim.fn.expand("~/Developer") .. "$",
			}

			local should_suppress = false
			for _, dir in ipairs(suppress_dirs) do
				if cwd:match(dir) then
					should_suppress = true
					break
				end
			end

			if not should_suppress then
				vim.schedule(function()
					require("persistence").load()
				end)
			end
		end
	end,
})
