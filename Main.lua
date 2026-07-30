local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local MacroData = {}
local IsRecording = false
local IsPlaying = false
local AutoFixUI = false
local AutoNextEnabled = false
local SelectedMacro = ""
local NewFileName = "MyMacro"
local FolderName = "SenzyMacros"
local LastRecordTime = 0
local AutoNextDelay = 8
local PlayLoopDelay = 3

if makefolder and not isfolder(FolderName) then
    makefolder(FolderName)
end

-- --------------------------------------------------
-- Remote Path Setup
-- --------------------------------------------------
local ReliableRemote = nil

local function getReliableRemote()
    if ReliableRemote and ReliableRemote.Parent then return ReliableRemote end
    pcall(function()
        ReliableRemote = ReplicatedStorage:FindFirstChild("Packages") 
            and ReplicatedStorage.Packages:FindFirstChild("_Index") 
            and ReplicatedStorage.Packages._Index:FindFirstChild("imezx_warp@1.0.14")
            and ReplicatedStorage.Packages._Index["imezx_warp@1.0.14"]:FindFirstChild("warp")
            and ReplicatedStorage.Packages._Index["imezx_warp@1.0.14"].warp:FindFirstChild("Index")
            and ReplicatedStorage.Packages._Index["imezx_warp@1.0.14"].warp.Index:FindFirstChild("Event")
            and ReplicatedStorage.Packages._Index["imezx_warp@1.0.14"].warp.Index.Event:FindFirstChild("Reliable")
    end)
    return ReliableRemote
end

-- --------------------------------------------------
-- Virtual Click Helper
-- --------------------------------------------------
local function clickGuiObject(guiObj)
    if guiObj and guiObj:IsA("GuiObject") and guiObj.Visible then
        local pos = guiObj.AbsolutePosition
        local size = guiObj.AbsoluteSize
        local clickX = pos.X + (size.X / 2)
        local clickY = pos.Y + (size.Y / 2) + 36
        
        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
    end
end

-- --------------------------------------------------
-- Dynamic UI Fixer Loop
-- --------------------------------------------------
local FIXED_FRAME_NAME = "FixedUpgradeFrame"

local function fixDynamicUINames()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end

    for _, descendant in ipairs(playerGui:GetDescendants()) do
        if descendant.Name == "upgradeButton" or descendant.Name == "UpgradeButton" then
            local parentFrame = descendant.Parent
            if parentFrame and parentFrame:IsA("GuiObject") and parentFrame.Name ~= FIXED_FRAME_NAME then
                parentFrame.Name = FIXED_FRAME_NAME
            end
        end
    end
end

task.spawn(function()
    while task.wait(1) do
        if AutoFixUI then
            pcall(fixDynamicUINames)
        end
    end
end)

-- --------------------------------------------------
-- Helper Functions & Serialization
-- --------------------------------------------------
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

local function serializeArg(arg)
    local t = typeof(arg)
    if t == "buffer" then
        return { Type = "buffer", Data = bufferToTable(arg) }
    elseif t == "Instance" then
        return { Type = "Instance", Data = arg:GetFullName() }
    elseif t == "Vector3" then
        return { Type = "Vector3", Data = { arg.X, arg.Y, arg.Z } }
    elseif t == "CFrame" then
        return { Type = "CFrame", Data = { arg:GetComponents() } }
    elseif t == "EnumItem" then
        return { Type = "Enum", Data = tostring(arg) }
    else
        return { Type = "raw", Data = arg }
    end
end

local function deserializeArg(argObj)
    if not argObj or type(argObj) ~= "table" then return argObj end
    
    if argObj.Type == "buffer" then
        return tableToBuffer(argObj.Data)
    elseif argObj.Type == "Instance" then
        local obj = game
        if type(argObj.Data) == "string" then
            for pathPart in string.gmatch(argObj.Data, "[^%.]+") do
                if pathPart ~= "game" then
                    obj = obj and obj:FindFirstChild(pathPart)
                end
            end
        end
        return obj
    elseif argObj.Type == "Vector3" then
        return Vector3.new(unpack(argObj.Data))
    elseif argObj.Type == "CFrame" then
        return CFrame.new(unpack(argObj.Data))
    else
        return argObj.Data
    end
end

