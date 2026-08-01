if getgenv().AutoRollSystem then
getgenv().AutoRollSystem.Enabled = false
if getgenv().AutoRollSystem.Connection then
pcall(function() getgenv().AutoRollSystem.Connection:Disconnect() end)
end
getgenv().AutoRollSystem = nil
end
getgenv().AutoRollSystem = {
Enabled = false,
Connection = nil
}
local Players = game:GetService(string.char(80, 108, 97, 121, 101, 114, 115))
local ReplicatedStorage = game:GetService(string.char(82, 101, 112, 108, 105, 99, 97, 116, 101, 100, 83, 116, 111, 114, 97, 103, 101))
local LocalPlayer = Players.LocalPlayer
local RarityList = {
string.char(65, 108, 108, 32, 82, 97, 114, 105, 116, 105, 101, 115), string.char(67, 111, 109, 109, 111, 110), string.char(82, 97, 114, 101), string.char(69, 112, 105, 99), string.char(76, 101, 103, 101, 110, 100, 97, 114, 121), string.char(77, 121, 116, 104, 105, 99), string.char(71, 111, 100), string.char(83, 101, 99, 114, 101, 116), string.char(76, 105, 109, 105, 116, 101, 100)
}
local CharacterList = {
string.char(65, 108, 108, 32, 67, 104, 97, 114, 97, 99, 116, 101, 114, 115), string.char(83, 97, 105, 116, 97, 109, 97), string.char(76, 117, 102, 102, 121), string.char(82, 105, 109, 117, 114, 117), string.char(83, 104, 105, 110, 114, 97), string.char(65, 114, 116, 104, 117, 114), string.char(83, 117, 107, 117, 110, 97, 32, 40, 72, 101, 105, 97, 110, 41), string.char(85, 115, 115, 111, 112), string.char(77, 97, 110, 106, 105),
string.char(71, 111, 106, 111), string.char(71, 111, 107, 117), string.char(72, 111, 115, 104, 105, 110, 97), string.char(89, 104, 119, 97, 116, 99, 104), string.char(66, 97, 110), string.char(79, 107, 117, 114, 117, 110), string.char(77, 97, 107, 105), string.char(74, 117, 110, 119, 111, 111), string.char(83, 116, 97, 114, 107), string.char(77, 111, 98),
string.char(69, 114, 119, 105, 110), string.char(90, 111, 114, 111), string.char(73, 116, 97, 100, 111, 114, 105), string.char(71, 117, 116, 115), string.char(83, 97, 107, 117, 114, 97), string.char(75, 111, 107, 117, 115, 104, 105, 98, 111), string.char(78, 97, 114, 117, 116, 111, 67, 108, 111, 110, 101), string.char(78, 97, 114, 117, 116, 111),
string.char(75, 114, 105, 108, 108, 105, 110), string.char(84, 97, 110, 106, 105, 114, 111), string.char(70, 114, 105, 101, 122, 97), string.char(70, 114, 105, 101, 114, 101, 110), string.char(66, 114, 111, 108, 121), string.char(84, 114, 117, 110, 107, 115), string.char(80, 105, 99, 99, 111, 108, 111), string.char(89, 111, 114), string.char(87, 104, 105, 115),
string.char(65, 99, 101), string.char(65, 107, 97, 122, 97), string.char(68, 111, 117, 109, 97), string.char(77, 117, 122, 97, 110), string.char(77, 117, 122, 97, 110, 32, 40, 69, 118, 111, 108, 118, 101, 100, 41), string.char(71, 114, 105, 109, 109, 106, 111, 119), string.char(82, 101, 110, 106, 105), string.char(66, 121, 97, 107, 117, 121, 97),
string.char(79, 114, 105, 104, 105, 109, 101), string.char(83, 97, 107, 97, 109, 111, 116, 111), string.char(83, 97, 107, 97, 109, 111, 116, 111, 32, 40, 70, 105, 116, 41), string.char(85, 108, 113, 117, 105, 111, 114, 114, 97), string.char(73, 99, 104, 105, 103, 111), string.char(67, 111, 115, 109, 105, 99, 32, 71, 97, 114, 111, 117), string.char(75, 105, 115, 117, 107, 101),
string.char(66, 101, 101, 114, 117, 115), string.char(89, 111, 114, 117, 105, 99, 104, 105), string.char(89, 111, 114, 105, 99, 104, 105), string.char(71, 121, 111, 109, 101, 105), string.char(68, 101, 97, 116, 104, 32, 75, 110, 105, 103, 104, 116), string.char(65, 105, 110, 122), string.char(83, 104, 97, 110, 107, 115), string.char(82, 101, 110, 103, 111, 107, 117),
string.char(90, 101, 110, 105, 116, 115, 117), string.char(77, 97, 115, 104), string.char(65, 108, 98, 101, 100, 111), string.char(83, 104, 97, 108, 108, 116, 101, 97, 114), string.char(69, 110, 116, 111, 109, 97), string.char(83, 112, 105, 100, 101, 114, 32, 40, 69, 110, 116, 111, 109, 97, 41), string.char(77, 101, 103, 117, 109, 105), string.char(84, 111, 106, 105),
string.char(71, 101, 110, 111, 115), string.char(82, 105, 107, 97), string.char(77, 97, 104, 111, 114, 97, 103, 97), string.char(89, 117, 116, 97), string.char(71, 111, 107, 117, 32, 40, 66, 108, 97, 99, 107, 41), string.char(66, 108, 97, 99, 107, 32, 70, 114, 105, 101, 122, 97), string.char(75, 101, 110, 112, 97, 99, 104, 105), string.char(70, 117, 115, 101, 100, 32, 90, 97, 109, 97, 115, 117),
string.char(83, 105, 109, 111, 32, 72, 97, 121, 104, 97), string.char(78, 97, 110, 97, 109, 105), string.char(71, 111, 116, 111), string.char(71, 111, 106, 111, 32, 40, 83, 104, 105, 98, 117, 121, 97, 41), string.char(65, 105, 122, 101, 110, 32, 40, 84, 114, 97, 110, 115, 99, 101, 110, 100, 101, 110, 116, 41), string.char(68, 105, 111), string.char(74, 105, 114, 101, 110),
string.char(76, 101, 108, 111, 117, 99, 104), string.char(83, 97, 105, 116, 97, 109, 97, 32, 40, 83, 101, 114, 105, 111, 117, 115, 41), string.char(83, 117, 107, 117, 110, 97), string.char(89, 97, 109, 97, 109, 111, 116, 111), string.char(66, 114, 105, 116, 97, 105, 110, 32, 65, 114, 109, 121)
}
local SelectedTargets = {}
local AutoSummonEnabled = false
local AutoBuyEnabled = false
local AutoMergeEnabled = false
local DisplayTagEnabled = false
local isBuying = false
local ROLL_SPEED = 0.1
local MERGE_DELAY = 2.0
local latestRollData = nil
local originalDisplayName = LocalPlayer.DisplayName
local RollRemote = nil
local BuyRemote = nil
local function isTargetSelected(nameOrRarity)
if not nameOrRarity then return false end
if SelectedTargets[string.char(65, 108, 108, 32, 82, 97, 114, 105, 116, 105, 101, 115)] or SelectedTargets[string.char(65, 108, 108, 32, 67, 104, 97, 114, 97, 99, 116, 101, 114, 115)] then
return true
end
local target = string.lower(tostring(nameOrRarity))
for selectedName, isSelected in pairs(SelectedTargets) do
if isSelected and string.lower(tostring(selectedName)) == target then
return true
end
end
return false
end
local function checkAndBuyFromData(data)
if not data or not AutoBuyEnabled or isBuying then
return
end
local charactersList = data.charactersList
local rollId = data.rollId
local plot = data.plot
if not charactersList then return end
local matchingSlots = {}
for slotKey, charData in pairs(charactersList) do
if typeof(charData) == string.char(116, 97, 98, 108, 101) then
local rarity = charData.Rarity or charData.rarity
local charName = charData.Name or charData.name or charData.Character
local mutation = charData.Mutation or charData.mutation or charData.Trait or charData.trait
local slotIndex = tonumber(slotKey) or charData.Slot or charData.slot
local matchFound = isTargetSelected(rarity) or isTargetSelected(charName) or isTargetSelected(mutation)
if matchFound then
table.insert(matchingSlots, {
slotIndex = slotIndex or slotKey,
charData = charData
})
end
end
end
if #matchingSlots > 0 then
isBuying = true
task.spawn(function()
for retry = 1, 8 do
for _, item in ipairs(matchingSlots) do
local slotIndex = tonumber(item.slotIndex)
if rollId and slotIndex and BuyRemote then
pcall(function()
BuyRemote:FireServer(rollId, slotIndex)
end)
end
end
if plot then
for _, obj in ipairs(plot:GetDescendants()) do
if obj:IsA(string.char(80, 114, 111, 120, 105, 109, 105, 116, 121, 80, 114, 111, 109, 112, 116)) and obj.Name ~= string.char(82, 111, 108, 108, 80, 114, 111, 109, 112, 116) then
pcall(function()
if fireproximityprompt then
fireproximityprompt(obj, 0)
end
end)
end
end
end
task.wait(0.1)
end
isBuying = false
end)
end
end
local Fluent = loadstring(game:HttpGet(string.char(104, 116, 116, 112, 115, 58, 47, 47, 103, 105, 116, 104, 117, 98, 46, 99, 111, 109, 47, 100, 97, 119, 105, 100, 45, 115, 99, 114, 105, 112, 116, 115, 47, 70, 108, 117, 101, 110, 116, 47, 114, 101, 108, 101, 97, 115, 101, 115, 47, 108, 97, 116, 101, 115, 116, 47, 100, 111, 119, 110, 108, 111, 97, 100, 47, 109, 97, 105, 110, 46, 108, 117, 97)))()
local SaveManager = loadstring(game:HttpGet(string.char(104, 116, 116, 112, 115, 58, 47, 47, 114, 97, 119, 46, 103, 105, 116, 104, 117, 98, 117, 115, 101, 114, 99, 111, 110, 116, 101, 110, 116, 46, 99, 111, 109, 47, 100, 97, 119, 105, 100, 45, 115, 99, 114, 105, 112, 116, 115, 47, 70, 108, 117, 101, 110, 116, 47, 109, 97, 115, 116, 101, 114, 47, 65, 100, 100, 111, 110, 115, 47, 83, 97, 118, 101, 77, 97, 110, 97, 103, 101, 114, 46, 108, 117, 97)))()
local InterfaceManager = loadstring(game:HttpGet(string.char(104, 116, 116, 112, 115, 58, 47, 47, 114, 97, 119, 46, 103, 105, 116, 104, 117, 98, 117, 115, 101, 114, 99, 111, 110, 116, 101, 110, 116, 46, 99, 111, 109, 47, 100, 97, 119, 105, 100, 45, 115, 99, 114, 105, 112, 116, 115, 47, 70, 108, 117, 101, 110, 116, 47, 109, 97, 115, 116, 101, 114, 47, 65, 100, 100, 111, 110, 115, 47, 73, 110, 116, 101, 114, 102, 97, 99, 101, 77, 97, 110, 97, 103, 101, 114, 46, 108, 117, 97)))()
local Window = Fluent:CreateWindow({
Title = string.char(83, 101, 110, 122, 121, 72, 117, 98),
SubTitle = "",
TabWidth = 160,
Size = UDim2.fromOffset(580, 480),
Acrylic = false,
Theme = string.char(68, 97, 114, 107),
MinimizeKey = Enum.KeyCode.LeftControl
})
local Tabs = {
Summon = Window:AddTab({ Title = string.char(83, 117, 109, 109, 111, 110, 32, 38, 32, 66, 117, 121), Icon = string.char(115, 104, 111, 112, 112, 105, 110, 103, 45, 99, 97, 114, 116) }),
Merge = Window:AddTab({ Title = string.char(65, 117, 116, 111, 32, 77, 101, 114, 103, 101), Icon = string.char(115, 112, 97, 114, 107, 108, 101, 115) }),
Visuals = Window:AddTab({ Title = string.char(68, 105, 115, 112, 108, 97, 121, 32, 38, 32, 84, 97, 103, 115), Icon = string.char(117, 115, 101, 114) }),
Settings = Window:AddTab({ Title = string.char(83, 101, 116, 116, 105, 110, 103, 115), Icon = string.char(115, 101, 116, 116, 105, 110, 103, 115) })
}
Tabs.Summon:AddSection(string.char(65, 117, 116, 111, 32, 82, 111, 108, 108, 32, 38, 32, 80, 117, 114, 99, 104, 97, 115, 101))
local AutoSummonToggle = Tabs.Summon:AddToggle(string.char(65, 117, 116, 111, 83, 117, 109, 109, 111, 110, 84, 111, 103, 103, 108, 101), {
Title = string.char(65, 117, 116, 111, 32, 83, 117, 109, 109, 111, 110),
Description = string.char(65, 117, 116, 111, 109, 97, 116, 105, 99, 97, 108, 108, 121, 32, 116, 114, 105, 103, 103, 101, 114, 115, 32, 115, 117, 109, 109, 111, 110, 105, 110, 103, 32, 112, 114, 111, 109, 112, 116, 115),
Default = false
})
AutoSummonToggle:OnChanged(function(Value)
AutoSummonEnabled = Value
getgenv().AutoRollSystem.Enabled = Value
end)
local AutoBuyToggle = Tabs.Summon:AddToggle(string.char(65, 117, 116, 111, 66, 117, 121, 84, 111, 103, 103, 108, 101), {
Title = string.char(65, 117, 116, 111, 32, 66, 117, 121),
Description = string.char(65, 117, 116, 111, 109, 97, 116, 105, 99, 97, 108, 108, 121, 32, 98, 117, 121, 115, 32, 115, 101, 108, 101, 99, 116, 101, 100, 32, 117, 110, 105, 116, 115, 32, 98, 97, 115, 101, 100, 32, 111, 110, 32, 102, 105, 108, 116, 101, 114, 115, 32, 98, 101, 108, 111, 119),
Default = false
})
AutoBuyToggle:OnChanged(function(Value)
AutoBuyEnabled = Value
if Value then
isBuying = false
if latestRollData then
checkAndBuyFromData(latestRollData)
end
end
end)
Tabs.Summon:AddSection(string.char(80, 117, 114, 99, 104, 97, 115, 101, 32, 84, 97, 114, 103, 101, 116, 115))
Tabs.Summon:AddParagraph({
Title = string.char(84, 97, 114, 103, 101, 116, 32, 70, 105, 108, 116, 101, 114, 105, 110, 103, 32, 73, 110, 102, 111),
Content = string.char(83, 101, 108, 101, 99, 116, 105, 110, 103, 32, 39, 65, 108, 108, 32, 82, 97, 114, 105, 116, 105, 101, 115, 39, 32, 111, 114, 32, 39, 65, 108, 108, 32, 67, 104, 97, 114, 97, 99, 116, 101, 114, 115, 39, 32, 119, 105, 108, 108, 32, 97, 117, 116, 111, 109, 97, 116, 105, 99, 97, 108, 108, 121, 32, 112, 117, 114, 99, 104, 97, 115, 101, 32, 97, 108, 108, 32, 114, 111, 108, 108, 101, 100, 32, 117, 110, 105, 116, 115, 32, 119, 105, 116, 104, 105, 110, 32, 116, 104, 97, 116, 32, 99, 97, 116, 101, 103, 111, 114, 121, 32, 114, 101, 103, 97, 114, 100, 108, 101, 115, 115, 32, 111, 102, 32, 105, 110, 100, 105, 118, 105, 100, 117, 97, 108, 32, 99, 104, 111, 105, 99, 101, 115, 46)
})
local RarityDropdown = Tabs.Summon:AddDropdown(string.char(82, 97, 114, 105, 116, 121, 68, 114, 111, 112, 100, 111, 119, 110), {
Title = string.char(83, 101, 108, 101, 99, 116, 32, 84, 97, 114, 103, 101, 116, 32, 82, 97, 114, 105, 116, 105, 101, 115),
Description = string.char(83, 101, 108, 101, 99, 116, 105, 110, 103, 32, 97, 32, 114, 97, 114, 105, 116, 121, 32, 119, 105, 108, 108, 32, 112, 117, 114, 99, 104, 97, 115, 101, 32, 65, 76, 76, 32, 117, 110, 105, 116, 115, 32, 98, 101, 108, 111, 110, 103, 105, 110, 103, 32, 116, 111, 32, 116, 104, 97, 116, 32, 116, 105, 101, 114, 46),
Values = RarityList,
Multi = true,
Default = {}
})
RarityDropdown:OnChanged(function(Value)
for _, r in ipairs(RarityList) do
SelectedTargets[r] = false
end
if type(Value) == string.char(116, 97, 98, 108, 101) then
for k, v in pairs(Value) do
if type(k) == string.char(115, 116, 114, 105, 110, 103) and v == true then
SelectedTargets[k] = true
elseif type(v) == string.char(115, 116, 114, 105, 110, 103) then
SelectedTargets[v] = true
end
end
end
if AutoBuyEnabled then
isBuying = false
if latestRollData then
checkAndBuyFromData(latestRollData)
end
end
end)
local CharacterDropdown = Tabs.Summon:AddDropdown(string.char(67, 104, 97, 114, 97, 99, 116, 101, 114, 68, 114, 111, 112, 100, 111, 119, 110), {
Title = string.char(83, 101, 108, 101, 99, 116, 32, 84, 97, 114, 103, 101, 116, 32, 67, 104, 97, 114, 97, 99, 116, 101, 114, 115),
Description = string.char(83, 101, 108, 101, 99, 116, 32, 115, 112, 101, 99, 105, 102, 105, 99, 32, 117, 110, 105, 116, 32, 110, 97, 109, 101, 115, 32, 116, 111, 32, 97, 117, 116, 111, 45, 98, 117, 121, 32, 119, 104, 101, 110, 32, 115, 117, 109, 109, 111, 110, 101, 100, 46),
Values = CharacterList,
Multi = true,
Default = {}
})
CharacterDropdown:OnChanged(function(Value)
for _, c in ipairs(CharacterList) do
SelectedTargets[c] = false
end
if type(Value) == string.char(116, 97, 98, 108, 101) then
for k, v in pairs(Value) do
if type(k) == string.char(115, 116, 114, 105, 110, 103) and v == true then
SelectedTargets[k] = true
elseif type(v) == string.char(115, 116, 114, 105, 110, 103) then
SelectedTargets[v] = true
end
end
end
if AutoBuyEnabled then
isBuying = false
if latestRollData then
checkAndBuyFromData(latestRollData)
end
end
end)
local SpeedSlider = Tabs.Summon:AddSlider(string.char(82, 111, 108, 108, 83, 112, 101, 101, 100, 83, 108, 105, 100, 101, 114), {
Title = string.char(83, 117, 109, 109, 111, 110, 32, 83, 112, 101, 101, 100, 32, 68, 101, 108, 97, 121),
Description = string.char(68, 101, 108, 97, 121, 32, 105, 110, 116, 101, 114, 118, 97, 108, 32, 98, 101, 116, 119, 101, 101, 110, 32, 115, 117, 109, 109, 111, 110, 32, 116, 114, 105, 103, 103, 101, 114, 115, 32, 40, 115, 101, 99, 111, 110, 100, 115, 41),
Default = 0.1,
Min = 0.05,
Max = 1.0,
Rounding = 2
})
SpeedSlider:OnChanged(function(Value)
ROLL_SPEED = Value
end)
Tabs.Merge:AddSection(string.char(80, 114, 111, 120, 105, 109, 105, 116, 121, 32, 77, 101, 114, 103, 101, 32, 83, 121, 115, 116, 101, 109))
local AutoMergeToggle = Tabs.Merge:AddToggle(string.char(65, 117, 116, 111, 77, 101, 114, 103, 101, 84, 111, 103, 103, 108, 101), {
Title = string.char(65, 117, 116, 111, 32, 77, 101, 114, 103, 101, 32, 40, 76, 101, 118, 101, 108, 32, 85, 112, 41),
Description = string.char(65, 117, 116, 111, 109, 97, 116, 105, 99, 97, 108, 108, 121, 32, 116, 114, 105, 103, 103, 101, 114, 115, 32, 76, 101, 118, 101, 108, 32, 85, 112, 32, 112, 114, 111, 109, 112, 116, 115, 32, 97, 99, 114, 111, 115, 115, 32, 97, 108, 108, 32, 97, 118, 97, 105, 108, 97, 98, 108, 101, 32, 99, 104, 97, 114, 97, 99, 116, 101, 114, 32, 115, 108, 111, 116, 115),
Default = false
})
AutoMergeToggle:OnChanged(function(Value)
AutoMergeEnabled = Value
end)
local DelaySlider = Tabs.Merge:AddSlider(string.char(77, 101, 114, 103, 101, 68, 101, 108, 97, 121, 83, 108, 105, 100, 101, 114), {
Title = string.char(77, 101, 114, 103, 101, 32, 83, 112, 101, 101, 100, 32, 68, 101, 108, 97, 121),
Description = string.char(73, 110, 116, 101, 114, 118, 97, 108, 32, 100, 101, 108, 97, 121, 32, 98, 101, 116, 119, 101, 101, 110, 32, 109, 101, 114, 103, 101, 32, 97, 116, 116, 101, 109, 112, 116, 115, 32, 40, 115, 101, 99, 111, 110, 100, 115, 41),
Default = 2.0,
Min = 0.1,
Max = 5.0,
Rounding = 1
})
DelaySlider:OnChanged(function(Value)
MERGE_DELAY = Value
end)
Tabs.Visuals:AddSection(string.char(78, 97, 109, 101, 32, 84, 97, 103, 32, 67, 117, 115, 116, 111, 109, 105, 122, 97, 116, 105, 111, 110))
local DisplayTagToggle = Tabs.Visuals:AddToggle(string.char(68, 105, 115, 112, 108, 97, 121, 84, 97, 103, 84, 111, 103, 103, 108, 101), {
Title = string.char(69, 110, 97, 98, 108, 101, 32, 67, 117, 115, 116, 111, 109, 32, 78, 97, 109, 101, 32, 84, 97, 103),
Description = string.char(79, 118, 101, 114, 114, 105, 100, 101, 115, 32, 111, 118, 101, 114, 104, 101, 97, 100, 32, 100, 105, 115, 112, 108, 97, 121, 32, 116, 101, 120, 116, 32, 116, 111, 32, 39, 83, 69, 78, 90, 89, 32, 72, 85, 66, 32, 79, 78, 32, 84, 79, 80, 39),
Default = false
})
local function UpdateOverheadDisplay(character)
if not character then return end
task.spawn(function()
local humanoid = character:WaitForChild(string.char(72, 117, 109, 97, 110, 111, 105, 100), 5)
if humanoid then
humanoid.DisplayName = DisplayTagEnabled and string.char(83, 69, 78, 90, 89, 32, 72, 85, 66, 32, 79, 78, 32, 84, 79, 80) or originalDisplayName
end
for _, obj in ipairs(character:GetDescendants()) do
if obj:IsA(string.char(84, 101, 120, 116, 76, 97, 98, 101, 108)) and obj.Name ~= string.char(84, 105, 116, 108, 101) then
if DisplayTagEnabled then
obj.Text = string.char(83, 69, 78, 90, 89, 32, 72, 85, 66, 32, 79, 78, 32, 84, 79, 80)
end
end
end
end)
end
DisplayTagToggle:OnChanged(function(Value)
DisplayTagEnabled = Value
if LocalPlayer.Character then
UpdateOverheadDisplay(LocalPlayer.Character)
end
end)
LocalPlayer.CharacterAdded:Connect(function(character)
if DisplayTagEnabled then
UpdateOverheadDisplay(character)
end
end)
task.spawn(function()
pcall(function()
local RS = ReplicatedStorage
local Remotes = RS:WaitForChild(string.char(82, 101, 109, 111, 116, 101, 115), 10)
if Remotes then
local CharactersRemotes = Remotes:WaitForChild(string.char(67, 104, 97, 114, 97, 99, 116, 101, 114, 115), 10)
if CharactersRemotes then
RollRemote = CharactersRemotes:WaitForChild(string.char(82, 111, 108, 108), 10)
BuyRemote = CharactersRemotes:WaitForChild(string.char(66, 117, 121), 10)
end
end
end)
if RollRemote then
getgenv().AutoRollSystem.Connection = RollRemote.OnClientEvent:Connect(function(...)
local args = {...}
local charactersList, rollId, plot
for _, arg in ipairs(args) do
if typeof(arg) == string.char(116, 97, 98, 108, 101) then charactersList = arg
elseif typeof(arg) == string.char(110, 117, 109, 98, 101, 114) then rollId = arg
elseif typeof(arg) == string.char(73, 110, 115, 116, 97, 110, 99, 101) then plot = arg end
end
if not charactersList then return end
latestRollData = {charactersList = charactersList, rollId = rollId, plot = plot}
if AutoBuyEnabled then
checkAndBuyFromData(latestRollData)
end
end)
end
end)
task.spawn(function()
while true do
if AutoSummonEnabled and not isBuying then
pcall(function()
for _, obj in ipairs(workspace:GetDescendants()) do
if obj:IsA(string.char(80, 114, 111, 120, 105, 109, 105, 116, 121, 80, 114, 111, 109, 112, 116)) and obj.Name == string.char(82, 111, 108, 108, 80, 114, 111, 109, 112, 116) then
if fireproximityprompt then
fireproximityprompt(obj, 0)
end
end
end
end)
end
task.wait(ROLL_SPEED)
end
end)
local function TriggerMergePrompts()
for _, prompt in ipairs(workspace:GetDescendants()) do
if prompt:IsA(string.char(80, 114, 111, 120, 105, 109, 105, 116, 121, 80, 114, 111, 109, 112, 116)) then
local objectText = tostring(prompt.ObjectText):lower()
local actionText = tostring(prompt.ActionText):lower()
local promptName = tostring(prompt.Name):lower()
local isLevelUpPrompt = actionText:find(string.char(108, 101, 118, 101, 108, 32, 117, 112))
or objectText:find(string.char(99, 104, 97, 114, 97, 99, 116, 101, 114, 32, 115, 108, 111, 116))
or promptName:find(string.char(108, 101, 118, 101, 108, 117, 112))
if isLevelUpPrompt then
pcall(function()
if fireproximityprompt then
fireproximityprompt(prompt, 0)
end
end)
end
end
end
end
task.spawn(function()
while true do
if AutoMergeEnabled then
pcall(TriggerMergePrompts)
end
task.wait(MERGE_DELAY)
end
end)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder(string.char(83, 101, 110, 122, 121, 72, 117, 98))
SaveManager:SetFolder(string.char(83, 101, 110, 122, 121, 72, 117, 98, 47, 99, 111, 110, 102, 105, 103, 115))
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
