-- Class
local Utility = {};

-- Variables
local teleportService = cloneref(game:GetService("TeleportService"))
local tweenService = cloneref(game:GetService("TweenService"))
local playerService = cloneref(game:GetService("Players"))
local localPlayer = cloneref(playerService.localPlayer)
local camera = cloneref(workspace.CurrentCamera)

-- Functions
function Utility.getBodyParts()
    return {
        -- R6
        "Head",
        "Torso",
        "Left Arm",
        "Right Arm",
        "Left Leg",
        "Right Leg",
        -- R15
        "LeftFoot",
        "LeftHand",
        "LeftLowerArm",
        "LeftLowerLeg",
        "LeftUpperArm",
        "LeftUpperLeg",
        "LowerTorso",
        "RightFoot",
        "RightHand",
        "RightLowerArm",
        "RightLowerLeg",
        "RightUpperArm",
        "RightUpperLeg",
        "UpperTorso"
    }
end

function Utility.getCorners()
    return {
        Vector3.new(1, 1, 1),
        Vector3.new(-1, 1, 1),
        Vector3.new(1, 1, -1),
        Vector3.new(-1, 1, -1),
        Vector3.new(1, -1, 1),
        Vector3.new(-1, -1, 1),
        Vector3.new(1, -1, -1),
        Vector3.new(-1, -1, -1),
    }
end

function Utility.worldToScreen(world)
    local screen, isVisible = camera:WorldToViewportPoint(world)
    return Vector2.new(screen.X, screen.Y), isVisible, screen.Z
end

function Utility.floor2(vector2)
    assert(typeof(vector2) == "Vector2", "Vector2 hadn't been passed")
    return Vector2.new(math.floor(vector2.X), math.floor(vector2.Y))
end

function Utility.floor3(vector3)
    assert(typeof(vector3) == "Vector3", "Vector3 hadn't been passed")
    return Vector3.new(math.floor(vector3.X), math.floor(vector3.Y), math.floor(vector3.Z))
end

function Utility.abs2(vector2)
    assert(typeof(vector2) == "Vector2", "Vector2 hadn't been passed")
    return Vector2.new(math.abs(vector2.X), math.abs(vector2.Y))
end

function Utility.abs3(vector3)
    assert(typeof(vector3) == "Vector3", "Vector3 hadn't been passed")
    return Vector3.new(math.abs(vector3.X), math.abs(vector3.Y), math.abs(vector3.Z))
end

function Utility.forEach(containers: table, callback: (part: Instance) -> ()) -- Just for loop with get children
    assert(typeof(containers) == "table", "Container hadn't been passed")
    assert(typeof(callback) == "function", "Callback hadn't been passed")

    for _, container in containers do
        for _, item in container:GetChildren() do
            callback(item)
        end
    end
end

function Utility.forDescendant(containers: table, callback: (part: Instance) -> ()) -- Same as foreach but uses getdescendants
    assert(typeof(containers) == "table", "Container hadn't been passed")
    assert(typeof(callback) == "function", "Callback hadn't been passed")

    for _, container in containers do
        for _, item in container:GetDescendants() do
            callback(item)
        end 
    end
end

function Utility.getCharacterFromPlayer(player: Player) -- Just use this instead of return shit
    assert(typeof(player) == "Instance", "Player hadn't been passed")
    return player.Character or player.CharacterAdded:Wait()
end

function Utility.getTeam(player)
    return player.Team
end

function Utility.isFriendly(player)
    local team = Utility.getTeam(player)
    local localTeam = Utility.getTeam(localPlayer)
    return if team then team == localTeam else false
end

function Utility.getHealth(player)
    local character = Utility.getCharacterFromPlayer(player)
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        return humanoid.Health, humanoid.MaxHealth
    end
    return 0, 0
end

function Utility.getTorso(thing: Instance) -- Usage: getRootPart(localPlayer.Character)
    assert(typeof(thing) == "Instance", "Instance hadn't been passed")
    return thing:FindFirstChild("UpperTorso") or thing:FindFirstChild("Torso")
end

function Utility.getRootpart(thing: Instance) -- Usage: getRootPart(localPlayer.Character)
    assert(typeof(thing) == "Instance", "Instance hadn't been passed")
    return thing.PrimaryPart
end

function Utility.sortNearestTable(passedTable: table, object: Instance) -- Usage: sortNearestTable(thingsTable, localPlayer.Character.UpperTorso)
    assert(typeof(passedTable) == "table", "Table hadn't been passed")
    assert(typeof(object) == "Instance", "Object hadn't been passed")

    table.sort(passedTable, function(a, b)
        local pointADistance = (object.Position - a.Position).Magnitude
        local pointBDistance = (object.Position - b.Position).Magnitude
        return pointADistance < pointBDistance
    end)
