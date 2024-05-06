local FRAMES_CLOSE = 1
local FRAMES_CLOSE_LQ = 3
local FRAMES_CLOSE_DISTANCE = 80
local FRAMES_FAR = 2
local FRAMES_FAR_LQ = 6
local FRAMES_FAR_DISTANCE = 160

local LerpNumber = function(i, j, a)
    return i + a * (j - i)
end

local ToVector2 = function(Vector)
    return Vector2.new(Vector.x, Vector.z)
end

local ToVector3 = function(Vector, y)
    return Vector3.new(Vector.x, y or 0, Vector.y)
end

Connections = {}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Camera = workspace.Camera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local PetModule = require(ReplicatedStorage.Modules.PetModule)
local ModelWrapper = require(ReplicatedStorage.Util.ModelWrapper)
local RunService = game:GetService("RunService")
local RNG = Random.new()

local Pet = Component.new({
    Tag = "Pet",
})

function Pet:Update()
	local Char = self.Owner.Character

	if not Char then
		return
	end

	local Root = Char.PrimaryPart

	if not Root then
		return
	end

	self.Counter = self.Counter + 1
	local Offset = Camera.CFrame.p - Root.Position
	local Distance = Offset:Dot(Offset)
	local LowQuality = self.Owner ~= Player and self.LowQuality

	if script.Parent.AllVisible.Value == false then
		return self:Despawn()
	end

	if script.Parent.OtherVisible.Value == false and self.Owner ~= Player then
		return self:Despawn()
	end

	local Frames = 0

	if Distance <= FRAMES_CLOSE_DISTANCE * FRAMES_CLOSE_DISTANCE then
		Frames = LowQuality and FRAMES_CLOSE_LQ or FRAMES_CLOSE
	elseif Distance <= FRAMES_FAR_DISTANCE * FRAMES_FAR_DISTANCE then
		Frames = LowQuality and FRAMES_FAR_LQ or FRAMES_FAR
	else
		return self:Despawn()
	end

	if self.Counter % Frames > 0 then
		return
	end

	local Lerp0 = LowQuality and 0.35 or 0.1
	local Lerp1 = LowQuality and 0.65 or 0.3

	if not self.Model.Parent then
		self:Spawn()
	end

	local Target = Root.Position + self.Offset
	local Next0 = self.Position:Lerp(Target, Lerp0) * Vector3.new(1, 0, 1)
	local Next1 = self.Position:Lerp(Target, Lerp1) * Vector3.new(0, 1, 0)
	local Next = Next0 + Next1
	local FlatOffset = (Next - self.Position) * Vector3.new(1, 0, 1)
	local Moving = FlatOffset:Dot(FlatOffset) > 0.025
	local State = self.State
	local now = tick()
	local Angle = (now + self.Phase) % (math.pi * 2)
	local Animation = CFrame.new(0, 0.25, 0)

	if Moving == true and State == "Walk" or State == "Walk" and self.Model.PrimaryPart.Position.Y > Root.Position.Y - 1.5 then
		local num = 4.5
		local AnimationIntensity = math.clamp((ToVector2(Next) - ToVector2(Target)).magnitude, 0, num) / num
		local y = math.abs(math.sin(Angle * 10)) * 3 * AnimationIntensity
		local r = math.rad(math.sin(Angle * 10)) * 20 * AnimationIntensity
		Animation = CFrame.new(0, y, 0) * CFrame.Angles(0, 0, r)
	elseif State == "Fly" then
		Animation = CFrame.new(0, 3, 0) * CFrame.Angles(math.rad(math.cos(Angle * 4)) * 8, 0, 0) + Vector3.new(0, math.sin(Angle * 4) * 0.5, 0)
	end

	local Twist

	if Moving then
		Twist = CFrame.new(Vector3.new(), Root.CFrame.lookVector)
	else
		Twist = CFrame.new(Vector3.new(), -Next0 + Root.Position * Vector3.new(1, 0, 1))
	end

	self.Twist = self.Twist:Lerp(Twist, Lerp0 * 0.5)
	self.Animation = self.Animation:Lerp(Animation, Lerp1)
	self.Position = Next
	self.Wrapper:SetCFrame(CFrame.new(self.Position) * self.Twist * self.Animation)
end

function Pet:Spawn()
	self.Position = self.Owner.Character.PrimaryPart and self.Owner.Character.PrimaryPart.Position or Vector3.new()
	self.Model.Parent = workspace.Pets
	self:Update()
end

function Pet:Despawn()
	self.Model.Parent = nil
end

function Pet:Destroy()
	self.Model:Destroy()
	self = nil
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
    local RobloxInstance = component.Instance

    component.Owner = game.Players:FindFirstChild(RobloxInstance:GetAttribute("Owner"))
    component.Id = RobloxInstance.Name
    component.Name = RobloxInstance:GetAttribute("Name")
    component.State = RobloxInstance:GetAttribute("State")
    component.Model = RobloxInstance

end)

        
return Pet