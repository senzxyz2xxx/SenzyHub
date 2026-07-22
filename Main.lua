local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local MacroData = {}
local IsRecording = false
local SelectedMacro = ""
local NewFileName = "MyMacro"
local FolderName = "SenzyMacros"
local LastRecordTime = 0

if makefolder and not isfolder(FolderName) then
    makefolder(FolderName)
end

-- --------------------------------------------------
-- UI Fixer: เปลี่ยนชื่อ UI ที่เป็น GUID สุ่มให้เป็นชื่อคงที่
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
                print("[Senzy Hub] แก้ไขชื่อ UI เป็น:", FIXED_FRAME_NAME)
            end
        end
    end
end

task.spawn(function()
    while task.wait(1) do
        pcall(fixDynamicUINames)
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
-- UI Setup & Fluent Init
-- --------------------------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SENZY HUB",
    SubTitle = "Macro System (Enhanced)",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 520),
    Theme = "Darker"
})

local Tabs = {
    Macro = Window:AddTab({ Title = "Macro", Icon = "play" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- --------------------------------------------------
-- Universal Remote Hooking
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
            
            print("[Senzy Hub] บันทึก (" .. actionType .. "):", self.Name)
            
            Fluent:Notify({
                Title = "Recorded Action",
                Content = actionType .. " -> " .. self.Name,
                Duration = 1.5
            })
        end)
    end

    return oldNamecall(self, ...)
end)

setreadonly(rawMeta, true)

-- --------------------------------------------------
-- UI Buttons & Functions
-- --------------------------------------------------
local CreateInput = Tabs.Macro:AddInput("CreateNameInput", {
    Title = "ชื่อไฟล์มาโครใหม่",
    Default = "MyMacro",
    Placeholder = "พิมพ์ชื่อไฟล์ที่นี่...",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        NewFileName = Value ~= "" and Value or "MyMacro"
    end
})

local MacroDropdown

Tabs.Macro:AddButton({
    Title = "➕ สร้างไฟล์มาโคร",
    Callback = function()
        local name = CreateInput.Value ~= "" and CreateInput.Value or NewFileName
        local filePath = FolderName .. "/" .. name .. ".json"
        
        writefile(filePath, HttpService:JSONEncode({}))
        MacroDropdown:SetValues(getMacroFiles())
        MacroDropdown:SetValue(name)
        SelectedMacro = name
        
        Fluent:Notify({ Title = "Senzy Hub", Content = "สร้างไฟล์เรียบร้อย!", Duration = 3 })
    end
})

MacroDropdown = Tabs.Macro:AddDropdown("MacroSelect", {
    Title = "เลือกไฟล์มาโคร",
    Values = getMacroFiles(),
    Multi = false,
    Default = 1,
    Callback = function(Value) SelectedMacro = Value end
})

-- 🗑️ ปุ่มลบไฟล์มาโครที่เลือกอยู่
Tabs.Macro:AddButton({
    Title = "🗑️ ลบไฟล์มาโครที่เลือก",
    Callback = function()
        if SelectedMacro == "" or SelectedMacro == "ไม่มีไฟล์เซฟ" then
            return Fluent:Notify({ Title = "Senzy Hub", Content = "กรุณาเลือกไฟล์ที่จะลบก่อน!", Duration = 3 })
        end

        local filePath = FolderName .. "/" .. SelectedMacro .. ".json"
        if isfile and isfile(filePath) and delfile then
            delfile(filePath)
            
            -- อัปเดตรายชื่อใน Dropdown
            local fileList = getMacroFiles()
            MacroDropdown:SetValues(fileList)
            SelectedMacro = fileList[1] or ""
            MacroDropdown:SetValue(SelectedMacro)

            Fluent:Notify({ Title = "Senzy Hub", Content = "ลบไฟล์สำเร็จ!", Duration = 3 })
        else
            Fluent:Notify({ Title = "Senzy Hub", Content = "ไม่พบไฟล์ หรือ Executer ไม่รองรับการลบ", Duration = 3 })
        end
    end
})

Tabs.Macro:AddButton({
    Title = "🔴 Start Record (เริ่มอัด)",
    Callback = function()
        if SelectedMacro == "" or SelectedMacro == "ไม่มีไฟล์เซฟ" then
            return Fluent:Notify({ Title = "Senzy Hub", Content = "กรุณาเลือกไฟล์ก่อน!", Duration = 3 })
        end
        
        fixDynamicUINames()
        
        MacroData = {}
        LastRecordTime = 0
        IsRecording = true
        Fluent:Notify({ Title = "Senzy Hub", Content = "เริ่มอัด...", Duration = 3 })
    end
})

Tabs.Macro:AddButton({
    Title = "⏹️ Stop & Save Record",
    Callback = function()
        if not IsRecording then return end
        IsRecording = false
        
        if #MacroData == 0 then
            return Fluent:Notify({ Title = "Senzy Hub", Content = "ไม่มีข้อมูล!", Duration = 3 })
        end
        
        local filePath = FolderName .. "/" .. SelectedMacro .. ".json"
        writefile(filePath, HttpService:JSONEncode(MacroData))
        Fluent:Notify({ Title = "Senzy Hub", Content = "บันทึก " .. #MacroData .. " รายการแล้ว!", Duration = 3 })
    end
})

Tabs.Macro:AddButton({
    Title = "▶️ Play Macro",
    Callback = function()
        if SelectedMacro == "" or SelectedMacro == "ไม่มีไฟล์เซฟ" then return end
        local filePath = FolderName .. "/" .. SelectedMacro .. ".json"
        if not isfile(filePath) then return end
        
        local success, data = pcall(function() 
            return HttpService:JSONEncode(readfile(filePath)) 
        end)
        data = HttpService:JSONDecode(readfile(filePath))
        if not data or #data == 0 then return end
        
        fixDynamicUINames()
        
        Fluent:Notify({ Title = "Senzy Hub", Content = "เริ่มเล่นมาโคร...", Duration = 3 })
        
        task.spawn(function()
            for i, action in ipairs(data) do
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
                else
                    warn("[Senzy Hub] หา Remote ไม่พบจาก Path:", action.RemotePath)
                end
            end
            Fluent:Notify({ Title = "Senzy Hub", Content = "เล่นเสร็จสิ้น!", Duration = 3 })
        end)
    end
})

Window:SelectTab(1)
