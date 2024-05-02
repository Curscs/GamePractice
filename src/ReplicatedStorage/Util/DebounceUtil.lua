local Debounce = {}

function Debounce:getDebounceStatus(player, key, amount)
    local theTime = player:GetAttribute(key)
    if theTime == nil then
        player:SetAttribute(key, os.clock())
        return true
    end

    if os.clock() - theTime >= amount then
        player:SetAttribute(key, os.clock())
        return true
    end

    return false
end

function Debounce:format(s)
    return string.format("%02i:%02i:%02i", s / 3600, s / 60 % 60, s % 60)
end

return Debounce