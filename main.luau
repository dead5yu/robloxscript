--// CONFIGURATION
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

local BOUNTY_THRESHOLD = 100000
local MAX_DISTANCE = 300
local ANIMATION_ID = "rbxassetid://507770239" -- Replace with your preferred animation

-- Global toggles
local settings = {
    AutoFarm = true,
    AutoBounty = true,
    UseAnimations = true,
}

--// GUI
local function createToggleButton(screenGui, name, position, default, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 160, 0, 35)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 18
    button.Text = name..": "..(default and "ON" or "OFF")
    button.Parent = screenGui

    local state = default
    button.MouseButton1Click:Connect(function()
        state = not state
        button.Text = name..": "..(state and "ON" or "OFF")
        callback(state)
    end)
    return button
end

local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FarhansHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    createToggleButton(screenGui, "AutoFarm", UDim2.new(0,20,0,50), settings.AutoFarm, function(v) settings.AutoFarm = v end)
    createToggleButton(screenGui, "AutoBounty", UDim2.new(0,20,0,100), settings.AutoBounty, function(v) settings.AutoBounty = v end)
    createToggleButton(screenGui, "Animations", UDim2.new(0,20,0,150), settings.UseAnimations, function(v) settings.UseAnimations = v end)
end

--// Animation Loader
local function loadAttackAnimation(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animation = Instance.new("Animation")
    animation.AnimationId = ANIMATION_ID
    local animTrack = humanoid:LoadAnimation(animation)
    return animTrack
end

--// Auto Farm Logic
local function autoFarm()
    while wait(0.5) do
        if not settings.AutoFarm then continue end
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if not hrp then continue end

        -- Auto quest pickup (example)
        local questName = "BanditQuest1"
        if not player.PlayerGui:FindFirstChild("QuestTitle") then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questName, 1)
            end)
        end

        -- Find nearest Bandit enemy
        local target
        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
            if enemy.Name == "Bandit" and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                local dist = (hrp.Position - enemy.HumanoidRootPart.Position).Magnitude
                if dist <= MAX_DISTANCE then
                    target = enemy
                    break
                end
            end
        end

        if target then
            hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
            local animTrack
            if settings.UseAnimations then
                animTrack = loadAttackAnimation(char)
                if animTrack then animTrack:Play() end
            end

            repeat
                pcall(function()
                    VirtualInputManager:SendMouseButtonEvent(true, 0, 0, game) -- M1 down
                    wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(false, 0, 0, game) -- M1 up
                end)
                wait(0.2)
            until not target or not target.Parent or target.Humanoid.Health <= 0 or not settings.AutoFarm

            if animTrack then animTrack:Stop() end
        end
    end
end

--// Auto Bounty Farm Logic
local function autoBounty()
    while wait(2) do
        if not settings.AutoBounty then continue end
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if not hrp then continue end

        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr:FindFirstChild("Data") then
                local isPvP = plr:FindFirstChild("CombatFolder")
                local bountyVal = plr.Data.Bounty and plr.Data.Bounty.Value or 0
                if isPvP and bountyVal >= BOUNTY_THRESHOLD then
                    local targetHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                    local dist = (hrp.Position - targetHRP.Position).Magnitude
                    if dist <= MAX_DISTANCE then
                        hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 5, 0)
                        pcall(function()
                            VirtualInputManager:SendMouseButtonEvent(true, 0, 0, game) -- M1 down
                            wait(0.1)
                            VirtualInputManager:SendMouseButtonEvent(false, 0, 0, game) -- M1 up
                        end)
                        wait(1.5)
                    end
                end
            end
        end
    end
end

--// Start
createGui()
spawn(autoFarm)
spawn(autoBounty)
