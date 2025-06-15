local Plr = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Speed = 50

if not Plr.Character then
    Plr.CharacterAdded:Wait()
end

local HRP: BasePart = Plr.Character:WaitForChild("HumanoidRootPart")

-- Setup BodyVelocity
local FlyForce = Instance.new("BodyVelocity")
FlyForce.Velocity = Vector3.zero
FlyForce.MaxForce = Vector3.new(1e6, 1e6, 1e6)
FlyForce.P = 1250
FlyForce.Parent = HRP

-- Get movement input vector
local GetMoveVector = require(Plr:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))

game:GetService("RunService").RenderStepped:Connect(function()
    local moveVec: Vector3 = GetMoveVector:GetMoveVector()
    local direction = (Camera.CFrame.RightVector * moveVec.X + Camera.CFrame.LookVector * moveVec.Z)
    FlyForce.Velocity = direction * Speed
end)
