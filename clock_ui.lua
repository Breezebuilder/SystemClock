function SystemClock.calculate_max_text_width(format_index)
    format_index = format_index or SystemClock.current.format
    local format = SystemClock.CLOCK_FORMATS[format_index]
    local font = G.LANG.font
    local width = 0
    local string = SystemClock.get_formatted_time(format, SystemClock.example_time, true)
    for _, c in utf8.chars(string) do
        local dx = font.FONT:getWidth(c) * SystemClock.current.size * G.TILESCALE * font.FONTSCALE +
            3 * G.TILESCALE * font.FONTSCALE
        dx = dx / (G.TILESIZE * G.TILESCALE)
        width = width + dx
    end
    return width
end

function SystemClock.create_UIBox_clock(style, text_size, colours, float)
    style = style or 2
    text_size = text_size or 1
    colours = colours or { text = G.C.WHITE, back = G.C.BLACK }

    local translucent_colour = (style == 3 or style == 4) and G.C.UI.TRANSPARENT_DARK or G.C.CLEAR
    local panel_outer_colour = (style == 4) and colours.back or G.C.CLEAR
    local panel_inner_colour = (style == 4) and G.C.DYN_UI.BOSS_DARK or (style == 5) and colours.back or G.C.CLEAR
    local panel_shadow_colour = (style == 5) and colours.shadow or G.C.CLEAR
    local emboss_amount = (style == 5) and 0.05 or 0
    local inner_width = SystemClock.calculate_max_text_width()

    return {
        n = G.UIT.ROOT,
        config = {
            align = 'cm',
            padding = 0.03,
            colour = translucent_colour,
            r = 0.1
        },
        nodes = {
            {
                n = G.UIT.R,
                config = {
                    align = 'cm',
                    padding = 0.05,
                    colour = panel_outer_colour,
                    r = 0.1
                },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = {
                            align = 'tm',
                            r = 0.1,
                            minw = 0.1,
                            colour = panel_shadow_colour,
                        },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = {
                                    align = 'cm',
                                    colour = panel_inner_colour,
                                    r = 0.1,
                                    minw = 0.5,
                                    padding = 0.03
                                },
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = {
                                            align = 'cm',
                                            padding = 0.03,
                                            minw = inner_width,
                                            r = 0.1
                                        },
                                        nodes = { SystemClock.create_clock_DynaText(style, text_size, colours, float) }
                                    }
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { minh = emboss_amount }
                            }
                        }
                    }
                }
            }
        }
    }
end

function SystemClock.create_clock_DynaText(style, text_size, colours, float)
    local dynaText = DynaText({
        string = { {
            ref_table = SystemClock,
            ref_value = 'time'
        } },
        colours = { colours.text },
        scale = text_size,
        shadow = (style > 1),
        pop_in = 0,
        pop_in_rate = 10,
        float = float,
        silent = true,
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

function SystemClock.reset_clock_ui()
    if G.HUD_clock then
        G.HUD_clock:remove()
    end
    if G.STAGE == G.STAGES.RUN and SystemClock.config.clock_visible then
        G.HUD_clock = MoveableContainer({
            config = {
                align = 'cm',
                offset = { x = 0, y = 0 },
                major = G,
                instance_type = SystemClock.draw_as_popup and 'POPUP'
            },
            nodes = {
                SystemClock.create_UIBox_clock(
                    SystemClock.current.style,
                    SystemClock.current.size,
                    SystemClock.assign_clock_colours(),
                    SystemClock.draw_as_popup
                )
            }
        })
        G.HUD_clock.states.drag.can = SystemClock.config.clock_allow_drag
        local position = SystemClock.current.position
        G.HUD_clock.T.x = position.x
        G.HUD_clock.T.y = position.y

        G.HUD_clock.stop_drag = function(self)
            MoveableContainer.stop_drag(self)
            SystemClock.current.position = { x = self.T.x, y = self.T.y }
            SystemClock.save_config()
            SystemClock.update_config_position_sliders()
        end
    end
end
