--strict

-- Scaler
-- 0_1195
-- March 15, 2021

--[[

	Github:
		https://github.com/Y1195/Scaler
	
	Model:
		https://www.roblox.com/library/6522838162/Scaler
	
	Demo Place:
		https://www.roblox.com/games/6522817409/UI-Scaler-Demo
	
	Video Demo:
		https://www.youtube.com/watch?v=k9rdnu12G88


	API:
		number Scaler:GetAttribute("Scale")

]]

local SCALE_TAG = "UIScale"
local SCALE_ATTRIBUTE = "Scale"
local RESOLUTION_ATTRIBUTE = "Resolution"

local DEFAULT_SCALE = 1
local DEFAULT_RESOLUTION = 720

local Collection = game:GetService("CollectionService")

local camera = workspace.CurrentCamera

local currentScale = script:GetAttribute(SCALE_ATTRIBUTE)
if currentScale == nil then
	currentScale = DEFAULT_SCALE
	script:SetAttribute(SCALE_ATTRIBUTE, currentScale)
end

local resolution = script:GetAttribute(RESOLUTION_ATTRIBUTE)
if resolution == nil then
	resolution = DEFAULT_RESOLUTION
	script:SetAttribute(RESOLUTION_ATTRIBUTE, resolution)
end

local multiplier = DEFAULT_SCALE / resolution

local scales = {}

local function applyScale(scale: UIScale)
	scale.Scale = currentScale
end

local function scaleAdded(scale: UIScale)
	assert(scale:IsA("UIScale"), scale:GetFullName() .. " is not a UIScale")

	applyScale(scale)
	table.insert(scales, scale)
end

local function scaleRemoved(scale: UIScale)
	local index = table.find(scales, scale)
	if index then
		table.remove(scales, index)
	end
end

local function updateScale()
	local sizeX, sizeY = camera.ViewportSize.X, camera.ViewportSize.Y
	currentScale = if sizeY < sizeX then multiplier * sizeY else multiplier * sizeX

	script:SetAttribute(SCALE_ATTRIBUTE, currentScale)

	for _, scale in ipairs(scales) do
		applyScale(scale)
	end
end

for _, scale in ipairs(Collection:GetTagged(SCALE_TAG)) do
	scaleAdded(scale)
end

updateScale()

script:GetAttributeChangedSignal(RESOLUTION_ATTRIBUTE):Connect(function()
	resolution = script:GetAttribute(RESOLUTION_ATTRIBUTE)
	multiplier = DEFAULT_SCALE / resolution
	updateScale()
end)
camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
Collection:GetInstanceAddedSignal(SCALE_TAG):Connect(scaleAdded)
Collection:GetInstanceRemovedSignal(SCALE_TAG):Connect(scaleRemoved)
