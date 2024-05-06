local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Component = require(ReplicatedStorage.Packages.Component)
local Camera = workspace.Camera
-- { Global } --
local Connections = {}
local EggOffset = CFrame.new(0,0,-6.5)
local PetOffset = CFrame.new(0,-1,-6.5) * CFrame.Angles(0,math.rad(180),0)

local  EggAnimation = Component.new({
    Tag = "EggAnimation",
})

function EggAnimation:Construct()
    self.Speed = 0
end

function EggAnimation:InitEggAnim(RobloxInstance)
    local totaleggs = 0
    local RealOffset = nil
    if RobloxInstance:GetAttribute("Type") == "Egg" then
        RealOffset = EggOffset
    elseif RobloxInstance:GetAttribute("Type") == "Pet" then
        RealOffset = PetOffset
    end 
    for _, _ in pairs(Workspace.Animations.EggHatching:GetChildren()) do
        totaleggs += 1
    end
    -- { Egg Init } --
    local EggCFrameVal = Instance.new("CFrameValue")

    Connections["EggRuntime"] = game:GetService("RunService").RenderStepped:Connect(function()
        if totaleggs == 1 then
            RobloxInstance:PivotTo(Camera.CFrame * RealOffset * CFrame.new(0,0,0) * EggCFrameVal.Value)
        elseif totaleggs == 2 then
            if RobloxInstance.Name == "1" then
                RobloxInstance:PivotTo(Camera.CFrame * RealOffset * CFrame.new(-2,0,0) * EggCFrameVal.Value)
            elseif RobloxInstance.Name == "2" then
                RobloxInstance:PivotTo(Camera.CFrame * RealOffset * CFrame.new(2,0,0) * EggCFrameVal.Value)
            end
        elseif totaleggs == 3 then
            if RobloxInstance.Name == "1" then
                RobloxInstance:PivotTo(Camera.CFrame * RealOffset * CFrame.new(-4,0,0) * EggCFrameVal.Value)
            elseif RobloxInstance.Name == "2" then
                RobloxInstance:PivotTo(Camera.CFrame * RealOffset * CFrame.new(0,0,0) * EggCFrameVal.Value)
            elseif RobloxInstance.Name == "3" then
                RobloxInstance:PivotTo(Camera.CFrame * RealOffset * CFrame.new(4,0,0) * EggCFrameVal.Value)
            end
        end
    end)

    if RobloxInstance:GetAttribute("Type") == "Egg" then
        EggCFrameVal.Value = CFrame.new(0,8,0)
        -- { Egg Tweens } --
        local Bounce = TweenService:Create(EggCFrameVal, TweenInfo.new(1, Enum.EasingStyle.Bounce), {Value = CFrame.new()})
        local Left = TweenService:Create(EggCFrameVal, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Value = CFrame.Angles(0,0,math.rad(25))})
        local Right = TweenService:Create(EggCFrameVal, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Value = CFrame.Angles(0,0,math.rad(-25))})
        -- { Egg Animation } --
        Bounce:Play()Bounce.Completed:Wait()
        for i = 1, 10 do
            Left:Play()Left.Completed:Wait()
            Right:Play()Right.Completed:Wait()
        end
        Bounce:Destroy()Left:Destroy()Right:Destroy()
        RobloxInstance:RemoveTag(EggAnimation.Tag)
        RobloxInstance:Destroy()
    elseif RobloxInstance:GetAttribute("Type") == "Pet" then
         -- { Egg Tweens } --
         local Down = TweenService:Create(EggCFrameVal, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {Value = CFrame.new(0,-8,0)})
         -- { Egg Animation } --
         task.wait(2)
         Down:Play()Down.Completed:Wait()
         Down:Destroy()
         RobloxInstance:RemoveTag(EggAnimation.Tag)
         RobloxInstance:Destroy()
    end
end

function EggAnimation:InitPetAnim()
    
end

EggAnimation.Started:Connect(function(component)
    local RobloxInstance = component.Instance
    EggAnimation:InitEggAnim(RobloxInstance)
end)

EggAnimation.Stopped:Connect(function()
    if Connections["EggRuntime"] then
        Connections["EggRuntime"]:Disconnect()
    end
end)

return EggAnimation