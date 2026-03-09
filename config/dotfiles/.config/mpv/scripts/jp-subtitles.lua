-- this whole script was made to make learning japanese smoother, by allowing
-- me to watch media with japanese subtitles and copy and/or open them in
-- yomitan/jisho for help

require 'mp'
require 'mp.msg'

-- NOTE just set your prefered chromium browser
BROWSER = "vivaldi"

WINDOWS = package.config:sub(1,1) == "\\"

local char_to_hex = function(c)
    return string.format("%%%02X", string.byte(c))
end

local function urlencode(url)
    if url == nil then
        return
    end
    url = url:gsub("\n", "\r\n")
    url = url:gsub("([^%w ])", char_to_hex)
    url = url:gsub(" ", "+")
    return url
end

local function set_clipboard(text)
    if WINDOWS then
        mp.commandv("run", "powershell", "set-clipboard", table.concat({'"', text, '"'}))
    else
        local pipe = io.popen("wl-copy", "w")
        pipe:write(text)
        pipe:close()
    end
end

local function browser(url)
    if WINDOWS then
        -- TODO untested
        mp.commandv("run", BROWSER .. ".exe ", url)
    else
        mp.commandv("run", BROWSER, url)
    end
end

local function copy_subtitle()
    local subtitle = string.format("%s", mp.get_property_osd("sub-text"))

    if subtitle == "" then
        mp.osd_message("There are no displayed subtitles.")
        return
    end

    set_clipboard(subtitle)

    mp.osd_message("Copied to clipboard")
end

-- the url prefix for yomitan (the extension id should not change unless manually compiled)
YOMITAN_URL = "chrome-extension://likgccmbimhjbgkjambclfkhldnlhbnn/search.html?query="
local function open_in_yomitan()
    local subtitle = string.format("%s", mp.get_property_osd("sub-text"))

    if subtitle == "" then
        mp.osd_message("There are no displayed subtitles.")
        return
    end

    mp.osd_message("Opening yomitan (" .. BROWSER .. ")")

    browser(YOMITAN_URL .. urlencode(subtitle))
end

JISHO_URL = "https://jisho.org/search/"
local function open_in_jisho()
    local subtitle = string.format("%s", mp.get_property_osd("sub-text"))

    if subtitle == "" then
        mp.osd_message("There are no displayed subtitles.")
        return
    end

    mp.osd_message("Opening jisho  (" .. BROWSER .. ")")

    browser(JISHO_URL .. urlencode(subtitle))
end

mp.add_key_binding("Alt+c", "copy_subtitle", copy_subtitle)
mp.add_key_binding("Alt+y", "open_in_yomitan", open_in_yomitan)
mp.add_key_binding("Alt+j", "open_in_jisho", open_in_jisho)
