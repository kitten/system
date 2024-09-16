local wezterm = require("wezterm")
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

return {
  term = "wezterm",
  default_prog = { zsh_bin, "-l" },

  mux_env_remove = {
    "SSH_AUTH_SOCK",
    "SSH_CLIENT",
    "SSH_CONNECTION",
    "GPG_TTY",
  },

  font = wezterm.font_with_fallback({ "Dank Mono", "codicon", "Font Awesome 6 Pro" }),
  allow_square_glyphs_to_overflow_width = "Always",
  freetype_load_target = "Light",
  freetype_render_target = "HorizontalLcd",
  font_size = font_size,
  line_height = 1.1,
  max_fps = 120,

  front_end = "WebGpu",
  enable_wayland = false,
  enable_scroll_bar = false,
  enable_kitty_keyboard = true,
  check_for_updates = false,
  window_close_confirmation = "NeverPrompt",
  native_macos_fullscreen_mode = true,
  warn_about_missing_glyphs = false,
  bold_brightens_ansi_colors = false,
  window_decorations = "RESIZE",
  window_background_opacity = 0.999,
  hide_mouse_cursor_when_typing = false,
  underline_thickness = "160%",

  use_fancy_tab_bar = false,
  tab_bar_at_bottom = true,
  tab_max_width = 24,
  tab_bar_style = {
    active_tab_left = empty,
    active_tab_right = empty,
    inactive_tab_left = empty,
    inactive_tab_right = empty,
    inactive_tab_hover_left = empty,
    inactive_tab_hover_right = empty,
  },

  inactive_pane_hsb = {
    hue = 1.0,
    saturation = 1.0,
    brightness = 1.0,
  },

  window_frame = {
    font = wezterm.font_with_fallback({ "Dank Mono", "codicon" }),
    font_size = font_size,
    active_titlebar_bg = colors.black,
    inactive_titlebar_bg = colors.black,
  },

  window_padding = {
    left = "3px",
    right = "3px",
    top = "4px",
    bottom = "4px",
  },

  colors = {
    background = colors.black,
    foreground = colors.white,
    cursor_border = colors.grey,
    cursor_fg = colors.grey,
    cursor_bg = colors.white,
    selection_bg = colors.grey,
    selection_fg = colors.white,
    split = colors.split,
    ansi = {
      colors.black,
      colors.red,
      colors.green,
      colors.yellow,
      colors.blue,
      colors.magenta,
      colors.aqua,
      colors.white,
    },
    brights = {
      colors.grey,
      colors.brightRed,
      colors.brightGreen,
      colors.orange,
      colors.brightBlue,
      colors.magenta,
      colors.cyan,
      colors.muted,
    },
    tab_bar = {
      background = colors.black,
      active_tab = {
        bg_color = colors.black,
        fg_color = colors.yellow,
        intensity = "Bold",
      },
      inactive_tab_edge = colors.black,
      inactive_tab = {
        bg_color = colors.black,
        fg_color = colors.muted,
      },
      inactive_tab_hover = {
        bg_color = colors.black,
        fg_color = colors.blue,
      },
      new_tab = {
        bg_color = colors.black,
        fg_color = colors.blue,
      },
    }
  },

  send_composed_key_when_left_alt_is_pressed = false,
  send_composed_key_when_right_alt_is_pressed = true,
  leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },
  keys = {
    { key = "a", mods = "LEADER|CTRL", action = wezterm.action({ SendString="\x01" }) },
    { key = "%", mods = "LEADER|SHIFT", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
    { key = "\"", mods = "LEADER|SHIFT", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
    { key = "c", mods = "LEADER", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
    { key = "h", mods = "CTRL", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
    { key = "j", mods = "CTRL", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
    { key = "k", mods = "CTRL", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
    { key = "l", mods = "CTRL", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
    { key = "h", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
    { key = "j", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
    { key = "k", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
    { key = "l", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
    { key = "H", mods = "LEADER|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Left", 2 } }) },
    { key = "J", mods = "LEADER|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Down", 2 } }) },
    { key = "K", mods = "LEADER|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Up", 2 } }) },
    { key = "L", mods = "LEADER|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Right", 2 } }) },
    { key = "n", mods = "LEADER", action = wezterm.action({ ActivateTabRelative = 1 }) },
    { key = "p", mods = "LEADER", action = wezterm.action({ ActivateTabRelative = -1 }) },
    { key = "l", mods = "LEADER", action = "ActivateLastTab" },
    { key = "&", mods = "LEADER|SHIFT", action = wezterm.action({ CloseCurrentTab = { confirm = true } }) },
    { key = "x", mods = "LEADER", action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
    { key = "-", mods = "LEADER", action = wezterm.action({ ClearScrollback = "ScrollbackAndViewport" }) },
    { key = "[", mods = "LEADER", action = "ActivateCopyMode" },
    { key = "z", mods = "LEADER", action = "TogglePaneZoomState" },
    { key = "s", mods = "LEADER", action = "ShowLauncher" },
  },
}
