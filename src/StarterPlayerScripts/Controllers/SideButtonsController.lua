local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Player = Players.LocalPlayer
-- { Gui Elements } --
local PlayerGui = Player:WaitForChild("PlayerGui")
local SideButtons = PlayerGui:WaitForChild("SideButtons")
local RightFrame = SideButtons:WaitForChild("RightFrame")

local SideButtonsController = Knit.CreateController({
    Name = "SideButtonsController",
    Client = {}
})

function SideButtonsController:OnClick(Button: string)
    local InventoryController = Knit.GetController("InventoryController")
    if Button.Name == "InventoryButton" then
        InventoryController:TriggerGui()
    end
end

function SideButtonsController:KnitStart()
    for _, instance in pairs(RightFrame:GetChildren()) do
        if instance:IsA("ImageButton") then
            instance.MouseButton1Click:Connect(function() self:OnClick(instance) end)
        end
    end
end

return SideButtonsController