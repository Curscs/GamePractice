local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Input = require(Packages.Input)
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local PetModule = require(ReplicatedStorage.Modules.PetModule)
local RarityModule = require(ReplicatedStorage.Modules.RarityModule)
-- { Global } --
local Connections = {}
local ClickedPet = nil
-- { InventoryGui } --
local InventorySG = PlayerGui:WaitForChild("Inventory")
local InventoryFrame = InventorySG:WaitForChild("Frame")
local UISCALE = InventorySG:WaitForChild("UIScale")
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

function InventoryController:OnPetStatsEquipClick()
    local PetService = Knit.GetService("PetService")
    if PetStats["Container"]["Equip"].Visible == true then
        if PetService:TriggerPet(ClickedPet) == "Equipped" then
            PetStats["Container"]["Unequip"].Visible = true
            PetStats["Container"]["Equip"].Visible = false
            InventoryController:UpdateGui()
        end
    end
end

function InventoryController:OnPetStatsUnequipClick()
    local PetService = Knit.GetService("PetService")
    if PetStats["Container"]["Unequip"].Visible == true then
        if PetService:TriggerPet(ClickedPet) == "Unequipped" then
            PetStats["Container"]["Equip"].Visible = true
            PetStats["Container"]["Unequip"].Visible = false
            InventoryController:UpdateGui()
        end
    end
end

function InventoryController:OnPetStatsCloseClick()
    PetStats.Visible = false
end

function InventoryController:OnPetClick(instance) -- when pet is clicked
    local DataService = Knit.GetService("DataService")
    local PlayerData = DataService:GetData("Inventory")
    local Pets = PlayerData["Pets"]
    PetStats.Visible = true
    -- Calculate offset
    local OffsetX = (instance.AbsolutePosition.X - InventoryFrame.AbsolutePosition.X) / UISCALE.Scale
    local OffsetY = (instance.AbsolutePosition.Y - InventoryFrame.AbsolutePosition.Y) / UISCALE.Scale
    -- Animate position change
    local PetStatNewPosition = UDim2.new(0.31, OffsetX, 0.32, OffsetY)
    local PetStatTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local PetStatMove = game:GetService("TweenService"):Create(PetStats, PetStatTweenInfo, {Position = PetStatNewPosition})
    PetStatMove:Play()
    PetStatMove.Completed:Connect(function()
        PetStatMove:Destroy()
    end)
    -- Display Data
    PetStats["Container"]["ItemName"].Text = PetModule.GetStat(Pets[instance.Name]["Name"], "Name")
    PetStats["Container"]["Rarity"].Text = PetModule.GetStat(Pets[instance.Name]["Name"], "Rarity")
    PetStats["Container"]["Currency"]["CurrencyAmount"].Text = PetModule.GetStat(Pets[instance.Name]["Name"], "CoinMul")
    -- Buttons Check
    if Pets[instance.Name]["Equipped"] == false then
        PetStats["Container"]["Equip"].Visible = true
        PetStats["Container"]["Unequip"].Visible = false
    elseif Pets[instance.Name]["Equipped"] == true then
        PetStats["Container"]["Unequip"].Visible = true
        PetStats["Container"]["Equip"].Visible = false
    end
    -- Button Click Connections
    ClickedPet = instance.Name
end

function InventoryController:OnGuiTrigger(action: string)
    if action == "Opened" then -- when gui is opened
        PetStats.Parent = InventoryFrame
        -- Connections
        Connections["StatsFrameSizeDetection"] = PetStats.Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()self:UpdateStatSize()end)
        Connections["ScrollDetection"] = PetContainer:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            if PetStats.Visible == true then
                PetStats.Visible = false
            end
        end)
    elseif action == "Closed" then -- when gui is closed
        PetStats.Parent = Misc
        PetStats.Visible = false
        -- Disconnects StatsFrameSizeDetection
        if Connections["StatsFrameSizeDetection"] then
            Connections["StatsFrameSizeDetection"]:Disconnect()Connections["StatsFrameSizeDetection"] = nil
        end
        -- Disconnects Scrolls Detection
        if Connections["ScrollDetection"] then
            Connections["ScrollDetection"]:Disconnect()Connections["ScrollDetection"] = nil
        end
        -- Destroys all pets when frame is closed
        for _, instance in pairs(PetContainer:GetChildren()) do
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
    for id, petstats in pairs(PetsData) do
        local TemplateClone = Template:Clone()
        local layoutOrder
        if petstats["Equipped"] then
            layoutOrder = PetModule.GetStat(petstats["Name"], "CoinMul") * -100000
        else
            layoutOrder = PetModule.GetStat(petstats["Name"], "CoinMul") * -0.1-- Not equipped pets are ordered by their CoinMul values
        end
        TemplateClone.LayoutOrder = layoutOrder
        TemplateClone.Parent = PetContainer
        TemplateClone.Name = id
        TemplateClone.Visible = true
        TemplateClone["PetName"].Text = petstats["Name"]
        TemplateClone["Pet"]["Icon"].Image = PetModule.GetImage(petstats["Name"])
        if petstats["Equipped"] == true then
            TemplateClone["Tick"].Visible = true
        end
        TemplateClone["PetName"]["UIGradient"].Color = RarityModule.Colors[PetModule.GetStat(petstats["Name"], "Rarity")]
        TemplateClone["UIGradient"].Color = RarityModule.Colors[PetModule.GetStat(petstats["Name"], "Rarity")]
    end
    for _, instance in pairs(PetContainer:GetChildren()) do 
        if instance:IsA("ImageButton") and instance.Name ~= "Template" then
            instance.MouseButton1Click:Connect(function()
                self:OnPetClick(instance)
            end)
        end
    end
end

function InventoryController:KnitInit()
    PetStats["Container"]["Equip"].MouseButton1Click:Connect(function()
        self:OnPetStatsEquipClick()
    end)
    PetStats["Container"]["Unequip"].MouseButton1Click:Connect(function()
        self:OnPetStatsUnequipClick()
    end)
    PetStats["Container"]["Close"].MouseButton1Click:Connect(function()
        self:OnPetStatsCloseClick()
    end)
end

return InventoryController