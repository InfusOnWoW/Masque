--[[

	This file is part of 'Masque', an add-on for World of Warcraft. For bug reports,
	suggestions and license information, please visit https://github.com/SFX-WoW/Masque.

	* File...: Skins\Skins.lua
	* Author.: StormFX, JJSheets

	Skin API

]]

local _, Core = ...

----------------------------------------
-- Lua
---

local error, setmetatable, type = error, setmetatable, type

----------------------------------------
-- Internal
---

-- @ Skins\Regions
local Layers = Core.RegTypes.Legacy

----------------------------------------
-- Locals
---

local Skins, SkinList = {}, {}
local Hidden = {Hide = true}

----------------------------------------
-- Functions
---

-- Returns a valid shape.
local function GetShape(Shape)
	if type(Shape) ~= "string" then
		Shape = "Square"
	end
	return Shape
end

-- Adds data to the skin tables.
local function AddSkin(SkinID, SkinData)
	local Template = SkinData.Template
	local Default = Core.DEFAULT_SKIN

	if Template then
		setmetatable(SkinData, {__index = Skins[Template]})
	end

	for Layer, Info in pairs(Layers) do
		local Skin = SkinData[Layer]

		if Layer == "AutoCastShine" then
			Skin = Skin or SkinData.Shine or SkinData.AutoCast
		elseif Layer == "ChargeCooldown" then
			Skin = Skin or SkinData.Cooldown
		end

		if (type(Skin) ~= "table") or (Skin.Hide and not Info.CanHide) then
			Skin = Default[Layer]
		elseif Info.Hide then
			Skin = Hidden
		end

		SkinData[Layer] = Skin
	end

	SkinData.SkinID = SkinID
	SkinData.API_VERSION = SkinData.API_VERSION or SkinData.Masque_Version

	local Shape = SkinData.Shape
	SkinData.Shape = GetShape(Shape)

	Skins[SkinID] = SkinData

	if not SkinData.Disable then
		SkinList[SkinID] = SkinID
	end
end

----------------------------------------
-- Core
---

Core.__Hidden = Hidden
Core.AddSkin = AddSkin

Core.Skins = setmetatable(Skins, {
	__index = function(self, id)
		if id == "Blizzard" then
			return self.Classic
		end
	end
})

Core.SkinList = SkinList

----------------------------------------
-- API
---

local API = Core.API

-- Wrapper for the AddSkin function.
function API:AddSkin(SkinID, SkinData, Replace)
	local Debug = Core.Debug

	if type(SkinID) ~= "string" then
		if Debug then
			error("Bad argument to API method 'AddSkin'. 'SkinID' must be a string.", 2)
		end
		return
	end

	if Skins[SkinID] then return end

	if type(SkinData) ~= "table" then
		if Debug then
			error("Bad argument to API method 'AddSkin'. 'SkinData' must be a table.", 2)
		end
		return
	end

	local Template = SkinData.Template

	if Template then
		if type(Template) ~= "string" then
			if Debug then
				error(("Invalid template reference by skin '%s'. 'Template' must be a string."):format(SkinID), 2)
			end
			return
		end

		local Parent = Skins[Template]

		if type(Parent) ~= "table"  then
			if Debug then
				error(("Invalid template reference by skin '%s'. Template '%s' does not exist or is not a table."):format(SkinID, Template), 2)
			end
			return
		end
	end

	AddSkin(SkinID, SkinData)
end

-- Retrieves the default skin.
function API:GetDefaultSkin()
	return "Classic"
end

-- Retrieves the skin data for the specified skin.
function API:GetSkin(SkinID)
	return SkinID and Skins[SkinID]
end

-- Retrieves the Skins table.
function API:GetSkins()
	return Skins
end
