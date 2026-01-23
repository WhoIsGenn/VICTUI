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
task.spawn(function()
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
        
        pcall(function()
            httpRequest({
                Url = WebhookConfig.Url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end

    sendWebhookNotification()
end)

-- ==================== PLAYER SETUP ====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
Player = LocalPlayer

-- CACHE OBJECTS
task.spawn(function()
    _G.Characters = workspace:FindFirstChild("Characters"):WaitForChild(LocalPlayer.Name)
    _G.HRP = _G.Characters:WaitForChild("HumanoidRootPart")
    _G.Overhead = _G.HRP:WaitForChild("Overhead")
    _G.Header = _G.Overhead:WaitForChild("Content"):WaitForChild("Header")
    _G.LevelLabel = _G.Overhead:WaitForChild("LevelContainer"):WaitForChild("Label")
    _G.Title = _G.Overhead:WaitForChild("TitleContainer"):WaitForChild("Label")
    _G.TitleEnabled = _G.Overhead:WaitForChild("TitleContainer")
end)

-- AUTO ANTI-AFK (ACTIVE ON EXECUTE)
local VirtualUser = game:GetService("VirtualUser")
_G.AntiAFK = true

Players.LocalPlayer.Idled:Connect(function()
    if _G.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

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

-- ==================== TAB 1: INFO ====================
local Tab1 = Window:AddTab({
    Name = "Info",
    Icon = "alert"
})

local infoSection = Tab1:AddSection("Information", true)

infoSection:AddParagraph({
    Title = "Victoria Hub Community",
    Content = "Join Our Community Discord Server to get the latest updates, support, and connect with other users!",
    Icon = "discord",
    ButtonText = "Copy Link",
    ButtonCallback = function()
        setclipboard("https://discord.gg/victoriahub")
        notif("Discord link copied!", 3, Color3.fromRGB(0, 255, 0), "Victoria Hub", "Info")
    end
})

-- ==================== TAB 2: PLAYERS ====================
local Tab2 = Window:AddTab({
    Name = "Players",
    Icon = "player"
})

local playerSection = Tab2:AddSection("Player Features", true)

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
local P, SG = game.Players.LocalPlayer, game.StarterGui
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

-- ==================== TAB 3: MAIN (FISHING) ====================
local Tab3 = Window:AddTab({
    Name = "Main",
    Icon = "fish"
})

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

-- FISHING SECTION
local fishingSection = Tab3:AddSection("Fishing Features", true)

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
local FC = require(RS.Controllers.FishingController)

local oc, orc = FC.RequestFishingMinigameClick, FC.RequestChargeFishingRod
local ap = false

task.spawn(function()
    while task.wait() do
        if ap then
            net["RF/UpdateAutoFishingState"]:InvokeServer(true)
        end
    end
end)

local function updateAutoPerfection(s)
    ap = s
    if s then
        FC.RequestFishingMinigameClick = function() end
        FC.RequestChargeFishingRod = function() end
    else
        net["RF/UpdateAutoFishingState"]:InvokeServer(false)
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
        notif("Animation applied: " .. _G.SelectedAnim, 3, Color3.fromRGB(0, 255, 0), "Animation", "Info")
    end
})

animationSection:AddButton({
    Title = "Disable Animation",
    Callback = function()
        _G.ActiveAnim = nil
        _G.SelectedAnim = "None"
        notif("Animation disabled", 3, Color3.fromRGB(255, 0, 0), "Animation", "Info")
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
            notif("Will sell at " .. SellAt .. " fish", 3, Color3.fromRGB(0, 255, 0), "Auto Sell", "Info")
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
            notif("Will sell every " .. SellMinute .. " minutes", 3, Color3.fromRGB(0, 255, 0), "Auto Sell", "Info")
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
    
    notif(string.format("Loaded %d fish and %d variants!", #GlobalFav.FishNames, #GlobalFav.VariantNames), 3, Color3.fromRGB(0, 255, 0), "Auto Favorite", "Info")
end

-- Auto Favorite Toggle
favSection:AddToggle({
    Title = "Auto Favorite",
    Content = "Automatically favorite caught fish",
    Default = false,
    Callback = function(state)
        GlobalFav.AutoFavoriteEnabled = state
        
        if state then
            notif("Auto Favorite enabled!", 3, Color3.fromRGB(0, 255, 0), "Auto Favorite", "Info")
        else
            notif("Auto Favorite disabled!", 3, Color3.fromRGB(255, 0, 0), "Auto Favorite", "Info")
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
                notif(selected .. " selected for favoriting", 2, Color3.fromRGB(0, 255, 0), "Auto Favorite", "Info")
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
                    notif(selected .. " selected for favoriting", 2, Color3.fromRGB(0, 255, 0), "Auto Favorite", "Info")
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
        
        notif("All selections cleared!", 2, Color3.fromRGB(255, 255, 0), "Auto Favorite", "Info")
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
            
            notif("Favorited " .. msg, 2, Color3.fromRGB(0, 255, 0), "Auto Favorite", "Info")
        end
    end
end)

-- ==================== FINAL NOTIFICATION ====================
task.spawn(function()
    task.wait(2)
    
    -- Get executor name
    local executorName = "Unknown"
    if identifyexecutor then executorName = identifyexecutor() end
    
    local executorColor = Color3.fromRGB(200, 200, 200)
    if executorName:lower():find("flux") then
        executorColor = Color3.fromHex("#30ff6a")
    elseif executorName:lower():find("delta") then
        executorColor = Color3.fromHex("#38b6ff")
    elseif executorName:lower():find("synapse") or executorName:lower():find("script") then
        executorColor = Color3.fromHex("#ffd700")
    elseif executorName:lower():find("krnl") then
        executorColor = Color3.fromHex("#1e90ff")
    end
    
    notif("Victoria Hub loaded! Executor: " .. executorName, 5, executorColor, "Victoria Hub", "Success")
end)

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
end

-- game:BindToClose(cleanup)

getgenv().VictoriaHubWindow = Window

return Window