local function getMacroFiles()
    local files = {}
    if listfiles then
        local targetPath = isfolder and isfolder(FolderName) and FolderName or ""
        for _, file in ipairs(listfiles(targetPath)) do
            if file:sub(-5) == ".json" then
                local cleanName = file:gsub("\\", "/"):match("[^/]+$")
                if cleanName then
                    table.insert(files, cleanName:sub(1, -6))
                end
            end
        end
    end
    if #files == 0 then table.insert(files, "ไม่มีไฟล์เซฟ") end
    return files
end

-- --------------------------------------------------
-- New UI Library Setup (Senz UI)
-- --------------------------------------------------
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/senzxyz2xxx/Ui/refs/heads/main/main.lua"))()

local Window = Library:CreateWindow({
    Title = "SENZY HUB",
    SubTitle = "Macro System (Virtual UI Supported)",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 540),
    Theme = "Darker"
})

local Tabs = {
    Macro = Window:CreateTab({ Title = "Macro", Icon = "play" }),
    Settings = Window:CreateTab({ Title = "Settings", Icon = "settings" })
}

-- --------------------------------------------------
-- Floating Logo Toggle Button System
-- --------------------------------------------------
local LOGO_IMAGE_NAME = "SenzH.png"
local LOGO_URL = "https://raw.githubusercontent.com/senzxyz2xxx/SenzyHub/refs/heads/main/SenzH.png"

if writefile and getgenv then
    if not isfile(LOGO_IMAGE_NAME) then
        pcall(function()
            writefile(LOGO_IMAGE_NAME, game:HttpGet(LOGO_URL))
        end)
    end
end

local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or game:GetService("CoreGui")
if playerGui:FindFirstChild("SenzyToggleButtonGui") then
    playerGui.SenzyToggleButtonGui:Destroy()
end

local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "SenzyToggleButtonGui"
toggleGui.ResetOnSpawn = false
toggleGui.DisplayOrder = 99999
toggleGui.Parent = playerGui

local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name = "LogoButton"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 15, 0.5, -25)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
toggleBtn.BorderSizePixel = 0
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.Parent = toggleGui

if getcustomasset and isfile(LOGO_IMAGE_NAME) then
    toggleBtn.Image = getcustomasset(LOGO_IMAGE_NAME)
else
    toggleBtn.Image = LOGO_URL
end

local uiCorner = Instance.new("UICorner", toggleBtn)
uiCorner.CornerRadius = UDim.new(0, 12)

local uiStroke = Instance.new("UIStroke", toggleBtn)
uiStroke.Color = Color3.fromRGB(120, 60, 255)
uiStroke.Thickness = 2

toggleBtn.MouseButton1Click:Connect(function()
    if Window and Window.Toggle then
        Window:Toggle()
    end
end)

-- --------------------------------------------------
-- Universal Hooking
-- --------------------------------------------------
local rawMeta = getrawmetatable(game)
local oldNamecall = rawMeta.__namecall
setreadonly(rawMeta, false)

rawMeta.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    local isFire = (method == "FireServer" or method == "fireServer")
    local isInvoke = (method == "InvokeServer" or method == "invokeServer")

    if IsRecording and (isFire or isInvoke) then
        task.spawn(function()
            local currentTime = os.clock()
            local timeDelay = (LastRecordTime == 0) and 0 or (currentTime - LastRecordTime)
            LastRecordTime = currentTime

            local processedArgs = {}
            for i, arg in ipairs(args) do
                table.insert(processedArgs, serializeArg(arg))
            end
            
            table.insert(MacroData, {
                RemotePath = self:GetFullName(),
                Type = isInvoke and "Invoke" or "Fire",
                Delay = timeDelay,
                Args = processedArgs
            })
            
            local actionType = isInvoke and "Invoke" or "Fire"
            
            Library:Notify({
                Title = "Recorded Action",
                Content = actionType .. " -> " .. self.Name,
                Time = 1.5
            })
        end)
    end

    return oldNamecall(self, ...)
end)

setreadonly(rawMeta, true)

-- --------------------------------------------------
-- UI Controls
-- --------------------------------------------------

