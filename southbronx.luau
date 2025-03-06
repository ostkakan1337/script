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
    Range = {16, 100},
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
    highlight.OutlineColor = Color3.new(1, 0, 0)
    highlight.OutlineTransparency = 0
    highlight.Parent = character

    local nameLabel = Instance.new("BillboardGui")
    nameLabel.Name = "ESP_Name"
    nameLabel.Adornee = character:FindFirstChild("Head")
    nameLabel.Size = UDim2.new(0, 200, 0, 50)
    nameLabel.StudsOffset = Vector3.new(0, 2, 0) -- Above the player
    nameLabel.AlwaysOnTop = true

    local nameText = Instance.new("TextLabel", nameLabel)
    nameText.Text = player.Name
    nameText.TextColor3 = Color3.new(1, 1, 1)
    nameText.TextSize = 14
    nameText.BackgroundTransparency = 1
    nameText.Size = UDim2.new(1, 0, 1, 0)
    nameText.Parent = nameLabel

    local distanceLabel = Instance.new("BillboardGui")
    distanceLabel.Name = "ESP_Distance"
    distanceLabel.Adornee = character:FindFirstChild("HumanoidRootPart")
    distanceLabel.Size = UDim2.new(0, 200, 0, 50)
    distanceLabel.StudsOffset = Vector3.new(0, -2, 0) -- Below the player
    distanceLabel.AlwaysOnTop = true

    local distanceText = Instance.new("TextLabel", distanceLabel)
    distanceText.Text = "0 studs"
    distanceText.TextColor3 = Color3.new(1, 1, 1)
    distanceText.TextSize = 14
    distanceText.BackgroundTransparency = 1
    distanceText.Size = UDim2.new(1, 0, 1, 0)
    distanceText.Parent = distanceLabel

    -- Store ESP objects
    espObjects[player] = {
        Highlight = highlight,
        NameLabel = nameLabel,
        DistanceLabel = distanceLabel
    }
end

-- Function to update ESP
local function updateESP()
    for player, esp in pairs(espObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Update distance
            local distance = (player.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            esp.DistanceLabel.TextLabel.Text = math.floor(distance) .. " studs"

            -- Toggle visibility
            esp.Highlight.Enabled = showChams and espEnabled
            esp.NameLabel.Enabled = showNames and espEnabled
            esp.DistanceLabel.Enabled = showDistance and espEnabled
        else
            -- Clean up if player leaves or character is invalid
            esp.Highlight:Destroy()
            esp.NameLabel:Destroy()
            esp.DistanceLabel:Destroy()
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
        espObjects[player] = nil
    end
end)

pcall(function()
    Rayfield:LoadConfiguration()
end)