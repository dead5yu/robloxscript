local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("User InputService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

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

-- Function to create a text label with fade animation
local function createTextLabel(text, position, size, parent)
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = size
    textLabel.Position = position
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 24
    textLabel.TextTransparency = 1
    textLabel.Parent = parent

    -- Fade in animation
    local fadeIn = TweenService:Create(textLabel, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0})
    fadeIn:Play()
    wait(2)

    -- Fade out animation
    local fadeOut = TweenService:Create(textLabel, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1})
    fadeOut:Play()
    wait(1)
    textLabel:Destroy()
end

-- Create initial text label
createTextLabel("SkibidiScripts", UDim2.new(0, 0, 0.45, 0), UDim2.new(1, 0, 0.1, 0), screenGui)

-- Main Frame Setup
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 250)
frame.Position = UDim2.new(0.5, -150, -0.3, 0)
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

-- Function to create buttons with hover effects
local function createButton(text, position, size, parent, color, hoverColor)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.Text = text
    button.BackgroundColor3 = color
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 14
    button.Parent = parent

    -- Add hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = hoverColor
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = color
    end)

    return button
end

-- Create buttons
local closeButton = createButton("", UDim2.new(1, -30, 0, 8), UDim2.new(0, 12, 0, 12), frame, Color3.fromRGB(255, 96, 92), Color3.fromRGB(225, 223, 225))
local minimizeButton = createButton("", UDim2.new(1, -50, 0, 8), UDim2.new(0, 12, 0, 12), frame, Color3.fromRGB(255, 189, 68), Color3.fromRGB(225, 223, 225))

-- Function to handle button clicks
local function onCloseButtonClick()
    screenGui:Destroy()
end

local function onMinimizeButtonClick()
    frame.Visible = not frame.Visible
end

-- Connect button click events
closeButton.MouseButton1Click:Connect(onCloseButtonClick)
minimizeButton.MouseButton1Click:Connect(onMinimizeButtonClick)

-- Speed Labels and Sliders
local function createSpeedControl(labelText, position, parent)
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.8, 0, 0, 20)
    speedLabel.Position = position
    speedLabel.Text = labelText
    speedLabel.TextColor3 = Color3.fromRGB(192, 191, 192)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Font = Enum.Font.SourceSans
    speedLabel.TextSize = 14
    speedLabel.Parent = parent

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(0.7, 0, 0, 3)
    sliderTrack.Position = UDim2.new(0.15, 0, 0.3, 0)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(225, 223, 225)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = parent

    local sliderThumb = Instance.new("TextButton")
    sliderThumb.Size = UDim2.new(0, 14, 0, 14)
    sliderThumb.Position = UDim2.new(0.5, -7, 0.3, -5)
    sliderThumb.BackgroundColor3 = Color3.fromRGB(192, 191, 192)
    sliderThumb.Text = ""
    sliderThumb.AutoButtonColor = false
    sliderThumb.Parent = parent

    return speedLabel, sliderTrack, sliderThumb
end

-- Create Fly Speed Control
local flySpeedLabel, flySliderTrack, flySliderThumb = createSpeedControl("Fly Speed: 50", UDim2.new(0.1, 0, 0.2, 0), frame)

-- Create Walk Speed Control
local walkSpeedLabel, walkSliderTrack, walkSliderThumb = createSpeedControl("Walk Speed: 16", UDim2.new(0.1, 0, 0.42, 0), frame)

-- Function to update speed labels and sliders
local function updateSpeed(sliderThumb, speedLabel, speed)
    local sliderWidth = sliderTrack.AbsoluteSize.X
    local sliderStart = sliderTrack.AbsolutePosition.X
    local mouseX = UserInputService:GetMouseLocation().X

    local relativePosition = math.clamp((mouseX - sliderStart) / sliderWidth, 0, 1)
    local actualScale = 0.15 + (relativePosition * 0.7)

    sliderThumb.Position = UDim2.new(actualScale, -7, 0.3, -5)
    speed = math.floor(10 + (relativePosition * 90))
    speedLabel.Text = labelText .. speed
end

-- Slider Drag Events
flySliderThumb.MouseButton1Down:Connect(function()
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSpeed(flySliderThumb, flySpeedLabel)
        end
    end)
end)

walkSliderThumb.MouseButton1Down:Connect(function()
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSpeed(walkSliderThumb, walkSpeedLabel)
        end
    end)
end)

-- Function to toggle flying
local function toggleFly()
    if flying then
        disableFly()
    else
        enableFly()
    end
end

-- Connect buttons to their toggle functions
flyButton.MouseButton1Click:Connect(toggleFly)
noclipButton.MouseButton1Click:Connect(toggleNoClip)
walkSpeedButton.MouseButton1Click:Connect(toggleWalkSpeed)

-- Handle character respawning
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Reset flying state
    if flying then
        disableFly()
    end
end)

-- Anti-AFK
local antiAFK = player.Idled:Connect(function()
    game:GetService("VirtualUser "):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    wait(1)
    game:GetService("VirtualUser "):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- Clean up on script termination
screenGui.AncestryChanged:Connect(function(_, newParent)
    if not newParent then
        if flying then
            disableFly()
        end
        antiAFK:Disconnect()
    end
end)