-- ⚡ BUTTON: Force Upgrade Active UI
Tabs.Macro:CreateButton({
    Title = "⚡ Force Click Upgrade Button (คลิกอัพเกรดบน UI)",
    Callback = function()
        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not pGui then return end

        local clicked = false
        for _, descendant in ipairs(pGui:GetDescendants()) do
            if descendant:IsA("GuiButton") and (descendant.Name:lower():find("upgrade") or descendant.Parent.Name:lower():find("upgrade")) then
                if descendant.Visible and descendant.AbsoluteSize.X > 0 then
                    clickGuiObject(descendant)
                    clicked = true
                    Library:Notify({ Title = "Senzy Hub", Content = "กดปุ่มอัพเกรดบน UI เรียบร้อย!", Time = 2 })
                    break
                end
            end
        end

        if not clicked then
            Library:Notify({ Title = "Senzy Hub", Content = "ไม่พบปุ่ม Upgrade บนหน้าจอ!", Time = 2 })
        end
    end
})

-- ⏭️ TOGGLE: Auto Next
Tabs.Macro:CreateToggle({
    Title = "⏭️ Auto Next (ไปด่านถัดไปอัตโนมัติ)",
    Default = false,
    Callback = function(Value)
        AutoNextEnabled = Value
        if AutoNextEnabled then
            Library:Notify({ Title = "Senzy Hub", Content = "เปิดใช้งาน Auto Next", Time = 3 })
            
            task.spawn(function()
                while AutoNextEnabled do
                    local remote = getReliableRemote()
                    if remote then
                        pcall(function()
                            remote:FireServer(buffer.fromstring("\004"), buffer.fromstring("\254\000\000"))
                        end)
                    end
                    task.wait(AutoNextDelay)
                end
            end)
        else
            Library:Notify({ Title = "Senzy Hub", Content = "ปิดใช้งาน Auto Next", Time = 3 })
        end
    end
})

Tabs.Macro:CreateSlider({
    Title = "⏱️ หน่วงเวลา Auto Next (วินาที)",
    Min = 3,
    Max = 30,
    Default = 8,
    Rounding = 0,
    Callback = function(Value) AutoNextDelay = Value end
})

local CreateInput = Tabs.Macro:CreateInput({
    Title = "ชื่อไฟล์มาโครใหม่",
    Placeholder = "พิมพ์ชื่อไฟล์ที่นี่...",
    Default = "MyMacro",
    Callback = function(Value) NewFileName = Value ~= "" and Value or "MyMacro" end
})

local MacroDropdown

Tabs.Macro:CreateButton({
    Title = "➕ สร้างไฟล์มาโคร",
    Callback = function()
        local name = (CreateInput and CreateInput.Value and CreateInput.Value ~= "") and CreateInput.Value or NewFileName
        local filePath = FolderName .. "/" .. name .. ".json"
        
        writefile(filePath, HttpService:JSONEncode({}))
        if MacroDropdown and MacroDropdown.Refresh then
            MacroDropdown:Refresh(getMacroFiles())
            MacroDropdown:Set(name)
        end
        SelectedMacro = name
        
        Library:Notify({ Title = "Senzy Hub", Content = "สร้างไฟล์เรียบร้อย!", Time = 3 })
    end
})

MacroDropdown = Tabs.Macro:CreateDropdown({
    Title = "เลือกไฟล์มาโคร",
    Values = getMacroFiles(),
    Default = "ไม่มีไฟล์เซฟ",
    Callback = function(Value) SelectedMacro = Value end
})

Tabs.Macro:CreateButton({
    Title = "🗑️ ลบไฟล์มาโครที่เลือก",
    Callback = function()
        if SelectedMacro == "" or SelectedMacro == "ไม่มีไฟล์เซฟ" then
            return Library:Notify({ Title = "Senzy Hub", Content = "กรุณาเลือกไฟล์ที่จะลบก่อน!", Time = 3 })
        end

        local filePath = FolderName .. "/" .. SelectedMacro .. ".json"
        if isfile and isfile(filePath) and delfile then
            delfile(filePath)
            local fileList = getMacroFiles()
            if MacroDropdown and MacroDropdown.Refresh then
                MacroDropdown:Refresh(fileList)
                SelectedMacro = fileList[1] or ""
                MacroDropdown:Set(SelectedMacro)
            end
            Library:Notify({ Title = "Senzy Hub", Content = "ลบไฟล์สำเร็จ!", Time = 3 })
        end
    end
})

