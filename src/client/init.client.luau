-- Rock Simulator Client
-- Handles camera, UI, and client-side rock experience

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

-- Rock simulation state
local myRock = nil
local cameraConnection = nil
local uiElements = {}

-- Camera settings
local CAMERA_OFFSET = Vector3.new(0, 8, 12)
local CAMERA_ANGLE = -15
local CAMERA_SMOOTH_TIME = 2

-- Wait for player's rock to be created
local function waitForMyRock()
    local rockName = "PlayerRock_" .. player.Name
    
    local rock = Workspace:FindFirstChild(rockName)
    while not rock do
        wait(0.5)
        rock = Workspace:FindFirstChild(rockName)
    end
    
    return rock
end

-- Set up camera to view the rock
local function setupRockCamera(rock)
    camera.CameraType = Enum.CameraType.Scriptable
    
    local function updateCamera()
        if rock and rock.Parent then
            local rockPosition = rock.Position
            local cameraPosition = rockPosition + CAMERA_OFFSET
            
            -- Create a smooth camera movement
            local cframe = CFrame.lookAt(cameraPosition, rockPosition)
            cframe = cframe * CFrame.Angles(math.rad(CAMERA_ANGLE), 0, 0)
            
            camera.CFrame = camera.CFrame:Lerp(cframe, 0.05)
        end
    end
    
    -- Connect the camera update
    cameraConnection = RunService.Heartbeat:Connect(updateCamera)
end

-- Create the zen-like UI
local function createRockUI()
    -- Main UI frame
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RockSimulatorUI"
    screenGui.Parent = playerGui
    
    -- Stats panel (top left)
    local statsFrame = Instance.new("Frame")
    statsFrame.Name = "StatsFrame"
    statsFrame.Size = UDim2.new(0, 250, 0, 150)
    statsFrame.Position = UDim2.new(0, 20, 0, 20)
    statsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    statsFrame.BackgroundTransparency = 0.7
    statsFrame.BorderSizePixel = 0
    statsFrame.Parent = screenGui
    
    -- Round the corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = statsFrame
    
    -- Stats title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🪨 Rock Statistics"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = statsFrame
    
    -- Stats labels
    local stats = {
        {name = "Time Existed", key = "TimeExisted"},
        {name = "Events Witnessed", key = "EventsWitnessed"}, 
        {name = "Weather Changes", key = "WeatherChanges"},
        {name = "Visitors Met", key = "VisitorsMetamorphosed"}
    }
    
    for i, stat in ipairs(stats) do
        local label = Instance.new("TextLabel")
        label.Name = stat.key
        label.Size = UDim2.new(1, -10, 0, 25)
        label.Position = UDim2.new(0, 5, 0, 25 + (i * 25))
        label.BackgroundTransparency = 1
        label.Text = stat.name .. ": 0"
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 14
        label.Font = Enum.Font.SourceSans
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = statsFrame
        
        uiElements[stat.key] = label
    end
    
    -- Zen message (center bottom)
    local zenFrame = Instance.new("Frame")
    zenFrame.Name = "ZenFrame"
    zenFrame.Size = UDim2.new(0, 400, 0, 80)
    zenFrame.Position = UDim2.new(0.5, -200, 1, -120)
    zenFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    zenFrame.BackgroundTransparency = 0.8
    zenFrame.BorderSizePixel = 0
    zenFrame.Parent = screenGui
    
    local zenCorner = Instance.new("UICorner")
    zenCorner.CornerRadius = UDim.new(0, 15)
    zenCorner.Parent = zenFrame
    
    local zenLabel = Instance.new("TextLabel")
    zenLabel.Name = "ZenMessage"
    zenLabel.Size = UDim2.new(1, -20, 1, -20)
    zenLabel.Position = UDim2.new(0, 10, 0, 10)
    zenLabel.BackgroundTransparency = 1
    zenLabel.Text = "You are a rock. Be still. Observe. Exist."
    zenLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    zenLabel.TextSize = 18
    zenLabel.Font = Enum.Font.SourceSansItalic
    zenLabel.TextXAlignment = Enum.TextXAlignment.Center
    zenLabel.TextYAlignment = Enum.TextYAlignment.Center
    zenLabel.TextWrapped = true
    zenLabel.Parent = zenFrame
    
    uiElements.zenMessage = zenLabel
    
    -- Rotate zen messages
    local zenMessages = {
        "You are a rock. Be still. Observe. Exist.",
        "Time flows around you like water around stone.",
        "You have witnessed the turning of seasons.",
        "Creatures come and go, but you remain.",
        "The earth speaks to you in silence.",
        "Your patience is eternal, your purpose unclear.",
        "What dreams may come to those who cannot sleep?",
        "You are both ancient and forever young."
    }
    
    spawn(function()
        while zenLabel.Parent do
            wait(15) -- Change message every 15 seconds
            if zenLabel.Parent then
                local newMessage = zenMessages[math.random(1, #zenMessages)]
                zenLabel.Text = newMessage
            end
        end
    end)
    
    return screenGui
end

-- Format time nicely
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    
    if hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, secs)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, secs)
    else
        return string.format("%ds", secs)
    end
end

-- Update UI with current stats
local function updateStatsUI()
    -- Simple time tracking from when the rock was found
    local timeExisted = tick() - (myRock and myRock:GetAttribute("SpawnTime") or tick())
    
    if uiElements.TimeExisted then
        uiElements.TimeExisted.Text = "Time Existed: " .. formatTime(timeExisted)
    end
    
    -- Other stats would be updated from server events in a full implementation
    -- For now, we'll show some basic progression
    if uiElements.EventsWitnessed then
        local events = math.floor(timeExisted / 10) -- 1 event per 10 seconds for demo
        uiElements.EventsWitnessed.Text = "Events Witnessed: " .. events
    end
end

-- Main initialization
local function initialize()
    print("Rock Simulator client starting...")
    
    -- Wait for our rock to be created
    myRock = waitForMyRock()
    print("Found my rock:", myRock.Name)
    
    -- Set up camera
    setupRockCamera(myRock)
    
    -- Create UI
    createRockUI()
    
    -- Start stats updating
    spawn(function()
        while myRock and myRock.Parent do
            updateStatsUI()
            wait(1)
        end
    end)
    
    print("Rock simulation initialized! You are now a rock. 🪨")
end

-- Start immediately - rock should be created without character
initialize()

-- Camera controls (optional subtle movement)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.R then
        -- Reset camera position
        if myRock then
            setupRockCamera(myRock)
        end
    end
end)
