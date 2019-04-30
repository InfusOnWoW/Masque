--[[

	This file is part of 'Masque', an add-on for World of Warcraft. For license information,
	please see the included License.txt file.

	* File...: Core\Button.lua
	* Author.: StormFX, JJSheets

	Button-Skinning API

]]

-- GLOBALS:

local _, Core = ...

----------------------------------------
-- Lua
---

local pairs, type = pairs, type

----------------------------------------
-- Internal
---

-- @ Skins\Skins
local Skins, __Empty = Core.Skins, Core.__Empty

-- @ Skins\Regions
local RegTypes = Core.RegTypes

-- @ Core\Utility
local GetScale = Core.GetScale

-- @ Core\Core
local SkinRegion = Core.SkinRegion

----------------------------------------
-- Locals
---

-- List of valid shapes.
local Shapes = {
	Circle = "Circle",
	Square = "Square",
}

-- Validates and returns a shape.
local function GetShape(Shape)
	return (Shape and Shapes[Shape]) or "Square"
end

----------------------------------------
-- Button
---

-- Applies a skin to a button and its associated layers.
function Core.SkinButton(Button, Regions, SkinID, Backdrop, Shadow, Gloss, Colors)
	if not Button then return end

	local bType = Button.__MSQ_bType
	local Skin, Disabled

	if SkinID then
		Skin = Skins[SkinID] or Skins.Classic
	else
		local Addon = Button.__MSQ_Addon or false
		Skin = Skins[Addon] or Skins.Default
		Disabled = true
	end

	Button.__MSQ_Enabled = (not Disabled and true) or nil
	Button.__MSQ_Shape = GetShape(Skin.Shape)

	if Disabled or type(Colors) ~= "table" then
		Colors = __Empty
	end

	local xScale, yScale = GetScale(Button)

	-- Backdrop
	local FloatingBG = Button.FloatingBG or Regions.Backdrop

	if Disabled then
		Backdrop = (FloatingBG and true) or false
	end

	SkinRegion("Backdrop", Backdrop, FloatingBG, Button, Skin.Backdrop, Colors.Backdrop, xScale, yScale)

	-- Icon
	local Icon = Regions.Icon

	if Icon then
		SkinRegion("Icon", Icon, Button, Skin.Icon, xScale, yScale)
	end

	-- Shadow
	Shadow = (Shadow and not Disabled) or false
	SkinRegion("Shadow", Shadow, Button, Skin.Shadow, Colors.Shadow, xScale, yScale)

	-- Normal
	local Normal = Regions.Normal

	if Normal ~= false then
		SkinRegion("Normal", Normal, Button, Skin.Normal, Colors.Normal, xScale, yScale)
	end

	-- FontStrings and Textures
	local Layers = (bType and RegTypes[bType]) or RegTypes.Legacy

	for Layer, Info in pairs(Layers) do
		if Info.Iterate then
			local Region = Regions[Layer]
			local Type = Info.Type

			if Region then
				if Type == "FontString" then
					SkinRegion("Text", Region, Button, Layer, Skin[Layer], xScale, yScale)
				else
					SkinRegion(Type, Region, Button, Layer, Skin[Layer], Colors[Layer], xScale, yScale)
				end
			end
		end
	end

	-- IconBorder
	local IconBorder = Regions.IconBorder

	if IconBorder then
		SkinRegion("IconBorder", IconBorder, Button, Skin.IconBorder, xScale, yScale)
	end

	-- Gloss
	Gloss = (Gloss and not Disabled) or false
	SkinRegion("Gloss", Gloss, Button, Skin.Gloss, Colors.Gloss, xScale, yScale)

	-- NewItem
	local NewItem = Regions.NewItem

	if NewItem then
		SkinRegion("NewItem", NewItem, Button, Skin.NewItem, xScale, yScale)
	end

	-- Cooldown
	local Cooldown = Regions.Cooldown

	if Cooldown then
		SkinRegion("Cooldown", Cooldown, Button, Skin.Cooldown, Colors.Cooldown, xScale, yScale)
	end

	-- ChargeCooldown
	local Charge = Regions.ChargeCooldown or Button.chargeCooldown
	local ChargeSkin = Skin.ChargeCooldown

	Button.__MSQ_ChargeSkin = ChargeSkin

	if Charge then
		SkinRegion("Cooldown", Charge, Button, ChargeSkin, nil, xScale, yScale)
	end

	-- AutoCastShine
	local Shine = Regions.AutoCastShine

	if Shine then
		SkinRegion("Frame", Shine, Button, Skin.AutoCastShine, xScale, yScale)
	end

	-- SpellAlert
	SkinRegion("SpellAlert", Button)
end
