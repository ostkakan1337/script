local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ostkakan1337/script/refs/heads/main/ui.lua"))()
local UserInputService = game:GetService("UserInputService")
shared.force_designer = true
local PepsisWorld = library:CreateWindow({
    Name = "Lunarity | Universal",
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
    {
        Name = "Unload Script",
        Callback = function()
            library:Unload()
        end
    },
    {
        Name = "Join Discord",
        Callback = function()
            setclipboard("https://discord.gg/dT8Db3wV")
            library:Notify({
                Title = "Discord",
                Text = "Discord invite copied to clipboard!",
                Duration = 3,
                Type = "Success"
            })
        end
    }
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
        Chams = { Enabled = false, FillColor = Color3.fromRGB(119, 120, 255), FillTransparency = 0.5, OutlineColor = Color3.fromRGB(119, 120, 255), OutlineTransparency = 1 } -- Outline off by default
    },
    BoxStyle = "Full",                                                                                                                                                        -- "Full" or "Corner"
    FilledBox = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 0),
        Transparency = 0.3
    }
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// bounding box
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
    Box.Thickness = 1  -- Thin lines
    Box.Filled = false -- Not filled (hollow)

    --// Filled Box
    local FilledBox = Drawing.new("Square")
    FilledBox.Visible = false
    FilledBox.Color = ESP.FilledBox.Color
    FilledBox.Thickness = 1
    FilledBox.Filled = true
    FilledBox.Transparency = ESP.FilledBox.Transparency

    --// Box Outline
    local BoxOutlineOuter = Drawing.new("Square")
    BoxOutlineOuter.Visible = false
    BoxOutlineOuter.Color = Color3.new(0, 0, 0)
    BoxOutlineOuter.Thickness = 1
    BoxOutlineOuter.Filled = false

    --// Corner Boxes
    local Corners = {}
    for i = 1, 8 do
        Corners[i] = Drawing.new("Line")
        Corners[i].Visible = false
        Corners[i].Color = ESP.Drawing.Boxes.Color
        Corners[i].Thickness = 1
    end

    --// Corner Outlineser
    local CornerOutlinesOuter = {}
    local CornerOutlinesInner = {}
    for i = 1, 8 do
        CornerOutlinesOuter[i] = Drawing.new("Line")
        CornerOutlinesOuter[i].Visible = false
        CornerOutlinesOuter[i].Color = Color3.new(0, 0, 0) -- Black outline
        CornerOutlinesOuter[i].Thickness = 1               -- Reduced from 3 to 1

        CornerOutlinesInner[i] = Drawing.new("Line")
        CornerOutlinesInner[i].Visible = false
        CornerOutlinesInner[i].Color = Color3.new(0, 0, 0) -- Black outline
        CornerOutlinesInner[i].Thickness = 1               -- Reduced from 3 to 1
    end

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
    Chams.FillTransparency = ESP.Drawing.Chams.FillTransparency
    Chams.OutlineTransparency = ESP.Drawing.Chams.OutlineTransparency
    Chams.Enabled = ESP.Drawing.Chams.Enabled

    -- Function to update Chams in real-time
    local function UpdateChams()
        if ESP.Drawing.Chams.Enabled then
            Chams.FillColor = ESP.Drawing.Chams.FillColor
            Chams.OutlineColor = ESP.Drawing.Chams.OutlineColor
            Chams.FillTransparency = ESP.Drawing.Chams.FillTransparency
            Chams.OutlineTransparency = ESP.Drawing.Chams.OutlineTransparency
            Chams.Enabled = true
        else
            Chams.Enabled = false
        end
    end

    -- Update ESP
    -- Health Bar
    local HealthBar = Drawing.new("Square")
    HealthBar.Visible = false
    HealthBar.Color = Color3.new(0, 1, 0) -- Green by default
    HealthBar.Thickness = 1
    HealthBar.Filled = true

    -- Health Bar Outline
    local HealthBarOutline = Drawing.new("Square")
    HealthBarOutline.Visible = false
    HealthBarOutline.Color = Color3.new(0, 0, 0) --// Black outline
    HealthBarOutline.Thickness = 1               --// Thinner outline
    HealthBarOutline.Filled = false

    -- Update ESP
    local RenderConnection
    RenderConnection = RunService.RenderStepped:Connect(function()
        if ESP.Enabled and Character and Character:FindFirstChild("HumanoidRootPart") then
            -- Update Chams in real-time
            UpdateChams()

            -- Update font size for text elements
            Name.Size = ESP.FontSize
            Distance.Size = ESP.FontSize
            HealthPercentage.Size = ESP.FontSize

            -- Update box color in real-time
            Box.Color = ESP.Drawing.Boxes.Color

            -- Update name and distance color in real-time
            Name.Color = ESP.Drawing.Names.Color
            Distance.Color = ESP.Drawing.Distances.Color

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

                    --// I increase the top of the box becouse it didnt fit
                    BoxPosition = Vector2.new(BoxPosition.X, BoxPosition.Y - 10)
                    BoxSize = Vector2.new(BoxSize.X, BoxSize.Y + 10)

                    --// Box ESP
                    if ESP.Drawing.Boxes.Enabled then
                        if ESP.BoxStyle == "Full" then
                            --// fill box if enabled
                            if ESP.FilledBox.Enabled then
                                FilledBox.Size = BoxSize
                                FilledBox.Position = BoxPosition
                                FilledBox.Color = ESP.FilledBox.Color
                                FilledBox.Transparency = ESP.FilledBox.Transparency
                                FilledBox.Visible = true
                            else
                                FilledBox.Visible = false
                            end

                            --// outer box
                            BoxOutlineOuter.Size = Vector2.new(BoxSize.X + 2, BoxSize.Y + 2)
                            BoxOutlineOuter.Position = Vector2.new(BoxPosition.X - 1, BoxPosition.Y - 1)
                            BoxOutlineOuter.Visible = true
                            BoxOutlineOuter.Color = Color3.new(0, 0, 0) -- Force black color

                            --// inner box
                            BoxOutlineInner.Size = Vector2.new(BoxSize.X - 2, BoxSize.Y - 2)
                            BoxOutlineInner.Position = Vector2.new(BoxPosition.X + 1, BoxPosition.Y + 1)
                            BoxOutlineInner.Visible = true
                            BoxOutlineInner.Color = Color3.new(0, 0, 0) -- Force black color

                            --// updates to the box
                            Box.Size = BoxSize
                            Box.Position = BoxPosition
                            Box.Color = ESP.Drawing.Boxes.Color -- Ensure color is updated
                            Box.Visible = true

                            -- Hide corner boxes
                            for i = 1, 8 do
                                Corners[i].Visible = false
                                CornerOutlinesOuter[i].Visible = false
                                CornerOutlinesInner[i].Visible = false
                            end
                        else --// corner box
                            --// hide boxes
                            Box.Visible = false
                            BoxOutlineOuter.Visible = false
                            BoxOutlineInner.Visible = false

                            --// filled boxss
                            if ESP.FilledBox.Enabled then
                                FilledBox.Size = BoxSize
                                FilledBox.Position = BoxPosition
                                FilledBox.Color = ESP.FilledBox.Color
                                FilledBox.Transparency = ESP.FilledBox.Transparency
                                FilledBox.Visible = true
                            else
                                FilledBox.Visible = false
                            end

                            --// corner size
                            local cornerSize = math.min(BoxSize.X, BoxSize.Y) * 0.25
                            cornerSize = math.clamp(cornerSize, 8, 20)

                            --// corner boxes outer lienes
                            --// Top Left Corner
                            CornerOutlinesOuter[1].From = Vector2.new(BoxPosition.X - 1, BoxPosition.Y - 1)
                            CornerOutlinesOuter[1].To = Vector2.new(BoxPosition.X + cornerSize + 1, BoxPosition.Y - 1)
                            CornerOutlinesOuter[2].From = Vector2.new(BoxPosition.X - 1, BoxPosition.Y - 1)
                            CornerOutlinesOuter[2].To = Vector2.new(BoxPosition.X - 1, BoxPosition.Y + cornerSize + 1)

                            --// Top Right Corner
                            CornerOutlinesOuter[3].From = Vector2.new(BoxPosition.X + BoxSize.X + 1, BoxPosition.Y - 1)
                            CornerOutlinesOuter[3].To = Vector2.new(BoxPosition.X + BoxSize.X - cornerSize - 1,
                                BoxPosition.Y - 1)
                            CornerOutlinesOuter[4].From = Vector2.new(BoxPosition.X + BoxSize.X + 1, BoxPosition.Y - 1)
                            CornerOutlinesOuter[4].To = Vector2.new(BoxPosition.X + BoxSize.X + 1,
                                BoxPosition.Y + cornerSize + 1)

                            --// Bottom Left Corner
                            CornerOutlinesOuter[5].From = Vector2.new(BoxPosition.X - 1, BoxPosition.Y + BoxSize.Y + 1)
                            CornerOutlinesOuter[5].To = Vector2.new(BoxPosition.X + cornerSize + 1,
                                BoxPosition.Y + BoxSize.Y + 1)
                            CornerOutlinesOuter[6].From = Vector2.new(BoxPosition.X - 1, BoxPosition.Y + BoxSize.Y + 1)
                            CornerOutlinesOuter[6].To = Vector2.new(BoxPosition.X - 1,
                                BoxPosition.Y + BoxSize.Y - cornerSize - 1)

                            --// Bottom Right Corner
                            CornerOutlinesOuter[7].From = Vector2.new(BoxPosition.X + BoxSize.X + 1,
                                BoxPosition.Y + BoxSize.Y + 1)
                            CornerOutlinesOuter[7].To = Vector2.new(BoxPosition.X + BoxSize.X - cornerSize - 1,
                                BoxPosition.Y + BoxSize.Y + 1)
                            CornerOutlinesOuter[8].From = Vector2.new(BoxPosition.X + BoxSize.X + 1,
                                BoxPosition.Y + BoxSize.Y + 1)
                            CornerOutlinesOuter[8].To = Vector2.new(BoxPosition.X + BoxSize.X + 1,
                                BoxPosition.Y + BoxSize.Y - cornerSize - 1)

                            -- Draw inner outlines
                            -- Top Left Corner (inner)
                            CornerOutlinesInner[1].From = Vector2.new(BoxPosition.X + 1, BoxPosition.Y + 1)
                            CornerOutlinesInner[1].To = Vector2.new(BoxPosition.X + cornerSize - 1, BoxPosition.Y + 1)
                            CornerOutlinesInner[2].From = Vector2.new(BoxPosition.X + 1, BoxPosition.Y + 1)
                            CornerOutlinesInner[2].To = Vector2.new(BoxPosition.X + 1, BoxPosition.Y + cornerSize - 1)

                            --// Top Right Corner
                            CornerOutlinesInner[3].From = Vector2.new(BoxPosition.X + BoxSize.X - 1, BoxPosition.Y + 1)
                            CornerOutlinesInner[3].To = Vector2.new(BoxPosition.X + BoxSize.X - cornerSize + 1,
                                BoxPosition.Y + 1)
                            CornerOutlinesInner[4].From = Vector2.new(BoxPosition.X + BoxSize.X - 1, BoxPosition.Y + 1)
                            CornerOutlinesInner[4].To = Vector2.new(BoxPosition.X + BoxSize.X - 1,
                                BoxPosition.Y + cornerSize - 1)

                            --// Bottom Left Corner
                            CornerOutlinesInner[5].From = Vector2.new(BoxPosition.X + 1, BoxPosition.Y + BoxSize.Y - 1)
                            CornerOutlinesInner[5].To = Vector2.new(BoxPosition.X + cornerSize - 1,
                                BoxPosition.Y + BoxSize.Y - 1)
                            CornerOutlinesInner[6].From = Vector2.new(BoxPosition.X + 1, BoxPosition.Y + BoxSize.Y - 1)
                            CornerOutlinesInner[6].To = Vector2.new(BoxPosition.X + 1,
                                BoxPosition.Y + BoxSize.Y - cornerSize + 1)

                            --// Bottom Right Corner
                            CornerOutlinesInner[7].From = Vector2.new(BoxPosition.X + BoxSize.X - 1,
                                BoxPosition.Y + BoxSize.Y - 1)
                            CornerOutlinesInner[7].To = Vector2.new(BoxPosition.X + BoxSize.X - cornerSize + 1,
                                BoxPosition.Y + BoxSize.Y - 1)
                            CornerOutlinesInner[8].From = Vector2.new(BoxPosition.X + BoxSize.X - 1,
                                BoxPosition.Y + BoxSize.Y - 1)
                            CornerOutlinesInner[8].To = Vector2.new(BoxPosition.X + BoxSize.X - 1,
                                BoxPosition.Y + BoxSize.Y - cornerSize + 1)

                            --// set the corner outlines to black and make them visible.
                            for i = 1, 8 do
                                CornerOutlinesOuter[i].Color = Color3.new(0, 0, 0) -- Force black color
                                CornerOutlinesOuter[i].Visible = true
                                CornerOutlinesInner[i].Color = Color3.new(0, 0, 0) -- Force black color
                                CornerOutlinesInner[i].Visible = true
                            end

                            --// corner boxes here
                            --// Top Left Corner
                            Corners[1].From = Vector2.new(BoxPosition.X, BoxPosition.Y)
                            Corners[1].To = Vector2.new(BoxPosition.X + cornerSize, BoxPosition.Y)
                            Corners[2].From = Vector2.new(BoxPosition.X, BoxPosition.Y)
                            Corners[2].To = Vector2.new(BoxPosition.X, BoxPosition.Y + cornerSize)

                            --// Top Right Corner
                            Corners[3].From = Vector2.new(BoxPosition.X + BoxSize.X, BoxPosition.Y)
                            Corners[3].To = Vector2.new(BoxPosition.X + BoxSize.X - cornerSize, BoxPosition.Y)
                            Corners[4].From = Vector2.new(BoxPosition.X + BoxSize.X, BoxPosition.Y)
                            Corners[4].To = Vector2.new(BoxPosition.X + BoxSize.X, BoxPosition.Y + cornerSize)

                            --// Bottom Left Corner
                            Corners[5].From = Vector2.new(BoxPosition.X, BoxPosition.Y + BoxSize.Y)
                            Corners[5].To = Vector2.new(BoxPosition.X + cornerSize, BoxPosition.Y + BoxSize.Y)
                            Corners[6].From = Vector2.new(BoxPosition.X, BoxPosition.Y + BoxSize.Y)
                            Corners[6].To = Vector2.new(BoxPosition.X, BoxPosition.Y + BoxSize.Y - cornerSize)

                            --// Bottom Right Corner
                            Corners[7].From = Vector2.new(BoxPosition.X + BoxSize.X, BoxPosition.Y + BoxSize.Y)
                            Corners[7].To = Vector2.new(BoxPosition.X + BoxSize.X - cornerSize, BoxPosition.Y + BoxSize
                            .Y)
                            Corners[8].From = Vector2.new(BoxPosition.X + BoxSize.X, BoxPosition.Y + BoxSize.Y)
                            Corners[8].To = Vector2.new(BoxPosition.X + BoxSize.X, BoxPosition.Y + BoxSize.Y - cornerSize)

                            -- Update colors and make all corners visible
                            for i = 1, 8 do
                                Corners[i].Color = ESP.Drawing.Boxes.Color -- Use the selected color
                                Corners[i].Visible = true
                            end
                        end
                    else
                        Box.Visible = false
                        BoxOutlineOuter.Visible = false
                        BoxOutlineInner.Visible = false
                        FilledBox.Visible = false
                        for i = 1, 8 do
                            Corners[i].Visible = false
                            CornerOutlinesOuter[i].Visible = false
                            CornerOutlinesInner[i].Visible = false
                        end
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

                            -- Health Bar - Red at bottom, green at top
                            HealthBar.Size = Vector2.new(2.5, BoxSize.Y * HealthRatio) -- Width: 2.5 (half of original), Height: Proportional to health
                            HealthBar.Position = Vector2.new(BoxPosition.X - 10,
                                BoxPosition.Y + BoxSize.Y - (BoxSize.Y * HealthRatio))
                            HealthBar.Color = Color3.new(1 - HealthRatio, HealthRatio, 0) -- Red to Green gradient
                            HealthBar.Visible = true

                            -- Health Bar Outline
                            HealthBarOutline.Size = Vector2.new(2.5, BoxSize.Y) -- Width: 2.5 (half of original), Height: Full height
                            HealthBarOutline.Position = Vector2.new(BoxPosition.X - 10,
                                BoxPosition.Y + BoxSize.Y - BoxSize.Y)
                            HealthBarOutline.Thickness = 1 -- Thinner outline
                            HealthBarOutline.Visible = true
                        else
                            HealthBar.Visible = false
                            HealthBarOutline.Visible = false
                        end
                    else
                        HealthBar.Visible = false
                        HealthBarOutline.Visible = false
                    end

                    -- Health Percentage (to the left of the box, but not inside the health bar)
                    if ESP.HealthPercentageEnabled then
                        local Humanoid = Character:FindFirstChild("Humanoid")
                        if Humanoid and Humanoid.Health > 0 then
                            local Health = Humanoid.Health
                            local MaxHealth = Humanoid.MaxHealth
                            local HealthPercent = math.floor((Health / MaxHealth) * 100)

                            HealthPercentage.Text = tostring(HealthPercent) .. "%"
                            HealthPercentage.Position = Vector2.new(BoxPosition.X - 35, BoxPosition.Y) -- Move further left to avoid overlapping with health bar
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
                BoxOutlineOuter.Visible = false
                BoxOutlineInner.Visible = false
                FilledBox.Visible = false
                for i = 1, 8 do
                    Corners[i].Visible = false
                    CornerOutlinesOuter[i].Visible = false
                    CornerOutlinesInner[i].Visible = false
                end
                Name.Visible = false
                Distance.Visible = false
                HealthBar.Visible = false
                HealthBarOutline.Visible = false
                HealthPercentage.Visible = false
                Chams.Enabled = false
            end
        else
            Box.Visible = false
            BoxOutlineOuter.Visible = false
            BoxOutlineInner.Visible = false
            FilledBox.Visible = false
            for i = 1, 8 do
                Corners[i].Visible = false
                CornerOutlinesOuter[i].Visible = false
                CornerOutlinesInner[i].Visible = false
            end
            Name.Visible = false
            Distance.Visible = false
            HealthBar.Visible = false
            HealthBarOutline.Visible = false
            HealthPercentage.Visible = false
            Chams.Enabled = false
        end
    end)

    -- Clean up when player leaves
    Player.CharacterRemoving:Connect(function()
        Box:Remove()
        BoxOutlineOuter:Remove()
        BoxOutlineInner:Remove()
        FilledBox:Remove()

        -- Remove corner boxes
        for i = 1, 8 do
            Corners[i]:Remove()
            CornerOutlinesOuter[i]:Remove()
            CornerOutlinesInner[i]:Remove()
        end

        Name:Remove()
        Distance:Remove()
        HealthBar:Remove()
        HealthBarOutline:Remove()
        HealthPercentage:Remove()
        Chams:Destroy()
        RenderConnection:Disconnect()
    end)
