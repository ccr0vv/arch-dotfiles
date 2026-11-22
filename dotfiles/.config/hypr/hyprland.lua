-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- HYPRLAND CONFIG (Lua)                                 --
-- Wiki: https://wiki.hypr.land/configuring/             --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --


------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "0x0",
    scale    = 1,
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


--------------------------------
---- COLORS (PYWAL) -----------
--------------------------------

local function load_wal()
    local colors = {}
    local home = os.getenv("HOME") or ""
    local f = io.open(home .. "/.cache/wal/colors-hyprland.conf", "r")
    if f then
        for line in f:lines() do
            local name, value = line:match("^%$([%w_]+)%s*=%s*(.-)%s*$")
            if name then colors[name] = value end
        end
        f:close()
    end
    return colors
end

local wal = load_wal()

local function color(name, fallback)
    return wal[name] or fallback
end

local color0 = color("color0", "rgba(1a1a1aee)")
local color1 = color("color1", "rgba(33ccffee)")
local color8 = color("color8", "rgba(595959aa)")


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "rofi -show run"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function ()
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("kbuildsycoca6")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("sleep 1 && waybar")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets,pkcs11,ssh")
    -- wallpaper
    hl.exec_cmd("awww-daemon & sleep 1; awww clear 000000")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_MENU_PREFIX", "arch-")

-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },

    general = {
        gaps_in  = 5,
        gaps_out = 20,

        border_size = 2,

        col = {
            active_border   = color1,
            inactive_border = color8,
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = color0,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})


----------------------
---- ANIMATIONS ------
----------------------

hl.curve("wind",         { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.0}  } })
hl.curve("winIn",        { type = "bezier", points = { {0.1, 1.0},   {0.1, 1.0}  } })
hl.curve("winOut",       { type = "bezier", points = { {0.3, -0.3},  {0, 1.0}    } })
hl.curve("liner",        { type = "bezier", points = { {1, 1},       {1, 1}      } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5},   {0.75, 1.0} } })

hl.animation({ leaf = "windows",      enabled = true, speed = 6,    bezier = "wind",   style = "slide" })
hl.animation({ leaf = "windowsIn",    enabled = true, speed = 6,    bezier = "winIn",  style = "slide" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 5,    bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove",  enabled = true, speed = 5,    bezier = "wind",   style = "slide" })
hl.animation({ leaf = "border",       enabled = true, speed = 1,    bezier = "liner" })
hl.animation({ leaf = "borderangle",  enabled = true, speed = 30,   bezier = "liner",  style = "loop" })
hl.animation({ leaf = "layers",       enabled = true, speed = 6,    bezier = "wind",   style = "popin 90%" })
hl.animation({ leaf = "layersIn",     enabled = true, speed = 6,    bezier = "winIn",  style = "popin 90%" })
hl.animation({ leaf = "layersOut",    enabled = true, speed = 5,    bezier = "winOut", style = "popin 90%" })
hl.animation({ leaf = "workspaces",   enabled = true, speed = 5,    bezier = "wind" })
hl.animation({ leaf = "fadeIn",       enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",      enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",         enabled = true, speed = 3.03, bezier = "almostLinear" })


----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper  = -1,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
    },

    debug = {
        disable_logs = false,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "br",
        kb_variant = "thinkpad",
        kb_model   = "x390",
        kb_options = "grp:win_space_toggle",

        follow_mouse = 1,

        sensitivity = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + Q",     hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E",     hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + L",     hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + W",     hl.dsp.exec_cmd("firefox"))

hl.bind(mainMod .. " + X", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
-- hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))  -- dwindle

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + Tab",         hl.dsp.focus({ workspace = "previous" }))
hl.bind(mainMod .. " + ALT + left",  hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.focus({ workspace = "+1" }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ workspace = "+1" }))

-- Scratchpad
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),   { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 5%+"),                          { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"),                          { locked = true, repeating = true })

-- Screenshots (hyprshot)
local shots = '"$HOME/Pictures/Screenshots/"'
hl.bind(mainMod .. " + SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m window --freeze -o " .. shots))
hl.bind("PRINT",                       hl.dsp.exec_cmd("hyprshot -m output --freeze -o " .. shots)) -- monitor
hl.bind(mainMod .. " + PRINT",         hl.dsp.exec_cmd("hyprshot -m region --freeze -o " .. shots))


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

local inFocusOpacity    = "1"
local notInFocusOpacity = "0.7"
local opacity           = inFocusOpacity .. " " .. notInFocusOpacity

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name  = "opacity-default",
    match = { class = ".*" },

    opacity = opacity,
})

hl.window_rule({
    name  = "opacity-kitty",
    match = { class = "^kitty$" },

    opacity = "1 1",
})

hl.window_rule({
    name  = "opacity-browsers",
    match = { class = "^(firefox|brave|chromium|librewolf|qutebrowser|zen-browser)$" },

    opacity = opacity,
})

hl.window_rule({ name = "opacity-spotify",  match = { title = ".*Spotify.*" },        opacity = opacity })
hl.window_rule({ name = "opacity-discord",  match = { title = ".*Discord.*" },        opacity = opacity })
hl.window_rule({ name = "opacity-telegram", match = { title = ".*Telegram.*" },       opacity = opacity })
hl.window_rule({ name = "opacity-code",     match = { title = ".*Code.*" },           opacity = opacity })
hl.window_rule({ name = "opacity-files",    match = { title = ".*(Thunar|nemo).*" },  opacity = opacity })

hl.window_rule({
    name  = "lunar-client-fullscreen",
    match = { class = "^Lunar Client.*$" },

    fullscreen = true,
})
