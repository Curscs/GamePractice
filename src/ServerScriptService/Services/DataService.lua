local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local DatastoreModule = require(ServerStorage.Datastore)
local UIUtil = require(ReplicatedStorage.Util.IDUtil)
local PetModule = require(ReplicatedStorage.Modules.PetModule)

local DataService = Knit.CreateService {
    Name = "DataService",
    Client = {},
    DataKey = "v1.85";
    DataTemplate = {
        Coins = 1000000;
        Gems = 0;
        Eggs = 0;
        Inventory = {
            Swords = {};
            Pets = {};
            Items = {};
        };
        Misc = {
            InventorySpace = 100
        }
    };
    DataDisplay = {"Coins", "Gems", "Eggs"};
    CurrencyImages = {
        ["Coins"] = "rbxassetid://11566087944"
    }
}
-- { Client Functions } --
function DataService.Client:GetData(player, currency: string)
    return self.Server:GetData(player, currency)
end

function DataService.Client:GetCurrencyImage(player, currency)
    return self.Server:GetCurrencyImage(currency)
end

-- { Server Functions } --
function DataService:GetCurrencyImage(currency: string)
    if self.CurrencyImages[currency] then
        return self.CurrencyImages[currency]
    end
end

function DataService:ChangeData(player, petid: string, currency: string, value: number | string | boolean)
    local Datastore = DatastoreModule.find(self.DataKey, player.UserId)
    if currency == "Equipped" then
        Datastore.Value["Inventory"]["Pets"][petid][currency] = value
    end
end

function DataService:AddPet(player, petname: string)
    local Datastore = DatastoreModule.find(self.DataKey, player.UserId)
    local PetsInv = Datastore.Value["Inventory"]["Pets"]
    local PetStats = PetModule.GetAllStats(petname)
    PetStats["CoinMul"] = nil
    PetStats["Rarity"] = nil
    PetStats["Damage"] = nil
    PetStats["Date"] = os.time()
    local ID = UIUtil:GenerateID(6)
    if PetsInv then
        if PetsInv[ID] then
            ID = UIUtil:GenerateID(6)
        end
        PetsInv[ID] = PetStats
    end
end

function DataService:RemoveCurrency(player, currency: string, amount: number)
    local Datastore = DatastoreModule.find(self.DataKey, player.UserId)
	if Datastore.Value[currency] then
		if Datastore.Value[currency] >= amount then
			Datastore.Value[currency] -= amount
			if Datastore.Leaderstats[currency] then
                self:UpdateLeaderstats(player, currency)
            end
            return "Success"
        end
    else
        error("Failed to find" .. currency)
    end
end

function DataService:AddCurrency(player, currency: string, amount: number)
    local Datastore = DatastoreModule.find(self.DataKey, player.UserId)
    if Datastore.Value[currency] then
        Datastore.Value[currency] += amount
        if Datastore.Leaderstats[currency] then
            self:UpdateLeaderstats(player, currency)
        end
        return "Success"
    else
        error("Failed to find" .. currency)
    end
end

function DataService:GetData(player, currency: string)
    local Datastore = DatastoreModule.find(self.DataKey, player.UserId)
    if Datastore.Value[currency] then
        return Datastore.Value[currency]
    else
        error("Failed to find" .. currency)
    end
end

function DataService:UpdateLeaderstats(player, currency: string)
    local Datastore = DatastoreModule.find(self.DataKey, player.UserId)
    Datastore.Leaderstats[currency].Value = Datastore.Value[currency]
end

function DataService:DataCheck(player)
    local Datastore = DatastoreModule.find(self.DataKey, player.UserId)
    while Datastore.State ~= true do
        task.wait(0.1)
    end
    while not player:FindFirstChild("leaderstats") do
        task.wait(0.1)
    end
    return "Success"
end

-- { Local Functions } --

function CreateDatastore()
    local function StateChanged(state, datastore)
        while datastore.State == false do
            if datastore:Open(DataService.DataTemplate) ~= "Success" then task.wait(6) end
        end
    end
    game.Players.PlayerAdded:Connect(function(player)
        local Datastore = DatastoreModule.new(DataService.DataKey, player.UserId)
        Datastore.StateChanged:Connect(StateChanged)
        StateChanged(Datastore.State, Datastore)
    end)
    game.Players.PlayerRemoving:Connect(function(player)
        local Datastore = DatastoreModule.find(DataService.DataKey, player.UserId)
        if Datastore ~= nil then Datastore:Destroy() end
    end)
end

function CreateLeaderstats()
    local function StateChanged(datastore, state, player, leaderstats)
        while state ~= true do return end
        if DataService:DataCheck(player) == "Success" then
            for i, stat in pairs(leaderstats:GetChildren()) do
                datastore.Leaderstats[stat.Name].Value = datastore.Value[stat.Name]
            end
        end
    end

    game.Players.PlayerAdded:Connect(function(player)
        local leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player

        for _, stat in pairs(DataService.DataDisplay) do
            if DataService.DataTemplate[stat] then
                local IntValue = Instance.new("IntValue")
                IntValue.Name = stat
                IntValue.Parent = leaderstats
            end
        end

        local Datastore = DatastoreModule.new(DataService.DataKey, player.UserId)
        Datastore.Leaderstats = leaderstats
        Datastore.StateChanged:Connect(function()
            StateChanged(Datastore, Datastore.State, player, leaderstats)
        end)
    end)
end
-- { Run Line } --
function DataService:KnitStart()
    CreateDatastore()
    CreateLeaderstats()
end

return DataService
