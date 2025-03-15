-- Services
local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = game:GetService("CoreGui")
local Lighting = cloneref(game:GetService("Lighting"))

-- ESP Module
local ESP = {
    Enabled = false, -- Disabled by default
    TeamCheck = false,
    MaxDistance = 200,
    FontSize = 11,
    FadeOut = {
        OnDistance = false,
        OnDeath = false,
        OnLeave = false,
    },
    Drawing = {
        Chams = {
            Enabled = false,
            Thermal = false,
            FillRGB = Color3.fromRGB(119, 120, 255),
            Fill_Transparency = 100,
            OutlineRGB = Color3.fromRGB(119, 120, 255),
            Outline_Transparency = 100,
            VisibleCheck = false,
        },
        Names = {
            Enabled = false,
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Flags = {
            Enabled = false,
        },
        Distances = {
            Enabled = false,
            Position = "Text",
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Weapons = {
            Enabled = false, WeaponTextRGB = Color3.fromRGB(119, 120, 255),
            Outlined = false,
            Gradient = false,
            GradientRGB1 = Color3.fromRGB(255, 255, 255), GradientRGB2 = Color3.fromRGB(119, 120, 255),
        },
        Healthbar = {
            Enabled = false,
            HealthText = false, Lerp = false, HealthTextRGB = Color3.fromRGB(119, 120, 255),
            Width = 2.5,
            Gradient = true, GradientRGB1 = Color3.fromRGB(200, 0, 0), GradientRGB2 = Color3.fromRGB(60, 60, 125), GradientRGB3 = Color3.fromRGB(119, 120, 255),
        },
        Boxes = {
            Animate = false,
            RotationSpeed = 300,
            Gradient = false, GradientRGB1 = Color3.fromRGB(119, 120, 255), GradientRGB2 = Color3.fromRGB(0, 0, 0),
            GradientFill = false, GradientFillRGB1 = Color3.fromRGB(119, 120, 255), GradientFillRGB2 = Color3.fromRGB(0, 0, 0),
            Filled = {
                Enabled = false,
                Transparency = 0.75,
                RGB = Color3.fromRGB(0, 0, 0),
            },
            Full = {
                Enabled = false,
                RGB = Color3.fromRGB(255, 255, 255),
            },
            Corner = {
                Enabled = false,
                RGB = Color3.fromRGB(255, 255, 255),
            },
        },
    },
    Connections = {
        RunService = RunService,
    },
    Fonts = {},
    Elements = {},
}

-- Local Variables
local lplayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local RotationAngle, Tick = -45, tick()

-- Weapon Icons
local Weapon_Icons = {
    ["Wooden Bow"] = "http://www.roblox.com/asset/?id=17677465400",
    ["Crossbow"] = "http://www.roblox.com/asset/?id=17677473017",
    ["Salvaged SMG"] = "http://www.roblox.com/asset/?id=17677463033",
    ["Salvaged AK47"] = "http://www.roblox.com/asset/?id=17677455113",
    ["Salvaged AK74u"] = "http://www.roblox.com/asset/?id=17677442346",
    ["Salvaged M14"] = "http://www.roblox.com/asset/?id=17677444642",
    ["Salvaged Python"] = "http://www.roblox.com/asset/?id=17677451737",
    ["Military PKM"] = "http://www.roblox.com/asset/?id=17677449448",
    ["Military M4A1"] = "http://www.roblox.com/asset/?id=17677479536",
    ["Bruno's M4A1"] = "http://www.roblox.com/asset/?id=17677471185",
    ["Military Barrett"] = "http://www.roblox.com/asset/?id=17677482998",
    ["Salvaged Skorpion"] = "http://www.roblox.com/asset/?id=17677459658",
    ["Salvaged Pump Action"] = "http://www.roblox.com/asset/?id=17677457186",
    ["Military AA12"] = "http://www.roblox.com/asset/?id=17677475227",
    ["Salvaged Break Action"] = "http://www.roblox.com/asset/?id=17677468751",
    ["Salvaged Pipe Rifle"] = "http://www.roblox.com/asset/?id=17677468751",
    ["Salvaged P250"] = "http://www.roblox.com/asset/?id=17677447257",
    ["Nail Gun"] = "http://www.roblox.com/asset/?id=17677484756"
}

-- Functions
local Functions = {}
function Functions:Create(Class, Properties)
    local _Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
    for Property, Value in pairs(Properties) do
        _Instance[Property] = Value
    end
    return _Instance
end

function Functions:FadeOutOnDist(element, distance)
    local transparency = math.max(0.1, 1 - (distance / ESP.MaxDistance))
    if element:IsA("TextLabel") then
        element.TextTransparency = 1 - transparency
    elseif element:IsA("ImageLabel") then
        element.ImageTransparency = 1 - transparency
    elseif element:IsA("UIStroke") then
        element.Transparency = 1 - transparency
    elseif element:IsA("Frame") then
        element.BackgroundTransparency = 1 - transparency
    elseif element:IsA("Highlight") then
        element.FillTransparency = 1 - transparency
        element.OutlineTransparency = 1 - transparency
    end
end

-- Initialize ESP
function ESP:Initialize()
    if self.Enabled then return end
    self.Enabled = true
    print("ESP initialized")
end

-- Destroy ESP
function ESP:Destroy()
    if not self.Enabled then return end
    self.Enabled = false
    for _, element in pairs(self.Elements) do
        element:Destroy()
    end
    self.Elements = {}
    print("ESP destroyed")
end

-- Update ESP Settings
function ESP:UpdateSettings()
    if not self.Enabled then return end
    for _, element in pairs(self.Elements) do
        element.Visible = self.Drawing.Names.Enabled
    end
    print("ESP settings updated")
end

-- Main ESP Function
local function CreateESP(plr)
    local Name = Functions:Create("TextLabel", {
        Parent = CoreGui,
        Position = UDim2.new(0.5, 0, 0, -11),
        Size = UDim2.new(0, 100, 0, 20),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.Code,
        TextSize = ESP.FontSize,
        TextStrokeTransparency = 0,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        RichText = true
    })
    table.insert(ESP.Elements, Name)

    -- Add other elements (Distance, Weapon, Healthbar, etc.) similarly

    local function UpdateESP()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local HRP = plr.Character.HumanoidRootPart
            local Pos, OnScreen = camera:WorldToScreenPoint(HRP.Position)
            local Dist = (camera.CFrame.Position - HRP.Position).Magnitude / 3.5714285714

            if OnScreen and Dist <= ESP.MaxDistance then
                Name.Visible = ESP.Drawing.Names.Enabled
                Name.Text = plr.Name
                Name.Position = UDim2.new(0, Pos.X, 0, Pos.Y - 20)
            else
                Name.Visible = false
            end
        else
            Name.Visible = false
        end
    end

    RunService.RenderStepped:Connect(UpdateESP)
end

-- Initialize ESP for all players
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= lplayer then
        CreateESP(plr)
    end
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(plr)
    for _, element in pairs(ESP.Elements) do
        if element.Name == plr.Name then
            element:Destroy()
        end
    end
end)

-- Main ESP Update Loop
RunService.RenderStepped:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= lplayer then
            UpdateESP(plr)
        end
    end
end)

