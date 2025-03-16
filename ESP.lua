local ESP = {}
ESP.Enabled = false
ESP.TeamCheck = false
ESP.MaxDistance = 200
ESP.FontSize = 11

-- Color settings
ESP.Drawing = {
    Names = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
    Boxes = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
    Healthbar = { Enabled = false, Width = 2.5, Gradient = false },
    Distances = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
    Weapons = { Enabled = false, Color = Color3.fromRGB(119, 120, 255) },
    Chams = { Enabled = false, FillColor = Color3.fromRGB(119, 120, 255), OutlineColor = Color3.fromRGB(119, 120, 255) }
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Function to create ESP elements
function ESP:CreateESP(Player)
    local Character = Player.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end

    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Color = ESP.Drawing.Boxes.Color
    Box.Visible = false

    local Name = Drawing.new("Text")
    Name.Size = ESP.FontSize
    Name.Color = ESP.Drawing.Names.Color
    Name.Outline = true
    Name.Visible = false

    local Distance = Drawing.new("Text")
    Distance.Size = ESP.FontSize
    Distance.Color = ESP.Drawing.Distances.Color
    Distance.Outline = true
    Distance.Visible = false

    local Healthbar = Drawing.new("Line")
    Healthbar.Visible = false

    local Chams = Instance.new("Highlight")
    Chams.Parent = game.CoreGui
    Chams.FillColor = ESP.Drawing.Chams.FillColor
    Chams.OutlineColor = ESP.Drawing.Chams.OutlineColor
    Chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Chams.Enabled = false

    local function UpdateESP()
        if ESP.Enabled and Character and Character:FindFirstChild("HumanoidRootPart") then
            local HumanoidRootPart = Character.HumanoidRootPart
            local Humanoid = Character:FindFirstChild("Humanoid")
            local Position, OnScreen = Camera:WorldToViewportPoint(HumanoidRootPart.Position)
            local DistanceFromPlayer = (Camera.CFrame.Position - HumanoidRootPart.Position).Magnitude

            if OnScreen and DistanceFromPlayer <= ESP.MaxDistance then
                local Size = math.clamp(400 / DistanceFromPlayer, 10, 50)

                -- Box ESP
                if ESP.Drawing.Boxes.Enabled then
                    Box.Size = Vector2.new(Size, Size * 1.5)
                    Box.Position = Vector2.new(Position.X - Size / 2, Position.Y - Size / 2)
                    Box.Visible = true
                else
                    Box.Visible = false
                end

                -- Name ESP
                if ESP.Drawing.Names.Enabled then
                    Name.Position = Vector2.new(Position.X, Position.Y - Size / 2 - 15)
                    Name.Text = Player.Name
                    Name.Visible = true
                else
                    Name.Visible = false
                end

                -- Distance ESP
                if ESP.Drawing.Distances.Enabled then
                    Distance.Position = Vector2.new(Position.X, Position.Y + Size / 2 + 5)
                    Distance.Text = string.format("[%d m]", math.floor(DistanceFromPlayer))
                    Distance.Visible = true
                else
                    Distance.Visible = false
                end

                -- Healthbar ESP
                if ESP.Drawing.Healthbar.Enabled and Humanoid then
                    local HealthRatio = Humanoid.Health / Humanoid.MaxHealth
                    Healthbar.From = Vector2.new(Position.X - Size / 2 - 5, Position.Y - Size / 2)
                    Healthbar.To = Vector2.new(Position.X - Size / 2 - 5, Position.Y + Size / 2 * (1 - HealthRatio))
                    Healthbar.Color = Color3.fromRGB(255 * (1 - HealthRatio), 255 * HealthRatio, 0)
                    Healthbar.Visible = true
                else
                    Healthbar.Visible = false
                end

                -- Chams ESP
                if ESP.Drawing.Chams.Enabled then
                    Chams.Adornee = Character
                    Chams.Enabled = true
                else
                    Chams.Enabled = false
                end
            else
                Box.Visible = false
                Name.Visible = false
                Distance.Visible = false
                Healthbar.Visible = false
                Chams.Enabled = false
            end
        else
            Box.Visible = false
            Name.Visible = false
            Distance.Visible = false
            Healthbar.Visible = false
            Chams.Enabled = false
        end
    end

    RunService.RenderStepped:Connect(UpdateESP)
end

-- Function to enable ESP for all players
function ESP:Initialize()
    ESP.Enabled = true
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            ESP:CreateESP(Player)
        end
    end
    Players.PlayerAdded:Connect(function(Player)
        ESP:CreateESP(Player)
    end)
end

-- Function to disable ESP
function ESP:Destroy()
    ESP.Enabled = false
end

return ESP
