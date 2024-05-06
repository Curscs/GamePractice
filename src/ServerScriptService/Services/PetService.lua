local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Knit = require(ReplicatedStorage.Packages.Knit)
local DebounceUtil = require(ReplicatedStorage.Util.DebounceUtil)
local PetModule = require(ReplicatedStorage.Modules.PetModule)
local PetService = Knit.CreateService({
    Name = "PetService",
    Client = {}
})
-- { Client Functions } --
function PetService.Client:TriggerPet(player, petid: string)
    return self.Server:TriggerPet(player, petid)
end

-- { Server Functions } --
function PetService:UnequipPet(petid)
    for _, instance in pairs(Workspace.Animations.PlayerPets:GetChildren()) do
        if instance.Name == petid then
            instance:Destroy()
        end
    end
end

function PetService:EquipPet(player, petid)
    local DataService = Knit.GetService("DataService")
    local Inventory = DataService:GetData(player, "Inventory")
    local Pets = Inventory.Pets
    for _, instance in pairs(ReplicatedStorage.Items.Pets:GetChildren()) do
        if instance.Name == Pets[petid]["Name"] then
            local PetClone = instance:Clone()
            PetClone.Parent = Workspace.Animations.PlayerPets
            PetClone.Name = petid
            PetClone:SetAttribute("Owner", player.Name)
            PetClone:SetAttribute("Name", Pets[petid]["Name"])
            PetClone:AddTag("Pet")
        end
    end
end

function PetService:TriggerPet(player, petid: string)
    if DebounceUtil:getDebounceStatus(player, "LastEquipped", 1) then
        local DataService = Knit.GetService("DataService")
        local Inventory = DataService:GetData(player, "Inventory")
        local Pets = Inventory.Pets
        if Pets[petid]["Equipped"] == false then
            DataService:ChangeData(player, petid, "Equipped", true)
            self:EquipPet(player, petid)
            return "Equipped"
        elseif Pets[petid]["Equipped"] == true then
            DataService:ChangeData(player, petid, "Equipped", false)
            self:UnequipPet(petid)
            return "Unequipped"
        end
        return "Fail"
    end
end

function PetService:KnitStart()
    game.Players.PlayerAdded:Connect(function(player)
        local DataService = Knit.GetService("DataService")
        if DataService:DataCheck(player) == "Success" then
            local Inventory = DataService:GetData(player, "Inventory")
            local Pets = Inventory.Pets
            for id, data in pairs(Pets) do
                if data["Equipped"] == true then
                    print("Hey")
                    self:EquipPet(player, id)
                end
            end
        end
    end)
end

return PetService