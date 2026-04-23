local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SENZY HUB",
    SubTitle = "Auto Farm Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Farm = Window:AddTab({ Title = "Farm", Icon = "zap" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options
local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer

-- ======== [ ฟังก์ชั่นหาชื่อมอนสเตอร์ใน Folder ] ========
local function GetMonsterList()
    local List = {}
    -- เปลี่ยน Path ตรงนี้ให้ตรงกับในเกม (เช่น workspace.Client.Enemies)
    local Success, Enemies = pcall(function() return workspace.Client.Enemies:GetChildren() end)
    if Success then
        for _, v in pairs(Enemies) do
            if v:IsA("Model") and not table.find(List, v.Name) then
                table.insert(List, v.Name)
            end
        end
    end
    return List
end

-- ======== [ FARM TAB ] ========

-- Dropdown สำหรับเลือกมอนสเตอร์
local MonsterDropdown = Tabs.Farm:AddDropdown("SelectedMonster", {
    Title = "Select Monster",
    Values = GetMonsterList(),
    Multi = false,
    Default = 1,
})

-- ปุ่มกด Refresh รายชื่อมอนสเตอร์
Tabs.Farm:AddButton({
    Title = "Refresh Monster List",
    Callback = function()
        MonsterDropdown:SetValues(GetMonsterList())
    end
})

-- Toggle เปิด/ปิดฟาร์ม
local AutoFarmTween = Tabs.Farm:AddToggle("AutoFarmTween", {Title = "Auto Farm (Tween)", Default = false})

-- ======== [ LOGIC AUTO FARM ] ========
task.spawn(function()
    while true do
        task.wait(0.1)
        if Options.AutoFarmTween.Value and Options.SelectedMonster.Value ~= "" then
            pcall(function()
                local TargetName = Options.SelectedMonster.Value
                local EnemyFolder = workspace.Client.Enemies
                local Character = Player.Character
                local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                
                if Root then
                    -- ค้นหามอนสเตอร์ที่ใกล้ที่สุดตามชื่อที่เลือก
                    local Target = nil
                    local MaxDist = math.huge
                    
                    for _, v in pairs(EnemyFolder:GetChildren()) do
                        if v.Name == TargetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            local Dist = (Root.Position - v.HumanoidRootPart.Position).Magnitude
                            if Dist < MaxDist then
                                MaxDist = Dist
                                Target = v
                            end
                        end
                    end
                    
                    if Target then
                        -- ระบบ Tween เคลื่อนที่
                        local TweenSpeed = 100 -- ปรับความเร็วได้
                        local Distance = (Root.Position - Target.HumanoidRootPart.Position).Magnitude
                        local Info = TweenInfo.new(Distance / TweenSpeed, Enum.EasingStyle.Linear)
                        
                        -- วาร์ปไปตำแหน่งเหนือมอนสเตอร์ 5 หน่วย
                        local Tween = TweenService:Create(Root, Info, {
                            CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                        })
                        Tween:Play()
                        
                        -- รอจนกว่าจะถึง หรือเป้าหมายตาย หรือปิด Toggle
                        repeat task.wait() 
                        until not Options.AutoFarmTween.Value or not Target or Target.Humanoid.Health <= 0 or (Root.Position - (Target.HumanoidRootPart.Position + Vector3.new(0,5,0))).Magnitude < 2
                        Tween:Cancel()
                    end
                end
            end)
        end
    end
end)

-- ======== [ สิ้นสุดสคริปต์ ] ========
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({
    Title = "Senzy Hub",
    Content = "Professional Farm System Loaded!",
    Duration = 5
})
