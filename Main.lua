-- Senzy Hub | Fluent Edition
-- Optimized for Xeno / Delta / Wave
-- Credits: Senzy

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

--สร้างหน้าต่างหลัก
local Window = Fluent:CreateWindow({
    Title = "SENZY HUB",
    SubTitle = "Anime Discovery | Fix Version",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Rewards", Icon = "star" }),
    Chests = Window:AddTab({ Title = "Chests", Icon = "box" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "zap" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- ======== [ REWARDS ] ========
Tabs.Main:AddButton({
    Title = "Claim UnitDex",
    Description = "รับ Gem จากทุกยูนิต",
    Callback = function()
        local Items = require(game.ReplicatedStorage.Systems.Items)
        local unitData = Items:GetCategoryData("Units")
        for unitName in pairs(unitData) do
            pcall(function() game.ReplicatedStorage.Systems.UnitDex.ClaimUnitReward:InvokeServer(unitName) end)
            task.wait(0.1)
        end
    end
})

-- ======== [ CHESTS ] ========
local AutoCollect = Tabs.Chests:AddToggle("AutoCollect", {Title = "Auto Collect Chests", Default = false})
AutoCollect:OnChanged(function()
    task.spawn(function()
        while Options.AutoCollect.Value do
            local ok, bonusChests = pcall(function() return workspace.Map.BonusChests end)
            if ok and bonusChests then
                for _, part in ipairs(bonusChests:GetChildren()) do
                    if not Options.AutoCollect.Value then break end
                    if part:IsA("BasePart") then
                        local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.5)
                            pcall(function() fireproximityprompt(part:FindFirstChildOfClass("ProximityPrompt") or part:FindFirstChild("ProximityPrompt", true)) end)
                        end
                    end
                end
            end
            task.wait(2)
        end
    end)
end)

-- ======== [ FARM ] ========
Tabs.Farm:AddToggle("AutoClaimQuest", {Title = "Auto Claim Quest", Default = false}):OnChanged(function()
    task.spawn(function()
        while Options.AutoClaimQuest.Value do
            for i = 1, 25 do
                if not Options.AutoClaimQuest.Value then break end
                pcall(function() game.ReplicatedStorage.Systems.Quests.ClaimQuest:InvokeServer(i) end)
                task.wait(0.3)
            end
            task.wait(5)
        end
    end)
end)

Tabs.Farm:AddToggle("AutoWave", {Title = "Auto Sweep Wave", Default = false}):OnChanged(function()
    task.spawn(function()
        while Options.AutoWave.Value do
            pcall(function() game.ReplicatedStorage.Systems.Sweeps.SweepWave:InvokeServer() end)
            task.wait(3)
        end
    end)
end)

Tabs.Farm:AddToggle("AutoQueue", {Title = "Auto Queue", Default = false}):OnChanged(function()
    task.spawn(function()
        while Options.AutoQueue.Value do
            pcall(function() game.ReplicatedStorage.Systems.Queue.RequestEnterQueue:InvokeServer() end)
            task.wait(5)
        end
    end)
end)

-- แก้ไข VOTE NEXT & RETRY (Logic แบบเดี่ยว ไม่รัวเกินไป)
local AutoVoteNext = Tabs.Farm:AddToggle("AutoVoteNext", {Title = "Auto Vote Next", Default = false})
AutoVoteNext:OnChanged(function()
    task.spawn(function()
        local voted = false
        while Options.AutoVoteNext.Value do
            local timer = game.ReplicatedStorage:GetAttribute("RoundEndTimer")
            if timer ~= nil then
                if not voted then
                    pcall(function() game.ReplicatedStorage.Systems.Voting.Vote:FireServer("Next") end)
                    voted = true
                end
            else
                voted = false
            end
            task.wait(1)
        end
    end)
end)

Tabs.Farm:AddToggle("AutoVoteRetry", {Title = "Auto Vote Retry", Default = false}):OnChanged(function()
    task.spawn(function()
        local voted = false
        while Options.AutoVoteRetry.Value do
            local timer = game.ReplicatedStorage:GetAttribute("RoundEndTimer")
            if timer ~= nil then
                if not voted then
                    pcall(function() game.ReplicatedStorage.Systems.Voting.Vote:FireServer("Retry") end)
                    voted = true
                end
            else
                voted = false
            end
            task.wait(1)
        end
    end)
end)

-- ======== [ PLAYER ] ========
Tabs.Player:AddSlider("WS", {Title = "WalkSpeed", Default = 16, Min = 16, Max = 150, Rounding = 1, Callback = function(v)
    pcall(function() game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end)
end})

-- ======== [ สิ้นสุดสคริปต์ (ห้ามลบ) ] ========
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({
    Title = "Senzy Hub Loaded",
    Content = "ปุ่มเปิด/ปิดคือ Left Control",
    Duration = 5
})
