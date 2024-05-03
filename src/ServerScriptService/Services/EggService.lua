local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local EggModule = require(ReplicatedStorage.Modules.EggModule)
local DebounceUtil = require(ReplicatedStorage.Util.DebounceUtil)

local EggService = Knit.CreateService({
    Name = "EggService",
    Client = {}
})

-- { Client Functions } --
function EggService.Client:OpenEgg(player, eggname: string, type: number)
    if DebounceUtil:getDebounceStatus(player, "LastHatched", 4) then
        return self.Server:OpenEgg(player, eggname, type)
    end
end

-- { Server Functions } --
function EggService:OpenEgg(player, eggname: string, type: number)
    local DataService = Knit.GetService("DataService")
    if DataService:RemoveCurrency(player, EggModule.GetCurrency(eggname), EggModule.GetPrice(eggname) * type) == "Success" then
        local Petnames = {}
        for i = 1 , type do
            Petnames[i] = self:SelectRandomPet(eggname)
            DataService:AddPet(player, Petnames[i])
        end
        return Petnames
    end
end

function EggService:SelectRandomPet(eggname: string)
    local totalchance = 0
    local tempchance = 0

    for _, chance in pairs(EggModule.GetAllPets(eggname)) do
        totalchance += chance
    end

    local RandomNum = math.random() * totalchance

    for petname, chance in pairs(EggModule.GetAllPets(eggname)) do
        tempchance += chance
        if RandomNum <= tempchance then
            return petname
        end
    end
end

return EggService