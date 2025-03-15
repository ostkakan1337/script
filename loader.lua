local HttpService = game:GetService("HttpService")
local PlaceId = game.PlaceId

print("Current PlaceId:", PlaceId)

local success, response = pcall(function()
    return HttpService:JSONDecode(game:HttpGet("https://apis.roblox.com/universes/v1/places/"..PlaceId.."/universe"))
end)

local UniverseID = success and response.universeId or nil

print("UniverseID:", UniverseID or "Failed to retrieve")

if PlaceId == 16732694052 then
    print("Loading fisch")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ostkakan1337/script/refs/heads/main/fisch.luau"))()
elseif PlaceId == 13643807539 then
    print("Loading south bronx")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ostkakan1337/script/refs/heads/main/southbronx.luau"))()
elseif UniverseID == 1234 then 
    print("WIP - Universe Match")
else
    print("WIP - No Match")
end