-- Rock Simulator Server
-- Main server script that manages player rocks and world events

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- DataStore setup (only works on published games, not in Studio)
local RockDataStore = nil
local useDataStore = false
if game:GetService("RunService"):IsStudio() then
    -- Studio mode - DataStore disabled for testing
    print("Running in Studio - DataStore disabled for testing")
else
    -- Published game - enable DataStore
    local DataStoreService = game:GetService("DataStoreService")
    RockDataStore = DataStoreService:GetDataStore("RockSimulatorData")
    useDataStore = true
end

-- Load AnimalSystem module
local AnimalSystem = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AnimalSystem"))

-- Player rocks storage
local playerRocks = {}

-- Rock configuration
local RockConfig = {
    ROCK_SIZE = Vector3.new(4, 3, 4),
    ROCK_MATERIAL = Enum.Material.Rock,
    ROCK_COLOR = Color3.fromRGB(105, 105, 105),
    CAMERA_OFFSET = Vector3.new(0, 5, 8),
    SPAWN_POSITIONS = {
        Vector3.new(0, 1.5, 0),      -- Sitting on ground (size.Y/2 = 1.5)
        Vector3.new(10, 1.5, 10),
        Vector3.new(-10, 1.5, 10),
        Vector3.new(10, 1.5, -10),
        Vector3.new(-10, 1.5, -10)
    }
}

