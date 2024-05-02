local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Input = require(Packages.Input)
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local PetModule = require(ReplicatedStorage.Modules.PetModule)
-- { Global } --
local Connections = {}
-- { InventoryGui } --
local InventorySG = PlayerGui:WaitForChild("Inventory")
local InventoryFrame = InventorySG:WaitForChild("Frame")
local UISCALE = InventoryFrame:WaitForChild("UIScale")
local ContentFrame = InventoryFrame:WaitForChild("Content")
local PetContainer = ContentFrame:WaitForChild("PetContainerFrame")
local Template = PetContainer:WaitForChild("Template")
local Misc = ReplicatedStorage:WaitForChild("Misc")
local PetStats = Misc:WaitForChild("PetBase")

local InventoryController = Knit.CreateController({
    Name = "InventoryController",
})

function InventoryController:UpdateStatSize()
    local layoutAbsoluteSize = PetStats.Container.UIListLayout.AbsoluteContentSize
    PetStats.Size = UDim2.new(0, layoutAbsoluteSize.X/ UISCALE.Scale + 18, 0, layoutAbsoluteSize.Y / UISCALE.Scale + 10)
    PetStats.Container.Size = UDim2.new(0, layoutAbsoluteSize.X / UISCALE.Scale, 0, layoutAbsoluteSize.Y / UISCALE.Scale + 10)
    PetStats.Background.Size = UDim2.new(0, layoutAbsoluteSize.X / UISCALE.Scale, 0, layoutAbsoluteSize.Y / UISCALE.Scale + 10)
    PetStats.Background2.Size = UDim2.new(0, layoutAbsoluteSize.X / UISCALE.Scale, 0, layoutAbsoluteSize.Y / UISCALE.Scale + 10)
end

function InventoryController:OnPetClick(instance) -- when pet is clicked
    PetStats.Visible = true
    local OffsetX = (instance.AbsolutePosition.X - InventoryFrame.AbsolutePosition.X) / UISCALE.Scale
    local OffsetY = (instance.AbsolutePosition.Y - InventoryFrame.AbsolutePosition.Y) / UISCALE.Scale
    PetStats.Position = UDim2.new(0.31, OffsetX, 0.32, OffsetY)
    PetStats["Container"]["ItemName"].Text = PetModule.GetStat(instance.Name, "Name")
    PetStats["Container"]["Rarity"].Text = PetModule.GetStat(instance.Name, "Rarity")
    PetStats["Container"]["Currency"]["CurrencyAmount"].Text = PetModule.GetStat(instance.Name, "CoinMul")
end

function InventoryController:OnGuiTrigger(action: string)
    if action == "Opened" then -- when gui is opened
        PetStats.Parent = InventoryFrame
        Connections["StatsFrameSizeDetection"] = PetStats.Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()self:UpdateStatSize()end)
        Connections["ScrollDetection"] = PetContainer:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            if PetStats.Visible == true then
                PetStats.Visible = false
            end
        end)
        for i, instance in pairs(PetContainer:GetChildren()) do -- creates click detection for each pet in inventory
            if instance:IsA("ImageButton") and instance.Name ~= "Template" then
                instance.MouseButton1Click:Connect(function()
                    self:OnPetClick(instance)
                end)
            end
        end
    elseif action == "Closed" then -- when gui is closed
        PetStats.Parent = Misc
        PetStats.Visible = false
        if Connections["StatsFrameSizeDetection"] then
            Connections["StatsFrameSizeDetection"]:Disconnect()  Connections["StatsFrameSizeDetection"] = nil
        end
        if Connections["ScrollDetection"] then
            Connections["ScrollDetection"]:Disconnect() Connections["ScrollDetection"] = nil
        end
        for _, instance in pairs(PetContainer:GetChildren()) do -- disconnects all click detections
            if instance:IsA("ImageButton") and instance.Name ~= "Template" then
                instance:Destroy()
            end
        end
    end
end

function InventoryController:TriggerGui()
    if InventorySG.Enabled == false then
        InventorySG.Enabled = true
        self:UpdateGui()
        self:OnGuiTrigger("Opened")
    elseif InventorySG.Enabled == true then
        InventorySG.Enabled = false
        self:OnGuiTrigger("Closed")
    end
end

function InventoryController:UpdateGui()
    local DataService = Knit.GetService("DataService")
    local InventoryData = DataService:GetData("Inventory")
    local PetsData = InventoryData["Pets"]
    for _, instance  in pairs(PetContainer:GetChildren()) do
        if instance:IsA("ImageButton") and instance.Name ~= "Template" then
            instance:Destroy()
        end
    end
    for _, petstats in pairs(PetsData) do
        local TemplateClone = Template:Clone()
        TemplateClone.LayoutOrder = petstats["CoinMul"]
        TemplateClone.Parent = PetContainer
        TemplateClone.Name = petstats["Name"]
        TemplateClone.Visible = true
        TemplateClone["PetName"].Text = petstats["Name"]
        TemplateClone["Pet"]["Icon"].Image = PetModule.GetImage(petstats["Name"])
    end
end

return InventoryController