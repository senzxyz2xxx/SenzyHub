-- Senzy Hub | Full Version
-- Execute via Xeno

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player.PlayerGui
local RF = game.ReplicatedStorage.Systems

if playerGui:FindFirstChild("SenzyHub") then playerGui.SenzyHub:Destroy() end

-- state
local states = {}
local loops = {}

-- ======== GUI ========
local sg = Instance.new("ScreenGui", playerGui)
sg.Name = "SenzyHub"
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 270, 0, 520)
main.Position = UDim2.new(0, 24, 0.5, -260)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local ms = Instance.new("UIStroke", main)
ms.Color = Color3.fromRGB(255,255,255)
ms.Transparency = 0.88
ms.Thickness = 1

local accent = Instance.new("Frame", main)
accent.Size = UDim2.new(0, 40, 0, 2)
accent.Position = UDim2.new(0, 16, 0, 0)
accent.BackgroundColor3 = Color3.fromRGB(130, 90, 255)
accent.BorderSizePixel = 0
Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

-- header
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 52)
header.BackgroundTransparency = 1

local logo = Instance.new("TextLabel", header)
logo.Size = UDim2.new(0, 28, 0, 28)
logo.Position = UDim2.new(0, 14, 0.5, -14)
logo.BackgroundColor3 = Color3.fromRGB(130, 90, 255)
logo.TextColor3 = Color3.fromRGB(255,255,255)
logo.Text = "S"
logo.TextSize = 13
logo.Font = Enum.Font.GothamBold
logo.TextXAlignment = Enum.TextXAlignment.Center
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0, 120, 0, 18)
title.Position = UDim2.new(0, 50, 0, 10)
title.BackgroundTransparency = 1
title.Text = "Senzy Hub"
title.TextColor3 = Color3.fromRGB(240,240,240)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

local ver = Instance.new("TextLabel", header)
ver.Size = UDim2.new(0, 120, 0, 14)
ver.Position = UDim2.new(0, 50, 0, 29)
ver.BackgroundTransparency = 1
ver.Text = "full version"
ver.TextColor3 = Color3.fromRGB(255,255,255)
ver.TextTransparency = 0.65
ver.TextSize = 11
ver.Font = Enum.Font.Gotham
ver.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -38, 0.5, -13)
closeBtn.BackgroundColor3 = Color3.fromRGB(30,30,45)
closeBtn.TextColor3 = Color3.fromRGB(160,160,160)
closeBtn.Text = "✕"
closeBtn.TextSize = 11
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
closeBtn.MouseButton1Click:Connect(function()
    for k, _ in pairs(states) do states[k] = false end
    sg:Destroy()
end)

local div = Instance.new("Frame", main)
div.Size = UDim2.new(1, -28, 0, 1)
div.Position = UDim2.new(0, 14, 0, 52)
div.BackgroundColor3 = Color3.fromRGB(255,255,255)
div.BackgroundTransparency = 0.92
div.BorderSizePixel = 0

-- scroll
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, 0, 1, -62)
scroll.Position = UDim2.new(0, 0, 0, 58)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = Color3.fromRGB(130, 90, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)

local pad = Instance.new("UIPadding", scroll)
pad.PaddingLeft = UDim.new(0, 14)
pad.PaddingRight = UDim.new(0, 14)
pad.PaddingTop = UDim.new(0, 8)
pad.PaddingBottom = UDim.new(0, 8)

-- footer
local footer = Instance.new("TextLabel", main)
footer.Size = UDim2.new(1, -28, 0, 18)
footer.Position = UDim2.new(0, 14, 1, -22)
footer.BackgroundTransparency = 1
footer.Text = "senzy hub  •  undetected"
footer.TextColor3 = Color3.fromRGB(255,255,255)
footer.TextTransparency = 0.82
footer.TextSize = 10
footer.Font = Enum.Font.Gotham
footer.TextXAlignment = Enum.TextXAlignment.Center

-- ======== Helper ========
local function makeSection(parent, labelText, order)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(130, 90, 255)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
end

