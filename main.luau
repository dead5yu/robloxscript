lua

Run
Copy code
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

-- Main Frame - EXPANDED WIDTH and HEIGHT for loadstring button
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 250) -- Increased width from 220 to 300, height from 200 to 250
frame.Position = UDim2.new(0.5, -150, -0.3, 0) -- Adjusted X position to center the wider frame
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

-- Close Button (Mac OS Style)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 12, 0, 12)
closeButton.Position = UDim2.new(1, -30, 0, 8)
closeButton.Text = ""
closeButton.BackgroundColor3 = Color3.fromRGB(255, 96, 92)
closeButton.AutoButtonColor = false
closeButton.Parent = frame

-- Add shadow to close button
local closeButtonShadow = Instance.new("UIStroke")
closeButtonShadow.Color = Color3.fromRGB(0, 0, 0)
closeButtonShadow.Transparency = 0.7
closeButtonShadow.Thickness = 1
closeButtonShadow.Parent = closeButton

-- Rounded corners for close button
local closeButtonCorner = Instance.new("UICorner")
closeButtonCorner.CornerRadius = UDim.new(1, 0)
closeButtonCorner.Parent = closeButton

-- Add hover effect to close button
closeButton.MouseEnter:Connect(function()
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(225, 223, 225) -- E1DFE1 color
    closeButton.TextSize = 8 -- Smaller X (changed from 10)
    closeButton.Font = Enum.Font.SourceSansBold -- Make it bold for better visibility
end)

closeButton.MouseLeave:Connect(function()
    closeButton.Text = ""
end)

-- Minimize Button (Mac OS Style)
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 12, 0, 12)
minimizeButton.Position = UDim2.new(1, -50, 0, 8)
minimizeButton.Text = ""
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 189, 68)
minimizeButton.AutoButtonColor = false
minimizeButton.Parent = frame

-- Add shadow to minimize button
local minimizeButtonShadow = Instance.new("UIStroke")
minimizeButtonShadow.Color = Color3.fromRGB(0, 0, 0)
minimizeButtonShadow.Transparency = 0.7
minimizeButtonShadow.Thickness = 1
minimizeButtonShadow.Parent = minimizeButton

-- Rounded corners for minimize button
local minimizeButtonCorner = Instance.new("UICorner")
minimizeButtonCorner.CornerRadius = UDim.new(1, 0)
minimizeButtonCorner.Parent = minimizeButton

-- Add hover effect to minimize button
minimizeButton.MouseEnter:Connect(function()
    minimizeButton.Text = "-"
    minimizeButton.TextColor3 = Color3.fromRGB(225, 223, 225) -- E1DFE1 color
    minimizeButton.TextSize = 14 -- Slightly larger for better centering
    minimizeButton.TextYAlignment = Enum.TextYAlignment.Center -- Center vertically
    minimizeButton.TextXAlignment = Enum.TextXAlignment.Center -- Center horizontally
    minimizeButton.Font = Enum.Font.SourceSansBold -- Make it bold for better visibility
end)

minimizeButton.MouseLeave:Connect(function()
    minimizeButton.Text = ""
end)

-- Fly Speed Label
local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Size = UDim2.new(0.8, 0, 0, 20)
flySpeedLabel.Position = UDim2.new(0.1, 0, 0.2, 0) -- Adjusted position
flySpeedLabel.Text = "Fly Speed: 50"
flySpeedLabel.TextColor3 = Color3.fromRGB(192, 191, 192)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Font = Enum.Font.SourceSans
flySpeedLabel.TextSize = 14
flySpeedLabel.Parent = frame

-- Fly Speed Slider Track
local flySliderTrack = Instance.new("Frame")
flySliderTrack.Size = UDim2.new(0.7, 0, 0, 3)
flySliderTrack.Position = UDim2.new(0.15, 0, 0.3, 0) -- Adjusted position
flySliderTrack.BackgroundColor3 = Color3.fromRGB(225, 223, 225)
flySliderTrack.BorderSizePixel = 0
flySliderTrack.Parent = frame

-- Rounded corners for fly slider track
local flySliderCorner = Instance.new("UICorner")
flySliderCorner.CornerRadius = UDim.new(1, 0)
flySliderCorner.Parent = flySliderTrack

-- Fly Slider Thumb
local flySliderThumb = Instance.new("TextButton")
flySliderThumb.Size = UDim2.new(0, 14, 0, 14)
flySliderThumb.Position = UDim2.new(0.5, -7, 0.3, -5) -- Adjusted position
flySliderThumb.BackgroundColor3 = Color3.fromRGB(192, 191, 192)
flySliderThumb.Text = ""
flySliderThumb.AutoButtonColor = false
flySliderThumb.Parent = frame

