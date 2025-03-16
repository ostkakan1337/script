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
    if not RootPart then return nil end

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
        if ScreenPos.Z > 0 then
            ScreenMin = Vector2.new(math.min(ScreenMin.X, ScreenPos.X), math.min(ScreenMin.Y, ScreenPos.Y))
            ScreenMax = Vector2.new(math.max(ScreenMax.X, ScreenPos.X), math.max(ScreenMax.Y, ScreenPos.Y))
        end
    end

    return ScreenMin, ScreenMax
end
-- Function to approximate text width
local function GetTextWidth(text, fontSize)
    return #text * (fontSize / 2) -- Approximation based on font size and character count
end

-- Function to create ESP elements
local function CreateESP(Player)
    local Character = Player.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end

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

    -- Chams ESP
    local Chams = Instance.new("Highlight")
    Chams.Parent = game.CoreGui
    Chams.FillColor = ESP.Drawing.Chams.FillColor
    Chams.OutlineColor = ESP.Drawing.Chams.OutlineColor
    Chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Chams.Enabled = false

    -- 3D Box Lines
    local Lines = {}
    for i = 1, 12 do
        Lines[i] = Drawing.new("Line")
        Lines[i].Visible = false
        Lines[i].Color = ESP.Drawing.Boxes.Color
        Lines[i].Thickness = 1
    end

    -- Update ESP
    local RenderConnection
    RenderConnection = RunService.RenderStepped:Connect(function()
        if ESP.Enabled and Character and Character:FindFirstChild("HumanoidRootPart") then
            local RootPart = Character.HumanoidRootPart
            local Position, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
            local DistanceFromPlayer = (Camera.CFrame.Position - RootPart.Position).Magnitude

            if OnScreen and DistanceFromPlayer <= ESP.MaxDistance then
                -- Box ESP
                if ESP.Drawing.Boxes.Enabled then
                    if ESP.Drawing.Boxes.Style == "Dynamic" then
                        -- Calculate bounding box
                        local ScreenMin, ScreenMax = CalculateBoundingBox(Character)
                        if ScreenMin and ScreenMax then
                            Box.Size = Vector2.new(ScreenMax.X - ScreenMin.X, ScreenMax.Y - ScreenMin.Y)
                            Box.Position = ScreenMin
                            Box.Visible = true
                            Box.Color = ESP.Drawing.Boxes.Color -- Update color in real-time
                        else
                            Box.Visible = false
                        end
                        for _, Line in pairs(Lines) do
                            Line.Visible = false -- Hide 3D box lines
                        end
                    elseif ESP.Drawing.Boxes.Style == "3D" then
                        -- 3D Box (fixed size)
                        local CF = RootPart.CFrame
                        local Size = Vector3.new(4, 6, 2) -- Adjust size as needed

                        local Corners = {
                            CF * CFrame.new(-Size.X / 2, Size.Y / 2, -Size.Z / 2).Position,
                            CF * CFrame.new(Size.X / 2, Size.Y / 2, -Size.Z / 2).Position,
                            CF * CFrame.new(Size.X / 2, -Size.Y / 2, -Size.Z / 2).Position,
                            CF * CFrame.new(-Size.X / 2, -Size.Y / 2, -Size.Z / 2).Position,
                            CF * CFrame.new(-Size.X / 2, Size.Y / 2, Size.Z / 2).Position,
                            CF * CFrame.new(Size.X / 2, Size.Y / 2, Size.Z / 2).Position,
                            CF * CFrame.new(Size.X / 2, -Size.Y / 2, Size.Z / 2).Position,
                            CF * CFrame.new(-Size.X / 2, -Size.Y / 2, Size.Z / 2).Position
                        }

                        local Indices = {
                            {1, 2}, {2, 3}, {3, 4}, {4, 1},
                            {5, 6}, {6, 7}, {7, 8}, {8, 5},
                            {1, 5}, {2, 6}, {3, 7}, {4, 8}
                        }

                        for i, IndexPair in pairs(Indices) do
                            local Start, End = Camera:WorldToViewportPoint(Corners[IndexPair[1]]), Camera:WorldToViewportPoint(Corners[IndexPair[2]])
                            Lines[i].From = Vector2.new(Start.X, Start.Y)
                            Lines[i].To = Vector2.new(End.X, End.Y)
                            Lines[i].Color = ESP.Drawing.Boxes.Color -- Update color in real-time
                            Lines[i].Visible = true
                        end
                        Box.Visible = false -- Hide dynamic box
                    end
                else
                    Box.Visible = false
                    for _, Line in pairs(Lines) do
                        Line.Visible = false
                    end
                end

                -- Name ESP
                if ESP.Drawing.Names.Enabled then
                    local NameWidth = GetTextWidth(Player.Name, ESP.FontSize)
                    Name.Position = Vector2.new(Position.X - NameWidth / 2, Position.Y - Box.Size.Y / 2 - 20) -- Centered above
                    Name.Color = ESP.Drawing.Names.Color
                    Name.Size = ESP.FontSize
                    Name.Visible = true
                else
                    Name.Visible = false
                end

                -- Distance ESP
                if ESP.Drawing.Distances.Enabled then
                    local DistanceText = tostring(math.floor(DistanceFromPlayer)) .. " studs"
                    local DistanceWidth = GetTextWidth(DistanceText, ESP.FontSize)
                    Distance.Position = Vector2.new(Position.X - DistanceWidth / 2, Position.Y + Box.Size.Y / 2 + 10) -- Centered below
                    Distance.Text = DistanceText
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
                for _, Line in pairs(Lines) do
                    Line.Visible = false
                end
            end
        else
            Box.Visible = false
            Name.Visible = false
            Distance.Visible = false
            Chams.Enabled = false
            for _, Line in pairs(Lines) do
                Line.Visible = false
            end
        end
    end)

    -- Clean up when player leaves
    Player.CharacterRemoving:Connect(function()
        Box:Remove()
        Name:Remove()
        Distance:Remove()
        Chams:Destroy()
        for _, Line in pairs(Lines) do
            Line:Remove()
        end
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
                    ESPData.Chams:Destroy()
                    for _, Line in pairs(ESPData.Lines) do
                        Line:Remove()
                    end
                end
            end
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