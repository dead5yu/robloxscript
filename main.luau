local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("User InputService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Sound Setup
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://6518811702" -- Replace with your desired sound ID
sound.Volume = 0.5
sound.Parent = workspace
sound:Play()

-- Ensure PlayerGui exists
if not player:FindFirstChild("PlayerGui") then
    Instance.new("PlayerGui").Parent = player
end

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "FlyUI"
screenGui.ResetOnSpawn = false

-- Text Animation at the Beginning
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 0.1, 0)
textLabel.Position = UDim2.new(0, 0, 0.45, 0)
textLabel.Text = "SkibidiScripts"
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.BackgroundTransparency = 1
textLabel.Font = Enum.Font.SourceSansBold
textLabel.TextSize = 24
textLabel.TextTransparency = 1
textLabel.Parent = screenGui

-- Fade in animation
local fadeIn = TweenService:Create(
    textLabel,
    TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {TextTransparency = 0}
)
fadeIn:Play()

-- Wait for the text to stay visible
wait(2)

-- Fade out animation
local fadeOut = TweenService:Create(
    textLabel,
    TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {TextTransparency = 1}
)
fadeOut:Play()

-- Wait for the fade out to finish
wait(1)

-- Remove the text label
textLabel:Destroy()

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 250)
frame.Position = UDim2.new(0.5, -150, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Add rounded corners to the frame
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.1, 0)
corner.Parent = frame

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.8, 0, 0, 20)
titleLabel.Position = UDim2.new(0.1, 0, 0.05, 0)
titleLabel.Text = "SkibidiScript"
titleLabel.TextColor3 = Color3.fromRGB(192, 191, 192)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.Parent = frame

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 12, 0, 12)
closeButton.Position = UDim2.new(1, -30, 0, 8)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(255, 96, 92)
closeButton.AutoButtonColor = false
closeButton.Parent = frame

-- Fly Speed Label
local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Size = UDim2.new(0.8, 0, 0, 20)
flySpeedLabel.Position = UDim2.new(0.1, 0, 0.2, 0)
flySpeedLabel.Text = "Fly Speed: 50"
flySpeedLabel.TextColor3 = Color3.fromRGB(192, 191, 192)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Font = Enum.Font.SourceSans
flySpeedLabel.TextSize = 14
flySpeedLabel.Parent = frame

-- Fly Speed Slider Track
local flySliderTrack = Instance.new("Frame")
flySliderTrack.Size = UDim2.new(0.7, 0, 0, 3)
flySliderTrack.Position = UDim2.new(0.15, 0, 0.3, 0)
flySliderTrack.BackgroundColor3 = Color3.fromRGB(225, 223, 225)
flySliderTrack.BorderSizePixel = 0
flySliderTrack.Parent = frame

-- Fly Slider Thumb
local flySliderThumb = Instance.new("TextButton")
flySliderThumb.Size = UDim2.new(0, 14, 0, 14)
flySliderThumb.Position = UDim2.new(0.5, -7, 0.3, -5)
flySliderThumb.BackgroundColor3 = Color3.fromRGB(192, 191, 192)
flySliderThumb.Text = ""
flySliderThumb.AutoButtonColor = false
flySliderThumb.Parent = frame

-- Flying Variables
local flySpeed = 50 -- Default fly speed
local flying = false
local bodyVelocity, bodyGyro

-- Function to enable flying
local function enableFly()
    if flying then return end -- Prevent multiple flying states
    flying = true
    humanoid.PlatformStand = true -- Disable gravity for the character

    -- Create a BodyVelocity for movement
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = rootPart

    -- Create a BodyGyro for stability
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000
    bodyGyro.D = 500
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart

    -- Fly loop
    spawn(function()
        while flying and bodyVelocity and bodyGyro do
            local camera = workspace.CurrentCamera
            local direction = Vector3.new(0, 0, 0)

            -- Movement keys
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end

            -- Normalize the direction vector
            if direction.Magnitude > 0 then
                direction = direction.Unit
            end

            -- Apply velocity in the direction of movement
            bodyVelocity.Velocity = direction * flySpeed
            
            -- Update BodyGyro to maintain orientation with camera
            bodyGyro.CFrame = CFrame.new(Vector3.new(0, 0, 0), camera.CFrame.LookVector)
            
            wait()
        end
    end)
end

-- Function to disable flying
local function disableFly()
    if not flying then return end
    flying = false
    humanoid.PlatformStand = false
    
    -- Remove the flying instances
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end

-- Function to toggle flying
function toggleFly()
    if flying then
        disableFly()
    else
        enableFly()
    end
end

-- Bind UI to Right Alt
User InputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Ignore if the game already processed the input

    if input.KeyCode == Enum.KeyCode.RightAlt then
        -- Toggle UI visibility (not implemented in this snippet)
    elseif input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    end
end)

-- Close Button Click
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy() -- Remove the UI
end)

-- UI Slide-In Animation
local slideIn = TweenService:Create(
    frame,
    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {Position = UDim2.new(0.5, -150, 0, 10)}
)
slideIn:Play()