end

-- Function to destroy ESP
local function DestroyESP()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            local Character = Player.Character
            if Character then
                -- Find and remove Highlight (Chams)
                for _, Child in pairs(Character:GetChildren()) do
                    if Child:IsA("Highlight") then
                        Child:Destroy()
                    end
                end
            end
        end
    end
end

-- Function to initialize ESP
local function InitializeESP()
    -- Clear any existing ESP elements first
    DestroyESP()

    -- Create ESP for all existing players
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            if Player.Character then
                CreateESP(Player)
            end

            -- Handle when player's character spawns/respawns
            Player.CharacterAdded:Connect(function(Character)
                -- Wait for HumanoidRootPart to ensure character is fully loaded
                Character:WaitForChild("HumanoidRootPart")
                CreateESP(Player)
            end)
        end
    end

    -- Handle new players joining
    Players.PlayerAdded:Connect(function(Player)
        if Player ~= LocalPlayer then
            -- Handle when player's character spawns
            Player.CharacterAdded:Connect(function(Character)
                -- Wait for HumanoidRootPart to ensure character is fully loaded
                Character:WaitForChild("HumanoidRootPart")
                CreateESP(Player)
            end)

            -- If player already has a character
            if Player.Character then
                CreateESP(Player)
            end
        end
    end)
