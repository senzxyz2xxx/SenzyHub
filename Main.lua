local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
	Title = "SENZY HUB",
	SubTitle = "",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Theme = "Darker"
})

local Tabs = {
	Farm = Window:AddTab({ Title = "Farm", Icon = "zap" })
}

local Options = Fluent.Options

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
	if walkConnection then return end -- กันเปิดซ้ำ

	walkConnection = game:GetService("RunService").Heartbeat:Connect(function()
		local character = player.Character
		if not character then return end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not rootPart then return end

		local targetPos = getReadyZonePosition()
		if not targetPos then return end

		-- ถ้ายังไปไม่ถึง ให้สั่ง MoveTo ซ้ำเรื่อยๆ (กันเคสโดนดันหลุด)
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

-- ====== ปุ่ม Toggle ใน UI ======
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

-- รีเซ็ตอัตโนมัติเมื่อ character ตายแล้วเกิดใหม่ (กัน error)
player.CharacterAdded:Connect(function()
	if autoWalkEnabled then
		stopAutoWalk()
		task.wait(1) -- รอ character โหลดเสร็จ
		startAutoWalk()
	end
end)
