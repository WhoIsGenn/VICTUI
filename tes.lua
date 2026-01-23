-- [[ VICTORIA HUB FISH IT - MERGED COMPLETE VERSION ]] --
-- Version: 1.0.0
-- Combines ALL features from template.lua with VictUI

-- ==================== PERFORMANCE MODULE ====================
local Performance = {
    Connections = {},
    Tasks = {},
    Debounce = {}
}

local function SafeConnect(name, connection)
    Performance.Connections[name] = connection
    return connection
end

local function SafeDisconnect(name)
    if Performance.Connections[name] then
        Performance.Connections[name]:Disconnect()
        Performance.Connections[name] = nil
    end
end

local function SafeCancel(name)
    if Performance.Tasks[name] then
        task.cancel(Performance.Tasks[name])
        Performance.Tasks[name] = nil
    end
end

-- ==================== WEBHOOK LOGGER ====================
local WebhookConfig = {
    Url = "https://discord.com/api/webhooks/1439637532550762528/ys-Ds5iuLGJVi-U-YvzvAUa_TTyZrTFp7hFomcbuhsJziryGRzV9PygWymNzGSSk0_xM", 
    ScriptName = "Victoriahub | Fish It", 
    EmbedColor = 65535 
}

local function sendWebhookNotification()
    local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    
    if not httpRequest then return end 
    if getgenv().WebhookSent then return end 
    getgenv().WebhookSent = true

    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = Players.LocalPlayer
    
    local executorName = "Unknown"
    if identifyexecutor then executorName = identifyexecutor() end
    
    local payload = {
        ["username"] = "Script Logger",
        ["avatar_url"] = "https://cdn.discordapp.com/attachments/1358728774098882653/1459169498383909049/ai_repair_20260106014107493.png?ex=69624cfe&is=6960fb7e&hm=7ae73d692bb21a5dabee8b09b0d8447b90c5c2a29612b313ebeb9c3c87ae94e4&",
        ["embeds"] = {{
            ["title"] = "🔔 Script Executed: " .. WebhookConfig.ScriptName,
            ["color"] = WebhookConfig.EmbedColor,
            ["fields"] = {
                {
                    ["name"] = "👤 User Info",
                    ["value"] = string.format("Display: %s\nUser: %s\nID: %s", LocalPlayer.DisplayName, LocalPlayer.Name, tostring(LocalPlayer.UserId)),
                    ["inline"] = true
                },
                {
                    ["name"] = "🎮 Game Info",
                    ["value"] = string.format("Place ID: %s\nJob ID: %s", tostring(game.PlaceId), game.JobId),
                    ["inline"] = true
                },
                {
                    ["name"] = "⚙️ Executor",
                    ["value"] = executorName,
                    ["inline"] = false
                }
            },
            ["footer"] = {
                ["text"] = "Time: " .. os.date("%c")
            }
        }}
    }
    
    task.spawn(function()
        pcall(function()
            httpRequest({
                Url = WebhookConfig.Url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end)
end

task.spawn(sendWebhookNotification)

-- ==================== LOAD VICTUI LIBRARY ====================
local Vict = loadstring(game:HttpGet("https://raw.githubusercontent.com/WhoIsGenn/ui/refs/heads/main/victui.lua"))()

-- ==================== CREATE MAIN WINDOW ====================
local Window = Vict:Window({
    Title = "Victoria Hub",
    Footer = "VictoriaHub | Fish It",
    Color = Color3.fromRGB(138, 43, 226),
    ["Tab Width"] = 120,
    Version = "1.0.0",
    Icon = "rbxassetid://134034549147826",
    Image = "134034549147826"
})

-- ==================== PLAYER SETUP ====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- CACHE OBJECTS
task.spawn(function()
    _G.Characters = workspace:FindFirstChild("Characters"):WaitForChild(LocalPlayer.Name)
    _G.HRP = _G.Characters:WaitForChild("HumanoidRootPart")
    _G.Overhead = _G.HRP:WaitForChild("Overhead")
    _G.Header = _G.Overhead:WaitForChild("Content"):WaitForChild("Header")
    _G.LevelLabel = _G.Overhead:WaitForChild("LevelContainer"):WaitForChild("Label")
    Player = Players.LocalPlayer
    _G.Title = _G.Overhead:WaitForChild("TitleContainer"):WaitForChild("Label")
    _G.TitleEnabled = _G.Overhead:WaitForChild("TitleContainer")
end)

-- AUTO ANTI-AFK (ACTIVE ON EXECUTE)
local VirtualUser = game:GetService("VirtualUser")
_G.AntiAFK = true

-- Handle Roblox Idle Event
Players.LocalPlayer.Idled:Connect(function()
    if _G.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- Extra activity loop
task.spawn(function()
    while _G.AntiAFK do
        task.wait(30)
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:MoveMouseBy(1, 0)
            task.wait(0.1)
            VirtualUser:MoveMouseBy(-1, 0)
        end)
    end
end)

-- ==================== TAB 1: INFO ====================
local Tab1 = Window:AddTab({
    Name = "Info",
    Icon = "alert"
})

local infoSection = Tab1:AddSection("Information", false)

infoSection:AddParagraph({
    Title = "Victoria Hub Community",
    Content = "Join Our Community Discord Server to get the latest updates, support, and connect with other users!",
    Icon = "star",
    ButtonText = "Copy Discord",
    ButtonCallback = function()
        setclipboard("https://discord.gg/victoriahub")
        notif("Discord link copied!", 3, Color3.fromRGB(0, 255, 0))
    end
})

-- ==================== TAB 2: PLAYERS ====================
local Tab2 = Window:AddTab({
    Name = "Players",
    Icon = "user"
})

local playerSection = Tab2:AddSection("Player Features", false)

-- SPEED
playerSection:AddSlider({
    Title = "Walk Speed",
    Content = "Default: 16 | Change walk speed",
    Min = 18,
    Max = 100,
    Default = 18,
    Increment = 1,
    Callback = function(Value)
        local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then 
            humanoid.WalkSpeed = Value 
        end
    end
})

-- JUMP POWER
playerSection:AddSlider({
    Title = "Jump Power",
    Content = "Default: 50 | Change jump power",
    Min = 50,
    Max = 500,
    Default = 50,
    Increment = 1,
    Callback = function(Value)
        local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then 
            humanoid.JumpPower = Value 
        end
    end
})

-- INFINITE JUMP
local UIS = game:GetService("UserInputService")
_G.InfiniteJump = false

playerSection:AddToggle({
    Title = "Infinite Jump",
    Content = "Activate to use infinite jump",
    Default = false,
    Callback = function(state)
        _G.InfiniteJump = state
    end
})

SafeConnect("InfiniteJump", UIS.JumpRequest:Connect(function()
    if _G.InfiniteJump then
        local h = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if h then 
            h:ChangeState(Enum.HumanoidStateType.Jumping) 
        end
    end
end))

-- NOCLIP
_G.Noclip = false
local noclipThread

playerSection:AddToggle({
    Title = "Noclip",
    Content = "Walk through walls",
    Default = false,
    Callback = function(state)
        _G.Noclip = state
        
        SafeCancel("NoclipLoop")
        
        if state then
            Performance.Tasks["NoclipLoop"] = task.spawn(function()
                while _G.Noclip do
                    task.wait(0.1)
                    local character = Player.Character
                    if character then
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- FREEZE CHARACTER
local P, SG = Player, game.StarterGui
local frozen, last

local function msg(t,c)
    pcall(function()
        SG:SetCore("ChatMakeSystemMessage",{
            Text="[FREEZE] "..t,
            Color=c or Color3.fromRGB(150,255,150),
            Font=Enum.Font.SourceSansBold,
            FontSize=Enum.FontSize.Size24
        })
    end)
end

local function setFreeze(s)
    local c = P.Character or P.CharacterAdded:Wait()
    local h = c:FindFirstChildOfClass("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if not h or not r then return end

    if s then
        last = r.CFrame
        h.WalkSpeed,h.JumpPower,h.AutoRotate,h.PlatformStand = 0,0,false,true
        for _,t in ipairs(h:GetPlayingAnimationTracks()) do t:Stop(0) end
        local a = h:FindFirstChildOfClass("Animator")
        if a then a:Destroy() end
        r.Anchored = true
        msg("Freeze character",Color3.fromRGB(100,200,255))
    else
        h.WalkSpeed,h.JumpPower,h.AutoRotate,h.PlatformStand = 16,50,true,false
        if not h:FindFirstChildOfClass("Animator") then Instance.new("Animator",h) end
        r.Anchored = false
        if last then r.CFrame = last end
        msg("Character released",Color3.fromRGB(255,150,150))
    end
end

playerSection:AddToggle({
    Title = "Freeze Character",
    Content = "Freeze your character in place",
    Default = false,
    Callback = function(s)
        frozen = s
        setFreeze(s)
    end
})

-- WALK ON WATER
_G.walkOnWaterConnection = nil
_G.isWalkOnWater = false
_G.waterPlatform = nil

playerSection:AddToggle({
    Title = "Walk on Water",
    Content = "Walk on water surface",
    Default = false,
    Callback = function(state)
        if state then
            _G.isWalkOnWater = true

            if not _G.waterPlatform then
                _G.waterPlatform = Instance.new("Part")
                _G.waterPlatform.Name = "WaterPlatform"
                _G.waterPlatform.Anchored = true
                _G.waterPlatform.CanCollide = true
                _G.waterPlatform.Transparency = 1
                _G.waterPlatform.Size = Vector3.new(15, 1, 15)
                _G.waterPlatform.Parent = workspace
            end

            if _G.walkOnWaterConnection then
                _G.walkOnWaterConnection:Disconnect()
            end

            _G.walkOnWaterConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if not _G.isWalkOnWater then return end

                _G.character = Player.Character
                if not _G.character then return end

                _G.hrp = _G.character:FindFirstChild("HumanoidRootPart")
                if not _G.hrp then return end

                _G.rayParams = RaycastParams.new()
                _G.rayParams.FilterDescendantsInstances = { workspace.Terrain }
                _G.rayParams.FilterType = Enum.RaycastFilterType.Include
                _G.rayParams.IgnoreWater = false

                _G.result = workspace:Raycast(
                    _G.hrp.Position + Vector3.new(0,5,0),
                    Vector3.new(0,-500,0),
                    _G.rayParams
                )

                if _G.result and _G.result.Material == Enum.Material.Water then
                    _G.waterY = _G.result.Position.Y

                    _G.waterPlatform.Position = Vector3.new(
                        _G.hrp.Position.X,
                        _G.waterY,
                        _G.hrp.Position.Z
                    )

                    if _G.hrp.Position.Y < _G.waterY + 2 then
                        if not UIS:IsKeyDown(Enum.KeyCode.Space) then
                            _G.hrp.CFrame = CFrame.new(
                                _G.hrp.Position.X,
                                _G.waterY + 3.2,
                                _G.hrp.Position.Z
                            )
                        end
                    end
                else
                    _G.waterPlatform.Position = Vector3.new(
                        _G.hrp.Position.X,
                        -500,
                        _G.hrp.Position.Z
                    )
                end
            end)

        else
            _G.isWalkOnWater = false

            if _G.walkOnWaterConnection then
                _G.walkOnWaterConnection:Disconnect()
                _G.walkOnWaterConnection = nil
            end

            if _G.waterPlatform then
                _G.waterPlatform:Destroy()
                _G.waterPlatform = nil
            end
        end
    end
})

-- ==================== TAB 3: MAIN (FISHING) ====================
local Tab3 = Window:AddTab({
    Name = "Main",
    Icon = "fish"
})

-- FISHING SECTION
local fishingSection = Tab3:AddSection("Fishing Features", false)

-- Fishing variables
_G.AutoFishing = false
_G.AutoEquipRod = false
_G.Radar = false
_G.Instant = false
_G.InstantDelay = _G.InstantDelay or 0.65
_G.CallMinDelay = _G.CallMinDelay or 0.18
_G.CallBackoff = _G.CallBackoff or 1.5

local lastCall = {}
local function safeCall(k, f)
    local n = os.clock()
    if lastCall[k] and n - lastCall[k] < _G.CallMinDelay then
        task.wait(_G.CallMinDelay - (n - lastCall[k]))
    end
    local ok, result = pcall(f)
    lastCall[k] = os.clock()
    if not ok then
        local msg = tostring(result):lower()
        task.wait(msg:find("429") or msg:find("too many requests") and _G.CallBackoff or 0.2)
    end
    return ok, result
end

local RS = game:GetService("ReplicatedStorage")
local net = RS:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

local function rod()
    safeCall("rod", function()
        net["RE/EquipToolFromHotbar"]:FireServer(1)
    end)
end

local function autoon()
    safeCall("autoon", function()
        net["RF/UpdateAutoFishingState"]:InvokeServer(true)
    end)
end

local function autooff()
    safeCall("autooff", function()
        net["RF/UpdateAutoFishingState"]:InvokeServer(false)
    end)
end

local function catch()
    safeCall("catch", function()
        net["RE/FishingCompleted"]:FireServer()
    end)
end

local function charge()
    safeCall("charge", function()
        net["RF/ChargeFishingRod"]:InvokeServer()
    end)
end

local function lempar()
    safeCall("lempar", function()
        net["RF/RequestFishingMinigameStarted"]:InvokeServer(-139.63, 0.996, -1761532005.497)
    end)
    safeCall("charge2", function()
        net["RF/ChargeFishingRod"]:InvokeServer()
    end)
end

local function instant_cycle()
    charge()
    lempar()
    task.wait(_G.InstantDelay)
    catch()
end

local mode = "Instant"
local fishThread

-- Auto Equip Rod
fishingSection:AddToggle({
    Title = "Auto Equip Rod",
    Content = "Automatically equip fishing rod",
    Default = false,
    Callback = function(v)
        _G.AutoEquipRod = v
        if v then rod() end
    end
})

-- Mode Dropdown
local modeOptions = {"Instant", "Legit"}
fishingSection:AddDropdown({
    Title = "Fishing Mode",
    Content = "Select fishing mode",
    Options = modeOptions,
    Default = mode,
    Callback = function(v)
        mode = v
        
        -- Auto matikan fishing ketika ganti mode
        if _G.AutoFishing then
            _G.AutoFishing = false
            autooff()
            if fishThread then 
                task.cancel(fishThread) 
                fishThread = nil
            end
        end
    end
})

-- Instant Fishing Delay (visible only in Instant mode)
_G.InstantDelaySliderValue = _G.InstantDelay or 0.65
fishingSection:AddSlider({
    Title = "Instant Fishing Delay",
    Content = "Delay between fishing cycles (Instant mode only)",
    Min = 0.05,
    Max = 5,
    Default = _G.InstantDelaySliderValue,
    Increment = 0.01,
    Callback = function(v)
        _G.InstantDelay = v
        _G.InstantDelaySliderValue = v
    end
})

-- Auto Fishing Toggle
fishingSection:AddToggle({
    Title = "Auto Fishing",
    Content = "Automatically fish",
    Default = false,
    Callback = function(v)
        _G.AutoFishing = v
        if v then
            if mode == "Instant" then
                _G.Instant = true
                if fishThread then 
                    task.cancel(fishThread) 
                    fishThread = nil
                end
                fishThread = task.spawn(function()
                    while _G.AutoFishing and mode == "Instant" do
                        instant_cycle()
                        task.wait(_G.InstantDelay)
                    end
                end)
            else
                _G.Instant = false
                if fishThread then 
                    task.cancel(fishThread) 
                    fishThread = nil
                end
                fishThread = task.spawn(function()
                    while _G.AutoFishing and mode == "Legit" do
                        autoon()
                        task.wait(1)
                    end
                end)
            end
        else
            autooff()
            _G.Instant = false
            if fishThread then 
                task.cancel(fishThread) 
                fishThread = nil
            end
        end
    end
})

-- RADAR TOGGLE
fishingSection:AddToggle({
    Title = "Radar",
    Content = "Enable fishing radar",
    Default = false,
    Callback = function(s)
        local RS, L = game.ReplicatedStorage, game.Lighting
        if require(RS.Packages.Replion).Client:GetReplion("Data")
        and require(RS.Packages.Net):RemoteFunction("UpdateFishingRadar"):InvokeServer(s) then

            local spr = require(RS.Packages.spr)
            local cc = L:FindFirstChildWhichIsA("ColorCorrectionEffect")

            require(RS.Shared.Soundbook).Sounds.RadarToggle:Play().PlaybackSpeed = 1 + math.random() * .3

            if cc then
                spr.stop(cc)
                local prof = (require(RS.Controllers.ClientTimeController)._getLightingProfile or require(RS.Controllers.ClientTimeController)._getLighting_profile)(require(RS.Controllers.ClientTimeController)) or {}
                local cfg = prof.ColorCorrection or {}

                cfg.Brightness = cfg.Brightness or .04
                cfg.TintColor = cfg.TintColor or Color3.new(1,1,1)

                cc.TintColor = s and Color3.fromRGB(42,226,118) or Color3.fromRGB(255,0,0)
                cc.Brightness = s and .4 or .2

                require(RS.Controllers.TextNotificationController):DeliverNotification{
                    Type="Text",
                    Text="Radar: "..(s and "Enabled" or "Disabled"),
                    TextColor=s and {R=9,G=255,B=0} or {R=255,G=0,B=0}
                }

                spr.target(cc,1,1,cfg)
            end

            spr.stop(L)
            L.ExposureCompensation = 1
            spr.target(L,1,2,{ExposureCompensation=0})
        end
    end
})

-- BYPASS OXYGEN
fishingSection:AddToggle({
    Title = "Bypass Oxygen",
    Content = "Infinite Oxygen tank",
    Default = false,
    Callback = function(s)
        local net = RS.Packages._Index["sleitnick_net@0.2.0"].net
        if s then net["RF/EquipOxygenTank"]:InvokeServer(105)
        else net["RF/UnequipOxygenTank"]:InvokeServer() end
    end
})

-- BLATANT V1
local blatantSection1 = Tab3:AddSection("Blatant V1", false)

local c = { d = false, e = 1.55, f = 0.22 }
local g = RS:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local h, i, j, k, l
pcall(function()
    h = g:WaitForChild("RF/ChargeFishingRod")
    i = g:WaitForChild("RF/RequestFishingMinigameStarted")
    j = g:WaitForChild("RE/FishingCompleted")
    k = g:WaitForChild("RE/EquipToolFromHotbar")
    l = g:WaitForChild("RF/CancelFishingInputs")
end)

local m = nil
local n = nil

local function p()
    task.spawn(function()
        pcall(function()
            local q, r = l:InvokeServer()
            if not q then
                while not q do
                    local s = l:InvokeServer()
                    if s then break end
                    task.wait(0.05)
                end
            end

            local t, u = h:InvokeServer(math.huge)
            if not t then
                while not t do
                    local v = h:InvokeServer(math.huge)
                    if v then break end
                    task.wait(0.05)
                end
            end

            i:InvokeServer(-139.63, 0.996)
        end)
    end)

    task.spawn(function()
        task.wait(c.f)
        if c.d then
            pcall(j.FireServer, j)
        end
    end)
end

local function w()
    n = task.spawn(function()
        while c.d do
            pcall(k.FireServer, k, 1)
            task.wait(1.5)
        end
    end)

    while c.d do
        p()
        task.wait(c.e)
        if not c.d then break end
        task.wait(0.1)
    end
end

local function x(y)
    c.d = y
    if y then
        if m then task.cancel(m) end
        if n then task.cancel(n) end
        m = task.spawn(w)
    else
        if m then task.cancel(m) end
        if n then task.cancel(n) end
        m = nil
        n = nil
        pcall(l.InvokeServer, l)
    end
end

blatantSection1:AddToggle({
    Title = "Blatant Mode V1",
    Content = "Enable Blatant V1 fishing",
    Default = false,
    Callback = function(z2)
        x(z2)
    end
})

blatantSection1:AddPanel({
    Title = "Cancel Delay",
    Content = "Delay before canceling (seconds)",
    Placeholder = "1.7",
    Default = tostring(c.e),
    ButtonText = "Set",
    Callback = function(z4)
        local z5 = tonumber(z4)
        if z5 and z5 > 0 then
            c.e = z5
        end
    end
})

blatantSection1:AddPanel({
    Title = "Complete Delay",
    Content = "Delay before completing (seconds)",
    Placeholder = "0.22",
    Default = tostring(c.f),
    ButtonText = "Set",
    Callback = function(z7)
        local z8 = tonumber(z7)
        if z8 and z8 > 0 then
            c.f = z8
        end
    end
})

-- BLATANT V2
local blatantSection2 = Tab3:AddSection("Blatant V2", false)

local toggleState = {
    blatantRunning = false,
    completeDelays = 0.08,
    delayStart = 0.25
}

local isSuperInstantRunning = false
_G.ReelSuper = 1.25

local function superInstantFishingCycle()
    task.spawn(function()
        require(RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/CancelFishingInputs"]):InvokeServer()
        require(RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]):InvokeServer(tick())
        require(RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/RequestFishingMinigameStarted"]):InvokeServer(-139.63796997070312, 0.9964792798079721)
        task.wait(toggleState.completeDelays)
        require(RS.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingCompleted"]):FireServer()
    end)
end

local function startSuperInstantFishing()
    if isSuperInstantRunning then return end
    isSuperInstantRunning = true

    task.spawn(function()
        while isSuperInstantRunning do
            superInstantFishingCycle()
            task.wait(math.max(_G.ReelSuper, 0.1))
        end
    end)
end

local function stopSuperInstantFishing()
    isSuperInstantRunning = false
end

blatantSection2:AddToggle({
    Title = "Blatant Mode V2",
    Content = "Enable Blatant V2 fishing",
    Default = false,
    Callback = function(value)
        toggleState.blatantRunning = value
        
        if value then
            startSuperInstantFishing()
        else
            stopSuperInstantFishing()
        end
    end
})

blatantSection2:AddPanel({
    Title = "Reel Delay",
    Content = "Delay between reels (seconds)",
    Placeholder = "1.25",
    Default = tostring(_G.ReelSuper),
    ButtonText = "Set",
    Callback = function(input)
        local num = tonumber(input)
        if num and num >= 0 then
            _G.ReelSuper = num
        end
    end
})

blatantSection2:AddPanel({
    Title = "Complete Delay",
    Content = "Delay before completing (seconds)",
    Placeholder = "0.08",
    Default = tostring(toggleState.completeDelays),
    ButtonText = "Set",
    Callback = function(input)
        local num = tonumber(input)
        if num and num > 0 then
            toggleState.completeDelays = num
        end
    end
})

-- RECOVERY FISHING BUTTON
local function doRecoveryFishing()
    -- Stop Blatant V1
    if c.d then
        c.d = false
        if m then 
            pcall(task.cancel, m)
            m = nil
        end
        if n then 
            pcall(task.cancel, n)
            n = nil
        end
    end
    
    -- Stop Blatant V2
    if toggleState.blatantRunning then
        toggleState.blatantRunning = false
        isSuperInstantRunning = false
    end
    
    -- Cancel all fishing
    pcall(function()
        if l then l:InvokeServer() end
        if require(RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/CancelFishingInputs"]) then
            require(RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/CancelFishingInputs"]):InvokeServer()
        end
    end)
    
    -- Reset rod
    pcall(function()
        if k then k:FireServer(1) end
        if require(RS.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]) then
            require(RS.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]):FireServer(1)
        end
    end)
    
    notif("Fishing recovery complete!", 3, Color3.fromRGB(0, 255, 0))
    return true
end

blatantSection1:AddButton({
    Title = "Recovery Fishing",
    Content = "Reset fishing state",
    Callback = doRecoveryFishing
})

blatantSection2:AddButton({
    Title = "Recovery Fishing",
    Content = "Reset fishing state",
    Callback = doRecoveryFishing
})

-- SKIN ANIMATION SECTION
local skinSection = Tab3:AddSection("Skin Animation", false)

_G.BlockRodAnim = false
_G.CurrentTrack = nil
_G.ActiveAnim = nil
_G.SelectedAnim = nil
_G.Animator = nil

-- Animation list
local AnimationList = {
    ["None"] = nil,
    ["Holy Trident"] = "Holy Trident - FishCaught",
    ["Eclipse Katana"] = "Eclipse Katana - FishCaught",
    ["1x1x1x1 Ban Hammer"] = "1x1x1x1 Ban Hammer - FishCaught",
    ["Frozen Krampus Scythe"] = "Frozen Krampus Scythe - FishCaught",
    ["The Vanquisher"] = "The Vanquisher - FishCaught",
    ["Gingerbread Katana"] = "Gingerbread Katana - FishCaught",
    ["Christmas Parasol"] = "Christmas Parasol - FishCaught",
    ["Blackhole Sword"] = "Blackhole Sword - FishCaught",
    ["Eternal Flower"] = "Eternal Flower - FishCaught"
}

local animNames = {}
for name in pairs(AnimationList) do
    table.insert(animNames, name)
end
table.sort(animNames)

skinSection:AddDropdown({
    Title = "Select Rod Animation",
    Content = "Choose fishing rod animation",
    Options = animNames,
    Default = "None",
    Callback = function(selected)
        _G.SelectedAnim = selected
    end
})

skinSection:AddButton({
    Title = "Apply Animation",
    Content = "Apply selected animation",
    Callback = function()
        _G.ActiveAnim = AnimationList[_G.SelectedAnim]
        notif("Animation applied: " .. _G.SelectedAnim, 3, Color3.fromRGB(0, 255, 0))
    end
})

skinSection:AddButton({
    Title = "Disable Animation",
    Content = "Disable all animations",
    Callback = function()
        _G.ActiveAnim = nil
        _G.SelectedAnim = "None"
        notif("All animations disabled", 3, Color3.fromRGB(255, 0, 0))
    end
})

-- Hook animation system
task.spawn(function()
    local function hookCharacter(char)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end

        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = humanoid
        end

        _G.Animator = animator

        animator.AnimationPlayed:Connect(function(track)
            if _G.BlockRodAnim and track ~= _G.CurrentTrack then
                track:Stop()
            end
        end)
    end

    if Player.Character then
        hookCharacter(Player.Character)
    end

    Player.CharacterAdded:Connect(function(char)
        _G.CurrentTrack = nil
        task.wait(0.2)
        hookCharacter(char)
    end)

    -- Fish caught event
    RS:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RE/FishCaught").OnClientEvent:Connect(function()
        if _G.ActiveAnim then
            local function PlayFishAnim(animName)
                if not _G.Animator then return end
                if not RS:FindFirstChild("Modules") then return end

                local animFolder = RS.Modules:FindFirstChild("Animations")
                if not animFolder then return end

                local animObj = animFolder:FindFirstChild(animName)
                if not animObj then return end

                _G.BlockRodAnim = true

                if _G.CurrentTrack then
                    _G.CurrentTrack:Stop()
                end

                local track = _G.Animator:LoadAnimation(animObj)
                track.Priority = Enum.AnimationPriority.Action
                track.Looped = false
                track:Play()

                _G.CurrentTrack = track

                task.delay(1, function()
                    _G.BlockRodAnim = false
                end)
            end
            
            PlayFishAnim(_G.ActiveAnim)
        end
    end)
end)

-- ==================== TAB 4: AUTO ====================
local Tab4 = Window:AddTab({
    Name = "Auto",
    Icon = "loop"
})

-- AUTO SELL SECTION
local sellSection = Tab4:AddSection("Auto Sell", false)

local AutoSell = false
local SellAt = 100
local Selling = false
local SellMinute = 5
local LastSell = 0

-- Item utility
local ItemUtility, DataService
task.spawn(function()
    ItemUtility = require(RS.Shared.ItemUtility)
    DataService = require(RS.Packages.Replion).Client:WaitReplion("Data")
end)

local function getFishCount()
    if not (DataService and ItemUtility) then return 0 end
    local items = DataService:GetExpect({ "Inventory", "Items" })
    local count = 0
    for _, v in pairs(items) do
        local itemData = ItemUtility.GetItemDataFromItemType("Items", v.Id)
        if itemData and itemData.Data and itemData.Data.Type == "Fish" then
            count += 1
        end
    end
    return count
end

-- Auto Sell Threshold
sellSection:AddPanel({
    Title = "Auto Sell When Fish ≥",
    Content = "Sell automatically when fish count reaches this number",
    Placeholder = "100",
    Default = tostring(SellAt),
    ButtonText = "Set",
    Callback = function(text)
        local n = tonumber(text)
        if n and n > 0 then 
            SellAt = math.floor(n) 
            notif("Will sell at " .. SellAt .. " fish", 3, Color3.fromRGB(0, 255, 0))
        end
    end
})

-- Auto Sell Toggle
sellSection:AddToggle({
    Title = "Auto Sell All Fish",
    Content = "Automatically sell all fish when threshold reached",
    Default = false,
    Callback = function(state)
        AutoSell = state
    end
})

-- Auto Sell Interval
sellSection:AddPanel({
    Title = "Auto Sell Interval (Minutes)",
    Content = "Sell automatically every X minutes",
    Placeholder = "5",
    Default = tostring(SellMinute),
    ButtonText = "Set",
    Callback = function(text)
        local n = tonumber(text)
        if n and n > 0 then 
            SellMinute = math.floor(n) 
            notif("Will sell every " .. SellMinute .. " minutes", 3, Color3.fromRGB(0, 255, 0))
        end
    end
})

-- Auto sell heartbeat
SafeConnect("AutoSellHeartbeat", game:GetService("RunService").Heartbeat:Connect(function()
    if not AutoSell or Selling then return end
    
    if getFishCount() >= SellAt then
        Selling = true
        pcall(function() 
            require(RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]):InvokeServer() 
        end)
        task.delay(1.5, function() Selling = false end)
    end
    
    if os.clock() - LastSell >= (SellMinute * 60) then
        if getFishCount() > 0 then
            Selling = true
            pcall(function() 
                require(RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]):InvokeServer() 
            end)
            LastSell = os.clock()
            task.delay(1.5, function() Selling = false end)
        else
            LastSell = os.clock()
        end
    end
end))

-- AUTO FAVORITE SECTION
local favSection = Tab4:AddSection("Auto Favorite", false)

local GlobalFav = {
    REObtainedNewFishNotification = RS.Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"],
    REFavoriteItem = RS.Packages._Index["sleitnick_net@0.2.0"].net["RE/FavoriteItem"],

    FishIdToName = {},
    FishNameToId = {},
    FishNames = {},
    Variants = {},
    VariantIdToName = {},
    VariantNames = {},
    SelectedFishIds = {},
    SelectedVariants = {},
    AutoFavoriteEnabled = false
}

-- Refresh fish data
local function refreshFishData()
    -- Clear old data
    GlobalFav.FishIdToName = {}
    GlobalFav.FishNameToId = {}
    GlobalFav.FishNames = {}
    GlobalFav.Variants = {}
    GlobalFav.VariantIdToName = {}
    GlobalFav.VariantNames = {}
    
    -- Load fish data
    for _, item in pairs(RS.Items:GetChildren()) do
        local ok, data = pcall(require, item)
        if ok and data.Data and data.Data.Type == "Fish" then
            local id = data.Data.Id
            local name = data.Data.Name
            GlobalFav.FishIdToName[id] = name
            GlobalFav.FishNameToId[name] = id
            table.insert(GlobalFav.FishNames, name)
        end
    end
    
    -- Sort fish names alphabetically
    table.sort(GlobalFav.FishNames)
    
    -- Load variant data
    for _, variantModule in pairs(RS.Variants:GetChildren()) do
        local ok, variantData = pcall(require, variantModule)
        if ok and variantData.Data and variantData.Data.Name then
            local id = variantData.Data.Id or variantModule.Name
            local name = variantData.Data.Name
            GlobalFav.Variants[id] = name
            GlobalFav.VariantIdToName[id] = name
            table.insert(GlobalFav.VariantNames, name)
        end
    end
    
    -- Sort variant names alphabetically
    table.sort(GlobalFav.VariantNames)
    
    notif(string.format("Loaded %d fish and %d variants!", #GlobalFav.FishNames, #GlobalFav.VariantNames), 3, Color3.fromRGB(0, 255, 0))
end

-- Auto Favorite Toggle
favSection:AddToggle({
    Title = "Auto Favorite",
    Content = "Automatically favorite caught fish",
    Default = false,
    Callback = function(state)
        GlobalFav.AutoFavoriteEnabled = state
        
        if state then
            notif("Auto Favorite enabled!", 3, Color3.fromRGB(0, 255, 0))
        else
            notif("Auto Favorite disabled!", 3, Color3.fromRGB(255, 0, 0))
        end
    end
})

-- Refresh Button
favSection:AddButton({
    Title = "Refresh Fish List",
    Content = "Load all available fish and variants",
    Callback = refreshFishData
})

-- Fish Selection Input
local selectedFishInput = ""
favSection:AddPanel({
    Title = "Select Fish (Comma separated)",
    Content = "Enter fish names to auto-favorite",
    Placeholder = "Shark, Whale, Dolphin",
    Default = "",
    ButtonText = "Set",
    Callback = function(input)
        selectedFishInput = input
        GlobalFav.SelectedFishIds = {}
        
        for fishName in input:gmatch("[^,]+") do
            local trimmedName = fishName:gsub("^%s*(.-)%s*$", "%1")
            local id = GlobalFav.FishNameToId[trimmedName]
            if id then
                GlobalFav.SelectedFishIds[id] = true
            end
        end
        
        local count = 0
        for _ in pairs(GlobalFav.SelectedFishIds) do count = count + 1 end
        notif(count .. " fish selected for favoriting", 3, Color3.fromRGB(0, 255, 0))
    end
})

-- Variant Selection Input
local selectedVariantInput = ""
favSection:AddPanel({
    Title = "Select Variants (Comma separated)",
    Content = "Enter variant names to auto-favorite",
    Placeholder = "Golden, Rainbow, Diamond",
    Default = "",
    ButtonText = "Set",
    Callback = function(input)
        selectedVariantInput = input
        GlobalFav.SelectedVariants = {}
        
        for variantName in input:gmatch("[^,]+") do
            local trimmedName = variantName:gsub("^%s*(.-)%s*$", "%1")
            for vId, name in pairs(GlobalFav.Variants) do
                if name == trimmedName then
                    GlobalFav.SelectedVariants[vId] = true
                end
            end
        end
        
        local count = 0
        for _ in pairs(GlobalFav.SelectedVariants) do count = count + 1 end
        notif(count .. " variants selected for favoriting", 3, Color3.fromRGB(0, 255, 0))
    end
})

-- Reset Button
favSection:AddButton({
    Title = "Reset Selection",
    Content = "Clear all fish and variant selections",
    Callback = function()
        GlobalFav.SelectedFishIds = {}
        GlobalFav.SelectedVariants = {}
        selectedFishInput = ""
        selectedVariantInput = ""
        notif("All selections cleared!", 3, Color3.fromRGB(255, 0, 0))
    end
})

-- Auto favorite logic
GlobalFav.REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId, _, data)
    if not GlobalFav.AutoFavoriteEnabled then return end

    local uuid = data.InventoryItem and data.InventoryItem.UUID
    local fishName = GlobalFav.FishIdToName[itemId] or "Unknown"
    local variantId = data.InventoryItem and data.InventoryItem.Metadata and data.InventoryItem.Metadata.VariantId

    if not uuid then return end

    local isFishSelected = GlobalFav.SelectedFishIds[itemId]
    local isVariantSelected = variantId and GlobalFav.SelectedVariants[variantId]
    
    -- Check if any fish selected
    local hasFishSelection = false
    for _ in pairs(GlobalFav.SelectedFishIds) do 
        hasFishSelection = true 
        break 
    end
    
    -- Check if any variant selected
    local hasVariantSelection = false
    for _ in pairs(GlobalFav.SelectedVariants) do 
        hasVariantSelection = true 
        break 
    end

    local shouldFavorite = false

    if isFishSelected and not hasVariantSelection then
        shouldFavorite = true
    elseif not hasFishSelection and isVariantSelected then
        shouldFavorite = true
    elseif isFishSelected and isVariantSelected then
        shouldFavorite = true
    end

    if shouldFavorite then
        local success = pcall(function()
            GlobalFav.REFavoriteItem:FireServer(uuid)
        end)
        
        if success then
            local msg = fishName
            if isVariantSelected and variantId then
                local variantName = GlobalFav.Variants[variantId] or variantId
                msg = msg .. " (" .. variantName .. ")"
            end
            
            notif("Auto favorited: " .. msg, 2, Color3.fromRGB(0, 255, 255))
        end
    end
end)

-- EVENT SECTION
local eventSection = Tab4:AddSection("Events", false)

-- Auto Open Mysterious Cave
_G.AutoOpenMaze = false
_G.AutoOpenMazeTask = nil

eventSection:AddToggle({
    Title = "Auto Open Mysterious Cave",
    Content = "Automatically open mysterious cave (Take Quest First)",
    Default = false,
    Callback = function(state)
        _G.AutoOpenMaze = state

        if state then
            _G.AutoOpenMazeTask = task.spawn(function()
                while _G.AutoOpenMaze do
                    pcall(function()
                        RS:WaitForChild("Packages")
                            :WaitForChild("_Index")
                            :WaitForChild("sleitnick_net@0.2.0")
                            :WaitForChild("net")
                            :WaitForChild("RE/SearchItemPickedUp")
                            :FireServer("TNT")

                        task.wait(1)

                        RS:WaitForChild("Packages")
                            :WaitForChild("_Index")
                            :WaitForChild("sleitnick_net@0.2.0")
                            :WaitForChild("net")
                            :WaitForChild("RE/GainAccessToMaze")
                            :FireServer()
                    end)

                    task.wait(2)
                end
            end)
        else
            _G.AutoOpenMaze = false
            if _G.AutoOpenMazeTask then
                task.cancel(_G.AutoOpenMazeTask)
                _G.AutoOpenMazeTask = nil
            end
        end
    end
})

-- Auto Claim Pirate Chest
_G.AutoClaimPirateChest = false
eventSection:AddToggle({
    Title = "Auto Claim Pirate Chest",
    Content = "Automatically claim pirate chest rewards",
    Default = false,
    Callback = function(v)
        _G.AutoClaimPirateChest = v
    end
})

-- Pirate chest event
task.spawn(function()
    local Claim = RS.Packages._Index["sleitnick_net@0.2.0"].net["RE/ClaimPirateChest"]
    local Award = RS.Packages._Index["sleitnick_net@0.2.0"].net["RE/AwardPirateChest"]

    Award.OnClientEvent:Connect(function(chestId)
        if _G.AutoClaimPirateChest then
            pcall(function()
                Claim:FireServer(chestId)
            end)
        end
    end)
end)

-- AUTO TOTEM SECTION
local totemSection = Tab4:AddSection("Totem Feature", false)

_G.AutoTotemEnabled = false
_G.SelectedTotemId = 1
_G.TotemDelayMinutes = 60

local function getTotemName(id)
    local map = {
        [1] = "Luck Totem",
        [2] = "Mutation Totem",
        [3] = "Shiny Totem"
    }
    return map[id] or ("Totem ID: " .. tostring(id))
end

-- Totem dropdown
local totemOptions = {"Luck Totem", "Mutation Totem", "Shiny Totem"}
totemSection:AddDropdown({
    Title = "Select Totem Type",
    Content = "Choose which totem to auto-place",
    Options = totemOptions,
    Default = totemOptions[1],
    Callback = function(selected)
        if selected == "Luck Totem" then
            _G.SelectedTotemId = 1
        elseif selected == "Mutation Totem" then
            _G.SelectedTotemId = 2
        elseif selected == "Shiny Totem" then
            _G.SelectedTotemId = 3
        end
    end
})

-- Place Totem Button
totemSection:AddButton({
    Title = "Place Selected Totem",
    Content = "Place the selected totem now",
    Callback = function()
        local Net = require(RS.Packages.Net)
        local Replion = require(RS.Packages.Replion)
        local DataReplion = Replion.Client:WaitReplion("Data")
        
        local inventory = DataReplion:Get("Inventory")
        if not inventory or not inventory.Totems then return end

        local spawnTotem = Net:RemoteEvent("SpawnTotem")

        for _, totem in pairs(inventory.Totems) do
            if totem.Id == _G.SelectedTotemId then
                spawnTotem:FireServer(totem.UUID)
                notif("Placed " .. getTotemName(_G.SelectedTotemId), 3, Color3.fromRGB(0, 255, 0))
                break
            end
        end
    end
})

-- Delay Input
totemSection:AddPanel({
    Title = "Delay (Minutes)",
    Content = "Delay between auto-placing totems",
    Placeholder = "60",
    Default = tostring(_G.TotemDelayMinutes),
    ButtonText = "Set",
    Callback = function(value)
        local minutes = tonumber(value)
        if minutes and minutes > 0 then
            _G.TotemDelayMinutes = minutes
            notif("Totem delay set to " .. minutes .. " minutes", 3, Color3.fromRGB(0, 255, 0))
        end
    end
})

-- Auto Place Totem Toggle
totemSection:AddToggle({
    Title = "Auto Place Totem",
    Content = "Automatically place totem on cooldown",
    Default = false,
    Callback = function(enabled)
        _G.AutoTotemEnabled = enabled
        if not enabled then return end

        task.spawn(function()
            while _G.AutoTotemEnabled do
                local Net = require(RS.Packages.Net)
                local Replion = require(RS.Packages.Replion)
                local DataReplion = Replion.Client:WaitReplion("Data")
                
                local inventory = DataReplion:Get("Inventory")
                if inventory and inventory.Totems then
                    local spawnTotem = Net:RemoteEvent("SpawnTotem")
                    for _, totem in pairs(inventory.Totems) do
                        if totem.Id == _G.SelectedTotemId then
                            spawnTotem:FireServer(totem.UUID)
                            notif("Auto-placed " .. getTotemName(_G.SelectedTotemId), 2, Color3.fromRGB(0, 255, 0))
                            break
                        end
                    end
                end
                task.wait(_G.TotemDelayMinutes * 60)
            end
        end)
    end
})

-- ==================== TAB 5: WEBHOOK ====================
local Tab5 = Window:AddTab({
    Name = "Webhook",
    Icon = "bell"
})

local webhookSection = Tab5:AddSection("Webhook Fish Caught", false)

local httpRequest = syn and syn.request or http and http.request or http_request or (fluxus and fluxus.request) or request

-- Fish Database
local fishDB = {}
local rarityList = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET" }
local tierToRarity = {
    [1] = "Common", [2] = "Uncommon", [3] = "Rare", [4] = "Epic",
    [5] = "Legendary", [6] = "Mythic", [7] = "SECRET"
}
local knownFishUUIDs = {}

-- Webhook URL
_G.WebhookURL = ""
_G.WebhookRarities = {}
_G.DetectNewFishActive = false

-- Build fish database
local function buildFishDatabase()
    local itemsContainer = RS:WaitForChild("Items")
    if not itemsContainer then return end

    for _, itemModule in ipairs(itemsContainer:GetChildren()) do
        local success, itemData = pcall(require, itemModule)
        if success and type(itemData) == "table" and itemData.Data and itemData.Data.Type == "Fish" then
            local data = itemData.Data
            if data.Id and data.Name then
                fishDB[data.Id] = {
                    Name = data.Name,
                    Tier = data.Tier,
                    Icon = data.Icon,
                    SellPrice = itemData.SellPrice
                }
            end
        end
    end
end

-- Get inventory fish
local function getInventoryFish()
    local ItemUtility = require(RS.Shared.ItemUtility)
    local Replion = require(RS.Packages.Replion)
    local DataService = Replion.Client:WaitReplion("Data")
    
    if not (DataService and ItemUtility) then return {} end
    local inventoryItems = DataService:GetExpect({ "Inventory", "Items" })
    local fishes = {}
    for _, v in pairs(inventoryItems) do
        local itemData = ItemUtility.GetItemDataFromItemType("Items", v.Id)
        if itemData and itemData.Data.Type == "Fish" then
            table.insert(fishes, { Id = v.Id, UUID = v.UUID, Metadata = v.Metadata })
        end
    end
    return fishes
end

-- Get player coins
local function getPlayerCoins()
    local Replion = require(RS.Packages.Replion)
    local DataService = Replion.Client:WaitReplion("Data")
    if not DataService then return "N/A" end
    
    local success, coins = pcall(function() return DataService:Get("Coins") end)
    if success and coins then
        return string.format("%d", coins):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    end
    return "N/A"
end

-- Get thumbnail URL
local function getThumbnailURL(assetString)
    local assetId = assetString:match("rbxassetid://(%d+)")
    if not assetId then return nil end
    local api = string.format(
        "https://thumbnails.roblox.com/v1/assets?assetIds=%s&type=Asset&size=420x420&format=Png",
        assetId
    )
    local success, response = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet(api))
    end)
    return success and response and response.data and response.data[1] and response.data[1].imageUrl
end

-- Test webhook
local function sendTestWebhook()
    if not httpRequest or not _G.WebhookURL or not _G.WebhookURL:match("discord.com/api/webhooks") then
        notif("Webhook URL Empty or Invalid", 3, Color3.fromRGB(255, 0, 0))
        return
    end

    local payload = {
        username = "Victoria Hub Webhook",
        avatar_url = "https://cdn.discordapp.com/attachments/1358728774098882653/1459169498383909049/ai_repair_20260106014107493.png?ex=69624cfe&is=6960fb7e&hm=7ae73d692bb21a5dabee8b09b0d8447b90c5c2a29612b313ebeb9c3c87ae94e4&",
        embeds = {{
            title = "Test Webhook Connected",
            description = "Webhook connection successful!",
            color = 0xFFFFFF
        }}
    }

    task.spawn(function()
        pcall(function()
            httpRequest({
                Url = _G.WebhookURL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = game:GetService("HttpService"):JSONEncode(payload)
            })
            notif("Test webhook sent successfully!", 3, Color3.fromRGB(0, 255, 0))
        end)
    end)
end

-- Send fish caught webhook
local function sendNewFishWebhook(newlyCaughtFish)
    if not httpRequest or not _G.WebhookURL or not _G.WebhookURL:match("discord.com/api/webhooks") then return end

    local newFishDetails = fishDB[newlyCaughtFish.Id]
    if not newFishDetails then return end

    local newFishRarity = tierToRarity[newFishDetails.Tier] or "Unknown"
    if #_G.WebhookRarities > 0 and not table.find(_G.WebhookRarities, newFishRarity) then return end

    local fishWeight = (newlyCaughtFish.Metadata and newlyCaughtFish.Metadata.Weight and string.format("%.2f Kg", newlyCaughtFish.Metadata.Weight)) or "N/A"
    local mutation   = (newlyCaughtFish.Metadata and newlyCaughtFish.Metadata.VariantId and tostring(newlyCaughtFish.Metadata.VariantId)) or "None"
    local sellPrice  = (newFishDetails.SellPrice and ("$"..string.format("%d", newFishDetails.SellPrice):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "").." Coins")) or "N/A"
    local currentCoins = getPlayerCoins()

    local totalFishInInventory = #getInventoryFish()
    local backpackInfo = string.format("%d/4500", totalFishInInventory)
    local playerName = game.Players.LocalPlayer.Name

    local payload = {
        content = nil,
        embeds = {{
            title = "Victoria Hub Webhook Fish caught!",
            description = string.format("Congrats! **%s** You obtained new **%s** here for full detail fish :", playerName, newFishRarity),
            url = "https://discord.gg/victoriahub",
            color = 65535,
            fields = {
                {
                    name = "Fish Details",
                    value = "```" ..
                        "Name Fish        : " .. newFishDetails.Name .. "\n" ..
                        "Rarity           : " .. newFishRarity .. "\n" ..
                        "Weight           : " .. fishWeight .. "\n" ..
                        "Mutation         : " .. mutation .. "\n" ..
                        "Sell Price       : " .. sellPrice .. "\n" ..
                        "Backpack Counter : " .. backpackInfo .. "\n" ..
                        "Current Coin     : " .. currentCoins .. "\n" ..
                        "```"
                }
            },
            footer = {
                text = "Victoria Hub Webhook",
                icon_url = "https://cdn.discordapp.com/attachments/1358728774098882653/1459169498383909049/ai_repair_20260106014107493.png?ex=69624cfe&is=6960fb7e&hm=7ae73d692bb21a5dabee8b09b0d8447b90c5c2a29612b313ebeb9c3c87ae94e4&"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
            thumbnail = { url = getThumbnailURL(newFishDetails.Icon) }
        }},
        username = "Victoria Hub Webhook",
        avatar_url = "https://cdn.discordapp.com/attachments/1358728774098882653/1459169498383909049/ai_repair_20260106014107493.png?ex=69624cfe&is=6960fb7e&hm=7ae73d692bb21a5dabee8b09b0d8447b90c5c2a29612b313ebeb9c3c87ae94e4&",
        attachments = {}
    }

    task.spawn(function()
        pcall(function()
            httpRequest({
                Url = _G.WebhookURL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = game:GetService("HttpService"):JSONEncode(payload)
            })
        end)
    end)
end

-- Webhook URL Input
webhookSection:AddPanel({
    Title = "Webhook URL",
    Content = "Enter your Discord webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Default = "",
    ButtonText = "Set",
    Callback = function(text)
        _G.WebhookURL = text
        notif("Webhook URL set!", 3, Color3.fromRGB(0, 255, 0))
    end
})

-- Rarity filter (multi-select)
local selectedRarities = {}
webhookSection:AddPanel({
    Title = "Rarity Filter (Comma separated)",
    Content = "Filter which rarities to send (Common, Uncommon, Rare, etc.)",
    Placeholder = "Legendary, Mythic, SECRET",
    Default = "",
    ButtonText = "Set",
    Callback = function(text)
        _G.WebhookRarities = {}
        for rarity in text:gmatch("[^,]+") do
            local trimmed = rarity:gsub("^%s*(.-)%s*$", "%1")
            table.insert(_G.WebhookRarities, trimmed)
        end
        notif("Rarity filter set: " .. table.concat(_G.WebhookRarities, ", "), 3, Color3.fromRGB(0, 255, 0))
    end
})

-- Send Webhook Toggle
webhookSection:AddToggle({
    Title = "Send Fish Caught Webhook",
    Content = "Send webhook notification when catching fish",
    Default = false,
    Callback = function(state)
        _G.DetectNewFishActive = state
        if state then
            notif("Fish webhook detection enabled", 3, Color3.fromRGB(0, 255, 0))
        else
            notif("Fish webhook detection disabled", 3, Color3.fromRGB(255, 0, 0))
        end
    end
})

-- Test Webhook Button
webhookSection:AddButton({
    Title = "Test Webhook",
    Content = "Send test webhook to check connection",
    Callback = sendTestWebhook
})

-- Initialize fish detection
task.spawn(function()
    buildFishDatabase()
    
    local initialFishList = getInventoryFish()
    for _, fish in ipairs(initialFishList) do
        if fish and fish.UUID then knownFishUUIDs[fish.UUID] = true end
    end
    
    Performance.Tasks["FishDetection"] = task.spawn(function()
        while true do
            task.wait(3)
            if _G.DetectNewFishActive then
                local currentFishList = getInventoryFish()
                for _, fish in ipairs(currentFishList) do
                    if fish and fish.UUID and not knownFishUUIDs[fish.UUID] then
                        knownFishUUIDs[fish.UUID] = true
                        sendNewFishWebhook(fish)
                    end
                end
            end
        end
    end)
end)

-- ==================== TAB 6: SHOP ====================
local Tab6 = Window:AddTab({
    Name = "Shop",
    Icon = "shop"
})

-- BUY ROD SECTION
local rodSection = Tab6:AddSection("Buy Rod", false)

local R = {
    ["Luck Rod"] = 79, ["Carbon Rod"] = 76, ["Grass Rod"] = 85,
    ["Demascus Rod"] = 77, ["Ice Rod"] = 78, ["Lucky Rod"] = 4,
    ["Midnight Rod"] = 80, ["Steampunk Rod"] = 6, ["Chrome Rod"] = 7,
    ["Astral Rod"] = 5, ["Ares Rod"] = 126, ["Angler Rod"] = 168,
    ["Bamboo Rod"] = 258
}

local rodOptions = {
    "Luck Rod (350 Coins)", "Carbon Rod (900 Coins)", "Grass Rod (1.5k Coins)",
    "Demascus Rod (3k Coins)", "Ice Rod (5k Coins)", "Lucky Rod (15k Coins)",
    "Midnight Rod (50k Coins)", "Steampunk Rod (215k Coins)", "Chrome Rod (437k Coins)",
    "Astral Rod (1M Coins)", "Ares Rod (3M Coins)", "Angler Rod (8M Coins)",
    "Bamboo Rod (12M Coins)"
}

local selectedRod = rodOptions[1]

rodSection:AddDropdown({
    Title = "Select Rod",
    Content = "Choose fishing rod to buy",
    Options = rodOptions,
    Default = selectedRod,
    Callback = function(v)
        selectedRod = v
    end
})

rodSection:AddButton({
    Title = "Buy Rod",
    Callback = function()
        local name = selectedRod:match("^(.-) %(")
        if name and R[name] then
            pcall(function() 
                require(RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseFishingRod"]):InvokeServer(R[name]) 
            end)
            notif("Purchased: " .. name, 3, Color3.fromRGB(0, 255, 0))
        end
    end
})

-- BUY BAIT SECTION
local baitSection = Tab6:AddSection("Buy Baits", false)

local B = {
    ["Luck Bait"] = 2, ["Midnight Bait"] = 3, ["Nature Bait"] = 10,
    ["Chroma Bait"] = 6, ["Dark Matter Bait"] = 8, ["Corrupt Bait"] = 15,
    ["Aether Bait"] = 16, ["Floral Bait"] = 20
}

local baitOptions = {}
for name, _ in pairs(B) do
    table.insert(baitOptions, name)
end

local selectedBait = baitOptions[1]

baitSection:AddDropdown({
    Title = "Select Bait",
    Content = "Choose bait to buy",
    Options = baitOptions,
    Default = selectedBait,
    Callback = function(v)
        selectedBait = v
    end
})

baitSection:AddButton({
    Title = "Buy Bait",
    Callback = function()
        if selectedBait and B[selectedBait] then
            pcall(function() 
                require(RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseBait"]):InvokeServer(B[selectedBait]) 
            end)
            notif("Purchased: " .. selectedBait, 3, Color3.fromRGB(0, 255, 0))
        end
    end
})

-- MERCHANT SECTION
local merchantSection = Tab6:AddSection("Merchant", false)

merchantSection:AddButton({
    Title = "OPEN MERCHANT",
    Content = "Open traveling merchant UI",
    Callback = function()
        local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        local merchantUI = playerGui:WaitForChild("Merchant")
        
        if merchantUI then
            merchantUI.Enabled = true
            notif("Merchant opened!", 3, Color3.fromRGB(0, 255, 0))
        end
    end
})

merchantSection:AddButton({
    Title = "CLOSE MERCHANT",
    Content = "Close traveling merchant UI",
    Callback = function()
        local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        local merchantUI = playerGui:FindFirstChild("Merchant")
        
        if merchantUI then
            merchantUI.Enabled = false
            notif("Merchant closed!", 3, Color3.fromRGB(255, 0, 0))
        end
    end
})

-- BUY WEATHER EVENT
local weatherSection = Tab6:AddSection("Weather Events", false)

local autoBuyEnabled = false
local buyDelay = 100 -- seconds

-- Weather to buy
local autoBuyWeathers = {
    "Wind",
    "Cloudy",
    "Storm"
}

weatherSection:AddToggle({
    Title = "Auto Buy Weather",
    Content = "Auto buy Wind, Cloudy, Storm (100s loop)",
    Default = false,
    Callback = function(state)
        autoBuyEnabled = state
        SafeCancel("AutoBuyWeather")

        if state then
            notif("Auto buy weather enabled!", 3, Color3.fromRGB(0, 255, 0))

            Performance.Tasks["AutoBuyWeather"] = task.spawn(function()
                while autoBuyEnabled do
                    for _, weatherName in ipairs(autoBuyWeathers) do
                        pcall(function()
                            require(RS.Packages._Index["sleitnick_net@0.2.0"])
                                .net["RF/PurchaseWeatherEvent"]
                                :InvokeServer(weatherName)
                        end)
                        task.wait(0.3) -- safe delay between requests
                    end

                    task.wait(buyDelay) -- 100 second delay
                end
            end)
        else
            notif("Auto buy weather disabled!", 3, Color3.fromRGB(255, 0, 0))
        end
    end
})

-- ==================== TAB 7: TELEPORT ====================
local Tab7 = Window:AddTab({
    Name = "Teleport",
    Icon = "gps"
})

-- ISLAND TELEPORT SECTION
local islandSection = Tab7:AddSection("Island Teleport", false)

local IslandLocations = {
    ["Ancient Jungle"] = CFrame.new(1480.000, 3.029, -334.000, -0.766, 0.000, -0.643, 0.000, 1.000, 0.000, 0.643, 0.000, -0.766),
    ["Coral Refs"] = CFrame.new(-3270.860, 2.500, 2228.100, -0.000, 0.000, 1.000, 0.000, 1.000, -0.000, -1.000, 0.000, -0.000),
    ["Crater Island"] = CFrame.new(1079.570, 3.645, 5080.350, -0.000, -0.000, 1.000, -0.000, 1.000, 0.000, -1.000, -0.000, -0.000),
    ["Enchant Room"] = CFrame.new(3232.390, -1302.855, 1401.953),
    ["Enchant Room 2"] = CFrame.new(1480, 126, -585),
    ["Esoteric Island"] = CFrame.new(3208.000, -1302.855, 1420.000, -0.940, 0.000, -0.342, 0.000, 1.000, 0.000, 0.342, 0.000, -0.940),
    ["Fisherman Island"] = CFrame.new(51.000, 2.279, 2762.000, 1.000, -0.000, -0.000, 0.000, 1.000, 0.000, 0.000, -0.000, 1.000),
    ["Kohana Volcano"] = CFrame.new(-561.810, 21.239, 156.720, -1.000, 0.000, -0.000, 0.000, 1.000, 0.000, 0.000, 0.000, -1.000),
    ["Konoha"] = CFrame.new(-625.000, 19.250, 424.000, -1.000, 0.000, -0.000, 0.000, 1.000, 0.000, 0.000, 0.000, -1.000),
    ["Sacred Temple"] = CFrame.new(1485.000, -21.875, -641.000, 0.866, 0.000, -0.500, -0.000, 1.000, 0.000, 0.500, 0.000, 0.866),
    ["Sysyphus Statue"] = CFrame.new(-3702.000, -135.074, -1009.000, -1.000, -0.000, -0.000, -0.000, 1.000, -0.000, 0.000, -0.000, -1.000),
    ["Treasure Room"] = CFrame.new(-3609.000, -279.074, -1591.000, 1.000, 0.000, -0.000, -0.000, 1.000, -0.000, 0.000, 0.000, 1.000),
    ["Tropical Grove"] = CFrame.new(-2020.000, 4.744, 3755.000, -1.000, -0.000, -0.000, -0.000, 1.000, -0.000, 0.000, -0.000, -1.000),
    ["Underground Cellar"] = CFrame.new(2136.000, -91.199, -699.000, 1.000, 0.000, -0.000, -0.000, 1.000, -0.000, 0.000, 0.000, 1.000),
    ["Weather Machine"] = CFrame.new(-1524.880, 2.875, 1915.560, -1.000, 0.000, -0.000, 0.000, 1.000, 0.000, 0.000, 0.000, -1.000),
    ["Ancient Ruin"] = CFrame.new(6085.609, -585.924, 4638.000, -0.666, -0.000, 0.746, -0.000, 1.000, 0.000, -0.746, -0.000, -0.666),
    ["Pirate Cave"] = CFrame.new(3399.000, 2.708, 3469.000, -0.000, 0.000, -1.000, -0.000, 1.000, 0.000, 1.000, 0.000, -0.000),
    ["Treasure Pirate Cave"] = CFrame.new(3307.264, -303.662, 3031.954, -0.761, 0.000, -0.649, 0.000, 1.000, 0.000, 0.649, 0.000, -0.761),
    ["Crystal Depths"] = CFrame.new(5637.000, -904.985, 15354.000, -0.866, 0.000, -0.500, 0.000, 1.000, 0.000, 0.500, 0.000, -0.866),
    ["Leviathan Den"] = CFrame.new(3473.000, -287.843, 3472.000, -0.866, 0.000, -0.500, 0.000, 1.000, 0.000, 0.500, 0.000, -0.866),
    ["Secret Passage"] = CFrame.new(3440.293, -287.845, 3384.696, -0.924, -0.000, -0.382, -0.000, 1.000, -0.000, 0.382, -0.000, -0.924),
}

local islandNames = {}
for name in pairs(IslandLocations) do table.insert(islandNames, name) end
table.sort(islandNames)

local SelectedIsland = islandNames[1]

islandSection:AddDropdown({
    Title = "Select Island",
    Content = "Choose island to teleport to",
    Options = islandNames,
    Default = SelectedIsland,
    Callback = function(Value)
        SelectedIsland = Value
    end
})

islandSection:AddButton({
    Title = "Teleport to Island",
    Callback = function()
        if SelectedIsland and IslandLocations[SelectedIsland] then
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = IslandLocations[SelectedIsland]
                notif("Teleported to: " .. SelectedIsland, 3, Color3.fromRGB(0, 255, 0))
            end
        end
    end
})

-- PLAYER TELEPORT SECTION
local playerTeleportSection = Tab7:AddSection("Player Teleport", false)

local selectedPlayerName = nil
local playerList = {}

-- Refresh player list
local function refreshPlayerList()
    playerList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            table.insert(playerList, plr.Name)
        end
    end
    table.sort(playerList)
    
    -- Update dropdown if we could
    if #playerList > 0 then
        selectedPlayerName = playerList[1]
    else
        selectedPlayerName = nil
    end
end

-- Player dropdown (using input since VictUI doesn't have dynamic dropdown)
playerTeleportSection:AddPanel({
    Title = "Teleport Target",
    Content = "Enter player name to teleport to",
    Placeholder = "PlayerName",
    Default = "",
    ButtonText = "Set",
    Callback = function(input)
        selectedPlayerName = input
        notif("Target set to: " .. input, 3, Color3.fromRGB(0, 255, 0))
    end
})

-- Refresh button
playerTeleportSection:AddButton({
    Title = "Refresh Player List",
    Content = "Refresh list of online players",
    Callback = function()
        refreshPlayerList()
        local playerCount = #playerList
        if playerCount > 0 then
            notif("Found " .. playerCount .. " players online", 3, Color3.fromRGB(0, 255, 0))
        else
            notif("No other players online", 3, Color3.fromRGB(255, 0, 0))
        end
    end
})

-- Teleport button
playerTeleportSection:AddButton({
    Title = "Teleport to Player",
    Content = "Teleport to selected player",
    Callback = function()
        if not selectedPlayerName then
            notif("No player selected!", 3, Color3.fromRGB(255, 0, 0))
            return
        end

        local target = Players:FindFirstChild(selectedPlayerName)
        if not target or not target.Character then
            notif("Target player not found!", 3, Color3.fromRGB(255, 0, 0))
            return
        end

        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local myHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

        if not targetHRP or not myHRP then
            notif("Character parts not found!", 3, Color3.fromRGB(255, 0, 0))
            return
        end

        -- Teleport to player
        myHRP.CFrame = CFrame.new(
            targetHRP.Position + Vector3.new(0, 3, 0)
        )
        notif("Teleported to: " .. selectedPlayerName, 3, Color3.fromRGB(0, 255, 0))
    end
})

-- Initialize player list
refreshPlayerList()

-- EVENT TELEPORT SECTION
local eventTeleportSection = Tab7:AddSection("Event Teleporter", false)

-- Event data
local eventData = {
    ["Worm Hunt"] = {
        TargetName = "Model",
        Locations = {
            Vector3.new(2190.85, -1.4, 97.575),
            Vector3.new(-2450.679, -1.4, 139.731),
            Vector3.new(-267.479, -1.4, 5188.531),
            Vector3.new(-327, -1.4, 2422)
        },
        PlatformY = 106,
        Priority = 1
    },

    ["Megalodon Hunt"] = {
        TargetName = "Megalodon Hunt",
        Locations = {
            Vector3.new(-1076.3, -1.4, 1676.2),
            Vector3.new(-1191.8, -1.4, 3597.3),
            Vector3.new(412.7, -1.4, 4134.4)
        },
        PlatformY = 106,
        Priority = 2
    },

    ["Ghost Shark Hunt"] = {
        TargetName = "Ghost Shark Hunt",
        Locations = {
            Vector3.new(489.559, -1.35, 25.406),
            Vector3.new(-1358.216, -1.35, 4100.556),
            Vector3.new(627.859, -1.35, 3798.081)
        },
        PlatformY = 106,
        Priority = 3
    },

    ["Shark Hunt"] = {
        TargetName = "Shark Hunt",
        Locations = {
            Vector3.new(1.65, -1.35, 2095.725),
            Vector3.new(1369.95, -1.35, 930.125),
            Vector3.new(-1585.5, -1.35, 1242.875),
            Vector3.new(-1896.8, -1.35, 2634.375)
        },
        PlatformY = 106,
        Priority = 4
    }
}

-- Event names
local eventNames = {}
for n in pairs(eventData) do
    table.insert(eventNames, n)
end

-- State
local ST = {
    player = Player,
    char = nil,
    hrp = nil,

    megRadius = 150,
    autoTP = false,
    autoFloat = false,
    selectedEvents = {},
    lastTP = nil,
    tpCooldown = 0.3,
    floatOffset = 6
}

-- Initialize character
local function bindChar(c)
    ST.char = c
    task.wait(1)
    ST.hrp = c:WaitForChild("HumanoidRootPart")
end

bindChar(ST.player.Character or ST.player.CharacterAdded:Wait())
ST.player.CharacterAdded:Connect(bindChar)

-- Force TP
local function forceTP(pos)
    if not ST.lastTP or (ST.lastTP - pos).Magnitude > 5 then
        ST.lastTP = pos
        for _ = 1, 2 do
            ST.hrp.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z)
            ST.hrp.AssemblyLinearVelocity = Vector3.zero
            ST.hrp.Velocity = Vector3.zero
            task.wait(0.02)
        end
    end
end

-- Main TP loop
local function runEventTP()
    while ST.autoTP do
        local list = {}

        for _, name in ipairs(ST.selectedEvents) do
            if eventData[name] then
                list[#list+1] = eventData[name]
            end
        end

        table.sort(list, function(a, b)
            return a.Priority < b.Priority
        end)

        for _, cfg in ipairs(list) do
            local found

            if cfg.TargetName == "Model" then
                local rings = workspace:FindFirstChild("!!! MENU RINGS")
                if rings then
                    for _, p in ipairs(rings:GetChildren()) do
                        if p.Name == "Props" then
                            local m = p:FindFirstChild("Model")
                            if m and m.PrimaryPart then
                                for _, loc in ipairs(cfg.Locations) do
                                    if (m.PrimaryPart.Position - loc).Magnitude <= ST.megRadius then
                                        found = m.PrimaryPart.Position
                                        break
                                    end
                                end
                            end
                        end
                        if found then break end
                    end
                end
            else
                for _, loc in ipairs(cfg.Locations) do
                    for _, d in ipairs(workspace:GetDescendants()) do
                        if d.Name == cfg.TargetName then
                            local pos = d:IsA("BasePart") and d.Position or (d.PrimaryPart and d.PrimaryPart.Position)
                            if pos and (pos - loc).Magnitude <= ST.megRadius then
                                found = pos
                                break
                            end
                        end
                    end
                    if found then break end
                end
            end

            if found then
                forceTP(found)
            end
        end

        task.wait(ST.tpCooldown)
    end
end

-- Float
game:GetService("RunService").RenderStepped:Connect(function()
    if ST.autoFloat and ST.hrp then
        local pos = ST.hrp.Position
        local targetY = workspace.Terrain.WaterLevel + ST.floatOffset
        if pos.Y < targetY then
            ST.hrp.CFrame = CFrame.new(pos.X, targetY, pos.Z)
            ST.hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)

-- Event selection input
eventTeleportSection:AddPanel({
    Title = "Select Events (Comma separated)",
    Content = "Events to auto-teleport to: Worm Hunt, Megalodon Hunt, etc.",
    Placeholder = "Worm Hunt, Megalodon Hunt",
    Default = "",
    ButtonText = "Set",
    Callback = function(input)
        ST.selectedEvents = {}
        for event in input:gmatch("[^,]+") do
            local trimmed = event:gsub("^%s*(.-)%s*$", "%1")
            table.insert(ST.selectedEvents, trimmed)
        end
        notif("Events set: " .. table.concat(ST.selectedEvents, ", "), 3, Color3.fromRGB(0, 255, 0))
    end
})

-- Auto Event Toggle
eventTeleportSection:AddToggle({
    Title = "Auto Event Teleport",
    Content = "Automatically teleport to selected events",
    Default = false,
    Callback = function(state)
        ST.autoTP = state
        ST.autoFloat = state
        ST.lastTP = nil
        if state then
            task.defer(runEventTP)
            notif("Auto event teleport enabled", 3, Color3.fromRGB(0, 255, 0))
        else
            notif("Auto event teleport disabled", 3, Color3.fromRGB(255, 0, 0))
        end
    end
})

-- ==================== TAB 8: SETTINGS ====================
local Tab8 = Window:AddTab({
    Name = "Settings",
    Icon = "settings"
})

-- MISC SECTION
local miscSection = Tab8:AddSection("Miscellaneous", false)

-- INFINITE ZOOM
local Z = {Player.CameraMaxZoomDistance, Player.CameraMinZoomDistance}

miscSection:AddToggle({
    Title = "Infinite Zoom",
    Content = "Infinite zoom to take photos",
    Default = false,
    Callback = function(s)
        if s then
            Player.CameraMaxZoomDistance = math.huge
            Player.CameraMinZoomDistance = .5
            notif("Infinite zoom enabled", 3, Color3.fromRGB(0, 255, 0))
        else
            Player.CameraMaxZoomDistance = Z[1] or 128
            Player.CameraMinZoomDistance = Z[2] or .5
            notif("Infinite zoom disabled", 3, Color3.fromRGB(255, 0, 0))
        end
    end
})

-- HIDE NAME
local hideNameValue = "Victoria Hub"
miscSection:AddPanel({
    Title = "Hide Name",
    Content = "Custom name to display",
    Placeholder = "Input Name",
    Default = hideNameValue,
    ButtonText = "Set",
    Callback = function(v)
        hideNameValue = v
        local char = Player.Character
        if char then
            local overhead = char:FindFirstChild("HumanoidRootPart"):FindFirstChild("Overhead")
            if overhead then
                local header = overhead.Content.Header
                header.Text = v
            end
        end
        notif("Custom name set: " .. v, 3, Color3.fromRGB(0, 255, 0))
    end
})

-- HIDE LEVEL
local hideLevelValue = "Lv. ???"
miscSection:AddPanel({
    Title = "Hide Level",
    Content = "Custom level to display",
    Placeholder = "Input Level",
    Default = hideLevelValue,
    ButtonText = "Set",
    Callback = function(v)
        hideLevelValue = v
        local char = Player.Character
        if char then
            local overhead = char:FindFirstChild("HumanoidRootPart"):FindFirstChild("Overhead")
            if overhead then
                local level = overhead.LevelContainer.Label
                level.Text = v
            end
        end
        notif("Custom level set: " .. v, 3, Color3.fromRGB(0, 255, 0))
    end
})

-- AUTO RECONNECT
local AutoReconnect = false
local VIM = game:GetService("VirtualInputManager")

local function click(btn)
    local pos = btn.AbsolutePosition + btn.AbsoluteSize / 2
    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
end

SafeConnect("AutoReconnect", game:GetService("CoreGui"):WaitForChild("RobloxPromptGui")
    :WaitForChild("promptOverlay")
    .ChildAdded:Connect(function(v)
        if not AutoReconnect then return end
        if v.Name ~= "ErrorPrompt" then return end

        task.wait(0.3)
        local btn = v:FindFirstChild("ReconnectButton", true)
        if btn then click(btn) end
    end))

miscSection:AddToggle({
    Title = "Auto Reconnect",
    Content = "Auto click Reconnect button",
    Default = false,
    Callback = function(v) 
        AutoReconnect = v
        if v then
            notif("Auto reconnect enabled", 3, Color3.fromRGB(0, 255, 0))
        else
            notif("Auto reconnect disabled", 3, Color3.fromRGB(255, 0, 0))
        end
    end
})

-- ANTI STAFF
local AntiStaffEnabled = true
local StaffBlacklist = {
    [75974130]=1,[40397833]=1,[187190686]=1,[33372493]=1,[889918695]=1,
    [33679472]=1,[30944240]=1,[25050357]=1,[8462585751]=1,[8811129148]=1,
    [192821024]=1,[4509801805]=1,[124505170]=1,[108397209]=1
}

miscSection:AddToggle({
    Title = "Anti Staff",
    Content = "Auto serverhop if staff detected",
    Default = true,
    Callback = function(s) 
        AntiStaffEnabled = s
        if s then
            notif("Anti-staff enabled", 3, Color3.fromRGB(0, 255, 0))
        else
            notif("Anti-staff disabled", 3, Color3.fromRGB(255, 0, 0))
        end
    end
})

local function hop()
    task.wait(6)
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        ).data
    end)
    
    if success and data then
        for _,v in ipairs(data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id, Player)
                break
            end
        end
    end
end

SafeConnect("PlayerAddedAntiStaff", Players.PlayerAdded:Connect(function(plr)
    if AntiStaffEnabled and plr ~= Player and StaffBlacklist[plr.UserId] then
        notif(plr.Name.." joined, serverhopping in 6 seconds...", 6, Color3.fromRGB(255, 255, 0))
        hop()
    end
end))

Performance.Tasks["AntiStaffCheck"] = task.spawn(function()
    while task.wait(2) do
        if AntiStaffEnabled then
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr ~= Player and StaffBlacklist[plr.UserId] then
                    notif(plr.Name.." detected, serverhopping in 6 seconds...", 6, Color3.fromRGB(255, 255, 0))
                    hop()
                    break
                end
            end
        end
    end
end)

-- SERVER SECTION
local serverSection = Tab8:AddSection("Server", false)

serverSection:AddButton({
    Title = "Rejoin",
    Content = "Rejoin to the same server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, Player)
    end
})

serverSection:AddButton({
    Title = "Server Hop",
    Content = "Switch to another server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, Player)
    end
})

-- OTHER SCRIPTS SECTION
local scriptSection = Tab8:AddSection("Other Scripts", false)

scriptSection:AddButton({
    Title = "Infinite Yield",
    Content = "Load Infinite Yield script",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/main/latest.lua'))()
        notif("Infinite Yield loaded successfully!", 5, Color3.fromRGB(0, 255, 0))
    end
})

-- GRAPHICS SECTION
local graphicsSection = Tab8:AddSection("Graphics", false)

-- FPS BOOST
local FPSBoost = false
local OriginalValues = {}
local FPSConnections = {}

local function saveOriginal(obj, property)
    if not OriginalValues[obj] then
        OriginalValues[obj] = {}
    end
    if OriginalValues[obj][property] == nil then
        OriginalValues[obj][property] = obj[property]
    end
end

local function applyBoost()
    -- Lighting settings
    local Lighting = game:GetService("Lighting")
    
    saveOriginal(Lighting, "GlobalShadows")
    saveOriginal(Lighting, "FogEnd")
    saveOriginal(Lighting, "Brightness")
    saveOriginal(Lighting, "EnvironmentDiffuseScale")
    saveOriginal(Lighting, "EnvironmentSpecularScale")
    saveOriginal(Lighting, "ClockTime")
    saveOriginal(Lighting, "Ambient")
    saveOriginal(Lighting, "OutdoorAmbient")
    
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.ClockTime = 12
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    
    -- Disable post effects
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            saveOriginal(effect, "Enabled")
            effect.Enabled = false
        end
    end
    
    -- Terrain settings
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    if Terrain then
        saveOriginal(Terrain, "WaterWaveSize")
        saveOriginal(Terrain, "WaterWaveSpeed")
        saveOriginal(Terrain, "WaterReflectance")
        saveOriginal(Terrain, "WaterTransparency")
        
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end
    
    -- Monitor new objects
    local connection = game.DescendantAdded:Connect(function(obj)
        if FPSBoost then
            pcall(function()
                if obj:IsA("BasePart") then
                    saveOriginal(obj, "Material")
                    saveOriginal(obj, "Reflectance")
                    saveOriginal(obj, "CastShadow")
                    
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                    obj.CastShadow = false
                    
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    saveOriginal(obj, "Transparency")
                    obj.Transparency = 1
                    
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    saveOriginal(obj, "Enabled")
                    obj.Enabled = false
                end
            end)
        end
    end)
    
    table.insert(FPSConnections, connection)
end

local function restoreBoost()
    -- Disconnect connections
    for _, connection in ipairs(FPSConnections) do
        pcall(function() connection:Disconnect() end)
    end
    FPSConnections = {}
    
    -- Restore values
    for obj, properties in pairs(OriginalValues) do
        if obj then
            for property, value in pairs(properties) do
                pcall(function()
                    obj[property] = value
                end)
            end
        end
    end
    
    OriginalValues = {}
end

graphicsSection:AddToggle({
    Title = "FPS Boost",
    Content = "Optimize graphics for better FPS",
    Default = false,
    Callback = function(v)
        FPSBoost = v
        
        if v then
            applyBoost()
            notif("FPS Boost enabled", 3, Color3.fromRGB(0, 255, 0))
        else
            restoreBoost()
            notif("FPS Boost disabled", 3, Color3.fromRGB(255, 0, 0))
        end
    end
})

-- REMOVE FISH NOTIFICATION
local PopupConn, RemoteConn

graphicsSection:AddToggle({
    Title = "Remove Fish Notification",
    Content = "Remove fish caught pop-up notifications",
    Default = false,
    Callback = function(state)
        local PlayerGui = Player:WaitForChild("PlayerGui")
        local RemoteEvent = RS.Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"]

        if state then
            local function getPopup()
                local gui = PlayerGui:FindFirstChild("Small Notification")
                if not gui then return end
                local display = gui:FindFirstChild("Display")
                if not display then return end
                return display:FindFirstChild("NewFrame")
            end

            local frame = getPopup()
            if frame then frame.Visible = false; frame:Destroy() end

            PopupConn = PlayerGui.DescendantAdded:Connect(function(v)
                if v.Name == "NewFrame" then
                    task.wait()
                    v.Visible = false
                    v:Destroy()
                end
            end)

            RemoteConn = RemoteEvent.OnClientEvent:Connect(function()
                local f = getPopup()
                if f then f.Visible = false; f:Destroy() end
            end)
            
            notif("Fish notifications removed", 3, Color3.fromRGB(0, 255, 0))
        else
            if PopupConn then PopupConn:Disconnect(); PopupConn = nil end
            if RemoteConn then RemoteConn:Disconnect(); RemoteConn = nil end
            notif("Fish notifications restored", 3, Color3.fromRGB(255, 0, 0))
        end
    end
})

-- HIDE ALL VFX
local VFXState = {on = false, cache = {}}

local VFX = {
    ParticleEmitter = true, Beam = true, Trail = true, Smoke = true,
    Fire = true, Sparkles = true, Explosion = true,
    PointLight = true, SpotLight = true, SurfaceLight = true, Highlight = true
}

local LE = {
    BloomEffect = true, SunRaysEffect = true, ColorCorrectionEffect = true,
    DepthOfFieldEffect = true, Atmosphere = true
}

local function disableVFX()
    for _, o in ipairs(workspace:GetDescendants()) do
        if VFX[o.ClassName] and o.Enabled == true then
            VFXState.cache[o] = true
            o.Enabled = false
        end
    end

    for _, o in ipairs(game:GetService("Lighting"):GetChildren()) do
        if LE[o.ClassName] and o.Enabled ~= nil then
            VFXState.cache[o] = true
            o.Enabled = false
        end
    end
end

local function restoreVFX()
    for o in pairs(VFXState.cache) do
        if o and o.Parent and o.Enabled ~= nil then o.Enabled = true end
    end
    VFXState.cache = {}
end

SafeConnect("VFXDescendant", workspace.DescendantAdded:Connect(function(o)
    if VFXState.on and VFX[o.ClassName] and o.Enabled ~= nil then
        task.defer(function() o.Enabled = false end)
    end
end))

SafeConnect("LightingDescendant", game:GetService("Lighting").DescendantAdded:Connect(function(o)
    if VFXState.on and LE[o.ClassName] and o.Enabled ~= nil then
        task.defer(function() o.Enabled = false end)
    end
end))

graphicsSection:AddToggle({
    Title = "Hide All VFX",
    Content = "Hide all visual effects",
    Default = false,
    Callback = function(state)
        VFXState.on = state
        if state then 
            disableVFX()
            notif("All VFX hidden", 3, Color3.fromRGB(0, 255, 0))
        else 
            restoreVFX()
            notif("VFX restored", 3, Color3.fromRGB(255, 0, 0))
        end
    end
})

-- REMOVE SKIN EFFECT
local VFXController = require(RS.Controllers.VFXController)
local ORI = {
    H = VFXController.Handle,
    P = VFXController.RenderAtPoint,
    I = VFXController.RenderInstance
}

graphicsSection:AddToggle({
    Title = "Remove Skin Effect",
    Content = "Remove fishing skin visual effects",
    Default = false,
    Callback = function(state)
        if state then
            VFXController.Handle = function() end
            VFXController.RenderAtPoint = function() end
            VFXController.RenderInstance = function() end

            local f = workspace:FindFirstChild("CosmeticFolder")
            if f then pcall(f.ClearAllChildren, f) end
            
            notif("Skin effects removed", 3, Color3.fromRGB(0, 255, 0))
        else
            VFXController.Handle = ORI.H
            VFXController.RenderAtPoint = ORI.P
            VFXController.RenderInstance = ORI.I
            notif("Skin effects restored", 3, Color3.fromRGB(255, 0, 0))
        end
    end
})

-- DISABLE CUTSCENE
_G.CutsceneController = require(RS.Controllers.CutsceneController)
_G.GuiControl = require(RS.Modules.GuiControl)
_G.ProximityPromptService = game:GetService("ProximityPromptService")
_G.AutoSkipCutscene = false

if not _G.OriginalPlayCutscene then
    _G.OriginalPlayCutscene = _G.CutsceneController.Play
end

_G.CutsceneController.Play = function(self, ...)
    if _G.AutoSkipCutscene then
        task.spawn(function()
            task.wait()
            if _G.GuiControl then _G.GuiControl:SetHUDVisibility(true) end
            _G.ProximityPromptService.Enabled = true
            Player:SetAttribute("IgnoreFOV", false)
        end)
        return
    end
    return _G.OriginalPlayCutscene(self, ...)
end

graphicsSection:AddToggle({
    Title = "Disable Cutscene",
    Content = "Skip all cutscenes automatically",
    Default = false,
    Callback = function(state)
        _G.AutoSkipCutscene = state
        if state then
            if _G.CutsceneController then
                _G.CutsceneController:Stop()
                _G.GuiControl:SetHUDVisibility(true)
                _G.ProximityPromptService.Enabled = true
            end
            notif("Cutscenes disabled", 3, Color3.fromRGB(0, 255, 0))
        else
            notif("Cutscenes enabled", 3, Color3.fromRGB(255, 0, 0))
        end
    end
})

-- ==================== FINAL CLEANUP ====================
local function cleanup()
    for name, _ in pairs(Performance.Tasks) do SafeCancel(name) end
    for name, _ in pairs(Performance.Connections) do SafeDisconnect(name) end
    
    _G.InfiniteJump = false
    _G.Noclip = false
    _G.AutoFishing = false
    _G.AutoEquipRod = false
    _G.Radar = false
    _G.Instant = false
    _G.AntiAFK = false
    _G.AutoSkipCutscene = false
    
    if FPSBoost then
        restoreBoost()
    end
end

-- game:BindToClose(cleanup)

-- ==================== FINAL NOTIFICATION ====================
task.spawn(function()
    task.wait(1)
    notif("Victoria Hub loaded successfully!", 5, Color3.fromRGB(138, 43, 226))
end)

getgenv().VictoriaHubWindow = Window

return Window
