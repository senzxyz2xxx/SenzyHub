-- Senzy Hub | Fluent Edition
-- Optimized for Xeno / Delta / Wave
-- Credits: Senzy & VOXY Logic

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SENZY HUB",
    SubTitle = "Anime Discovery",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, 
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- จัดหมวดหมู่ Tab แบบพี่ VOX
local Tabs = {
    Main = Window:AddTab({ Title = "Rewards", Icon = "star" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "zap" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- ==========================================
-- [ REWARDS TAB ]
-- ==========================================

Tabs.Main:AddButton({
    Title = "Claim All UnitDex",
    Description = "รับ Gems จากยูนิตทุกตัวที่มีในดาต้าเบส",
    Callback = function()
        local Items = require(game.ReplicatedStorage.Systems.Items)
        local unitData = Items:GetCategoryData("Units")
        local dexRF = game.ReplicatedStorage.Systems.UnitDex.ClaimUnitReward
        
        for unitName in pairs(unitData) do
            pcall(function() dexRF:InvokeServer(unitName) end)
            task.wait(0.1)
        end
        
        Fluent:Notify({
            Title = "Success",
            Content = "กวาดรางวัล UnitDex เรียบร้อยแล้ว!",
            Duration = 5
        })
    end
})

-- ==========================================
-- [ FARM TAB ]
-- ==========================================

-- แก้ไข Logic Vote Next ให้กดได้จริงและเสถียร
local VoteNextToggle = Tabs.Farm:AddToggle("AutoVoteNext", {Title = "Auto Vote Next", Default = false, Description = "โหวตด่านต่อไปอัตโนมัติเมื่อจบตา"})

VoteNextToggle:OnChanged(function()
    task.spawn(function()
        local voteRE = game.ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Voting"):WaitForChild("Vote")
        while Options.AutoVoteNext.Value do
            -- เช็คจาก Attribute ตามที่ระบบเกมใช้
            if game.ReplicatedStorage:GetAttribute("RoundEndTimer") then
                print("🏁 จบด่านแล้ว! กำลังส่งคำสั่งโหวต Next...")
                pcall(function() voteRE:FireServer("Next") end)
                
                -- รอจนกว่าด่านใหม่จะเริ่ม (Timer หายไป) ถึงจะเริ่มทำงานรอบต่อไป
                repeat task.wait(1) until not game.ReplicatedStorage:GetAttribute("RoundEndTimer") or not Options.AutoVoteNext.Value
                print("🔄 เริ่มด่านใหม่ รีเซ็ตระบบโหวต")
            end
            task.wait(1)
        end
    end)
end)

local AutoClaimQuest = Tabs.Farm:AddToggle("AutoClaimQuest", {Title = "Auto Claim Quest", Default = false})
AutoClaimQuest:OnChanged(function()
    task.spawn(function()
        local questRF = game.ReplicatedStorage.Systems.Quests.ClaimQuest
        while Options.AutoClaimQuest.Value do
            for i = 1, 25 do
                if not Options.AutoClaimQuest.Value then break end
                pcall(function() questRF:InvokeServer(i) end)
                task.wait(0.2)
            end
            task.wait(10)
        end
    end)
end)

local AutoWave = Tabs.Farm:AddToggle("AutoWave", {Title = "Auto Sweep Wave", Default = false})
AutoWave:OnChanged(function()
    task.spawn(function()
        local sweepRF = game.ReplicatedStorage.Systems.Sweeps.SweepWave
        while Options.AutoWave.Value do
            pcall(function() sweepRF:InvokeServer() end)
            task.wait(5)
        end
    end)
end)

-- ==========================================
-- [ PLAYER TAB ]
-- ==========================================

local SpeedSlider = Tabs.Player:AddSlider("WalkSpeed", {
    Title = "WalkSpeed Hack",
    Description = "ปรับความเร็วการเคลื่อนที่",
    Default = 16,
    Min = 16,
    Max = 150,
    Rounding = 1,
    Callback = function(Value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

Tabs.Player:AddToggle("InfJump", {Title = "Infinite Jump", Default = false}):OnChanged(function()
    local conn
    conn = game:GetService("UserInputService").JumpRequest:Connect(function()
        if not Options.InfJump.Value then conn:Disconnect() return end
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end)
end)

-- ==========================================
-- [ FINALIZE ]
-- ==========================================

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({
    Title = "Senzy Hub Loaded",
    Content = "กด Left Control เพื่อย่อ/ขยายเมนู",
    Duration = 8
})

print("✅ [Senzy Hub] Fluent UI Loaded Successfully")
