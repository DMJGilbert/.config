return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	config = function()
		require("noice").setup({
			views = {
				cmdline_popup = {
					border = {
						style = "none",
						padding = { 2, 5 },
					},
					filter_options = {},
				},
			},
			routes = {
				{
					filter = { event = "msg_show", kind = { "search_count", "wmsg" } },
					opts = { skip = true },
				},
			},
			cmdline = {
				view = "cmdline_popup",
				opts = { buf_options = { filetype = "vim" } },
				icons = {
					["/"] = { icon = " ", hl_group = "DiagnosticWarn", firstc = false },
					["?"] = { icon = " ", hl_group = "DiagnosticWarn", firstc = false },
					[":"] = { icon = " ", hl_group = "DiagnosticInfo", firstc = false },
				},
			},
			popup = {
				border = {
					style = "none",
				},
			},
		})

		require("notify").setup({
			render = "simple",
			stages = "static",
			on_open = function(win)
				vim.api.nvim_win_set_config(win, {
					border = "none",
				})
			end,
		})

		local colors = require("catppuccin.palettes").get_palette()
		vim.api.nvim_set_hl(0, "NotifyERRORTitle", { bg = colors.red, fg = colors.mantle })
		vim.api.nvim_set_hl(0, "NotifyERRORIcon", { bg = colors.red, fg = colors.mantle })
		vim.api.nvim_set_hl(0, "NotifyWARNTitle", { bg = colors.peach, fg = colors.mantle })
		vim.api.nvim_set_hl(0, "NotifyWARNIcon", { bg = colors.peach, fg = colors.mantle })
		vim.api.nvim_set_hl(0, "NotifyINFOTitle", { bg = colors.blue, fg = colors.mantle })
		vim.api.nvim_set_hl(0, "NotifyINFOIcon", { bg = colors.blue, fg = colors.mantle })

		vim.api.nvim_set_hl(0, "NotifyERRORBorder", { fg = colors.mantle })
		vim.api.nvim_set_hl(0, "NotifyWARNBorder", { fg = colors.mantle })
		vim.api.nvim_set_hl(0, "NotifyINFOBorder", { fg = colors.mantle })
	end,
}
