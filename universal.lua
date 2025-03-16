-- Load UI Library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ostkakan1337/script/refs/heads/main/ui.lua"))()

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
            Content = "Discord invite copied to clipboard!",
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
    Drawing = {
        Boxes = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) }, -- White boxes
        Names = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) }, -- White names
        Distances = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) }, -- White distances
        Chams = { Enabled = false, FillColor = Color3.fromRGB(119, 120, 255), OutlineColor = Color3.fromRGB(119, 120, 255), OutlineTransparency = 0 } -- Purple fill and outline
    }
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Function to create ESP elements
local function CreateESP(Player)
    local Character = Player.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end

    -- Box ESP
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = ESP.Drawing.Boxes.Color
    Box.Thickness = 1 -- Thin boxes
    Box.Filled = false -- No fill, just outline

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

    -- Chams ESP
    local Chams = Instance.new("Highlight")
    Chams.Parent = game.CoreGui
    Chams.FillColor = ESP.Drawing.Chams.FillColor
    Chams.OutlineColor = ESP.Drawing.Chams.OutlineColor
    Chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Chams.Enabled = false

    -- Update ESP
    RunService.RenderStepped:Connect(function()
        if ESP.Enabled and Character and Character:FindFirstChild("HumanoidRootPart") then
            local RootPart = Character.HumanoidRootPart
            local Position, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
            local DistanceFromPlayer = (Camera.CFrame.Position - RootPart.Position).Magnitude

            if OnScreen and DistanceFromPlayer <= ESP.MaxDistance then
                -- Calculate box size dynamically based on player's bounding box
                local Top = Camera:WorldToViewportPoint((Character:GetModelCFrame() * CFrame.new(0, Character:GetExtentsSize().Y / 2, 0)).Position
                local Bottom = Camera:WorldToViewportPoint((Character:GetModelCFrame() * CFrame.new(0, -Character:GetExtentsSize().Y / 2, 0)).Position
                local Width = (Top - Bottom).X
                local Height = (Top - Bottom).Y

                -- Box ESP
                if ESP.Drawing.Boxes.Enabled then
                    Box.Size = Vector2.new(Width, Height)
                    Box.Position = Vector2.new(Position.X - Width / 2, Position.Y - Height / 2)
                    Box.Color = ESP.Drawing.Boxes.Color
                    Box.Visible = true
                else
                    Box.Visible = false
                end

                -- Name ESP
                if ESP.Drawing.Names.Enabled then
                    Name.Position = Vector2.new(Position.X, Position.Y - Height / 2 - 20)
                    Name.Color = ESP.Drawing.Names.Color
                    Name.Size = ESP.FontSize
                    Name.Visible = true
                else
                    Name.Visible = false
                end

                -- Distance ESP
                if ESP.Drawing.Distances.Enabled then
                    Distance.Position = Vector2.new(Position.X, Position.Y + Height / 2 + 10)
                    Distance.Text = tostring(math.floor(DistanceFromPlayer)) .. " studs"
                    Distance.Color = ESP.Drawing.Distances.Color
                    Distance.Size = ESP.FontSize
                    Distance.Visible = true
                else
                    Distance.Visible = false
                end

                -- Chams ESP
                if ESP.Drawing.Chams.Enabled then
                    Chams.Adornee = Character
                    Chams.FillColor = ESP.Drawing.Chams.FillColor
                    Chams.OutlineColor = ESP.Drawing.Chams.OutlineColor
                    Chams.OutlineTransparency = ESP.Drawing.Chams.OutlineTransparency
                    Chams.Enabled = true
                else
                    Chams.Enabled = false
                end
            else
                Box.Visible = false
                Name.Visible = false
                Distance.Visible = false
                Chams.Enabled = false
            end
        else
            Box.Visible = false
            Name.Visible = false
            Distance.Visible = false
            Chams.Enabled = false
        end
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
    for _, drawing in pairs(Drawing.GetObjects()) do
        drawing:Remove()
    end
    for _, highlight in pairs(game.CoreGui:GetChildren()) do
        if highlight:IsA("Highlight") then
            highlight:Destroy()
        end
    end
end

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

ESPSection:AddToggle({
    Name = "Team Check",
    Flag = "ESPSection_TeamCheck",
    Callback = function(Value)
        ESP.TeamCheck = Value
    end
})

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

ESPSection:AddSlider({
    Name = "Font Size",
    Flag = "ESPSection_FontSize",
    Value = 11,
    Min = 8,
    Max = 20,
    Callback = function(Value)
        ESP.FontSize = Value
        -- Update font size for all ESP elements
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer then
                local Character = Player.Character
                if Character and Character:FindFirstChild("HumanoidRootPart") then
                    local ESPData = Character:FindFirstChild("ESPData")
                    if ESPData then
                        ESPData.Name.Size = Value
                        ESPData.Distance.Size = Value
                    end
                end
            end
        end
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