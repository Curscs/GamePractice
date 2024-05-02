local Egg = {}

function Egg.new(name: string, currency: string, price: number, pets: table)
    local self = {}
    self.Name = name
    self.Currency = currency
    self.Price = price
    self.Pets = pets
    return self
end

Egg.Eggs = {
    ["Common Egg"] = Egg.new("Common Egg", "Coins", 100, {
        ["Doggy"] = 30,
        ["Kitty"] = 20,
        ["???"] = 1,
    })
}

-- { Functions } --
function Egg.GetAllPets(name: string)
    if Egg.Eggs[name].Pets then
        return Egg.Eggs[name]["Pets"]
    end
end
function Egg.GetPet(eggname: string, petname:string)
    if Egg.Eggs[eggname].Pets[petname] then
        return Egg.Eggs[eggname].Pets[petname]
    end
end
function Egg.GetCurrency(name: string)
    if Egg.Eggs[name] then
        return Egg.Eggs[name]["Currency"]
    end
end
function Egg.GetPrice(name: string)
    if Egg.Eggs[name] then
        return Egg.Eggs[name]["Price"]
    end
end

return Egg