-- UI Library Integration
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
        ESP:Destroy()
        library:Unload()
    end
})

-- ESP Tab
local ESPTab = PepsisWorld:CreateTab({
    Name = "ESP"
})

-- Enable/Disable ESP
local ESPSection = ESPTab:CreateSection({
    Name = "ESP Settings"
})

ESPSection:AddToggle({
    Name = "Enable ESP",
    Flag = "ESPSection_EnableESP",
    Default = false,
    Callback = function(Value)
        if Value then
            ESP:Initialize()
        else
            ESP:Destroy()
        end
    end
})

ESPSection:AddToggle({
    Name = "Team Check",
    Flag = "ESPSection_TeamCheck",
    Callback = function(Value)
        ESP.TeamCheck = Value
        ESP:UpdateSettings()
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
        ESP:UpdateSettings()
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
        ESP:UpdateSettings()
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
        ESP:UpdateSettings()
    end
})

ChamsSection:AddToggle({
    Name = "Thermal Effect",
    Flag = "ChamsSection_ThermalEffect",
    Callback = function(Value)
        ESP.Drawing.Chams.Thermal = Value
        ESP:UpdateSettings()
    end
})

ChamsSection:AddColorPicker({
    Name = "Chams Fill Color",
    Flag = "ChamsSection_FillColor",
    Color = Color3.fromRGB(119, 120, 255),
    Callback = function(Value)
        ESP.Drawing.Chams.FillRGB = Value
        ESP:UpdateSettings()
    end
})

