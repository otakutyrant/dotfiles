---@class mp
---@field add_key_binding fun(key: string, name: string, fn: fun())
---@field get_property_native fun(name: string): any
---@field set_property_native fun(name: string, value: any)
---@field osd_message fun(message: string, duration?: number)
---@diagnostic disable-next-line: lowercase-global
---@type mp
mp = mp

mp.add_key_binding("a", "ab-loop-set-a", function()
    mp.set_property_native("ab-loop-a", "no")
    local time_pos = mp.get_property_native("time-pos")
    mp.set_property_native("ab-loop-a", time_pos)
    mp.osd_message("set ab-loop-a")
end)

mp.add_key_binding("s", "ab-loop-set-b", function()
    mp.set_property_native("ab-loop-b", "no")
    local time_pos = mp.get_property_native("time-pos")
    mp.set_property_native("ab-loop-b", time_pos)
    mp.osd_message("set ab-loop-b")
end)

mp.add_key_binding("d", "ab-loop-clear", function()
    mp.set_property_native("ab-loop-a", "no")
    mp.set_property_native("ab-loop-b", "no")
    mp.osd_message("clear ab-loop")
end)
