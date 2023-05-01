-- ___Usage___:
--- ab-loop-sub [autopause]: Set ab-loop to current subtitle. Specify 'autopause' arg to pause before every loop
--- copy-subtitle:           Copy current subtitle to clipboard. Works on mac 10.13 and windows 10

_G.abloopavoidjankpause = false

function pause_on_sub_loop(prop, value)
    if _G.abloopavoidjankpause == true then
        _G.abloopavoidjankpause = false
        return
    end
    if value and value ~= '' then
        local startloop = mp.get_property("ab-loop-a")
        local substart = mp.get_property("sub-start")
        if substart and startloop and substart == startloop then
            mp.set_property("pause", "yes")
        end
    end
end

function ab_loop_sub(autopause)
    local existingloop = mp.get_property_number("ab-loop-b")
    if existingloop then
        mp.osd_message("Clear A-B Loop", 0.5)

        mp.set_property("ab-loop-a", "no")
        mp.set_property("ab-loop-b", "no")

        mp.unobserve_property(pause_on_sub_loop)
        mp.set_property("pause", "no")
    else
        local substart = mp.get_property("sub-start")
        local subend = mp.get_property("sub-end")

        if substart and subend then
            mp.osd_message("A-B Loop Subtitle", 0.5)

            local suboffset = mp.get_property("sub-delay")
            mp.set_property_number("ab-loop-a", substart  + suboffset)
            mp.set_property_number("ab-loop-b", subend + suboffset + 0.075)

            _G.abloopavoidjankpause = true
            if autopause then mp.observe_property("sub-text", "native", pause_on_sub_loop) end
        else
            mp.osd_message("No subtitles present", 0.5)
        end
    end

end

function escape(s)
  return (s:gsub('\'', '\'\\\'\''))
end

function copy_subtitle()
    local subtext = mp.get_property("sub-text")
    if subtext and subtext ~= '' then
        os.execute("echo '" .. escape(subtext) .. "' | xclip -selection clipboard -i")
        mp.osd_message(subtext, 0.5)
    else
        mp.osd_message("No subtitles present", 0.5)
    end
end

mp.add_key_binding(nil, "ab-loop-sub", ab_loop_sub)
mp.add_key_binding(nil, "copy-subtitle", copy_subtitle)
