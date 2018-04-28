--[[
	Item link format: |c<QUALITY COLOR>|Hitem:<ID>:<ENCHANT>:<GEM1>:<GEM2>:<GEM3>:<GEM4>:<SUFFIX>:<SUFFIX POWER>|h[<ITEM NAME & SUFFIX>]|h|r
	The <ENCHANT> and <GEM*> fields can have both normal enchantments and gems.
	Pre-TBC items use a different suffix system, but can still be modified to use the TBC way.
	http://www.wowwiki.com/ItemString?oldid=1031624
--]]

FakeItem = {}

----------------------------------------------------------------------------------------------------
-- item properties
----------------------------------------------------------------------------------------------------
-- Some Vanilla-style suffixes do the same thing as others and aren't added to the list. These are
-- the left out ones and which list suffix that they're a copy of
local suffixDuplicates = {
	[1649] = 1648, [1651] = 1650, [1653] = 1652, [1655] = 1654, [1659] = 1658,
	[1661] = 1660, [1663] = 1662, [1665] = 1664, [1666] = 1664, [1669] = 1668,
	[1670] = 1668, [1671] = 1668, [1673] = 1672, [1675] = 1674, [1676] = 1674,
	[1678] = 1677, [1679] = 1677, [1680] = 1677, [1681] = 1677, [1683] = 1682,
	[1685] = 1684, [1686] = 1684, [1687] = 1684, [1689] = 1688, [1691] = 1690,
	[1692] = 1690, [1693] = 1690, [1695] = 1694, [1697] = 1696, [1698] = 1696,
	[1699] = 1696, [1701] = 1700, [1703] = 1702, [2068] = 2067, [2069] = 2067,
	[2071] = 2070, [2072] = 2070, [2074] = 2073, [2076] = 2075, [2077] = 2075,
	[2079] = 2078, [2081] = 2080, [2082] = 2080, [2084] = 2083, [2086] = 2085,
	[2087] = 2085, [2089] = 2088, [2091] = 2090, [2092] = 2090, [2094] = 2093,
	[2096] = 2095, [2097] = 2095, [2099] = 2098, [2101] = 2100, [2102] = 2100,
	[2104] = 2103, [1743] = 1742, [1744] = 1742, [1745] = 1742, [1746] = 1742,
	[1747] = 1742, [1749] = 1748, [1750] = 1748, [1752] = 1751, [1753] = 1751,
	[1755] = 1754, [1756] = 1754, [1758] = 1757, [1759] = 1757, [1761] = 1760,
	[1762] = 1760, [1764] = 1763, [1765] = 1763, [1767] = 1766, [1768] = 1766,
	[1770] = 1769, [1771] = 1769, [1773] = 1772, [1774] = 1772, [1775] = 1772,
	[1776] = 1772, [1777] = 1772, [1778] = 1772, [1779] = 1772, [1781] = 1780,
	[1782] = 1780, [1784] = 1783, [1785] = 1783, [1787] = 1786, [1788] = 1786,
	[1789] = 1786, [1791] = 1790, [1792] = 1790, [1794] = 1793, [1795] = 1793,
	[1796] = 1793, [1798] = 1797, [2106] = 2105, [2107] = 2105, [2108] = 2105,
	[2109] = 2105, [2111] = 2110, [2112] = 2110, [2113] = 2110, [2115] = 2114,
	[2116] = 2114, [2117] = 2114, [2119] = 2118, [2120] = 2118, [2121] = 2118,
	[2123] = 2122, [2124] = 2122, [2125] = 2122, [2127] = 2126, [2128] = 2126,
	[2129] = 2126, [2131] = 2130, [2132] = 2130, [2133] = 2130, [2135] = 2134,
	[2136] = 2134, [2137] = 2134, [2139] = 2138, [2140] = 2138, [2141] = 2138,
}

----------------------------------------------------------------------------------------------------
-- GUI
----------------------------------------------------------------------------------------------------
-- item settings
local itemName -- doesn't include suffix
local itemQuality -- full color code including |c
local itemId
local itemLink
local itemEnchantName, itemEnchantId
local itemGemName1, itemGemId1
local itemGemName2, itemGemId2
local itemGemName3, itemGemId3
local itemGemName4, itemGemId4
local itemSuffixPath, itemSuffixName, itemSuffixId, itemSuffixPower

-- GUI settings
local GUI_BUTTON_WIDTH   = 100
local GUI_BUTTON_SPACING = 6

