local funcs = loadstring(game:HttpGet("https://raw.githubusercontent.com/ostkakan1337/script/refs/heads/main/functions.lua"))()
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ostkakan1337/script/refs/heads/main/ui.lua"))()
local Wait = library.subs.Wait

-- Load the ESP system as a library
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/ostkakan1337/script/refs/heads/main/ESP.lua"))()

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

-- ESP Tab
local ESPTab = PepsisWorld:CreateTab({
    Name = "ESP"
})

local ESPSection = ESPTab:CreateSection({
    Name = "ESP Settings"
})

-- Enable/Disable ESP
ESPSection:AddToggle({
    Name = "Enable ESP",
    Flag = "ESPSection_EnableESP",
    Default = false, -- ESP is disabled by default
    Callback = function(Value)
        if Value then
            ESP:Initialize() -- Initialize ESP if enabled
        else
            ESP:Destroy() -- Destroy ESP if disabled
        end
    end
})

-- Team Check
ESPSection:AddToggle({
    Name = "Team Check",
    Flag = "ESPSection_TeamCheck",
    Callback = function(Value)
        ESP.TeamCheck = Value
        ESP:UpdateSettings() -- Update ESP settings
    end
})

-- Max Distance
ESPSection:AddSlider({
    Name = "Max Distance",
    Flag = "ESPSection_MaxDistance",
    Value = 200,
    Min = 0,
    Max = 1000,
    Callback = function(Value)
        ESP.MaxDistance = Value
        ESP:UpdateSettings() -- Update ESP settings
    end
})

-- Font Size
ESPSection:AddSlider({
    Name = "Font Size",
    Flag = "ESPSection_FontSize",
    Value = 11,
    Min = 8,
    Max = 20,
    Callback = function(Value)
        ESP.FontSize = Value
        ESP:UpdateSettings() -- Update ESP settings
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
        ESP:UpdateSettings() -- Update ESP settings
    end
})

ChamsSection:AddToggle({
    Name = "Thermal Effect",
    Flag = "ChamsSection_ThermalEffect",
    Callback = function(Value)
        ESP.Drawing.Chams.Thermal = Value
        ESP:UpdateSettings() -- Update ESP settings
    end
})

ChamsSection:AddColorPicker({
    Name = "Chams Fill Color",
    Flag = "ChamsSection_FillColor",
    Color = Color3.fromRGB(119, 120, 255),
    Callback = function(Value)
        ESP.Drawing.Chams.FillRGB = Value
        ESP:UpdateSettings() -- Update ESP settings
    end
})

ChamsSection:AddColorPicker({
    Name = "Chams Outline Color",
    Flag = "ChamsSection_OutlineColor",
    Color = Color3.fromRGB(119, 120, 255),
    Callback = function(Value)
        ESP.Drawing.Chams.OutlineRGB = Value
        ESP:UpdateSettings() -- Update ESP settings
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
        ESP:UpdateSettings() -- Update ESP settings
    end
})

NamesSection:AddColorPicker({
    Name = "Names Color",
    Flag = "NamesSection_NamesColor",
    Color = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        ESP.Drawing.Names.RGB = Value
        ESP:UpdateSettings() -- Update ESP settings
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
        ESP:UpdateSettings() -- Update ESP settings
    end
})

DistancesSection:AddDropdown({
    Name = "Distance Position",
    Flag = "DistancesSection_DistancePosition",
    List = {"Bottom", "Text"},
    Default = "Text",
    Callback = function(Value)
        ESP.Drawing.Distances.Position = Value
        ESP:UpdateSettings() -- Update ESP settings
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
        ESP:UpdateSettings() -- Update ESP settings
    end
})

WeaponsSection:AddColorPicker({
    Name = "Weapon Text Color",
    Flag = "WeaponsSection_WeaponTextColor",
    Color = Color3.fromRGB(119, 120, 255),
    Callback = function(Value)
        ESP.Drawing.Weapons.WeaponTextRGB = Value
        ESP:UpdateSettings() -- Update ESP settings
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
        ESP:UpdateSettings() -- Update ESP settings
    end
})

HealthbarSection:AddToggle({
    Name = "Show Health Text",
    Flag = "HealthbarSection_ShowHealthText",
    Callback = function(Value)
        ESP.Drawing.Healthbar.HealthText = Value
        ESP:UpdateSettings() -- Update ESP settings
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
        ESP:UpdateSettings() -- Update ESP settings
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
        ESP:UpdateSettings() -- Update ESP settings
    end
})

BoxesSection:AddToggle({
    Name = "Animate Boxes",
    Flag = "BoxesSection_AnimateBoxes",
    Callback = function(Value)
        ESP.Drawing.Boxes.Animate = Value
        ESP:UpdateSettings() -- Update ESP settings
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
        ESP:UpdateSettings() -- Update ESP settings
    end
})

-- Load Configuration
pcall(function()
    library:LoadConfiguration()
end)