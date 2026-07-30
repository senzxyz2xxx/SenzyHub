-- --------------------------------------------------
-- Minimal UI Debug Test
-- --------------------------------------------------
local LibraryLoaded, SenzyLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/senzxyz2xxx/Ui/refs/heads/main/main.lua"))()
end)

if not LibraryLoaded or not SenzyLib then
    warn("[DEBUG] ❌ ไม่สามารถโหลด UI Library จาก URL ได้!")
    return
end

print("[DEBUG] ✅ โหลด UI Library สำเร็จ!")

-- 1. ทดสอบสร้าง Tabs
local MainTab = nil
local Status, Err = pcall(function()
    MainTab = SenzyLib:CreateTab("Debug Test")
end)

if not Status then
    warn("[DEBUG] ❌ เกิดข้อผิดพลาดในการสร้าง Tab: " .. tostring(Err))
    return
end

print("[DEBUG] ✅ สร้าง Tab สำเร็จ!")

-- 2. เพิ่ม Elements ใน Tab เพื่อทดสอบ Event/Callback
MainTab:AddSection("🔍 Test Controls")

MainTab:AddButton("🔴 Click Me (Test Button)", function()
    print("[DEBUG] 🔘 ปุ่ม Test Button ถูกกดใช้งานได้ปกติ!")
    
    -- ลองเรียกใช้ระบบ Notification ถ้ามี
    pcall(function()
        if SenzyLib.Notify then
            SenzyLib:Notify("Button Clicked Successfully!", 2)
        end
    end)
end)

MainTab:AddToggle("🟢 Test Toggle", false, function(Value)
    print("[DEBUG] 🔘 Toggle State เปลี่ยนเป็น: " .. tostring(Value))
end)

MainTab:AddSlider("⏱️ Test Slider", 1, 100, 50, function(Value)
    print("[DEBUG] 🔘 Slider Value เปลี่ยนเป็น: " .. tostring(Value))
end)

print("[DEBUG] 🚀 สคริปต์ Debug ทำงานสมบูรณ์แบบ! ให้ลองกดเล่นปุ่มบนหน้าจอแล้วเช็ค Output (F9)")
