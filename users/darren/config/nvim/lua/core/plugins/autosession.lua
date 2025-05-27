return {
	"rmagatti/auto-session", -- auto save session
	config = function()
		require("auto-session").setup({
			pre_save_cmds = { "Neotree close" },
			log_level = "error",
			auto_session_suppress_dirs = {
				"~/",
				"~/Downloads",
				"~/Developer",
			},
			auto_session_use_git_branch = true,
			auto_save_enabled = true,
		})
	end,
}
