local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "DaHub | South Bronx: The Trenches",
    Icon = "pill",
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

local Tab2 = Window:CreateTab("Movement", 0)

Tab2:CreateDivider()

-- Undetectable Movement Speed
local movementSpeed = 16
local speedEnabled = false
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Function to apply undetectable movement speed using CFrame
local function applyMovement()
    while speedEnabled and humanoid and rootPart do
        local moveDirection = humanoid.MoveDirection
        if moveDirection.Magnitude > 0 then
            -- Use CFrame to move the player smoothly
            rootPart.CFrame = rootPart.CFrame + moveDirection * (movementSpeed * 0.1)
        end
        task.wait()
    end
end

-- Movement Speed Slider
Tab2:CreateSlider({
    Name = "Movement Speed",
    Range = {16, 25}, -- Max speed set to 25
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 16,
    Flag = "MovementSpeed",
    Callback = function(value)
        movementSpeed = value
        if speedEnabled then
            humanoid.WalkSpeed = movementSpeed
        end
    end,
})

-- Toggle for Movement Speed
Tab2:CreateToggle({
    Name = "Enable Movement Speed",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(value)
        speedEnabled = value
        if speedEnabled then
            humanoid.WalkSpeed = movementSpeed
        else
            humanoid.WalkSpeed = 16 -- Default speed
        end
    end,
})

-- New Tab for ESP
local Tab3 = Window:CreateTab("ESP", 0)

Tab3:CreateDivider()

-- Custom ESP Variables
local espEnabled = false
local showNames = true
local showChams = true
local showDistance = true
local showTool = true
local maxDistance = 500
local textColor = Color3.new(1, 1, 1)
local chamsColor = Color3.new(1, 0, 0)
local espObjects = {}

-- Function to create ESP for a player
local function createESP(player)
    if player == game.Players.LocalPlayer then return end -- Skip local player

    local character = player.Character
    if not character then return end

    -- Create ESP objects
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = 0.5
    highlight.FillColor = chamsColor -- Set the fill color for the chams
    highlight.OutlineColor = chamsColor
    highlight.OutlineTransparency = 0
    highlight.Parent = character

    local nameLabel = Instance.new("BillboardGui")
    nameLabel.Name = "ESP_Name"
    nameLabel.Adornee = character:FindFirstChild("Head")
    nameLabel.Size = UDim2.new(0, 200, 0, 50)
    nameLabel.StudsOffset = Vector3.new(0, 3.5, 0) -- Above the player
    nameLabel.AlwaysOnTop = true
    nameLabel.Parent = character

    local nameText = Instance.new("TextLabel", nameLabel)
    nameText.Text = player.Name
    nameText.TextColor3 = textColor
    nameText.TextSize = 7 -- Smaller text size
    nameText.BackgroundTransparency = 1
    nameText.Size = UDim2.new(1, 0, 1, 0)

    local distanceLabel = Instance.new("BillboardGui")
    distanceLabel.Name = "ESP_Distance"
    distanceLabel.Adornee = character:FindFirstChild("HumanoidRootPart")
    distanceLabel.Size = UDim2.new(0, 200, 0, 50)
    distanceLabel.StudsOffset = Vector3.new(0, -4.0, 0) -- Below the player
    distanceLabel.AlwaysOnTop = true
    distanceLabel.Parent = character

    local distanceText = Instance.new("TextLabel", distanceLabel)
    distanceText.Text = "0 studs"
    distanceText.TextColor3 = textColor
    distanceText.TextSize = 7 -- Smaller text size
    distanceText.BackgroundTransparency = 1
    distanceText.Size = UDim2.new(1, 0, 1, 0)

    local toolLabel = Instance.new("BillboardGui")
    toolLabel.Name = "ESP_Tool"
    toolLabel.Adornee = character:FindFirstChild("HumanoidRootPart")
    toolLabel.Size = UDim2.new(0, 200, 0, 50)
    toolLabel.StudsOffset = Vector3.new(0, -5.5, 0) -- Below the distance
    toolLabel.AlwaysOnTop = true
    toolLabel.Parent = character

    local toolText = Instance.new("TextLabel", toolLabel)
    toolText.Text = "Tool: None"
    toolText.TextColor3 = textColor
    toolText.TextSize = 7 -- Smaller text size
    toolText.BackgroundTransparency = 1
    toolText.Size = UDim2.new(1, 0, 1, 0)

    -- Store ESP objects
    espObjects[player] = {
        Highlight = highlight,
        NameLabel = nameLabel,
        NameText = nameText,
        DistanceLabel = distanceLabel,
        DistanceText = distanceText,
        ToolLabel = toolLabel,
        ToolText = toolText
    }
