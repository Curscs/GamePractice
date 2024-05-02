local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Component = require(ReplicatedStorage.Packages.Component)
local Camera = workspace.Camera
-- { Global } --
local Connections = {}
local EggOffset = CFrame.new(0,0,-8.5)

local  EggAnimation = Component.new({
    Tag = "EggAnimation",
})

function EggAnimation:Construct()
    self.Speed = 0
end

EggAnimation.Started:Connect(function(component)
    local RobloxInstance = component.Instance
    if RobloxInstance:GetAttribute("Type") == "Egg" then
        local totaleggs = 0
        for _, _ in pairs(Workspace.Animations.EggHatching:GetChildren()) do
            totaleggs += 1
        end
        -- { Egg Init } --
        local EggCFrameVal = Instance.new("CFrameValue")
        Connections["EggRuntime"] = game:GetService("RunService").RenderStepped:Connect(function()
            if totaleggs == 1 then
                RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(0,0,0) * EggCFrameVal.Value)
            elseif totaleggs == 2 then
                if RobloxInstance.Name == "1" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(-2,0,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "2" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(2,0,0) * EggCFrameVal.Value)
                end
            elseif totaleggs == 3 then
                if RobloxInstance.Name == "1" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(-4,0,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "2" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(0,0,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "3" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(4,0,0) * EggCFrameVal.Value)
                end
            elseif totaleggs == 4 then
                if RobloxInstance.Name == "1" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(-6,0,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "2" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(-2,0,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "3" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(2,0,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "4" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(6,0,0) * EggCFrameVal.Value)
                end
            elseif totaleggs == 8 then
                if RobloxInstance.Name == "1" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(-6,-2.5,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "2" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(-2,-2.5,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "3" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(2,-2.5,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "4" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(6,-2.5,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "5" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(-6,2.5,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "6" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(-2,2.5,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "7" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(6,2.5,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "8" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(2,2.5,0) * EggCFrameVal.Value)
                end
            end
        end)
        EggCFrameVal.Value = CFrame.new(0,8,0)
        -- { Egg Tweens } --
        local Bounce = game:GetService("TweenService"):Create(EggCFrameVal, TweenInfo.new(1, Enum.EasingStyle.Bounce), {Value = CFrame.new()})
        local Left = game:GetService("TweenService"):Create(EggCFrameVal, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Value = CFrame.Angles(0,0,math.rad(25))})
        local Right = game:GetService("TweenService"):Create(EggCFrameVal, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Value = CFrame.Angles(0,0,math.rad(-25))})
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
        local totaleggs = 0
        for _, _ in pairs(Workspace.Animations.EggHatching:GetChildren()) do
            totaleggs += 1
        end
        -- { Egg Init } --
        local EggCFrameVal = Instance.new("CFrameValue")
        Connections["EggRuntime"] = game:GetService("RunService").RenderStepped:Connect(function()
            if totaleggs == 1 then
                RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(0,0,0) * EggCFrameVal.Value)
            elseif totaleggs == 2 then
                if RobloxInstance.Name == "1" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(-2,0,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "2" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(2,0,0) * EggCFrameVal.Value)
                end
            elseif totaleggs == 3 then
                if RobloxInstance.Name == "1" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(-4,0,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "2" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(0,0,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "3" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(4,0,0) * EggCFrameVal.Value)
                end
            elseif totaleggs == 4 then
                if RobloxInstance.Name == "1" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(-6,0,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "2" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(-2,0,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "3" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(2,0,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "4" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(6,0,0) * EggCFrameVal.Value)
                end
            elseif totaleggs == 8 then
                if RobloxInstance.Name == "1" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(-6,-2.5,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "2" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(-2,-2.5,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "3" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(2,-2.5,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "4" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(6,-2.5,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "5" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(-6,2.5,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "6" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(-2,2.5,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "7" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(6,2.5,0) * EggCFrameVal.Value)
                elseif RobloxInstance.Name == "8" then
                    RobloxInstance:PivotTo(Camera.CFrame * EggOffset * CFrame.new(2,2.5,0) * EggCFrameVal.Value)
                end
            end
        end)
        EggCFrameVal.Value = CFrame.new(0,8,0)
        -- { Egg Tweens } --
        local Bounce = game:GetService("TweenService"):Create(EggCFrameVal, TweenInfo.new(1, Enum.EasingStyle.Bounce), {Value = CFrame.new()})
        local Left = game:GetService("TweenService"):Create(EggCFrameVal, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Value = CFrame.Angles(0,0,math.rad(25))})
        local Right = game:GetService("TweenService"):Create(EggCFrameVal, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Value = CFrame.Angles(0,0,math.rad(-25))})
        -- { Egg Animation } --
        Bounce:Play()Bounce.Completed:Wait()
        for i = 1, 10 do
            Left:Play()Left.Completed:Wait()
            Right:Play()Right.Completed:Wait()
        end
        Bounce:Destroy()Left:Destroy()Right:Destroy()
        RobloxInstance:RemoveTag(EggAnimation.Tag)
        RobloxInstance:Destroy()
    end
    -- { Pet Init } --

end)

EggAnimation.Stopped:Connect(function()
    if Connections["EggRuntime"] then
        Connections["EggRuntime"]:Disconnect()
    end
end)

return EggAnimation