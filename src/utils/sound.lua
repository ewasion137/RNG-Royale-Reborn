local Settings = require("src.utils.settings")

local Sound = {
    sources = {},
    music = nil,
    music_name = nil,
}

function Sound.load()
    local sound_files = love.filesystem.getDirectoryItems("assets/sounds")
    for _, file in ipairs(sound_files) do
        local path = "assets/sounds/" .. file
        Sound.sources[file] = love.audio.newSource(path, "static")
    end
end

function Sound.play_sfx(name)
    if Settings.sfx_volume <= 0 then return end
    local source = Sound.sources[name]
    if not source then return end

    local clone = source:clone()
    clone:setVolume(Settings.sfx_volume)
    clone:play()
end

function Sound.play_music(name)
    if Sound.music_name == name and Sound.music then
        return
    end

    Sound.stop_music()
    local source = Sound.sources[name]
    if not source then return end

    Sound.music = source:clone()
    Sound.music:setLooping(true)
    Sound.music:setVolume(Settings.music_volume)
    Sound.music:play()
    Sound.music_name = name
end

function Sound.stop_music()
    if Sound.music then
        Sound.music:stop()
        Sound.music = nil
        Sound.music_name = nil
    end
end

function Sound.set_music_volume(volume)
    Settings.music_volume = volume
    if Sound.music then
        Sound.music:setVolume(volume)
    end
end

function Sound.fade_out_music(duration)
    duration = duration or 0.3
    if not Sound.music then return end

    local start_volume = Sound.music:getVolume()
    local elapsed = 0
    while elapsed < duration do
        elapsed = elapsed + love.timer.getDelta()
        local progress = math.min(elapsed / duration, 1)
        Sound.music:setVolume(start_volume * (1 - progress))
        coroutine.yield()
    end
    Sound.music:setVolume(0)
end

function Sound.fade_in_music(target_volume, duration)
    duration = duration or 0.5
    if not Sound.music then return end

    local elapsed = 0
    while elapsed < duration do
        elapsed = elapsed + love.timer.getDelta()
        local progress = math.min(elapsed / duration, 1)
        Sound.music:setVolume(target_volume * progress)
        coroutine.yield()
    end
    Sound.music:setVolume(target_volume)
end

return Sound
