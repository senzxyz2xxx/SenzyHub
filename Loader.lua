local Games = {
    [107653945083776] = "https://raw.githubusercontent.com/senzxyz2xxx/SenzyHub/refs/heads/main/Maps/senzyhub1.lua",
    [133294838637122] = "https://raw.githubusercontent.com/senzxyz2xxx/SenzyHub/refs/heads/main/Maps/JumpToStealSoccerPlayers.lua"
}

local currentPlaceId = game.PlaceId
local scriptUrl = Games[currentPlaceId]

if scriptUrl then
    local success, response = pcall(function()
        return game:HttpGet(scriptUrl)
    end)
    
    if success and response then
        local func, err = loadstring(response)
        if func then
            func()
        else
            warn("[Senzy Hub] Syntax Error :", err)
        end
    else
        warn("[Senzy Hub] Error (Check Network/URL):", response)
    end
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
