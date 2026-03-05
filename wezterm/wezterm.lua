local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Remove inner terminal padding so tmux uses the full content area.
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- Let tmux manage tabs.
config.enable_tab_bar = false

return config
