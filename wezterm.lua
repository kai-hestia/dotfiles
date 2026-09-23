-- Windows config for WezTerm, ported from the macOS Alacritty setup.
-- This file lives in the dotfiles repo; %USERPROFILE%\.wezterm.lua on Windows
-- is a symlink pointing here.
local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-- Font: JetBrainsMono Nerd Font Mono, size 17 (same as Alacritty).
config.font = wezterm.font 'JetBrainsMono Nerd Font Mono'
config.font_size = 12.0

-- Shell: WSL (Ubuntu) starting in the Linux home dir; fish is the login shell there.
config.default_prog = { 'wsl.exe', '~' }

-- IME: let the system (Rime/Weasel) render the preedit. This is what makes the
-- IME candidate popup follow the terminal cursor on Windows.
config.ime_preedit_rendering = 'System'

-- TERM for programs inside WSL (Alacritty had env.TERM = "xterm-256color").
config.term = 'xterm-256color'

-- Bell: no sound, no visual flash (Alacritty had bell.duration = 0).
config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_duration_ms = 0,
  fade_out_duration_ms = 0,
}

-- Window: borderless, opaque, no padding (Alacritty: decorations "none", opacity 1.0).
config.window_decorations = 'NONE'
config.window_background_opacity = 1.0
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

-- No tab bar; tmux handles multiplexing.
config.enable_tab_bar = false

-- Match Alacritty's default scrollback.
config.scrollback_lines = 10000

-- Live config reload (Alacritty: live_config_reload = true).
-- NOTE: the config is symlinked from the WSL side, and Windows file watching
-- cannot see changes made in the WSL filesystem, so auto-reload will not fire.
-- Press Ctrl+Shift+R (WezTerm's default reload binding) after editing this file.
config.automatically_reload_config = true

-- Alt+Enter / Shift+Enter send Ctrl+J (\n), so pi receives a newline through tmux
-- (same as the Alacritty keyboard bindings).
config.keys = {
  { key = 'Enter', mods = 'ALT', action = act.SendString '\n' },
  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\n' },
}

-- Start fullscreen, hiding the taskbar (Alacritty: startup_mode = "Fullscreen").
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():toggle_fullscreen()
end)

return config
