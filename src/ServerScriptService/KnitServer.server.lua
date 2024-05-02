local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Components = script.Parent.Components

Knit.AddServices(script.Parent.Services)
Knit.Start({ServicePromises = false}):andThen(function()
    Knit.Components = {}
    for _, c in pairs(Components:GetChildren()) do
        Knit.Components[c.Name] = require(c)
    end
end):catch(warn):await()