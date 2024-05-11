local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local CatchableController = Knit.CreateController({
    Name = "CatchableController",
    Client = {}
})

return CatchableController