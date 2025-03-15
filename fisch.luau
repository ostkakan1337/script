local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "DaHub | Fisch",
    Icon = "fish-symbol",
    LoadingTitle = "DaHub",
    LoadingSubtitle = "by sparvish",
    Theme = "Default",
    
    ConfigurationSaving = {
       Enabled = true,
       FileName = "DaHub"
    },
})

local Tab1 = Window:CreateTab("Main", 0)

Tab1:CreateDivider()

Tab1:CreateParagraph({
    Title = "Information",
    Content = "Welcome to DaHub! Stay updated with the latest features."
})

Tab1:CreateButton({
    Name = "Join Discord",
    Callback = function()
        setclipboard("https://discord.gg/yourserver")
        Rayfield:Notify({
            Title = "Discord",
            Content = "Discord invite copied to clipboard!",
            Duration = 5,
            Type = "Success"
        })
    end,
})

Tab1:CreateParagraph({
    Title = "Changelog",
    Content = "- Added Auto Cast, Auto Shake, and Auto Reel\n- Implemented Rayfield UI\n- More features coming soon!"
})

local autoShake = false
local autoReel = false
local AutoCast = false

local VirtualInputManager = game:GetService("VirtualInputManager")

local function AutoFish()
    while AutoCast do
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("events") then
                local castEvent = tool.events:FindFirstChild("cast")
                if castEvent then
                    castEvent:FireServer(math.random(90, 99))
                end
            end
        end
        task.wait(2)
    end
end

