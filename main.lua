--[[ 
    Copyright 2024 Lounek
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
       http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_HEALTH");
frame:RegisterEvent("UNIT_POWER_FREQUENT");
frame:RegisterEvent("PLAYER_TARGET_CHANGED");

local healthTextFrame = frame:CreateFontString(nil, "BORDER", "TextStatusBarText")
healthTextFrame:SetTextScale(0.9)
healthTextFrame:SetPoint("CENTER", _G["TargetFrameHealthBar"], "CENTER", 0, 0)
healthTextFrame:Hide()

local powerTextFrame = frame:CreateFontString(nil, "BORDER", "TextStatusBarText")
powerTextFrame:SetTextScale(0.9)
powerTextFrame:SetPoint("CENTER", _G["TargetFrameManaBar"], "CENTER", 0, 0)
powerTextFrame:Hide()

local function IsHealthKnown()
  local guid = UnitGUID("target")
  if not guid then
    return false
  end
  
  local unitType = strsplit("-", guid)
  if unitType == "Player" or unitType == "Pet" then
    return UnitPlayerOrPetInRaid("target") 
    or UnitPlayerOrPetInParty("target")
  end

  return true
end

local function FormatNumber(value)
  if value >= 1000000 then
    return format("%.1fm", value / 1000000)
  elseif value >= 10000 then
    return format("%.1fk", value / 1000)
  else
    return value
  end
end

local function Show()
  healthTextFrame:Show()
  powerTextFrame:Show()
end

local function Hide()
  healthTextFrame:Hide()
  powerTextFrame:Hide()
end

local function UpdateHealth()
  local hp = UnitHealth("target")
  
  if IsHealthKnown() then
    local maxhp = UnitHealthMax("target")
    healthTextFrame:SetText(format("%s / %s", FormatNumber(hp), FormatNumber(maxhp)))
  else
    healthTextFrame:SetText(format("%s%%", hp))
  end
end

local function UpdatePower()
  local maxValue = UnitPowerMax("target")
  
  if maxValue > 0 then
    local value = UnitPower("target")
    powerTextFrame:SetText(format("%s / %s", FormatNumber(value), FormatNumber(maxValue)))
  else
    powerTextFrame:Hide()
  end
end

local function Update()
  if not UnitExists("target") or UnitIsDead("target") then
    Hide()
    return
  end
  
  Show()
  UpdateHealth()
  UpdatePower()
end

local function HandleUnitEvent(unit)
  if unit == "target" then
    Update()
  end
end

local EventHandler = function(self, event, arg1, ...)
  if event == "PLAYER_TARGET_CHANGED" then
    Update()
  elseif event == "UNIT_HEALTH" or event == "UNIT_POWER_FREQUENT" then
    HandleUnitEvent(arg1)
  end
end

frame:SetScript("OnEvent", EventHandler)