Tabs.Macro:CreateToggle({
    Title = "🔴 Record Macro (เริ่ม / หยุดและบันทึก)",
    Default = false,
    Callback = function(Value)
        IsRecording = Value
        if IsRecording then
            if SelectedMacro == "" or SelectedMacro == "ไม่มีไฟล์เซฟ" then
                Library:Notify({ Title = "Senzy Hub", Content = "กรุณาเลือกไฟล์ก่อน!", Time = 3 })
                return
            end
            
            fixDynamicUINames()
            MacroData = {}
            LastRecordTime = 0
            Library:Notify({ Title = "Senzy Hub", Content = "เริ่มอัดมาโคร...", Time = 3 })
        else
            if #MacroData == 0 then
                Library:Notify({ Title = "Senzy Hub", Content = "ไม่มีข้อมูลที่จะบันทึก!", Time = 3 })
            else
                local filePath = FolderName .. "/" .. SelectedMacro .. ".json"
                writefile(filePath, HttpService:JSONEncode(MacroData))
                Library:Notify({ Title = "Senzy Hub", Content = "บันทึก " .. #MacroData .. " รายการเรียบร้อย!", Time = 3 })
            end
        end
    end
})

Tabs.Macro:CreateToggle({
    Title = "▶️ Auto Play Macro (เล่นมาโครวนซ้ำ)",
    Default = false,
    Callback = function(Value)
        IsPlaying = Value
        if IsPlaying then
            if SelectedMacro == "" or SelectedMacro == "ไม่มีไฟล์เซฟ" then
                Library:Notify({ Title = "Senzy Hub", Content = "กรุณาเลือกไฟล์ก่อน!", Time = 3 })
                return
            end
            
            local filePath = FolderName .. "/" .. SelectedMacro .. ".json"
            if not isfile(filePath) then
                Library:Notify({ Title = "Senzy Hub", Content = "ไม่พบไฟล์มาโคร!", Time = 3 })
                return
            end
            
            Library:Notify({ Title = "Senzy Hub", Content = "เริ่มเล่นมาโคร...", Time = 3 })
            
            task.spawn(function()
                while IsPlaying do
                    local success, rawData = pcall(function() return readfile(filePath) end)
                    if not success or not rawData then break end
                    
                    -- แก้จุดบั๊กเดิม: เปลี่ยนจาก JSONEncode เป็น JSONDecode
                    local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(rawData) end)
                    if not decodeSuccess or type(data) ~= "table" or #data == 0 then break end
                    
                    fixDynamicUINames()
                    
                    for i, action in ipairs(data) do
                        if not IsPlaying then break end
                        
                        local delayTime = action.Delay or 0.1
                        if delayTime > 0 then task.wait(delayTime) end
                        
                        local remoteObj = game
                        if action.RemotePath then
                            for pathPart in string.gmatch(action.RemotePath, "[^%.]+") do
                                if pathPart ~= "game" then
                                    remoteObj = remoteObj and remoteObj:FindFirstChild(pathPart)
                                end
                            end
                        end
                        
                        if remoteObj then
                            local fireArgs = {}
                            for _, argObj in ipairs(action.Args or {}) do
                                table.insert(fireArgs, deserializeArg(argObj))
                            end
                            
                            pcall(function()
                                if action.Type == "Invoke" and remoteObj:IsA("RemoteFunction") then
                                    remoteObj:InvokeServer(unpack(fireArgs))
                                elseif remoteObj:IsA("RemoteEvent") then
                                    remoteObj:FireServer(unpack(fireArgs))
                                end
                            end)
                        end
                    end
                    
                    if IsPlaying then
                        task.wait(PlayLoopDelay)
                    end
                end
                Library:Notify({ Title = "Senzy Hub", Content = "หยุดเล่นมาโครแล้ว!", Time = 3 })
            end)
        end
    end
})

Tabs.Macro:CreateSlider({
    Title = "⏱️ พักหลังเล่นจบ 1 รอบ (วินาที)",
    Min = 1,
    Max = 15,
    Default = 3,
    Rounding = 0,
    Callback = function(Value) PlayLoopDelay = Value end
})

Tabs.Settings:CreateToggle({
    Title = "⚙️ Auto Fix Dynamic UI Names",
    Default = true,
    Callback = function(Value) AutoFixUI = Value end
})

Window:SelectTab(1)
