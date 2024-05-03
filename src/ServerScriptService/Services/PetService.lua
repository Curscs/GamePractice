local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local DebounceUtil = require(ReplicatedStorage.Util.DebounceUtil)

local PetService = Knit.CreateService({
    Name = "PetService",
    Client = {}
})
-- { Client Functions } --
function PetService.Client:TriggerPet(player, petid: string)
    if DebounceUtil:getDebounceStatus(player, "LastEquipped", 1) then
        return self.Server:TriggerPet(player, petid)
    end
end

-- { Server Functions } --
function PetService:TriggerPet(player, petid: string)
    local DataService = Knit.GetService("DataService")
    local Inventory = DataService:GetData(player, "Inventory")
    local Pets = Inventory.Pets
    if Pets[petid]["Equipped"] == false then
        DataService:ChangeData(player, petid, "Equipped", true)
        return "Success"
    elseif Pets[petid]["Equipped"] == true then
        DataService:ChangeData(player, petid, "Equipped", false)
        return "Success"
    end
    return "Fail"
end

return PetService