--------------------------------------------------
-- main frame
--------------------------------------------------
local guiFrame = CreateFrame("Frame", "FakeItemFrame", UIParent)
table.insert(UISpecialFrames, guiFrame:GetName()) -- make it closable with escape key
guiFrame:SetFrameStrata("HIGH")
guiFrame:SetBackdrop({
	bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
	tile=1, tileSize=32, edgeSize=32,
	insets={left=11, right=12, top=12, bottom=11}
})
guiFrame:SetPoint("CENTER")
guiFrame:SetWidth(((GUI_BUTTON_WIDTH+GUI_BUTTON_SPACING) * 7) + 40) -- +40 because of rude long shoulder enchant name
guiFrame:SetHeight(196)

-- make it draggable
guiFrame:SetMovable(true)
guiFrame:EnableMouse(true)
guiFrame:RegisterForDrag("LeftButton")
guiFrame:SetScript("OnDragStart", guiFrame.StartMoving)
guiFrame:SetScript("OnDragStop", guiFrame.StopMovingOrSizing)
guiFrame:SetScript("OnMouseDown", function(self, button)
	if button == "LeftButton" and not self.isMoving then
		local cursorType, _, cursorLink = GetCursorInfo()
		if cursorType == "item" then
			_G.SlashCmdList["FAKEITEM"](cursorLink)
			ClearCursor()
		end
		self:StartMoving()
		self.isMoving = true
	end
end)
guiFrame:SetScript("OnMouseUp", function(self, button)
	if button == "LeftButton" and self.isMoving then
		self:StopMovingOrSizing()
		self.isMoving = false
	end
end)
guiFrame:SetScript("OnReceiveDrag", function(self)
	local cursorType, _, cursorLink = GetCursorInfo()
	if cursorType == "item" then
		_G.SlashCmdList["FAKEITEM"](cursorLink)
		ClearCursor()
	end
end)
guiFrame:SetScript("OnHide", function(self)
	if self.isMoving then
		self:StopMovingOrSizing()
		self.isMoving = false
	end
end)

--------------------------------------------------
-- item name and ID at the top
--------------------------------------------------
local textItem = guiFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
textItem:SetPoint("TOP", guiFrame, "TOP", 0, -16)

--------------------------------------------------
-- enchantment option
--------------------------------------------------
local buttonEnchant = CreateFrame("Button", "FakeItemButtonEnchant", guiFrame, "UIPanelButtonTemplate2")
buttonEnchant:SetWidth(GUI_BUTTON_WIDTH)
buttonEnchant:SetPoint("TOP", textItem, "BOTTOM", 0, -6) -- will be centered horizontally later
_G[buttonEnchant:GetName().."Text"]:SetText("Enchant")

local checkboxEnchant = CreateFrame("CheckButton", "FakeItemCheckboxEnchant", guiFrame, "OptionsCheckButtonTemplate")
checkboxEnchant:SetPoint("TOPLEFT", buttonEnchant, "BOTTOMLEFT", 0, 4)
_G[checkboxEnchant:GetName().."Text"]:SetText("Red")
checkboxEnchant.tooltipText = "If checked, this line on the item tooltip will be red."
checkboxEnchant:SetHitRectInsets(0, -_G[checkboxEnchant:GetName().."Text"]:GetStringWidth(), 4, 4)

--------------------------------------------------
-- gem #1 option
--------------------------------------------------
local buttonGem1 = CreateFrame("Button", "FakeItemButtonGem1", guiFrame, "UIPanelButtonTemplate2")
buttonGem1:SetWidth(GUI_BUTTON_WIDTH)
buttonGem1:SetPoint("LEFT", buttonEnchant, "RIGHT", GUI_BUTTON_SPACING, 0)
_G[buttonGem1:GetName().."Text"]:SetText("Gem #1")

--------------------------------------------------
-- gem #2 option
--------------------------------------------------
local buttonGem2 = CreateFrame("Button", "FakeItemButtonGem2", guiFrame, "UIPanelButtonTemplate2")
buttonGem2:SetWidth(GUI_BUTTON_WIDTH)
buttonGem2:SetPoint("LEFT", buttonGem1, "RIGHT", GUI_BUTTON_SPACING, 0)
_G[buttonGem2:GetName().."Text"]:SetText("Gem #2")

