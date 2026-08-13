local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/senzxyz2xxx/Ui/refs/heads/main/Main.lua"))()
end)

if not success or not Library then
    return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Window = Library:Window({
    Title = "SENZY HUB",
    Footer = "Free Script",
    Logo = 111116339097216
})

-- Tab: Info
local InfoTab = Window:MakeTab({
    Title = "Info",
    Icon = 115960025411300
})

InfoTab:Button({
    Title = "SENZY HUB",
    Desc = "Discord: discord.gg/FAvu9ENrcb (Click to copy link)",
    Callback = function()
        if setclipboard then
            setclipboard("discord.gg/FAvu9ENrcb")
        end
    end
})

-- Tab: Teleport
local TeleportTab = Window:MakeTab({
    Title = "Teleport",
    Icon = 115960025411300
})

local exactZoneNames = {
    "Common",
    "Rare",
    "Epic",
    "Legendary",
    "Mythic",
    "Secret",
    "Slime God",
    "Spain",
    "OG",
    "Champions"
}

local function getZoneObjects()
    local zoneObjects = {}
    for _, zoneName in ipairs(exactZoneNames) do
        local foundObj = nil
        for _, obj in ipairs(workspace:GetDescendants()) do
            if (obj:IsA("Folder") or obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower() == zoneName:lower() then
                foundObj = obj
                break
            end
        end
        if foundObj then
            zoneObjects[zoneName] = foundObj
        end
    end
    return zoneObjects
end

local zoneMap = getZoneObjects()
local selectedZoneName = exactZoneNames[1]

local ZoneDropdown = TeleportTab:Dropdown({
    Title = "Select Zone",
    Value = selectedZoneName,
    List = exactZoneNames,
    Callback = function(Value)
        selectedZoneName = Value
    end,
})

local function extractPartFromData(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then
        return obj
    else
        for _, child in ipairs(obj:GetDescendants()) do
            if child:IsA("BasePart") then
                return child
            end
        end
    end
    return nil
end

TeleportTab:Button({
    Title = "Teleport to Zone",
    Desc = "Teleport to selected zone",
    Callback = function()
        local targetObj = zoneMap[selectedZoneName]
        if targetObj and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = extractPartFromData(targetObj)
            if targetPart then
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end
})

TeleportTab:Button({
    Title = "Teleport to My Plot",
    Desc = "Teleport back to your personal plot",
    Callback = function()
        local myPlot = nil
        local pName = LocalPlayer.Name:lower()
        local pDisp = LocalPlayer.DisplayName:lower()
        local pIdStr = tostring(LocalPlayer.UserId)

        -- ค้นหาจากโฟลเดอร์หลักใน Workspace ก่อน (เช่น Tycoons, Plots, Bases ฯลฯ)
        for _, folder in ipairs(workspace:GetChildren()) do
            if folder:IsA("Folder") or folder:IsA("Model") then
                for _, plot in ipairs(folder:GetChildren()) do
                    if plot:IsA("Folder") or plot:IsA("Model") then
                        local plotName = plot.Name:lower()
                        local isMatch = (plotName == pName or plotName == pDisp or plotName == pIdStr or plotName:find(pName))
                        
                        if not isMatch then
                            -- ตรวจสอบภายใน Plot (Value, Attributes, TextLabel, Sign)
                            for _, descendant in ipairs(plot:GetDescendants()) do
                                if descendant:IsA("StringValue") or descendant:IsA("IntValue") then
                                    local val = tostring(descendant.Value):lower()
                                    if val == pName or val == pDisp or val == pIdStr then
                                        isMatch = true
                                        break
                                    end
                                elseif descendant:IsA("ObjectValue") then
                                    if descendant.Value == LocalPlayer then
                                        isMatch = true
                                        break
                                    end
                                elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                                    local txt = descendant.Text:lower()
                                    if txt:find(pName, 1, true) or txt:find(pDisp, 1, true) then
                                        isMatch = true
                                        break
                                    end
                                end
                            end
                            
                            for _, attrVal in pairs(plot:GetAttributes()) do
                                local attrStr = tostring(attrVal):lower()
                                if attrStr == pName or attrStr == pDisp or attrStr == pIdStr then
                                    isMatch = true
                                    break
                                end
                            end
                        end

                        if isMatch then
                            myPlot = plot
                            break
                        end
                    end
                end
            end
            if myPlot then break end
        end

        -- หากยังไม่เจอ ให้ลองค้นหาแบบกวาดภาพรวมทั้งหมดใน Workspace อีกครั้งอย่างระมัดระวัง
        if not myPlot then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if (obj:IsA("Folder") or obj:IsA("Model")) and obj ~= LocalPlayer.Character and not obj:IsDescendantOf(LocalPlayer.Character) then
                    local objName = obj.Name:lower()
                    if objName == pName or objName == pDisp or objName == pIdStr then
                        myPlot = obj
                        break
                    end
                end
            end
        end

        if myPlot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = extractPartFromData(myPlot)
            if targetPart then
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end
})

-- Tab: Upgrade & Farm
local UpgradeTab = Window:MakeTab({
    Title = "Upgrade & Farm",
    Icon = 115960025411300
})

local autoJumpEnabled = false
local autoCarryEnabled = false
local autoRebirthEnabled = false
local autoUpgradeSlimeEnabled = false

local function getMyPlotTargets()
    local ids = {}
    for i = 1, 20 do
        table.insert(ids, tostring(i))
    end
    return ids
end

UpgradeTab:Button({
    Title = "Purchase Floor",
    Desc = "Automatically purchase new floors",
    Callback = function()
        local s, remotes = pcall(function() return ReplicatedStorage.SharedModules.Network.Remotes end)
        if s and remotes then
            local floorEvent = remotes:FindFirstChild("Purchase Floor")
            if floorEvent and floorEvent:IsA("RemoteFunction") then
                for i = 1, 10 do
                    pcall(function()
                        floorEvent:InvokeServer(i)
                    end)
                end
            end
        end
    end
})

UpgradeTab:Button({
    Title = "Collect Earnings",
    Desc = "Collect all earnings from your plot instantly",
    Callback = function()
        local s, remotes = pcall(function() return ReplicatedStorage.SharedModules.Network.Remotes end)
        if s and remotes then
            local collectEvent = remotes:FindFirstChild("Collect Earnings")
            if collectEvent and collectEvent:IsA("RemoteEvent") then
                local targets = getMyPlotTargets()
                for _, id in ipairs(targets) do
                    collectEvent:FireServer(id)
                end
            end
        end
    end
})

UpgradeTab:Toggle({
    Title = "Auto Upgrade Slime",
    Value = false,
    Callback = function(State)
        autoUpgradeSlimeEnabled = State
        task.spawn(function()
            while autoUpgradeSlimeEnabled do
                local s, remotes = pcall(function() return ReplicatedStorage.SharedModules.Network.Remotes end)
                if s and remotes then
                    local upgradeEvent = remotes:FindFirstChild("Upgrade Slime")
                    if upgradeEvent and upgradeEvent:IsA("RemoteEvent") then
                        local targets = getMyPlotTargets()
                        for _, id in ipairs(targets) do
                            upgradeEvent:FireServer(id)
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
})

UpgradeTab:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(State)
        autoRebirthEnabled = State
        task.spawn(function()
            while autoRebirthEnabled do
                local s, remotes = pcall(function() return ReplicatedStorage.SharedModules.Network.Remotes end)
                if s and remotes then
                    local rebirthEvent = remotes:FindFirstChild("Rebirth")
                    if rebirthEvent and rebirthEvent:IsA("RemoteEvent") then
                        rebirthEvent:FireServer()
                    end
                end
                task.wait(1)
            end
        end)
    end
})

UpgradeTab:Toggle({
    Title = "Auto Jump Upgrade",
    Value = false,
    Callback = function(State)
        autoJumpEnabled = State
        task.spawn(function()
            while autoJumpEnabled do
                local s, remotes = pcall(function() return ReplicatedStorage.SharedModules.Network.Remotes end)
                if s and remotes then
                    local speedEvent = remotes:FindFirstChild("Buy Speed Upgrade")
                    if speedEvent and speedEvent:IsA("RemoteEvent") then
                        speedEvent:FireServer(3)
                    end
                end
                task.wait(0.5)
            end
        end)
    end
})

UpgradeTab:Toggle({
    Title = "Auto Carry Limit",
    Value = false,
    Callback = function(State)
        autoCarryEnabled = State
        task.spawn(function()
            while autoCarryEnabled do
                local s, remotes = pcall(function() return ReplicatedStorage.SharedModules.Network.Remotes end)
                if s and remotes then
                    local carryEvent = remotes:FindFirstChild("Upgrade Carry Limit")
                    if carryEvent and carryEvent:IsA("RemoteEvent") then
                        carryEvent:FireServer()
                    end
                end
                task.wait(0.5)
            end
        end)
    end
})

-- Tab: Settings
local SettingsTab = Window:MakeTab({
    Title = "Settings",
    Icon = 115960025411300
})

local infJumpEnabled = false
local flyEnabled = false
local flySpeed = 50

local bv, bg, flyConn

SettingsTab:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(State)
        infJumpEnabled = State
    end
})

UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

SettingsTab:Toggle({
    Title = "Fly",
    Value = false,
    Callback = function(State)
        flyEnabled = State
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if flyEnabled then
            if hrp and hum then
                hum.PlatformStand = true
                bg = Instance.new("BodyGyro", hrp)
                bg.P = 9e4
                bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                bg.cframe = hrp.CFrame
                
                bv = Instance.new("BodyVelocity", hrp)
                bv.velocity = Vector3.new(0, 0, 0)
                bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
                
                flyConn = RunService.RenderStepped:Connect(function()
                    if not flyEnabled then return end
                    local cam = workspace.CurrentCamera
                    local moveDirection = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDirection = moveDirection + cam.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDirection = moveDirection - cam.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDirection = moveDirection - cam.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDirection = moveDirection + cam.CFrame.RightValue or cam.CFrame.RightVector
                    end
                    
                    bv.velocity = moveDirection * flySpeed
                    bg.cframe = cam.CFrame
                end)
            end
        else
            if hum then hum.PlatformStand = false end
            if flyConn then flyConn:Disconnect() end
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
        end
    end
})

SettingsTab:Slider({
    Title = "Fly Speed",
    Min = 10,
    Max = 200,
    Value = 50,
    Callback = function(Value)
        flySpeed = Value
    end
})

print("SENZY ON TOP START")