-- Add shadow to fly slider thumb
local flySliderThumbShadow = Instance.new("UIStroke")
flySliderThumbShadow.Color = Color3.fromRGB(0, 0, 0)
flySliderThumbShadow.Transparency = 0.7
flySliderThumbShadow.Thickness = 1
flySliderThumbShadow.Parent = flySliderThumb

-- Rounded corners for fly slider thumb
local flyThumbCorner = Instance.new("UICorner")
flyThumbCorner.CornerRadius = UDim.new(1, 0)
flyThumbCorner.Parent = flySliderThumb

-- Walk Speed Label
local walkSpeedLabel = Instance.new("TextLabel")
walkSpeedLabel.Size = UDim2.new(0.8, 0, 0, 20)
walkSpeedLabel.Position = UDim2.new(0.1, 0, 0.42, 0)
walkSpeedLabel.Text = "Walk Speed: 16"
walkSpeedLabel.TextColor3 = Color3.fromRGB(192, 191, 192)
walkSpeedLabel.BackgroundTransparency = 1
walkSpeedLabel.Font = Enum.Font.SourceSans
walkSpeedLabel.TextSize = 14
walkSpeedLabel.Parent = frame

-- Walk Speed Slider Track
local walkSliderTrack = Instance.new("Frame")
walkSliderTrack.Size = UDim2.new(0.7, 0, 0, 3)
walkSliderTrack.Position = UDim2.new(0.15, 0, 0.52, 0)
walkSliderTrack.BackgroundColor3 = Color3.fromRGB(225, 223, 225)
walkSliderTrack.BorderSizePixel = 0
walkSliderTrack.Parent = frame

-- Rounded corners for walk slider track
local walkSliderCorner = Instance.new("UICorner")
walkSliderCorner.CornerRadius = UDim.new(1, 0)
walkSliderCorner.Parent = walkSliderTrack

-- Walk Speed Slider Thumb
local walkSliderThumb = Instance.new("TextButton")
walkSliderThumb.Size = UDim2.new(0, 14, 0, 14)
walkSliderThumb.Position = UDim2.new(0.15, -7, 0.52, -5) -- Start position at min
walkSliderThumb.BackgroundColor3 = Color3.fromRGB(192, 191, 192) -- Different color
walkSliderThumb.Text = ""
walkSliderThumb.AutoButtonColor = false
walkSliderThumb.Parent = frame

-- Add shadow to walk slider thumb
local walkSliderThumbShadow = Instance.new("UIStroke")
walkSliderThumbShadow.Color = Color3.fromRGB(0, 0, 0)
walkSliderThumbShadow.Transparency = 0.7
walkSliderThumbShadow.Thickness = 1
walkSliderThumbShadow.Parent = walkSliderThumb

-- Rounded corners for walk slider thumb
local walkThumbCorner = Instance.new("UICorner")
walkThumbCorner.CornerRadius = UDim.new(1, 0)
walkThumbCorner.Parent = walkSliderThumb

-- Fly Button
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0.35, 0, 0, 30)
flyButton.Position = UDim2.new(0.1, 0, 0.65, 0) -- Adjusted position
flyButton.Text = "Fly: OFF [F]" -- Added key info to button
flyButton.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Font = Enum.Font.SourceSansBold
flyButton.TextSize = 14
flyButton.Parent = frame

-- Add shadow to fly button
local flyButtonShadow = Instance.new("UIStroke")
flyButtonShadow.Color = Color3.fromRGB(0, 0, 0)
flyButtonShadow.Transparency = 0.7
flyButtonShadow.Thickness = 1
flyButtonShadow.Parent = flyButton

-- Rounded corners for fly button
local flyButtonCorner = Instance.new("UICorner")
flyButtonCorner.CornerRadius = UDim.new(0.2, 0)
flyButtonCorner.Parent = flyButton

-- NoClip Button
local noclipButton = Instance.new("TextButton")
noclipButton.Size = UDim2.new(0.35, 0, 0, 30)
noclipButton.Position = UDim2.new(0.55, 0, 0.65, 0) -- Adjusted position
noclipButton.Text = "NoClip: OFF"
noclipButton.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
noclipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipButton.Font = Enum.Font.SourceSansBold
noclipButton.TextSize = 14
noclipButton.Parent = frame

-- Add shadow to noclip button
local noclipButtonShadow = Instance.new("UIStroke")
noclipButtonShadow.Color = Color3.fromRGB(0, 0, 0)
noclipButtonShadow.Transparency = 0.7
noclipButtonShadow.Thickness = 1
noclipButtonShadow.Parent = noclipButton

-- Rounded corners for noclip button
local noclipButtonCorner = Instance.new("UICorner")
noclipButtonCorner.CornerRadius = UDim.new(0.2, 0)
noclipButtonCorner.Parent = noclipButton

