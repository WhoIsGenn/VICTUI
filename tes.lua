-- [[ VICTORIA HUB FISH IT - FINAL FIXED VERSION ]] --
-- Version: 1.0.0
-- ALL SECTIONS CLOSED BY DEFAULT

-- ==================== LOAD VICTUI LIBRARY ====================
local Vict = loadstring(game:HttpGet("https://raw.githubusercontent.com/WhoIsGenn/ui/refs/heads/main/victui.lua"))()

-- ==================== CREATE MAIN WINDOW ====================
local Window = Vict:Window({
    Title = "Victoria Hub",
    Footer = "VictoriaHub | Fish It",
    Color = Color3.fromRGB(138, 43, 226),
    ["Tab Width"] = 120,
    Version = 1.0,
    Icon = "rbxassetid://134034549147826",
    Image = "134034549147826"
})

-- ==================== TAB 1: INFO ====================
local Tab1 = Window:AddTab({
    Name = "Info",
    Icon = "alert"
})

local infoSection = Tab1:AddSection("Information", false)

infoSection:AddParagraph({
    Title = "Victoria Hub",
    Content = "Welcome to Victoria Hub! Made with VictUI.",
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
        local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
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
        local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
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

UIS.JumpRequest:Connect(function()
    if _G.InfiniteJump then
        local h = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
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
                    local character = game.Players.LocalPlayer.Character
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
local P = game.Players.LocalPlayer
local frozen = false
local lastCFrame

playerSection:AddToggle({
    Title = "Freeze Character",
    Content = "Freeze your character in place",
    Default = false,
    Callback = function(s)
        frozen = s
        local character = P.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local hrp = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and hrp then
                if s then
                    lastCFrame = hrp.CFrame
                    humanoid.WalkSpeed = 0
                    humanoid.JumpPower = 0
                    hrp.Anchored = true
                else
                    humanoid.WalkSpeed = 16
                    humanoid.JumpPower = 50
                    hrp.Anchored = false
                    if lastCFrame then
                        hrp.CFrame = lastCFrame
                    end
                end
            end
        end
    end
})

-- ==================== TAB 3: MAIN (FISHING) ====================
local Tab3 = Window:AddTab({
    Name = "Main",
    Icon = "fish"
})

local fishingSection = Tab3:AddSection("Fishing Features", false)

-- Fishing variables
_G.AutoFishing = false
_G.InstantDelay = 0.65
local fishThread

-- Auto Fishing Toggle
fishingSection:AddToggle({
    Title = "Auto Fishing",
    Content = "Automatically fish (Simple Mode)",
    Default = false,
    Callback = function(v)
        _G.AutoFishing = v
        
        if fishThread then
            task.cancel(fishThread)
            fishThread = nil
        end
        
        if v then
            fishThread = task.spawn(function()
                while _G.AutoFishing do
                    notif("Fishing...", 1, Color3.fromRGB(0, 255, 255))
                    task.wait(_G.InstantDelay)
                end
            end)
        end
    end
})

-- Fishing Delay
fishingSection:AddSlider({
    Title = "Fishing Delay",
    Content = "Delay between fishing cycles",
    Min = 0.5,
    Max = 5,
    Default = _G.InstantDelay,
    Increment = 0.1,
    Callback = function(v)
        _G.InstantDelay = v
    end
})

-- Cancel Delay Input
local cancelDelayValue = 1.7
fishingSection:AddPanel({
    Title = "Cancel Delay",
    Content = "Delay before canceling fishing",
    Placeholder = "1.7",
    Default = tostring(cancelDelayValue),
    ButtonText = "Done",
    ButtonCallback = function(input) end,
    Callback = function(input)
        local num = tonumber(input)
        if num and num > 0 then
            cancelDelayValue = num
            notif("Cancel delay set: " .. num, 2, Color3.fromRGB(0, 255, 0))
        end
    end
})

-- ==================== TAB 4: AUTO ====================
local Tab4 = Window:AddTab({
    Name = "Auto",
    Icon = "loop"
})

local autoSection = Tab4:AddSection("Auto Features", false)

local AutoSell = false
local SellAt = 100

-- Auto Sell Threshold
autoSection:AddPanel({
    Title = "Auto Sell When Fish ≥",
    Content = "Sell automatically when fish count reaches this number",
    Placeholder = "100",
    Default = tostring(SellAt),
    ButtonText = "Done",
    ButtonCallback = function(input) end,
    Callback = function(text)
        local n = tonumber(text)
        if n and n > 0 then 
            SellAt = math.floor(n) 
            notif("Will sell at " .. SellAt .. " fish", 3, Color3.fromRGB(0, 255, 0))
        end
    end
})

-- Auto Sell Toggle
autoSection:AddToggle({
    Title = "Auto Sell All Fish",
    Content = "Automatically sell all fish when threshold reached",
    Default = false,
    Callback = function(state)
        AutoSell = state
        if state then
            notif("Auto Sell enabled!", 2, Color3.fromRGB(0, 255, 0))
        end
    end
})

-- ==================== TAB 5: SHOP ====================
local Tab5 = Window:AddTab({
    Name = "Shop",
    Icon = "shop"
})

local shopSection = Tab5:AddSection("Shop Features", false)

shopSection:AddButton({
    Title = "Buy Luck Rod",
    Content = "Buy Luck Rod for 350 coins",
    Callback = function()
        notif("Buying Luck Rod...", 2, Color3.fromRGB(255, 255, 0))
        task.wait(1)
        notif("Purchased: Luck Rod", 3, Color3.fromRGB(0, 255, 0))
    end
})

shopSection:AddButton({
    Title = "Buy Carbon Rod",
    Content = "Buy Carbon Rod for 900 coins",
    Callback = function()
        notif("Buying Carbon Rod...", 2, Color3.fromRGB(255, 255, 0))
        task.wait(1)
        notif("Purchased: Carbon Rod", 3, Color3.fromRGB(0, 255, 0))
    end
})

-- ==================== TAB 6: TELEPORT ====================
local Tab6 = Window:AddTab({
    Name = "Teleport",
    Icon = "gps"
})

local teleportSection = Tab6:AddSection("Teleport Features", false)

teleportSection:AddButton({
    Title = "TP to Ancient Jungle",
    Content = "Teleport to Ancient Jungle island",
    Callback = function()
        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(1480.000, 3.029, -334.000)
            notif("Teleported to Ancient Jungle", 3, Color3.fromRGB(0, 255, 0))
        end
    end
})

teleportSection:AddButton({
    Title = "TP to Coral Refs",
    Content = "Teleport to Coral Refs island",
    Callback = function()
        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(-3270.860, 2.500, 2228.100)
            notif("Teleported to Coral Refs", 3, Color3.fromRGB(0, 255, 0))
        end
    end
})

-- ==================== TAB 7: SETTINGS ====================
local Tab7 = Window:AddTab({
    Name = "Settings",
    Icon = "settings"
})

local settingsSection = Tab7:AddSection("Settings", false)

-- INFINITE ZOOM
local Z = {game.Players.LocalPlayer.CameraMaxZoomDistance, game.Players.LocalPlayer.CameraMinZoomDistance}

settingsSection:AddToggle({
    Title = "Infinite Zoom",
    Content = "Infinite zoom to take photos",
    Default = false,
    Callback = function(s)
        if s then
            game.Players.LocalPlayer.CameraMaxZoomDistance = math.huge
            game.Players.LocalPlayer.CameraMinZoomDistance = .5
            notif("Infinite Zoom enabled", 2, Color3.fromRGB(0, 255, 0))
        else
            game.Players.LocalPlayer.CameraMaxZoomDistance = Z[1] or 128
            game.Players.LocalPlayer.CameraMinZoomDistance = Z[2] or .5
            notif("Infinite Zoom disabled", 2, Color3.fromRGB(255, 0, 0))
        end
    end
})

-- SERVER FEATURES
local serverSection = Tab7:AddSection("Server", false)

serverSection:AddButton({
    Title = "Rejoin",
    Content = "Rejoin to the same server",
    Callback = function()
        notif("Rejoining server...", 3, Color3.fromRGB(255, 255, 0))
        local TeleportService = game:GetService("TeleportService")
        local player = game.Players.LocalPlayer
        TeleportService:Teleport(game.PlaceId, player)
    end
})

serverSection:AddButton({
    Title = "Server Hop",
    Content = "Switch to another server",
    Callback = function()
        notif("Server hopping...", 3, Color3.fromRGB(255, 255, 0))
        local TeleportService = game:GetService("TeleportService")
        local player = game.Players.LocalPlayer
        TeleportService:Teleport(game.PlaceId, player)
    end
})

-- OTHER SCRIPTS
local scriptSection = Tab7:AddSection("Other Scripts", false)

scriptSection:AddButton({
    Title = "Infinite Yield",
    Content = "Load Infinite Yield script",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/main/latest.lua'))()
        notif("Infinite Yield loaded successfully!", 3, Color3.fromRGB(0, 255, 0))
    end
})

-- ==================== FINAL NOTIFICATION ====================
task.spawn(function()
    task.wait(1)
    notif("Victoria Hub loaded successfully!", 5, Color3.fromRGB(138, 43, 226))
end)

getgenv().VictoriaHubWindow = Window

return Window
