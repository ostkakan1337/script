local funcs = loadstring(game:HttpGet("https://raw.githubusercontent.com/ostkakan1337/script/refs/heads/main/functions.lua"))()
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ostkakan1337/script/refs/heads/main/ui.lua"))()
local Wait = library.subs.Wait -- Only returns if the GUI has not been terminated. For 'while Wait() do' loops

local PepsisWorld = library:CreateWindow({
    Name = "DaHub | Fisch",
    Themeable = {
        Info = "by sparvish"
    }
})

local GeneralTab = PepsisWorld:CreateTab({
    Name = "Main"
})

local InformationSection = GeneralTab:CreateSection({
    Name = "Information"
})

InformationSection:AddButton({
    Name = "Discord",
    Callback = function()
        setclipboard("https://discord.gg/yourserver")
        library:Notify({
            Title = "Join Discord",
            Content = "Discord invite copied to clipboard!",
            Duration = 5,
            Type = "Success"
        })
    end
})

InformationSection:AddButton({
    Name = "Unload Script",
    Callback = function()
        library:Unload();
    end
})

local AutoFishingSection = GeneralTab:CreateSection({
    Name = "Auto Fishing",
    Side = 'Right'
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

AutoFishingSection:AddToggle({
    Name = "Auto Cast",
    Flag = "AutoFishingSection_AutoCast",
    Callback = function(Value)
        AutoCast = Value
        if AutoCast then
            task.spawn(AutoFish)
        end
    end
})

AutoFishingSection:AddToggle({
    Name = "Auto Shake",
    Flag = "AutoFishingSection_AutoShake",
    Callback = function(Value)
        autoShake = Value
        if autoShake then
            task.spawn(AutoShakeFunction)
        end
    end
})

AutoFishingSection:AddToggle({
    Name = "Auto Reel",
    Flag = "AutoFishingSection_AutoReel",
    Callback = function(Value)
        autoReel = Value
        if autoReel then
            task.spawn(AutoReelFunction)
        end
    end
})

local SellAllSection = GeneralTab:CreateSection({
    Name = "Sell All"
})

SellAllSection:AddButton({
    Name = "Sell All Fish",
    Callback = function()
        local merchant = workspace.world.npcs["Marc Merchant"]
        if merchant and merchant:FindFirstChild("merchant") then
            local sellAllFunction = merchant.merchant:FindFirstChild("sellall")
            if sellAllFunction and sellAllFunction:IsA("RemoteFunction") then
                sellAllFunction:InvokeServer()
                library:Notify({
                    Title = "Sell All",
                    Content = "All fish have been sold!",
                    Duration = 5,
                    Type = "Success"
                })
            else
                library:Notify({
                    Title = "Error",
                    Content = "SellAll function not found.",
                    Duration = 5,
                    Type = "Error"
                })
            end
        else
            library:Notify({
                Title = "Error",
                Content = "Marc Merchant not found.",
                Duration = 5,
                Type = "Error"
            })
        end
    end
})

local TeleportationTab = PepsisWorld:CreateTab({
    Name = "Teleportation"
})

local TeleportationSection = TeleportationTab:CreateSection({
    Name = "Teleportation"
})

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

local selectedZone = ZoneNames[1] or "Moosewood"
local selectedRod = RodNames[1] or "Heaven Rod"

TeleportationSection:AddDropdown({
    Name = "Select Zone",
    List = ZoneNames, -- Change from "Options" to "List"
    Default = selectedZone,
    Callback = function(Value)
        selectedZone = Value
    end
})

TeleportationSection:AddButton({
    Name = "Teleport to Selected Zone",
    Callback = function()
        local zoneCFrame = TeleportLocations['Zones'][selectedZone]
        if zoneCFrame then
            game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = zoneCFrame
            library:Notify({
                Title = "Teleport",
                Content = "Teleported to " .. selectedZone,
                Duration = 5,
                Type = "Success"
            })
        else
            library:Notify({
                Title = "Error",
                Content = "Invalid zone selected.",
                Duration = 5,
                Type = "Error"
            })
        end
    end
})

TeleportationSection:AddDropdown({
    Name = "Select Rod Location",
    List = RodNames, -- Change from "Options" to "List"
    Default = selectedRod,
    Callback = function(Value)
        selectedRod = Value
    end
})

TeleportationSection:AddButton({
    Name = "Teleport to Selected Rod",
    Callback = function()
        local rodCFrame = TeleportLocations['Rods'][selectedRod]
        if rodCFrame then
            game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = rodCFrame
            library:Notify({
                Title = "Teleport",
                Content = "Teleported to " .. selectedRod,
                Duration = 5,
                Type = "Success"
            })
        else
            library:Notify({
                Title = "Error",
                Content = "Invalid rod location selected.",
                Duration = 5,
                Type = "Error"
            })
        end
    end
})

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

TeleportationSection:Divider()

TeleportationSection:AddDropdown({
    Name = "Select Spawn Location",
    List = spawnNames, -- Change from "Options" to "List"
    Default = selectedSpawn,
    Callback = function(Value)
        selectedSpawn = Value
    end
})

TeleportationSection:AddButton({
    Name = "Teleport to Selected Spawn",
    Callback = function()
        local spawnIndex = spawnLocations[selectedSpawn]
        if spawnIndex then
            local spawnFolder = workspace.world.spawns[selectedSpawn]
            if spawnFolder and #spawnFolder:GetChildren() >= spawnIndex then
                local spawnPart = spawnFolder:GetChildren()[spawnIndex]
                if spawnPart and spawnPart:IsA("BasePart") then
                    game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = spawnPart.CFrame
                    library:Notify({
                        Title = "Teleport",
                        Content = "Teleported to " .. selectedSpawn,
                        Duration = 5,
                        Type = "Success"
                    })
                else
                    library:Notify({
                        Title = "Error",
                        Content = "Invalid spawn part.",
                        Duration = 5,
                        Type = "Error"
                    })
                end
            else
                library:Notify({
                    Title = "Error",
                    Content = "Spawn folder or part not found.",
                    Duration = 5,
                    Type = "Error"
                })
            end
        else
            library:Notify({
                Title = "Error",
                Content = "Invalid spawn location selected.",
                Duration = 5,
                Type = "Error"
            })
        end
    end
})

pcall(function()
    library:LoadConfiguration()
end)