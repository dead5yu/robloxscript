-- ✅ CONFIGURATION
_G.AutoFarm = true
_G.AutoBountyFarm = true
_G.UseAnimations = true
local BOUNTY_THRESHOLD = 100000 -- Minimum bounty to target players
local MAX_DISTANCE = 300 -- Max distance to engage targets
local ANIMATION_ID = "rbxassetid://507770239" -- Sword slash animation (replace as you want)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- 🖥️ Create Toggle GUI
local function createToggleGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FarhansHubGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local function createButton(name, position, defaultState, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 150, 0, 35)
        button.Position = position
        button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        button.BorderColor3 = Color3.new(0, 0, 0)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 18
        button.Text = name .. ": " .. (defaultState and "ON" or "OFF")
        button.Parent = screenGui

        local state = defaultState
        button.MouseButton1Click:Connect(function()
            state = not state
            button.Text = name .. ": " .. (state and "ON" or "OFF")
            callback(state)
        end)
    end

    createButton("AutoFarm", UDim2.new(0, 20, 0, 50), _G.AutoFarm, function(v) _G.AutoFarm = v end)
    createButton("AutoBounty", UDim2.new(0, 20, 0, 100), _G.AutoBountyFarm, function(v) _G.AutoBountyFarm = v end)
    createButton("Animations", UDim2.new(0, 20, 0, 150), _G.UseAnimations, function(v) _G.UseAnimations = v end)
end
createToggleGui()

-- Load attack animation for character
local function loadAttackAnimation(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    local anim = Instance.new("Animation")
    anim.AnimationId = ANIMATION_ID
    local track = humanoid:LoadAnimation(anim)
    return track
end

-- 🤖 Auto Farm (NPCs + Quest)
spawn(function()
    while wait(0.5) do
        if not _G.AutoFarm then continue end
        pcall(function()
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local enemyName = "Bandit"
            local questName = "BanditQuest1"

            -- Auto Quest Pickup
            if not player.PlayerGui:FindFirstChild("QuestTitle") then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questName, 1)
            end

            -- Find enemy
            local target = nil
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if v.Name == enemyName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    local distance = (hrp.Position - v.HumanoidRootPart.Position).Magnitude
                    if distance <= MAX_DISTANCE then
                        target = v
                        break
                    end
                end
            end

            -- Attack enemy with animation and M1 clicks
            if target then
                hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                local animTrack
                if _G.UseAnimations then
                    animTrack = loadAttackAnimation(char)
                    if animTrack then animTrack:Play() end
                end

                repeat
                    VirtualInputManager:SendMouseButtonEvent(true, 0, 0, game) -- M1 Down
                    wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(false, 0, 0, game) -- M1 Up
                    wait(0.2)
                until not target or target.Humanoid.Health <= 0 or not _G.AutoFarm

                if animTrack then animTrack:Stop() end
            end
        end)
    end
end)

-- 🔥 Auto Bounty Farm (Players)
spawn(function()
    while wait(2) do
        if not _G.AutoBountyFarm then continue end
        pcall(function()
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr:FindFirstChild("Data") then
                    local isPvP = plr:FindFirstChild("CombatFolder")
                    local bountyValue = plr.Data.Bounty and plr.Data.Bounty.Value or 0
                    if isPvP and bountyValue >= BOUNTY_THRESHOLD then
                        local targetHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                        local distance =