--------------------------------------------------
-- gem #3 option
--------------------------------------------------
local buttonGem3 = CreateFrame("Button", "FakeItemButtonGem3", guiFrame, "UIPanelButtonTemplate2")
buttonGem3:SetWidth(GUI_BUTTON_WIDTH)
buttonGem3:SetPoint("LEFT", buttonGem2, "RIGHT", GUI_BUTTON_SPACING, 0)
_G[buttonGem3:GetName().."Text"]:SetText("Gem #3")

--------------------------------------------------
-- gem #4 option
--------------------------------------------------
local buttonGem4 = CreateFrame("Button", "FakeItemButtonGem4", guiFrame, "UIPanelButtonTemplate2")
buttonGem4:SetWidth(GUI_BUTTON_WIDTH)
buttonGem4:SetPoint("LEFT", buttonGem3, "RIGHT", GUI_BUTTON_SPACING, 0)
_G[buttonGem4:GetName().."Text"]:SetText("Gem #4")

local checkboxGem4 = CreateFrame("CheckButton", "FakeItemCheckboxGem4", guiFrame, "OptionsCheckButtonTemplate")
checkboxGem4:SetPoint("TOPLEFT", buttonGem4, "BOTTOMLEFT", 0, 4)
_G[checkboxGem4:GetName().."Text"]:SetText("Red")
checkboxGem4.tooltipText = "If checked, this line on the item tooltip will be red."
checkboxGem4:SetHitRectInsets(0, -_G[checkboxGem4:GetName().."Text"]:GetStringWidth(), 4, 4)

--------------------------------------------------
-- suffix option
--------------------------------------------------
-- for showing tooltips
local function WidgetTooltip_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT")
	GameTooltip:SetText(this.tooltipText, nil, nil, nil, nil, 1)
	GameTooltip:Show()
end
local function WidgetTooltip_OnLeave()
	GameTooltip:Hide()
end

local buttonSuffix = CreateFrame("Button", "FakeItemButtonSuffix", guiFrame, "UIPanelButtonTemplate2")
buttonSuffix:SetWidth(GUI_BUTTON_WIDTH)
buttonSuffix:SetPoint("LEFT", buttonGem4, "RIGHT", GUI_BUTTON_SPACING, 0)
_G[buttonSuffix:GetName().."Text"]:SetText("Suffix")

local inputSuffix = CreateFrame("EditBox", "FakeItemInputSuffix", guiFrame, "InputBoxTemplate")
inputSuffix:SetWidth(45)
inputSuffix:SetHeight(40)
inputSuffix:SetPoint("LEFT", buttonSuffix, "RIGHT", 8, -2)
inputSuffix:SetNumeric(true)
inputSuffix:SetMaxLetters(5)
inputSuffix:SetAutoFocus(false)
inputSuffix.tooltipText = "When using TBC suffixes, this sets how strong they are."
inputSuffix:SetScript("OnEnter", WidgetTooltip_OnEnter)
inputSuffix:SetScript("OnLeave", WidgetTooltip_OnLeave)
inputSuffix:SetScript("OnEnterPressed", function() inputSuffix:ClearFocus() end)
inputSuffix:SetScript("OnEditFocusLost", function()
	local value = tonumber(inputSuffix:GetText())
	if not value then
		inputSuffix:SetNumber(0)
	elseif value > 65535 then
		inputSuffix:SetNumber(65535)
	end
end)

local textSuffix = guiFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
textSuffix:SetPoint("BOTTOMLEFT", inputSuffix, "TOPLEFT", 0, -8)
textSuffix:SetText("Power:")

--------------------------------------------------
-- center the buttons/input
--------------------------------------------------
buttonEnchant:SetPoint("LEFT", guiFrame, "CENTER", 0-((inputSuffix:GetRight()-buttonEnchant:GetLeft())/2), 0)

--------------------------------------------------
-- description
--------------------------------------------------
local textDescription = guiFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
textDescription:SetPoint("TOP", checkboxEnchant, "BOTTOM", 0, -3)
textDescription:SetPoint("LEFT", guiFrame, "LEFT", 16, 0)
textDescription:SetJustifyH("LEFT")

--------------------------------------------------
-- reset button
--------------------------------------------------
local buttonReset = CreateFrame("Button", "FakeItemButtonReset", guiFrame, "UIPanelButtonTemplate2")
buttonReset:SetWidth(150)
buttonReset:SetPoint("BOTTOMLEFT", guiFrame, "BOTTOMLEFT", 16, 12)
_G[buttonReset:GetName().."Text"]:SetText("Reset")

