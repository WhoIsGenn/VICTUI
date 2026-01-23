-- [[ VICTORIA HUB FISH IT - PATCHED VERSION ]] --
-- Version: 1.0.0

-- ==================== LOAD VICTUI LIBRARY ====================
local Vict = loadstring(game:HttpGet("https://raw.githubusercontent.com/WhoIsGenn/ui/refs/heads/main/victui.lua"))()

-- ==================== PATCH THE LIBRARY ====================
-- Override the AddSection function to force sections closed
local originalAddTab = Window.AddTab
Window.AddTab = nil  -- Clear dulu

-- Create custom Window that forces sections closed
local function createPatchedWindow(options)
    local win = Vict:Window(options)
    
    -- Override AddTab method
    local originalWinAddTab = win.AddTab
    win.AddTab = function(self, tabOptions)
        local tab = originalWinAddTab(self, tabOptions)
        
        -- Override AddSection method for this tab
        local originalTabAddSection = tab.AddSection
        tab.AddSection = function(self, name, alwaysOpen)
            -- FORCE alwaysOpen to be false
            local section = originalTabAddSection(self, name, false)
            
            -- Try to close the section immediately
            task.spawn(function()
                task.wait(0.05)  -- Wait a tiny bit
                -- Try to find and click the collapse button
                pcall(function()
                    local coreGui = game:GetService("CoreGui")
                    for _, v in pairs(coreGui:GetDescendants()) do
                        if v:IsA("TextButton") and v.Name == "SectionToggle" then
                            if v.Text == "▼" then  -- If open
                                v:Fire("MouseButton1Click")
                            end
                        end
                    end
                end)
            end)
            
            return section
        end
        
        return tab
    end
    
    return win
end

-- ==================== CREATE MAIN WINDOW ====================
local Window = createPatchedWindow({
    Title = "Victoria Hub",
    Footer = "VictoriaHub | Fish It",
    Color = Color3.fromRGB(138, 43, 226),
    ["Tab Width"] = 120,
    Version = 1.0,
    Icon = "rbxassetid://134034549147826",
    Image = "134034549147826"
})

-- ==================== CREATE TABS AFTER DELAY ====================
-- Function to create all tabs after UI loads
local function createAllTabs()
    -- Wait for UI to initialize
    task.wait(0.5)
    
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
    _G.InstantDelay = 0.65
    local fishThread
    local RS = game:GetService("ReplicatedStorage")
    local net = RS:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

    -- Simple fishing function
    local function simpleFish()
        pcall(function()
            net["RF/ChargeFishingRod"]:InvokeServer()
            net["RF/RequestFishingMinigameStarted"]:InvokeServer(-139.63, 0.996)
            task.wait(_G.InstantDelay)
            net["RE/FishingCompleted"]:FireServer()
        end)
    end

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
                fishThread = task.spawn(function()
                    while _G.AutoFishing do
                        simpleFish()
                        task.wait(_G.InstantDelay + 0.5)
                    end
                end)
            end
        end
    })

    -- ==================== TAB 4: AUTO ====================
    local Tab4 = Window:AddTab({
        Name = "Auto",
        Icon = "loop"
    })

    local autoSection = Tab4:AddSection("Auto Features", false)

    autoSection:AddToggle({
        Title = "Auto Equip Rod",
        Content = "Automatically equip fishing rod",
        Default = false,
        Callback = function(v)
            _G.AutoEquipRod = v
            if v then
                pcall(function()
                    net["RE/EquipToolFromHotbar"]:FireServer(1)
                end)
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
            pcall(function() 
                net["RF/PurchaseFishingRod"]:InvokeServer(79) 
            end)
            notif("Purchased: Luck Rod", 3, Color3.fromRGB(0, 255, 0))
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

    -- ==================== TAB 7: SETTINGS ====================
    local Tab7 = Window:AddTab({
        Name = "Settings",
        Icon = "settings"
    })

    local settingsSection = Tab7:AddSection("Settings", false)

    settingsSection:AddButton({
        Title = "Infinite Yield",
        Content = "Load Infinite Yield script",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/main/latest.lua'))()
            notif("Infinite Yield loaded successfully!", 3, Color3.fromRGB(0, 255, 0))
        end
    })

    -- Force close all sections one more time
    task.wait(1)
    for _, v in pairs(game:GetService("CoreGui"):GetDescendants()) do
        if v:IsA("TextButton") and (v.Text == "▼" or v.Text == "▲") then
            if v.Text == "▼" then
                v:Fire("MouseButton1Click")
            end
        end
    end
end

-- Start creating tabs
task.spawn(createAllTabs)

-- ==================== FINAL NOTIFICATION ====================
task.spawn(function()
    task.wait(2)
    notif("Victoria Hub loaded successfully!", 5, Color3.fromRGB(138, 43, 226))
end)

getgenv().VictoriaHubWindow = Window

return Window