end

-- Function to update ESP
local function updateESP()
    for player, esp in pairs(espObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance <= maxDistance then
                -- Update distance
                esp.DistanceText.Text = math.floor(distance) .. " studs"

                -- Update tool
                local tool = player.Character:FindFirstChildOfClass("Tool")
                esp.ToolText.Text = "Tool: " .. (tool and tool.Name or "None")

                -- Update colors
                esp.NameText.TextColor3 = textColor
                esp.DistanceText.TextColor3 = textColor
                esp.ToolText.TextColor3 = textColor
                esp.Highlight.FillColor = chamsColor -- Update chams fill color
                esp.Highlight.OutlineColor = chamsColor

                -- Toggle visibility
                esp.Highlight.Enabled = showChams and espEnabled
                esp.NameLabel.Enabled = showNames and espEnabled
                esp.DistanceLabel.Enabled = showDistance and espEnabled
                esp.ToolLabel.Enabled = showTool and espEnabled
            else
                -- Hide ESP if player is beyond max distance
                esp.Highlight.Enabled = false
                esp.NameLabel.Enabled = false
                esp.DistanceLabel.Enabled = false
                esp.ToolLabel.Enabled = false
            end
        else
            -- Clean up if player leaves or character is invalid
            esp.Highlight:Destroy()
            esp.NameLabel:Destroy()
            esp.DistanceLabel:Destroy()
            esp.ToolLabel:Destroy()
            espObjects[player] = nil
        end
    end
end

-- Function to initialize ESP for all players
local function initializeESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        createESP(player)
    end
end

-- Toggle for ESP
Tab3:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(value)
        espEnabled = value
        if espEnabled then
            initializeESP()
        else
            for _, esp in pairs(espObjects) do
                esp.Highlight:Destroy()
                esp.NameLabel:Destroy()
                esp.DistanceLabel:Destroy()
                esp.ToolLabel:Destroy()
            end
            espObjects = {}
        end
    end,
})

-- Toggle for Names
Tab3:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Flag = "ShowNames",
    Callback = function(value)
        showNames = value
        updateESP()
    end,
})

-- Toggle for Chams
Tab3:CreateToggle({
    Name = "Show Chams",
    CurrentValue = true,
    Flag = "ShowChams",
    Callback = function(value)
        showChams = value
        updateESP()
    end,
})

-- Toggle for Distance
Tab3:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Flag = "ShowDistance",
    Callback = function(value)
        showDistance = value
        updateESP()
    end,
})

-- Toggle for Tool
Tab3:CreateToggle({
    Name = "Show Tool",
    CurrentValue = true,
    Flag = "ShowTool",
    Callback = function(value)
        showTool = value
        updateESP()
    end,
})

-- Max Distance Slider
Tab3:CreateSlider({
    Name = "Max Distance",
    Range = {50, 1000},
    Increment = 10,
    Suffix = " studs",
    CurrentValue = 500,
    Flag = "MaxDistance",
    Callback = function(value)
        maxDistance = value
        updateESP()
    end,
})

-- Color Picker for Text
Tab3:CreateColorPicker({
    Name = "Text Color",
    Color = textColor, -- Sync with the current text color
    Flag = "TextColor",
    Callback = function(value)
        textColor = value
        updateESP()
    end,
})

-- Color Picker for Chams
Tab3:CreateColorPicker({
    Name = "Chams Color",
    Color = chamsColor, -- Sync with the current chams color
    Flag = "ChamsColor",
    Callback = function(value)
        chamsColor = value
        updateESP()
    end,
})

-- Listen for new players
game.Players.PlayerAdded:Connect(function(player)
    if espEnabled then
        createESP(player)
    end
end)

-- Listen for player removal
game.Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        espObjects[player].Highlight:Destroy()
        espObjects[player].NameLabel:Destroy()
        espObjects[player].DistanceLabel:Destroy()
        espObjects[player].ToolLabel:Destroy()
        espObjects[player] = nil
    end
end)

-- Update ESP in real-time
game:GetService("RunService").RenderStepped:Connect(function()
    if espEnabled then
        updateESP()
    end
end)

-- Load configuration and sync colors
pcall(function()
    Rayfield:LoadConfiguration()
    -- Sync color pickers with current values
    Tab3:UpdateColorPicker("TextColor", textColor)
    Tab3:UpdateColorPicker("ChamsColor", chamsColor)
end)