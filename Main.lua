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
    Main = Window:AddTab({ Title = "Main", Icon = "box" }),
    Info = Window:AddTab({ Title = "Info", Icon = "info" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local isAutoChest = false

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

-- Tab Main: Auto Chests
Tabs.Main:AddSection("Auto Chest")

local ChestToggle = Tabs.Main:AddToggle("AutoChestToggle", { Title = "Auto Chests (Instant Warp)", Default = false })
ChestToggle:OnChanged(function(Value)
    isAutoChest = Value
end)

-- Tab Info: Announcement
Tabs.Info:AddSection("Information")
Tabs.Info:AddParagraph({
    Title = "Notice",
    Content = "Other features are coming soon! Stay tuned for upcoming updates."
})

-- Loop: Auto Chest (Instant Teleport + 0.3s)
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
