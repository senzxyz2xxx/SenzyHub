-- Senzy Hub | Full Version
-- Execute via Xeno

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player.PlayerGui
local RF = game.ReplicatedStorage.Systems

if playerGui:FindFirstChild("SenzyHub") then playerGui.SenzyHub:Destroy() end

local states = {}
local minimized = false

local sg = Instance.new("ScreenGui", playerGui)
sg.Name = "SenzyHub"
sg.ResetOnSpawn = false
sg.DisplayOrder = 999

local win = Instance.new("Frame", sg)
win.Size = UDim2.new(0, 300, 0, 480)
win.Position = UDim2.new(0.5, -150, 0.5, -240)
win.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
win.BorderSizePixel = 0
win.Active = true
win.Draggable = true
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 12)

local winStroke = Instance.new("UIStroke", win)
winStroke.Color = Color3.fromRGB(70, 70, 78)
winStroke.Thickness = 1

local titlebar = Instance.new("Frame", win)
titlebar.Size = UDim2.new(1, 0, 0, 40)
titlebar.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
titlebar.BorderSizePixel = 0
Instance.new("UICorner", titlebar).CornerRadius = UDim.new(0, 12)

local tbFix = Instance.new("Frame", titlebar)
tbFix.Size = UDim2.new(1, 0, 0.5, 0)
tbFix.Position = UDim2.new(0, 0, 0.5, 0)
tbFix.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
tbFix.BorderSizePixel = 0

local function makeLight(color, xPos)
    local f = Instance.new("Frame", titlebar)
    f.Size = UDim2.new(0, 12, 0, 12)
    f.Position = UDim2.new(0, xPos, 0.5, -6)
    f.BackgroundColor3 = color
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
    return f
end

local redLight    = makeLight(Color3.fromRGB(255, 95, 86),  12)
local yellowLight = makeLight(Color3.fromRGB(255, 189, 46), 28)
local greenLight  = makeLight(Color3.fromRGB(39, 201, 63),  44)

local closeHit = Instance.new("TextButton", redLight)
closeHit.Size = UDim2.new(1,0,1,0)
closeHit.BackgroundTransparency = 1
closeHit.Text = ""
closeHit.MouseButton1Click:Connect(function()
    for k in pairs(states) do states[k] = false end
    sg:Destroy()
end)

local minHit = Instance.new("TextButton", yellowLight)
minHit.Size = UDim2.new(1,0,1,0)
minHit.BackgroundTransparency = 1
minHit.Text = ""
minHit.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(win, TweenInfo.new(0.2), {
        Size = minimized and UDim2.new(0,300,0,40) or UDim2.new(0,300,0,480)
    }):Play()
end)

local titleTxt = Instance.new("TextLabel", titlebar)
titleTxt.Size = UDim2.new(1,0,1,0)
titleTxt.BackgroundTransparency = 1
titleTxt.Text = "Senzy Hub"
titleTxt.TextColor3 = Color3.fromRGB(220,220,220)
titleTxt.TextSize = 13
titleTxt.Font = Enum.Font.GothamBold
titleTxt.TextXAlignment = Enum.TextXAlignment.Center

local sep = Instance.new("Frame", win)
sep.Size = UDim2.new(1,0,0,1)
sep.Position = UDim2.new(0,0,0,40)
sep.BackgroundColor3 = Color3.fromRGB(60,60,68)
sep.BorderSizePixel = 0

local tabBar = Instance.new("Frame", win)
tabBar.Size = UDim2.new(1,0,0,36)
tabBar.Position = UDim2.new(0,0,0,41)
tabBar.BackgroundColor3 = Color3.fromRGB(32,32,36)
tabBar.BorderSizePixel = 0

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local sep2 = Instance.new("Frame", win)
sep2.Size = UDim2.new(1,0,0,1)
sep2.Position = UDim2.new(0,0,0,77)
sep2.BackgroundColor3 = Color3.fromRGB(60,60,68)
sep2.BorderSizePixel = 0

local content = Instance.new("Frame", win)
content.Size = UDim2.new(1,0,1,-78)
content.Position = UDim2.new(0,0,0,78)
content.BackgroundTransparency = 1
content.ClipsDescendants = true

-- ======== Tab System ========
local tabs = {}

