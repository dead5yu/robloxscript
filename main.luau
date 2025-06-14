-- ✅ CONFIGURATION
_G.AutoFarm = true
_G.AutoBountyFarm = true
_G.AutoEquipF3X = true
local BOUNTY_THRESHOLD = 100000 -- Minimum bounty to target players
local MAX_DISTANCE = 300 -- Max distance to engage targets

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

-- 📟 Simple Toggle GUI
local function createToggleGui()
    local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    screenGui.Name = "AutoFarmGUI"
    screenGui.ResetOnSpawn = false

    local function createButton(name, pos, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 150, 0, 30)
        button.Position = pos
        button.Text = name .. ": ON"
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.SourceSans
        button.TextSize = 18
        button.Parent = screenGui

        local state = true
        button.MouseButton1Click:Connect(function()
            state = not state
            button.Text = name .. ": " .. (state and "ON" or "OFF")
            callback(state)
        end)
    end

    createButton("AutoFarm", UDim2.new(0, 20, 0, 50), function(v) _G.AutoFarm = v end)
    createButton("AutoBounty", UDim2.new(0, 20, 0, 90), function(v) _G.AutoBountyFarm = v end)
    createButton("AutoEquipF3X", UDim2.new(0, 20, 0, 130), function(v) _G.AutoEquipF3X = v end)
end
createToggleGui()

-- ♻️ Auto Respawn Support
player.CharacterAdded:Connect(function()
    wait(3)
end)

-- 🤖 Auto Farm (NPCs + Quest)
spawn(function()
    while wait(0.5) do
        if not _G.AutoFarm then continue end
        pcall(function()
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- 🔧 SETTINGS
            local enemyName = "Bandit"
            local questName = "BanditQuest1"

            -- ✅ Auto Quest Pickup
            if not player.PlayerGui:FindFirstChild("QuestTitle") then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questName, 1)
            end

            -- 🎯 Find Valid Enemy
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

            -- ⚔️ Attack Enemy
            if target then
                hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                repeat
                    for _, key in ipairs({"Z", "X", "C"}) do
                        VirtualInputManager:SendKeyEvent(true, key, false, game)
                        wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, key, false, game)
                        wait(0.1)
                    end
                    wait()
                until not target or target.Humanoid.Health <= 0 or not _G.AutoFarm
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
                        local distance = (hrp.Position - targetHRP.Position).Magnitude
                        if distance <= MAX_DISTANCE then
                            hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 5, 0)
                            for _, key in ipairs({"Z", "X", "C"}) do
                                VirtualInputManager:SendKeyEvent(true, key, false, game)
                                wait(0.1)
                                VirtualInputManager:SendKeyEvent(false, key, false, game)
                                wait(0.1)
                            end
                            wait(1.5)
                        end
                    end
                end
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
            local tool = backpack and backpack:FindFirstChild("F3X") or character:FindFirstChild("F3X")

            if tool and character and not character:FindFirstChildOfClass("Tool") then
                character.Humanoid:EquipTool(tool)

            end
        end)
    end
end)
"Add main.luau script"
