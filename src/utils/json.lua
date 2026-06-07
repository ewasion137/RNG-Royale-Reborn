local json = {}

local escape_map = {
    ["\\"] = "\\\\",
    ["\""] = "\\\"",
    ["\b"] = "\\b",
    ["\f"] = "\\f",
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\t"] = "\\t",
}

local function escape_string(value)
    return value:gsub('[\\"%z\1-\31]', function(char)
        return escape_map[char] or string.format("\\u%04x", char:byte())
    end)
end

local function is_array(tbl)
    local count = 0
    for k in pairs(tbl) do
        if type(k) ~= "number" then
            return false
        end
        count = count + 1
    end
    return count == #tbl
end

function json.encode(value)
    local t = type(value)
    if t == "nil" then
        return "null"
    elseif t == "boolean" then
        return value and "true" or "false"
    elseif t == "number" then
        if value ~= value or value == math.huge or value == -math.huge then
            error("invalid number")
        end
        return string.format("%.14g", value)
    elseif t == "string" then
        return '"' .. escape_string(value) .. '"'
    elseif t == "table" then
        if is_array(value) then
            local parts = {}
            for i = 1, #value do
                parts[i] = json.encode(value[i])
            end
            return "[" .. table.concat(parts, ",") .. "]"
        end

        local parts = {}
        for k, v in pairs(value) do
            if type(k) == "string" then
                table.insert(parts, json.encode(k) .. ":" .. json.encode(v))
            end
        end
        table.sort(parts)
        return "{" .. table.concat(parts, ",") .. "}"
    end
    error("unsupported type: " .. t)
end

local function skip_whitespace(str, pos)
    return str:find("%S", pos) or (#str + 1)
end

local function decode_value(str, pos)
    pos = skip_whitespace(str, pos)
    local char = str:sub(pos, pos)

    if char == "{" then
        local obj = {}
        pos = pos + 1
        pos = skip_whitespace(str, pos)
        if str:sub(pos, pos) == "}" then
            return obj, pos + 1
        end
        while true do
            local key
            key, pos = decode_value(str, pos)
            pos = skip_whitespace(str, pos)
            assert(str:sub(pos, pos) == ":", "expected colon")
            pos = pos + 1
            local value
            value, pos = decode_value(str, pos)
            obj[key] = value
            pos = skip_whitespace(str, pos)
            local next_char = str:sub(pos, pos)
            if next_char == "}" then
                return obj, pos + 1
            end
            assert(next_char == ",", "expected comma")
            pos = pos + 1
        end
    elseif char == "[" then
        local arr = {}
        pos = pos + 1
        pos = skip_whitespace(str, pos)
        if str:sub(pos, pos) == "]" then
            return arr, pos + 1
        end
        while true do
            local value
            value, pos = decode_value(str, pos)
            table.insert(arr, value)
            pos = skip_whitespace(str, pos)
            local next_char = str:sub(pos, pos)
            if next_char == "]" then
                return arr, pos + 1
            end
            assert(next_char == ",", "expected comma")
            pos = pos + 1
        end
    elseif char == '"' then
        local buffer = {}
        pos = pos + 1
        while true do
            local c = str:sub(pos, pos)
            if c == '"' then
                return table.concat(buffer), pos + 1
            elseif c == "\\" then
                local esc = str:sub(pos + 1, pos + 1)
                if esc == "u" then
                    local hex = str:sub(pos + 2, pos + 5)
                    table.insert(buffer, string.char(tonumber(hex, 16)))
                    pos = pos + 6
                else
                    local map = { b = "\b", f = "\f", n = "\n", r = "\r", t = "\t", ["\\"] = "\\", ['"'] = '"' }
                    table.insert(buffer, map[esc] or esc)
                    pos = pos + 2
                end
            else
                table.insert(buffer, c)
                pos = pos + 1
            end
        end
    elseif str:sub(pos, pos + 3) == "true" then
        return true, pos + 4
    elseif str:sub(pos, pos + 4) == "false" then
        return false, pos + 5
    elseif str:sub(pos, pos + 3) == "null" then
        return nil, pos + 4
    else
        local num = str:match("^%-?%d+%.?%d*[eE]?[%+%-]?%d*", pos)
        assert(num, "invalid number at " .. pos)
        return tonumber(num), pos + #num
    end
end

function json.decode(str)
    local value, pos = decode_value(str, 1)
    pos = skip_whitespace(str, pos)
    assert(pos > #str, "trailing data")
    return value
end

return json