end

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

-- Health Settings Section
local HealthSection = ESPTab:CreateSection({
    Name = "Health Settings"
})

-- Add Health Bar Toggle
HealthSection:AddToggle({
    Name = "Enable Health Bar",
    Flag = "HealthSection_HealthBar",
    Callback = function(Value)
        ESP.HealthBarEnabled = Value
    end
})

-- Add Health Percentage Toggle
HealthSection:AddToggle({
    Name = "Enable Health Percentage",
    Flag = "HealthSection_HealthPercentage",
    Callback = function(Value)
        ESP.HealthPercentageEnabled = Value
    end
})

-- Chams Settings Section
local ChamsSection = ESPTab:CreateSection({
    Name = "Chams Settings",
    Side = "Right",
})

ChamsSection:AddToggle({
    Name = "Enable Chams",
    Flag = "ChamsSection_EnableChams",
    Callback = function(Value)
        ESP.Drawing.Chams.Enabled = Value
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

ChamsSection:AddLabel({
    Text = "----------- Options -----------"
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

-- Chams Fill Opacity Slider
ChamsSection:AddSlider({
    Name = "Chams Fill Opacity",
    Flag = "ChamsSection_FillOpacity",
    Value = 0.5,
    Min = 0,
    Max = 1,
    Callback = function(Value)
        ESP.Drawing.Chams.FillTransparency = 1 - Value
    end
})