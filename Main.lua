local LibraryLoaded, SenzyLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/senzxyz2xxx/Ui/refs/heads/main/main.lua"))()
end)

if not LibraryLoaded or not SenzyLib then
    warn("[DEBUG] ควยไม่ได้")
    return
end

print("[DEBUG] ได้")

local MainTab = nil
local Status, Err = pcall(function()
    MainTab = SenzyLib:CreateTab("Debug Test")
end)

if not Status then
    warn("[DEBUG] เอ๋อแล้ว: " .. tostring(Err))
    return
end

print("[DEBUG] สร้าง Tab")

MainTab:AddSection("🔍 Test Controls")

MainTab:AddButton(" Click  (Test Button)", function()
    print("[DEBUG] ปกติ")
    
    pcall(function()
        if SenzyLib.Notify then
            SenzyLib:Notify("Successfully", 2)
        end
    end)
end)

MainTab:AddToggle("🟢Test Toggle", false, function(Value)
    print("[DEBUG] 🔘Toggle State เปลี่ยนเป็น: " .. tostring(Value))
end)

MainTab:AddSlider("Test Slider", 1, 100, 50, function(Value)
    print("[DEBUG] Slider Value เปลี่ยนเป็น: " .. tostring(Value))
end)

print("[DEBUG] Debug ทำงาน")
