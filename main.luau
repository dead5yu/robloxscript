-- ✅ CONFIGURATION
_G.AutoFarm = true
_G.AutoBountyFarm = true
_G.AutoEquipF3X = true
_G.Float = true

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
            print("[GUI] " .. name .. " toggled to " .. (state and "ON" or "OFF"))
        end)
    end

    createButton("AutoFarm", UDim2.new(0, 20, 0, 50), _G.AutoFarm, function(v) _G.AutoFarm = v end)
    createButton("AutoBounty", UDim2.new(0, 20, 0, 90), _G.AutoBountyFarm, function(v) _G.AutoBountyFarm = v end)
    createButton("AutoEquipF3X", UDim2.new(0, 20, 0, 130), _G.AutoEquipF3X, function(v) _G.AutoEquipF3X = v end)
    createButton("Float", UDim2.new(0, 20, 0, 170), _G.Float, function(v) _G.Float = v end)
end
createToggleGui()

-- ♻️ Auto Respawn Support
player.CharacterAdded:Connect(function()
    print("[Respawn] Character added, waiting 3 seconds...")
    wait(3)
    print("[Respawn] Ready")
end)

-- 🧊 Float in Air Support
local function enableFloat()
    print("[Float] Enabling float...")
    local floatVelocity = Instance.new("BodyVelocity")
    floatVelocity.Velocity = Vector3.new(0, 20, 0)
    floatVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    floatVelocity.Name = "FloatVel"
    return floatVelocity
end

-- 🤖 Auto Farm (NPCs + Quest)
spawn(function()
    while wait(0.5) do
        if not _G.AutoFarm then continue end
        pcall(function()
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                print("[AutoFarm] No HumanoidRootPart found")
                return
            end

            if _G.Float and not hrp:FindFirstChild("FloatVel") then
                local float = enableFloat()
                float.Parent = hrp
            elseif not _G.Float and hrp:FindFirstChild("FloatVel") then
                hrp.FloatVel:Destroy()
                print("[Float] Disabled")
            end

            local enemyName = "Bandit"
            local questName = "BanditQuest1"

            -- Auto Quest Pickup
            if not player.PlayerGui:FindFirstChild("QuestTitle") then
                print("[AutoFarm] Starting quest:", questName)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questName, 1)
            end

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
                print("[AutoFarm] Attacking enemy:", target.Name)
                hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                repeat
                    ReplicatedStorage.Remotes.CommF_:FireServer("Attack")
                    wait(0.3)
                until not target or target.Humanoid.Health <= 0 or not _G.AutoFarm
                print("[AutoFarm] Enemy defeated or farm stopped")
            else
                print("[AutoFarm] No valid enemy found")
            end
        end)
    end
end)

-- 🔥 Auto Bounty Farm (Players)
spawn(function()
    while wait(1) do
        if not _G.AutoBountyFarm then continue end
        pcall(function()
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                print("[AutoBounty] No HumanoidRootPart found")
                return
            end

            if _G.Float and not hrp:FindFirstChild("FloatVel") then
                local float = enableFloat()
                float.Parent = hrp
            elseif not _G.Float and hrp:FindFirstChild("FloatVel") then
                hrp.FloatVel:Destroy()
                print("[Float] Disabled")
            end

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
                print("[AutoBounty] Attacking player:", bestTarget.Name)
                local targetHRP = bestTarget.Character:FindFirstChild("HumanoidRootPart")
                local enemyHum = bestTarget.Character:FindFirstChild("Humanoid")
                hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 5, 0)
                repeat
                    ReplicatedStorage.Remotes.CommF_:FireServer("Attack")
                    wait(0.3)
                until not enemyHum or enemyHum.Health <= 0 or not _G.AutoBountyFarm
                print("[AutoBounty] Player defeated or bounty farm stopped")
            else
                print("[AutoBounty] No valid bounty target found")
            end
        end)
    end
end)

-- 🧰 Auto Equip F3X Tool
spawn(function()
    while wait(2) do
        if not _G.AutoEquipF3X then continue end
        pcall(function()
            local backpack = player:FindFirstChild("Backpack")
            local character = player.Character or player.CharacterAdded:Wait()
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and not character:FindFirstChildOfClass("Tool") then
                    character.Humanoid:EquipTool(tool)
                    print("[AutoEquip] Equipped tool:", tool.Name)
                    break
                end
            end
        end)
    end
end)

