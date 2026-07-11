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

task.wait(0.5)

-- ====== หา GUI ตัวใหม่ที่เพิ่งโผล่มา (คือของ Fluent) ======
local fluentGui = nil
for _, g in pairs(CoreGui:GetChildren()) do
	if g:IsA("ScreenGui") and not existingGuis[g] then
		fluentGui = g
		break
	end
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
	if fluentGui then
		fluentGui.Enabled = uiVisible
	else
		for _, g in pairs(CoreGui:GetChildren()) do
			if g:IsA("ScreenGui") and not existingGuis[g] and g.Name ~= "SenzyIcon" then
				fluentGui = g
				fluentGui.Enabled = uiVisible
				break
			end
		end
	end
end)

-- ====== 🛠️ การตั้งค่าระบบ Auto Parry (จากโค้ดล่าสุดของมึง) ======
local BALL_NAME = "BallShadow" 
local EXCLUSIVE_RADIUS = 10  
local PARRY_COOLDOWN = 0.3    
local RING_COLOR = Color3.new(1, 0, 0) 

local lastParryTime = 0
local hasParriedThisTarget = false
local ballPositions = {} 
local autoParryEnabled = false
local parryConnection = nil

local VisualRing = Instance.new("CylinderHandleAdornment")
VisualRing.Name = "LocalParryRangeVisual"
VisualRing.Color3 = RING_COLOR
VisualRing.Transparency = 0.8
VisualRing.Radius = EXCLUSIVE_RADIUS 
VisualRing.Height = 0.2 
VisualRing.Angle = 360
VisualRing.AlwaysOnTop = true 
VisualRing.Parent = CoreGui

local function tryParry()
	local now = tick()
	if now - lastParryTime < PARRY_COOLDOWN then return end
	lastParryTime = now
	hasParriedThisTarget = true

	local VirtualInputManager = game:GetService("VirtualInputManager")
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
	task.wait(0.02)
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

local function startAutoParry()
	if parryConnection then return end
	parryConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		if dt <= 0 then dt = 0.001 end 

		local character = game.Players.LocalPlayer.Character
		if not character then 
			VisualRing.Adornee = nil
			return 
		end
		
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then 
			VisualRing.Adornee = nil
			return 
		end

		VisualRing.Adornee = hrp
		VisualRing.CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(math.rad(90), 0, 0)
		VisualRing.Radius = EXCLUSIVE_RADIUS 

		local realBall = nil
		local closestDistance = 99999

		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj.Name == BALL_NAME and obj:IsA("BasePart") and not obj:IsDescendantOf(character) then
				local currentPos = obj.Position
				local lastPos = ballPositions[obj]
				
				local speed = 0
				local isMovingTowardsUs = false
				
				if lastPos then
					local displacement = currentPos - lastPos
					speed = displacement.Magnitude / dt
					
					if speed > 15 then
						local moveDirection = displacement.Unit
						local toPlayer = (hrp.Position - currentPos).Unit
						if moveDirection:Dot(toPlayer) > 0 then
							isMovingTowardsUs = true
						end
					end
				end
				
				ballPositions[obj] = currentPos

				if isMovingTowardsUs then
					local distance = Vector2.new(hrp.Position.X - currentPos.X, hrp.Position.Z - currentPos.Z).Magnitude
					if distance < closestDistance then
						closestDistance = distance
						realBall = obj
					end
				end
			end
		end

		for obj, _ in pairs(ballPositions) do
			if not obj or not obj:IsDescendantOf(workspace) then
				ballPositions[obj] = nil
			end
		end

		if not realBall then
			hasParriedThisTarget = false
			return 
		end

		if closestDistance > (EXCLUSIVE_RADIUS + 2) then
			hasParriedThisTarget = false
		end

		if closestDistance <= EXCLUSIVE_RADIUS and not hasParriedThisTarget then
			tryParry()
		end
	end)
end

local function stopAutoParry()
	if parryConnection then
		parryConnection:Disconnect()
		parryConnection = nil
	end
	VisualRing.Adornee = nil
	ballPositions = {}
end

-- ====== ระบบ Auto Walk ======
local player = game.Players.LocalPlayer
local autoWalkEnabled = false
local walkConnection = nil

local function checkStandingOnPlatform(character)
	local ok, platform = pcall(function()
		return workspace["New Lobby"].Lobby.Build:GetChildren()[38]["Meshes/Platform_Cube.012 (1)"]
	end)
	
	if not ok or not platform or not platform:IsA("BasePart") then
		return false
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = {character}
	
	local parts = workspace:GetPartsInPart(platform, overlapParams)
	return #parts > 0
end

local function getReadyZonePosition()
	local ok, target = pcall(function()
		return workspace["New Lobby"].ReadyArea.ReadyZone
	end)
	if not ok or not target then
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
		
		if not checkStandingOnPlatform(character) then
			humanoid:Move(Vector3.new(0,0,0))
			return
		end
		
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

-- ====== 🔘 ปุ่มสลับ เปิด/ปิด บนหน้าต่าง UI ======

-- 1. ปุ่มสำหรับระบบ Auto Walk
local AutoWalkToggle = Tabs.Farm:AddToggle("AutoWalkToggle", {
	Title = "Auto Walk to ReadyZone",
	Description = "เดินเฉพาะตอนอยู่บน Platform เท่านั้น",
	Default = false,
})

AutoWalkToggle:OnChanged(function()
	autoWalkEnabled = AutoWalkToggle.Value
	if autoWalkEnabled then
		startAutoWalk()
	else
		stopAutoWalk()
	end
end)

-- 2. ปุ่มสำหรับระบบ Auto Parry (เวอร์ชันที่มึงอัปเดตมา)
local AutoParryToggle = Tabs.Farm:AddToggle("AutoParryToggle", {
	Title = "Auto Parry (10 Studs)",
	Description = "เปิด-ปิด ระบบตีบอลอัตโนมัติเมื่อบอลเข้าวงแดง",
	Default = false,
})

AutoParryToggle:OnChanged(function()
	autoParryEnabled = AutoParryToggle.Value
	if autoParryEnabled then
		startAutoParry()
	else
		stopAutoParry()
	end
end)

-- รีเซ็ตค่าหากตัวละครตายแล้วเกิดใหม่/หายไป
player.CharacterRemoving:Connect(function()
	VisualRing.Adornee = nil
	ballPositions = {}
end)

player.CharacterAdded:Connect(function()
	if autoWalkEnabled then
		stopAutoWalk()
		task.wait(1)
		startAutoWalk()
	end
	if autoParryEnabled then
		stopAutoParry()
		task.wait(0.5)
		startAutoParry()
	end
end)
