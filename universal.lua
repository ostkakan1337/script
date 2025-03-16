local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ostkakan1337/script/refs/heads/main/ui.lua"))()
shared.force_designer = true
local PepsisWorld = library:CreateWindow({
    Name = "DaHub | Fisch",
    Themeable = {
        Info = "by sparvish"
    }
})

-- Main Tab
local GeneralTab = PepsisWorld:CreateTab({
    Name = "Main"
})

local InformationSection = GeneralTab:CreateSection({
    Name = "Information"
})

InformationSection:AddButton({
    Name = "Join Discord",
    Callback = function()
        setclipboard("https://discord.gg/yourserver")
        library:Notify({
            Title = "Discord",
            Text = "Discord invite copied to clipboard!",
            Duration = 5,
            Type = "Success"
        })
    end
})

InformationSection:AddButton({
    Name = "Unload Script",
    Callback = function()
        library:Unload()
    end
})

-- ESP Tab
local ESPTab = PepsisWorld:CreateTab({
    Name = "ESP"
})

-- ESP Settings Section
local ESPSection = ESPTab:CreateSection({
    Name = "ESP Settings"
})

local ESP = {
    Enabled = false,
    TeamCheck = false,
    MaxDistance = 200,
    FontSize = 11,
    HealthBarEnabled = false,
    HealthPercentageEnabled = false,
    Drawing = {
        Boxes = { Enabled = false, Color = Color3.fromRGB(255, 255, 255), Style = "Dynamic" }, -- Default to Dynamic
        Names = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
        Distances = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
        Chams = { Enabled = false, FillColor = Color3.fromRGB(119, 120, 255), OutlineColor = Color3.fromRGB(119, 120, 255), OutlineTransparency = 1 } -- Outline off by default
    }
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
-- Function to calculate the 2D bounding box of a player's character
local function CalculateBoundingBox(Character)
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then
        print("RootPart is nil for character:", Character)
        return nil, nil
    end

    local Min, Max = RootPart.Position, RootPart.Position
    for _, Part in pairs(Character:GetChildren()) do
        if Part:IsA("BasePart") then
            local PartMin = Part.Position - Part.Size / 2
            local PartMax = Part.Position + Part.Size / 2
            Min = Vector3.new(math.min(Min.X, PartMin.X), math.min(Min.Y, PartMin.Y), math.min(Min.Z, PartMin.Z))
            Max = Vector3.new(math.max(Max.X, PartMax.X), math.max(Max.Y, PartMax.Y), math.max(Max.Z, PartMax.Z))
        end
    end

    local Corners = {
        Vector3.new(Min.X, Min.Y, Min.Z),
        Vector3.new(Max.X, Min.Y, Min.Z),
        Vector3.new(Min.X, Max.Y, Min.Z),
        Vector3.new(Max.X, Max.Y, Min.Z),
        Vector3.new(Min.X, Min.Y, Max.Z),
        Vector3.new(Max.X, Min.Y, Max.Z),
        Vector3.new(Min.X, Max.Y, Max.Z),
        Vector3.new(Max.X, Max.Y, Max.Z)
    }

    local ScreenMin, ScreenMax = Vector2.new(math.huge, math.huge), Vector2.new(-math.huge, -math.huge)
    for _, Corner in pairs(Corners) do
        local ScreenPos = Camera:WorldToViewportPoint(Corner)
        if ScreenPos and ScreenPos.Z > 0 then
            ScreenMin = Vector2.new(math.min(ScreenMin.X, ScreenPos.X), math.min(ScreenMin.Y, ScreenPos.Y))
            ScreenMax = Vector2.new(math.max(ScreenMax.X, ScreenPos.X), math.max(ScreenMax.Y, ScreenPos.Y))
        end
    end

    return ScreenMin, ScreenMax
end

-- Function to create ESP elements
local function CreateESP(Player)
    local Character = Player.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then
        print("Character or HumanoidRootPart is nil for player:", Player)
        return
    end

    -- Box ESP
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = ESP.Drawing.Boxes.Color
    Box.Thickness = 1 -- Thin lines
    Box.Filled = false -- Not filled (hollow)

    -- Name ESP
    local Name = Drawing.new("Text")
    Name.Visible = false
    Name.Color = ESP.Drawing.Names.Color
    Name.Size = ESP.FontSize
    Name.Text = Player.Name
    Name.Outline = true

    -- Distance ESP
    local Distance = Drawing.new("Text")
    Distance.Visible = false
    Distance.Color = ESP.Drawing.Distances.Color
    Distance.Size = ESP.FontSize
    Distance.Outline = true

    -- Health Bar
    local HealthBar = Drawing.new("Square")
    HealthBar.Visible = false
    HealthBar.Color = Color3.new(0, 1, 0) -- Green by default
    HealthBar.Thickness = 1
    HealthBar.Filled = true

    -- Health Percentage
    local HealthPercentage = Drawing.new("Text")
    HealthPercentage.Visible = false
    HealthPercentage.Color = Color3.new(1, 1, 1) -- White
    HealthPercentage.Size = ESP.FontSize
    HealthPercentage.Outline = true

    -- Chams
    local Chams = Instance.new("Highlight")
    Chams.Parent = Character
    Chams.FillColor = ESP.Drawing.Chams.FillColor
    Chams.OutlineColor = ESP.Drawing.Chams.OutlineColor
    Chams.OutlineTransparency = ESP.Drawing.Chams.OutlineTransparency
    Chams.Enabled = ESP.Drawing.Chams.Enabled

    -- Update ESP
    local RenderConnection
    RenderConnection = RunService.RenderStepped:Connect(function()
        if ESP.Enabled and Character and Character:FindFirstChild("HumanoidRootPart") then
            local RootPart = Character.HumanoidRootPart
            local Position, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
            if not Position then
                print("Position is nil for player:", Player)
                return
            end
            local DistanceFromPlayer = (Camera.CFrame.Position - RootPart.Position).Magnitude

            if OnScreen and DistanceFromPlayer <= ESP.MaxDistance then
                -- Calculate the bounding box based on the character's parts
                local ScreenMin, ScreenMax = CalculateBoundingBox(Character)
                if ScreenMin and ScreenMax then
                    local BoxSize = ScreenMax - ScreenMin
                    local BoxPosition = ScreenMin

                    -- Box ESP
                    if ESP.Drawing.Boxes.Enabled then
                        Box.Size = BoxSize
                        Box.Position = BoxPosition
                        Box.Visible = true
                    else
                        Box.Visible = false
                    end

                    -- Name ESP (to the right of the box)
                    if ESP.Drawing.Names.Enabled then
                        Name.Position = Vector2.new(BoxPosition.X + BoxSize.X + 5, BoxPosition.Y)
                        Name.Visible = true
                    else
                        Name.Visible = false
                    end

                    -- Distance ESP (below the name)
                    if ESP.Drawing.Distances.Enabled then
                        Distance.Position = Vector2.new(BoxPosition.X + BoxSize.X + 5, BoxPosition.Y + 15)
                        Distance.Text = tostring(math.floor(DistanceFromPlayer)) .. " studs"
                        Distance.Visible = true
                    else
                        Distance.Visible = false
                    end

                    -- Health Bar (to the left of the box)
                    if ESP.HealthBarEnabled then
                        local Humanoid = Character:FindFirstChild("Humanoid")
                        if Humanoid and Humanoid.Health > 0 then
                            local Health = Humanoid.Health
                            local MaxHealth = Humanoid.MaxHealth
                            local HealthRatio = Health / MaxHealth

                            HealthBar.Size = Vector2.new(5, BoxSize.Y * HealthRatio) -- Width: 5, Height: Proportional to health
                            HealthBar.Position = Vector2.new(BoxPosition.X - 10, BoxPosition.Y + BoxSize.Y - (BoxSize.Y * HealthRatio))
                            HealthBar.Color = Color3.new(1 - HealthRatio, HealthRatio, 0) -- Red to Green gradient
                            HealthBar.Visible = true
                        else
                            HealthBar.Visible = false
                        end
                    else
                        HealthBar.Visible = false
                    end

                    -- Health Percentage (to the left of the box)
                    if ESP.HealthPercentageEnabled then
                        local Humanoid = Character:FindFirstChild("Humanoid")
                        if Humanoid and Humanoid.Health > 0 then
                            local Health = Humanoid.Health
                            local MaxHealth = Humanoid.MaxHealth
                            local HealthPercent = math.floor((Health / MaxHealth) * 100)

                            HealthPercentage.Text = tostring(HealthPercent) .. "%"
                            HealthPercentage.Position = Vector2.new(BoxPosition.X - 20, BoxPosition.Y)
                            HealthPercentage.Visible = true
                        else
                            HealthPercentage.Visible = false
                        end
                    else
                        HealthPercentage.Visible = false
                    end
                end
            else
                Box.Visible = false
                Name.Visible = false
                Distance.Visible = false
                HealthBar.Visible = false
                HealthPercentage.Visible = false
            end
        else
            Box.Visible = false
            Name.Visible = false
            Distance.Visible = false
            HealthBar.Visible = false
            HealthPercentage.Visible = false
        end
    end)

    -- Clean up when player leaves
    Player.CharacterRemoving:Connect(function()
        Box:Remove()
        Name:Remove()
        Distance:Remove()
        HealthBar:Remove()
        HealthPercentage:Remove()
        Chams:Destroy()
        RenderConnection:Disconnect()
    end)
end

-- Function to initialize ESP
local function InitializeESP()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            CreateESP(Player)
        end
    end
    Players.PlayerAdded:Connect(function(Player)
        CreateESP(Player)
    end)
end

-- Function to destroy ESP
local function DestroyESP()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            local Character = Player.Character
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                local ESPData = Character:FindFirstChild("ESPData")
                if ESPData then
                    ESPData.Box:Remove()
                    ESPData.Name:Remove()
                    ESPData.Distance:Remove()
                    ESPData.HealthBar:Remove()
                    ESPData.HealthPercentage:Remove()
                end
            end
        end
    end
end

-- Add Health Bar Toggle
ESPSection:AddToggle({
    Name = "Enable Health Bar",
    Flag = "ESPSection_HealthBar",
    Callback = function(Value)
        ESP.HealthBarEnabled = Value
    end
})

-- Add Health Percentage Toggle
ESPSection:AddToggle({
    Name = "Enable Health Percentage",
    Flag = "ESPSection_HealthPercentage",
    Callback = function(Value)
        ESP.HealthPercentageEnabled = Value
    end
})

-- Enable ESP Toggle
ESPSection:AddToggle({
    Name = "Enable ESP",
    Flag = "ESPSection_EnableESP",
    Default = false,
    Callback = function(Value)
        ESP.Enabled = Value
        if Value then
            InitializeESP()
        else
            DestroyESP()
        end
    end
})

-- Add Chams Transparency Slider
ESPSection:AddSlider({
    Name = "Chams Transparency",
    Flag = "ESPSection_ChamsTransparency",
    Value = 1,
    Min = 0,
    Max = 1,
    Callback = function(Value)
        ESP.ChamsTransparency = Value
    end
})

-- Team Check Toggle
ESPSection:AddToggle({
    Name = "Team Check",
    Flag = "ESPSection_TeamCheck",
    Callback = function(Value)
        ESP.TeamCheck = Value
    end
})

-- Max Distance Slider
ESPSection:AddSlider({
    Name = "Max Distance",
    Flag = "ESPSection_MaxDistance",
    Value = 200,
    Min = 0,
    Max = 1000,
    Callback = function(Value)
        ESP.MaxDistance = Value
    end
})

-- Font Size Slider
ESPSection:AddSlider({
    Name = "Font Size",
    Flag = "ESPSection_FontSize",
    Value = 11,
    Min = 8,
    Max = 20,
    Callback = function(Value)
        ESP.FontSize = Value
    end
})

-- Boxes Settings
local BoxesSection = ESPTab:CreateSection({
    Name = "Boxes Settings"
})

BoxesSection:AddToggle({
    Name = "Enable Boxes",
    Flag = "BoxesSection_EnableBoxes",
    Callback = function(Value)
        ESP.Drawing.Boxes.Enabled = Value
    end
})

BoxesSection:AddColorPicker({
    Name = "Box Color",
    Flag = "BoxesSection_BoxColor",
    Color = Color3.fromRGB(255, 255, 255), -- White
    Callback = function(Value)
        ESP.Drawing.Boxes.Color = Value
    end
})

-- Add Dropdown for Box Styles
BoxesSection:AddDropdown({
    Name = "Box Style",
    Flag = "BoxesSection_BoxStyle",
    Default = "Dynamic",
    List = {"Dynamic", "3D"},
    Callback = function(Value)
        ESP.Drawing.Boxes.Style = Value
    end
})

-- Names Settings
local NamesSection = ESPTab:CreateSection({
    Name = "Names Settings"
})

NamesSection:AddToggle({
    Name = "Enable Names",
    Flag = "NamesSection_EnableNames",
    Callback = function(Value)
        ESP.Drawing.Names.Enabled = Value
    end
})

NamesSection:AddColorPicker({
    Name = "Name Color",
    Flag = "NamesSection_NameColor",
    Color = Color3.fromRGB(255, 255, 255), -- White
    Callback = function(Value)
        ESP.Drawing.Names.Color = Value
    end
})

-- Distances Settings
local DistancesSection = ESPTab:CreateSection({
    Name = "Distances Settings"
})

DistancesSection:AddToggle({
    Name = "Enable Distances",
    Flag = "DistancesSection_EnableDistances",
    Callback = function(Value)
        ESP.Drawing.Distances.Enabled = Value
    end
})

DistancesSection:AddColorPicker({
    Name = "Distance Color",
    Flag = "DistancesSection_DistanceColor",
    Color = Color3.fromRGB(255, 255, 255), -- White
    Callback = function(Value)
        ESP.Drawing.Distances.Color = Value
    end
})

-- Chams Settings
local ChamsSection = ESPTab:CreateSection({
    Name = "Chams Settings"
})

ChamsSection:AddToggle({
    Name = "Enable Chams",
    Flag = "ChamsSection_EnableChams",
    Callback = function(Value)
        ESP.Drawing.Chams.Enabled = Value
    end
})

ChamsSection:AddColorPicker({
    Name = "Chams Fill Color",
    Flag = "ChamsSection_FillColor",
    Color = Color3.fromRGB(119, 120, 255), -- Purple
    Callback = function(Value)
        ESP.Drawing.Chams.FillColor = Value
    end
})

ChamsSection:AddColorPicker({
    Name = "Chams Outline Color",
    Flag = "ChamsSection_OutlineColor",
    Color = Color3.fromRGB(119, 120, 255), -- Purple
    Callback = function(Value)
        ESP.Drawing.Chams.OutlineColor = Value
    end
})

-- Chams Outline Toggle
ChamsSection:AddToggle({
    Name = "Toggle Chams Outline",
    Flag = "ChamsSection_ToggleOutline",
    Callback = function(Value)
        ESP.Drawing.Chams.OutlineTransparency = Value and 0 or 1
    end
})