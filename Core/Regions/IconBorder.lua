--[[

	This file is part of 'Masque', an add-on for World of Warcraft. For bug reports,
	suggestions and license information, please visit https://github.com/SFX-WoW/Masque.

	* File...: Core\Regions\IconBorder.lua
	* Author.: StormFX

	Texture Regions

	* See Skins\Default.lua for region defaults.

]]

local _, Core = ...

----------------------------------------
-- Internal
---

-- @ Masque
local Masque = Core.AddOn

-- @ Skins\Default
local Default = Core.DEFAULT_SKIN.IconBorder

-- @ Core\Utility
local GetSize, GetTexCoords, SetPoints = Core.GetSize, Core.GetTexCoords, Core.SetPoints
local GetTypeSkin = Core.GetTypeSkin

----------------------------------------
-- Locals
---

local DEFAULT_TEXTURE = Default.Texture
local RELIC_TEXTURE = Default.RelicTexture

----------------------------------------
-- Hook
---

-- Counters texture changes for artifact items.
local function Hook_SetTexture(Region, Texture)
	if Region.__ExitHook or not Region.__MSQ_Skin then
		return
	end

	Region.__ExitHook = true

	local Skin = Region.__MSQ_Skin
	local SkinTexture = Skin.Texture

	if Texture == RELIC_TEXTURE then
		SkinTexture = Skin.RelicTexture or SkinTexture or Texture
		Region.__MSQ_Texture = Texture
	else
		SkinTexture = SkinTexture or DEFAULT_TEXTURE
		Region.__MSQ_Texture = DEFAULT_TEXTURE
	end

	Region:SetTexture(SkinTexture)
	Region.__ExitHook = nil
end

----------------------------------------
-- Core
---

-- Skins the 'IconBorder' region of a button.
function Core.SkinIconBorder(Region, Button, Skin, xScale, yScale)
	local Texture = Region.__MSQ_Texture or Region:GetTexture()
	Skin = GetTypeSkin(Button, Button.__MSQ_bType, Skin)

	if Button.__MSQ_Enabled then
		Region.__MSQ_Skin = Skin
		Region.__MSQ_Texture = Texture

		Hook_SetTexture(Region, Texture)

		if not Masque:IsHooked(Region, "SetTexture") then
			Masque:SecureHook(Region, "SetTexture", Hook_SetTexture)
		end
	else
		if Masque:IsHooked(Region, "SetTexture") then
			Masque:UnHook(Region, "SetTexture")
		end

		Region.__MSQ_Skin = nil
		Region.__MSQ_Texture = nil

		Region:SetTexture(Texture)
	end

	Region:SetTexCoord(GetTexCoords(Skin.TexCoords))
	Region:SetBlendMode(Skin.BlendMode or "BLEND")
	Region:SetDrawLayer(Skin.DrawLayer or "OVERLAY", Skin.DrawLevel or 0)
	Region:SetSize(GetSize(Skin.Width, Skin.Height, xScale, yScale))
	SetPoints(Region, Button, Skin, nil, Skin.SetAllPoints)
end
