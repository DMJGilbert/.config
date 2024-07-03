return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	config = function()
		-- Dashboard
		local dashboard = require("alpha.themes.dashboard")

		local function button(sc, txt, keybind, keybind_opts)
			local b = dashboard.button(sc, txt, keybind, keybind_opts)
			b.opts.hl = "Constant"
			b.opts.hl_shortcut = "Type"
			return b
		end

		local function footer()
			return "v" .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
		end

		dashboard.section.header.val = {
			[[                                             ]],
			[[                                             ]],
			[[                                             ]],
			[[                                             ]],
			[[        ....                                 ]],
			[[    .xH888888Hx.                             ]],
			[[  .H8888888888888:                    ...    ]],
			[[  888*"""?""*88888X         u       ."@88i   ]],
			[[ 'f     d8x.   ^%88k     us888u.   ."%%888>  ]],
			[[ '>    <88888X   '?8  .@88 "8888"     '88%   ]],
			[[  `:..:`888888>    8> 9888  9888    ."dILr~` ]],
			[[         `"*88     X  9888  9888   '".-%88b  ]],
			[[    .xHHhx.."      !  9888  9888   .   '888k ]],
			[[   X88888888hx. ..!   9888  9888   8    8888 ]],
			[[  !   "*888888888"    "888*""888" '8    8888 ]],
			[[         ^"***"`       ^Y"   ^Y'  '8    888F ]],
			[[                                   %k  <88F  ]],
			[[                                    "+:*%`   ]],
			[[                                             ]],
			[[                                             ]],
		}
		dashboard.section.header.opts.hl = "Constant"

		dashboard.section.buttons.val = {
			button("<Leader>o", "  Find file"),
			button("<Leader>n", "󰝰  File explorer"),
			button("<Leader>e", "󱊒  Live grep"),
			button("<Leader>t", "  List tasks"),
			button("<Leader>gg", "󰊢  Open git"),
			button("q", "  Quit", "<Cmd>qa<CR>"),
		}

		dashboard.section.footer.val = footer()
		dashboard.section.footer.opts.hl = "Constant"

		require("alpha").setup(dashboard.opts)
	end,
}
