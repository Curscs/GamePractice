local Players = game:GetService("Players")
local FRAMES_CLOSE = 1
local FRAMES_CLOSE_LQ = 3
local FRAMES_CLOSE_DISTANCE = 80
local FRAMES_FAR = 2
local FRAMES_FAR_LQ = 6
local FRAMES_FAR_DISTANCE = 160

local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local PetModule = require(ReplicatedStorage.Modules.PetModule)
local ModelWrapper = require(ReplicatedStorage.Util.ModelWrapper)
local RunService = game:GetService("RunService")
local RNG = Random.new()
local Connections = {}

local Camera = workspace.Camera

local LerpNumber = function(i, j, a)
    return i + a * (j - i)
end
local ToVector2 = function(Vector)
    return Vector2.new(Vector.x, Vector.z)
end
local ToVector3 = function(Vector, y)
    return Vector3.new(Vector.x, y or 0, Vector.y)
end

local Pet = Component.new({
    Tag = "Pet",
    LowQuality = false,
    OthersVisible = true,
    AllVisible = true
})

function Pet:Update(self)
    if not self.Owner.Character or not self.Owner.Character.PrimaryPart then
        return
    end

    local root = self.Owner.Character.PrimaryPart
    local cameraOffset = Camera.CFrame.Position - root.Position
    local distanceSquared = cameraOffset:Dot(cameraOffset)
    local lowQuality = self.Owner ~= Player and self.LowQuality

    local frames = 0

    if distanceSquared <= FRAMES_CLOSE_DISTANCE * FRAMES_CLOSE_DISTANCE then
        frames = lowQuality and FRAMES_CLOSE_LQ or FRAMES_CLOSE
    elseif distanceSquared <= FRAMES_FAR_DISTANCE * FRAMES_FAR_DISTANCE then
        frames = lowQuality and FRAMES_FAR_LQ or FRAMES_FAR
    end

    if self.Counter % frames > 0 then
        return
    end

    local lerp0 = lowQuality and 0.35 or 0.1
    local lerp1 = lowQuality and 0.65 or 0.3

    local targetPosition = root.Position + (root.CFrame.lookVector * self.Radius)
    local nextPos0 = self.Position:Lerp(targetPosition, lerp0) * Vector3.new(1, 0, 1)
    local nextPos1 = self.Position:Lerp(targetPosition, lerp1) * Vector3.new(0, 1, 0)
    local nextPos = nextPos0 + nextPos1
    local flatOffset = (nextPos - self.Position) * Vector3.new(1, 0, 1)
    local moving = flatOffset.magnitude > 0.025
    local angle = (tick() + self.Phase) % (math.pi * 2)
    local animation = CFrame.new(0, 0.25, 0)

    if moving then
        local animationIntensity = math.clamp((ToVector2(nextPos) - ToVector2(targetPosition)).magnitude, 0, 1)
        local y = math.abs(math.sin(angle * 10)) * 3 * animationIntensity
        local r = math.rad(math.sin(angle * 10)) * 20 * animationIntensity
        animation = CFrame.new(0, y, 0) * CFrame.Angles(0, 0, r)
    end

    local twist

    if moving then
        twist = CFrame.new(Vector3.new(), root.CFrame.lookVector)
    else
        twist = CFrame.new(Vector3.new(), -nextPos0 + root.Position * Vector3.new(1, 0, 1))
    end

    self.Twist = self.Twist:Lerp(twist, lerp0 * 0.5)
    self.Animation = self.Animation:Lerp(animation, lerp1)
    self.Position = nextPos
    self.Wrapper:SetCFrame(CFrame.new(self.Position) * self.Twist * self.Animation)

    -- Debug prints
    print("Current Distance:", distanceSquared)
    print("Current Next Position:", nextPos)
    print("Current Animation Frame:", self.Animation)
end


function Pet:Construct()
    self.Owner = nil
    self.Id = nil
    self.Name = nil
    self.State = nil
    self.Model = nil
    self.Wrapper = nil
    self.Counter = 0
    self.Phase = RNG:NextNumber(-math.pi, math.pi)
    self.Radius = RNG:NextNumber(4, 6.5)
    self.Size = nil
    self.Offset = Vector3.new()
    self.Position = Vector3.new()
    self.Animation = CFrame.new()
    self.Twist = CFrame.new()
end

Pet.Started:Connect(function(component)
    local self = component
    local RobloxInstance = component.Instance
    self.Owner = game.Players:FindFirstChild(RobloxInstance:GetAttribute("Owner"))
    self.Id = RobloxInstance.Name
    self.Name = RobloxInstance:GetAttribute("Name")
    self.Type = PetModule.GetStat(component.Name, "Type")
    self.Model = RobloxInstance
    self.Wrapper = ModelWrapper.new(self.Model)
    self.Size = self.Model:GetBoundingBox()
    for _, Instance in next, RobloxInstance:GetDescendants() do
        if Instance:IsA("BasePart") then
            Instance.CanCollide = false
        end
    end

    if not RobloxInstance.PrimaryPart then
        RobloxInstance.PrimaryPart = RobloxInstance:FindFirstChild("Root")
    end

    self.Position = self.Owner.Character.PrimaryPart and self.Owner.Character.PrimaryPart.Position or Vector3.new()
    Connections[self.Id] = RunService:BindToRenderStep("PetRendering", Enum.RenderPriority.Character.Value + 1, function(dt)
        Pet:Update(self)
    end)
end)

Pet.Stopped:Connect(function(component)
    local self = component
    if Connections[self.Id] then
        Connections[self.Id]:Disconnect()
        Connections[self.Id] = nil
    end
end)

return Pet