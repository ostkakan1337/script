local Workspace, RunService, Players, CoreGui, Lighting = cloneref(game:GetService("Workspace")), cloneref(game:GetService("RunService")), cloneref(game:GetService("Players")), game:GetService("CoreGui"), cloneref(game:GetService("Lighting"))

local ESP = {
    Enabled = false, -- Start with ESP disabled
    TeamCheck = false,
    MaxDistance = 200,
    FontSize = 11,
    FadeOut = {
        OnDistance = false,
        OnDeath = false,
        OnLeave = false,
    },
    Options = { 
        Teamcheck = false, TeamcheckRGB = Color3.fromRGB(0, 255, 0),
        Friendcheck = false, FriendcheckRGB = Color3.fromRGB(0, 255, 0),
        Highlight = false, HighlightRGB = Color3.fromRGB(255, 0, 0),
    },
    Drawing = {
        Chams = {
            Enabled  = false,
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
            Gradient = false, GradientRGB1 = Color3.fromRGB(200, 0, 0), GradientRGB2 = Color3.fromRGB(60, 60, 125), GradientRGB3 = Color3.fromRGB(119, 120, 255), 
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
        };
    };
    Connections = {
        RunService = RunService;
    };
    Fonts = {};
}

-- Def & Vars
local Euphoria = ESP.Connections;
local lplayer = Players.LocalPlayer;
local camera = game.Workspace.CurrentCamera;
local Cam = Workspace.CurrentCamera;
local RotationAngle, Tick = -45, tick();

-- Weapon Images
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
};

-- Functions
local Functions = {}
do
    function Functions:Create(Class, Properties)
        local _Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
        for Property, Value in pairs(Properties) do
            _Instance[Property] = Value
        end
        return _Instance;
    end
    --
    function Functions:FadeOutOnDist(element, distance)
        local transparency = math.max(0.1, 1 - (distance / ESP.MaxDistance))
        if element:IsA("TextLabel") then
            element.TextTransparency = 1 - transparency
        elseif element:IsA("ImageLabel") then
            element.ImageTransparency = 1 - transparency
        elseif element:IsA("UIStroke") then
            element.Transparency = 1 - transparency
        elseif element:IsA("Frame") and (element == Healthbar or element == BehindHealthbar) then
            element.BackgroundTransparency = 1 - transparency
        elseif element:IsA("Frame") then
            element.BackgroundTransparency = 1 - transparency
        elseif element:IsA("Highlight") then
            element.FillTransparency = 1 - transparency
            element.OutlineTransparency = 1 - transparency
        end;
    end;  
end;

-- Initialize ESP
function ESP:Initialize()
    if self.Enabled then return end -- Avoid re-initializing if already enabled
    self.Enabled = true

    -- Create the ESP holder
    self.ScreenGui = Functions:Create("ScreenGui", {
        Parent = CoreGui,
        Name = "ESPHolder",
    });

    -- Start ESP for all players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lplayer then
            coroutine.wrap(self.CreateESP)(player)
        end
    end

    -- Listen for new players
    Players.PlayerAdded:Connect(function(player)
        coroutine.wrap(self.CreateESP)(player)
    end)
end

-- Destroy ESP
function ESP:Destroy()
    if not self.Enabled then return end -- Avoid destroying if already disabled
    self.Enabled = false

    -- Remove the ESP holder
    if self.ScreenGui then
        self.ScreenGui:Destroy()
        self.ScreenGui = nil
    end
end

-- Create ESP for a player
function ESP:CreateESP(plr)
    if not self.Enabled then return end

    local character = plr.Character
    if not character then return end

    -- Create ESP elements (Highlight, BillboardGui, etc.)
    local highlight = Functions:Create("Highlight", {
        Parent = self.ScreenGui,
        Adornee = character,
        FillColor = self.Drawing.Chams.FillRGB,
        OutlineColor = self.Drawing.Chams.OutlineRGB,
        FillTransparency = 0.5,
        OutlineTransparency = 0,
    })

    local billboard = Functions:Create("BillboardGui", {
        Parent = self.ScreenGui,
        Adornee = character.PrimaryPart,
        Size = UDim2.new(0, 200, 0, 50),
        StudsOffset = Vector3.new(0, 2, 0),
    })

    local textLabel = Functions:Create("TextLabel", {
        Parent = billboard,
        Text = plr.Name,
        TextColor3 = self.Drawing.Names.RGB,
        TextSize = self.FontSize,
        BackgroundTransparency = 1,
    })

    -- Store ESP elements for later removal
    self.ESPObjects[plr] = {highlight, billboard}
end

-- Update ESP settings
function ESP:UpdateSettings()
    if not self.Enabled then return end

    -- Update ESP elements for all players
    for player, espObjects in pairs(self.ESPObjects) do
        local highlight, billboard = unpack(espObjects)
        highlight.FillColor = self.Drawing.Chams.FillRGB
        highlight.OutlineColor = self.Drawing.Chams.OutlineRGB
        billboard.TextLabel.TextColor3 = self.Drawing.Names.RGB
        billboard.TextLabel.TextSize = self.FontSize
    end
end

-- Initialize ESP objects table
ESP.ESPObjects = {}

-- Initialize ESP if enabled by default
if ESP.Enabled then
    ESP:Initialize()
end

return ESP