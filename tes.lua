-- [[ VICTORIA HUB FISH IT - MIGRATED TO VictUI ]] --
-- Version: 1.0.0
-- ALL ORIGINAL FEATURES MIGRATED TO VictUI LIBRARY

-- ==================== LOAD VICTUI LIBRARY ====================
local Vict = loadstring(game:HttpGet("https://raw.githubusercontent.com/WhoIsGenn/ui/refs/heads/main/victui.lua"))()

-- ==================== CREATE MAIN WINDOW ====================
local Window = Vict:Window({
    Title = "Victoria Hub",
    Footer = "VictoriaHub | Fish It",
    Color = Color3.fromRGB(138, 43, 226),
    ["Tab Width"] = 120,
    Version = 0.094,
    Icon = "rbxassetid://134034549147826",
    Image = "134034549147826",
    Theme = nil,
    ThemeTransparency = 0.5
})

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

-- Extra activity loop (anti detect tambahan)
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

-- TITLE ANIMATION
task.spawn(function()
    task.wait(2)
    if _G.TitleEnabled then
        _G.TitleEnabled.Visible = false
        _G.Title.TextScaled = false
        _G.Title.TextSize = 19
        _G.Title.Text = "Victoria Hub"

        local uiStroke = Instance.new("UIStroke")
        uiStroke.Thickness = 2
        uiStroke.Color = Color3.fromRGB(170, 0, 255)
        uiStroke.Parent = _G.Title

        local colors = {
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(255, 0, 127),
            Color3.fromRGB(0, 255, 127),
            Color3.fromRGB(255, 255, 0)
        }

        local i = 1
        local function colorCycle()
            if not _G.Title or not _G.Title.Parent then return end
            
            local nextColor = colors[(i % #colors) + 1]
            local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            
            game:GetService("TweenService"):Create(_G.Title, tweenInfo, { TextColor3 = nextColor }):Play()
            game:GetService("TweenService"):Create(uiStroke, tweenInfo, { Color = nextColor }):Play()
            
            i += 1
            Performance.Tasks["ColorCycle"] = task.delay(1.5, colorCycle)
        end
        
        colorCycle()
    end
end)

-- ==================== EXECUTOR DETECTION ====================
local executorName = "Unknown"
if identifyexecutor then executorName = identifyexecutor() end

local executorColor = Color3.fromRGB(200, 200, 200)
if executorName:lower():find("flux") then
    executorColor = Color3.fromHex("#30ff6a")
elseif executorName:lower():find("delta") then
    executorColor = Color3.fromHex("#38b6ff")
elseif executorName:lower():find("arceus") then
    executorColor = Color3.fromHex("#a03cff")
elseif executorName:lower():find("krampus") or executorName:lower():find("oxygen") then
    executorColor = Color3.fromHex("#ff3838")
elseif executorName:lower():find("volcano") then
    executorColor = Color3.fromHex("#ff8c00")
elseif executorName:lower():find("synapse") or executorName:lower():find("script") or executorName:lower():find("krypton") then
    executorColor = Color3.fromHex("#ffd700")
elseif executorName:lower():find("wave") then
    executorColor = Color3.fromHex("#00e5ff")
elseif executorName:lower():find("zenith") then
    executorColor = Color3.fromHex("#ff00ff")
elseif executorName:lower():find("seliware") then
    executorColor = Color3.fromHex("#00ffa2")
elseif executorName:lower():find("krnl") then
    executorColor = Color3.fromHex("#1e90ff")
elseif executorName:lower():find("trigon") then
    executorColor = Color3.fromHex("#ff007f")
elseif executorName:lower():find("nihon") then
    executorColor = Color3.fromHex("#8a2be2")
elseif executorName:lower():find("celery") then
    executorColor = Color3.fromHex("#4caf50")
elseif executorName:lower():find("lunar") then
    executorColor = Color3.fromHex("#8080ff")
elseif executorName:lower():find("valyse") then
    executorColor = Color3.fromHex("#ff1493")
elseif executorName:lower():find("vega") then
    executorColor = Color3.fromHex("#4682b4")
elseif executorName:lower():find("electron") then
    executorColor = Color3.fromHex("#7fffd4")
elseif executorName:lower():find("awp") then
    executorColor = Color3.fromHex("#ff005e")
elseif executorName:lower():find("bunni") or executorName:lower():find("bunni.lol") then
    executorColor = Color3.fromHex("#ff69b4")
end

-- Send notification
notif("Victoria Hub loaded! Executor: " .. executorName, 5, executorColor, "Victoria Hub", "Info")

-- ==================== DISCORD DIALOG ====================
Window:AddParagraph({
    Title = "Join Discord",
    Content = "For updates and support, join our Discord server!",
    Icon = "discord",
    ButtonText = "Copy Link",
    ButtonCallback = function()
        if setclipboard then
            setclipboard("https://discord.gg/victoriahub")
            Vict:MakeNotify({
                Title = "Success",
                Description = "Copied to clipboard!",
                Content = "Discord link has been copied",
                Color = Color3.fromRGB(0, 255, 0),
                Time = 0.5,
                Delay = 3
            })
        else
            Vict:MakeNotify({
                Title = "Error",
                Description = "Copy failed",
                Content = "Your executor doesn't support clipboard",
                Color = Color3.fromRGB(255, 0, 0),
                Time = 0.5,
                Delay = 3
            })
        end
    end
})

-- ==================== TAB 1: INFO ====================
local Tab1 = Window:AddTab({
    Name = "Info",
    Icon = "alert"
})

Tab1:AddParagraph({
    Title = "Victoria Hub Community",
    Content = "Join Our Community Discord Server to get the latest updates, support, and connect with other users!",
    Icon = "discord",
    ButtonText = "Copy Link",
    ButtonCallback = function()
        setclipboard("https://discord.gg/victoriahub")
        Vict:MakeNotify({
            Title = "Success",
            Description = "Link copied!",
            Content = "Discord link copied to clipboard",
            Color = Color3.fromRGB(0, 255, 0),
            Time = 0.5,
            Delay = 3
        })
    end
})

-- ==================== TAB 2: PLAYERS ====================
local Tab2 = Window:AddTab({
    Name = "Players",
    Icon = "user"
})

local otherSection = Tab2:AddSection("Other Features", false)

-- SPEED
otherSection:AddSlider({
    Title = "Speed",
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
otherSection:AddSlider({
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

otherSection:AddToggle({
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

otherSection:AddToggle({
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
local frozen, last
local P, SG = game.Players.LocalPlayer, game.StarterGui

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

otherSection:AddToggle({
    Title = "Freeze Character",
    Content = "Freeze your character in place",
    Default = false,
    Callback = function(s)
        frozen = s
        setFreeze(s)
    end
})

-- DISABLE ANIMATIONS
local animDisabled = false
local animConn

local function applyAnimState()
    local c = P.Character or P.CharacterAdded:Wait()
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return end

    if animDisabled then
        for _, track in ipairs(h:GetPlayingAnimationTracks()) do
            pcall(function() track:Stop(0); track:Destroy() end)
        end

        if animConn then animConn:Disconnect(); animConn = nil end

        animConn = h.AnimationPlayed:Connect(function(track)
            if animDisabled and track then
                task.defer(function()
                    pcall(function() track:Stop(0); track:Destroy() end)
                end)
            end
        end)
    else
        if animConn then animConn:Disconnect(); animConn = nil end
        local animate = c:FindFirstChild("Animate")
        if animate then animate.Disabled = false end
        h:ChangeState(Enum.HumanoidStateType.Physics)
        task.wait()
        h:ChangeState(Enum.HumanoidStateType.Running)
    end
end

SafeConnect("CharacterAddedAnim", P.CharacterAdded:Connect(function()
    task.wait(0.4)
    if animDisabled then pcall(applyAnimState) end
end))

otherSection:AddToggle({
    Title = "Disable Animations",
    Content = "Disable all character animations",
    Default = false,
    Callback = function(state)
        animDisabled = state
        pcall(applyAnimState)
    end
})

-- WALK ON WATER
_G.LocalPlayer = game:GetService("Players").LocalPlayer
_G.RunService = game:GetService("RunService")
_G.UserInputService = game:GetService("UserInputService")

_G.walkOnWaterConnection = nil
_G.isWalkOnWater = false
_G.waterPlatform = nil

otherSection:AddToggle({
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

            _G.walkOnWaterConnection = _G.RunService.RenderStepped:Connect(function()
                if not _G.isWalkOnWater then return end

                _G.character = _G.LocalPlayer.Character
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
                        if not _G.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
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

local fishingSection = Tab3:AddSection("Fishing", false)

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
local net = RS.Packages._Index["sleitnick_net@0.2.0"].net

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

-- Fishing Mode
local mode = "Instant"
local fishThread
local sellThread

fishingSection:AddDropdown({
    Title = "Fishing Mode",
    Content = "Select fishing mode",
    Options = {"Instant", "Legit"},
    Default = "Instant",
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

-- Instant Fishing Delay Slider
fishingSection:AddSlider({
    Title = "Instant Fishing Delay",
    Content = "Delay between instant fishing cycles",
    Min = 0.05,
    Max = 5,
    Default = _G.InstantDelay,
    Increment = 0.01,
    Callback = function(v)
        _G.InstantDelay = v
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

-- BLANTANT V1 SECTION
local blatantV1Section = Tab3:AddSection("Blatant V1", false)

-- BLANTANT V1 CONFIG & FUNCTIONS
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

blatantV1Section:AddToggle({
    Title = "Blatant Mode V1",
    Content = "Activate Blatant V1 fishing",
    Default = false,
    Callback = function(z2)
        x(z2)
    end
})

blatantV1Section:AddPanel({
    Title = "Cancel Delay",
    Content = "Delay before canceling fishing",
    Placeholder = "1.7",
    Default = tostring(c.e),
    ButtonText = "Set",
    ButtonCallback = function(input)
        local z5 = tonumber(input)
        if z5 and z5 > 0 then
            c.e = z5
        end
    end
})

blatantV1Section:AddPanel({
    Title = "Complete Delay",
    Content = "Delay before completing fishing",
    Placeholder = "1.4",
    Default = tostring(c.f),
    ButtonText = "Set",
    ButtonCallback = function(input)
        local z8 = tonumber(input)
        if z8 and z8 > 0 then
            c.f = z8
        end
    end
})

blatantV1Section:AddButton({
    Title = "Recovery Fishing",
    Callback = function()
        -- Recovery function for Blatant V1
        pcall(function()
            if l then l:InvokeServer() end
            if k then k:FireServer(1) end
        end)
    end
})

-- BLANTANT V2 SECTION
local blatantV2Section = Tab3:AddSection("Blatant V2", false)

-- BLANTANT V2 CONFIG & FUNCTIONS
local netFolder = RS:WaitForChild('Packages'):WaitForChild('_Index'):WaitForChild('sleitnick_net@0.2.0'):WaitForChild('net')

local Remotes = {}
Remotes.RF_RequestFishingMinigameStarted = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
Remotes.RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
Remotes.RF_CancelFishing = netFolder:WaitForChild("RF/CancelFishingInputs")
Remotes.RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
Remotes.RE_EquipTool = netFolder:WaitForChild("RE/EquipToolFromHotbar")

local toggleState = {
    blatantRunning = false,
}

local FishingController = require(
    RS:WaitForChild('Controllers'):WaitForChild('FishingController')
)

local oldCharge = FishingController.RequestChargeFishingRod
FishingController.RequestChargeFishingRod = function(...)
    if toggleState.blatantRunning then
        return
    end
    return oldCharge(...)
end

local isSuperInstantRunning = false
_G.ReelSuper = 1.25
toggleState.completeDelays = 0.08
toggleState.delayStart = 0.25

local function superInstantFishingCycle()
    task.spawn(function()
        Remotes.RF_CancelFishing:InvokeServer()
        Remotes.RF_ChargeFishingRod:InvokeServer(tick())
        Remotes.RF_RequestFishingMinigameStarted:InvokeServer(-139.63796997070312, 0.9964792798079721)
        task.wait(toggleState.completeDelays)
        Remotes.RE_FishingCompleted:FireServer()
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

blatantV2Section:AddToggle({
    Title = "Blatant Mode V2",
    Content = "Activate Blatant V2 fishing",
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

blatantV2Section:AddPanel({
    Title = "Reel Delay",
    Content = "Delay between fishing cycles",
    Placeholder = "1.25",
    Default = tostring(_G.ReelSuper),
    ButtonText = "Set",
    ButtonCallback = function(input)
        local num = tonumber(input)
        if num and num >= 0 then
            _G.ReelSuper = num
        end
    end
})

blatantV2Section:AddPanel({
    Title = "Complete Delay",
    Content = "Delay before completing fishing",
    Placeholder = "0.08",
    Default = tostring(toggleState.completeDelays),
    ButtonText = "Set",
    ButtonCallback = function(input)
        local num = tonumber(input)
        if num and num > 0 then
            toggleState.completeDelays = num
        end
    end
})

blatantV2Section:AddButton({
    Title = "Recovery Fishing",
    Callback = function()
        -- Recovery function for Blatant V2
        pcall(function()
            if Remotes.RF_CancelFishing then
                Remotes.RF_CancelFishing:InvokeServer()
            end
            if Remotes.RE_EquipTool then
                Remotes.RE_EquipTool:FireServer(1)
            end
        end)
    end
})

-- BLANTANT V3 SECTION
local blatantV3Section = Tab3:AddSection("Blatant V3 [TESTER]", false)

-- BLANTANT V3 CONFIG
local V3Config = {
    IsRunning = false,
    ReelDelay = 1.55,
    CompleteDelay = 0.22
}

-- NETWORK REMOTES FOR V3
local netFolderV3 = RS:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

local RemotesV3 = {}
pcall(function()
    RemotesV3.Charge = netFolderV3:WaitForChild("RF/ChargeFishingRod")
    RemotesV3.StartMinigame = netFolderV3:WaitForChild("RF/RequestFishingMinigameStarted")
    RemotesV3.Complete = netFolderV3:WaitForChild("RE/FishingCompleted")
    RemotesV3.Equip = netFolderV3:WaitForChild("RE/EquipToolFromHotbar")
    RemotesV3.Cancel = netFolderV3:WaitForChild("RF/CancelFishingInputs")
end)

-- STATE THREADS FOR V3
local MainThreadV3 = nil
local EquipThreadV3 = nil

-- CORE CAST FUNCTION FOR V3
local function ExecuteCastV3()
    task.spawn(function()
        pcall(function()
            -- Cancel existing fishing with retry
            local cancelSuccess = RemotesV3.Cancel:InvokeServer()
            if not cancelSuccess then
                while not cancelSuccess do
                    cancelSuccess = RemotesV3.Cancel:InvokeServer()
                    if cancelSuccess then break end
                    task.wait(0.05)
                end
            end
            
            -- Charge rod with retry
            local chargeSuccess = RemotesV3.Charge:InvokeServer(tick())
            if not chargeSuccess then
                while not chargeSuccess do
                    chargeSuccess = RemotesV3.Charge:InvokeServer(tick())
                    if chargeSuccess then break end
                    task.wait(0.05)
                end
            end
            
            -- Start minigame
            RemotesV3.StartMinigame:InvokeServer(-139.63, 0.996)
        end)
    end)
    
    -- Auto complete
    task.spawn(function()
        task.wait(V3Config.CompleteDelay)
        if V3Config.IsRunning then
            pcall(RemotesV3.Complete.FireServer, RemotesV3.Complete)
        end
    end)
end

-- FISHING LOOP FOR V3
local function FishingLoopV3()
    while V3Config.IsRunning do
        ExecuteCastV3()
        task.wait(V3Config.ReelDelay)
    end
end

-- AUTO EQUIP LOOP FOR V3
local function EquipLoopV3()
    while V3Config.IsRunning do
        pcall(RemotesV3.Equip.FireServer, RemotesV3.Equip, 1)
        task.wait(1.5)
    end
end

-- TOGGLE FUNCTION FOR V3
local function ToggleV3(enabled)
    V3Config.IsRunning = enabled
    
    if enabled then
        -- Cancel old threads
        if MainThreadV3 then task.cancel(MainThreadV3) end
        if EquipThreadV3 then task.cancel(EquipThreadV3) end
        
        -- Start new threads
        MainThreadV3 = task.spawn(FishingLoopV3)
        EquipThreadV3 = task.spawn(EquipLoopV3)
    else
        -- Stop threads
        if MainThreadV3 then 
            task.cancel(MainThreadV3)
            MainThreadV3 = nil
        end
        if EquipThreadV3 then 
            task.cancel(EquipThreadV3)
            EquipThreadV3 = nil
        end
        
        -- Cancel fishing
        pcall(RemotesV3.Cancel.InvokeServer, RemotesV3.Cancel)
    end
end

blatantV3Section:AddToggle({
    Title = "Blatant Mode V3",
    Content = "Activate Blatant V3 fishing (TESTER)",
    Default = false,
    Callback = function(value)
        ToggleV3(value)
    end
})

blatantV3Section:AddPanel({
    Title = "Reel Delay",
    Content = "Delay between fishing cycles",
    Placeholder = "1.9",
    Default = tostring(V3Config.ReelDelay),
    ButtonText = "Set",
    ButtonCallback = function(input)
        local num = tonumber(input)
        if num and num > 0 then
            V3Config.ReelDelay = num
        end
    end
})

blatantV3Section:AddPanel({
    Title = "Complete Delay",
    Content = "Delay before completing fishing",
    Placeholder = "1.4",
    Default = tostring(V3Config.CompleteDelay),
    ButtonText = "Set",
    ButtonCallback = function(input)
        local num = tonumber(input)
        if num and num > 0 then
            V3Config.CompleteDelay = num
        end
    end
})

blatantV3Section:AddButton({
    Title = "Recovery Fishing",
    Callback = function()
        -- Recovery function for V3
        pcall(function()
            if RemotesV3.Cancel then
                RemotesV3.Cancel:InvokeServer()
            end
            if RemotesV3.Equip then
                RemotesV3.Equip:FireServer(1)
            end
        end)
    end
})

-- AUTO PERFECTION SECTION
local autoPerfectionSection = Tab3:AddSection("Auto Perfection", false)

-- AUTO PERFECTION FUNCTIONS
local Net = RS.Packages._Index["sleitnick_net@0.2.0"].net
local FC = require(RS.Controllers.FishingController)

local oc, orc = FC.RequestFishingMinigameClick, FC.RequestChargeFishingRod
local ap = false

task.spawn(function()
    while task.wait() do
        if ap then
            Net["RF/UpdateAutoFishingState"]:InvokeServer(true)
        end
    end
end)

local function updateAutoPerfection(s)
    ap = s
    if s then
        FC.RequestFishingMinigameClick = function() end
        FC.RequestChargeFishingRod = function() end
    else
        Net["RF/UpdateAutoFishingState"]:InvokeServer(false)
        FC.RequestFishingMinigameClick = oc
        FC.RequestChargeFishingRod = orc
    end
end

autoPerfectionSection:AddToggle({
    Title = "Auto Perfection",
    Content = "Automatically get perfect catches",
    Default = false,
    Callback = function(s)
        updateAutoPerfection(s)
    end
})

-- SKIN ANIMATION SECTION
local animationSection = Tab3:AddSection("Skin Animation", false)

-- SKIN ANIMATION SETUP
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local NetAnim = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- STATE
_G.BlockRodAnim = false
_G.CurrentTrack = nil
_G.ActiveAnim = nil
_G.SelectedAnim = nil
_G.Animator = nil

-- HOOK ANIMATOR
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

-- PLAY ANIMATION
local function PlayFishAnim(animName)
    if not _G.Animator then return end
    if not ReplicatedStorage:FindFirstChild("Modules") then return end

    local animFolder = ReplicatedStorage.Modules:FindFirstChild("Animations")
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

-- ANIMATION MAP
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

animationSection:AddDropdown({
    Title = "Select Rod Animation",
    Content = "Choose fishing rod animation",
    Options = animNames,
    Default = "None",
    Callback = function(selected)
        _G.SelectedAnim = selected
    end
})

animationSection:AddButton({
    Title = "Apply Animation",
    Callback = function()
        _G.ActiveAnim = AnimationList[_G.SelectedAnim]
        Vict:MakeNotify({
            Title = "Animation",
            Description = "Applied",
            Content = "Animation applied: " .. _G.SelectedAnim,
            Color = Color3.fromRGB(0, 255, 0),
            Time = 0.5,
            Delay = 3
        })
    end
})

animationSection:AddButton({
    Title = "Disable Animation",
    Callback = function()
        _G.ActiveAnim = nil
        _G.SelectedAnim = "None"
        Vict:MakeNotify({
            Title = "Animation",
            Description = "Disabled",
            Content = "Animation disabled",
            Color = Color3.fromRGB(255, 0, 0),
            Time = 0.5,
            Delay = 3
        })
    end
})

-- FISH CAUGHT EVENT
NetAnim:WaitForChild("RE/FishCaught").OnClientEvent:Connect(function()
    if _G.ActiveAnim then
        PlayFishAnim(_G.ActiveAnim)
    end
end)

-- ITEM SECTION
local itemSection = Tab3:AddSection("Item Features", false)

-- RADAR
itemSection:AddToggle({
    Title = "Radar",
    Content = "Activate fishing radar",
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
itemSection:AddToggle({
    Title = "Bypass Oxygen",
    Content = "Infinite oxygen underwater",
    Default = false,
    Callback = function(s)
        local net = game.ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
        if s then 
            net["RF/EquipOxygenTank"]:InvokeServer(105)
        else 
            net["RF/UnequipOxygenTank"]:InvokeServer() 
        end
    end
})

-- ==================== TAB 4: AUTO ====================
local Tab4 = Window:AddTab({
    Name = "Auto",
    Icon = "loop"
})

-- AUTO SELL SECTION
local sellSection = Tab4:AddSection("Auto Sell", false)

local SellAllRF = RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]
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

sellSection:AddPanel({
    Title = "Auto Sell When Fish ≥",
    Content = "Sell automatically when fish count reaches this number",
    Placeholder = "100",
    Default = tostring(SellAt),
    ButtonText = "Set",
    ButtonCallback = function(text)
        local n = tonumber(text)
        if n and n > 0 then 
            SellAt = math.floor(n) 
            Vict:MakeNotify({
                Title = "Auto Sell",
                Description = "Threshold set",
                Content = "Will sell at " .. SellAt .. " fish",
                Color = Color3.fromRGB(0, 255, 0),
                Time = 0.5,
                Delay = 3
            })
        end
    end
})

sellSection:AddToggle({
    Title = "Auto Sell All Fish",
    Content = "Automatically sell all fish when threshold reached",
    Default = false,
    Callback = function(state)
        AutoSell = state
    end
})

sellSection:AddPanel({
    Title = "Auto Sell Interval (Minutes)",
    Content = "Sell automatically every X minutes",
    Placeholder = "5",
    Default = tostring(SellMinute),
    ButtonText = "Set",
    ButtonCallback = function(text)
        local n = tonumber(text)
        if n and n > 0 then 
            SellMinute = math.floor(n) 
            Vict:MakeNotify({
                Title = "Auto Sell",
                Description = "Interval set",
                Content = "Will sell every " .. SellMinute .. " minutes",
                Color = Color3.fromRGB(0, 255, 0),
                Time = 0.5,
                Delay = 3
            })
        end
    end
})

-- Combined Auto Sell Heartbeat
SafeConnect("AutoSellHeartbeat", game:GetService("RunService").Heartbeat:Connect(function()
    if not AutoSell or Selling then return end
    
    if getFishCount() >= SellAt then
        Selling = true
        pcall(function() SellAllRF:InvokeServer() end)
        task.delay(1.5, function() Selling = false end)
    end
    
    if os.clock() - LastSell >= (SellMinute * 60) then
        if getFishCount() > 0 then
            Selling = true
            pcall(function() SellAllRF:InvokeServer() end)
            LastSell = os.clock()
            task.delay(1.5, function() Selling = false end)
        else
            LastSell = os.clock()
        end
    end
end))

-- AUTO FAVORITE SECTION
local favSection = Tab4:AddSection("Auto Favorite", false)

-- AUTO FAVORITE SETUP
local GlobalFav = {
    REObtainedNewFishNotification = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"],
    REFavoriteItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FavoriteItem"],

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

-- Load fish data
local function refreshDropdowns()
    -- Clear old data
    GlobalFav.FishIdToName = {}
    GlobalFav.FishNameToId = {}
    GlobalFav.FishNames = {}
    GlobalFav.Variants = {}
    GlobalFav.VariantIdToName = {}
    GlobalFav.VariantNames = {}
    
    -- Load fish data
    for _, item in pairs(ReplicatedStorage.Items:GetChildren()) do
        local ok, data = pcall(require, item)
        if ok and data.Data and data.Data.Type == "Fish" then
            local id = data.Data.Id
            local name = data.Data.Name
            GlobalFav.FishIdToName[id] = name
            GlobalFav.FishNameToId[name] = id
            table.insert(GlobalFav.FishNames, name)
        end
    end
    
    -- Sort fish names
    table.sort(GlobalFav.FishNames)
    
    -- Load variant data
    for _, variantModule in pairs(ReplicatedStorage.Variants:GetChildren()) do
        local ok, variantData = pcall(require, variantModule)
        if ok and variantData.Data and variantData.Data.Name then
            local id = variantData.Data.Id or variantModule.Name
            local name = variantData.Data.Name
            GlobalFav.Variants[id] = name
            GlobalFav.VariantIdToName[id] = name
            table.insert(GlobalFav.VariantNames, name)
        end
    end
    
    -- Sort variant names
    table.sort(GlobalFav.VariantNames)
    
    Vict:MakeNotify({
        Title = "Auto Favorite",
        Description = "Loaded",
        Content = string.format("Loaded %d fish and %d variants!", #GlobalFav.FishNames, #GlobalFav.VariantNames),
        Color = Color3.fromRGB(0, 255, 0),
        Time = 0.5,
        Delay = 3
    })
end

-- Auto Favorite Toggle
favSection:AddToggle({
    Title = "Auto Favorite",
    Content = "Automatically favorite caught fish",
    Default = false,
    Callback = function(state)
        GlobalFav.AutoFavoriteEnabled = state
        
        if state then
            Vict:MakeNotify({
                Title = "Auto Favorite",
                Description = "Enabled",
                Content = "Auto Favorite enabled!",
                Color = Color3.fromRGB(0, 255, 0),
                Time = 0.5,
                Delay = 3
            })
        else
            Vict:MakeNotify({
                Title = "Auto Favorite",
                Description = "Disabled",
                Content = "Auto Favorite disabled!",
                Color = Color3.fromRGB(255, 0, 0),
                Time = 0.5,
                Delay = 3
            })
        end
    end
})

-- Fish Dropdown
local fishDropdownInstance
fishDropdownInstance = favSection:AddDropdown({
    Title = "Select Fish",
    Content = "Choose which fish to auto favorite",
    Options = GlobalFav.FishNames,
    Default = "",
    Callback = function(selected)
        GlobalFav.SelectedFishIds = {}
        
        if selected and selected ~= "" then
            local id = GlobalFav.FishNameToId[selected]
            if id then
                GlobalFav.SelectedFishIds[id] = true
                Vict:MakeNotify({
                    Title = "Auto Favorite",
                    Description = "Fish selected",
                    Content = selected .. " selected for favoriting",
                    Color = Color3.fromRGB(0, 255, 0),
                    Time = 0.5,
                    Delay = 2
                })
            end
        end
    end
})

-- Variant Dropdown
local variantDropdownInstance
variantDropdownInstance = favSection:AddDropdown({
    Title = "Select Variants",
    Content = "Choose which variants to auto favorite",
    Options = GlobalFav.VariantNames,
    Default = "",
    Callback = function(selected)
        GlobalFav.SelectedVariants = {}
        
        if selected and selected ~= "" then
            for vId, name in pairs(GlobalFav.Variants) do
                if name == selected then
                    GlobalFav.SelectedVariants[vId] = true
                    Vict:MakeNotify({
                        Title = "Auto Favorite",
                        Description = "Variant selected",
                        Content = selected .. " selected for favoriting",
                        Color = Color3.fromRGB(0, 255, 0),
                        Time = 0.5,
                        Delay = 2
                    })
                    break
                end
            end
        end
    end
})

-- Refresh Button
favSection:AddButton({
    Title = "Refresh Fish List",
    Callback = function()
        refreshDropdowns()
        -- Update dropdowns
        if fishDropdownInstance then
            fishDropdownInstance:Set("")
            -- Note: VictUI doesn't have direct refresh for dropdown options
            -- We'll just notify user
        end
        if variantDropdownInstance then
            variantDropdownInstance:Set("")
        end
    end
})

-- Reset Button
favSection:AddButton({
    Title = "Reset Selection",
    Callback = function()
        GlobalFav.SelectedFishIds = {}
        GlobalFav.SelectedVariants = {}
        
        if fishDropdownInstance then
            fishDropdownInstance:Set("")
        end
        
        if variantDropdownInstance then
            variantDropdownInstance:Set("")
        end
        
        Vict:MakeNotify({
            Title = "Auto Favorite",
            Description = "Reset",
            Content = "All selections cleared!",
            Color = Color3.fromRGB(255, 255, 0),
            Time = 0.5,
            Delay = 2
        })
    end
})

-- Initialize fish data
task.spawn(function()
    task.wait(2)
    refreshDropdowns()
end)

-- AUTO FAVORITE LOGIC
GlobalFav.REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId, _, data)
    if not GlobalFav.AutoFavoriteEnabled then return end

    local uuid = data.InventoryItem and data.InventoryItem.UUID
    local fishName = GlobalFav.FishIdToName[itemId] or "Unknown"
    local variantId = data.InventoryItem and data.InventoryItem.Metadata and data.InventoryItem.Metadata.VariantId

    if not uuid then 
        return 
    end

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
            
            Vict:MakeNotify({
                Title = "Auto Favorite",
                Description = "Favorited",
                Content = "Favorited " .. msg,
                Color = Color3.fromRGB(0, 255, 0),
                Time = 0.5,
                Delay = 2
            })
        end
    end
end)

-- EVENT SECTION
local eventSection = Tab4:AddSection("Event Features", false)

-- Auto Open Mysterious Cave
_G.AutoOpenMaze = false
_G.AutoOpenMazeTask = nil

eventSection:AddToggle({
    Title = "Auto Open Mysterious Cave",
    Content = "Take Quest First - Auto open mysterious cave",
    Default = false,
    Callback = function(state)
        _G.AutoOpenMaze = state

        if state then
            _G.AutoOpenMazeTask = task.spawn(function()
                while _G.AutoOpenMaze do
                    pcall(function()
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Packages")
                            :WaitForChild("_Index")
                            :WaitForChild("sleitnick_net@0.2.0")
                            :WaitForChild("net")
                            :WaitForChild("RE/SearchItemPickedUp")
                            :FireServer("TNT")

                        task.wait(1)

                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Packages")
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

local NetEvent = RS.Packages._Index["sleitnick_net@0.2.0"].net
local Claim = NetEvent["RE/ClaimPirateChest"]
local Award = NetEvent["RE/AwardPirateChest"]

Award.OnClientEvent:Connect(function(chestId)
    if _G.AutoClaimPirateChest then
        pcall(function()
            Claim:FireServer(chestId)
        end)
    end
end)

-- AUTO TOTEM SECTION
local autoTotemSection = Tab4:AddSection("Totem Feature", false)

-- AUTO TOTEM SETUP
local ReplionTotem = require(RS.Packages.Replion)
local DataReplion = ReplionTotem.Client:WaitReplion("Data")

-- STATE
_G.AutoTotemEnabled = false
_G.SelectedTotemId = nil
_G.TotemDelayMinutes = 60

-- TOTEM NAME
local function getTotemName(id)
    local map = {
        [1] = "Luck Totem",
        [2] = "Mutation Totem",
        [3] = "Shiny Totem"
    }
    return map[id] or ("Totem ID: " .. tostring(id))
end

-- GET UNIQUE TOTEMS
local function getUniqueTotems()
    local inventory = DataReplion:Get("Inventory")
    local seen, result = {}, {}

    if inventory and inventory.Totems then
        for _, totem in pairs(inventory.Totems) do
            if not seen[totem.Id] then
                seen[totem.Id] = true
                table.insert(result, {
                    Name = getTotemName(totem.Id),
                    Id = totem.Id
                })
            end
        end
    end
    return result
end

-- Initialize totems
local totemTypes = getUniqueTotems()
local totemOptions = {}

for _, t in ipairs(totemTypes) do
    table.insert(totemOptions, t.Name)
end

-- DROPDOWN
if #totemOptions > 0 then
    autoTotemSection:AddDropdown({
        Title = "Select Totem Type",
        Content = "Choose which totem to auto place",
        Options = totemOptions,
        Default = totemOptions[1],
        Callback = function(selected)
            for _, t in ipairs(totemTypes) do
                if t.Name == selected then
                    _G.SelectedTotemId = t.Id
                    break
                end
            end
        end
    })
    _G.SelectedTotemId = totemTypes[1].Id
end

-- PLACE NOW BUTTON
autoTotemSection:AddButton({
    Title = "Place Selected Totem",
    Callback = function()
        local inventory = DataReplion:Get("Inventory")
        if not inventory or not inventory.Totems then return end

        local spawnTotem = require(RS.Packages.Net):RemoteEvent("SpawnTotem")

        for _, totem in pairs(inventory.Totems) do
            if totem.Id == _G.SelectedTotemId then
                spawnTotem:FireServer(totem.UUID)
                Vict:MakeNotify({
                    Title = "Totem",
                    Description = "Placed",
                    Content = "Totem placed: " .. getTotemName(_G.SelectedTotemId),
                    Color = Color3.fromRGB(0, 255, 0),
                    Time = 0.5,
                    Delay = 3
                })
                break
            end
        end
    end
})

-- DELAY INPUT
autoTotemSection:AddPanel({
    Title = "Delay (Minutes)",
    Content = "Delay between auto placing totems",
    Placeholder = "60",
    Default = "60",
    ButtonText = "Set",
    ButtonCallback = function(value)
        local minutes = tonumber(value)
        if minutes and minutes > 0 then
            _G.TotemDelayMinutes = minutes
            Vict:MakeNotify({
                Title = "Totem",
                Description = "Delay set",
                Content = "Auto place delay: " .. minutes .. " minutes",
                Color = Color3.fromRGB(0, 255, 0),
                Time = 0.5,
                Delay = 3
            })
        end
    end
})

-- AUTO TOGGLE
autoTotemSection:AddToggle({
    Title = "Auto Place Totem",
    Content = "Automatically place selected totem",
    Default = false,
    Callback = function(enabled)
        _G.AutoTotemEnabled = enabled
        if not enabled then return end

        task.spawn(function()
            while _G.AutoTotemEnabled do
                local inventory = DataReplion:Get("Inventory")
                if inventory and inventory.Totems then
                    local spawnTotem = require(RS.Packages.Net):RemoteEvent("SpawnTotem")
                    for _, totem in pairs(inventory.Totems) do
                        if totem.Id == _G.SelectedTotemId then
                            spawnTotem:FireServer(totem.UUID)
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
    Icon = "web"
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

-- Load ItemUtility and DataService for webhook
local ItemUtility, ReplionWebhook, DataServiceWebhook
task.spawn(function()
    ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
    ReplionWebhook = require(ReplicatedStorage.Packages.Replion)
    DataServiceWebhook = ReplionWebhook.Client:WaitReplion("Data")
end)

function buildFishDatabase()
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

function getInventoryFish()
    if not (DataServiceWebhook and ItemUtility) then return {} end
    local inventoryItems = DataServiceWebhook:GetExpect({ "Inventory", "Items" })
    local fishes = {}
    for _, v in pairs(inventoryItems) do
        local itemData = ItemUtility.GetItemDataFromItemType("Items", v.Id)
        if itemData and itemData.Data.Type == "Fish" then
            table.insert(fishes, { Id = v.Id, UUID = v.UUID, Metadata = v.Metadata })
        end
    end
    return fishes
end

function getPlayerCoins()
    if not DataServiceWebhook then return "N/A" end
    local success, coins = pcall(function() return DataServiceWebhook:Get("Coins") end)
    if success and coins then
        return string.format("%d", coins):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    end
    return "N/A"
end

function getThumbnailURL(assetString)
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

function sendTestWebhook()
    if not httpRequest or not _G.WebhookURL or not _G.WebhookURL:match("discord.com/api/webhooks") then
        Vict:MakeNotify({
            Title = "Webhook Error",
            Description = "Invalid URL",
            Content = "Webhook URL is empty or invalid",
            Color = Color3.fromRGB(255, 0, 0),
            Time = 0.5,
            Delay = 3
        })
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
        end)
        Vict:MakeNotify({
            Title = "Webhook",
            Description = "Test sent",
            Content = "Test webhook sent successfully!",
            Color = Color3.fromRGB(0, 255, 0),
            Time = 0.5,
            Delay = 3
        })
    end)
end

function sendNewFishWebhook(newlyCaughtFish)
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
    Content = "Paste your Discord Webhook URL here",
    Placeholder = "https://discord.com/api/webhooks/...",
    Default = _G.WebhookURL or "",
    ButtonText = "Save",
    ButtonCallback = function(text)
        _G.WebhookURL = text
        Vict:MakeNotify({
            Title = "Webhook",
            Description = "URL saved",
            Content = "Webhook URL saved successfully!",
            Color = Color3.fromRGB(0, 255, 0),
            Time = 0.5,
            Delay = 3
        })
    end
})

-- Rarity Filter Dropdown (multi-selection simulated with single dropdown)
webhookSection:AddDropdown({
    Title = "Rarity Filter",
    Content = "Select rarity to send webhook for",
    Options = rarityList,
    Default = "",
    Callback = function(selected)
        if selected and selected ~= "" then
            _G.WebhookRarities = {selected}
            Vict:MakeNotify({
                Title = "Webhook",
                Description = "Filter set",
                Content = "Webhook will send for: " .. selected,
                Color = Color3.fromRGB(0, 255, 0),
                Time = 0.5,
                Delay = 3
            })
        end
    end
})

-- Send Webhook Toggle
webhookSection:AddToggle({
    Title = "Send Webhook",
    Content = "Enable/disable webhook sending",
    Default = _G.DetectNewFishActive or false,
    Callback = function(state)
        _G.DetectNewFishActive = state
    end
})

-- Test Webhook Button
webhookSection:AddButton({
    Title = "Test Webhook",
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

local N = {
    "Luck Rod (350 Coins)", "Carbon Rod (900 Coins)", "Grass Rod (1.5k Coins)",
    "Demascus Rod (3k Coins)", "Ice Rod (5k Coins)", "Lucky Rod (15k Coins)",
    "Midnight Rod (50k Coins)", "Steampunk Rod (215k Coins)", "Chrome Rod (437k Coins)",
    "Astral Rod (1M Coins)", "Ares Rod (3M Coins)", "Angler Rod (8M Coins)",
    "Bamboo Rod (12M Coins)"
}

local M = {}
for _, display in ipairs(N) do
    local name = display:match("^(.-) %(")
    if name then M[display] = name end
end

local S = N[1]

rodSection:AddDropdown({
    Title = "Select Rod",
    Content = "Choose fishing rod to buy",
    Options = N,
    Default = S,
    Callback = function(v)
        S = v
    end
})

rodSection:AddButton({
    Title = "Buy Rod",
    Callback = function()
        local k = M[S]
        if k and R[k] then
            pcall(function() 
                RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseFishingRod"]:InvokeServer(R[k]) 
            end)
            Vict:MakeNotify({
                Title = "Shop",
                Description = "Rod purchased",
                Content = "Purchased: " .. k,
                Color = Color3.fromRGB(0, 255, 0),
                Time = 0.5,
                Delay = 3
            })
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

local baitNames = {}
for name, _ in pairs(B) do
    table.insert(baitNames, name .. " (Price varies)")
end

local selectedBait = baitNames[1]

baitSection:AddDropdown({
    Title = "Select Bait",
    Content = "Choose bait to buy",
    Options = baitNames,
    Default = selectedBait,
    Callback = function(v)
        selectedBait = v
    end
})

baitSection:AddButton({
    Title = "Buy Bait",
    Callback = function()
        local name = selectedBait:match("^(.-) %(")
        if name and B[name] then
            pcall(function() 
                RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseBait"]:InvokeServer(B[name]) 
            end)
            Vict:MakeNotify({
                Title = "Shop",
                Description = "Bait purchased",
                Content = "Purchased: " .. name,
                Color = Color3.fromRGB(0, 255, 0),
                Time = 0.5,
                Delay = 3
            })
        end
    end
})

-- MERCHANT SHOP SECTION
local merchantSection = Tab6:AddSection("Remote Merchant", false)

local TravelingMerchantController = require(
    ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("TravelingMerchantController")
)

merchantSection:AddButton({
    Title = "OPEN MERCHANT",
    Callback = function()
        local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        local merchantUI = playerGui:WaitForChild("Merchant")
        
        if merchantUI then
            merchantUI.Enabled = true
            Vict:MakeNotify({
                Title = "Merchant",
                Description = "Opened",
                Content = "Merchant UI opened",
                Color = Color3.fromRGB(0, 255, 0),
                Time = 0.5,
                Delay = 3
            })
        end
    end
})

merchantSection:AddButton({
    Title = "CLOSE MERCHANT",
    Callback = function()
        local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        local merchantUI = playerGui:FindFirstChild("Merchant")
        
        if merchantUI then
            merchantUI.Enabled = false
            Vict:MakeNotify({
                Title = "Merchant",
                Description = "Closed",
                Content = "Merchant UI closed",
                Color = Color3.fromRGB(255, 0, 0),
                Time = 0.5,
                Delay = 3
            })
        end
    end
})

-- BUY WEATHER EVENT SECTION
local weatherSection = Tab6:AddSection("Buy Weather Event", false)

local autoBuyEnabled = false
local buyDelay = 100 -- 100 detik

-- Weather yang dibeli terus
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
            Vict:MakeNotify({
                Title = "Auto Buy Weather",
                Description = "Enabled",
                Content = "Auto buy Wind, Cloudy, Storm (100s loop)",
                Color = Color3.fromRGB(0, 255, 0),
                Time = 0.5,
                Delay = 2
            })

            Performance.Tasks["AutoBuyWeather"] = task.spawn(function()
                while autoBuyEnabled do
                    for _, weatherName in ipairs(autoBuyWeathers) do
                        pcall(function()
                            RS.Packages._Index["sleitnick_net@0.2.0"]
                                .net["RF/PurchaseWeatherEvent"]
                                :InvokeServer(weatherName)
                        end)
                        task.wait(0.3) -- jeda aman antar request
                    end

                    task.wait(buyDelay) -- delay 100 detik
                end
            end)
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

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Function untuk mendapatkan HRP
local function getHRP()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        return Player.Character.HumanoidRootPart
    end
    return nil
end

-- Pakai CFrame untuk teleport
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
            local hrp = getHRP()
            if hrp then
                hrp.CFrame = IslandLocations[SelectedIsland]
                Vict:MakeNotify({
                    Title = "Teleport",
                    Description = "Success",
                    Content = "Teleported to: " .. SelectedIsland,
                    Color = Color3.fromRGB(0, 255, 0),
                    Time = 0.5,
                    Delay = 3
                })
            end
        end
    end
})

-- PLAYER TELEPORT SECTION
local tpplayerSection = Tab7:AddSection("Player Teleport", false)

local selectedPlayerName = nil

-- Function untuk mendapatkan daftar pemain
local function getPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            table.insert(list, plr.Name)
        end
    end
    table.sort(list)
    return list
end

-- Refresh function untuk player list
local function refreshPlayerList()
    local players = getPlayerList()
    
    -- Create new dropdown
    tpplayerSection:AddDropdown({
        Title = "Teleport Target",
        Content = "Select player to teleport to",
        Options = players,
        Default = #players > 0 and players[1] or "",
        Callback = function(value)
            selectedPlayerName = value
        end
    })
end

-- Teleport to Player Button
tpplayerSection:AddButton({
    Title = "Teleport to Player",
    Callback = function()
        if not selectedPlayerName then
            Vict:MakeNotify({
                Title = "Teleport Error",
                Description = "No player",
                Content = "No player selected",
                Color = Color3.fromRGB(255, 0, 0),
                Time = 0.5,
                Delay = 3
            })
            return
        end

        local target = Players:FindFirstChild(selectedPlayerName)
        if not target or not target.Character then
            Vict:MakeNotify({
                Title = "Teleport Error",
                Description = "Target not found",
                Content = "Target player not available",
                Color = Color3.fromRGB(255, 0, 0),
                Time = 0.5,
                Delay = 3
            })
            return
        end

        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local myHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

        if not targetHRP or not myHRP then
            return
        end

        -- Teleport EXACT position (above target)
        myHRP.CFrame = CFrame.new(
            targetHRP.Position + Vector3.new(0, 3, 0)
        )
        
        Vict:MakeNotify({
            Title = "Teleport",
            Description = "Success",
            Content = "Teleported to: " .. selectedPlayerName,
            Color = Color3.fromRGB(0, 255, 0),
            Time = 0.5,
            Delay = 3
        })
    end
})

-- Refresh Player List Button
tpplayerSection:AddButton({
    Title = "Refresh Player List",
    Callback = function()
        refreshPlayerList()
        Vict:MakeNotify({
            Title = "Teleport",
            Description = "Refreshed",
            Content = "Player list refreshed",
            Color = Color3.fromRGB(0, 255, 0),
            Time = 0.5,
            Delay = 3
        })
    end
})

-- Initialize player list
refreshPlayerList()

-- EVENT TELEPORTER SECTION
local eventsSection = Tab7:AddSection("Event Teleporter", false)

-- SERVICES
local S = setmetatable({}, {
    __index = function(_, k)
        return game:GetService(k)
    end
})

-- STATE
local ST = {
    player = S.Players.LocalPlayer,
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

-- INIT CHARACTER
local function bindChar(c)
    ST.char = c
    task.wait(1)
    ST.hrp = c:WaitForChild("HumanoidRootPart")
end

bindChar(ST.player.Character or ST.player.CharacterAdded:Wait())
ST.player.CharacterAdded:Connect(bindChar)

-- EVENT DATA
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

-- EVENT NAMES
local eventNames = {}
for n in pairs(eventData) do
    eventNames[#eventNames+1] = n
end

-- FORCE TP
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

-- MAIN TP LOOP
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
                local rings = S.Workspace:FindFirstChild("!!! MENU RINGS")
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
                    for _, d in ipairs(S.Workspace:GetDescendants()) do
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

-- FLOAT
S.RunService.RenderStepped:Connect(function()
    if ST.autoFloat and ST.hrp then
        local pos = ST.hrp.Position
        local targetY = S.Workspace.Terrain.WaterLevel + ST.floatOffset
        if pos.Y < targetY then
            ST.hrp.CFrame = CFrame.new(pos.X, targetY, pos.Z)
            ST.hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)

-- Event Selection Dropdown
eventsSection:AddDropdown({
    Title = "Select Events",
    Content = "Choose events to auto teleport to",
    Options = eventNames,
    Default = "",
    Callback = function(v)
        ST.selectedEvents = {v}
    end
})

-- Auto Event Toggle
eventsSection:AddToggle({
    Title = "Auto Event Teleport",
    Content = "Automatically teleport to selected events",
    Default = false,
    Callback = function(state)
        ST.autoTP = state
        ST.autoFloat = state
        ST.lastTP = nil
        if state then
            task.defer(runEventTP)
            Vict:MakeNotify({
                Title = "Event Teleport",
                Description = "Enabled",
                Content = "Auto event teleport enabled",
                Color = Color3.fromRGB(0, 255, 0),
                Time = 0.5,
                Delay = 3
            })
        else
            Vict:MakeNotify({
                Title = "Event Teleport",
                Description = "Disabled",
                Content = "Auto event teleport disabled",
                Color = Color3.fromRGB(255, 0, 0),
                Time = 0.5,
                Delay = 3
            })
        end
    end
})

-- ==================== TAB 8: SETTINGS ====================
local Tab8 = Window:AddTab({
    Name = "Settings",
    Icon = "settings"
})

-- MISCELLANEOUS SECTION
local playerSettings = Tab8:AddSection("Miscellaneous", false)

-- PING DISPLAY
local PingEnabled = true
local Frame, HeaderText, StatsText, CloseButton
local lastPingUpdate = 0
local pingUpdateInterval = 0.5

local function makeDraggable(frame)
    local UserInputService = game:GetService("UserInputService")
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function createPingDisplay()
    local CG = game:GetService("CoreGui")
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "PerformanceHUD"
    Gui.Parent = CG
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    Frame = Instance.new("Frame", Gui)
    Frame.Size = UDim2.fromOffset(220, 60)
    Frame.Position = UDim2.fromScale(0.5, 0.05)
    Frame.AnchorPoint = Vector2.new(0.5, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BackgroundTransparency = 0.7
    Frame.BorderSizePixel = 0
    Frame.Visible = PingEnabled
    Frame.ZIndex = 1000
    Frame.Active = true

    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Thickness = 2
    Stroke.Color = Color3.fromRGB(100, 100, 100)
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.ZIndex = 1001

    -- Close Button
    CloseButton = Instance.new("TextButton", Frame)
    CloseButton.Size = UDim2.fromOffset(20, 20)
    CloseButton.Position = UDim2.new(1, -25, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BackgroundTransparency = 0.3
    CloseButton.BorderSizePixel = 0
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 12
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.ZIndex = 1003
    
    local CloseCorner = Instance.new("UICorner", CloseButton)
    CloseCorner.CornerRadius = UDim.new(0, 3)

    CloseButton.MouseButton1Click:Connect(function()
        PingEnabled = false
        Frame.Visible = false
    end)

    CloseButton.MouseEnter:Connect(function()
        CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    end)

    CloseButton.MouseLeave:Connect(function()
        CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end)

    -- Header Text (CENTER)
    HeaderText = Instance.new("TextLabel", Frame)
    HeaderText.Size = UDim2.new(1, 0, 0, 20)
    HeaderText.Position = UDim2.fromOffset(0, 5)
    HeaderText.BackgroundTransparency = 1
    HeaderText.Font = Enum.Font.GothamBold
    HeaderText.TextSize = 11
    HeaderText.TextXAlignment = Enum.TextXAlignment.Center
    HeaderText.TextYAlignment = Enum.TextYAlignment.Center
    HeaderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeaderText.Text = "VICTORIA PANEL"
    HeaderText.ZIndex = 1002

    -- Divider Line
    local Divider = Instance.new("Frame", Frame)
    Divider.Size = UDim2.new(1, -20, 0, 1)
    Divider.Position = UDim2.fromOffset(10, 28)
    Divider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Divider.BorderSizePixel = 0
    Divider.ZIndex = 1002

    -- Stats Text
    StatsText = Instance.new("TextLabel", Frame)
    StatsText.Size = UDim2.new(1, -20, 0, 25)
    StatsText.Position = UDim2.fromOffset(10, 32)
    StatsText.BackgroundTransparency = 1
    StatsText.Font = Enum.Font.GothamBold
    StatsText.TextSize = 10
    StatsText.TextXAlignment = Enum.TextXAlignment.Center
    StatsText.TextYAlignment = Enum.TextYAlignment.Center
    StatsText.TextColor3 = Color3.fromRGB(230, 230, 230)
    StatsText.ZIndex = 1002
    
    -- Make draggable
    makeDraggable(Frame)
    
    return Frame
end

if createPingDisplay() then
    SafeConnect("PingUpdate", game:GetService("RunService").RenderStepped:Connect(function()
        if not PingEnabled then return end
        
        local now = tick()
        if now - lastPingUpdate < pingUpdateInterval then return end
        lastPingUpdate = now
        
        local Stats = game:GetService("Stats")
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        local cpu = string.format("%.2f", Stats.PerformanceStats.CPU:GetValue())
        
        StatsText.Text = string.format("PING: %d ms | CPU: %s%%", ping, cpu)
    end))
end

playerSettings:AddToggle({
    Title = "Ping Display",
    Content = "Show ping and CPU usage overlay",
    Default = false,
    Callback = function(v)
        PingEnabled = v
        if Frame then Frame.Visible = v end
    end
})

-- HIDE NAME & LEVEL
local P = Player
local C = P.Character or P.CharacterAdded:Wait()
local O = C:WaitForChild("HumanoidRootPart"):WaitForChild("Overhead")
local H = O.Content.Header
local L = O.LevelContainer.Label

local D = {h = H.Text, l = L.Text, ch = H.Text, cl = L.Text, on = false}

playerSettings:AddPanel({
    Title = "Hide Name",
    Content = "Custom name to display",
    Placeholder = "Input Name",
    Default = D.h,
    ButtonText = "Set",
    ButtonCallback = function(v)
        D.ch = v
        if D.on then H.Text = v end
    end
})

playerSettings:AddPanel({
    Title = "Hide Level",
    Content = "Custom level to display",
    Placeholder = "Input Level",
    Default = D.l,
    ButtonText = "Set",
    ButtonCallback = function(v)
        D.cl = v
        if D.on then L.Text = v end
    end
})

playerSettings:AddToggle({
    Title = "Hide Name & Level (Custom)",
    Content = "Use custom name and level display",
    Default = false,
    Callback = function(v)
        D.on = v
        if v then
            H.Text = D.ch
            L.Text = D.cl
        else
            H.Text = D.h
            L.Text = D.l
        end
    end
})

-- DEFAULT HIDE
local HN, HL = "discord.gg/victoriahub", "Lv. ???"
local S = {on = false, ui = nil}

local function setup(c)
    local o = c:WaitForChild("HumanoidRootPart"):WaitForChild("Overhead")
    local h = o.Content.Header
    local l = o.LevelContainer.Label
    return {h = h, l = l, dh = h.Text, dl = l.Text}
end

S.ui = setup(P.Character or P.CharacterAdded:Wait())

SafeConnect("CharAddedHide", P.CharacterAdded:Connect(function(c)
    task.wait(0.2)
    S.ui = setup(c)
    if S.on then
        S.ui.h.Text = HN
        S.ui.l.Text = HL
    end
end))

playerSettings:AddToggle({
    Title = "Hide Name & Level (Default)",
    Content = "Use default hidden name and level",
    Default = false,
    Callback = function(v)
        S.on = v
        if not S.ui then return end
        if v then
            S.ui.h.Text = HN
            S.ui.l.Text = HL
        else
            S.ui.h.Text = S.ui.dh
            S.ui.l.Text = S.ui.dl
        end
    end
})

-- INFINITE ZOOM
local Z = {P.CameraMaxZoomDistance, P.CameraMinZoomDistance}

playerSettings:AddToggle({
    Title = "Infinite Zoom",
    Content = "Infinite zoom to take photos",
    Default = false,
    Callback = function(s)
        if s then
            P.CameraMaxZoomDistance = math.huge
            P.CameraMinZoomDistance = .5
        else
            P.CameraMaxZoomDistance = Z[1] or 128
            P.CameraMinZoomDistance = Z[2] or .5
        end
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

playerSettings:AddToggle({
    Title = "Auto Reconnect",
    Content = "Auto click Reconnect button",
    Default = false,
    Callback = function(v) 
        AutoReconnect = v 
    end
})

-- ANTI STAFF
local ON = true
local BL = {
    [75974130]=1,[40397833]=1,[187190686]=1,[33372493]=1,[889918695]=1,
    [33679472]=1,[30944240]=1,[25050357]=1,[8462585751]=1,[8811129148]=1,
    [192821024]=1,[4509801805]=1,[124505170]=1,[108397209]=1
}

playerSettings:AddToggle({
    Title = "Anti Staff",
    Content = "Auto serverhop if staff detected",
    Default = true,
    Callback = function(s) 
        ON = s 
    end
})

local function hop()
    task.wait(6)
    local d = game.HttpService:JSONDecode(
        game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
    ).data
    for _,v in ipairs(d) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id, Player)
            break
        end
    end
end

SafeConnect("PlayerAddedAntiStaff", game:GetService("Players").PlayerAdded:Connect(function(plr)
    if ON and plr~=Player and BL[plr.UserId] then
        Vict:MakeNotify({
            Title = "Anti Staff",
            Description = "Staff detected!",
            Content = plr.Name.." joined, serverhopping in 6 seconds...",
            Color = Color3.fromRGB(255, 165, 0),
            Time = 0.5,
            Delay = 6
        })
        hop()
    end
end))

Performance.Tasks["AntiStaffCheck"] = task.spawn(function()
    while task.wait(2) do
        if ON then
            for _,plr in ipairs(game:GetService("Players"):GetPlayers()) do
                if plr~=Player and BL[plr.UserId] then
                    Vict:MakeNotify({
                        Title = "Anti Staff",
                        Description = "Staff detected!",
                        Content = plr.Name.." detected, serverhopping in 6 seconds...",
                        Color = Color3.fromRGB(255, 165, 0),
                        Time = 0.5,
                        Delay = 6
                    })
                    hop()
                    break
                end
            end
        end
    end
end)

-- GRAPHICS SECTION
local graphicSection = Tab8:AddSection("Graphics Feature", false)

-- FPS BOOST
local FPSBoost = false
local CurrentConnections = {}
local OriginalValues = {}

-- Function to save original value
local function saveOriginal(obj, property)
    if not OriginalValues[obj] then
        OriginalValues[obj] = {}
    end
    if OriginalValues[obj][property] == nil then
        OriginalValues[obj][property] = obj[property]
    end
end

-- Apply FPS Boost
local function applyBoost()
    -- Lighting settings
    local Lighting = game:GetService("Lighting")
    
    -- Save and apply lighting settings
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
    
    -- Disable all post effects
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
        
        -- Try to disable terrain decoration
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(Terrain, "Decoration", false)
            else
                Terrain.Decoration = false
            end
        end)
    end
    
    -- Rendering settings
    saveOriginal(settings().Rendering, "QualityLevel")
    saveOriginal(settings().Rendering, "MeshPartDetailLevel")
    
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    
    -- Monitor and optimize new objects
    local function optimizeObject(obj)
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
                
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or 
                   obj:IsA("Smoke") or obj:IsA("Fire") then
                saveOriginal(obj, "Enabled")
                obj.Enabled = false
                
            elseif obj:IsA("Beam") or obj:IsA("SpotLight") or 
                   obj:IsA("PointLight") or obj:IsA("SurfaceLight") then
                saveOriginal(obj, "Enabled")
                obj.Enabled = false
                
            elseif obj:IsA("Sound") then
                saveOriginal(obj, "Volume")
                if obj.Volume > 0.5 then
                    obj.Volume = 0.1
                end
            end
        end)
    end
    
    -- Optimize all existing objects
    for _, obj in pairs(game:GetDescendants()) do
        optimizeObject(obj)
    end
    
    -- Monitor for new objects
    local connection = game.DescendantAdded:Connect(function(obj)
        if FPSBoost then
            optimizeObject(obj)
        end
    end)
    
    table.insert(CurrentConnections, connection)
    
    -- FPS Cap
    pcall(function()
        if setfpscap then
            setfpscap(999)
        end
    end)
end

-- Restore original settings
local function restoreBoost()
    -- Disconnect all monitoring connections
    for _, connection in ipairs(CurrentConnections) do
        pcall(function() connection:Disconnect() end)
    end
    CurrentConnections = {}
    
    -- Restore all saved values
    for obj, properties in pairs(OriginalValues) do
        if obj and (obj.Parent or obj == game:GetService("Lighting") or obj == settings().Rendering) then
            for property, value in pairs(properties) do
                pcall(function()
                    obj[property] = value
                end)
            end
        end
    end
    
    -- Clear the saved values
    OriginalValues = {}
    
    -- Restore Terrain Decoration if needed
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    if Terrain then
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(Terrain, "Decoration", true)
            else
                Terrain.Decoration = true
            end
        end)
    end
end

-- UI Toggle
graphicSection:AddToggle({
    Title = "FPS Boost",
    Content = "Optimize graphics for better FPS",
    Default = false,
    Callback = function(v)
        FPSBoost = v
        
        if v then
            applyBoost()
        else
            restoreBoost()
        end
    end
})

-- REMOVE FISH NOTIFICATION
local PopupConn, RemoteConn

graphicSection:AddToggle({
    Title = "Remove Fish Notification Pop-up",
    Content = "Remove fish caught notification popups",
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
        else
            if PopupConn then PopupConn:Disconnect(); PopupConn = nil end
            if RemoteConn then RemoteConn:Disconnect(); RemoteConn = nil end
        end
    end
})

-- DISABLE 3D RENDERING
local G
graphicSection:AddToggle({
    Title = "Disable 3D Rendering",
    Content = "Disable 3D rendering (black screen)",
    Default = false,
    Callback = function(s)
        pcall(function() 
            game:GetService("RunService"):Set3dRenderingEnabled(not s) 
        end)
        if s then
            G = Instance.new("ScreenGui")
            G.IgnoreGuiInset = true
            G.ResetOnSpawn = false
            G.Parent = Player.PlayerGui

            local frame = Instance.new("Frame", G)
            frame.Size = UDim2.fromScale(1,1)
            frame.BackgroundColor3 = Color3.new(1,1,1)
            frame.BorderSizePixel = 0
        elseif G then
            G:Destroy()
            G = nil
        end
    end
})

-- HIDE ALL VFX
local VFXState = {on = false, cache = {}}

local VFXTypes = {
    ParticleEmitter = true, Beam = true, Trail = true, Smoke = true,
    Fire = true, Sparkles = true, Explosion = true,
    PointLight = true, SpotLight = true, SurfaceLight = true, Highlight = true
}

local LETypes = {
    BloomEffect = true, SunRaysEffect = true, ColorCorrectionEffect = true,
    DepthOfFieldEffect = true, Atmosphere = true
}

local function disableVFX()
    for _, o in ipairs(workspace:GetDescendants()) do
        if VFXTypes[o.ClassName] and o.Enabled == true then
            VFXState.cache[o] = true
            o.Enabled = false
        end
    end

    for _, o in ipairs(game:GetService("Lighting"):GetChildren()) do
        if LETypes[o.ClassName] and o.Enabled ~= nil then
            VFXState.cache[o] = true
            o.Enabled = false
        end
    end
end

local function restoreVFX()
    for o in pairs(VFXState.cache) do
        if o and o.Parent and o.Enabled ~= nil then 
            o.Enabled = true 
        end
    end
    VFXState.cache = {}
end

SafeConnect("VFXDescendant", workspace.DescendantAdded:Connect(function(o)
    if VFXState.on and VFXTypes[o.ClassName] and o.Enabled ~= nil then
        task.defer(function() o.Enabled = false end)
    end
end))

SafeConnect("LightingDescendant", game:GetService("Lighting").DescendantAdded:Connect(function(o)
    if VFXState.on and LETypes[o.ClassName] and o.Enabled ~= nil then
        task.defer(function() o.Enabled = false end)
    end
end))

graphicSection:AddToggle({
    Title = "Hide All VFX",
    Content = "Hide all visual effects",
    Default = false,
    Callback = function(state)
        VFXState.on = state
        if state then 
            disableVFX() 
        else 
            restoreVFX() 
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

graphicSection:AddToggle({
    Title = "Remove Skin Effect",
    Content = "Remove your skin visual effects",
    Default = false,
    Callback = function(state)
        if state then
            VFXController.Handle = function() end
            VFXController.RenderAtPoint = function() end
            VFXController.RenderInstance = function() end

            local f = workspace:FindFirstChild("CosmeticFolder")
            if f then pcall(f.ClearAllChildren, f) end
        else
            VFXController.Handle = ORI.H
            VFXController.RenderAtPoint = ORI.P
            VFXController.RenderInstance = ORI.I
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
            LocalPlayer:SetAttribute("IgnoreFOV", false)
        end)
        return
    end
    return _G.OriginalPlayCutscene(self, ...)
end

graphicSection:AddToggle({
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
        end
    end
})

-- SERVER SECTION
local serverSection = Tab8:AddSection("Server", false)

serverSection:AddButton({
    Title = "Rejoin",
    Content = "Rejoin to the same server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        
        TeleportService:Teleport(game.PlaceId, player)
    end
})

serverSection:AddButton({
    Title = "Server Hop",
    Content = "Switch to another server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        
        local player = Players.LocalPlayer
        local PlaceId = game.PlaceId
        
        TeleportService:Teleport(PlaceId, player)
    end
})

-- OTHER SCRIPTS SECTION
local scriptSection = Tab8:AddSection("Other Scripts", false)

scriptSection:AddButton({
    Title = "Infinite Yield",
    Content = "Load Infinite Yield script",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/main/latest.lua'))()
        Vict:MakeNotify({
            Title = "Scripts",
            Description = "Loaded",
            Content = "Infinite Yield loaded successfully!",
            Color = Color3.fromRGB(0, 255, 0),
            Time = 0.5,
            Delay = 3
        })
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
    
    if Frame then Frame:Destroy() end
    if G then G:Destroy() end
end

-- Bind cleanup to game close
-- game:BindToClose(cleanup)

-- ==================== FINAL INIT ====================
getgenv().VictoriaHubWindow = Window

-- Send final notification
Vict:MakeNotify({
    Title = "Victoria Hub",
    Description = "Loaded Successfully!",
    Content = "All features migrated to VictUI! Executor: " .. executorName,
    Color = executorColor,
    Time = 0.5,
    Delay = 5
})

return Window
