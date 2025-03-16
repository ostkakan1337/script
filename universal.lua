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
        Chams = { Enabled = false, FillColor = Color3.fromRGB(119, 120, 255), FillTransparency = 0.5, OutlineColor = Color3.fromRGB(119, 120, 255), OutlineTransparency = 1 } -- Outline off by default
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
    Box.Thickness = 1  -- Thin lines
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
    HealthBarOutline.Color = Color3.new(0, 0, 0) -- Black outline
    HealthBarOutline.Thickness = 1               -- Thinner outline
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

                            -- Health Bar
                            HealthBar.Size = Vector2.new(2.5, BoxSize.Y * HealthRatio) -- Width: 2.5 (half of original), Height: Proportional to health
                            HealthBar.Position = Vector2.new(BoxPosition.X - 10,
                                BoxPosition.Y + BoxSize.Y - (BoxSize.Y * HealthRatio))
                            HealthBar.Color = Color3.new(1 - HealthRatio, HealthRatio, 0) -- Red to Green gradient
                            HealthBar.Visible = true

                            -- Health Bar Outline
                            HealthBarOutline.Size = Vector2.new(2.5, BoxSize.Y) -- Width: 2.5 (half of original), Height: Full height
                            HealthBarOutline.Position = Vector2.new(BoxPosition.X - 10,
                                BoxPosition.Y + BoxSize.Y - BoxSize.Y)
                            HealthBarOutline.Thickness = 1  -- Thinner outline
                            HealthBarOutline.Visible = true
                        else
                            HealthBar.Visible = false
                            HealthBarOutline.Visible = false
                        end
                    else
                        HealthBar.Visible = false
                        HealthBarOutline.Visible = false
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
                HealthBarOutline.Visible = false
                HealthPercentage.Visible = false
                Chams.Enabled = false
            end
        else
            Box.Visible = false
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
        Name:Remove()
        Distance:Remove()
        HealthBar:Remove()
        HealthBarOutline:Remove()
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
                    ESPData.HealthBar:Remove()
                    ESPData.HealthBarOutline:Remove()
                    ESPData.HealthPercentage:Remove()
                end
            end
        end
    end
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

-- Chams Outline Toggle
ChamsSection:AddToggle({
    Name = "Toggle Chams Outline",
    Flag = "ChamsSection_ToggleOutline",
    Callback = function(Value)
        ESP.Drawing.Chams.OutlineTransparency = Value and 0 or 1
    end
})

-- Box, Names, and Distances Settings Section
local BoxNamesDistancesSection = ESPTab:CreateSection({
    Name = "Box, Names, and Distances Settings"
})

BoxNamesDistancesSection:AddToggle({
    Name = "Enable Boxes",
    Flag = "BoxNamesDistancesSection_EnableBoxes",
    Callback = function(Value)
        ESP.Drawing.Boxes.Enabled = Value
    end
})

BoxNamesDistancesSection:AddColorPicker({
    Name = "Box Color",
    Flag = "BoxNamesDistancesSection_BoxColor",
    Color = Color3.fromRGB(255, 255, 255), -- White
    Callback = function(Value)
        ESP.Drawing.Boxes.Color = Value
    end
})

BoxNamesDistancesSection:AddToggle({
    Name = "Enable Names",
    Flag = "BoxNamesDistancesSection_EnableNames",
    Callback = function(Value)
        ESP.Drawing.Names.Enabled = Value
    end
})

BoxNamesDistancesSection:AddColorPicker({
    Name = "Name Color",
    Flag = "BoxNamesDistancesSection_NameColor",
    Color = Color3.fromRGB(255, 255, 255), -- White
    Callback = function(Value)
        ESP.Drawing.Names.Color = Value
    end
})

BoxNamesDistancesSection:AddToggle({
    Name = "Enable Distances",
    Flag = "BoxNamesDistancesSection_EnableDistances",
    Callback = function(Value)
        ESP.Drawing.Distances.Enabled = Value
    end
})

BoxNamesDistancesSection:AddColorPicker({
    Name = "Distance Color",
    Flag = "BoxNamesDistancesSection_DistanceColor",
    Color = Color3.fromRGB(255, 255, 255), -- White
    Callback = function(Value)
        ESP.Drawing.Distances.Color = Value
    end
})

-- Font Size Slider
local FontSizeSection = ESPTab:CreateSection({
    Name = "Font Size Settings"
})