local function makeTab(name, icon, order)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0.25,0,1,0)
    btn.BackgroundColor3 = Color3.fromRGB(32,32,36)
    btn.BorderSizePixel = 0
    btn.Text = icon.."\n"..name
    btn.TextColor3 = Color3.fromRGB(120,120,130)
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    btn.LayoutOrder = order

    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0.6,0,0,2)
    indicator.Position = UDim2.new(0.2,0,1,-2)
    indicator.BackgroundColor3 = Color3.fromRGB(110,60,255)
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 1
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1,0)

    local page = Instance.new("ScrollingFrame", content)
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(110,60,255)
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false

    local pl = Instance.new("UIListLayout", page)
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Padding = UDim.new(0,5)

    local pp = Instance.new("UIPadding", page)
    pp.PaddingLeft = UDim.new(0,12)
    pp.PaddingRight = UDim.new(0,12)
    pp.PaddingTop = UDim.new(0,8)
    pp.PaddingBottom = UDim.new(0,10)

    tabs[name] = {btn=btn, page=page, indicator=indicator}

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.page.Visible = false
            t.btn.TextColor3 = Color3.fromRGB(120,120,130)
            t.btn.BackgroundColor3 = Color3.fromRGB(32,32,36)
            t.indicator.BackgroundTransparency = 1
        end
        page.Visible = true
        btn.TextColor3 = Color3.fromRGB(220,220,230)
        btn.BackgroundColor3 = Color3.fromRGB(40,38,50)
        indicator.BackgroundTransparency = 0
    end)

    return page
end

local rewardsPage = makeTab("Rewards", "★", 1)
local chestsPage  = makeTab("Chests",  "□", 2)
local farmPage    = makeTab("Farm",    "⚡", 3)
local playerPage  = makeTab("Player",  "◈", 4)

tabs["Rewards"].page.Visible = true
tabs["Rewards"].btn.TextColor3 = Color3.fromRGB(220,220,230)
tabs["Rewards"].btn.BackgroundColor3 = Color3.fromRGB(40,38,50)
tabs["Rewards"].indicator.BackgroundTransparency = 0

-- ======== Helpers ========
local function makeCard(page, order)
    local card = Instance.new("Frame", page)
    card.Size = UDim2.new(1,0,0,54)
    card.BackgroundColor3 = Color3.fromRGB(40,40,46)
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,8)
    local cs = Instance.new("UIStroke", card)
    cs.Color = Color3.fromRGB(60,60,68)
    cs.Thickness = 1
    return card, cs
end

local function addLabels(card, label, sub)
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0.62,0,0,18)
    lbl.Position = UDim2.new(0,12,0,9)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(220,218,228)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local s = Instance.new("TextLabel", card)
    s.Size = UDim2.new(0.62,0,0,14)
    s.Position = UDim2.new(0,12,0,30)
    s.BackgroundTransparency = 1
    s.Text = sub
    s.TextColor3 = Color3.fromRGB(140,136,158)
    s.TextSize = 10
    s.Font = Enum.Font.Gotham
    s.TextXAlignment = Enum.TextXAlignment.Left
end

local function makeToggle(page, labelText, subText, order, onEnable, onDisable)
    local card, cs = makeCard(page, order)
    addLabels(card, labelText, subText)

    local sw = Instance.new("Frame", card)
    sw.Size = UDim2.new(0,36,0,20)
    sw.Position = UDim2.new(1,-48,0.5,-10)
    sw.BackgroundColor3 = Color3.fromRGB(55,52,68)
    sw.BorderSizePixel = 0
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1,0)

    local thumb = Instance.new("Frame", sw)
    thumb.Size = UDim2.new(0,14,0,14)
    thumb.Position = UDim2.new(0,3,0.5,-7)
    thumb.BackgroundColor3 = Color3.fromRGB(140,136,158)
    thumb.BorderSizePixel = 0
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1,0)

    states[labelText] = false

    local hitbox = Instance.new("TextButton", card)
    hitbox.Size = UDim2.new(1,0,1,0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""

    hitbox.MouseButton1Click:Connect(function()
        states[labelText] = not states[labelText]
        local on = states[labelText]
        TweenService:Create(sw, TweenInfo.new(0.15), {
            BackgroundColor3 = on and Color3.fromRGB(100,50,240) or Color3.fromRGB(55,52,68)
        }):Play()
        TweenService:Create(thumb, TweenInfo.new(0.15), {
            Position = on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
            BackgroundColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,136,158)
        }):Play()
        TweenService:Create(cs, TweenInfo.new(0.15), {
            Color = on and Color3.fromRGB(100,50,240) or Color3.fromRGB(60,60,68)
        }):Play()
        if on then task.spawn(onEnable)
        elseif onDisable then onDisable() end
    end)
end

local function makeButton(page, labelText, subText, order, onClick)
    local card, cs = makeCard(page, order)
    addLabels(card, labelText, subText)

    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.new(0,52,0,26)
    btn.Position = UDim2.new(1,-62,0.5,-13)
    btn.BackgroundColor3 = Color3.fromRGB(100,50,240)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = "run"
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        if btn.Text == "..." then return end
        btn.Text = "..."
        btn.BackgroundColor3 = Color3.fromRGB(55,50,80)
        task.spawn(function()
            local ok = pcall(onClick)
            btn.Text = ok and "✓" or "✕"
            btn.BackgroundColor3 = ok and Color3.fromRGB(40,175,90) or Color3.fromRGB(200,50,60)
            task.wait(1.5)
            btn.Text = "run"
            btn.BackgroundColor3 = Color3.fromRGB(100,50,240)
        end)
    end)
