local Rarity = {}

local secretColors = {
    Color3.fromRGB(237, 41, 255),    -- #ed29ff
    Color3.fromRGB(123, 1, 229),     -- #7b01e5
    Color3.fromRGB(229, 19, 236)     -- #e513ec
}

function CreateSecretColorSequence()
    local colorSequence = {}

    for i, color in ipairs(secretColors) do
        table.insert(colorSequence, ColorSequenceKeypoint.new((i - 1) / (#secretColors - 1), color))
    end

    return ColorSequence.new(colorSequence)
end

Rarity.Colors = {
    ["Common"] = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
    ["Secret"] = CreateSecretColorSequence()
}

return Rarity