FontSizeSection:AddSlider({
    Name = "Font Size",
    Flag = "FontSizeSection_FontSize",
    Value = 11,
    Min = 8,
    Max = 20,
    Callback = function(Value)
        ESP.FontSize = Value
        -- Update font size for all ESP text elements
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character then
                local ESPData = Player.Character:FindFirstChild("ESPData")
                if ESPData then
                    if ESPData.Name then
                        ESPData.Name.Size = Value
                    end
                    if ESPData.Distance then
                        ESPData.Distance.Size = Value
                    end
                    if ESPData.HealthPercentage then
                        ESPData.HealthPercentage.Size = Value
                    end
                end
            end
        end
    end
})

-- Movement Tab
local MovementTab = PepsisWorld:CreateTab({
    Name = "Movement"
})

-- Movement Settings Section
local MovementSection = MovementTab:CreateSection({
    Name = "Movement Settings"
})

-- Movement Speed Slider
local MovementSpeed = 16 -- Default movement speed
MovementSection:AddSlider({
    Name = "Movement Speed",
    Flag = "MovementSection_MovementSpeed",
    Value = 16,
    Min = 0,
    Max = 100,
    Callback = function(Value)
        MovementSpeed = Value
        -- Update the player's walkspeed
        local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.WalkSpeed = MovementSpeed
        end
    end
})

-- Jump Power Slider
local JumpPower = 50 -- Default jump power
MovementSection:AddSlider({
    Name = "Jump Power",
    Flag = "MovementSection_JumpPower",
    Value = 50,
    Min = 0,
    Max = 200,
    Callback = function(Value)
        JumpPower = Value
        -- Update the player's jumppower
        local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.JumpPower = JumpPower
        end
    end
})

-- Automatically update walkspeed and jumppower when the player's character changes
LocalPlayer.CharacterAdded:Connect(function(Character)
    local Humanoid = Character:WaitForChild("Humanoid")
    Humanoid.WalkSpeed = MovementSpeed
    Humanoid.JumpPower = JumpPower
end)

-- No Clip and Fly Section
local NoClipFlySection = MovementTab:CreateSection({
    Name = "No Clip and Fly"
})

-- No Clip Toggle
local NoClipEnabled = false
NoClipFlySection:AddToggle({
    Name = "Enable No Clip",
    Flag = "NoClipFlySection_NoClip",
    Callback = function(Value)
        NoClipEnabled = Value
        if NoClipEnabled then
            -- Enable No Clip
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            RunService.Stepped:Connect(function()
                if NoClipEnabled and LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            -- Disable No Clip
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

-- Fly Toggle
local FlyEnabled = false
local FlySpeed = 50 -- Default fly speed
local BodyVelocity -- Declare BodyVelocity outside the toggle callback

NoClipFlySection:AddToggle({
    Name = "Enable Fly",
    Flag = "NoClipFlySection_Fly",
    Callback = function(Value)
        FlyEnabled = Value
        if FlyEnabled then
            -- Enable Fly
            if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge) -- Allow full movement
                BodyVelocity.Parent = LocalPlayer.Character.PrimaryPart

                -- Fly logic
                local FlyConnection
                FlyConnection = RunService.Stepped:Connect(function()
                    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                        local Camera = workspace.CurrentCamera
                        local RootPart = LocalPlayer.Character.PrimaryPart
                        local LookVector = Camera.CFrame.LookVector
                        local RightVector = Camera.CFrame.RightVector

                        -- Reset velocity
                        BodyVelocity.Velocity = Vector3.new(0, 0, 0)

                        -- Movement based on input
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            BodyVelocity.Velocity = BodyVelocity.Velocity + LookVector * FlySpeed
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            BodyVelocity.Velocity = BodyVelocity.Velocity - LookVector * FlySpeed
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                            BodyVelocity.Velocity = BodyVelocity.Velocity - RightVector * FlySpeed
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            BodyVelocity.Velocity = BodyVelocity.Velocity + RightVector * FlySpeed
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            BodyVelocity.Velocity = BodyVelocity.Velocity + Vector3.new(0, FlySpeed, 0)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            BodyVelocity.Velocity = BodyVelocity.Velocity - Vector3.new(0, FlySpeed, 0)
                        end
                    else
                        -- Disconnect the fly connection if fly is disabled
                        FlyConnection:Disconnect()
                    end
                end)
            end
        else
            -- Disable Fly
            if BodyVelocity then
                BodyVelocity:Destroy()
            end
        end
    end
})

-- Fly Speed Slider
NoClipFlySection:AddSlider({
    Name = "Fly Speed",
    Flag = "NoClipFlySection_FlySpeed",
    Value = 50,
    Min = 0,
    Max = 200,
    Callback = function(Value)
        FlySpeed = Value
    end
})