-- Create a rock for a player
local function createPlayerRock(player)
    local rock = Instance.new("Part")
    rock.Name = "PlayerRock_" .. player.Name
    rock.Size = RockConfig.ROCK_SIZE
    rock.Material = RockConfig.ROCK_MATERIAL
    rock.Color = RockConfig.ROCK_COLOR
    rock.Shape = Enum.PartType.Block
    rock.Anchored = true
    rock.CanCollide = true
    
    -- Choose a random spawn position
    local spawnIndex = math.random(1, #RockConfig.SPAWN_POSITIONS)
    rock.Position = RockConfig.SPAWN_POSITIONS[spawnIndex]
    
    -- Add some texture variation
    rock.TopSurface = Enum.SurfaceType.Smooth
    rock.BottomSurface = Enum.SurfaceType.Smooth
    
    -- Add a subtle mesh for more rock-like appearance
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Sphere
    mesh.Scale = Vector3.new(1.2, 0.8, 1.1)
    mesh.Parent = rock
    
    -- Add a name tag above the rock
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = rock
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name .. " the Rock"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 18
    nameLabel.Parent = billboard
    
    -- Parent to workspace
    rock.Parent = Workspace
    
    -- Store rock data
    playerRocks[player] = {
        rockPart = rock,
        spawnTime = tick(),
        stats = {
            TimeExisted = 0,
            EventsWitnessed = 0,
            WeatherChanges = 0,
            VisitorsMetamorphosed = 0
        }
    }
    
    return rock
end

-- Remove a player's rock
local function removePlayerRock(player)
    local rockData = playerRocks[player]
    if rockData and rockData.rockPart then
        rockData.rockPart:Destroy()
    end
    playerRocks[player] = nil
end

-- When a player joins
Players.PlayerAdded:Connect(function(player)
    -- Wait for character to load
    local character = player.Character or player.CharacterAdded:Wait()
    
    -- Hide the character by moving it far away and anchoring it
    if character:FindFirstChild("HumanoidRootPart") then
        character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(0, -500, 0)
        character:FindFirstChild("HumanoidRootPart").Anchored = true
    end
    
    -- Make the humanoid invisible and invulnerable
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    end
    
    -- Hide all character parts
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Transparency = 1
        end
    end
    
    -- Create their rock
    createPlayerRock(player)
    
    print(player.Name .. " has become a rock!")
end)

-- Simple data saving function
local function savePlayerData(player, rockStats)
    if not rockStats or not useDataStore then return end
    
    local success = pcall(function()
        local dataToSave = {
            totalTimeAsRock = rockStats.TimeExisted or 0,
            totalEventsWitnessed = rockStats.EventsWitnessed or 0,
            totalWeatherChanges = rockStats.WeatherChanges or 0,
            totalVisitors = rockStats.VisitorsMetamorphosed or 0,
            lastPlayTime = tick()
        }
        if RockDataStore then
            RockDataStore:SetAsync(player.UserId, dataToSave)
        end
    end)
    
    if success then
        print("Saved data for " .. player.Name .. " the Rock")
    else
        warn("Failed to save data for " .. player.Name)
    end
end

-- When a player leaves
Players.PlayerRemoving:Connect(function(player)
    local rockData = playerRocks[player]
    if rockData then
        -- Save their rock stats before they leave
        savePlayerData(player, rockData.stats)
    end
    
    removePlayerRock(player)
    print(player.Name .. " is no longer a rock. Their journey has been saved.")
end)

-- Environmental events system
local function createRandomEvent()
    -- Weather change events
    if math.random() < 0.3 then
        local eventType = math.random(1, 3)
        
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
            
            print("Fog rolls in... Visibility: " .. newFogEnd)
            
        elseif eventType == 2 then
            -- Time of day change
            local newTimeOfDay = math.random(6, 18) -- 6 AM to 6 PM
            local timeString = newTimeOfDay .. ":00:00"
            
            local timeTween = TweenService:Create(
                Lighting,
                TweenInfo.new(10, Enum.EasingStyle.Sine),
                {TimeOfDay = timeString}
            )
            timeTween:Play()
            
            print("Time shifts to " .. timeString)
            
        elseif eventType == 3 then
            -- Wind effect (move any loose objects)
            local wind = Instance.new("Part")
            wind.Name = "WindEffect"
            wind.Transparency = 1
            wind.CanCollide = false
            wind.Anchored = true
            wind.Size = Vector3.new(100, 50, 100)
            wind.Position = Vector3.new(0, 25, 0)
            wind.Parent = Workspace
            
            -- Add particle effect for wind
            local attachment = Instance.new("Attachment")
            attachment.Parent = wind
            
            local particles = Instance.new("ParticleEmitter")
            particles.Texture = "rbxasset://textures/particles/smoke_main.dds"
            particles.Lifetime = NumberRange.new(2, 4)
            particles.Rate = 50
            particles.SpreadAngle = Vector2.new(45, 45)
            particles.Speed = NumberRange.new(5, 10)
            particles.Color = ColorSequence.new(Color3.fromRGB(200, 200, 200))
            particles.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0.8),
                NumberSequenceKeypoint.new(1, 1)
            }
            particles.Parent = attachment
            
            -- Remove after a while
            game:GetService("Debris"):AddItem(wind, 15)
            
            print("A strong wind blows through the area...")
        end
        
        -- Notify all rocks they witnessed a weather change
        for player, rockData in pairs(playerRocks) do
            rockData.stats.WeatherChanges = rockData.stats.WeatherChanges + 1
            rockData.stats.EventsWitnessed = rockData.stats.EventsWitnessed + 1
        end
    end
    
    -- Spawn wandering creatures with interactions
    if math.random() < 0.4 then
        -- Use the new AnimalSystem for interactive creatures
        for player, rockData in pairs(playerRocks) do
            if rockData and rockData.rockPart then
                AnimalSystem.spawnCreature(rockData.rockPart.Position)
                
                -- Notify rocks they witnessed a visitor
                rockData.stats.VisitorsMetamorphosed = rockData.stats.VisitorsMetamorphosed + 1
                rockData.stats.EventsWitnessed = rockData.stats.EventsWitnessed + 1
            end
        end
        
        print("A creature is drawn by your rock's presence...")
    end
    
    -- Rare mystical events
    if math.random() < 0.1 then
        local mysticalEvents = {
            "rainbow", "shooting_star", "aurora", "glowing_mushroom"
        }
        
        local eventType = mysticalEvents[math.random(1, #mysticalEvents)]
        
        if eventType == "rainbow" then
            -- Create a rainbow effect
            local rainbow = Instance.new("Part")
            rainbow.Name = "Rainbow"
            rainbow.Size = Vector3.new(50, 1, 1)
            rainbow.Material = Enum.Material.ForceField
            rainbow.Color = Color3.fromRGB(255, 0, 0)
            rainbow.Anchored = true
            rainbow.CanCollide = false
            rainbow.Position = Vector3.new(0, 30, -30)
            rainbow.Parent = Workspace
            
            -- Animate rainbow colors
            spawn(function()
                local colors = {
                    Color3.fromRGB(255, 0, 0),    -- Red
                    Color3.fromRGB(255, 127, 0),  -- Orange  
                    Color3.fromRGB(255, 255, 0),  -- Yellow
                    Color3.fromRGB(0, 255, 0),    -- Green
                    Color3.fromRGB(0, 0, 255),    -- Blue
                    Color3.fromRGB(75, 0, 130),   -- Indigo
                    Color3.fromRGB(148, 0, 211)   -- Violet
                }
                
                for i = 1, 30 do -- 30 seconds of rainbow
                    if rainbow.Parent then
                        rainbow.Color = colors[math.random(1, #colors)]
                        wait(1)
                    end
                end
            end)
            
            game:GetService("Debris"):AddItem(rainbow, 30)
            
            print("A magical rainbow appears in the sky!")
            
        elseif eventType == "glowing_mushroom" then
            -- Spawn a glowing mushroom
            local mushroom = Instance.new("Part")
            mushroom.Name = "GlowingMushroom"
            mushroom.Size = Vector3.new(3, 4, 3)
            mushroom.Material = Enum.Material.Neon
            mushroom.Color = Color3.fromRGB(0, 255, 127)
            mushroom.Shape = Enum.PartType.Cylinder
            mushroom.Anchored = true
            mushroom.Position = Vector3.new(math.random(-20, 20), 2, math.random(-20, 20))
            mushroom.Parent = Workspace
            
            -- Add pulsing glow
            local pointLight = Instance.new("PointLight")
            pointLight.Brightness = 2
            pointLight.Color = Color3.fromRGB(0, 255, 127)
            pointLight.Range = 15
            pointLight.Parent = mushroom
            
            -- Pulsing effect
            spawn(function()
                while mushroom.Parent do
                    local tween = TweenService:Create(
                        pointLight,
                        TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                        {Brightness = 0.5}
                    )
                    tween:Play()
                    wait(2)
                end
            end)
            
            game:GetService("Debris"):AddItem(mushroom, 120) -- Lasts 2 minutes
            
            print("A mystical glowing mushroom sprouts from the earth!")
        end
        
        -- Extra event points for mystical events
        for player, rockData in pairs(playerRocks) do
            rockData.stats.EventsWitnessed = rockData.stats.EventsWitnessed + 5 -- Bonus for rare events
        end
    end
end

-- Start the environmental events loop
spawn(function()
    while true do
        wait(math.random(10, 30)) -- Random intervals between 10-30 seconds
        createRandomEvent()
    end
end)

-- Creature spawn loop - spawns creatures more frequently for interaction
spawn(function()
    while true do
        wait(math.random(8, 20)) -- Creatures spawn frequently
        
        for player, rockData in pairs(playerRocks) do
            if rockData and rockData.rockPart then
                -- Randomly spawn a creature near the rock
                if math.random() < 0.6 then
                    AnimalSystem.spawnCreature(rockData.rockPart.Position)
                end
            end
        end
    end
end)

-- Update rock stats periodically
spawn(function()
    while true do
        wait(1) -- Update every second
        
        for player, rockData in pairs(playerRocks) do
            if rockData then
                rockData.stats.TimeExisted = tick() - rockData.spawnTime
            end
        end
    end
end)

print("Rock Simulator Server initialized! 🪨")
