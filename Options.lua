-- HudTooltipTweaks: settings panel. Hand-built with a plain CheckButton
-- template and registered via Settings.RegisterCanvasLayoutCategory, instead
-- of the native Settings.CreateCheckbox/RegisterProxySetting path used
-- originally - confirmed that path's checkbox write never actually reached
-- this addon's saved value on this client (a direct slash-command toggle
-- worked fine while the checkbox did nothing), so the new per-line
-- checkboxes use the same hand-built CheckButton approach already proven
-- working in SwingTimerBuffTracking's own options panel instead of repeating
-- the same broken mechanism.

local Addon = HudTooltipTweaks

local Options = {}
Addon.Options = Options

local category
local panel

local function MakeCheck(parent, text, onClick)
	local c = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	local label = c.Text or c.text or c:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	label:ClearAllPoints()
	label:SetPoint("LEFT", c, "RIGHT", 2, 1)
	label:SetText(text)
	c:SetScript("OnClick", function(self)
		onClick(self:GetChecked() and true or false)
	end)
	return c
end

function Options:Init()
	if category then
		return
	end
	local db = Addon.db

	panel = CreateFrame("Frame")
	panel.name = Addon.name

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(Addon.name)

	local targetCheck = MakeCheck(panel, "Show target in tooltip", function(value)
		db.showMouseoverTarget = value
	end)
	targetCheck:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -2, -16)

	local guildCheck = MakeCheck(panel, "Show guild line", function(value)
		db.showGuildLine = value
	end)
	guildCheck:SetPoint("TOPLEFT", targetCheck, "BOTTOMLEFT", 0, -8)

	local levelCheck = MakeCheck(panel, "Show level/race line", function(value)
		db.showLevelLine = value
	end)
	levelCheck:SetPoint("TOPLEFT", guildCheck, "BOTTOMLEFT", 0, -8)

	local classCheck = MakeCheck(panel, "Show class line", function(value)
		db.showClassLine = value
	end)
	classCheck:SetPoint("TOPLEFT", levelCheck, "BOTTOMLEFT", 0, -8)

	local factionCheck = MakeCheck(panel, "Show faction line", function(value)
		db.showFactionLine = value
	end)
	factionCheck:SetPoint("TOPLEFT", classCheck, "BOTTOMLEFT", 0, -8)

	function panel:Refresh()
		targetCheck:SetChecked(db.showMouseoverTarget)
		guildCheck:SetChecked(db.showGuildLine)
		levelCheck:SetChecked(db.showLevelLine)
		classCheck:SetChecked(db.showClassLine)
		factionCheck:SetChecked(db.showFactionLine)
	end
	panel:SetScript("OnShow", panel.Refresh)

	category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
	Settings.RegisterAddOnCategory(category)
end

function Options:Open()
	if not category then
		return
	end
	-- OpenToCategory's argument has shifted between client builds; try the
	-- category object first and its numeric id as a fallback.
	if not pcall(Settings.OpenToCategory, category) then
		pcall(Settings.OpenToCategory, category.GetID and category:GetID() or nil)
	end
end