ChamsSection:AddColorPicker({
    Name = "Chams Outline Color",
    Flag = "ChamsSection_OutlineColor",
    Color = Color3.fromRGB(119, 120, 255),
    Callback = function(Value)
        ESP.Drawing.Chams.OutlineRGB = Value
        ESP:UpdateSettings()
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
        ESP:UpdateSettings()
    end
})

NamesSection:AddColorPicker({
    Name = "Names Color",
    Flag = "NamesSection_NamesColor",
    Color = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        ESP.Drawing.Names.RGB = Value
        ESP:UpdateSettings()
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
        ESP:UpdateSettings()
    end
})

DistancesSection:AddDropdown({
    Name = "Distance Position",
    Flag = "DistancesSection_DistancePosition",
    List = {"Bottom", "Text"},
    Default = "Text",
    Callback = function(Value)
        ESP.Drawing.Distances.Position = Value
        ESP:UpdateSettings()
    end
})

-- Weapons Settings
local WeaponsSection = ESPTab:CreateSection({
    Name = "Weapons Settings"
})

WeaponsSection:AddToggle({
    Name = "Enable Weapons",
    Flag = "WeaponsSection_EnableWeapons",
    Callback = function(Value)
        ESP.Drawing.Weapons.Enabled = Value
        ESP:UpdateSettings()
    end
})

WeaponsSection:AddColorPicker({
    Name = "Weapon Text Color",
    Flag = "WeaponsSection_WeaponTextColor",
    Color = Color3.fromRGB(119, 120, 255),
    Callback = function(Value)
        ESP.Drawing.Weapons.WeaponTextRGB = Value
        ESP:UpdateSettings()
    end
})

-- Healthbar Settings
local HealthbarSection = ESPTab:CreateSection({
    Name = "Healthbar Settings"
})

HealthbarSection:AddToggle({
    Name = "Enable Healthbar",
    Flag = "HealthbarSection_EnableHealthbar",
    Callback = function(Value)
        ESP.Drawing.Healthbar.Enabled = Value
        ESP:UpdateSettings()
    end
})

HealthbarSection:AddToggle({
    Name = "Show Health Text",
    Flag = "HealthbarSection_ShowHealthText",
    Callback = function(Value)
        ESP.Drawing.Healthbar.HealthText = Value
        ESP:UpdateSettings()
    end
})

HealthbarSection:AddSlider({
    Name = "Healthbar Width",
    Flag = "HealthbarSection_HealthbarWidth",
    Value = 2.5,
    Min = 1,
    Max = 5,
    Callback = function(Value)
        ESP.Drawing.Healthbar.Width = Value
        ESP:UpdateSettings()
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
        ESP.Drawing.Boxes.Full.Enabled = Value
        ESP:UpdateSettings()
    end
})

BoxesSection:AddToggle({
    Name = "Animate Boxes",
    Flag = "BoxesSection_AnimateBoxes",
    Callback = function(Value)
        ESP.Drawing.Boxes.Animate = Value
        ESP:UpdateSettings()
    end
})

BoxesSection:AddSlider({
    Name = "Rotation Speed",
    Flag = "BoxesSection_RotationSpeed",
    Value = 300,
    Min = 0,
    Max = 1000,
    Callback = function(Value)
        ESP.Drawing.Boxes.RotationSpeed = Value
        ESP:UpdateSettings()
    end
})