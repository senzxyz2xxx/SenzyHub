local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("BLINK_RELIABLE_REMOTE")

local MacroData = {}
local IsRecording = false
local SelectedMacro = ""
local SaveFileName = "MyMacro"

-- --------------------------------------------------
-- 1. Helper Functions (Money, Buffer & Files)
-- --------------------------------------------------
-- ฟังก์ชันดึงค่าเงินผู้เล่น (ถ้าแมพมึงใช้ชื่ออื่น ให้เปลี่ยน "Money" ตรงนี้)
local function getPlayerMoney()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local money = leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Coins") or leaderstats:FindFirstChild("Cash")
        if money then return money.Value end
    end
    -- ป้องกันกรณีเงินอยู่ใน PlayerGui หรือตำแหน่งอื่น
    return 0
end

local function bufferToTable(buf)
    local t = {}
    for i = 0, buffer.len(buf) - 1 do
        table.insert(t, buffer.readu8(buf, i))
    end
    return t
end

local function tableToBuffer(t)
    local buf = buffer.create(#t)
    for i, v in ipairs(t) do
        buffer.writeu8(buf, i - 1, v)
    end
    return buf
end

local function getMacroFiles()
    local files = {}
    if listfiles then
        for _, file in ipairs(listfiles("")) do
            if file:sub(-5) == ".json" then
                local name = file:gsub("\\", "/"):match("[^/]+$"):sub(1, -6)
                table.insert(files, name)
            end
        end
    end
    if #files == 0 then table.insert(files, "ไม่มีไฟล์เซฟ") end
    return files
end

-- --------------------------------------------------
-- 2. Hooking Remote (บันทึกอิงตามค่าเงิน)
-- --------------------------------------------------
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if IsRecording and self == Remote and method == "FireServer" then
        local buf = args[1]
        if typeof(buf) == "buffer" then
            table.insert(MacroData, {
                Money = getPlayerMoney(), -- บันทึกค่าเงินตอนยิง Remote
                Data = bufferToTable(buf)
            })
            print("[Senzy Hub] บันทึกแอคชั่นแล้ว! เงินที่ใช้:", getPlayerMoney())
        end
    end
    return oldNamecall(self, ...)
end)

-- --------------------------------------------------
-- 3. Fluent UI Setup
-- --------------------------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SENZY HUB",
    SubTitle = "Macro System (Money-Based)",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Darker"
})

local Tabs = {
    Macro = Window:AddTab({ Title = "Macro", Icon = "play" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- --------------------------------------------------
-- 4. Controls & File Manager
-- --------------------------------------------------
Tabs.Macro:AddButton({
    Title = "🔴 Start Record",
    Callback = function()
        MacroData = {}
        IsRecording = true
        Fluent:Notify({ Title = "Senzy Hub", Content = "เริ่มอัดมาโคร (ระบบจับตามค่าเงิน)...", Duration = 3 })
    end
})

Tabs.Macro:AddButton({
    Title = "⏹️ Stop Record",
    Callback = function()
        IsRecording = false
        Fluent:Notify({ Title = "Senzy Hub", Content = "หยุดอัดเรียบร้อย!", Duration = 3 })
    end
})

Tabs.Macro:AddInput("SaveNameInput", {
    Title = "ชื่อไฟล์สำหรับเซฟ",
    Default = "MyMacro",
    Placeholder = "พิมพ์ชื่อไฟล์...",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        SaveFileName = Value ~= "" and Value or "MyMacro"
    end
})

Tabs.Macro:AddButton({
    Title = "💾 Save Macro",
    Callback = function()
        if #MacroData == 0 then 
            return Fluent:Notify({ Title = "Senzy Hub", Content = "ไม่มีข้อมูลให้อัด!", Duration = 3 }) 
        end
        
        local success, err = pcall(function()
            writefile(SaveFileName .. ".json", HttpService:JSONEncode(MacroData))
        end)
        
        if success then
            Fluent:Notify({ Title = "Senzy Hub", Content = "เซฟลงไฟล์ " .. SaveFileName .. ".json แล้ว!", Duration = 3 })
        else
            Fluent:Notify({ Title = "Senzy Hub", Content = "เซฟล้มเหลว: " .. tostring(err), Duration = 3 })
        end
    end
})

local MacroDropdown = Tabs.Macro:AddDropdown("MacroSelect", {
    Title = "เลือกไฟล์มาโครที่จะใช้",
    Values = getMacroFiles(),
    Multi = false,
    Default = 1,
    Callback = function(Value)
        SelectedMacro = Value
    end
})

Tabs.Macro:AddButton({
    Title = "🔄 Refresh รายชื่อไฟล์",
    Callback = function()
        MacroDropdown:SetValues(getMacroFiles())
        Fluent:Notify({ Title = "Senzy Hub", Content = "อัปเดตรายชื่อไฟล์แล้ว!", Duration = 2 })
    end
})

Tabs.Macro:AddButton({
    Title = "▶️ Play Macro",
    Callback = function()
        if SelectedMacro == "" or SelectedMacro == "ไม่มีไฟล์เซฟ" then
            return Fluent:Notify({ Title = "Senzy Hub", Content = "กรุณาเลือกไฟล์มาโครก่อน!", Duration = 3 })
        end
        
        local fileName = SelectedMacro .. ".json"
        if not isfile(fileName) then 
            return Fluent:Notify({ Title = "Senzy Hub", Content = "ไม่พบไฟล์!", Duration = 3 }) 
        end
        
        -- แก้จุดบั๊ก: ใช้ JSONDecode อ่านไฟล์
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        
        if not success or not data then
            return Fluent:Notify({ Title = "Senzy Hub", Content = "อ่านไฟล์เซฟล้มเหลว!", Duration = 3 })
        end
        
        Fluent:Notify({ Title = "Senzy Hub", Content = "กำลังเล่นมาโคร: " .. SelectedMacro, Duration = 3 })
        
        -- ทำงานวนตามค่าเงิน
        task.spawn(function()
            for i, action in ipairs(data) do
                local targetMoney = action.Money or 0
                
                -- วนรอจนกว่าเงินผู้เล่นจะถึงราคาที่บันทึกไว้
                repeat 
                    task.wait(0.2) 
                until getPlayerMoney() >= targetMoney
                
                -- เงินพอแล้ว ยิง Remote วาง/อัปเกรด
                local restoredBuffer = tableToBuffer(action.Data)
                Remote:FireServer(restoredBuffer, {})
                
                task.wait(0.3) -- ดีเลย์กันสแปมส่ง Remote รัวเกินไป
            end
            Fluent:Notify({ Title = "Senzy Hub", Content = "เล่นมาโครจบแล้ว!", Duration = 3 })
        end)
    end
})

-- --------------------------------------------------
-- 5. Toggle Keybind & UI Control
-- --------------------------------------------------
local ToggleKeybind = Tabs.Settings:AddKeybind("GUI_Toggle", {
    Title = "UI Toggle Key",
    Default = "P"
})

local isGuiVisible = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local targetKey = Enum.KeyCode[ToggleKeybind.Value] or Enum.KeyCode.P
    if input.KeyCode == targetKey then
        isGuiVisible = not isGuiVisible
        
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name:find("Fluent") or gui:FindFirstChild("Main")) then
                gui.Enabled = isGuiVisible
            end
        end
    end
end)

Window:SelectTab(1)
