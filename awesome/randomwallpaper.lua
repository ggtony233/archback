local cjson = require("cjson")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local string = require("string")
local home = os.getenv("HOME")

-- -*- encoding:utf-8 -*-
---- Wallpaper setup function
function set_wallpaper()
--    local WallpaerPath="/gamedisk/SteamLibrary/steamapps/workshop/content/431960"
    local WallpaerPath=config()
    -- Read the JSON file
    local content = ReadDir(WallpaerPath)
    local wallpapers,e = cjson.decode(content)
    if wallpapers == nil or #wallpapers == 0 then
        naughty.notify({ preset = naughty.config.presets.critical,
                        title = "Wallpaper error",
                        text = "The wallpaper list is empty" })
        return
    end
    -- Randomly choose a wallpaper
    local wallpaper = wallpapers[math.random(#wallpapers)]
    local data = io.popen("xprop -root | grep _NET_SUPPORTING")
    local textr = data:read("*all")
    local Wid = string.match(textr,"window id # ([x%x]+)")
    naughty.notify({ title = "WID", text = Wid})
    data:close()
    if wallpaper.type == "Image" then
        gears.wallpaper.fit(wallpaper.path, s)
    elseif wallpaper.type == "Video" then
        awful.spawn.with_shell("xwinwrap -ov -ni -g 2560x1440+0+0 -- mpv --loop --no-audio --Wid="..Wid.." " .. wallpaper.path)
    elseif wallpaper.type == "Html" then
       awful.spawn.with_shell("xwinwrap -ov -ni -g 2560x1440+0+0 -- mpv --no-audio --loop --Wid="..Wid.." " .. wallpaper.path)
    end
end
function ReadDir(path)
    NamedPath = string.gsub(path,"/","_") 
    local f,e = io.open("/home/ggtony/.config/awesome/"..NamedPath..".json", "r")
    if f == nil then
        naughty.notify({ preset = naughty.config.presets.critical,
                        title = "Wallpaper error",
                        text = e })
        os.execute("/usr/local/bin/ScanDir -l "..path.." -o  /home/ggtony/.config/awesome/"..NamedPath..".json")
        local f,e = io.open("/home/ggtony/.config/awesome/"..NamedPath..".json", "r")
        if f == nil then
            naughty.notify({ preset = naughty.config.presets.critical,
                        title = "Wallpaper error",
                        text = e })
           
        end
        return
    end
    local content = f:read("*all")
    f:close()
    return content
end
function config()
    cudir=get_script_path()
    local data = io.open(cudir.."/conf/config.json","r")
    if data == nil then
        naughty.notify({ preset = naughty.config.presets.critical,
                        title = "Wallpaper error",
                        text = cudir })
        return
    end
    local content = data:read("*all")
    data:close()
    local config,e = cjson.decode(content)
    if config == nil then
        naughty.notify({ preset = naughty.config.presets.critical,
                        title = "Wallpaper error",
                        text = e })
        return
    end
    return config.wallpaper_path
end
function get_script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end