end

-- ======== REWARDS TAB ========
makeButton(rewardsPage, "Claim UnitDex", "claim gem จากทุก unit", 1, function()
    local Items = require(game.ReplicatedStorage.Systems.Items)
    local unitData = Items:GetCategoryData("Units")
    local dexRF = RF.UnitDex.ClaimUnitReward
    for unitName in pairs(unitData) do
        pcall(function() dexRF:InvokeServer(unitName) end)
        task.wait(0.1)
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextButton") and (gui.Text == "Claim!" or gui.Text == "Claim") then
                pcall(function() gui.MouseButton1Click:Fire() end)
            end
        end
        task.wait(0.15)
    end
end)

-- ======== CHESTS TAB ========
makeToggle(chestsPage, "Auto Collect", "วาร์ปเก็บ chest อัตโนมัติ", 1, function()
    while states["Auto Collect"] do
        local ok, bonusChests = pcall(function() return workspace.Map.BonusChests end)
        if not ok or not bonusChests then task.wait(3) continue end
        local parts = {}
        for _, c in ipairs(bonusChests:GetChildren()) do
            if c:IsA("BasePart") then table.insert(parts, c) end
        end
        if #parts == 0 then
            task.wait(5)
        else
            for _, part in ipairs(parts) do
                if not states["Auto Collect"] then break end
                if not part or not part.Parent then continue end
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then break end
                root.CFrame = part.CFrame + Vector3.new(0,3,0)
                task.wait(0.6)
                pcall(function()
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    for _, obj in ipairs(part:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then pcall(fireproximityprompt, obj) end
                    end
                    task.wait(0.5)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end)
                local retry = 0
                while part and part.Parent and retry < 4 do
                    task.wait(0.3)
                    retry += 1
                end
                task.wait(0.4)
            end
        end
    end
end)

-- ======== FARM TAB ========
makeToggle(farmPage, "Auto Claim Quest", "claim quest วนอัตโนมัติ", 1, function()
    while states["Auto Claim Quest"] do
        -- วนหา quest id 1-20 ที่ claim ได้
        for i = 1, 20 do
            if not states["Auto Claim Quest"] then break end
            pcall(function() RF.Quests.ClaimQuest:InvokeServer(i) end)
            task.wait(0.3)
        end
        task.wait(5)
    end
end)

makeToggle(farmPage, "Auto Wave", "sweep wave อัตโนมัติ", 2, function()
    while states["Auto Wave"] do
        pcall(function() RF.Sweeps.SweepWave:InvokeServer() end)
        task.wait(3)
    end
end)

makeToggle(farmPage, "Auto Queue", "เข้า queue อัตโนมัติ", 3, function()
    while states["Auto Queue"] do
        pcall(function() RF.Queue.RequestEnterQueue:InvokeServer() end)
        task.wait(5)
    end
end)

makeToggle(farmPage, "Auto Vote Next", "โหวต next หลังจบด่าน", 4, function()
    local voteRE = game.ReplicatedStorage.Systems.Voting.Vote
    while states["Auto Vote Next"] do
        if game.ReplicatedStorage:GetAttribute("RoundEndTimer") ~= nil then
            pcall(function() voteRE:FireServer("Next") end)
            task.wait(18)
        end
        task.wait(1)
    end
end)

makeToggle(farmPage, "Auto Vote Retry", "โหวต retry หลังจบด่าน", 5, function()
    local voteRE = game.ReplicatedStorage.Systems.Voting.Vote
    while states["Auto Vote Retry"] do
        if game.ReplicatedStorage:GetAttribute("RoundEndTimer") ~= nil then
            pcall(function() voteRE:FireServer("Retry") end)
            task.wait(18)
        end
        task.wait(1)
    end
end)

-- ======== PLAYER TAB ========
makeToggle(playerPage, "Speed Hack", "walkspeed x3", 1, function()
    while states["Speed Hack"] do
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 48 end
        task.wait(0.5)
    end
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = 16 end
end)

makeToggle(playerPage, "Infinite Jump", "กระโดดได้ไม่จำกัด", 2, function()
    local conn
    conn = UserInputService.JumpRequest:Connect(function()
        if not states["Infinite Jump"] then conn:Disconnect() return end
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
    while states["Infinite Jump"] do task.wait(1) end
    conn:Disconnect()
end)

print("senzy hub loaded ✅")