--------------------------------------------------
-- create link button
--------------------------------------------------
local buttonCreate = CreateFrame("Button", "FakeItemButtonCreate", guiFrame, "UIPanelButtonTemplate2")
buttonCreate:SetWidth(150)
buttonCreate:SetPoint("BOTTOM", guiFrame, "BOTTOM", 0, 12)
_G[buttonCreate:GetName().."Text"]:SetText("Create Link")
buttonCreate:SetScript("OnClick", function()
	inputSuffix:ClearFocus()

	-- set and fix the suffix power
	itemSuffixPower = tonumber(inputSuffix:GetText())
	if not itemSuffixPower or itemSuffixPower < 0 then
		itemSuffixPower = 0
		inputSuffix:SetNumber(0)
	elseif itemSuffixPower > 65535 then
		itemSuffixPower = 65535
		inputSuffix:SetNumber(65535)
	end

	-- create new link
	local fakeLink = string.format("%s|Hitem:%d:%s%d:%d:%d:%d:%s%d:%d:%d|h[%s]|h|r",
		itemQuality, itemId or 0,
		(checkboxEnchant:GetChecked() and "-" or ""), itemEnchantId or 0,
		itemGemId1 or 0,
		itemGemId2 or 0,
		itemGemId3 or 0,
		(checkboxGem4:GetChecked() and "-" or ""), itemGemId4 or 0,
		itemSuffixId or 0, itemSuffixPower,
		(itemName .. (itemSuffixName and " " or "") .. (itemSuffixName or ""))
	)

	DEFAULT_CHAT_FRAME:AddMessage(fakeLink)
end)

--------------------------------------------------
-- close button
--------------------------------------------------
local buttonClose = CreateFrame("Button", "FakeItemButtonClose", guiFrame, "UIPanelButtonTemplate2")
buttonClose:SetWidth(150)
buttonClose:SetPoint("BOTTOMRIGHT", guiFrame, "BOTTOMRIGHT", -16, 12)
_G[buttonClose:GetName().."Text"]:SetText("Close")
buttonClose:SetScript("OnClick", function() guiFrame:Hide() end)

--------------------------------------------------
-- done adding widgets
--------------------------------------------------
guiFrame:Hide()

--------------------------------------------------
-- update the item's description text
--------------------------------------------------
local function UpdateDescription()
	textItem:SetText(itemQuality .. itemName .. "|r [" .. itemId .. "]")

	textDescription:SetFormattedText("Enchant: |cff00ff00%d|r: |cffffffff%s|r\nGem1: |cff00ff00%d|r: |cffffffff%s|r\nGem2: |cff00ff00%d|r: |cffffffff%s|r\nGem3: |cff00ff00%d|r: |cffffffff%s|r\nGem4: |cff00ff00%d|r: |cffffffff%s|r\nSuffix: |cff00ff00%d|r: |cffffffff%s|r",
		itemEnchantId, itemEnchantName or (itemEnchantId == 0 and "none" or "unknown"),
		itemGemId1, itemGemName1 or (itemGemId1 == 0 and "none" or "unknown"),
		itemGemId2, itemGemName2 or (itemGemId2 == 0 and "none" or "unknown"),
		itemGemId3, itemGemName3 or (itemGemId3 == 0 and "none" or "unknown"),
		itemGemId4, itemGemName4 or (itemGemId4 == 0 and "none" or "unknown"),
		itemSuffixId, itemSuffixPath or "none")
end

--------------------------------------------------
-- reset item settings and open the GUI
--------------------------------------------------
-- recursively search through the enchantment menu to find the name of an enchantID
local function FindEnchantName(onTable, id)
	local name
	for i=1,#onTable do
		if onTable[i].menuList then
			name = FindEnchantName(onTable[i].menuList, id)
			if name then
				return name
			end
		elseif onTable[i].arg2 == id then
			return onTable[i].arg1
		end
	end
end

-- recursively search through the suffix menu to find the name of a suffix ID
local function FindSuffixName(onTable, id)
	local name
	for i=1,#onTable do
		if type(onTable[i]) == "table" then
			if onTable[i].menuList then
				name, path = FindSuffixName(onTable[i].menuList, id)
				if name then
					return name, path
				end
			elseif onTable[i].value == id then
				return onTable[i].arg2, onTable[i].arg1
			end
		end
	end
end

