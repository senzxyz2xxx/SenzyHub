local Games = {
    [107653945083776] = "https://raw.githubusercontent.com/senzxyz2xxx/SenzyHub/refs/heads/main/senzyhub1.lua"
}

local currentPlaceId = game.PlaceId
local scriptUrl = Games[currentPlaceId]

if scriptUrl then
    loadstring(game:HttpGet(scriptUrl))()
else
    local StarterGui = game:GetService("StarterGui")
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Senzy Hub",
            Text = "Game not supported! (Place ID: " .. tostring(currentPlaceId) .. ")",
            Duration = 5
        })
    end)
    warn("[Senzy Hub] Unsupported Game Place ID:", currentPlaceId)
end
