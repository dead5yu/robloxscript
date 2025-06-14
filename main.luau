-- ✅ CONFIGURATION
_G.AutoFarm = false
_G.AutoBountyFarm = false

local BOUNTY_THRESHOLD = 100000 -- Minimum bounty to target players
local MAX_DISTANCE = 300 -- Max distance to engage targets

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local Backpack = player:WaitForChild("Backpack")

-- 📟 Simple Toggle GUI
local function createToggleGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoFarmGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local function createButton(name, pos, defaultState, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 150, 0, 30)
        button.Position = pos
        button.Text = name .. ": " .. (defaultState and "ON" or "OFF")
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.SourceSans
        button.TextSize = 18
        button.Parent = screenGui

        local state = defaultState
        button.MouseButton1Click:Connect(function()
            state = not state
            button.Text = name .. ": " .. (state and "ON" or "OFF")
            callback(state)
        end)
    end

    createButton("AutoFarm", UDim2.new(0, 20, 0, 50), _G.AutoFarm, function(v) _G.AutoFarm = v end)
    createButton("AutoBounty", UDim2.new(0, 20, 0, 90), _G.AutoBountyFarm, function(v) _G.AutoBountyFarm = v end)
end
createToggleGui()

-- ♻️ Auto Respawn Support
player.CharacterAdded:Connect(function()
    wait(3)
end)

-- Helper: Equip any tool that looks like a weapon
local function equipTool()
    local char = player.Character
    if not char then return end

    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = char
            break
        end
    end
end

-- 🤖 Auto Farm (NPCs + Quest) without float
spawn(function()
    while wait(0.5) do
        if not _G.AutoFarm then continue end
        pcall(function()
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- Equip tool before attacking
            equipTool()

            -- SETTINGS
            local enemyName = "Bandit" -- Adjust if you want different NPCs
            local questName = "BanditQuest1" -- Adjust quest name to your farming quest

            -- Auto Quest Pickup
            if not player.PlayerGui:FindFirstChild("QuestTitle") then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questName, 1)
            end

            -- Find Closest Valid Enemy NPC
            local target, closestDist = nil, MAX_DISTANCE + 1
            for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                if enemy.Name == enemyName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                    local dist = (hrp.Position - enemy.HumanoidRootPart.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        target = enemy
                    end
                end
            end

            -- Attack Enemy NPC by moving close and firing attack
            if target then
                local targetHRP = target:FindFirstChild("HumanoidRootPart")
                local humanoid = target:FindFirstChild("Humanoid")
                repeat
                    if not target or not humanoid or humanoid.Health <= 0 then break end

                    -- Move close to target (near ground)
                    hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 3, 0)

                    -- Fire attack remote
                    local success, err = pcall(function()
                        ReplicatedStorage.Remotes.CommF_:FireServer("Attack")
                    end)
                    if not success then warn("Attack FireServer failed:", err) end

                    wait(0.4)
                until not target or humanoid.Health <= 0 or not _G.AutoFarm
            end
        end)
    end
end)

-- 🔥 Auto Bounty Farm (Players) without float
spawn(function()
    while wait(1) do
        if not _G.AutoBountyFarm then continue end
        pcall(function()
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- Equip tool before attacking
            equipTool()

            local bestTarget = nil
            local bestDistance = MAX_DISTANCE + 1

            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr:FindFirstChild("Data") then
                    local bountyValue = plr.Data:FindFirstChild("Bounty") and plr.Data.Bounty.Value or 0
                    local isPvP = plr:FindFirstChild("CombatFolder")
                    if isPvP and bountyValue >= BOUNTY_THRESHOLD then
                        local targetHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                        local dist = (hrp.Position - targetHRP.Position).Magnitude
                        if dist < bestDistance and dist <= MAX_DISTANCE then
                            bestTarget = plr
                            bestDistance = dist
                        end
                    end
                end
            end

            if bestTarget and bestTarget.Character and bestTarget.Character:FindFirstChild("Humanoid") then
                local targetHRP = bestTarget.Character:FindFirstChild("HumanoidRootPart")
                local enemyHum = bestTarget.Character:FindFirstChild("Humanoid")
                repeat
                    hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 3, 0) -- near ground
                    ReplicatedStorage.Remotes.CommF_:FireServer("Attack")
                    wait(0.3)
                until not enemyHum or enemyHum.Health <= 0 or not _G.AutoBountyFarm
            end
        end)
    end
end)