local function ResetGui()
	-- reset checkboxes
	checkboxEnchant:SetChecked(false)
	checkboxGem4:SetChecked(false)

	-- set the item string number values
	itemId, itemEnchantId, itemGemId1, itemGemId2, itemGemId3, itemGemId4, itemSuffixId, itemSuffixPower = nil, nil, nil, nil, nil, nil, nil, nil

	local parameters = itemLink:match("item:([%d:-]+)") -- extract the ID:enchant:gem1:gem2:gem3:gem4:suffix:power part of the item link
	if parameters then
		itemId, itemEnchantId, itemGemId1, itemGemId2, itemGemId3, itemGemId4, itemSuffixId, itemSuffixPower = strsplit(":", parameters)
		itemId = tonumber(itemId)
		itemEnchantId = tonumber(itemEnchantId)
		itemGemId1 = tonumber(itemGemId1)
		itemGemId2 = tonumber(itemGemId2)
		itemGemId3 = tonumber(itemGemId3)
		itemGemId4 = tonumber(itemGemId4)
		itemSuffixId = tonumber(itemSuffixId)
		itemSuffixPower = tonumber(itemSuffixPower)

		itemEnchantName = itemEnchantId == 0 and "none" or FindEnchantName(FakeItem.enchantmentMenu, itemEnchantId) or "unknown"
		itemGemName1 = itemGemId1 == 0 and "none" or FindEnchantName(FakeItem.enchantmentMenu, itemGemId1) or "unknown"
		itemGemName2 = itemGemId2 == 0 and "none" or FindEnchantName(FakeItem.enchantmentMenu, itemGemId2) or "unknown"
		itemGemName3 = itemGemId3 == 0 and "none" or FindEnchantName(FakeItem.enchantmentMenu, itemGemId3) or "unknown"
		itemGemName4 = itemGemId4 == 0 and "none" or FindEnchantName(FakeItem.enchantmentMenu, itemGemId4) or "unknown"

		-- fix the item name and suffix name
		itemQuality, itemName = itemLink:match("^(|c%x+)|H.*%[(.*)]")
		itemSuffixPath, itemSuffixName = nil, nil
		if itemSuffixId ~= 0 then
			local id = suffixDuplicates[itemSuffixId] or itemSuffixId
			itemSuffixName, itemSuffixPath = FindSuffixName(FakeItem.suffixMenu, id)
			if itemSuffixName then
				itemName = itemName:match("(.*) " .. itemSuffixName)
			end
		end
	end

	-- make sure it's a proper item -- an error here should only happen if the GUI isn't open yet
	if not itemName or not itemId or not itemEnchantId or not itemGemId1 or not itemGemId2 or not itemGemId3 or not itemGemId4 or not itemSuffixId or not itemSuffixPower then
		DEFAULT_CHAT_FRAME:AddMessage("FakeItem: That was a bad item link!", 1, 0, 0)
		return
	end

	-- set the GUI text and show the window
	textItem:SetText(itemName .. " [ID: " .. itemId .. "]")
	inputSuffix:SetText(itemSuffixPower)
	UpdateDescription()
	guiFrame:Show()
end

buttonReset:SetScript("OnClick", function() CloseDropDownMenus() inputSuffix:ClearFocus() ResetGui() end)

----------------------------------------------------------------------------------------------------
-- dropdown menus
----------------------------------------------------------------------------------------------------
local menuFrame = CreateFrame("frame", "FakeItemMenu", guiFrame, "UIDropDownMenuTemplate")
local enchantmentMenuOpened = nil -- which menu is currenly opened - 1 to 5, meaning enchant/gem1/gem2/gem3/gem4

-- open a menu. button = the button to open it on. menu = the menu to use.
-- optional enchantment number: enchantment=1, gem1=2, gem2=3, gem3=4, gem4=5
local function OpenMenu(button, menu, enchantmentNumber)
	inputSuffix:ClearFocus()
	CloseDropDownMenus()
	enchantmentMenuOpened = enchantmentNumber
	EasyMenu(menu, menuFrame, button, 0 , 0, "MENU");
end

