local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PetModule = require(ReplicatedStorage.Modules.PetModule)
local Component = require(ReplicatedStorage.Packages.Component)
local ModelWrapper = require(ReplicatedStorage.Util.ModelWrapper)
local Trove = require(ReplicatedStorage.Packages.Trove)
local CameraUtil = require(ReplicatedStorage.Util.CameraUtil)
local Player = Players.LocalPlayer
local Camera = Workspace.Camera
local CatchablePet = Component.new({
    Tag = "CatchablePet",
})

local Cleaner = Trove.new()

function CatchablePet:Construct()
    self.Name = nil
    self.Range = 6
    self.State = "Walking"
    self.Action = "Idle"
    self.Trove2 = Trove.new()
    self.TurnTime = tick()
    self.LastTurn = Vector3.new()
    self.Turn = CFrame.new()
    self.Phase = Random.new():NextNumber(-math.pi, math.pi)
    self.Animation = CFrame.new()
    self.Position = Vector3.new()
    self.ModelWrapper = ModelWrapper.new(self.Instance)
end

CatchablePet.Started:Connect(function(self)
    self.Name = self.Instance:GetAttribute("Name")
    self.State = PetModule.GetStat(self.Name, "State")
    self.Position = self.Instance.PrimaryPart.Position
    self:OnStart()
end)

CatchablePet.Stopped:Connect(function(self)
    Cleaner:Clean()
end)

function CatchablePet:OnStart()
    self:CreateUI()
    Cleaner:Add(RunService.RenderStepped:Connect(function()
        local UI = self.Instance.PrimaryPart:FindFirstChildOfClass("BillboardGui")
        local Character = Player.Character or Player.Character:Wait()
        local HRP = Character:WaitForChild("HumanoidRootPart")
        local Distance = (self.Instance.PrimaryPart.Position - HRP.Position).magnitude
        if self.Range >= Distance and self.Action ~= "Interacting" then
            if UI.Enabled ~= true then
                UI.Enabled = true
                self.Trove2:Add(game:GetService("UserInputService").InputBegan:Connect(function(input)
                    self:OnInteract(input)
                end))
            end
        elseif self.Range < Distance then
            if UI.Enabled ~= false then UI.Enabled = false
                self.Trove2:Clean()
            end
        end
    end))
end

function CatchablePet:CreateUI()
    local UI = ReplicatedStorage.Misc.CatchableUI
    local UIClone = UI:Clone()
    UIClone.Parent = self.Instance.PrimaryPart
end

function CatchablePet:OnInteract(input)
    local UI = self.Instance.PrimaryPart:FindFirstChildOfClass("BillboardGui")
    if input.KeyCode == Enum.KeyCode.E then
        self.Action = "Interacting"
        UI.Enabled = false
        Player.Character.Humanoid.WalkSpeed = 0
        CameraUtil:SetCameraHost(self.Instance.PrimaryPart)
        CameraUtil:LockCameraPanning(true, true)
        CameraUtil:SetCameraView("ThirdPerson")
        CameraUtil:Change("Offset", CFrame.new(0,0.75,0))
        CameraUtil:Change("MinZoom", 3)
        CameraUtil:Change("MaxZoom", 3)
        CameraUtil:Change("Zoom", 3)
        self:MakePlayersInvisible()
    end
end

function CatchablePet:MakePlayersInvisible()
    for _, player in pairs(Players:GetPlayers()) do
        local Mplayer = ModelWrapper.new(player.Character)
        Mplayer:SetTransparency(1)
    end
end

function CatchablePet:OnRender()
    if self.TurnTime <= tick() and self.Action ~= "Interacting" then
        self.LastTurn = math.random(1,360)
        self.TurnTime = tick() + math.random(5,50)
   elseif self.Action == "Interacting" then
        -- Calculate the angle between the pet and the camera
        local cameraPosition = Camera.CFrame.Position -- Assuming Camera is the variable holding the camera's CFrame
        local petPosition = self.Position
        local direction = (cameraPosition - petPosition).unit
        local angle = math.atan2(direction.X, direction.Z)
        self.LastTurn = math.deg(angle) - 180
    end

    local now = tick()
    local angle = (now + self.Phase) % (math.pi * 2)
    local animation = CFrame.new(0, 0.25, 0)
    if self.State == "Flying" then
        local cframe = CFrame.new(0, 3, 0)
        local anim = CFrame.Angles(math.rad(math.cos(angle * 4)) * 8, 0, 0)
        local anim2 = Vector3.new(0, math.sin(angle * 4) * 0.5, 0)
        animation = cframe * anim + anim2
    end

    self.Animation = self.Animation:Lerp(animation, 0.1)
    local finalAnimation = self.Turn * self.Animation
    self.Turn = self.Turn:Lerp(CFrame.Angles(0, math.rad(self.LastTurn), 0), 0.1)
    if self.ModelWrapper then
        self.ModelWrapper:SetCFrame(CFrame.new(self.Position)  * finalAnimation)
    end
end

RunService:BindToRenderStep("PetRendering", Enum.RenderPriority.Character.Value + 1, function(dt)
    for _, component in pairs(CatchablePet:GetAll()) do
        component:OnRender()
    end
end)

return CatchablePet