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

-- ======== GUI ========
local sg = Instance.new("ScreenGui", playerGui)
sg.Name = "SenzyHub"
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 280, 0, 540)
main.Position = UDim2.new(0, 20, 0.5, -270)
main.BackgroundColor3 = Color3.fromRGB(8, 8, 16)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

-- glow border
local glow = Instance.new("UIStroke", main)
glow.Color = Color3.fromRGB(110, 60, 255)
glow.Transparency = 0.4
glow.Thickness = 1.5

-- top color bar
local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 3)
topBar.BackgroundColor3 = Color3.fromRGB(110, 60, 255)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(1, 0)

-- header bg
local headerBg = Instance.new("Frame", main)
headerBg.Size = UDim2.new(1, 0, 0, 58)
headerBg.Position = UDim2.new(0, 0, 0, 0)
headerBg.BackgroundColor3 = Color3.fromRGB(14, 10, 28)
headerBg.BorderSizePixel = 0

local headerFix = Instance.new("Frame", headerBg)
headerFix.Size = UDim2.new(1, 0, 0.5, 0)
headerFix.Position = UDim2.new(0, 0, 0.5, 0)
headerFix.BackgroundColor3 = Color3.fromRGB(14, 10, 28)
headerFix.BorderSizePixel = 0

-- logo circle
local logoBg = Instance.new("Frame", headerBg)
logoBg.Size = UDim2.new(0, 34, 0, 34)
logoBg.Position = UDim2.new(0, 14, 0.5, -17)
logoBg.BackgroundColor3 = Color3.fromRGB(110, 60, 255)
logoBg.BorderSizePixel = 0
Instance.new("UICorner", logoBg).CornerRadius = UDim.new(0, 10)

local logoTxt = Instance.new("TextLabel", logoBg)
logoTxt.Size = UDim2.new(1, 0, 1, 0)
logoTxt.BackgroundTransparency = 1
logoTxt.Text = "S"
logoTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
logoTxt.TextSize = 16
logoTxt.Font = Enum.Font.GothamBold
logoTxt.TextXAlignment = Enum.TextXAlignment.Center

local titleTxt = Instance.new("TextLabel", headerBg)
titleTxt.Size = UDim2.new(0, 130, 0, 20)
titleTxt.Position = UDim2.new(0, 56, 0, 10)
titleTxt.BackgroundTransparency = 1
titleTxt.Text = "Senzy Hub"
titleTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
titleTxt.TextSize = 15
titleTxt.Font = Enum.Font.GothamBold
titleTxt.TextXAlignment = Enum.TextXAlignment.Left

local subTxt = Instance.new("TextLabel", headerBg)
subTxt.Size = UDim2.new(0, 130, 0, 14)
subTxt.Position = UDim2.new(0, 56, 0, 32)
subTxt.BackgroundTransparency = 1
subTxt.Text = "full version  •  undetected"
subTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
subTxt.TextTransparency = 0.6
subTxt.TextSize = 10
subTxt.Font = Enum.Font.Gotham
subTxt.TextXAlignment = Enum.TextXAlignment.Left

-- status dot
local dotFrame = Instance.new("Frame", headerBg)
dotFrame.Size = UDim2.new(0, 6, 0, 6)
dotFrame.Position = UDim2.new(1, -40, 0.5, -3)
dotFrame.BackgroundColor3 = Color3.fromRGB(60, 220, 120)
dotFrame.BorderSizePixel = 0
Instance.new("UICorner", dotFrame).CornerRadius = UDim.new(1, 0)

-- close btn
local closeBtn = Instance.new("TextButton", headerBg)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 80)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "✕"
closeBtn.TextSize = 10
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
closeBtn.MouseButton1Click:Connect(function()
    for k in pairs(states) do states[k] = false end
    sg:Destroy()
end)

-- divider
local div = Instance.new("Frame", main)
div.Size = UDim2.new(1, -24, 0, 1)
div.Position = UDim2.new(0, 12, 0, 58)
div.BackgroundColor3 = Color3.fromRGB(110, 60, 255)
div.BackgroundTransparency = 0.7
div.BorderSizePixel = 0

