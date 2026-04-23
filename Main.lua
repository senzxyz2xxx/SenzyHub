local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({ Title = "SENZY HUB", SubTitle = "Monster TP Farm", TabWidth = 160, Size = UDim2.fromOffset(580, 460), Theme = "Darker" })
local Tabs = { Farm = Window:AddTab({ Title = "Farm", Icon = "zap" }) }
local Options = Fluent.Options

-- ฟังก์ชั่นดึงรายชื่อมอนสเตอร์ที่ไม่ซ้ำกัน
local function GetEnemies()
    local List = {}
    for _, v in pairs(workspace.Client.Enemies:GetChildren()) do
        if v:IsA("Model") and not table.find(List, v.Name) then
            table.insert(List, v.Name)
        end
    end
    -- ถ้าใน Folder ไม่มีมอนสเตอร์เลย ให้ใส่ค่า Default ไว้
    if #List == 0 then table.insert(List, "Buggo") end 
    return List
end

local MonsterDropdown = Tabs.Farm:AddDropdown("SelectedMonster", { Title = "Select Monster", Values = GetEnemies(), Default = 1 })
local AutoFarm = Tabs.Farm:AddToggle("AutoFarm", {Title = "TP Farm (ALL)", Default = false})

-- Loop ฟาร์มแบบ TP ทันทีและสลับเป้าหมาย
task.spawn(function()
    while true do
        task.wait()
        if Options.AutoFarm.Value and Options.SelectedMonster.Value ~= "" then
            pcall(function()
                local TargetName = Options.SelectedMonster.Value
                local Root = game.Players.LocalPlayer.Character.HumanoidRootPart
                
                -- วนลูปเช็คมอนสเตอร์ทุกตัวในโฟลเดอร์ (ไม่ใช้ Logic "ตัวที่ใกล้ที่สุด" เพื่อแก้ปัญหาล็อคตัวเดิม)
                for _, monster in pairs(workspace.Client.Enemies:GetChildren()) do
                    if not Options.AutoFarm.Value then break end
                    
                    local humanoid = monster:FindFirstChild("Humanoid")
                    local targetPart = monster:FindFirstChild("HumanoidRootPart") or monster:FindFirstChild("Head")
                    
                    if monster:IsA("Model") and monster.Name == TargetName and targetPart and humanoid and humanoid.Health > 0 then
                        
                        -- วาร์ปไปตำแหน่งเหนือมอนสเตอร์เล็กน้อยทันที (Instant TP)
                        Root.CFrame = targetPart.CFrame * CFrame.new(0, 5, 0)
                        
                        -- รอจนกว่ามอนสเตอร์ตัวนี้จะตาย ถึงจะไปหาตัวถัดไปใน Loop
                        repeat task.wait() until not Options.AutoFarm.Value or not monster:Parent() or humanoid.Health <= 0
                        
                        -- พอมอนสเตอร์ตาย สคริปต์จะออกจาก repeat loop แล้วไปหาตัวถัดไปทันที
                    end
                end
            end)
        end
    end
end)

Window:SelectTab(1)
Fluent:Notify({Title = "Senzy Hub", Content = "TP Farm for ALL monsters Loaded!", Duration = 5})
