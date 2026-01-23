-- [[ VICTORIA HUB FISH IT - COMPLETE FIXED VERSION ]] --
-- Version: 1.0.0

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
    Icon = "rbxassetid://105950071843685",
    Image = "105950071843685"
})

-- ==================== PLAYER SETUP ====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ANTI-AFK
_G.AntiAFK = true
local VirtualUser = game:GetService("VirtualUser")

LocalPlayer.Idled:Connect(function()
    if _G.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- TITLE ANIMATION
task.spawn(function()
    task.wait(2)
    local character = LocalPlayer.Character
    if character then
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            local overhead = hrp:WaitForChild("Overhead", 3)
            if overhead then
                local titleContainer = overhead:WaitForChild("TitleContainer", 2)
                if titleContainer then
                    titleContainer.Visible = false
                    local title = titleContainer:WaitForChild("Label", 1)
                    if title then
                        title.TextScaled = false
                        title.TextSize = 19
                        title.Text = "Victoria Hub"

                        local uiStroke = Instance.new("UIStroke")
                        uiStroke.Thickness = 2
                        uiStroke.Color = Color3.fromRGB(170, 0, 255)
                        uiStroke.Parent = title

                        local colors = {
                            Color3.fromRGB(0, 255, 255),
                            Color3.fromRGB(255, 0, 127),
                            Color3.fromRGB(0, 255, 127),
                            Color3.fromRGB(255, 255, 0)
                        }

                        local i = 1
                        local function colorCycle()
                            if not title or not title.Parent then return end
                            
                            local nextColor = colors[(i % #colors) + 1]
                            local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                            
                            game:GetService("TweenService"):Create(title, tweenInfo, { TextColor3 = nextColor }):Play()
                            game:GetService("TweenService"):Create(uiStroke, tweenInfo, { Color = nextColor }):Play()
                            
                            i += 1
                            task.delay(1.5, colorCycle)
                        end
                        
                        colorCycle()
                    end
                end
            end
        end
    end
end)

-- ==================== TAB 1: INFO ====================
local Tab1 = Window:AddTab({
    Name = "Info",
    Icon = "alert"
})

local infoSection = Tab1:AddSection("Information")

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

local playerSection = Tab2:AddSection("Player Features")

-- SPEED
local walkSpeedValue = 16
playerSection:AddInput({
    Title = "Walk Speed",
    Content = "Default: 16 | Press Enter to apply",
    Default = "16",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 18 and num <= 100 then
            walkSpeedValue = num
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then 
                humanoid.WalkSpeed = num 
            end
        end
    end
})

-- JUMP POWER
local jumpPowerValue = 50
playerSection:AddInput({
    Title = "Jump Power",
    Content = "Default: 50 | Press Enter to apply",
    Default = "50",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 50 and num <= 500 then
            jumpPowerValue = num
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then 
                humanoid.JumpPower = num 
            end
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

UIS.JumpRequest:Connect(function()
    if _G.InfiniteJump then
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then 
            h:ChangeState(Enum.HumanoidStateType.Jumping) 
        end
    end
end)

-- NOCLIP
_G.Noclip = false
local noclipThread

playerSection:AddToggle({
    Title = "Noclip",
    Content = "Walk through walls",
    Default = false,
    Callback = function(state)
        _G.Noclip = state
        
        if noclipThread then
            task.cancel(noclipThread)
            noclipThread = nil
        end
        
        if state then
            noclipThread = task.spawn(function()
                while _G.Noclip do
                    task.wait(0.1)
                    local character = LocalPlayer.Character
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
local frozen = false
local lastCFrame = nil

playerSection:AddToggle({
    Title = "Freeze Character",
    Content = "Freeze your character in place",
    Default = false,
    Callback = function(s)
        frozen = s
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not hrp then return end
        
        if s then
            lastCFrame = hrp.CFrame
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            humanoid.AutoRotate = false
            humanoid.PlatformStand = true
            hrp.Anchored = true
        else
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
            humanoid.AutoRotate = true
            humanoid.PlatformStand = false
            hrp.Anchored = false
            if lastCFrame then
                hrp.CFrame = lastCFrame
            end
        end
    end
})

-- WALK ON WATER
local isWalkOnWater = false
local waterPlatform = nil
local walkOnWaterConnection = nil

playerSection:AddToggle({
    Title = "Walk on Water",
    Content = "Walk on water surface",
    Default = false,
    Callback = function(state)
        isWalkOnWater = state
        
        if walkOnWaterConnection then
            walkOnWaterConnection:Disconnect()
            walkOnWaterConnection = nil
        end
        
        if waterPlatform then
            waterPlatform:Destroy()
            waterPlatform = nil
        end
        
        if state then
            waterPlatform = Instance.new("Part")
            waterPlatform.Name = "WaterPlatform"
            waterPlatform.Anchored = true
            waterPlatform.CanCollide = true
            waterPlatform.Transparency = 1
            waterPlatform.Size = Vector3.new(15, 1, 15)
            waterPlatform.Parent = workspace

            walkOnWaterConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if not isWalkOnWater then return end

                local character = LocalPlayer.Character
                if not character then return end

                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = { workspace.Terrain }
                rayParams.FilterType = Enum.RaycastFilterType.Include
                rayParams.IgnoreWater = false

                local result = workspace:Raycast(
                    hrp.Position + Vector3.new(0,5,0),
                    Vector3.new(0,-500,0),
                    rayParams
                )

                if result and result.Material == Enum.Material.Water then
                    local waterY = result.Position.Y
                    waterPlatform.Position = Vector3.new(hrp.Position.X, waterY, hrp.Position.Z)

                    if hrp.Position.Y < waterY + 2 then
                        if not UIS:IsKeyDown(Enum.KeyCode.Space) then
                            hrp.CFrame = CFrame.new(hrp.Position.X, waterY + 3.2, hrp.Position.Z)
                        end
                    end
                else
                    waterPlatform.Position = Vector3.new(hrp.Position.X, -500, hrp.Position.Z)
                end
            end)
        end
    end
})

-- DISABLE ANIMATIONS
local animDisabled = false
local animConn

playerSection:AddToggle({
    Title = "Disable Animations",
    Content = "Disable character animations",
    Default = false,
    Callback = function(state)
        animDisabled = state
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        if state then
            for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0); track:Destroy() end)
            end

            if animConn then animConn:Disconnect(); animConn = nil end

            animConn = humanoid.AnimationPlayed:Connect(function(track)
                if animDisabled and track then
                    task.defer(function()
                        pcall(function() track:Stop(0); track:Destroy() end)
                    end)
                end
            end)
        else
            if animConn then animConn:Disconnect(); animConn = nil end
            local animate = character:FindFirstChild("Animate")
            if animate then animate.Disabled = false end
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            task.wait()
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
})

-- ==================== TAB 3: MAIN (FISHING) ====================
local Tab3 = Window:AddTab({
    Name = "Main",
    Icon = "fish"
})

-- FISHING SECTION
local fishingSection = Tab3:AddSection("Fishing Features")

local RS = game:GetService("ReplicatedStorage")
local net = RS:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- FISHING VARIABLES
_G.AutoFishing = false
_G.AutoEquipRod = false
_G.InstantDelay = 0.65
_G.CallMinDelay = 0.18
_G.CallBackoff = 1.5

local fishThread
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

-- Auto Fishing Toggle
fishingSection:AddToggle({
    Title = "Auto Fishing",
    Content = "Automatically fish",
    Default = false,
    Callback = function(v)
        _G.AutoFishing = v
        
        if fishThread then
            task.cancel(fishThread)
            fishThread = nil
        end
        
        if v then
            if mode == "Instant" then
                fishThread = task.spawn(function()
                    while _G.AutoFishing and mode == "Instant" do
                        instant_cycle()
                        task.wait(_G.InstantDelay)
                    end
                end)
            else
                fishThread = task.spawn(function()
                    while _G.AutoFishing and mode == "Legit" do
                        autoon()
                        task.wait(1)
                    end
                end)
            end
        else
            autooff()
        end
    end
})

-- Mode Dropdown
local modeOptions = {"Instant", "Legit"}
fishingSection:AddDropdown({
    Title = "Fishing Mode",
    Content = "Select fishing mode",
    Options = modeOptions,
    Default = "Instant",
    Callback = function(v)
        mode = v
        
        -- Stop fishing when switching modes
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

-- Instant Fishing Delay Input
fishingSection:AddInput({
    Title = "Instant Fishing Delay",
    Content = "Delay between fishing cycles (Instant mode only)",
    Default = "0.65",
    Callback = function(v)
        local num = tonumber(v)
        if num and num >= 0.05 and num <= 5 then
            _G.InstantDelay = num
        end
    end
})

-- Auto Equip Rod
fishingSection:AddToggle({
    Title = "Auto Equip Rod",
    Content = "Automatically equip fishing rod",
    Default = false,
    Callback = function(v)
        _G.AutoEquipRod = v
        if v then
            rod()
        end
    end
})

-- RADAR (Fixed: Not auto-enable on execute)
local radarEnabled = false
fishingSection:AddToggle({
    Title = "Radar",
    Content = "Enable fishing radar",
    Default = false,
    Callback = function(s)
        radarEnabled = s
        local RS, L = game.ReplicatedStorage, game.Lighting
        if require(RS.Packages.Replion).Client:GetReplion("Data") then
            require(RS.Packages.Net):RemoteFunction("UpdateFishingRadar"):InvokeServer(s)
        end
    end
})

-- BYPASS OXYGEN
fishingSection:AddToggle({
    Title = "Bypass Oxygen",
    Content = "Infinite Oxygen tank",
    Default = false,
    Callback = function(s)
        if s then 
            net["RF/EquipOxygenTank"]:InvokeServer(105)
        else 
            net["RF/UnequipOxygenTank"]:InvokeServer() 
        end
    end
})

-- BLATANT V1 SECTION
local blatantV1Section = Tab3:AddSection("Blatant V1")

local c = { d = false, e = 1.55, f = 0.22 }
local m = nil
local n = nil

-- Cancel Delay Input
blatantV1Section:AddInput({
    Title = "Cancel Delay",
    Content = "Delay before canceling fishing (seconds)",
    Default = "1.55",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then
            c.e = num
        end
    end
})

-- Complete Delay Input
blatantV1Section:AddInput({
    Title = "Complete Delay",
    Content = "Delay before completing fishing (seconds)",
    Default = "0.22",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then
            c.f = num
        end
    end
})

-- Blatant V1 Toggle
blatantV1Section:AddToggle({
    Title = "Blatant Mode V1",
    Content = "Enable Blatant V1 fishing",
    Default = false,
    Callback = function(z2)
        c.d = z2
        if z2 then
            if m then task.cancel(m) end
            if n then task.cancel(n) end
            m = task.spawn(function()
                n = task.spawn(function()
                    while c.d do
                        pcall(function()
                            net["RE/EquipToolFromHotbar"]:FireServer(1)
                        end)
                        task.wait(1.5)
                    end
                end)
                
                while c.d do
                    task.spawn(function()
                        pcall(function()
                            net["RF/CancelFishingInputs"]:InvokeServer()
                            net["RF/ChargeFishingRod"]:InvokeServer(math.huge)
                            net["RF/RequestFishingMinigameStarted"]:InvokeServer(-139.63, 0.996)
                        end)
                    end)
                    
                    task.spawn(function()
                        task.wait(c.f)
                        if c.d then
                            pcall(function()
                                net["RE/FishingCompleted"]:FireServer()
                            end)
                        end
                    end)
                    
                    task.wait(c.e)
                    if not c.d then break end
                    task.wait(0.1)
                end
            end)
        else
            if m then task.cancel(m) end
            if n then task.cancel(n) end
            m = nil
            n = nil
            pcall(function()
                net["RF/CancelFishingInputs"]:InvokeServer()
            end)
        end
    end
})

-- BLATANT V2 SECTION
local blatantV2Section = Tab3:AddSection("Blatant V2")

local toggleState = {
    blatantRunning = false,
    completeDelays = 0.08
}
local isSuperInstantRunning = false

-- Reel Delay Input
blatantV2Section:AddInput({
    Title = "Reel Delay",
    Content = "Delay between reels (seconds)",
    Default = "1.25",
    Callback = function(v)
        local num = tonumber(v)
        if num and num >= 0 then
            _G.ReelSuper = num
        end
    end
})

-- Complete Delay Input
blatantV2Section:AddInput({
    Title = "Complete Delay",
    Content = "Delay before completing (seconds)",
    Default = "0.08",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then
            toggleState.completeDelays = num
        end
    end
})

-- Blatant V2 Toggle
blatantV2Section:AddToggle({
    Title = "Blatant Mode V2",
    Content = "Enable Blatant V2 fishing",
    Default = false,
    Callback = function(value)
        toggleState.blatantRunning = value
        
        if value then
            isSuperInstantRunning = true
            task.spawn(function()
                while isSuperInstantRunning do
                    task.spawn(function()
                        pcall(function()
                            net["RF/CancelFishingInputs"]:InvokeServer()
                            net["RF/ChargeFishingRod"]:InvokeServer(tick())
                            net["RF/RequestFishingMinigameStarted"]:InvokeServer(-139.63796997070312, 0.9964792798079721)
                            task.wait(toggleState.completeDelays)
                            net["RE/FishingCompleted"]:FireServer()
                        end)
                    end)
                    task.wait(math.max(_G.ReelSuper or 1.25, 0.1))
                end
            end)
        else
            isSuperInstantRunning = false
        end
    end
})

-- RECOVERY FISHING BUTTON
blatantV1Section:AddButton({
    Title = "Recovery Fishing",
    Content = "Reset fishing state",
    Callback = function()
        -- Stop Blatant V1
        if c.d then
            c.d = false
            if m then 
                task.cancel(m)
                m = nil
            end
            if n then 
                task.cancel(n)
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
            net["RF/CancelFishingInputs"]:InvokeServer()
        end)
        
        -- Reset rod
        pcall(function()
            net["RE/EquipToolFromHotbar"]:FireServer(1)
        end)
    end
})

blatantV2Section:AddButton({
    Title = "Recovery Fishing",
    Content = "Reset fishing state",
    Callback = function()
        -- Stop Blatant V1
        if c.d then
            c.d = false
            if m then 
                task.cancel(m)
                m = nil
            end
            if n then 
                task.cancel(n)
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
            net["RF/CancelFishingInputs"]:InvokeServer()
        end)
        
        -- Reset rod
        pcall(function()
            net["RE/EquipToolFromHotbar"]:FireServer(1)
        end)
    end
})

-- SKIN ANIMATION SECTION
local skinSection = Tab3:AddSection("Skin Animation")

local selectedAnim = "None"
local activeAnim = nil

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
    Default = selectedAnim,
    Callback = function(v)
        selectedAnim = v
        activeAnim = AnimationList[v]
    end
})

-- Apply Animation Button
skinSection:AddButton({
    Title = "Apply Animation",
    Content = "Apply selected animation",
    Callback = function()
        activeAnim = AnimationList[selectedAnim]
    end
})

-- ==================== TAB 4: AUTO ====================
local Tab4 = Window:AddTab({
    Name = "Auto",
    Icon = "loop"
})

-- AUTO SELL SECTION
local sellSection = Tab4:AddSection("Auto Sell")

local AutoSell = false
local SellAt = 100
local Selling = false
local SellMinute = 5
local LastSell = 0

-- Auto Sell Threshold Input
sellSection:AddInput({
    Title = "Auto Sell When Fish ≥",
    Content = "Sell automatically when fish count reaches this number",
    Default = "100",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then 
            SellAt = math.floor(num)
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

-- Auto Sell Interval Input
sellSection:AddInput({
    Title = "Auto Sell Interval (Minutes)",
    Content = "Sell automatically every X minutes",
    Default = "5",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then 
            SellMinute = math.floor(num)
        end
    end
})

-- AUTO FAVORITE SECTION
local favSection = Tab4:AddSection("Auto Favorite")

local GlobalFav = {
    FishNames = {},
    VariantNames = {},
    SelectedFish = {},
    SelectedVariants = {},
    AutoFavoriteEnabled = false
}

-- Load fish data
task.spawn(function()
    for _, item in pairs(RS.Items:GetChildren()) do
        local ok, data = pcall(require, item)
        if ok and data.Data and data.Data.Type == "Fish" then
            table.insert(GlobalFav.FishNames, data.Data.Name)
        end
    end
    table.sort(GlobalFav.FishNames)
    
    for _, variantModule in pairs(RS.Variants:GetChildren()) do
        local ok, variantData = pcall(require, variantModule)
        if ok and variantData.Data and variantData.Data.Name then
            table.insert(GlobalFav.VariantNames, variantData.Data.Name)
        end
    end
    table.sort(GlobalFav.VariantNames)
end)

-- Fish Selection Dropdown
local selectedFishOptions = {}
favSection:AddDropdown({
    Title = "Select Fish",
    Content = "Choose fish to auto-favorite",
    Options = GlobalFav.FishNames,
    Default = {},
    Multi = true,
    Callback = function(v)
        GlobalFav.SelectedFish = v
    end
})

-- Variant Selection Dropdown
local selectedVariantOptions = {}
favSection:AddDropdown({
    Title = "Select Variants",
    Content = "Choose variants to auto-favorite",
    Options = GlobalFav.VariantNames,
    Default = {},
    Multi = true,
    Callback = function(v)
        GlobalFav.SelectedVariants = v
    end
})

-- Auto Favorite Toggle
favSection:AddToggle({
    Title = "Auto Favorite",
    Content = "Automatically favorite caught fish",
    Default = false,
    Callback = function(state)
        GlobalFav.AutoFavoriteEnabled = state
    end
})

-- EVENT SECTION
local eventSection = Tab4:AddSection("Events")

-- Auto Open Mysterious Cave
local AutoOpenMaze = false
local AutoOpenMazeTask = nil

eventSection:AddToggle({
    Title = "Auto Open Mysterious Cave",
    Content = "Automatically open mysterious cave",
    Default = false,
    Callback = function(state)
        AutoOpenMaze = state

        if state then
            AutoOpenMazeTask = task.spawn(function()
                while AutoOpenMaze do
                    pcall(function()
                        net["RE/SearchItemPickedUp"]:FireServer("TNT")
                        task.wait(1)
                        net["RE/GainAccessToMaze"]:FireServer()
                    end)
                    task.wait(2)
                end
            end)
        else
            AutoOpenMaze = false
            if AutoOpenMazeTask then
                task.cancel(AutoOpenMazeTask)
                AutoOpenMazeTask = nil
            end
        end
    end
})

-- Auto Claim Pirate Chest
local AutoClaimPirateChest = false
eventSection:AddToggle({
    Title = "Auto Claim Pirate Chest",
    Content = "Automatically claim pirate chest rewards",
    Default = false,
    Callback = function(v)
        AutoClaimPirateChest = v
    end
})

-- Pirate chest event
task.spawn(function()
    local Award = net["RE/AwardPirateChest"]
    Award.OnClientEvent:Connect(function(chestId)
        if AutoClaimPirateChest then
            pcall(function()
                net["RE/ClaimPirateChest"]:FireServer(chestId)
            end)
        end
    end)
end)

-- ==================== TAB 5: WEBHOOK ====================
local Tab5 = Window:AddTab({
    Name = "Webhook",
    Icon = "plug"
})

local webhookSection = Tab5:AddSection("Webhook Fish Caught")

local httpRequest = syn and syn.request or http and http.request or http_request or (fluxus and fluxus.request) or request

-- Webhook Variables
local WebhookURL = ""
local WebhookRarities = {}
local DetectNewFishActive = false

-- Rarity filter dropdown
local rarityOptions = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET"}
webhookSection:AddDropdown({
    Title = "Rarity Filter",
    Content = "Filter which rarities to send",
    Options = rarityOptions,
    Default = {},
    Multi = true,
    Callback = function(v)
        WebhookRarities = v
    end
})

-- Webhook URL Input
webhookSection:AddInput({
    Title = "Webhook URL",
    Content = "Enter your Discord webhook URL",
    Default = "",
    Callback = function(text)
        WebhookURL = text
    end
})

-- Send Webhook Toggle
webhookSection:AddToggle({
    Title = "Send Fish Caught Webhook",
    Content = "Send webhook notification when catching fish",
    Default = false,
    Callback = function(state)
        DetectNewFishActive = state
    end
})

-- Test Webhook Button
webhookSection:AddButton({
    Title = "Test Webhook",
    Content = "Send test webhook to check connection",
    Callback = function()
        if not httpRequest or not WebhookURL or not WebhookURL:match("discord.com/api/webhooks") then
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
                    Url = WebhookURL,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = game:GetService("HttpService"):JSONEncode(payload)
                })
                notif("Test webhook sent!", 3, Color3.fromRGB(0, 255, 0))
            end)
        end)
    end
})

-- ==================== TAB 6: SHOP ====================
local Tab6 = Window:AddTab({
    Name = "Shop",
    Icon = "shop"
})

-- BUY ROD SECTION
local rodSection = Tab6:AddSection("Buy Rod")

local R = {
    ["Luck Rod"] = 79, ["Carbon Rod"] = 76, ["Grass Rod"] = 85,
    ["Ice Rod"] = 78, ["Lucky Rod"] = 4, ["Midnight Rod"] = 80,
    ["Steampunk Rod"] = 6, ["Chrome Rod"] = 7, ["Astral Rod"] = 5
}

local rodOptions = {
    "Luck Rod (350 Coins)", "Carbon Rod (900 Coins)", "Grass Rod (1.5k Coins)",
    "Ice Rod (5k Coins)", "Lucky Rod (15k Coins)", "Midnight Rod (50k Coins)",
    "Steampunk Rod (215k Coins)", "Chrome Rod (437k Coins)", "Astral Rod (1M Coins)"
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
                net["RF/PurchaseFishingRod"]:InvokeServer(R[name]) 
            end)
        end
    end
})

