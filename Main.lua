local CoreGui = game:GetService("CoreGui")

-- ====== บันทึก GUI ที่มีอยู่ก่อน (ก่อนโหลด Fluent) ======
local existingGuis = {}
for _, g in pairs(CoreGui:GetChildren()) do
	existingGuis[g] = true
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
	Title = "SENZY HUB",
	SubTitle = "",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Theme = "Darker"
})

local Tabs = {
	Farm = Window:AddTab({ Title = "Auto", Icon = "zap" })
}

local Options = Fluent.Options

task.wait(0.5) -- รอให้ Fluent สร้าง GUI เสร็จสมบูรณ์ก่อน

-- ====== หา GUI ตัวใหม่ที่เพิ่งโผล่มา (คือของ Fluent) ======
local fluentGui = nil
for _, g in pairs(CoreGui:GetChildren()) do
	if g:IsA("ScreenGui") and not existingGuis[g] then
		fluentGui = g
		print("เจอ Fluent GUI ชื่อ:", g.Name)
		break
	end
end

if not fluentGui then
	warn("ยังหา Fluent GUI ไม่เจอ อาจจะสร้างช้ากว่านี้ ลองเพิ่ม task.wait()")
end

-- ====== ไอคอนลอยสำหรับเปิด/ปิด UI ======
local IconGui = Instance.new("ScreenGui")
IconGui.Name = "SenzyIcon"
IconGui.ResetOnSpawn = false
IconGui.Parent = CoreGui

local IconButton = Instance.new("ImageButton")
IconButton.Name = "ToggleIcon"
IconButton.Size = UDim2.fromOffset(50, 50)
IconButton.Position = UDim2.fromOffset(20, 100)
IconButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
IconButton.BackgroundTransparency = 0.1
IconButton.Image = "rbxassetid://7733960981"
IconButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
IconButton.AutoButtonColor = true
IconButton.Draggable = true
IconButton.Active = true
IconButton.Parent = IconGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = IconButton

local uiVisible = true

IconButton.MouseButton1Click:Connect(function()
	uiVisible = not uiVisible
	print("กดไอคอน, uiVisible:", uiVisible, "| fluentGui:", fluentGui)

	if fluentGui then
		fluentGui.Enabled = uiVisible
	else
		-- ถ้ายังไม่เจอ ลองหาใหม่อีกรอบตอนกด
		for _, g in pairs(CoreGui:GetChildren()) do
			if g:IsA("ScreenGui") and not existingGuis[g] and g.Name ~= "SenzyIcon" then
				fluentGui = g
				fluentGui.Enabled = uiVisible
				print("เจอตอนกด:", g.Name)
				break
			end
		end
	end
end)

-- ====== ระบบ Auto Walk ======
local player = game.Players.LocalPlayer
local autoWalkEnabled = false
local walkConnection = nil

local function getReadyZonePosition()
	local ok, target = pcall(function()
		return workspace["New Lobby"].ReadyArea.ReadyZone
	end)
	if not ok or not target then
		warn("หา ReadyZone ไม่เจอ")
		return nil
	end
	if target:IsA("BasePart") then
		return target.Position
	elseif target:IsA("Model") then
		return target:GetPivot().Position
	end
	return nil
end

local function startAutoWalk()
	if walkConnection then return end
	walkConnection = game:GetService("RunService").Heartbeat:Connect(function()
		local character = player.Character
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not rootPart then return end
		local targetPos = getReadyZonePosition()
		if not targetPos then return end
		local distance = (rootPart.Position - targetPos).Magnitude
		if distance > 3 then
			humanoid:MoveTo(targetPos)
		end
	end)
end

local function stopAutoWalk()
	if walkConnection then
		walkConnection:Disconnect()
		walkConnection = nil
	end
end

local AutoWalkToggle = Tabs.Farm:AddToggle("AutoWalkToggle", {
	Title = "Auto Walk to ReadyZone",
	Description = "เดินไปที่ New Lobby > ReadyArea > ReadyZone อัตโนมัติ",
	Default = false,
})

AutoWalkToggle:OnChanged(function()
	autoWalkEnabled = AutoWalkToggle.Value
	if autoWalkEnabled then
		print("เปิด Auto Walk")
		startAutoWalk()
	else
		print("ปิด Auto Walk")
		stopAutoWalk()
	end
end)

player.CharacterAdded:Connect(function()
	if autoWalkEnabled then
		stopAutoWalk()
		task.wait(1)
		startAutoWalk()
	end
end)
