local clock_ui = {}

local config = require('systemclock.config')
local config_ui = require('systemclock.config_ui')
local locale = require('systemclock.locale')
local draggable_container = require('systemclock.draggablecontainer')

clock_ui.has_dynamic_shadow_colour = false

clock_ui.styles = {
    ['simple'] = {

    },
    ['shadow'] = {
        text_shadow = true
    },
    ['translucent'] = {
        shadow_colour = G.C.UI.TRANSPARENT_DARK,
        shadow_padding = 0.05,
        text_shadow = true
    },
    ['panel'] = {
        shadow_colour = G.C.UI.TRANSPARENT_DARK,
        shadow_padding = 0.02,
        outer_colour_ref = 'back',
        outer_padding = 0.03,
        inner_colour = G.C.DYN_UI.BOSS_DARK,
        inner_padding = 0.05,
        text_padding = 0.05,
        text_shadow = true
    },
    ['emboss'] = {
        shadow_colour_ref = 'shadow',
        outer_colour_ref = 'back',
        emboss_amount = 0.05,
        inner_padding = 0.1,
        text_shadow = true
    },
    ['throwback'] = {
        shadow_colour_ref = 'shadow',
        outer_colour_ref = 'back',
        inner_colour = G.C.DYN_UI.BOSS_DARK,
        outer_width = 1.45,
        outer_height = 1.15,
        outer_padding = 0.01,
        inner_width = 1.2,
        inner_height = 0.7,
        emboss_amount = 0.05,
        heading_text = 'sysclock_time_heading',
        text_shadow = true
    }
}

local function calculate_max_text_width()
    local font = G.LANG.font
    local width = 0
    local string = SystemClock.get_formatted_time(SystemClock.current_format.format_string, true, SystemClock.example_time)
    for _, c in utf8.chars(string) do
        local dx = font.FONT:getWidth(c) * SystemClock.current_preset.size * G.TILESCALE * font.FONTSCALE
        dx = dx + 3 * G.TILESCALE * font.FONTSCALE
        dx = dx / (G.TILESIZE * G.TILESCALE)
        width = width + dx
    end
    return width
end

local function create_clock_h_popup(text, text_size)
    text_size = text_size or 0.35
    local rows = {}

    for i = 1, #text do
        local row = {
            n = G.UIT.R,
            config = { align = 'cm', padding = 0.05 * text_size },
            nodes = {
                {
                    n = G.UIT.T,
                    config = {
                        text = text[i],
                        shadow = true,
                        colour = G.C.UI.TEXT_LIGHT,
                        scale = text_size
                    }
                }
            }
        }
        table.insert(rows, row)
    end

    local h_popup = {
        n = G.UIT.ROOT,
        config = {
            padding = 0.1,
            r = 0.1,
            colour = { 0.205, 0.246, 0.253, 0.9 }
        },
        nodes = {
            {
                n = G.UIT.C,
                nodes = rows
            }
        }
    }

    return h_popup
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
        pop_in_rate = 9999999,
        float = float,
        silent = silent,
    })

    return {
        n = G.UIT.O,
        config = {
            align = 'cm',
            id = 'sysclock_clock_text',
            object = dynaText
        }
    }
end

local function create_clock_UIBox(style_name, text_size, float)
    style_name = style_name or 'simple'
    text_size = text_size or 1

    local colours = SystemClock.assign_clock_colours()

    local style = clock_ui.styles[style_name] or {}

    clock_ui.has_dynamic_shadow_colour = style.shadow_colour_ref == 'shadow'

    local panel_outer_colour = style.outer_colour or style.outer_colour_ref and colours[style.outer_colour_ref] or G.C.CLEAR
    local panel_inner_colour = style.inner_colour or style.inner_colour_ref and colours[style.inner_colour_ref] or G.C.CLEAR
    local panel_shadow_colour = style.shadow_colour or style.shadow_colour_ref and colours[style.shadow_colour_ref] or G.C.CLEAR
    local text_colours = style.text_colours or (style.text_colour and { style.text_colour }) or (style.text_colour_ref and { colours[style.text_colour_ref] }) or { colours.text }

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
                                    padding = 0.02
                                },
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = locale.translate('sysclock_time_heading'),
                                            minh = 1,
                                            scale = 0.85 * 0.4,
                                            colour = G.C.UI.TEXT_LIGHT,
                                            shadow = style.text_shadow
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

function clock_ui.reset(juice)
    local prev_pos
    if G.HUD_clock then
        prev_pos = { x = G.HUD_clock.T.x, y = G.HUD_clock.T.y }
        G.HUD_clock:remove()
    end
    if config.clock_visible and (config.clock_persistent or G.STAGE == G.STAGES.RUN or SystemClock.draw_as_popup) then
        local position = SystemClock.current_preset.position
        prev_pos = prev_pos or position

        local tooltip_popup = config.clock_right_click_tutorial and create_clock_h_popup(locale.translate('sysclock_right_click_tooltip'))

        G.HUD_clock = draggable_container(
            {
                T = { x = position.x, y = position.y },
                VT = { x = prev_pos.x, y = prev_pos.y },
                config = {
                    major = G,
                    bond = 'Weak',
                    instance_type = SystemClock.draw_as_popup and 'POPUP',
                    h_popup = tooltip_popup
                },
                definition = create_clock_UIBox(
                    SystemClock.current_preset.style,
                    SystemClock.current_preset.size,
                    config_ui.is_open
                ),
                zoom = true,
                can_drag = config.clock_allow_drag or config_ui.is_open
            }
        )

        local temporary_drag = false

        G.HUD_clock.drag = function(self)
            if not config.clock_allow_drag then
                temporary_drag = true
                SystemClock.set_draggable(true, true)
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

        if juice then G.HUD_clock:juice_up(0.1, 0.1) end
    end
end

return clock_ui
