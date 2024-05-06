local Pet = {}

function Pet.new(name: string, rarity: string, state: string, damage: number, coinmul: number)
    local self = {}
    self.Name = name
    self.Rarity = rarity
    self.State = state
    self.Damage = damage
    self.CoinMul = coinmul
    self.Equipped = false
    self.Locked = false
    self.Level = 0
    self.Date = 0
    return self
end

Pet.Pets = {
    ["Doggy"] = Pet.new("Doggy", "Common", "Walking", 5, 4),
    ["Kitty"] = Pet.new("Kitty", "Common", "Walking", 4, 5),
    ["???"] = Pet.new("???", "Secret", "Flying", 100, 500000),
}

Pet.Images = {
    ["Doggy"] = "rbxassetid://15001919673",
    ["Kitty"] = "rbxassetid://15001944854",
    ["???"] = "rbxassetid://15432067950",
}

-- { Functions } --
function Pet.GetStat(name: string, stat: string)
    if Pet.Pets[name] then
        return Pet.Pets[name][stat]
    end
end
function Pet.GetAllStats(name: string)
    if Pet.Pets[name] then
        return Pet.Pets[name]
    end
end
function Pet.GetImage(name: string)
    if Pet.Images[name] then
        return Pet.Images[name]
    end
end

return Pet