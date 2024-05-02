local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Player = game.Players.LocalPlayer
local Component = require(ReplicatedStorage.Packages.Component)
local EggModule = require(ReplicatedStorage.Modules.EggModule)
local PetModule = require(ReplicatedStorage.Modules.PetModule)
-- { Globals } --
local Connections = {}
-- { Gui Elements } --
local Misc = ReplicatedStorage:WaitForChild("Misc")
local EggUI = Misc:WaitForChild("EggUI")

local Egg = Component.new({
    Tag = "Egg",
})

function Egg:Construct()
    self.Range = 5
end

function Egg:CollideFalse(EggInstance)
    for _, instance in pairs(EggInstance:GetChildren()) do
        instance.CanCollide = false
    end
end

function Egg:EggOpened(EggInstance, pets, type: number)
    local Pets = {}
    for i, pet in pairs(pets) do
        Pets[i] = ReplicatedStorage.Items.Pets[pet]
    end
    x = nil
    for i = 1, type do
        local EggsRepFolder = ReplicatedStorage.Items.Eggs
        local EggClone = EggsRepFolder[EggInstance.Name]:Clone()
        self:CollideFalse(EggClone)
        EggClone:PivotTo(CFrame.new(0,-90,0))
        x = EggClone
        EggClone.Name = i
        EggClone.Parent = workspace.Animations.EggHatching
        EggClone:SetAttribute("Type", "Egg")
        EggClone:AddTag("EggAnimation")
    end
    while x:HasTag("EggAnimation") do
        task.wait(0.1)
    end
    for _, pet in pairs(Pets) do
        local PetClone = pet:Clone()
        PetClone.Parent = Workspace.Animations.EggHatching
        PetClone:SetAttribute("Type", "Pet")
        PetClone:AddTag("EggAnimation")
    end
end

function Egg:OnKeyPressed(input, EggInstance)
    local pets = {}
    local EggService = Knit.GetService("EggService")
    local Children = Workspace.Animations.EggHatching:GetChildren()
    if input.KeyCode == Enum.KeyCode.E and #Children == 0 then
        pets[1] = EggService:OpenEgg(EggInstance.Name, 1)
        if pets[1] ~= nil then
            self:EggOpened(EggInstance, pets, 1)
        end
    elseif input.KeyCode == Enum.KeyCode.R and #Children == 0 then
        pets = EggService:OpenEgg(EggInstance.Name, 3)
        if pets ~= nil then
            self:EggOpened(EggInstance, pets, 3)
        end
    end
end

function Egg:CreateEggUI(EggInstance)
    local DataService = Knit.GetService("DataService")
    local EggUIClone = EggUI:Clone()
    local PetTemplate = EggUIClone["Frame"]["Pets"]["Template"]
    local EggPrice = EggUIClone["Bottom"]["Currency"]["Amount"]
    local EggCurrencyIcon = EggUIClone["Bottom"]["Currency"]["Icon"]
    for petname, chance in pairs(EggModule.GetAllPets(EggInstance.Name)) do
        local PetTemplateClone = PetTemplate:Clone()
        PetTemplateClone.Parent = EggUIClone["Frame"]["Pets"]
        PetTemplateClone.LayoutOrder = -chance
        PetTemplateClone.Name = petname
        PetTemplateClone["Chance"].Text = chance .. "%"
        PetTemplateClone["Inner"]["Icon"].Image = PetModule.GetImage(petname)
        PetTemplateClone.Visible = true
    end
    EggPrice.Text = EggModule.GetPrice(EggInstance.Name)
    EggCurrencyIcon.Image = DataService:GetCurrencyImage(EggModule.GetCurrency(EggInstance.Name))
    EggUIClone.Parent = EggInstance.PrimaryPart
    EggUIClone.Enabled = true
end

Egg.Started:Connect(function(component)
    local eggFullName = component.Instance:GetFullName()
    Connections[eggFullName] = game:GetService("RunService").Heartbeat:Connect(function()
        local EggInstance = component.Instance
        local Character = Player.Character or Player.Character:Wait()
        local HRP = Character:WaitForChild("HumanoidRootPart")
        local Distance = (EggInstance.PrimaryPart.Position - HRP.Position).magnitude

        if not EggInstance.PrimaryPart:FindFirstChildOfClass("BillboardGui") and Distance <= component.Range then
            Egg:CreateEggUI(EggInstance)
            if Connections[eggFullName .. "_InputDetect"] then Connections[eggFullName .. "_InputDetect"]:Disconnect() Connections[eggFullName .. "_InputDetect"] = nil end
            Connections[eggFullName .. "_InputDetect"] = game:GetService("UserInputService").InputBegan:Connect(function(input)
                Egg:OnKeyPressed(input, EggInstance)
            end)
        elseif Distance > component.Range then
            if Connections[eggFullName .. "_InputDetect"] then
                Connections[eggFullName .. "_InputDetect"]:Disconnect()
                Connections[eggFullName .. "_InputDetect"] = nil
            end
            if EggInstance.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                EggInstance.PrimaryPart:FindFirstChildOfClass("BillboardGui"):Destroy()
            end
        end
    end)
end)

Egg.Stopped:Connect(function(component)
    Connections[component.Instance:GetFullName()]:Disconnect()
end)

return Egg