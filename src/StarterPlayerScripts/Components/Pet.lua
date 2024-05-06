local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local ModelWrapper = require(ReplicatedStorage.Util.ModelWrapper)
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PetModule = require(ReplicatedStorage.Modules.PetModule)
local RNG = Random.new()

local ToVector2 = function(Vector)
	return Vector2.new(Vector.x, Vector.z)
end


local Pet = Component.new({
    Tag = "Pet",
})

function Pet:Construct()
    self.Owner = nil
    self.Id = nil
    self.Name = nil
    self.State = nil
    self.CoordFrame = CFrame.new()
    self.LastTick = 0
    self.Offset = Vector3.new()
    self.Radius = RNG:NextNumber(4, 6.5)
    self.Phase = RNG:NextNumber(-math.pi, math.pi)
    self.Twist = CFrame.new()
    self.Animation = CFrame.new()
    self.Position = Vector3.new()
    self.ModelWrapper = nil
end

Pet.Started:Connect(function(self)
    local RobloxInstance = self.Instance

    self.Owner = game.Players:WaitForChild(RobloxInstance:GetAttribute("Owner"))
    self.Id = RobloxInstance.Name
    self.Name = RobloxInstance:GetAttribute("Name")
    self.State = PetModule.GetStat(RobloxInstance:GetAttribute("Name"), "State")
    self.ModelWrapper = ModelWrapper.new(self.Instance)

    while self.Instance.PrimaryPart == nil do
        task.wait()
    end
    while self.Owner.Character == nil do
        task.wait()
    end
    while not self.Instance:IsDescendantOf(Workspace.Animations.PlayerPets) do
        task.wait()
    end

    self.Instance.ChildAdded:Connect(function(child)
        if child:IsA("BasePart") then
            child.CFrame = self.Instance.PrimaryPart.CFrame or CFrame.new()
            self.ModelWrapper = ModelWrapper.new(self.Instance)
        end
    end)

    


end)

return Pet
