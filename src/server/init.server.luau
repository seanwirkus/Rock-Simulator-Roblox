-- Exploration Game Server
-- Players can move around freely and experience the world

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

print("Server initialized - Exploration mode active!")

local function cleanupOldRocks()
    for _, obj in pairs(Workspace:GetChildren()) do
        -- Only clean up old PlayerRock instances, NOT the RockPlayer template
        if obj.Name:match("^PlayerRock_") then
            obj:Destroy()
            print("Cleaned up old rock object: " .. obj.Name)
        end
    end
end

cleanupOldRocks()

-- Create a baseplate if it doesn't exist
local function ensureBaseplate()
    if not Workspace:FindFirstChild("Baseplate") then
        local baseplate = Instance.new("Part")
        baseplate.Name = "Baseplate"
        baseplate.Size = Vector3.new(512, 1, 512)
        baseplate.Position = Vector3.new(0, 0, 0)
        baseplate.Material = Enum.Material.Grass
        baseplate.Color = Color3.fromRGB(34, 139, 34)
        baseplate.CanCollide = true
        baseplate.Anchored = true
        baseplate.Parent = Workspace
        
        print("Created baseplate!")
    end
end

ensureBaseplate()

-- When a player joins, give them the RockPlayer model as their character
Players.PlayerAdded:Connect(function(player)
    print(player.Name .. " joined!")
    
    -- Wait for default character to load
    local character = player.Character or player.CharacterAdded:Wait()
    wait(0.1)
    
    -- Find the RockPlayer template
    local rockTemplate = Workspace:FindFirstChild("RockPlayer")
    
    if rockTemplate then
        -- Clone the RockPlayer model
        local newCharacter = rockTemplate:Clone()
        newCharacter.Name = player.Name
        
        -- Ensure it has a Humanoid
        if not newCharacter:FindFirstChild("Humanoid") then
            local humanoid = Instance.new("Humanoid")
            humanoid.Parent = newCharacter
        end
        
        -- Ensure it has a HumanoidRootPart for movement
        local rootPart = newCharacter:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            -- Look for any BasePart to use as root
            for _, part in pairs(newCharacter:FindFirstChildOfClass("BasePart") and {newCharacter:FindFirstChildOfClass("BasePart")} or newCharacter:GetDescendants()) do
                if part:IsA("BasePart") then
                    rootPart = part
                    rootPart.Name = "HumanoidRootPart"
                    break
                end
            end
        end
        
        -- Position it
        if rootPart then
            rootPart.CFrame = character:FindFirstChild("HumanoidRootPart").CFrame
        end
        
        newCharacter.Parent = Workspace
        
        -- Remove the old default character
        character:Destroy()
        
        -- Set the new character for the player
        player.Character = newCharacter
        
        print("Replaced " .. player.Name .. " with RockPlayer model!")
    else
        print("Warning: RockPlayer template not found in Workspace!")
    end
end)

-- When a player leaves
Players.PlayerRemoving:Connect(function(player)
    print(player.Name .. " left the game.")
end)

-- Environmental events system
local function createRandomEvent()
    if math.random() < 0.3 then
        local eventType = math.random(1, 2)
        
        if eventType == 1 then
            -- Fog change
            local newFogEnd = math.random(50, 200)
            local newBrightness = math.random(1, 3)
            
            local fogTween = TweenService:Create(
                Lighting,
                TweenInfo.new(5, Enum.EasingStyle.Sine),
                {FogEnd = newFogEnd, Brightness = newBrightness}
            )
            fogTween:Play()
            print("Weather changing...")
            
        elseif eventType == 2 then
            -- Time of day change
            local newTimeOfDay = math.random(6, 18)
            local timeString = newTimeOfDay .. ":00:00"
            
            local timeTween = TweenService:Create(
                Lighting,
                TweenInfo.new(10, Enum.EasingStyle.Sine),
                {TimeOfDay = timeString}
            )
            timeTween:Play()
            print("Time shifts to " .. timeString)
        end
    end
end

-- Start environmental events
spawn(function()
    while true do
        wait(math.random(15, 30))
        createRandomEvent()
    end
end)

print("Game server ready!")