--------------------------------------------------
-- enchantment menu
--------------------------------------------------
-- called from each menu item - set the item's new enchantment/gem
function FakeItem.SetEnchantmentFromMenu(name, id)
	if not name or not id then
		name = "none"
		id = 0
	end

	if enchantmentMenuOpened == 1 then
		itemEnchantName, itemEnchantId = name, id
	elseif enchantmentMenuOpened == 2 then
		itemGemName1, itemGemId1 = name, id
	elseif enchantmentMenuOpened == 3 then
		itemGemName2, itemGemId2 = name, id
	elseif enchantmentMenuOpened == 4 then
		itemGemName3, itemGemId3 = name, id
	elseif enchantmentMenuOpened == 5 then
		itemGemName4, itemGemId4 = name, id
	end

	UpdateDescription()
	CloseDropDownMenus() -- have to close the menu with this or else only the submenu will close
end

buttonEnchant:SetScript("OnClick", function() OpenMenu(this, FakeItem.enchantmentMenu, 1) end)
buttonGem1:SetScript("OnClick", function() OpenMenu(this, FakeItem.enchantmentMenu, 2) end)
buttonGem2:SetScript("OnClick", function() OpenMenu(this, FakeItem.enchantmentMenu, 3) end)
buttonGem3:SetScript("OnClick", function() OpenMenu(this, FakeItem.enchantmentMenu, 4) end)
buttonGem4:SetScript("OnClick", function() OpenMenu(this, FakeItem.enchantmentMenu, 5) end)

--------------------------------------------------
-- suffix menu
--------------------------------------------------
-- called from each menu item - set the item's new suffix
function FakeItem.SetSuffixFromMenu(fullName, suffixName)
	if not fullName or not suffixName or not this or this.value == 0 then
		itemSuffixPath = nil
		itemSuffixName = nil
		itemSuffixId = 0
	else
		itemSuffixPath = fullName
		itemSuffixName = suffixName
		itemSuffixId = this.value
	end
	UpdateDescription()
	CloseDropDownMenus()
end

buttonSuffix:SetScript("OnClick", function() OpenMenu(this, FakeItem.suffixMenu) end)

----------------------------------------------------------------------------------------------------
-- slash command - open the GUI after being given an item link or ID to start with
----------------------------------------------------------------------------------------------------
-- if the server needs to be queried with an ID, this will keep checking for a few seconds if needed
local retryFrame    = CreateFrame("frame")
local retryId       = 0
local retryAttempts = 0
local retryTime     = 0
retryFrame:Hide()
retryFrame:SetScript("OnUpdate", function(self, elapsed)
	retryTime = retryTime - elapsed
	if retryTime <= 0 then
		retryTime = retryTime + 1
		SlashCmdList.FAKEITEM(retryId)
	end
end)

_G.SLASH_FAKEITEM1 = "/fakeitem"
function SlashCmdList.FAKEITEM(input)
	if not input or input == "" then
		DEFAULT_CHAT_FRAME:AddMessage("Usage: /fakeitem <item link or item ID#>", 1, 1, 0)
		return
	end

	-- load menu data if needed
	if not FakeItem.enchantmentMenu then
		local _, reason = LoadAddOn("FakeItemData")
		if not FakeItem.enchantmentMenu then
			DEFAULT_CHAT_FRAME:AddMessage("Unable to load the FakeItemData addon: " .. (reason or "no error message given!"), 1, 0, 0)
			return
		end
	end

	-- set the item link from either the passed in link or item ID
	itemLink = nil
	if tonumber(input) ~= nil then
		local id = tonumber(input)
		itemLink = select(2, GetItemInfo(id))
		-- if the ID isn't known, the server will be queried
		if not itemLink then
			if retryId == id then
				-- item is currently being checked - show a message if it's being slow or give up
				retryAttempts = retryAttempts + 1
				if retryAttempts == 2 then
					DEFAULT_CHAT_FRAME:AddMessage("FakeItem: An item using ID " .. retryId .. " isn't known so the server is being queried...", 0, 1, 0)
				elseif retryAttempts >= 6 then
					DEFAULT_CHAT_FRAME:AddMessage("FakeItem: An item using ID " .. retryId .. " doesn't seem to exist!", 1, 0, 0)
					retryFrame:Hide()
				end
			else
				-- query the server for the item and start the automatic checking for it
				GameTooltip:SetHyperlink("item:" .. id)
				retryId = id
				retryAttempts = 0
				retryTime = 1
				retryFrame:Show()
			end
			return
		end
	else
		itemLink = input
		if not itemLink then
			DEFAULT_CHAT_FRAME:AddMessage("FakeItem: That isn't an item link or an ID!", 1, 0, 0)
			return
		end
	end

	retryId = nil
	retryFrame:Hide()
	ResetGui()
end