end

function Utility.distanceBetweenPoints(pointA: Vector3, pointB: Vector3) -- Usage: distanceBetweenPoints(rootPart1.Position, rootPart2.Position)
    assert(typeof(pointA) == "Vector3", "Point A hadn't been passed")
    assert(typeof(pointB) == "Vector3", "Point B hadn't been passed")

    return (pointA - pointB).Magnitude
end

function Utility.hasItem(itemName: string) -- Instead of doing backpack:FindFirstChild() or character:FindFirstChild() just use this
    assert(typeof(itemName) == "string", "Item name hadn't been passed")

    local character = Utility.getCharacterFromPlayer(localPlayer)
    local backpack = localPlayer:FindFirstChild("Backpack")

    if backpack and character then
        return backpack:FindFirstChild(itemName) or character:FindFirstChild(itemName)
    end
end

function Utility.equipWeapon(toolThing: string, method: string) -- Usage: equipWeapon("Combat", "Name") or equipWeapon("Melee", "ToolTip")
    assert(typeof(toolThing) == "string", "Tool Name or ToolTip haven't been passsed")
    assert(typeof(method) == "string", "Method hadn't been passed")

    local character = Utility.getCharacterFromPlayer(localPlayer)
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    local backpack = localPlayer:FindFirstChild("Backpack")
    
    if method == "Name" then
        if Utility.hasItem("toolThing") then
            humanoid:EquipTool(backpack:FindFirstChild(toolThing))
        end
    elseif method == "ToolTip" then
        Utility.forEach(backpack, function(child)
            if child:IsA("Tool") and child.ToolTip == toolThing then
                humanoid:EquipTool(child)
            end
        end)
    else
        error("Invalid method had been passed, please use 'Name' or 'ToolTip'")
    end
end

function Utility.getClosest(containers: table, object: Instance) -- Usage: getClosest(characters, localPlayer.Character.UpperTorso)
    assert(typeof(containers) == "table", "Container hadn't been passed")
    assert(typeof(object) == "Instance", "Object hadn't been passed")

    local things = {}

    Utility.forEach(containers, function(child)
        if child:IsA("BasePart") then
            table.insert(things, child)
        end
    end)

    Utility.sortNearestTable(things, object)
    return things
end

function Utility.createTween(object: Instance, tweenInfo: TweenInfo, properties: table) -- Usage: playTween(rootPart, TweenInfo.new(1), {CFrame = rootPart.CFrame + Vector3.yAxis * 20})
    assert(typeof(object) == "Instance", "Object hadn't been passed")
    assert(typeof(tweenInfo) == "TweenInfo", "TweenInfo hadn't been passed")
    assert(typeof(properties) == "table", "Properties hadn't been passed")

    local tween = tweenService:Create(object, tweenInfo, properties)
    return tween
end

function Utility.spoofIndex(objects: table, properties: table, value: any) -- Usage: spoofIndex({humanoid}, {"WalkSpeed"}, 16)
    assert(typeof(objects) == "table", "Objects hadn't been passed")
    assert(typeof(properties) == "table", "Properties hadn't been passed")
    assert(value, "Value hadn't been passed")

    local index
    index = hookmetamethod(game, "__index", function(self, property, ...)
        local isValidProperty = table.find(properties, property)
        local isValidObject = table.find(objects, self)

        if isValidProperty and isValidObject then
            return value
        end

        return index(self, property, ...)
    end)
end

function Utility.spoofNameCall(objects: table, methods: table, callback: () -> ()) -- Usage: spoofNameCall({localPlayer}, {"Kick"}, function() return end))
    assert(typeof(objects) == "table", "Objects hadn't been passed")
    assert(typeof(methods) == "table", "Methods hadn't been passed")
    assert(typeof(callback) == "function", "Callback hadn't been passed")

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local isValidMethod = table.find(methods, getnamecallmethod())
        local isValidObject = table.find(objects, self)

        if isValidMethod and isValidObject then
            return callback()
        end
    
        return oldNamecall(self, ...)
    end)
end

function Utility.blockNameCall(objects: table, methods: table) -- Usage: blockNameCall({localPlayer}, {"Kick"})
    assert(typeof(objects) == "table", "Objects hadn't been passed")
    assert(typeof(methods) == "table", "Methods hadn't been passed")

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local isValidMethod = table.find(methods, getnamecallmethod())
        local isValidObject = table.find(objects, self)

        if isValidMethod and isValidObject then
            return
        end

        return oldNamecall(self, ...)
    end)
end

function Utility.rejoinServer()
    teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
end

function Utility.hopServer()
    teleportService:Teleport(game.PlaceId, localPlayer)
end

return Utility
