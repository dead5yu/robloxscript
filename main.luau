-- ✅ CONFIGURATION
_G.AutoFarm = false
_G.AutoBountyFarm = false

local BOUNTY_THRESHOLD = 100000 -- Minimum bounty to target players
local MAX_DISTANCE = 300 -- Max distance to engage targets

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

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

-- Equip combat tool by name
local function equipCombatTool()
    local char = player.Character
    if not char then return false end

    local toolName = "Combat" -- Change this to your exact tool name if different
    local tool = char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChild(toolName)
    if tool and tool.Parent ~= char then
        tool.Parent = char
        wait(0.2)
    end
    return tool and tool.Parent == char
end

-- Simulate left mouse button click for attack
local function doAttack()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1) -- mouse button down
    wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1) -- mouse button up
end

local function finishQuestIfComplete(questName)
    -- Checks if quest objective is complete and finishes quest if possible
    -- This might depend on your game’s UI and quest system; adjust accordingly

    local questGui = player.PlayerGui:FindFirstChild("QuestTitle")
    if questGui then
        local questText = questGui.TextLabel.Text or ""
        -- Example check: if quest text contains "Complete" or similar, finish quest
        -- Replace below with your actual condition or detection
        if questText:lower():find("complete") then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("FinishQuest", questName, 1)
            wait(1)
            -- Start new quest
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questName, 1)
            wait(1)
            return true
        end
    end
    return false
end

-- Auto Farm (NPCs + Quest) with auto attack from above
spawn(function()
    while wait(0.5) do
        if not _G.AutoFarm then continue end
        pcall(function()
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local questName = "BanditQuest1"
            local enemyName = "Bandit"

            -- Auto Quest Pickup if no quest active
            if not player.PlayerGui:FindFirstChild("QuestTitle") then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questName, 1)
                wait(1)
            end

            -- Check if quest finished, if yes finish and start again
            finishQuestIfComplete(questName)

            -- Find closest enemy NPC
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

            if target then
                local humanoid = target:FindFirstChild("Humanoid")
                local targetHRP = target:FindFirstChild("HumanoidRootPart")
                if humanoid and targetHRP then
                    repeat
                        if not _G.AutoFarm then break end
                        -- Stay 20 studs ABOVE target to avoid damage
                        hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 20, 0)

                        -- Equip tool
                        local equipped = equipCombatTool()
                        if not equipped then
                            warn("Failed to equip combat tool")
                            wait(0.5)
                            continue
                        end

                        -- Attack
                        doAttack()
                        wait(0.5)
                    until humanoid.Health <= 0 or not _G.AutoFarm
                end
            end
        end)
    end
end)

-- Auto Bounty Farm (Players) with auto attack
spawn(function()
    while wait(1) do
        if not _G.AutoBountyFarm then continue end
        pcall(function()
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

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
                    if not _G.AutoBountyFarm then break end
                    -- Stay 20 studs above player target to avoid damage
                    hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 20, 0)

                    -- Equip tool
                    local equipped = equipCombatTool()
                    if not equipped then
                        warn("Failed to equip combat tool")
                        wait(0.5)
                        continue
                    end

                    -- Attack
                    doAttack()
                    wait(0.5)
                until not enemyHum or enemyHum.Health <= 0 or not _G.AutoBountyFarm
            end
        end)
    end
end)
