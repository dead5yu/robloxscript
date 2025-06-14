-- ✅ CONFIGURATION
_G.AutoFarm = false
_G.AutoBountyFarm = false

local BOUNTY_THRESHOLD = 100000 -- Minimum bounty to target players
local MAX_DISTANCE = 300 -- Max distance to engage targets

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- 📟 Simple Toggle GUI (without Float button)
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

-- Auto Respawn Support
player.CharacterAdded:Connect(function()
    wait(3)
end)

-- Equip combat tool function
local function equipCombatTool()
    local char = player.Character
    if not char then return false end
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("combat") then
            player.Character.Humanoid:EquipTool(tool)
            return true
        end
    end
    -- If no tool in character, check backpack
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("combat") then
            player.Character.Humanoid:EquipTool(tool)
            return true
        end
    end
    return false
end

-- Auto attack function (fires the attack remote)
local function doAttack()
    ReplicatedStorage.Remotes.CommF_:FireServer("Attack")
end

-- Quest functions
local function hasActiveQuest()
    return player.PlayerGui:FindFirstChild("QuestTitle") ~= nil
end

local function isQuestComplete()
    local questGui = player.PlayerGui:FindFirstChild("QuestTitle")
    if questGui and questGui.TextLabel then
        local txt = questGui.TextLabel.Text:lower()
        -- Adjust this text check depending on your game's UI wording for quest completion
        if txt:find("complete") or txt:find("finished") then
            return true
        end
    end
    return false
end

local function handleQuest(questName)
    if not hasActiveQuest() then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questName, 1)
        wait(1)
    elseif isQuestComplete() then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("FinishQuest", questName, 1)
        wait(1)
        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questName, 1)
        wait(1)
    end
end

local MAX_DISTANCE = 300
local questName = "BanditQuest1"
local enemyName = "Bandit"

-- Auto Farm Thread
spawn(function()
    while wait(0.5) do
        if not _G.AutoFarm then continue end
        pcall(function()
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- Handle Quest properly
            handleQuest(questName)

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
                        -- Stay 20 studs above to avoid damage
                        hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 20, 0)

                        -- Equip combat tool
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

-- Auto Bounty Farm Thread
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
                    hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 20, 0) -- float 20 studs above
                    ReplicatedStorage.Remotes.CommF_:FireServer("Attack")
                    wait(0.3)
                until not enemyHum or enemyHum.Health <= 0 or not _G.AutoBountyFarm
            end
        end)
    end
end)