local function AutoShakeFunction()
    while autoShake do
        local PlayerGUI = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
        local shakeUI = PlayerGUI and PlayerGUI:FindFirstChild("shakeui")
        if shakeUI and shakeUI.Enabled then
            local button = shakeUI:FindFirstChild("safezone"):FindFirstChild("button")
            if button and button:IsA("ImageButton") and button.Visible then
                local pos, size = button.AbsolutePosition, button.AbsoluteSize
                VirtualInputManager:SendMouseButtonEvent(pos.X + size.X / 2, pos.Y + size.Y / 2, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(pos.X + size.X / 2, pos.Y + size.Y / 2, 0, false, game, 0)
            end
        end
        task.wait(0.3)
    end
end

local function AutoReelFunction()
    local reelfinishedEvent = game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished")
    while autoReel do
        task.wait(2)
        reelfinishedEvent:FireServer(100, false)
    end
end

local Tab2 = Window:CreateTab("Auto Features", 0)

Tab2:CreateDivider()

Tab2:CreateToggle({
    Name = "Auto Cast",
    Default = false,
    Callback = function(Value)
        AutoCast = Value
        if AutoCast then
            task.spawn(AutoFish)
        end
    end,
})

Tab2:CreateToggle({
    Name = "Auto Shake",
    Default = false,
    Callback = function(Value)
        autoShake = Value
        if autoShake then
            task.spawn(AutoShakeFunction)
        end
    end,
})

Tab2:CreateToggle({
    Name = "Auto Reel",
    Default = false,
    Callback = function(Value)
        autoReel = Value
        if autoReel then
            task.spawn(AutoReelFunction)
        end
    end,
})

-- Teleportation Tab
local Tab3 = Window:CreateTab("Teleportation", 0)

Tab3:CreateDivider()

local TeleportLocations = {
    ['Zones'] = {
        ['Moosewood'] = CFrame.new(379.875, 134.5, 233.549),
        ['Roslit Bay'] = CFrame.new(-1472.98, 132.52, 707.64),
        ['Forsaken Shores'] = CFrame.new(-2491.1, 133.25, 1561.29),
    },
    ['Rods'] = {
        ['Heaven Rod'] = CFrame.new(20025.05, -467.66, 7114.4),
        ['Summit Rod'] = CFrame.new(20213.33, 736.66, 5707.82),
        ['Kings Rod'] = CFrame.new(1380.83, -807.19, -304.22)
    }
}

local ZoneNames = {}
local RodNames = {}
for i, _ in pairs(TeleportLocations['Zones']) do table.insert(ZoneNames, i) end
for i, _ in pairs(TeleportLocations['Rods']) do table.insert(RodNames, i) end

-- Ensure Defaults Are Always Valid
local selectedZone = ZoneNames[1] or "Moosewood"
local selectedRod = RodNames[1] or "Heaven Rod"

Tab3:CreateDropdown({
    Name = "Select Zone",
    Options = ZoneNames,
    Default = selectedZone,
    Callback = function(Value)
        selectedZone = Value
    end,
})

Tab3:CreateButton({
    Name = "Teleport to Selected Zone",
    Callback = function()
        local zoneCFrame = TeleportLocations['Zones'][selectedZone]
        if zoneCFrame then
            game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = zoneCFrame
            Rayfield:Notify({
                Title = "Teleport",
                Content = "Teleported to " .. selectedZone,
                Duration = 5,
                Type = "Success"
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Invalid zone selected.",
                Duration = 5,
                Type = "Error"
            })
        end
    end,
})

Tab3:CreateDivider()

Tab3:CreateDropdown({
    Name = "Select Rod Location",
    Options = RodNames,
    Default = selectedRod,
    Callback = function(Value)
        selectedRod = Value
    end,
})

Tab3:CreateButton({
    Name = "Teleport to Selected Rod",
    Callback = function()
        local rodCFrame = TeleportLocations['Rods'][selectedRod]
        if rodCFrame then
            game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = rodCFrame
            Rayfield:Notify({
                Title = "Teleport",
                Content = "Teleported to " .. selectedRod,
                Duration = 5,
                Type = "Success"
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Invalid rod location selected.",
                Duration = 5,
                Type = "Error"
            })
        end
    end,
})

-- New Teleportation Feature for Specific Spawns
Tab3:CreateDivider()

local spawnLocations = {
    ["Abyssal Zenith"] = 5, -- Example: workspace.world.spawns["Abyssal Zenith"]:GetChildren()[5]
    ["Challengers Deep"] = 4, -- Example: workspace.world.spawns["Challengers Deep"]:GetChildren()[4]
    -- Add more locations as needed
}

local spawnNames = {}
for name, _ in pairs(spawnLocations) do
    table.insert(spawnNames, name)
end

local selectedSpawn = spawnNames[1] or "Abyssal Zenith"

Tab3:CreateDropdown({
    Name = "Select Spawn Location",
    Options = spawnNames,
    Default = selectedSpawn,
    Callback = function(Value)
        selectedSpawn = Value
    end,
})

Tab3:CreateButton({
    Name = "Teleport to Selected Spawn",
    Callback = function()
        local spawnIndex = spawnLocations[selectedSpawn]
        if spawnIndex then
            local spawnFolder = workspace.world.spawns[selectedSpawn]
            if spawnFolder and #spawnFolder:GetChildren() >= spawnIndex then
                local spawnPart = spawnFolder:GetChildren()[spawnIndex]
                if spawnPart and spawnPart:IsA("BasePart") then
                    game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = spawnPart.CFrame
                    Rayfield:Notify({
                        Title = "Teleport",
                        Content = "Teleported to " .. selectedSpawn,
                        Duration = 5,
                        Type = "Success"
                    })
                else
                    Rayfield:Notify({
                        Title = "Error",
                        Content = "Invalid spawn part.",
                        Duration = 5,
                        Type = "Error"
                    })
                end
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Spawn folder or part not found.",
                    Duration = 5,
                    Type = "Error"
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Invalid spawn location selected.",
                Duration = 5,
                Type = "Error"
            })
        end
    end,
})

-- Sell All Button
local Tab4 = Window:CreateTab("Sell All", 0)

Tab4:CreateDivider()

Tab4:CreateButton({
    Name = "Sell All Fish",
    Callback = function()
        local merchant = workspace.world.npcs["Marc Merchant"]
        if merchant and merchant:FindFirstChild("merchant") then
            local sellAllFunction = merchant.merchant:FindFirstChild("sellall")
            if sellAllFunction and sellAllFunction:IsA("RemoteFunction") then
                sellAllFunction:InvokeServer()
                Rayfield:Notify({
                    Title = "Sell All",
                    Content = "All fish have been sold!",
                    Duration = 5,
                    Type = "Success"
                })
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "SellAll function not found.",
                    Duration = 5,
                    Type = "Error"
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Marc Merchant not found.",
                Duration = 5,
                Type = "Error"
            })
        end
    end,
})

pcall(function()
    Rayfield:LoadConfiguration()
end)