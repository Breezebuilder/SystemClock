function SystemClock.calculate_max_text_width(formatIndex)
    formatIndex = formatIndex or SystemClock.current.format
    local format = SystemClock.CLOCK_FORMATS[formatIndex]
    local font = G.LANG.font
    local width = 0
    local string = SystemClock.get_formatted_time(format, SystemClock.exampleTime, true)
    for _, c in utf8.chars(string) do
        local dx = font.FONT:getWidth(c) * SystemClock.current.size * G.TILESCALE * font.FONTSCALE +
            3 * G.TILESCALE * font.FONTSCALE
        dx = dx / (G.TILESIZE * G.TILESCALE)
        width = width + dx
    end
    return width
end

function SystemClock.create_UIBox_clock(style, textSize, colours, float)
    style = style or 2
    textSize = textSize or 1
    colours = colours or { text = G.C.WHITE, back = G.C.BLACK }

    local translucentColour = (style == 3 or style == 4) and G.C.UI.TRANSPARENT_DARK or G.C.CLEAR
    local panelOuterColour = (style == 4) and colours.back or G.C.CLEAR
    local panelInnerColour = (style == 4) and G.C.DYN_UI.BOSS_DARK or (style == 5) and colours.back or G.C.CLEAR
    local panelShadowColour = (style == 5) and colours.shadow or G.C.CLEAR
    local embossAmount = (style == 5) and 0.05 or 0
    local innerWidth = SystemClock.calculate_max_text_width()

    return {
        n = G.UIT.ROOT,
        config = {
            align = 'cm',
            padding = 0.03,
            colour = translucentColour,
            r = 0.1
        },
        nodes = {
            {
                n = G.UIT.R,
                config = {
                    align = 'cm',
                    padding = 0.05,
                    colour = panelOuterColour,
                    r = 0.1
                },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = {
                            align = 'tm',
                            r = 0.1,
                            minw = 0.1,
                            colour = panelShadowColour,
                        },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = {
                                    align = 'cm',
                                    colour = panelInnerColour,
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
                                            minw = innerWidth,
                                            r = 0.1
                                        },
                                        nodes = { SystemClock.create_clock_DynaText(style, textSize, colours, float) }
                                    }
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { minh = embossAmount }
                            }
                        }
                    }
                }
            }
        }
    }
end

function SystemClock.create_clock_DynaText(style, textSize, colours, float)
    local dynaText = DynaText({
        string = { {
            ref_table = SystemClock,
            ref_value = 'time'
        } },
        colours = { colours.text },
        scale = textSize,
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
    if G.STAGE == G.STAGES.RUN and SystemClock.config.clockVisible then
        G.HUD_clock = MoveableContainer({
            config = {
                align = 'cm',
                offset = { x = 0, y = 0 },
                major = G,
                instance_type = SystemClock.drawAsPopup and 'POPUP'
            },
            nodes = {
                SystemClock.create_UIBox_clock(
                    SystemClock.current.style,
                    SystemClock.current.size,
                    SystemClock.get_clock_colours(),
                    SystemClock.drawAsPopup
                )
            }
        })
        G.HUD_clock.states.drag.can = SystemClock.config.clockAllowDrag
        local position = SystemClock.current.position
        G.HUD_clock.T.x = position.x
        G.HUD_clock.T.y = position.y

        G.HUD_clock.move = function(self, dt)
            MoveableContainer.move(self, dt)
            SystemClock.current.position = { x = self.T.x, y = self.T.y }
        end

        G.HUD_clock.stop_drag = function(self)
            MoveableContainer.stop_drag(self)
            SystemClock.save_mod_config()
            SystemClock.update_config_position_sliders()
        end
    end
end