-- Walk Speed Toggle Button
local walkSpeedButton = Instance.new("TextButton")
walkSpeedButton.Size = UDim2.new(0.35, 0, 0, 30) -- Changed from 0.8 to 0.35 to match other buttons
walkSpeedButton.Position = UDim2.new(0.1, 0, 0.82, 0)
walkSpeedButton.Text = "Walk Speed: OFF [X]" -- Added key info to button
walkSpeedButton.BackgroundColor3 = Color3.fromRGB(0, 202, 78)
walkSpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
walkSpeedButton.Font = Enum.Font.SourceSansBold
walkSpeedButton.TextSize = 14
walkSpeedButton.Parent = frame

-- Add shadow to walk speed button
local walkSpeedButtonShadow = Instance.new("UIStroke")
walkSpeedButtonShadow.Color = Color3.fromRGB(0, 0, 0)
walkSpeedButtonShadow.Transparency = 0.7
walkSpeedButtonShadow.Thickness = 1
walkSpeedButtonShadow.Parent = walkSpeedButton

-- Rounded corners for walk speed button
local walkSpeedButtonCorner = Instance.new("UICorner")
walkSpeedButtonCorner.CornerRadius = UDim.new(0.2, 0)
walkSpeedButtonCorner.Parent = walkSpeedButton

-- NEW: LoadString Button
local loadStringButton = Instance.new("TextButton")
loadStringButton.Size = UDim2.new(0.35, 0, 0, 30)
loadStringButton.Position = UDim2.new(0.55, 0, 0.82, 0) -- Position next to walk speed button
loadStringButton.Text = "Stroke"
loadStringButton.BackgroundColor3 = Color3.fromRGB(255, 64, 64) -- Red color to make it stand out
loadStringButton.TextColor3 = Color3.fromRGB(255, 255, 255)
loadStringButton.Font = Enum.Font.SourceSansBold
loadStringButton.TextSize = 14
loadStringButton.Parent = frame

-- Add shadow to loadstring button
local loadStringButtonShadow = Instance.new("UIStroke")
loadStringButtonShadow.Color = Color3.fromRGB(0, 0, 0)
loadStringButtonShadow.Transparency = 0.7
loadStringButtonShadow.Thickness = 1
loadStringButtonShadow.Parent = loadStringButton

-- Rounded corners for loadstring button
local loadStringButtonCorner = Instance.new("UICorner")
loadStringButtonCorner.CornerRadius = UDim.new(0.2, 0)
loadStringButtonCorner.Parent = loadStringButton

-- NEW: Discord Button
local discordButton = Instance.new("TextButton")
discordButton.Size = UDim2.new(0, 80, 0, 10) -- Small button size
discordButton.Position = UDim2.new(0.5, -40, 0.95, 0) -- Centered at bottom of frame
discordButton.Text = "Discord"
discordButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218) -- Discord blue color
discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
discordButton.Font = Enum.Font.SourceSansBold
discordButton.TextSize = 14
discordButton.Parent = frame

-- Add shadow to Discord button
local discordButtonShadow = Instance.new("UIStroke")
discordButtonShadow.Color = Color3.fromRGB(0, 0, 0)
discordButtonShadow.Transparency = 0.7
discordButtonShadow.Thickness = 1
discordButtonShadow.Parent = discordButton

-- Rounded corners for Discord button
local discordButtonCorner = Instance.new("UICorner")
discordButtonCorner.CornerRadius = UDim.new(0.2, 0)
discordButtonCorner.Parent = discordButton

-- Small Discord icon (optional)
local discordIcon = Instance.new("ImageLabel")
discordIcon.Size = UDim2.new(0, 16, 0, 16)
discordIcon.Position = UDim2.new(0, 5, 0.5, -8)
discordIcon.BackgroundTransparency = 1
discordIcon.Image = "rbxassetid://4494451673" -- Discord icon asset ID
discordIcon.Parent = discordButton

-- Discord button click function
discordButton.MouseButton1Click:Connect(function()
    -- Visual feedback
    local originalColor = discordButton.BackgroundColor3
    discordButton.BackgroundColor3 = Color3.fromRGB(78, 93, 148) -- Darker discord color
    
    -- Open Discord invite with a Roblox system message
    local inviteLink = "https://discord.gg/Spyydr4c"
    
    -- Use Roblox's internal function to open URL
    pcall(function()
        -- First method (GUI method)
        game:GetService("GuiService"):OpenBrowserWindow(inviteLink)
    end)
    
    -- If the above fails, try alternate method
    pcall(function()
        -- Second method (legacy)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Discord Invite",
            Text = "
