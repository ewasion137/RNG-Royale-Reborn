local Format = {}

function Format.number(value)
    local negative = value < 0
    local n = math.abs(math.floor(value))
    local str = tostring(n)
    local formatted = str:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if formatted:sub(1, 1) == "," then
        formatted = formatted:sub(2)
    end
    return negative and ("-" .. formatted) or formatted
end

function Format.money(value)
    return Format.number(value) .. "$"
end

function Format.time(seconds)
    seconds = math.max(0, math.floor(seconds))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    if hours >= 1 then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    end
    return string.format("%02d:%02d", minutes, secs)
end

return Format
