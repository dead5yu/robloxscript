-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Config
local config = {
    AutoFarm = true,
    AutoBounty = true,
    BountyThreshold = 100000,
    MaxDistance = 300,
}

-- UI
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "AutoFarmUI"

local function createToggle(name, position, initialValue, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 30)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.Text = name .. ": ON"
    btn.Parent = ScreenGui

    local state = initialValue

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)

    return btn, function() return state end
end

-- Toggles
createToggle("AutoFarm", UDim2.new(0, 20, 0, 50), true, function(v) config.AutoFarm = v end)
createToggle("AutoBounty", UDim2.new(0, 20, 0, 90), true, function(v) config.AutoBounty = v end)

-- Utility function to click M1
local function clickM1()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

-- Auto Quest Pickup
local function pickupQuest()
    if not player.PlayerGui:FindFirstChild("QuestTitle") then
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
        end)
    end
end

-- Find target enemy within max distance
local function findEnemy(enemyName, hrp)
    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
        if enemy.Name == enemyName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
            if enemyHRP and (hrp.Position - enemyHRP.Position).Magnitude <= config.MaxDistance then
                return enemy
            end
        end
    end
    return nil
end

-- Attack enemy using key presses + M1 clicks
local function attackEnemy(enemy)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or not enemy or not enemy:FindFirstChild("HumanoidRootPart") then return end

    hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)

    while config.AutoFarm and enemy.Humanoid.Health > 0 and hum.Health > 0 do
        for _, key in ipairs({"Z", "X", "C"}) do
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
            task.wait(0.1)
        end
        clickM1()
        task.wait(0.1)
    end
end

-- Auto Farm loop
RunService.Heartbeat:Connect(function()
    if not config.AutoFarm then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    pickupQuest()

    local targetEnemy = findEnemy("Bandit", hrp)
    if targetEnemy then
        attackEnemy(targetEnemy)
    end
end)

-- Auto Bounty Hunt
RunService.Heartbeat:Connect(function()
    if not config.AutoBounty then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr:FindFirstChild("Data") then
            local combatFolder = plr:FindFirstChild("CombatFolder")
            local bounty = plr.Data:FindFirstChild("Bounty")
            if combatFolder and bounty and bounty.Value >= config.BountyThreshold then
                local targetHRP = plr.Character.HumanoidRootPart
                if (hrp.Position - targetHRP.Position).Magnitude <= config.MaxDistance then
                    hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 5, 0)
                    for _, key in ipairs({"Z", "X", "C"}) do
                        VirtualInputManager:SendKeyEvent(true, key, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, key, false, game)
                        task.wait(0.1)
                    end
                    clickM1()
                    task.wait(1.5)
                end
            end
        end
    end
end)

-- Respawn Support
player.CharacterAdded:Connect(function()
    task.wait(3)
end)

