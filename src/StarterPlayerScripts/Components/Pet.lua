local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local ModelWrapper = require(ReplicatedStorage.Util.ModelWrapper)
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PetModule = require(ReplicatedStorage.Modules.PetModule)
local Trove = require(ReplicatedStorage.Packages.Trove)
local RNG = Random.new()

local ToVector2 = function(Vector)
	return Vector2.new(Vector.x, Vector.z)
end

local Pet = Component.new({
    Tag = "Pet",
})

function Pet:Construct()
    self.trove = Trove.new()
    self.Owner = nil
    self.Id = nil
    self.Name = nil
    self.State = nil
    self.CoordFrame = CFrame.new()
    self.LastTick = 0
    self.Offset = Vector3.new()
    self.Radius = RNG:NextNumber(3, 4)
    self.Phase = RNG:NextNumber(-math.pi, math.pi)
    self.Twist = CFrame.new()
    self.Animation = CFrame.new()
    self.Position = Vector3.new()
    self.ModelWrapper = nil
    self.trove = Trove.new()
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

    self.trove:Add(function()
        self:updateOffsets()
        return self.trove:WrapClean()
    end)
    self:spawn(self.Owner.Character.PrimaryPart.Position - Vector3.new(0, 2.5, 0))
end)

Pet.Stopped:Connect(function(self)
    self.trove:Clean()
end)

function Pet:updateOffsets()
    local arr = {}
    local components = Pet:GetAll()
    for _, component in pairs(components) do
        if component.Owner == self.Owner then
            table.insert(arr, component)
        end
    end

    local angle = math.pi * 2 / #arr
    for i, v in ipairs(arr) do
        v:setOffset(CFrame.Angles(0, angle * (i + 1) + RNG:NextNumber(-angle * 0.53, angle * 0.3), 0) * Vector3.new(0, v.Flying and -2.5 or -3.0, v.Radius))
    end
end

function Pet:setOffset(offset)
    self.Offset = offset
end

function Pet:spawn(origin)
    self.Position = origin
    self:updateOffsets()
    self:onRender()
end

function Pet:onRender()
    local playerChar = self.Owner.Character
    if self.Owner.Character == nil or self.Instance.PrimaryPart == nil or self.Owner.Character.PrimaryPart == nil or playerChar.Humanoid == nil then
        return
    end

    local target = self.Owner.Character.PrimaryPart.Position + self.Offset
    local Next0 = self.Position:Lerp(target, 0.1) * Vector3.new(1, 0, 1)
    local Next1 = self.Position:Lerp(target, 0.3) * Vector3.new(0, 1, 0)
    local Next = Next0 + Next1
    local moving = playerChar.Humanoid.MoveDirection.Magnitude > 0
    local now = tick()
    local angle = (now + self.Phase) % (math.pi * 2)
    local animation = CFrame.new(0, 0.25, 0)
    local twist = CFrame.new()

    if self.State == "Flying" then
        local cframe = CFrame.new(0, 3, 0)
        local anim = CFrame.Angles(math.rad(math.cos(angle * 4)) * 8, 0, 0)
        local anim2 = Vector3.new(0, math.sin(angle * 4) * 0.5, 0)
        animation = cframe * anim + anim2
    end

    if moving and self.State ~= "Flying" then
        local animationIntensity = math.clamp((ToVector2(Next) - ToVector2(target)).Magnitude, 0, 4.5) / 4.5
        local y = math.abs(math.sin(angle * 10)) * 3 * animationIntensity
        local r = math.rad(math.sin(angle * 10)) * 20 * animationIntensity
        animation = CFrame.new(0, y, 0) * CFrame.Angles(0, 0, r)
    end

    if moving then
        twist = CFrame.new(Vector3.new(), self.Owner.Character.PrimaryPart.CFrame.LookVector)
    else
        twist = CFrame.new(Vector3.new(), ((Next0 * -1) + (self.Owner.Character.PrimaryPart.Position or Vector3.new())) * Vector3.new(1, 0, 1))
    end

    self.Twist = self.Twist:Lerp(twist, 0.1 * 0.5)
    self.Animation = self.Animation:Lerp(animation, 0.3)
    self.Position = Next

    if self.ModelWrapper then
        self.ModelWrapper:SetCFrame(CFrame.new(self.Position) * self.Twist * self.Animation)
    end
end

RunService:BindToRenderStep("PetRendering", Enum.RenderPriority.Character.Value + 1, function(dt)
    for _, petComponent in ipairs(Pet:GetAll()) do
        petComponent:onRender(petComponent)
    end
end)

return Pet





--[[
elseif atBack then
        local rowCount = math.ceil(numPets / 3)  -- Calculate the number of rows
        local offsetY = -3  -- Offset along the Y-axis for shifting all rows downwards
        local playerOffsetX = 0 -- Offset for centering around the player
    
        -- Calculate the total width of all pets in each row
        local rowWidths = {}
        for i = 1, rowCount do
            local rowPets = math.min(numPets - (i - 1) * 3, 3)  -- Number of pets in the current row
            rowWidths[i] = (rowPets - 1) * 1.5  -- Calculate total width of the pets in the row
        end
    
        -- Calculate total width of all rows
        local totalWidth = math.max(unpack(rowWidths))
    
        -- Calculate the offset for centering around the player
        playerOffsetX = -totalWidth / 2
    
        for i, v in ipairs(arr) do
            -- Calculate row and column indices without using math.floor
            local rowIndex = math.floor((i - 1) / 3) + 1
            local colIndex = (i - 1) % 3 + 1
    
            -- Calculate offsetX for the current row
            local rowPets = math.min(numPets - (rowIndex - 1) * 3, 3) -- Number of pets in the current row
            local offsetX = -rowWidths[rowIndex] / 2 + playerOffsetX  -- Start X-offset from the center of the row
    
            -- Adjust offsetX for rows with fewer pets
            if rowPets < 3 and rowIndex ~= 1 then
                offsetX = offsetX + (3 - rowPets) * 1.5 / 2
            elseif rowPets == 3 and rowIndex == 1 then
                offsetX = offsetX + (3 - rowPets) * (1.5 / 2)/2
            elseif rowPets == 2 and rowIndex == 1 then
                offsetX = offsetX + (3 - rowPets) * ((1.5 / 2)/2)/2
            elseif rowPets == 1 and rowIndex == 1 then
                offsetX = offsetX + (3 - rowPets) * (((1.5 / 2)/2)/2)/2
            end
            -- Calculate offset based on row and column indices
            local offsetZ = -(rowIndex - 1) * 3 + offsetY  -- Apply the offset along the Y-axis
    
            -- Set the offset for the current pet
            v:setOffset(Vector3.new(offsetX + (colIndex - 1) * 3, v.Flying and -2.5 or -3.0, offsetZ))
        end
    end
]]