local function makeToggle(parent, labelText, subText, order, onEnable, onDisable)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, 0, 0, 52)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0.7, 0, 0, 18)
    lbl.Position = UDim2.new(0, 12, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", card)
    sub.Size = UDim2.new(0.7, 0, 0, 14)
    sub.Position = UDim2.new(0, 12, 0, 28)
    sub.BackgroundTransparency = 1
    sub.Text = subText
    sub.TextColor3 = Color3.fromRGB(255,255,255)
    sub.TextTransparency = 0.6
    sub.TextSize = 11
    sub.Font = Enum.Font.Gotham
    sub.TextXAlignment = Enum.TextXAlignment.Left

    local sw = Instance.new("Frame", card)
    sw.Size = UDim2.new(0, 36, 0, 20)
    sw.Position = UDim2.new(1, -48, 0.5, -10)
    sw.BackgroundColor3 = Color3.fromRGB(35,35,55)
    sw.BorderSizePixel = 0
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame", sw)
    thumb.Size = UDim2.new(0, 14, 0, 14)
    thumb.Position = UDim2.new(0, 3, 0.5, -7)
    thumb.BackgroundColor3 = Color3.fromRGB(80,80,100)
    thumb.BorderSizePixel = 0
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local key = labelText
    states[key] = false

    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    btn.MouseButton1Click:Connect(function()
        states[key] = not states[key]
        local on = states[key]
        TweenService:Create(sw, TweenInfo.new(0.2), {
            BackgroundColor3 = on and Color3.fromRGB(130,90,255) or Color3.fromRGB(35,35,55)
        }):Play()
        TweenService:Create(thumb, TweenInfo.new(0.2), {
            Position = on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
            BackgroundColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(80,80,100)
        }):Play()
        if on then
            task.spawn(onEnable)
        else
            if onDisable then onDisable() end
        end
    end)

    return card
end

local function makeButton(parent, labelText, subText, order, onClick)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, 0, 0, 52)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0.75, 0, 0, 18)
    lbl.Position = UDim2.new(0, 12, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", card)
    sub.Size = UDim2.new(0.75, 0, 0, 14)
    sub.Position = UDim2.new(0, 12, 0, 28)
    sub.BackgroundTransparency = 1
    sub.Text = subText
    sub.TextColor3 = Color3.fromRGB(255,255,255)
    sub.TextTransparency = 0.6
    sub.TextSize = 11
    sub.Font = Enum.Font.Gotham
    sub.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.new(0, 52, 0, 26)
    btn.Position = UDim2.new(1, -62, 0.5, -13)
    btn.BackgroundColor3 = Color3.fromRGB(130, 90, 255)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = "claim"
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        btn.Text = "..."
        btn.BackgroundColor3 = Color3.fromRGB(60,60,80)
        local ok, res = pcall(onClick)
        task.wait(0.3)
        if ok then
            btn.Text = "✓"
            btn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
        else
            btn.Text = "✕"
            btn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        end
        task.wait(1.5)
        btn.Text = "claim"
        btn.BackgroundColor3 = Color3.fromRGB(130, 90, 255)
    end)
end

-- ======== Sections ========

-- REWARDS
makeSection(scroll, "— rewards", 1)

makeButton(scroll, "Offline Rewards", "claim รางวัล offline", 2, function()
    RF.OfflineRewards.ClaimRewards:InvokeServer()
end)

makeButton(scroll, "Loyalty Roblox", "claim loyalty prize", 3, function()
    RF.Loyalty.ClaimRobloxPrize:InvokeServer()
end)

makeButton(scroll, "Loyalty Discord", "claim discord prize", 4, function()
    RF.Loyalty.ClaimDicordPrize:InvokeServer()
end)