-- scroll area
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, 0, 1, -68)
scroll.Position = UDim2.new(0, 0, 0, 64)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = Color3.fromRGB(110, 60, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

local pad = Instance.new("UIPadding", scroll)
pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingRight = UDim.new(0, 12)
pad.PaddingTop = UDim.new(0, 6)
pad.PaddingBottom = UDim.new(0, 10)

-- ======== Helpers ========
local function makeSection(labelText, order)
    local row = Instance.new("Frame", scroll)
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order

    local line = Instance.new("Frame", row)
    line.Size = UDim2.new(0, 20, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = Color3.fromRGB(110, 60, 255)
    line.BackgroundTransparency = 0.3
    line.BorderSizePixel = 0

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -28, 1, 0)
    lbl.Position = UDim2.new(0, 26, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(labelText)
    lbl.TextColor3 = Color3.fromRGB(110, 60, 255)
    lbl.TextTransparency = 0.2
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function makeToggle(labelText, subText, order, onEnable, onDisable)
    local card = Instance.new("Frame", scroll)
    card.Size = UDim2.new(1, 0, 0, 54)
    card.BackgroundColor3 = Color3.fromRGB(16, 12, 30)
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = Color3.fromRGB(255, 255, 255)
    cardStroke.Transparency = 0.92
    cardStroke.Thickness = 1

    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0.65, 0, 0, 18)
    lbl.Position = UDim2.new(0, 12, 0, 9)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(235, 235, 245)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", card)
    sub.Size = UDim2.new(0.65, 0, 0, 14)
    sub.Position = UDim2.new(0, 12, 0, 30)
    sub.BackgroundTransparency = 1
    sub.Text = subText
    sub.TextColor3 = Color3.fromRGB(160, 150, 190)
    sub.TextSize = 10
    sub.Font = Enum.Font.Gotham
    sub.TextXAlignment = Enum.TextXAlignment.Left

    local sw = Instance.new("Frame", card)
    sw.Size = UDim2.new(0, 38, 0, 22)
    sw.Position = UDim2.new(1, -50, 0.5, -11)
    sw.BackgroundColor3 = Color3.fromRGB(30, 24, 50)
    sw.BorderSizePixel = 0
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

    local swStroke = Instance.new("UIStroke", sw)
    swStroke.Color = Color3.fromRGB(255, 255, 255)
    swStroke.Transparency = 0.85
    swStroke.Thickness = 1

    local thumb = Instance.new("Frame", sw)
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new(0, 3, 0.5, -8)
    thumb.BackgroundColor3 = Color3.fromRGB(80, 70, 110)
    thumb.BorderSizePixel = 0
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    states[labelText] = false

    local hitbox = Instance.new("TextButton", card)
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""

    hitbox.MouseButton1Click:Connect(function()
        states[labelText] = not states[labelText]
        local on = states[labelText]

        TweenService:Create(sw, TweenInfo.new(0.18), {
            BackgroundColor3 = on and Color3.fromRGB(90, 40, 220) or Color3.fromRGB(30, 24, 50)
        }):Play()
        TweenService:Create(thumb, TweenInfo.new(0.18), {
            Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(80, 70, 110)
        }):Play()
        TweenService:Create(cardStroke, TweenInfo.new(0.18), {
            Transparency = on and 0.6 or 0.92,
            Color = on and Color3.fromRGB(110, 60, 255) or Color3.fromRGB(255, 255, 255)
        }):Play()

        if on then task.spawn(onEnable)
        elseif onDisable then onDisable() end
    end)
end

local function makeButton(labelText, subText, order, onClick)
    local card = Instance.new("Frame", scroll)
    card.Size = UDim2.new(1, 0, 0, 54)
    card.BackgroundColor3 = Color3.fromRGB(16, 12, 30)
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = Color3.fromRGB(255, 255, 255)
    cardStroke.Transparency = 0.92
    cardStroke.Thickness = 1

    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0.65, 0, 0, 18)
    lbl.Position = UDim2.new(0, 12, 0, 9)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(235, 235, 245)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", card)
    sub.Size = UDim2.new(0.65, 0, 0, 14)
    sub.Position = UDim2.new(0, 12, 0, 30)
    sub.BackgroundTransparency = 1
    sub.Text = subText
    sub.TextColor3 = Color3.fromRGB(160, 150, 190)
    sub.TextSize = 10
    sub.Font = Enum.Font.Gotham
    sub.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.new(0, 54, 0, 28)
    btn.Position = UDim2.new(1, -64, 0.5, -14)
    btn.BackgroundColor3 = Color3.fromRGB(90, 40, 220)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "run"
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        btn.Text = "..."
        btn.BackgroundColor3 = Color3.fromRGB(50, 40, 80)
        task.spawn(function()
            local ok = pcall(onClick)
            task.wait(0.2)
            btn.Text = ok and "✓" or "✕"
            btn.BackgroundColor3 = ok and Color3.fromRGB(40, 180, 100) or Color3.fromRGB(200, 50, 60)
            task.wait(1.5)
            btn.Text = "run"
            btn.BackgroundColor3 = Color3.fromRGB(90, 40, 220)
        end)
    end)
