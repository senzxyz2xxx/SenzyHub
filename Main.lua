local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SenzyHub",
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Purple",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main Farm", Icon = "sword" }),
    Misc = Window:AddTab({ Title = "Misc / Safety", Icon = "user-check" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local isAutoFarm = false
local isAutoQuest = false
local isAutoChest = false
local isNameSpoof = false
local fakeName = "@Senzy On Top"
local selectedNpcName = "Thief 1 [Lv. 1]"

local realUsername = LocalPlayer.Name
local realDisplayName = LocalPlayer.DisplayName

local hiddenTextLabels = {}
local fakeNameGui = nil

local function getRemotes()
    local events = ReplicatedStorage:FindFirstChild("Events")
    local questFunc = ReplicatedStorage:FindFirstChild("QuestFunction") or (events and events:FindFirstChild("QuestFunction"))
    return questFunc
end

local function getFarmTarget()
    if not selectedNpcName or selectedNpcName == "" then return nil end
    local cleanName = selectedNpcName:split(" [")[1]
    
    local searchPaths = {
        Workspace:FindFirstChild("NPC Zones"),
        Workspace:FindFirstChild("NPCs"),
        Workspace:FindFirstChild("Enemies"),
        Workspace
    }

    for _, path in ipairs(searchPaths) do
        if path then
            for _, v in ipairs(path:GetDescendants()) do
                if v:IsA("Model") and v.Name:find(cleanName) then
                    local hum = v:FindFirstChildOfClass("Humanoid")
                    local root = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso") or v.PrimaryPart
                    if hum and hum.Health > 0 and root then
                        return v, root
                    end
                end
            end
        end
    end
    return nil
end

local function getChests()
    local foundChests = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        local name = v.Name:lower()
        if (name:find("chest") or name:find("treasure")) and not name:find("aura") then
            if v:IsA("Model") or v:IsA("BasePart") then
                table.insert(foundChests, v)
            end
        end
    end
    return foundChests
end

-- ซ่อนชื่อเดิม + แสดงชื่อปลอม
local function hideOriginalNameTags()
    local character = LocalPlayer.Character
    if not character then return end

    -- ซ่อน TextLabel ที่มีชื่อจริงทั้งหมดในตัวละคร
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Name ~= "SenzyFakeLabel" then
            if obj.Text:find(realUsername) or obj.Text:find(realDisplayName) then
                if not hiddenTextLabels[obj] then
                    hiddenTextLabels[obj] = obj.TextTransparency
                end
                obj.TextTransparency = 1
                if obj:FindFirstChildOfClass("UIStroke") then
                    obj:FindFirstChildOfClass("UIStroke").Enabled = false
                end
            end
        end
    end
end

local function restoreOriginalNameTags()
    -- เอาป้ายชื่อปลอมออก
    if fakeNameGui then
        fakeNameGui:Destroy()
        fakeNameGui = nil
    end

    -- คืนค่าความโปร่งแสงให้ป้ายชื่อเดิม
    for label, origTrans in pairs(hiddenTextLabels) do
        if label and label.Parent then
            pcall(function()
                label.TextTransparency = origTrans
                if label:FindFirstChildOfClass("UIStroke") then
                    label:FindFirstChildOfClass("UIStroke").Enabled = true
                end
            end)
        end
    end
    table.clear(hiddenTextLabels)
end

local function applyCustomNameTag()
    local character = LocalPlayer.Character
    if not character then return end
    
    local head = character:FindFirstChild("Head")
    if not head then return end

    hideOriginalNameTags()

    if not fakeNameGui or fakeNameGui.Parent ~= head then
        if fakeNameGui then fakeNameGui:Destroy() end

        local bb = Instance.new("BillboardGui")
        bb.Name = "SenzyFakeNameTag"
        bb.Adornee = head
        bb.Size = UDim2.new(0, 300, 0, 70)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.AlwaysOnTop = true

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "SenzyFakeLabel"
        textLabel.Parent = bb
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = fakeName
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextStrokeTransparency = 0
        textLabel.Font = Enum.Font.FredokaOne
        textLabel.TextSize = 36

        bb.Parent = head
        fakeNameGui = bb
    end
end

Tabs.Main:AddSection("Auto Farm")

local NpcDropdown = Tabs.Main:AddDropdown("NpcSelect", {
    Title = "Select Target NPC",
    Values = {"Thief 1 [Lv. 1]", "Thief 2 [Lv. 5]", "Thief 3 [Lv. 10]", "Thief 4 [Lv. 15]", "Thief 5 [Lv. 20]"},
    Default = "Thief 1 [Lv. 1]",
})

NpcDropdown:OnChanged(function(Value)
    selectedNpcName = Value
end)

local FarmToggle = Tabs.Main:AddToggle("AutoFarmToggle", { Title = "Auto Farm NPC", Default = false })
FarmToggle:OnChanged(function(Value)
    isAutoFarm = Value
end)

local QuestToggle = Tabs.Main:AddToggle("AutoQuestToggle", { Title = "Auto Accept Quest", Default = false })
QuestToggle:OnChanged(function(Value)
    isAutoQuest = Value
end)

Tabs.Main:AddSection("Auto Chest")

local ChestToggle = Tabs.Main:AddToggle("AutoChestToggle", { Title = "Auto Chests (Instant Warp)", Default = false })
ChestToggle:OnChanged(function(Value)
    isAutoChest = Value
end)

Tabs.Misc:AddSection("Safety Tools")

local NameSpoofToggle = Tabs.Misc:AddToggle("NameSpoofToggle", { Title = "Name Spoofer (Senzy On Top)", Default = false })
NameSpoofToggle:OnChanged(function(Value)
    isNameSpoof = Value
    if not Value then
        restoreOriginalNameTags()
    end
end)

-- Loop: Custom Name Tag & Hide Original
task.spawn(function()
    while true do
        task.wait(0.5)
        if isNameSpoof then
            applyCustomNameTag()
        else
            restoreOriginalNameTags()
        end
    end
end)

-- Loop 1: Auto Farm
task.spawn(function()
    while true do
        task.wait()
        if isAutoFarm then
            local targetNpc, targetRoot = getFarmTarget()
            local character = LocalPlayer.Character
            
            if targetNpc and targetRoot and character then
                local myRoot = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if myRoot and humanoid then
                    myRoot.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 6.5, 0))
                    
                    if not myRoot:FindFirstChild("FarmBV") then
                        local bv = Instance.new("BodyVelocity")
                        bv.Name = "FarmBV"
                        bv.Velocity = Vector3.new(0, 0, 0)
                        bv.MaxForce = Vector3.new(0, math.huge, 0)
                        bv.Parent = myRoot
                    end

                    local weapon = character:FindFirstChildOfClass("Tool")
                    if not weapon then
                        local backpackTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                        if backpackTool then
                            humanoid:EquipTool(backpackTool)
                            weapon = backpackTool
                        end
                    end

                    if weapon then
                        weapon:Activate()
                        local swordServer = weapon:FindFirstChild("SwordServer")
                        if swordServer and swordServer:FindFirstChild("UpdateMousePosition") then
                            pcall(function()
                                swordServer.UpdateMousePosition:FireServer(targetRoot.Position)
                            end)
                        end
                    end
                end
            end
        else
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local bv = character.HumanoidRootPart:FindFirstChild("FarmBV")
                if bv then bv:Destroy() end
            end
        end
    end
end)

