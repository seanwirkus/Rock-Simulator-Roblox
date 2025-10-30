-- Rock Simulator Client - FIXED
-- Simple, working camera and movement

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

-- Simple camera state
local cameraDistance = 15
local cameraAngle = Vector2.new(0, -30) -- yaw, pitch
local isOrbiting = false
local lastMouse = Vector2.new()

-- Simple movement
local keysPressed = {}
local jumpCooldown = 0

-- Simple camera state
local cameraDistance = 15
local cameraAngle = Vector2.new(0, -30) -- yaw, pitch
local isOrbiting = false
local lastMouse = Vector2.new()

-- Simple movement
local keysPressed = {}
local jumpCooldown = 0

-- ============ CAMERA ============
camera.CameraType = Enum.CameraType.Scriptable
camera.FieldOfView = 80

local function updateCamera()
    if not player.Character then return end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Position camera around rock
    local yaw = math.rad(cameraAngle.X)
    local pitch = math.rad(cameraAngle.Y)
    
    local camPos = root.Position + Vector3.new(
        math.sin(yaw) * math.cos(pitch) * cameraDistance,
        math.sin(pitch) * cameraDistance + 3,
        math.cos(yaw) * math.cos(pitch) * cameraDistance
    )
    
    camera.CFrame = CFrame.new(camPos, root.Position + Vector3.new(0, 2, 0))
end

RunService.RenderStepped:Connect(updateCamera)

-- ============ INPUT ============

-- Orbit camera with right mouse
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isOrbiting = true
        lastMouse = UserInputService:GetMouseLocation()
    elseif input.UserInputType == Enum.UserInputType.MouseWheel then
        cameraDistance = math.clamp(cameraDistance - input.Position.Z * 2, 5, 30)
    end
    
    -- Movement keys
    if input.KeyCode == Enum.KeyCode.W then keysPressed.W = true
    elseif input.KeyCode == Enum.KeyCode.S then keysPressed.S = true
    elseif input.KeyCode == Enum.KeyCode.A then keysPressed.A = true
    elseif input.KeyCode == Enum.KeyCode.D then keysPressed.D = true
    elseif input.KeyCode == Enum.KeyCode.R then cameraAngle = Vector2.new(0, -30) cameraDistance = 15
    elseif input.KeyCode == Enum.KeyCode.Space then
        if jumpCooldown <= 0 and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local dir = Vector3.new(0, 0, 0)
                if keysPressed.W then dir = dir + Vector3.new(0, 0, 1) end
                if keysPressed.S then dir = dir + Vector3.new(0, 0, -1) end
                if keysPressed.A then dir = dir + Vector3.new(-1, 0, 0) end
                if keysPressed.D then dir = dir + Vector3.new(1, 0, 0) end
                
                local jumpVel = (dir.Magnitude > 0 and dir.Unit * 25 or Vector3.new(0, 1, 0)) + Vector3.new(0, 20, 0)
                
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = jumpVel
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bv.Parent = root
                game:GetService("Debris"):AddItem(bv, 0.15)
                jumpCooldown = 0.4
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isOrbiting = false
    end
    
    if input.KeyCode == Enum.KeyCode.W then keysPressed.W = false
    elseif input.KeyCode == Enum.KeyCode.S then keysPressed.S = false
    elseif input.KeyCode == Enum.KeyCode.A then keysPressed.A = false
    elseif input.KeyCode == Enum.KeyCode.D then keysPressed.D = false
    end
end)

-- Orbit camera with mouse drag
UserInputService.InputChanged:Connect(function(input)
    if isOrbiting and input.UserInputType == Enum.UserInputType.MouseMovement then
        local newMouse = UserInputService:GetMouseLocation()
        local delta = newMouse - lastMouse
        cameraAngle = cameraAngle + Vector2.new(-delta.X * 0.5, -delta.Y * 0.5)
        cameraAngle = Vector2.new(cameraAngle.X % 360, math.clamp(cameraAngle.Y, -80, 30))
        lastMouse = newMouse
    end
end)

-- Cooldown timer
RunService.Heartbeat:Connect(function()
    if jumpCooldown > 0 then jumpCooldown = jumpCooldown - game:GetService("RunService").Heartbeat:Wait() end
end)

-- ============ UI ============

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0, 300, 0, 150)
infoLabel.Position = UDim2.new(0, 20, 0, 20)
infoLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
infoLabel.BackgroundTransparency = 0.3
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
infoLabel.TextSize = 14
infoLabel.Font = Enum.Font.GothamBold
infoLabel.Text = "🪨 ROCK SIMULATOR\n\nWASD - Move\nSPACE - Jump\nRight-Drag - Orbit\nScroll - Zoom\nR - Reset Camera"
infoLabel.TextWrapped = true
infoLabel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = infoLabel

print("✅ Rock Simulator Ready!")
