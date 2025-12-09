local wezterm = require("wezterm")

local colorscheme = "Catppuccin Frappe"
local colors = wezterm.color.get_builtin_schemes()[colorscheme]
local font_family = "SauceCodePro Nerd Font"
local font = wezterm.font({
	family = font_family,
	weight = "Regular",
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
})
local action = wezterm.action

local get_process_icon = function(tab)
	local process_icons = {
		["nvim"] = {
			{ Text = wezterm.nerdfonts.custom_vim },
		},
		["zellij"] = {
			{ Text = wezterm.nerdfonts.cod_terminal_tmux },
		},
		["zsh"] = {
			{ Text = wezterm.nerdfonts.dev_terminal },
		},
		["ssh"] = {
			{ Text = wezterm.nerdfonts.cod_remote },
		},
		["git"] = {
			{ Text = wezterm.nerdfonts.dev_git },
		},
		["node"] = {
			{ Text = wezterm.nerdfonts.dev_nodejs_small },
		},
		["docker"] = {
			{ Text = wezterm.nerdfonts.dev_docker },
		},
	}

	local process = string.gsub(tab.active_pane.foreground_process_name, "(.*[/\\])(.*)", "%2")
	return wezterm.format(process_icons[process] or { { Text = process } })
end

local function get_current_working_dir(tab)
	local current_dir = tab.active_pane.current_working_dir.file_path
	local HOME_DIR = string.format("file://%s", os.getenv("HOME"))
	local process = string.gsub(tab.active_pane.foreground_process_name, "(.*[/\\])(.*)", "%2")
	if process == "ssh" then
		return "ssh"
	end
	return current_dir == HOME_DIR and "~" or string.format("%s", string.gsub(current_dir, "(.*[/\\])(.*)", "%2"))
end

wezterm.on("format-tab-title", function(tab)
	return wezterm.format({
		{ Text = get_process_icon(tab) },
		{ Text = " " },
		{ Text = get_current_working_dir(tab) },
		{ Text = "   " },
	})
end)

return {
	window_decorations = "RESIZE",
	enable_tab_bar = true,
	use_fancy_tab_bar = true,
	tab_max_width = 25,
	hide_tab_bar_if_only_one_tab = true,
	window_padding = {
		left = 5,
		right = 5,
		top = 0,
		bottom = 0,
	},
	color_scheme = colorscheme,
	bold_brightens_ansi_colors = true,
	force_reverse_video_cursor = true,
	font = font,
	font_size = 11,
	max_fps = 60,
	window_close_confirmation = "NeverPrompt",
	window_background_opacity = 1.0,
	switch_to_last_active_tab_when_closing_tab = true,
	tab_bar_at_bottom = true,
	scrollback_lines = 6000,
	audible_bell = "Disabled",
	window_frame = {
		font = wezterm.font({ family = font_family }),
		font_size = 10.0,
		active_titlebar_bg = colors["background"],
	},
	colors = {
		tab_bar = {
			background = colors["background"],
			active_tab = {
				bg_color = "#8caaee",
				fg_color = "#303446",
			},
			inactive_tab = {
				bg_color = "#51576d",
				fg_color = colors["foreground"],
			},
			new_tab = {
				bg_color = colors["background"],
				fg_color = colors["foreground"],
			},
		},
	},
	keys = {
		{ key = "(", mods = "ALT", action = action.ActivateTabRelative(-1) },
		{ key = ")", mods = "ALT", action = action.ActivateTabRelative(1) },
	},
}
