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
local PlayerGui = Player:WaitForChild("PlayerGui")
local PetCatching = PlayerGui:WaitForChild("PetCatching")
local Frame = PetCatching:WaitForChild("Frame")
local Cancel = Frame:WaitForChild("Cancel")
local Catch = Frame:WaitForChild("Catch")
local Catchable = Component.new({
    Tag = "Catchable",
})

function Catchable:Construct()
    self.Name = nil
    self.Range = 6
    self.State = "Walking"
    self.Action = "Idle"
    self.Trove = Trove.new()
    self.Trove2 = Trove.new()
    self.TurnTime = tick()
    self.LastTurn = Vector3.new()
    self.Turn = CFrame.new()
    self.Phase = Random.new():NextNumber(-math.pi, math.pi)
    self.Animation = CFrame.new()
    self.Position = Vector3.new()
    self.ModelWrapper = ModelWrapper.new(self.Instance)
end

Catchable.Started:Connect(function(self)
    self.Name = self.Instance:GetAttribute("Name")
    self.State = PetModule.GetStat(self.Name, "State")
    self.Position = self.Instance.PrimaryPart.Position
    self:OnStart()
end)

Catchable.Stopped:Connect(function(self)
    self.Trove:Clean()
    self.Trove2:Clean()
end)

function Catchable:OnStart()
    self:CreateUI()
    self.Trove:Add(RunService.RenderStepped:Connect(function()
        local UI = self.Instance.PrimaryPart:FindFirstChildOfClass("BillboardGui")
        local Character = Player.Character or Player.Character:Wait()
        local HRP = Character:WaitForChild("HumanoidRootPart")
        local Distance = (self.Instance.PrimaryPart.Position - HRP.Position).magnitude
        if self.Range >= Distance and self.Action ~= "Interacting" then
            if UI.Enabled ~= true then
                self.Trove2:Add(game:GetService("UserInputService").InputBegan:Connect(function(input)
                    print("Input detected")
                    self:OnInteract(input)
                end))
                UI.Enabled = true
            end
        elseif self.Range < Distance and self.Action ~= "Fighting" then
            if UI.Enabled ~= false then
                self.Trove2:Clean()
                UI.Enabled = false
            end
        end
    end))
end

function Catchable:CreateUI()
    local UI = ReplicatedStorage.Misc.CatchableUI
    local UIClone = UI:Clone()
    UIClone.Parent = self.Instance.PrimaryPart
end

function Catchable:OnInteract(input)
    print(self.Name)
    local UI = self.Instance.PrimaryPart:FindFirstChildOfClass("BillboardGui")
    if input.KeyCode == Enum.KeyCode.E then
        self.Action = "Interacting"
        UI.Enabled = false
        self:LockPlayer(true)
        CameraUtil:SetCameraHost(self.Instance.PrimaryPart)
        CameraUtil:LockCameraPanning(true, true)
        CameraUtil:SetCameraView("ThirdPerson")
        CameraUtil:Change("Offset", CFrame.new(0,0.75,0))
        CameraUtil:Change("MinZoom", 3)
        CameraUtil:Change("MaxZoom", 3)
        CameraUtil:Change("Zoom", 3)
        self:MakePlayersInvisible(1)
        PetCatching.Enabled = true
    end
end

function Catchable:LockPlayer(value: boolean)
    if value == true then
        Player.Character.Humanoid.WalkSpeed = 0
        Player.Character.Humanoid.JumpPower = 0
    elseif value == false then
        Player.Character.Humanoid.WalkSpeed = 16
        Player.Character.Humanoid.JumpPower = 50
    end
end

function Catchable:MakePlayersInvisible(value: number)
    for _, player in pairs(Players:GetPlayers()) do
        local Mplayer = ModelWrapper.new(player.Character)
        Mplayer:SetTransparency(value)
    end
end

function Catchable:OnRender()
    if self.TurnTime <= tick() and self.Action ~= "Interacting" and self.Action ~= "Fighting" then
        self.LastTurn = math.random(1,360)
        self.TurnTime = tick() + math.random(5,50)
    elseif self.Action == "Interacting" then
        local cameraPosition = Camera.CFrame.Position
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
    for _, component in pairs(Catchable:GetAll()) do
        component:OnRender()
    end
end)

Catch.MouseButton1Click:Connect(function()
    local oldplayerpos = Player.Character.HumanoidRootPart.CFrame
    local x = nil
    local c = nil
    PetCatching.Enabled = false
    for _, component in pairs(Catchable:GetAll()) do
        if component.Action == "Interacting" then
            component.Action = "Fighting"
            component.Position = Vector3.new(-64.737, 1, -59.861)
            x = component.Instance.PrimaryPart:FindFirstChildOfClass("BillboardGui")
            c = component
        end
    end
    
    Catchable:MakePlayersInvisible(0)
    Player.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(-64.737, 5, -41.884))
    if not Workspace.Animations.Misc:FindFirstChild("Fighting") then
        local Fighting = Instance.new("BoolValue")
        Fighting.Name = "Fighting"
        Fighting.Parent = Workspace.Animations.Misc
    end
    Workspace.Animations.Misc.Fighting.Value = true
    CameraUtil:SetCameraHost(Workspace.PetCatchingArea.Camera)
    CameraUtil:LockCameraPanning(true, true)
    CameraUtil:SetCameraView("ThirdPerson")
    CameraUtil:Change("Offset", CFrame.Angles(0,math.rad(90),0))
    CameraUtil:Change("MinZoom", 3)
    CameraUtil:Change("MaxZoom", 3)
    CameraUtil:Change("Zoom", 3)
    task.wait(1)
    if x ~= nil then
        print(x)
        x.Enabled = true
        x.Frame.Visible = false
        x.Result.Visible = true
        task.wait(2)
        x.Enabled = false
        x.Frame.Visible = true
        x.Result.Visible = false
    end
    if c ~= nil then
        c.Instance:Destroy()
    end
    Player.Character.HumanoidRootPart.CFrame = oldplayerpos
    Catchable:LockPlayer(false)
    CameraUtil:SetCameraView("Default")
end)

Cancel.MouseButton1Click:Connect(function()
    PetCatching.Enabled = false
    CameraUtil:SetCameraView("Default")
    for _, component in pairs(Catchable:GetAll()) do
        if component.Action == "Interacting" then
            component.Action = "Idle"
        end
    end
    Catchable:LockPlayer(false)
    Catchable:MakePlayersInvisible(0)
end)

return Catchable