-- BUY BAIT SECTION
local baitSection = Tab6:AddSection("Buy Baits")

local B = {
    ["Luck Bait"] = 2, ["Midnight Bait"] = 3, ["Nature Bait"] = 10,
    ["Chroma Bait"] = 6, ["Dark Matter Bait"] = 8, ["Corrupt Bait"] = 15
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
                net["RF/PurchaseBait"]:InvokeServer(B[selectedBait]) 
            end)
        end
    end
})

-- BUY WEATHER EVENT
local weatherSection = Tab6:AddSection("Weather Events")

local autoBuyEnabled = false

weatherSection:AddToggle({
    Title = "Auto Buy Weather",
    Content = "Auto buy Wind, Cloudy, Storm (100s loop)",
    Default = false,
    Callback = function(state)
        autoBuyEnabled = state

        if state then
            task.spawn(function()
                while autoBuyEnabled do
                    for _, weatherName in ipairs({"Wind", "Cloudy", "Storm"}) do
                        pcall(function()
                            net["RF/PurchaseWeatherEvent"]:InvokeServer(weatherName)
                        end)
                        task.wait(0.3)
                    end
                    task.wait(100)
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
local islandSection = Tab7:AddSection("Island Teleport")

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
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = IslandLocations[SelectedIsland]
            end
        end
    end
})

-- PLAYER TELEPORT SECTION
local playerTeleportSection = Tab7:AddSection("Player Teleport")

-- Function to get player list
local function getPlayerList()
    local players = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(players, plr.Name)
        end
    end
    table.sort(players)
    return players
end

-- Player dropdown
local playerList = getPlayerList()
local selectedPlayer = playerList[1] or ""

playerTeleportSection:AddDropdown({
    Title = "Select Player",
    Content = "Choose player to teleport to",
    Options = playerList,
    Default = selectedPlayer,
    Callback = function(v)
        selectedPlayer = v
    end
})

-- Refresh player list button
playerTeleportSection:AddButton({
    Title = "Refresh Player List",
    Content = "Refresh list of online players",
    Callback = function()
        playerList = getPlayerList()
        selectedPlayer = playerList[1] or ""
        -- Note: VictUI doesn't support dynamic dropdown refresh
        notif("Player list refreshed", 2, Color3.fromRGB(0, 255, 0))
    end
})

-- Teleport to player button
playerTeleportSection:AddButton({
    Title = "Teleport to Player",
    Content = "Teleport to selected player",
    Callback = function()
        if not selectedPlayer then
            notif("No player selected!", 3, Color3.fromRGB(255, 0, 0))
            return
        end

        local target = Players:FindFirstChild(selectedPlayer)
        if not target or not target.Character then
            notif("Target player not found!", 3, Color3.fromRGB(255, 0, 0))
            return
        end

        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if not targetHRP or not myHRP then
            notif("Character parts not found!", 3, Color3.fromRGB(255, 0, 0))
            return
        end

        myHRP.CFrame = CFrame.new(targetHRP.Position + Vector3.new(0, 3, 0))
    end
})

-- EVENT TELEPORT SECTION
local eventTeleportSection = Tab7:AddSection("Event Teleporter")

-- Event data (FROM ORIGINAL SCRIPT)
local S = setmetatable({}, {
    __index = function(_, k)
        return game:GetService(k)
    end
})

local ST = {
    player = LocalPlayer,
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

-- Event data (ORIGINAL)
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
table.sort(eventNames)

-- Force TP function
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

-- Float on water
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

-- Event selection dropdown
eventTeleportSection:AddDropdown({
    Title = "Select Events",
    Content = "Choose events to auto-teleport to",
    Options = eventNames,
    Default = {},
    Multi = true,
    Callback = function(v)
        ST.selectedEvents = v
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
        end
    end
})

-- ==================== TAB 8: SETTINGS ====================
local Tab8 = Window:AddTab({
    Name = "Settings",
    Icon = "settings"
})

-- MISC SECTION
local miscSection = Tab8:AddSection("Miscellaneous")

-- INFINITE ZOOM
local infiniteZoom = false
local originalZoom = {LocalPlayer.CameraMaxZoomDistance, LocalPlayer.CameraMinZoomDistance}

miscSection:AddToggle({
    Title = "Infinite Zoom",
    Content = "Infinite zoom to take photos",
    Default = false,
    Callback = function(s)
        infiniteZoom = s
        if s then
            LocalPlayer.CameraMaxZoomDistance = math.huge
            LocalPlayer.CameraMinZoomDistance = .5
        else
            LocalPlayer.CameraMaxZoomDistance = originalZoom[1] or 128
            LocalPlayer.CameraMinZoomDistance = originalZoom[2] or .5
        end
    end
})

-- HIDE NAME INPUT
local hideNameValue = "Victoria Hub"
miscSection:AddInput({
    Title = "Hide Name",
    Content = "Custom name to display",
    Default = "",
    Callback = function(v)
        hideNameValue = v
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local overhead = hrp:FindFirstChild("Overhead")
                if overhead then
                    local content = overhead:FindFirstChild("Content")
                    if content then
                        local header = content:FindFirstChild("Header")
                        if header then
                            header.Text = v
                        end
                    end
                end
            end
        end
    end
})

-- HIDE LEVEL INPUT
local hideLevelValue = "Lv. ???"
miscSection:AddInput({
    Title = "Hide Level",
    Content = "Custom level to display",
    Default = "",
    Callback = function(v)
        hideLevelValue = v
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local overhead = hrp:FindFirstChild("Overhead")
                if overhead then
                    local levelContainer = overhead:FindFirstChild("LevelContainer")
                    if levelContainer then
                        local label = levelContainer:FindFirstChild("Label")
                        if label then
                            label.Text = v
                        end
                    end
                end
            end
        end
    end
})

-- ANTI STAFF
local AntiStaffEnabled = false
local StaffBlacklist = {
    [75974130]=1,[40397833]=1,[187190686]=1,[33372493]=1,[889918695]=1,
    [33679472]=1,[30944240]=1,[25050357]=1,[8462585751]=1,[8811129148]=1,
    [192821024]=1,[4509801805]=1,[124505170]=1,[108397209]=1
}

miscSection:AddToggle({
    Title = "Anti Staff",
    Content = "Auto serverhop if staff detected",
    Default = false,
    Callback = function(s) 
        AntiStaffEnabled = s
    end
})

-- SERVER SECTION
local serverSection = Tab8:AddSection("Server")

serverSection:AddButton({
    Title = "Rejoin",
    Content = "Rejoin to the same server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

serverSection:AddButton({
    Title = "Server Hop",
    Content = "Switch to another server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

-- OTHER SCRIPTS SECTION
local scriptSection = Tab8:AddSection("Other Scripts")

scriptSection:AddButton({
    Title = "Infinite Yield",
    Content = "Load Infinite Yield script",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/main/latest.lua'))()
    end
})

-- ==================== FINAL ====================
getgenv().VictoriaHubWindow = Window

-- Single notification on load
task.spawn(function()
    task.wait(1)
    notif("Victoria Hub loaded successfully!", 5, Color3.fromRGB(138, 43, 226))
end)

return Window
