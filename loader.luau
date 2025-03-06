local UniverseID = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://apis.roblox.com/universes/v1/places/"..game.PlaceId.."/universe")).universeId
if game.PlaceId == 16732694052 then

    loadstring(game:HttpGet("https://raw.githubusercontent.com/ostkakan1337/script/refs/heads/main/fisch.luau"))()

elseif game.PlaceId == 10179538382 then 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ostkakan1337/script/refs/heads/main/southbronx.luau"))()
elseif UniverseID == 1234  then 
    print("WIP")
else
    print("WIP")
end
