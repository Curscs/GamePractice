local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local ModelWrapper = require(ReplicatedStorage.Util.ModelWrapper)
local RunService = game:GetService("RunService")
local RNG = Random.new()

local Pet = Component.new({
    Tag = "Pet",
})

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
    component.Wrapper = ModelWrapper.new(component.Model)
    component.Size = component.Model:GetBoundingBox()

end)

return Pet