-- Loop 2: Auto Quest
task.spawn(function()
    while true do
        task.wait(2)
        if isAutoQuest then
            local questFunc = getRemotes()
            if questFunc then
                pcall(function()
                    questFunc:InvokeServer("Level 10")
                end)
            end
        end
    end
end)

-- Loop 3: Auto Chest (Instant Teleport + 0.3s)
task.spawn(function()
    while true do
        task.wait(0.3)
        if isAutoChest then
            local chests = getChests()
            for _, chest in ipairs(chests) do
                if not isAutoChest then break end
                
                local character = LocalPlayer.Character
                if character then
                    local myRoot = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
                    if myRoot and chest and chest.Parent then
                        local targetPart = nil
                        if chest:IsA("BasePart") then
                            targetPart = chest
                        elseif chest:IsA("Model") then
                            targetPart = chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart")
                        end
                        
                        if targetPart then
                            myRoot.CFrame = targetPart.CFrame + Vector3.new(0, 2, 0)
                            
                            pcall(function()
                                if firetouchinterest then
                                    firetouchinterest(myRoot, targetPart, 0)
                                    task.wait(0.05)
                                    firetouchinterest(myRoot, targetPart, 1)
                                end
                                
                                local prompt = chest:FindFirstChildOfClass("ProximityPrompt") or targetPart:FindFirstChildOfClass("ProximityPrompt")
                                if prompt and fireproximityprompt then
                                    fireproximityprompt(prompt)
                                end
                            end)

                            task.wait(0.3)
                        end
                    end
                end
            end
        end
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("SenzyHub")
SaveManager:SetFolder("SenzyHub/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