makeButton(scroll, "Unit Dex Reward", "claim unit dex reward", 5, function()
    local rs = game:GetService("ReplicatedStorage")
    local systems = rs:WaitForChild("Systems", 5)
    local loadRemote = systems:WaitForChild("ModelProvider"):WaitForChild("ModelReceived")
    local claimRemote = systems:WaitForChild("UnitDex"):WaitForChild("ClaimUnitReward")
    
    -- ลองแค่ตัวที่คุณมีชัวร์ๆ ก่อน (เช่น Ice Mage หรือ Deckhand)
    local targetUnits = {"Ice Mage", "Deckhand", "Swordsman"} 

    for _, name in ipairs(targetUnits) do
        print("🚀 กำลังปลดล็อค: " .. name)
        
        -- 1. ยิงโหลดโมเดล
        loadRemote:FireServer(name)
        
        -- 2. รอนานขึ้นนิดนึง (0.5 วินาที) ให้ Server บันทึกข้อมูล
        task.wait(0.5) 
        
        -- 3. ยิงรับรางวัล
        local ok, result = pcall(function()
            return claimRemote:InvokeServer(name)
        end)
        
        if ok and result then
            print("💰 [SUCCESS] Gems เข้าบัญชีแล้วสำหรับ: " .. name)
        else
            print("❌ [FAILED] ตัวนี้อาจจะรับไปแล้วหรือยังไม่เงื่อนไขไม่ครบ: " .. name)
        end
    end
end)
-- CHESTS
makeToggle(scroll, "Auto Collect", "วาร์ปเก็บ chest อัตโนมัติ", 7,
    function()
        local bonusChests = workspace.Map.BonusChests
        while states["Auto Collect"] do
            local parts = {}
            for _, c in ipairs(bonusChests:GetChildren()) do
                if c:IsA("BasePart") then table.insert(parts, c) end
            end
            
            if #parts == 0 then
                task.wait(1)
            else
                for _, part in ipairs(parts) do
                    if not states["Auto Collect"] then break end
                    
                    -- ตรวจสอบว่ากล่องยังอยู่ไหมก่อนจะทำ (ป้องกันการวาร์ปซ้ำที่ที่ว่าง)
                    if not part or not part.Parent then continue end

                    local char = player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if not root then break end
                    
                    -- 1. วาร์ปไปที่หีบ
                    root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.8) -- รอให้เซิร์ฟเวอร์รู้ว่าเราถึงแล้ว
                    
                    -- 2. เริ่มกระบวนการกดเปิด
                    pcall(function()
                        -- กด E ค้าง
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        
                        -- ลองใช้ fireproximityprompt ควบคู่ไปด้วยเพื่อให้ชัวร์
                        for _, obj in ipairs(part:GetDescendants()) do
                            if obj:IsA("ProximityPrompt") then
                                pcall(fireproximityprompt, obj)
                            end
                        end

                        task.wait(0.8) -- ระยะเวลากด E ค้าง (0.8 ตามที่ขอ)
                        
                        -- ปล่อย E
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    end)

                    -- 3. [จุดสำคัญ] รอให้กล่องหายไปก่อนค่อยไปต่อ
                    -- ถ้ากล่องยังอยู่ แสดงว่ายังเก็บไม่เสร็จ ให้รออีกนิด
                    local retry = 0
                    while part and part.Parent and retry < 5 do
                        task.wait(0.3)
                        retry = retry + 1
                    end
                    
                    -- 4. Cooldown ท้ายลูป ป้องกันการวาร์ปรัวจนโดนเตะ
                    task.wait(1.2) 
                end
            end
        end
    end
)
-- QUESTS
makeToggle(scroll, "Auto Claim Quest", "claim quest วนอัตโนมัติ", 9,
    function()
        while states["Auto Claim Quest"] do
            pcall(function()
                for i = 1, 10 do
                    if not states["Auto Claim Quest"] then break end
                    RF.Quests.ClaimQuest:InvokeServer(i)
                    task.wait(0.2) -- พักนิดนึงป้องกันเซิร์ฟเวอร์เตะ
                end
            end)
            task.wait(5) -- รอ 5 วินาทีค่อยเช็ครับใหม่ยกแผง
        end
    end
)
-- FARM
makeSection(scroll, "— farm", 10)

makeToggle(scroll, "Auto Wave", "sweep wave อัตโนมัติ", 11,
    function()
        while states["Auto Wave"] do
            pcall(function() RF.Sweeps.SweepWave:InvokeServer() end)
            task.wait(3)
        end
    end
)

makeToggle(scroll, "Auto Queue", "เข้า queue อัตโนมัติ", 12,
    function()
        while states["Auto Queue"] do
            pcall(function() RF.Queue.RequestEnterQueue:InvokeServer() end)
            task.wait(5)
        end
    end
)

-- PLAYER
makeSection(scroll, "— player", 13)

makeToggle(scroll, "Speed Hack", "walkspeed x3", 14,
    function()
        while states["Speed Hack"] do
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum.WalkSpeed = 48 end
            end
            task.wait(0.5)
        end
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
)

makeToggle(scroll, "Infinite Jump", "กระโดดได้ไม่จำกัด", 15,
    function()
        local conn
        conn = UserInputService.JumpRequest:Connect(function()
            if not states["Infinite Jump"] then
                conn:Disconnect()
                return
            end
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
        while states["Infinite Jump"] do task.wait(1) end
        conn:Disconnect()
    end
)

print("senzy hub loaded ✅")
