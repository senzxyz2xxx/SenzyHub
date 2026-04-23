local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({ Title = "SENZY HUB", SubTitle = "Fast Farm", TabWidth = 160, Size = UDim2.fromOffset(580, 460), Theme = "Darker" })
local Tabs = { Farm = Window:AddTab({ Title = "Farm", Icon = "zap" }) }
local Options = Fluent.Options

-- ฟังก์ชั่นหาชื่อมอนสเตอร์ (ดึงชื่อที่ไม่ซ้ำกันมาโชว์)
local function GetEnemies()
    local List = {}
    for _, v in pairs(workspace.Client.Enemies:GetChildren()) do
        if v:IsA("Model") and not table.find(List, v.Name) then table.insert(List, v.Name) end
    end
    return List
end

local MonsterDropdown = Tabs.Farm:AddDropdown("SelectedMonster", { Title = "Select Monster", Values = GetEnemies(), Default = 1 })
local AutoFarm = Tabs.Farm:AddToggle("AutoFarm", {Title = "Fast TP Farm", Default = false})

-- Loop ฟาร์มแบบวาร์ปทันที
task.spawn(function()
    while true do
        task.wait()
        if Options.AutoFarm.Value and Options.SelectedMonster.Value ~= "" then
            pcall(function()
                local TargetName = Options.SelectedMonster.Value
                local Root = game.Players.LocalPlayer.Character.HumanoidRootPart
                
                -- หาตัวที่ใกล้ที่สุดของประเภทนั้น และเลือดยังมากกว่า 0
                local Target = nil
                local Dist = math.huge
                for _, v in pairs(workspace.Client.Enemies:GetChildren()) do
                    if v.Name == TargetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        local d = (Root.Position - v.HumanoidRootPart.Position).Magnitude
                        if d < Dist then
                            Dist = d
                            Target = v
                        end
                    end
                end

                -- ถ้าเจอตัวที่เลือก ให้วาร์ปไปทันที
                if Target then
                    -- วาร์ปไปตำแหน่งเหนือมอนสเตอร์เล็กน้อย
                    Root.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                    
                    -- รอจนกว่ามอนสเตอร์ตัวนี้จะตาย ถึงจะไปหาตัวใหม่ (แก้ปัญหาล็อคตัวเดิม)
                    repeat task.wait() until not Options.AutoFarm.Value or not Target:Parent() or Target.Humanoid.Health <= 0
                end
            end)
        end
    end
end)

Window:SelectTab(1)
