----- {{ Starting Checks;

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/g4s10r/Scripts/main/Linoria"))();

if (game.PlaceId ~= 443406476) then
    error(string.format("[SK22T] - Unsupported game"));
end

if not (listfiles or hookmetamethod or getcustomasset) then
    Library:Notify("[FATAL-ERROR] - Your exploit doesn't support required functions", math.huge);
    return;
end

if (not LPH_OBFUSCATED) then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Luraph/macrosdk/main/luraphsdk.lua"))()
end

----- {{ Includes;

local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/g4s10r/Scripts/refs/heads/main/ThemeManager"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/g4s10r/Scripts/refs/heads/main/SaveManager"))()
local Signal       = loadstring(game:HttpGet("https://raw.githubusercontent.com/g4s10r/Scripts/main/GoodSignal"))();

----- {{ Constants;

local Players      = cloneref(game:GetService("Players"));
local Workspace    = cloneref(game:GetService("Workspace"));
local RunService   = cloneref(game:GetService("RunService"));
local LogService   = cloneref(game:GetService("LogService"));
local HttpService  = cloneref(game:GetService("HttpService"));
local TweenService = cloneref(game:GetService("TweenService"));
local UserInput    = cloneref(game:GetService("UserInputService"));
local Storage      = cloneref(game:GetService("ReplicatedStorage"));
local Baddies      = cloneref(Workspace:FindFirstChild("Baddies"));
local Camera       = cloneref(Workspace.CurrentCamera);
local Client       = Players.LocalPlayer;

----- {{ Variables;

local RenderBinds = {"Gun", "Aimbot", "Loop"};
local Mouse       = Client:GetMouse();
local Interact    = Workspace:WaitForChild("Interact", 0.25);
local Ignore      = Workspace:WaitForChild("Ignore", 0.25);
local MysteryBox  = Interact:FindFirstChild("MysteryBox", true);
local Character   = Client.Character;

----- {{ Variable Table;

    local Sk22t = {
        Aimbot = {
            AutoKill = false,
            Autobot = {
                Enabled = false,
                MaxDistance = 500,
                TweenSpeed = 3,
                MaxMouseDistance = 65
            },
            Enabled = false,
            Hitbox = "Head",
            Wallbang = false,
            WallCheck = false,
            Radius = 0,
            Circle = {
                Visible = false,
                Color = Color3.new(1, 1, 1),
                Transparency = 1
            }
        },

        Visuals = {
            Highlight = {
                Enabled = false,
                HealthBased = false,
                FillColor = Color3.fromRGB(255, 0, 0),
                OutlineColor = Color3.fromRGB(255, 255, 255),
                MysteryBox = {
                    Enabled = false,
                    FillColor = Color3.fromRGB(255, 255, 0),
                    OutlineColor = Color3.fromRGB(255, 255, 255)
                },
            },
            Sound = {
                Enabled = false,
                Name = "Skeet",
                Volume = 0.5
            },
            Hitmarker = {
                Enabled = false,
                Duration = 0.2
            },
            Hitlog = {
                Enabled = false,
            },
            Viewmodel = {
                Enabled = false,
                Color = Color3.new(1, 1, 1),
                Material = "SmoothPlastic",
                FieldOfView = 70
            }
        },

        Mod = {
            Enabled = false,
            Damage = {
                On = false,
                Value = 1,
                OneShot = false,
            },
            Speed = {
                On = false,
                Value = 1
            },
            FireRate = {
                On = false,
                Value = 1
            },
            InfiniteAmmo = false,
            RemoveSpread = false,
            InstaEquip = false,
            FullAuto = false
        },

        Exploit = {
            InfiniteStamina = false,
            Points = 1000
        }
    }

----- {{ File System;

    local FileSystem = {};

    FileSystem.Sounds = {
        ["Bell.wav"] = base64_decode(game:HttpGet("https://sk22t.dev/hitsounds/Bell.txt"));
        ["Cod.wav"] = base64_decode(game:HttpGet("https://sk22t.dev/hitsounds/Cod.txt"));
        ["Fatality.wav"] = base64_decode(game:HttpGet("https://sk22t.dev/hitsounds/Fatality.txt"));
        ["Neverlose.wav"] = base64_decode(game:HttpGet("https://sk22t.dev/hitsounds/Neverlose.txt"));
        ["Primordial.wav"] = base64_decode(game:HttpGet("https://sk22t.dev/hitsounds/Primordial.txt"));
        ["Qbeep.wav"] = base64_decode(game:HttpGet("https://sk22t.dev/hitsounds/Qbeep.txt"));
        ["Rust.wav"] = base64_decode(game:HttpGet("https://sk22t.dev/hitsounds/Rust.txt"));
        ["Skeet.wav"] = base64_decode(game:HttpGet("https://sk22t.dev/hitsounds/Skeet.txt"));
        ["Star.wav"] = base64_decode(game:HttpGet("https://sk22t.dev/hitsounds/Star.txt"));
    }

    if not (isfolder("Sk22t.dev")) then
        makefolder("Sk22t.dev");
        if not (isfolder("Sk22t.dev/asset")) then
            makefolder("Sk22t.dev/asset");
            if not (isfolder("Sk22t.dev/asset/sound")) then
                makefolder("Sk22t.dev/asset/sound");
            end
        end
    end

    for Index, Sound in next, FileSystem.Sounds do
        if not (isfile(string.format("Sk22t.dev/asset/sound/%s", Index))) then
            writefile(string.format("Sk22t.dev/asset/sound/%s", Index), Sound);
        end
    end

------- }}

----- {{ Utility;

    local Utility = {};

    function Utility.Instance(ClassName, Properties)
        local Instance = Instance.new(ClassName);

        for Index, Value in next, Properties do 
            Instance[Index] = Value;
        end
        
        return Instance;
    end

    function Utility.Draw(Shape, Properties)
        assert(Shape ~= nil, "[Sk22t.dev] - Unknown or null drawing shape");
        Properties = Properties or {};
        
        local Drawing = Drawing.new(Shape);
        
        for Index, Value in next, Properties do 
            Drawing[Index] = Value;
        end

        return Drawing;
    end

    function Utility.RandomName()
        return HttpService:GenerateGUID(false):lower():sub(1, 6);
    end

    function Utility.Recursive(Table)
        for Index, Value in next, Table do
            print(Index, Value);
            
            if (type(Value) == "table") then
                Utility.Recursive(Value);
            end
        end
    end

    function Utility.CopyTable(Table)
        local New = {}

        for Index, Value in Table do
            New[Index] = (type(Value) == "table" and Utility.CopyTable(Value)) or Value;
        end

        return New;
    end

    function Utility.DictionaryLength(Table)
        local Total = 0;

        for Index, _ in  next, Table do
            Total += 1;
        end

        return Total;
    end

------- }}

----- {{ Folders;

    DirectoryFolder = Utility.Instance("Folder", {
        Parent = game.CoreGui;
        Name = "[Sk22t.dev]";
    });

    local WorkspaceFolder = Utility.Instance("Folder", {
        Parent = Workspace;
        Name = Utility.RandomName();
    });

    local SoundsFolder = Utility.Instance("Folder", {
        Parent = DirectoryFolder;
        Name = "Sounds";
    });

    local ActiveFolder = Utility.Instance("Folder", {
        Parent = SoundsFolder;
        Name = "Active";
    });

    local ModelsFolder = Utility.Instance("Folder", {
        Parent = DirectoryFolder;
        Name = "Models";
    });

    local HighlightFolder = Utility.Instance("Folder", {
        Parent = DirectoryFolder;
        Name = "Highlights";
    });

------- }}

----- {{ Connection System;

    local Connection = {
        Signals = {};
    };

    Connection.__index = Connection;

    function Connection.new(Signal, Function)
        assert(Signal ~= nil, "[Sk22t.dev] - Signal isn't specified");
        assert(Function ~= nil, "[Sk22t.dev] - Function isn't specified");

        local NewConnection = Signal:Connect(Function);

        Connection.Signals[Signal] = NewConnection;

        local NewSignal = {};
        NewSignal._signal = Signal;

        return setmetatable(NewSignal, {
            __index = Connection;
        });
    end

    function Connection:close(_Signal)
        if (type(_Signal) == "table") then
            if (_Signal._signal ~= nil and typeof(_Signal._signal) == "RBXScriptConnection") then
                _Signal:Disconnect();
            elseif (Signal.isSignal(_Signal)) then
                _Signal:DisconnectAll();
            end
        elseif (typeof(_Signal) == "RBXScriptConnection") then
            _Signal:Disconnect();
        end

        self.Signals[_Signal] = nil;
    end

    function Connection:closeall()
        local Signals = self.Signals;
        
        for _, Signal in next, Signals do
            self:close(Signal);
        end
    end

------- }}

----- {{ Anti-cheat bypass;

    if (hookfunction) then
        local OldGC; OldGC = hookfunction(getrenv().gcinfo, newcclosure(function()
            return math.random(900, 1200);
        end))
    end

    local Script = Client:FindFirstChildOfClass("LocalScript");
    if Script then Script:Remove(); end

    for _, Connection in next, getconnections(LogService.MessageOut) do
        if not (checkcaller()) then
            Connection:Disable();
        end
    end

------- }}

----- {{ Highlight System;

    local HighlightSettings = Sk22t.Visuals.Highlight;

    local Highlight = {
        Cache = {};
    };

    Highlight.__index = Highlight;

    function Highlight.new(Object, Options)
        Options = Options or {};

        local Instance = Utility.Instance("Highlight", {
            Parent = HighlightFolder;
        });

        local Meta = {};
        Meta.Instance = Object;
        Meta.noCallback = Options.noCallback or false;
        Meta.Highlight = Instance;
        Meta.Connections = {};

        for Index, Value in next, Options do
            if (Index ~= "noCallback") then
                Instance[Index] = Value;
            end
        end

        local Name = Utility.RandomName();
        Instance.Adornee = Object;
        Instance.Name = Name;
        
        Highlight.Cache[Name] = Meta;
        Highlight.Cache[Object] = true;

        return setmetatable(Meta, {
            __index = Highlight
        });
    end

    function Highlight:Update(Options)
        Options = Options or {};

        local Instance = self.Highlight;

        for Index, Value in next, Options do
            Instance[Index] = Value;
        end
    end

    function Highlight:Listen(Signal, Function)
        assert(Signal ~= nil, "[Sk22t.dev] - Signal isn't specified");
        assert(Function ~= nil, "[Sk22t.dev] - Function isn't specified");

        local Connection = Signal:Connect(Function);

        table.insert(self.Connections, Connection);

        return Connection;
    end

    function Highlight:Remove()
        if (self.Highlight:IsDescendantOf(HighlightFolder)) then
            for _, Connection in next, self.Connections do
                Connection:Disconnect();
            end
            
            Highlight.Cache[self.Highlight.Name] = nil;
            Highlight.Cache[self.Instance] = nil;

            self.Highlight:Remove();
        end
    end

    function Highlight:onHealthChange(Connection)
        local Health = self.Humanoid.Health;
        if (HighlightSettings.HealthBased) then
            self.Highlight.FillColor = Color3.fromHSV((0 + 120 * (Health / self.Humanoid.MaxHealth)) / 350, 1, 1);
            if (Health <= 0 and Connection) then
                Connection:Disconnect();
            end
        end
    end

    function Highlight.Callback(Index, Value)
        for _, Meta in next, Highlight.Cache do
            if (type(Meta) == "table" and not Meta.noCallback) then
                if (Value == "HB") then -- Health based
                    Meta:Update({
                        [Index] = Meta:onHealthChange()
                    });
                else
                    if (Index == "FillColor" and HighlightSettings.HealthBased) then return end;

                    Meta:Update({
                        [Index] = Value
                    });
                end
            end
        end
    end

    function Highlight.BindToZombie(Zombie)
        local NewHighlight = Highlight.new(Zombie, {
            Enabled = HighlightSettings.Enabled;
            FillColor = HighlightSettings.FillColor;
            OutlineColor = HighlightSettings.OutlineColor;
        })

        NewHighlight.Humanoid = NewHighlight.Instance:WaitForChild("Humanoid", 1);

        NewHighlight.FillColor = ((NewHighlight:onHealthChange() and HighlightSettings.HealthBased) or HighlightSettings.FillColor);

        local Connection = NewHighlight:Listen(NewHighlight.Humanoid:GetPropertyChangedSignal("Health"), function()
            if (HighlightSettings.HealthBased) then
                NewHighlight:onHealthChange();
            end
        end)

        Zombie.AncestryChanged:Once(function()        
            NewHighlight:Remove();
        end)

        return NewHighlight;
    end

------- }}

----- {{ Game Related Functions;

    local Game = {};
    Game.Functions = {};

    local WeaponScript = Character:FindFirstChild("WeaponScript") or nil;
    local BoxSettings = Sk22t.Visuals.Highlight.MysteryBox;
    local DamageKey = nil;
    local BoxHighlight;

    -- Anti-AFK
    for _, Connection in next, getconnections(Client.Idled) do
        Connection:Disconnect();
    end

    function Game.GetFunction(Script, Name)
        if (Game.Functions[Name] ~= nil) then
            return Game.Functions[Name];
        end

        local Environment, Function = getsenv(Script), nil;

        if (Environment and Environment.Name ~= nil) then
            Function = Environment[Name];
            Game.Functions[Name] = Function;

            return Function;
        end

        for Index, Value in next, getgc() do
            if (type(Value) == "function") then
                if (getfenv(Value).script.Name == Script.Name and debug.getinfo(Value).name == Name) then
                    Function = Value;
                    break;
                end
            end
        end

        Game.Functions[Name] = Function;

        return Function;
    end

    function Game.IsAlive()
        return ((Character ~= nil and Character:FindFirstChild("Humanoid")) and Character.Humanoid.Health > 0) or false;
    end

    function Game.GetDamageKey()
        if (DamageKey ~= nil) then
            return DamageKey;
        end

        for _, Value in next, getgc() do
            if (type(Value) == "function" and debug.getinfo(Value).name == "Knife") then
                for _, Key in next, debug.getupvalues(Value) do
                    if (type(Key) == "number") then
                        return Key;
                    end
                end
            end
        end
    end

    if not (BoxHighlight) then
        MysteryBox = Interact:WaitForChild("MysteryBox", 1);
        
        if (MysteryBox) then
            BoxHighlight = Highlight.new(MysteryBox, {
                Enabled = BoxSettings.Enabled;
                FillColor = BoxSettings.FillColor;
                OutlineColor = BoxSettings.OutlineColor;
                noCallback = true;
            })
        end
    end

    function Game.onRespawn()
        table.clear(Game.Functions);

        WeaponScript = Character:WaitForChild("WeaponScript", 1);
        if (WeaponScript) then
            Game.GetFunction(WeaponScript, "OnReloadInput");
            Game.GetFunction(WeaponScript, "OnFireWeaponInput");
            Game.GetFunction(WeaponScript, "Sprint");
        end
    end

    if (Game.IsAlive()) then
        Game.onRespawn();
    end

    function Game.onMapChange()
        MysteryBox = Interact:WaitForChild("MysteryBox", 1);
        Ignore = Workspace:WaitForChild("Ignore", 1);

        if not (BoxHighlight) then            
            if (MysteryBox) then
                BoxHighlight = Highlight.new(MysteryBox, {
                    Enabled = BoxSettings.Enabled;
                    FillColor = BoxSettings.FillColor;
                    OutlineColor = BoxSettings.OutlineColor;
                    noCallback = true;
                })
            end
        end

        BoxHighlight:Update({
            Adornee = MysteryBox;
        })
    end

    function Game.KillAll()
        coroutine.wrap(function()
            for _, Zombie in next, Baddies:GetChildren() do
                local Humanoid = Zombie:FindFirstChild("Humanoid");
                if (Humanoid and Humanoid:FindFirstChild("Damage")) then
                    Humanoid.Damage:FireServer({
                        ["Damage"] = math.huge,
                        ["WeaponName"] = "Beretta M9",
                        ["Force"] = 0,
                        ["GibPower"] = 0,
                        ["BodyPart"] = Zombie.HeadBox
                    }, (DamageKey or Game.GetDamageKey()));
                end
            end
        end)();
    end

    function Game.GetPoints(Point)
        local Zombie = Baddies:FindFirstChild("Zombie", true);

        if (Zombie ~= nil) then
            local Remote = Zombie:FindFirstChild("Humanoid").Damage;
            local Amount = math.ceil(Point / 10);

            for Iteration = 1, Amount do
                if not (Zombie:IsDescendantOf(game)) then
                    return;
                end

                Remote:FireServer({
                    ["Damage"] = 0,
                    ["WeaponName"] = "Beretta M9",
                    ["Force"] = 0,
                    ["GibPower"] = 0,
                    ["BodyPart"] = Zombie.HeadBox
                }, (DamageKey or Game.GetDamageKey()));

                task.wait(0.0125);
            end
        end
    end
    
------- }}

----- {{ Gun System;

    local Default   = {};
    local Forbidden = {"Knife", "Bottle", "Revive Kit", "RemoveSlot", "Double Tap Root Beer", "Juggernog", "Mule Kick", "Quick Revive", "Speed Cola"};
    local Backpack  = Client.Backpack;
    local SlotNum   = Backpack.EquippedSlot;
    local Round     = Workspace:FindFirstChild("RoundNum");

    function GetGun()
        return getrenv()._G.Equipped or nil;
    end

    function GetRoundDamage()
        local Value = Round.Value or 1;
        if (Value < 10) then
            return (Value * 100) + 50;
        elseif (Value >= 10) then
            return math.ceil(950 * (1.10) ^ (Value - 9));
        end
    end

    local _GunSignal = Connection.new(Signal.new(), function(Arg, Options)
        if (Arg == "Set") then
            local Gun = Options[1];
            if not (Gun[Options[2]] == Options[3]) then
                rawset(Gun, Options[2], Options[3]);
            end
        end
        if (Arg == "Restore") then
            local Gun = Options[1];
            if (Gun.Ammo ~= math.huge and not Sk22t.Mod.InfiniteAmmo) then return end;
            Gun[Options[2]] = Default[Gun.WeaponName][Options[2]];
        end
        if (Arg == "RestoreAll") then
            if (Game.IsAlive() and getrenv()._G.Weapons ~= nil) then
                for _, Gun in next, getrenv()._G.Weapons do
                    for Index, Value in next, Gun do
                        Gun[Index] = Default[Gun.WeaponName][Index];
                    end
                end
            end
        end
        if (Arg == "Save") then
            local Gun = Options[1];
            if not (Default[Gun.WeaponName]) then
                Default[Gun.WeaponName] = {};
                for Index, Value in next, Gun do
                    if (type(Value) ~= "table") then
                        Default[Gun.WeaponName][Index] = Value;
                    else
                        Default[Gun.WeaponName][Index] = Utility.CopyTable(Value);
                    end
                end
            end
        end
    end)

    local GunSignal = _GunSignal._signal;

    RunService:BindToRenderStep("Gun", 300, LPH_NO_VIRTUALIZE(function()
        if (Game.IsAlive()) then
            local Gun = GetGun();
            if (Gun ~= nil) then
                if not (Default[Gun.WeaponName]) then
                    GunSignal:Fire("Save", {Gun});
                end

                xpcall(function()
                    if (Sk22t.Mod.Enabled and Gun ~= nil and not table.find(Forbidden, Gun.WeaponName)) then
                        local DefaultValues = Default[Gun.WeaponName];
                        -- Damage modifier
                        if (Sk22t.Mod.Damage.On) then
                            GunSignal:Fire("Set", {Gun.Damage, "Min", ((Sk22t.Mod.Damage.OneShot and math.huge) or (GetRoundDamage() * Sk22t.Mod.Damage.Value / 100))});
                            GunSignal:Fire("Set", {Gun.Damage, "Max", ((Sk22t.Mod.Damage.OneShot and math.huge) or (GetRoundDamage() * Sk22t.Mod.Damage.Value / 100))});
                        else
                            GunSignal:Fire("Set", {Gun.Damage, "Min", (DefaultValues.Damage.Min)});
                            GunSignal:Fire("Set", {Gun.Damage, "Max", (DefaultValues.Damage.Max)});
                        end
                        -- Infinite ammo
                        if (Sk22t.Mod.InfiniteAmmo) then
                            GunSignal:Fire("Set", {Gun, "Ammo", math.huge});
                        else
                            GunSignal:Fire("Restore", {Gun, "Ammo"});
                        end
                        -- Speed
                        GunSignal:Fire("Set", {Gun, "MoveSpeed", (Sk22t.Mod.Speed.On and Sk22t.Mod.Speed.Value) or DefaultValues.MoveSpeed});
                        -- Fire rate
                        GunSignal:Fire("Set", {Gun, "FireTime", (Sk22t.Mod.FireRate.On and Sk22t.Mod.FireRate.Value / 100) or DefaultValues.FireTime});
                        -- Full auto
                        GunSignal:Fire("Set", {Gun, "Semi", (Sk22t.Mod.FullAuto and false) or (not Sk22t.Mod.FullAuto and DefaultValues.Semi)});
                        -- Insta equip
                        GunSignal:Fire("Set", {Gun, "RaiseSpeed", ((Sk22t.Mod.InstaEquip and 0) or DefaultValues.RaiseSpeed)});
                        -- No spread
                        GunSignal:Fire("Set", {Gun, "GunKick", (Sk22t.Mod.RemoveSpread and 0) or DefaultValues.GunKick});
                        GunSignal:Fire("Set", {Gun.Spread, "Min", (Sk22t.Mod.RemoveSpread and 0) or DefaultValues.Spread.Min});
                        GunSignal:Fire("Set", {Gun.Spread, "Max", (Sk22t.Mod.RemoveSpread and 0) or DefaultValues.Spread.Max});
                        GunSignal:Fire("Set", {Gun.ViewKick.Pitch, "Min", (Sk22t.Mod.RemoveSpread and 0) or DefaultValues.ViewKick.Pitch.Min});
                        GunSignal:Fire("Set", {Gun.ViewKick.Pitch, "Max", (Sk22t.Mod.RemoveSpread and 0) or DefaultValues.ViewKick.Pitch.Max});
                        GunSignal:Fire("Set", {Gun.ViewKick.Yaw, "Min", (Sk22t.Mod.RemoveSpread and 0) or DefaultValues.ViewKick.Yaw.Min});
                        GunSignal:Fire("Set", {Gun.ViewKick.Yaw, "Max", (Sk22t.Mod.RemoveSpread and 0) or DefaultValues.ViewKick.Yaw.Max});
                    end
                end, function()
                    warn("[!] - Error in gun system, debug below");
                    print(string.format("\t- Gun Name: %s", Gun.WeaponName));
                end) 
            end
        end
    end))

------- }}

----- {{ Aimbot;

    local ScreenCenter;

    function GetChance(Percentage)
        return math.random(0, 99) < Percentage;
    end

    function OnScreen(Object)
        local _, OnScreen = Camera:WorldToScreenPoint(Object.Position);
        return OnScreen;
    end

    function GetScreenCenter()
        return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2);
    end

    function GetDirection(Origin, Position)
        return (Position - Origin).Unit * 1000;
    end

    function GetMagnitudeFromMouse(Object) -- Takes magnitude from center of screen, not mouse currently
        local Position, OnScreen = Camera:WorldToScreenPoint(Object.Position);
        if (OnScreen) then
            local ScreenPos = ScreenCenter;
            local Magnitude = (Vector2.new(Position.X, Position.Y) - ScreenPos).Magnitude;
            return Magnitude;
        end
        return math.huge;
    end

    function WallCheck(Position)
        local Ignore  = {Character, Camera, Workspace.Ignore};
        local Obscuring = Camera:GetPartsObscuringTarget({Position}, Ignore);

        for Index, Object in next, Obscuring do
            if (Object.Transparency == 1) then
                Obscuring[Index] = nil;
            end
        end

        return not (#Obscuring > 0);
    end

    function GetClosest(Folder)
        local Target  = nil;
        local Closest = math.huge;
        local Hitbox  = Sk22t.Aimbot.Hitbox;

        for _, Object in next, Folder:GetChildren() do
            if (Object:FindFirstChild("HumanoidRootPart") and Object:FindFirstChild("Humanoid") and Object.Humanoid.Health > 0) then
                local Hitbox = Object[Sk22t.Aimbot.Hitbox] or Object.HumanoidRootPart;
                local Distance = GetMagnitudeFromMouse(Hitbox);
                if (not OnScreen(Hitbox)) then continue end
                if (Sk22t.Aimbot.WallCheck and not WallCheck(Hitbox.Position)) then continue end
                if (Sk22t.Aimbot.Radius + (Distance * 0.3) < Distance) then continue end

                if (Distance < Closest) then
                    Closest = Distance;
                    Target = Object;
                end
            end
        end

        return Target;
    end

    function GetClosestToCharacter(Folder)
        local Target  = nil;
        local Closest = math.huge;

        for _, Object in next, Folder:GetChildren() do
            if (Object:FindFirstChild("HumanoidRootPart") and Object:FindFirstChild("Humanoid") and Object.Humanoid.Health > 0) then
                local Hitbox = Object[Sk22t.Aimbot.Hitbox] or Object.HumanoidRootPart;
                local Distance = (Character.HumanoidRootPart.Position - Object.HumanoidRootPart.Position).Magnitude;
                if (Sk22t.Aimbot.Autobot.MaxDistance < Distance) then continue end
                if (not WallCheck(Hitbox.Position)) then continue end

                if (Distance < Closest) then
                    Closest = Distance;
                    Target = Object;
                end
            end
        end
        
        return Target;
    end
    
    ScreenCenter = GetScreenCenter();

    function Shoot()
        local Gun = GetGun();
        local FireFn = Game.Functions.OnFireWeaponInput or Game.GetFunction(WeaponScript, "OnFireWeaponInput");
        local ReloadFn = Game.Functions.OnReloadInput or Game.GetFunction(WeaponScript, "OnReloadInput");

        if (Gun ~= nil) then
            local Ammo = Gun.Ammo;
            if (Ammo == 0) then        
                if (ReloadFn ~= nil) then
                    coroutine.wrap(function()
                        local EnumReload = {
                            UserInputType = Enum.UserInputType.Keyboard,
                            KeyCode = Enum.KeyCode.R,
                            UserInputState = Enum.UserInputState.Begin,
                        };

                        task.defer(ReloadFn, EnumReload);

                        task.delay(0.05, function()
                            EnumReload.UserInputState = Enum.UserInputState.End;
                        end)
                    end)();
                end
                
                repeat task.wait(0.1) until Ammo > 0;
            end
        end

        if (FireFn ~= nil) then
            coroutine.wrap(function()
                local EnumShoot = {
                    UserInputType = Enum.UserInputType.MouseButton1,
                    UserInputState = Enum.UserInputState.Begin,
                };

                task.defer(FireFn, EnumShoot);

                task.delay(0.05, function()
                    EnumShoot.UserInputState = Enum.UserInputState.End;
                end)
            end)();
        end
    end

    function Aim(Vector)
        if (WallCheck(Vector)) then
            local Time = math.min(((Camera.CFrame.Position - Vector).Magnitude / (200 + (Sk22t.Aimbot.Autobot.TweenSpeed * 50))), 0.5);

            Tween = TweenService:Create(Camera, TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                CFrame = CFrame.new(Camera.CFrame.Position, Vector)
            }):Play();
            
            local Position, _ = Camera:WorldToViewportPoint(Vector);
            if ((Vector2.new(ScreenCenter.X, ScreenCenter.Y) - Vector2.new(Position.X, Position.Y)).Magnitude < Sk22t.Aimbot.Autobot.MaxMouseDistance) then
                Shoot();
            end
        end
    end

    local Circle = Utility.Draw("Circle", {
        Position = ScreenCenter,
        Visible = false,
        Radius = 0,
        Color = Color3.new(1, 1, 1),
    });

    RunService:BindToRenderStep("Aimbot", 199, LPH_NO_VIRTUALIZE(function()
        if (Game.IsAlive() and Sk22t.Aimbot.Autobot.Enabled) then
            local Target = GetClosestToCharacter(Baddies);
            if (Target ~= nil) then
                local Head = Target:FindFirstChild("Head");
                if (Head) then
                    Aim(Head.Position + (Head.AssemblyLinearVelocity * 0.1));
                end
            end
        end
        
        Circle.Visible = (Game.IsAlive() and Sk22t.Aimbot.Circle.Visible and Sk22t.Aimbot.Enabled) or false;
        if (Sk22t.Aimbot.Circle) then
            Circle.Radius = Sk22t.Aimbot.Radius;
            Circle.Color  = Sk22t.Aimbot.Circle.Color;
            Circle.Transparency = Sk22t.Aimbot.Circle.Transparency;
        end
    end))

------- }}

----- {{ Sounds;

    local Sounds  = {};
    Sounds.List = {};

    for Index, Sound in next, listfiles("Sk22t.dev/asset/sound") do
        local Id = getcustomasset(Sound);
        local SlashSplit = string.split(Sound, "\\")[4] or string.split(Sound, "\\")[1] or string.split(Sound, "/")[4];
        local Name = string.split(SlashSplit, ".")[1];

        local NewSound = Utility.Instance("Sound", {
            SoundId = Id;
            Parent = SoundsFolder;
            Name = Name;
        })

        Sounds[Name] = NewSound;
        table.insert(Sounds.List, Name);
    end

    function Sounds.Refresh()
        for _, Sound in next, SoundsFolder:GetChildren() do
            if (Sound:IsA("Sound")) then
                Sound:Remove();
            end
        end

        for Index, Sound in next, Sounds do
            if (Sound:IsA("Sound")) then
                Sounds[Index] = nil;
            end
        end

        table.clear(Sounds.List);
    end

    function Sounds.Play(Name)
        coroutine.wrap(function()
            local Sound = Sounds[Name]:Clone();

            Sound.Parent = ActiveFolder;
            Sound.Volume = Sk22t.Visuals.Sound.Volume;

            Sound:Play();
            Sound.Ended:Wait();
            Sound:Remove();
        end)();       
    end

------- }}

----- {{ Hitmarker;

    local Hitmarker = {};
    local ImageData = { -- Base 64 encoded
        ["Hitmarker"] = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAI5JREFUWIXtl+EKgCAMhDff/53Xj1IsVjrxHNK+P8XS3SEML6K/w9dTlBqKm1YqVRFtAUS80qJigJnRJoo4s37Icn4Xye+Txbt6I0yYe840MdzruXHYQEv8a+RmjObK8Q6CIAg2xf0ySloxb6yz2yitmKcZaGY3C9as6RrJXEMpUrxLAy3+ZsL/1wystQEHJuOjfS8gJ9MAAAAASUVORK5CYII="
    }

    -- Thanks to Fraktality 
    local function RgbToLuv13(c)
        local r, g, b = c.r, c.g, c.b
        r = r < 0.0404482362771076 and r / 12.92 or 0.87941546140213 * (r + 0.055) ^ 2.4;
        g = g < 0.0404482362771076 and g / 12.92 or 0.87941546140213 * (g + 0.055) ^ 2.4;
        b = b < 0.0404482362771076 and b / 12.92 or 0.87941546140213 *(b + 0.055) ^ 2.4;
        local y = 0.2125862307855956 * r + 0.71517030370341085 * g + 0.0722004986433362 * b;
        local z = 3.6590806972265883 * r + 11.4426895800574232 * g + 4.1149915024264843 * b;
        local l = y > 0.008856451679035631 and 116 * y ^ (1/3) - 16 or 903.296296296296 * y;
        if z > 1e-15 then
            local x = 0.9257063972951867 * r - 0.8333736323779866 * g - 0.09209820666085898 * b;
            return l, l * x / z, l * (9 * y / z - 0.46832);
        else
            return l, -0.19783 * l, -0.46832 * l;
        end
    end

    local function LerpCIELUV(c0, c1)
        local l0, u0, v0 = RgbToLuv13(c0)
        local l1, u1, v1 = RgbToLuv13(c1)

        return function(t)
            local l = (1 - t) * l0 + t * l1
            if l < 0.0197955 then
                return Black
            end

            local u = ((1 - t) * u0 + t * u1) / l + 0.19783;
            local v = ((1 - t) * v0 + t * v1) / l + 0.46832;

            local y = (l + 16) / 116;
            y = y > 0.206896551724137931 and y * y * y or 0.12841854934601665 * y - 0.01771290335807126;
            local x = y * u / v;
            local z = y * ((3 - 0.75 * u) / v - 5);

            local r =  7.2914074 * x - 1.5372080 * y - 0.4986286 * z;
            local g = -2.1800940 * x + 1.8757561 * y + 0.0415175 * z;
            local b =  0.1253477 * x - 0.2040211 * y + 1.0569959 * z;

            if r < 0 and r < g and r < b then
                r, g, b = 0, g - r, b - r
            elseif g < 0 and g < b then
                r, g, b = r - g, 0, b - g
            elseif b < 0 then
                r, g, b = r - b, g - b, 0
            end

            return Color3.new(
                Clamp(r < 3.1306684425e-3 and 12.92 * r or 1.055 * r ^ (1/2.4) - 0.055, 0, 1),
                Clamp(g < 3.1306684425e-3 and 12.92 * g or 1.055 * g ^ (1/2.4) - 0.055, 0, 1),
                Clamp(b < 3.1306684425e-3 and 12.92 * b or 1.055 * b ^ (1/2.4) - 0.055, 0, 1)
            )
        end
    end

    function Hitmarker.Tween(Render, Info, Properties)
        local Start = {};
        local Time = 0;
        
        for Index, Value in next, Properties do
            Start[Index] = Render[Index];
            Properties[Index] = (typeof(Value) == "Color3" and LerpCIELUV(Start[Index], Value) or (Value - Start[Index]));
        end
        
        local Connection; Connection = RunService.RenderStepped:Connect(function(Delta)
            if Time < Info.Time then
                Time = Time + Delta;
                local TweenedValue = TweenService:GetValue((Time / Info.Time), Info.EasingStyle, Info.EasingDirection);

                for Index, Value in next, Properties do
                    if typeof(Value) == "number" then
                        Render[Index] = (Value * TweenedValue) + Start[Index];
                    elseif typeof(Value) == "Vector2" then
                        Render[Index] = Vector2.new((Value.X * TweenedValue) + Start[Index].X, (Value.Y * TweenedValue) + Start[Index].Y);
                    end
                end
            else
                Connection:Disconnect()
            end
        end)
    end

    local Marker = Utility.Draw("Image", {
        Data = base64_decode(ImageData["Hitmarker"]);
        Size = Vector2.new(32, 32);
        Visible = true;
        Transparency = 0; -- 0 is transparent
    });

    Hitmarker.Image = Marker;

    function Hitmarker:Hit(Time)
        Marker.Position = ScreenCenter - Vector2.new(Marker.Size.X / 2, Marker.Size.Y / 2);

        coroutine.wrap(function()
            Hitmarker.Tween(Marker, TweenInfo.new(Time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Transparency = 1;
            })

            task.wait(Time / 3);

            Hitmarker.Tween(Marker, TweenInfo.new(Time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Transparency = 0;
            })
        end)();
    end
------- }}

----- {{ Viewmodel;

    local Viewmodel = {};

    local ViewmodelSettings = Sk22t.Visuals.Viewmodel;

    function Viewmodel.Set()
        coroutine.wrap(function()
            if (Game.IsAlive()) then
                local Model = Ignore:WaitForChild("PlayerFolder"):FindFirstChild("Model");

                if (Model) then
                    if not (ModelsFolder:FindFirstChild(GetGun().WeaponName)) then
                        local Clone = Model:Clone();
                        Clone.Parent = ModelsFolder;
                        Clone.Name = GetGun().WeaponName;
                    end
        
                    if (Model) then
                        for _, Object in next, Model:GetChildren() do
                            if (ViewmodelSettings.Enabled) then
                                Object.Material = Enum.Material[ViewmodelSettings.Material];
                                Object.Color = ViewmodelSettings.Color;
                            else
                                local Original = ModelsFolder:FindFirstChild(GetGun().WeaponName)[Object.Name];
                                if (Original) then
                                    Object.Material = Original.Material;
                                    Object.Color = Original.Color;
                                end
                            end
                        end
                    end
                end
            end
        end)();
    end

------- }}

----- {{ Hooks;

    local HitmarkerSettings = Sk22t.Visuals.Hitmarker;
    local SoundSettings = Sk22t.Visuals.Sound;

    local OldIndex; OldIndex = hookmetamethod(game, "__index", LPH_NO_VIRTUALIZE(function(...)
        local Args = {...};
        local self, Key = Args[1], Args[2];

        if (self == WorkspaceFolder and not checkcaller()) then
            return nil
        end

        return OldIndex(...);
    end))

    local OldNamecall; OldNamecall = hookmetamethod(game, "__namecall", LPH_NO_VIRTUALIZE(function(...)
        local Args = {...}
        if (getnamecallmethod() == "Raycast" and Sk22t.Aimbot.Enabled and not checkcaller() and getcallingscript().Name == "WeaponScript") then
            local Target = GetClosest(Baddies);
            if (Target) then
                local Origin = Args[2];
                local Hitbox = Target[Sk22t.Aimbot.Hitbox];
                Args[3] = GetDirection(Origin, Hitbox.CFrame.Position);
            end

            if (Sk22t.Aimbot.Wallbang) then
                local RaycastParams = Args[4];
                RaycastParams:AddToFilter({Workspace.Map, Workspace.Interact});
            end

            setnamecallmethod("Raycast");
            return OldNamecall(unpack(Args));
        end

        if (getnamecallmethod() == "FireServer" and Args[1].ClassName == "RemoteEvent" and not checkcaller()) then
            local Remote = Args[1];
            local Name = Remote.Name;

            if (Name == "Damage") then
                if (SoundSettings.Enabled) then
                    setthreadidentity(8);
                    Sounds.Play(SoundSettings.Name);
                    setthreadidentity(2);
                end

                if (Sk22t.Visuals.Hitlog.Enabled) then
                    local Humanoid = Remote.Parent;
                    local DamageDealt = Args[2]["Damage"];

                    if (DamageDealt == 0/0 or DamageDealt == nan) then
                        DamageDealt = math.huge;
                    end

                    if (Humanoid:IsDescendantOf(Baddies)) then
                        local Remaining = math.max((Humanoid.Health - DamageDealt), 0);
                        setthreadidentity(8);
                        Library:Notify(string.format("[SK22T] - Did %* damage on zombie (remaining %i)", ((DamageDealt == math.huge and "inf") or math.round(DamageDealt)), Remaining));
                        setthreadidentity(2);
                    end
                end

                if (HitmarkerSettings.Enabled) then
                    Hitmarker:Hit(HitmarkerSettings.Duration);
                end
            end

            if (Name == "SendData") then
                return
            end

            setnamecallmethod("FireServer");
        end

        if (getnamecallmethod() == "InvokeServer") then
            local Remote = Args[1];
            local Name = Remote.Name;

            if (Name == "UpdateDamageKey") then
                DamageKey = Args[2];
            end

            setnamecallmethod("InvokeServer");
        end

        return OldNamecall(...);
    end))

------- }}

----- {{ Connections;

    local LoopTick = tick();
    RunService:BindToRenderStep("Loop", 300, LPH_NO_VIRTUALIZE(function() -- Child added doesn't work for last zombie for some reason
        if (Game.IsAlive()) then
            -- Auto kill
            if (Sk22t.Aimbot.AutoKill and tick() - LoopTick >= 0.25) then
                Game.KillAll();
                LoopTick = tick();
            end
            
            -- Infinite stamina
            if (WeaponScript ~= nil and WeaponScript:IsDescendantOf(game)) then
                local Function = Game.GetFunction(WeaponScript, "Sprint");
                if (Function ~= nil) then
                    local Upvalue = debug.getupvalue(Function, 14);
                    if (Sk22t.Exploit.InfiniteStamina and Upvalue ~= math.huge) then
                        debug.setupvalue(Function, 14, math.huge);
                    elseif (not Sk22t.Exploit.InfiniteStamina and Upvalue == math.huge) then
                        debug.setupvalue(Function, 14, 4.5);
                    end
                end
            end

            -- Viewmodel modifier
            if (ViewmodelSettings.Enabled) then
                Viewmodel.Set();
            end
        end
    end))

    Connection.new(Client.CharacterAdded, function(New)
        Character = New;
    end)

    Connection.new(Baddies.ChildAdded, function(Child)
        Highlight.BindToZombie(Child);
    end)

    Connection.new(SlotNum.Changed, function()
        if not (Sk22t.Mod.Enabled) then
            GunSignal:Fire("RestoreAll", {GetGun()});
        end
    end)

    Connection.new(Camera:GetPropertyChangedSignal("ViewportSize"), function()
        ScreenCenter = GetScreenCenter();
        Circle.Position = ScreenCenter;
    end)

    Connection.new(Workspace.ChildRemoved, function(Child)
        if (Child.Name == "Countdown") then
            Game.onMapChange();

            task.delay(2, function()
                Game.onRespawn();
            end)
        end
    end)

    Connection.new(Camera:GetPropertyChangedSignal("FieldOfView"), function()
        Camera.FieldOfView = ViewmodelSettings.FieldOfView;
    end)

------- }}

----- {{ Startup;

    local Window = Library:CreateWindow({
        Title = "Sk22t.dev - Project Lazarus",
        Center = true,
        AutoShow = true,
        TabPadding = 8,
        MenuFadeTime = 0.2
    })

    local Tabs = {
        Aimbot = Window:AddTab("Aimbot"),
        Visuals = Window:AddTab("Visuals"),
        Misc = Window:AddTab("Misc"),
        Menu = Window:AddTab("Settings")
    }

------- }}

----- {{ Menu;

    local Autofarm = Tabs.Aimbot:AddLeftGroupbox("Autofarm");

    Autofarm:AddToggle("Autobot", {
        Text = "Enable Auto Bot",
        Default = false,
        Callback = function(Value)
            Sk22t.Aimbot.Autobot.Enabled = Value;
        end
    })

    local AutofarmDependency = Autofarm:AddDependencyBox();

    AutofarmDependency:SetupDependencies({
        {Toggles.Autobot, true}
    });

    AutofarmDependency:AddInput("DistanceTextbox", {
        Default = 500,
        Numeric = true,
        Finished = false,
    
        Text = "Max Distance (studs)",
        Placeholder = "studs",
        MaxLength = 5,
    
        Callback = function(Value)
            Sk22t.Aimbot.Autobot.MaxDistance = tonumber(Value);
        end
    })

    AutofarmDependency:AddSlider("MaxTweenSpeed", {
        Text = "Tween Speed",
        Default = 3,
        Min = 1,
        Max = 5,
        Rounding = 0,
        Callback = function(Value)
            Sk22t.Aimbot.Autobot.TweenSpeed = Value;
        end
    });

    AutofarmDependency:AddSlider("MaxMouseDistance", {
        Text = "Max Mouse Distance",
        Default = 15,
        Min = 1,
        Max = 15,
        Rounding = 0,
        Callback = function(Value)
            Sk22t.Aimbot.Autobot.MaxMouseDistance = Value;
        end
    });

    Autofarm:AddToggle("AutoKill", {
        Text = "Auto Kill",
        Default = false,
        Tooltip = "Automatically kill all the zombies",
        Callback = function(Value)
            Sk22t.Aimbot.AutoKill = Value;
        end
    })

    local GunModifications = Tabs.Aimbot:AddLeftGroupbox("Gun Modification");

    GunModifications:AddToggle("ModifyMaster", {
        Text = "Master Toggle",
        Default = false,
        Tooltip = "Enable/disable gun modifications.",
        Callback = function(Value)
            Sk22t.Mod.Enabled = Value;
            if not (Value) then
                GunSignal:Fire("RestoreAll", {GetGun()});
            end
        end
    })

    local ModsDependency = GunModifications:AddDependencyBox();

    ModsDependency:SetupDependencies({
        {Toggles.ModifyMaster, true}
    });

    ModsDependency:AddToggle("Damage", {
        Text = "Damage Modifier",
        Default = false,
        Tooltip = "Modify guns damage.",
        Callback = function(Value)
            Sk22t.Mod.Damage.On = Value;
        end
    })

    local DamageDependency = ModsDependency:AddDependencyBox();
    local DamageDependency2 = ModsDependency:AddDependencyBox();

    DamageDependency:SetupDependencies({
        {Toggles.Damage, true},
    });

    DamageDependency:AddToggle("OneShot", {
        Text = "One Shot (Reccomended)",
        Default = false,
        Tooltip = "One shot every zombie regardless of health.",
        Callback = function(Value)
            Sk22t.Mod.Damage.OneShot = Value;
        end
    })

    DamageDependency2:SetupDependencies({
        {Toggles.Damage, true},
        {Toggles.OneShot, false},
    });

    DamageDependency2:AddSlider("Damage", {
        Text = "Damage",
        Default = 1,
        Min = 1,
        Max = 100,
        Rounding = 0,
        Suffix = "%",
        Callback = function(Value)
            Sk22t.Mod.Damage.Value = Value;
        end
    });

    ModsDependency:AddDivider()

    ModsDependency:AddToggle("FireRate", {
        Text = "Fire Time",
        Default = false,
        Tooltip = "Modify guns fire rate.",
        Callback = function(Value)
            Sk22t.Mod.FireRate.On = Value;
        end
    })

    local FireRateDependency = ModsDependency:AddDependencyBox();

    FireRateDependency:SetupDependencies({
        {Toggles.FireRate, true}
    })

    FireRateDependency:AddSlider("FireRateValue", {
        Text = "Value",
        Default = 1,
        Min = 1,
        Max = 100,
        Rounding = 0,
        Tooltip = "Fire rate. Might not work with every gun.",
        Callback = function(Value)
            Sk22t.Mod.FireRate.Value = Value;
        end
    })

    ModsDependency:AddDivider()

    ModsDependency:AddToggle("Speed", {
        Text = "Walk Speed",
        Default = false,
        Tooltip = "Walk speed multiplier with gun.",
        Callback = function(Value)
            Sk22t.Mod.Speed.On = Value;
        end
    })

    local SpeedDependency = ModsDependency:AddDependencyBox();

    SpeedDependency:SetupDependencies({
        {Toggles.Speed, true}
    })

    SpeedDependency:AddSlider("SpeedValue", {
        Text = "Multiplier",
        Default = 1,
        Min = 1,
        Max = 10,
        Rounding = 1,
        Tooltip = "Speed multiplier.",
        Callback = function(Value)
            Sk22t.Mod.Speed.Value = Value;
        end
    })

    ModsDependency:AddDivider()

    ModsDependency:AddToggle("InfAmmo", {
        Text = "Infinite Ammo",
        Default = false,
        Tooltip = "Never go out of ammo.",
        Callback = function(Value)
            Sk22t.Mod.InfiniteAmmo = Value;
        end
    })

    ModsDependency:AddToggle("FullAuto", {
        Text = "Full Automatic",
        Default = false,
        Tooltip = "Might not work with every gun.",
        Callback = function(Value)
            Sk22t.Mod.FullAuto = Value;
        end
    })

    ModsDependency:AddToggle("RemoveSpread", {
        Text = "Remove Spread",
        Default = false,
        Tooltip = "Remove gun spread.",
        Callback = function(Value)
            Sk22t.Mod.RemoveSpread = Value;
        end
    })

    ModsDependency:AddToggle("InstaEquip", {
        Text = "Instant Equip",
        Default = false,
        Tooltip = "Draw your gun in a blink of an eye.",
        Callback = function(Value)
            Sk22t.Mod.InstaEquip = Value;
        end
    })

    local Silent = Tabs.Aimbot:AddRightGroupbox("Silent Aim");

    Silent:AddToggle("SilentAim", {
        Text = "Enable Silent Aim",
        Default = false,
        Tooltip = "Redirects bullets to the zombies",
        Callback = function(Value)
            Sk22t.Aimbot.Enabled = Value;
        end
    })

    local AimbotDep = Silent:AddDependencyBox();
    AimbotDep:SetupDependencies({
        {Toggles.SilentAim, true}
    });

    AimbotDep:AddDropdown("Hitbox", {
        Values = {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"},
        Default = 1,
        Multi = false,
        Text = "Hitbox",
        Tooltip = "Choose which part to aim",
        Callback = function(Value)
            Sk22t.Aimbot.Hitbox = Value;
        end
    })

    AimbotDep:AddSlider("Radius", {
        Text = "Aimbot Radius",
        Default = 10,
        Min = 10,
        Max = 750,
        Rounding = 0,
        Callback = function(Value)
            Sk22t.Aimbot.Radius = Value;
        end
    });

    AimbotDep:AddToggle("Wallbang", {
        Text = "Wall Penetration",
        Default = false,
        Tooltip = "Ignore walls basically",
        Callback = function(Value)
            Sk22t.Aimbot.Wallbang = Value;
            if (Value) then
                Toggles.WallCheck:SetValue(false);
            end
        end
    })

    AimbotDep:AddToggle("WallCheck", {
        Text = "Visible Check",
        Default = false,
        Tooltip = "Ignore zombies behind walls",
        Callback = function(Value)
            Sk22t.Aimbot.WallCheck = Value;
            if (Value) then
                Toggles.Wallbang:SetValue(false);
            end
        end
    })

    AimbotDep:AddToggle("Circle", {
        Text = "FOV Circle",
        Default = false,
        Tooltip = "Draw max aimbot radius",
        Callback = function(Value)
            Sk22t.Aimbot.Circle.Visible = Value;
        end
    })

    AimbotDep:AddLabel("Circle Color"):AddColorPicker("CircleColor", {
        Default = Color3.new(1, 1, 1),
        Title = "Circle Color",
        Transparency = 0
    })

    Options.CircleColor:OnChanged(function()
        Sk22t.Aimbot.Circle.Color = Options.CircleColor.Value;
        Sk22t.Aimbot.Circle.Transparency = 1 - Options.CircleColor.Transparency;
    end)

    local HighlightTab = Tabs.Visuals:AddLeftGroupbox("Highlight");
    local ViewmodelTab = Tabs.Visuals:AddLeftGroupbox("Viewmodel");
    local VisualsElements = Tabs.Visuals:AddRightGroupbox("Elements");

    HighlightTab:AddToggle("HighlightZombies", {
        Text = "Highlight Zombies",
        Default = false,
        Tooltip = "Highlights all zombies",
        Callback = function(Value)
            Sk22t.Visuals.Highlight.Enabled = Value;
            Highlight.Callback("Enabled", Value);

            if (Value) then
                for Index, Zombie in next, Baddies:GetChildren() do
                    if not (Highlight.Cache[Zombie]) then
                        Highlight.BindToZombie(Zombie);
                    end
                end
            end
        end
    }):AddColorPicker("HighlightColor", {
        Default = Color3.new(1, 0, 0),
        Title = "Fill Color",
        Transparency = nil,
        Callback = function(Value)
            Sk22t.Visuals.Highlight.FillColor = Value;
            Highlight.Callback("FillColor", Value);
        end
    }):AddColorPicker("HiglightOutlineColor", {
        Default = Color3.new(1, 1, 1),
        Title = "Outline Color",
        Transparency = nil,
        Callback = function(Value)
            Sk22t.Visuals.Highlight.OutlineColor = Value;
            Highlight.Callback("OutlineColor", Value);
        end
    })

    HighlightTab:AddToggle("HealthBased", {
        Text = "Health Color",
        Default = false,
        Tooltip = "Changes highlight color based on zombies health",
        Callback = function(Value)
            Sk22t.Visuals.Highlight.HealthBased = Value;

            if (Value) then
                Highlight.Callback("FillColor", "HB");
            else
                Highlight.Callback("FillColor", HighlightSettings.FillColor);
            end
        end
    })

    HighlightTab:AddDivider()

    HighlightTab:AddToggle("MysteryBox", {
        Text = "Highlight Mystery Box",
        Default = false,
        Tooltip = "Highlight mystery box",
        Callback = function(Value)
            Sk22t.Visuals.Highlight.MysteryBox.Enabled = Value;

            if not (BoxHighlight) then return end;

            BoxHighlight:Update({
                Enabled = Value;
            })
        end
    }):AddColorPicker("HighlightColor", {
        Default = Color3.new(1, 1, 0),
        Title = "Fill Color",
        Transparency = nil,
        Callback = function(Value)
            Sk22t.Visuals.Highlight.MysteryBox.FillColor = Value;

            if not (BoxHighlight) then return end;

            BoxHighlight:Update({
                FillColor = Value;
            })
        end
    }):AddColorPicker("HighlightColor", {
        Default = Color3.new(1, 1, 1),
        Title = "Outline Color",
        Transparency = nil,
        Callback = function(Value)
            Sk22t.Visuals.Highlight.MysteryBox.OutlineColor = Value;

            if not (BoxHighlight) then return end;

            BoxHighlight:Update({
                OutlineColor = Value;
            })
        end
    })

    ViewmodelTab:AddToggle("Viewmodel", {
        Text = "Enable Viewmodel Tweaks",
        Default = false,
        Callback = function(Value)
            Sk22t.Visuals.Viewmodel.Enabled = Value;

            if not (Value) then
                Viewmodel.Set();
            end
        end
    })

    local ViewDependency = ViewmodelTab:AddDependencyBox();

    ViewDependency:SetupDependencies({
        {Toggles.Viewmodel, true}
    })

    ViewDependency:AddDropdown("Material", {
        Values = {"ForceField", "Neon", "Glacier", "SmoothPlastic"},
        Default = "SmoothPlastic",
        Multi = false,
        Text = "Select",
        Tooltip = "Select sound to be played",
        Callback = function(Value)
            Sk22t.Visuals.Viewmodel.Material = Value;
        end
    })
    
    ViewDependency:AddLabel("Material Color"):AddColorPicker("MaterialColor", {
        Default = Color3.fromRGB(27, 42, 53),
        Title = "Material Color",
        Transparency = nil,
        Callback = function(Value)
            Sk22t.Visuals.Viewmodel.Color = Value;
        end
    })

    ViewmodelTab:AddSlider("FoV", {
        Text = "Camera FOV",
        Default = 70,
        Min = 70,
        Max = 120,
        Rounding = 0,
        Callback = function(Value)
            Sk22t.Visuals.Viewmodel.FieldOfView = Value;
            Camera.FieldOfView = Value;
        end
    });

    VisualsElements:AddToggle("Hitsound", {
        Text = "Hitsounds",
        Default = false,
        Tooltip = "Plays sound upon hit",
        Callback = function(Value)
            Sk22t.Visuals.Sound.Enabled = Value;
        end
    })

    local HitsoundDep = VisualsElements:AddDependencyBox();

    HitsoundDep:SetupDependencies({
        {Toggles.Hitsound, true}
    })

    HitsoundDep:AddDropdown("HitsoundName", {
        Values = Sounds.List,
        Default = "Skeet",
        Multi = false,
        Text = "Select",
        Tooltip = "Select sound to be played",
        Callback = function(Value)
            Sk22t.Visuals.Sound.Name = Value;
        end
    })

    HitsoundDep:AddSlider("Volume", {
        Text = "Volume",
        Default = 0.5,
        Min = 0.1,
        Max = 1,
        Rounding = 1,
        Callback = function(Value)
            Sk22t.Visuals.Sound.Volume = Value;
        end
    });

    VisualsElements:AddToggle("Hitmarker", {
        Text = "Hitmarker",
        Default = false,
        Tooltip = "Displays a hitmarker upon hit",
        Callback = function(Value)
            Sk22t.Visuals.Hitmarker.Enabled = Value;
        end
    })

    local HitmarkerDep = VisualsElements:AddDependencyBox();

    HitmarkerDep:SetupDependencies({
        {Toggles.Hitmarker, true}
    })

    HitmarkerDep:AddSlider("HitmarkerDuration", {
        Text = "Duration",
        Default = 0.2,
        Min = 0.1,
        Max = 0.5,
        Rounding = 1,
        Callback = function(Value)
            Sk22t.Visuals.Hitmarker.Duration = Value;
        end
    });

    VisualsElements:AddToggle("Hitlog", {
        Text = "Hitlogs",
        Default = false,
        Tooltip = "Shows hit info",
        Callback = function(Value)
            Sk22t.Visuals.Hitlog.Enabled = Value;
        end
    })

    local Exploits = Tabs.Misc:AddLeftGroupbox("Exploits");
    local Loadstrings = Tabs.Misc:AddRightGroupbox("Other");

    Exploits:AddToggle("InfiniteStamina", {
        Text = "Infinite Stamina",
        Default = false,
        Tooltip = "Non-stop running.",
        Callback = function(Value)
            Sk22t.Exploit.InfiniteStamina = Value;
        end
    })

    Exploits:AddInput("PointTextbox", {
        Default = 1000,
        Numeric = true,
        Finished = false,
    
        Text = "Point Amount",
        Placeholder = "Amount",
        MaxLength = 5,
    
        Callback = function(Value)
            Sk22t.Exploit.Points = Value;
        end
    })

    Exploits:AddButton("Give Points", function()
        Game.GetPoints(Sk22t.Exploit.Points);
    end)

    Loadstrings:AddButton({
        Text = "Rejoin",
        DoubleClick = false,
        Func = function()
            cloneref(game:GetService("TeleportService")):TeleportToPlaceInstance(game.PlaceId, game.JobId, Client);
        end
    })
------- }}

----- {{ Finishing Touches;

    Library:OnUnload(function()
        for _, Name in next, RenderBinds do
            RunService:UnbindFromRenderStep(Name);
        end

        GunSignal:Fire("RestoreAll");

        cleardrawcache();

        for _, Hl in next, Highlight.Cache do
            if (type(Hl) == "table") then
                Hl:Remove();
            end
        end

        table.clear(Highlight.Cache);

        Connection:closeall();

        Library.Unloaded = true;

        hookmetamethod(game, "__index", function(...)
            return OldIndex(...);
        end)

        hookmetamethod(game, "__namecall", function(...)
            return OldNamecall(...);
        end)
    end)

    local MenuGroup = Tabs.Menu:AddLeftGroupbox("Menu")
    MenuGroup:AddButton("Unload", function() Library:Unload() end)
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {Default = "LeftControl", NoUI = true, Text = "Menu keybind"})
    Library.ToggleKeybind = Options.MenuKeybind 
    
    SaveManager:SetLibrary(Library);
    SaveManager:IgnoreThemeSettings();
    SaveManager:SetIgnoreIndexes({"MenuKeybind"});
    SaveManager:SetFolder("Sk22t.dev");
    SaveManager:BuildConfigSection(Tabs.Menu);

    ThemeManager:SetLibrary(Library);
    ThemeManager:SetFolder("Sk22t.dev");
    ThemeManager:ApplyToTab(Tabs.Menu);

    SaveManager:LoadAutoloadConfig();
 
------- }}