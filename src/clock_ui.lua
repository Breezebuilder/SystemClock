local clock_ui = {}

local config = require('systemclock.config')
local locale = require('systemclock.locale')
local draggable_container = require('systemclock.draggablecontainer')

clock_ui.styles = {
    [1] = {
        name = 'simple',
    },
    [2] = {
        name = 'shadow',
        text_shadow = true
    },
    [3] = {
        name = 'translucent',
        shadow_colour = G.C.UI.TRANSPARENT_DARK,
        shadow_padding = 0.05,
        text_shadow = true
    },
    [4] = {
        name = 'panel',
        shadow_colour = G.C.UI.TRANSPARENT_DARK,
        shadow_padding = 0.02,
        outer_colour_ref = 'back',
        outer_padding = 0.02,
        inner_colour = G.C.DYN_UI.BOSS_DARK,
        inner_padding = 0.05,
        text_padding = 0.05,
        text_shadow = true
    },
    [5] = {
        name = 'embossed',
        shadow_colour_ref = 'shadow',
        outer_colour_ref = 'back',
        emboss_amount = 0.05,
        inner_padding = 0.1,
        text_shadow = true
    }
}

local function calculate_max_text_width(format_index)
    format_index = format_index or SystemClock.current_preset.format
    local format = SystemClock.CLOCK_FORMATS[format_index]
    local font = G.LANG.font
    local width = 0
    local string = SystemClock.get_formatted_time(format, SystemClock.example_time, true)
    for _, c in utf8.chars(string) do
        local dx = font.FONT:getWidth(c) * SystemClock.current_preset.size * G.TILESCALE * font.FONTSCALE +
            3 * G.TILESCALE * font.FONTSCALE
        dx = dx / (G.TILESIZE * G.TILESCALE)
        width = width + dx
    end
    return width
end

local function create_clock_DynaText(text_size, colours, shadow, float, silent)
    local dynaText = DynaText({
        string = { {
            ref_table = SystemClock,
            ref_value = 'time'
        } },
        colours = colours,
        scale = text_size,
        shadow = shadow,
        pop_in = 0,
        pop_in_rate = 10,
        float = float,
        silent = silent,
    })

    return {
        n = G.UIT.O,
        config = {
            align = 'cm',
            id = 'clock_text',
            object = dynaText
        }
    }
end

local function create_UIBox_clock(style_index, text_size, float)
    style_index = style_index or 2
    text_size = text_size or 1

    local colours = SystemClock.assign_clock_colours()

    local style = clock_ui.styles[style_index]

    local panel_outer_colour = style.outer_colour_ref and colours[style.outer_colour_ref] or style.outer_colour or G.C.CLEAR
    local panel_inner_colour = style.inner_colour_ref and colours[style.inner_colour_ref] or style.inner_colour or G.C.CLEAR
    local panel_shadow_colour = style.shadow_colour_ref and colours[style.shadow_colour_ref] or style.shadow_colour or G.C.CLEAR
    local text_colours = style.text_colour_ref and { colours[style.text_colour_ref] } or style.text_colours or style.text_colour and { style.text_colour } or { colours.text }

    local text_width = math.max(style.inner_width or 0, calculate_max_text_width())

    return {
        n = G.UIT.ROOT,
        config = {
            align = 'tm',
            colour = panel_shadow_colour,
            padding = style.shadow_padding,
            minw = 0.1,
            r = 0.1
        },
        nodes = {
            {
                n = G.UIT.R,
                config = {
                    align = 'cm',
                    colour = panel_outer_colour,
                    padding = style.outer_padding,
                    minh = style.outer_height,
                    minw = style.outer_width,
                    r = 0.1
                },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { padding = style.outer_padding },
                        nodes = {
                            style.heading_text and {
                                n = G.UIT.R,
                                config = {
                                    align = "cm",
                                },
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = locale.translate('sysclock_time_heading'),
                                            minh = 1,
                                            scale = 0.85 * 0.4,
                                            colour = G.C.UI.TEXT_LIGHT,
                                            shadow = true
                                        }
                                    }
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = {
                                    align = 'cm',
                                    colour = panel_inner_colour,
                                    padding = style.inner_padding,
                                    minh = style.inner_height,
                                    minw = style.inner_width,
                                    r = 0.1,
                                },
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = {
                                            align = 'cm',
                                            padding = style.text_padding,
                                            minw = text_width,
                                            r = 0.1
                                        },
                                        nodes = { create_clock_DynaText(text_size, text_colours, style.text_shadow, float, true) }
                                    }
                                }
                            }
                        }
                    }
                }
            },
            {
                n = G.UIT.R,
                config = { minh = style.emboss_amount }
            }
        }
    }
end

function clock_ui.reset()
    if G.HUD_clock then
        G.HUD_clock:remove()
    end
    if config.clock_visible and (G.STAGE == G.STAGES.RUN or SystemClock.draw_as_popup) then
        G.HUD_clock = draggable_container({
            config = {
                align = 'cm',
                offset = { x = 0, y = 0 },
                major = G,
                instance_type = SystemClock.draw_as_popup and 'POPUP'
            },
            nodes = {
                create_UIBox_clock(
                    SystemClock.current_preset.style_index,
                    SystemClock.current_preset.size,
                    SystemClock.draw_as_popup
                )
            },
            zoom = true
        })
        G.HUD_clock.states.drag.can = SystemClock.draw_as_popup or config.clock_allow_drag
        local position = SystemClock.current_preset.position
        G.HUD_clock.T.x = position.x
        G.HUD_clock.T.y = position.y

        local temporary_drag = false

        G.HUD_clock.drag = function(self)
            if not config.clock_allow_drag then
                SystemClock.set_draggable(true, true)
                temporary_drag = true
            end
            draggable_container.drag(self)
        end

        G.HUD_clock.stop_drag = function(self)
            draggable_container.stop_drag(self)
            SystemClock.set_position({ x = self.T.x, y = self.T.y })
            if temporary_drag then
                SystemClock.set_draggable(false, true)
                temporary_drag = false
            end
        end
    end
end

return clock_ui