end

-- ======== Sections ========

-- REWARDS
makeSection("rewards", 1)

makeButton("Offline Rewards", "claim รางวัล offline", 2, function()
    RF.OfflineRewards.ClaimRewards:InvokeServer()
end)

makeButton("Loyalty Roblox", "claim loyalty prize", 3, function()
    RF.Loyalty.ClaimRobloxPrize:InvokeServer()
end)

makeButton("Loyalty Discord", "claim discord prize", 4, function()
    RF.Loyalty.ClaimDicordPrize:InvokeServer()
end)

makeButton("Claim UnitDex", "claim gem จากทุก unit", 5, function()
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
            if (gui:IsA("Frame") or gui:IsA("ImageButton")) and gui.Visible
                and gui.AbsoluteSize.X > 200 and gui.AbsoluteSize.X < 500 then
                pcall(function() gui.Visible = false end)
            end
        end
        task.wait(0.1)
    end
end)

makeSection("round", 16)

makeToggle("Auto Vote Next", "โหวต next หลังจบด่าน", 17, function()
    local voteRE = game.ReplicatedStorage.Systems.Voting.Vote
    while states["Auto Vote Next"] do
        local timer = game.ReplicatedStorage:GetAttribute("RoundEndTimer")
        if timer ~= nil then
            pcall(function() voteRE:FireServer("Next") end)
            print("✅ โหวต Next")
            task.wait(18)
        end
        task.wait(1)
    end
end)

makeToggle("Auto Vote Retry", "โหวต retry หลังจบด่าน", 18, function()
    local voteRE = game.ReplicatedStorage.Systems.Voting.Vote
    while states["Auto Vote Retry"] do
        local timer = game.ReplicatedStorage:GetAttribute("RoundEndTimer")
        if timer ~= nil then
            pcall(function() voteRE:FireServer("Retry") end)
            print("✅ โหวต Retry")
            task.wait(18)
        end
        task.wait(1)
    end
end)
-- CHESTS
makeSection("chests", 6)

makeToggle("Auto Collect", "วาร์ปเก็บ chest อัตโนมัติ", 7, function()
    local bonusChests = workspace.Map.BonusChests
    while states["Auto Collect"] do
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
                root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.8)
                pcall(function()
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    for _, obj in ipairs(part:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            pcall(fireproximityprompt, obj)
                        end
                    end
                    task.wait(0.5)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end)
                local retry = 0
                while part and part.Parent and retry < 5 do
                    task.wait(0.3)
                    retry += 1
                end
                task.wait(0.5)
            end
        end
    end
end)

-- QUESTS
makeSection("quests", 8)

makeToggle("Auto Claim Quest", "claim quest วนอัตโนมัติ", 9, function()
    while states["Auto Claim Quest"] do
        for i = 1, 10 do
            if not states["Auto Claim Quest"] then break end
            pcall(function() RF.Quests.ClaimQuest:InvokeServer(i) end)
            task.wait(0.2)
        end
        task.wait(5)
    end
end)

-- FARM
makeSection("farm", 10)

makeToggle("Auto Wave", "sweep wave อัตโนมัติ", 11, function()
    while states["Auto Wave"] do
        pcall(function() RF.Sweeps.SweepWave:InvokeServer() end)
        task.wait(3)
    end
end)

makeToggle("Auto Queue", "เข้า queue อัตโนมัติ", 12, function()
    while states["Auto Queue"] do
        pcall(function() RF.Queue.RequestEnterQueue:InvokeServer() end)
        task.wait(5)
    end
end)

-- PLAYER
makeSection("player", 13)

makeToggle("Speed Hack", "walkspeed x3", 14, function()
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

makeToggle("Infinite Jump", "กระโดดได้ไม่จำกัด", 15, function()
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
