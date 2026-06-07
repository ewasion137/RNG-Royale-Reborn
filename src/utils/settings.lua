local json = require("src.utils.json")

local Settings = {
    music_volume = 0.5,
    sfx_volume = 0.3,
}

local SETTINGS_FILE = "settings.json"

function Settings.load()
    if not love.filesystem.getInfo(SETTINGS_FILE) then
        return
    end

    local ok, data = pcall(function()
        return json.decode(love.filesystem.read(SETTINGS_FILE))
    end)

    if ok and data then
        Settings.music_volume = data.MusicVolume or Settings.music_volume
        Settings.sfx_volume = data.SfxVolume or Settings.sfx_volume
    end
end

function Settings.save()
    love.filesystem.write(SETTINGS_FILE, json.encode({
        MusicVolume = Settings.music_volume,
        SfxVolume = Settings.sfx_volume,
    }))
end

return Settings
