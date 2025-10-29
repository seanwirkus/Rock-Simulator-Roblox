-- Animal Interaction System
-- Creatures that detect and react to rocks

local CREATURE_TYPES = {
    {
        name = "Butterfly",
        size = Vector3.new(0.5, 0.5, 0.5),
        color = Color3.fromRGB(255, 200, 0),
        speed = 8,
        detectionRange = 30,
        behavior = "curious",
        lifetime = 45,
        sound = "butterfly"
    },
    {
        name = "Bird",
        size = Vector3.new(1, 1, 2),
        color = Color3.fromRGB(139, 69, 19),
        speed = 15,
        detectionRange = 50,
        behavior = "cautious",
        lifetime = 60,
        sound = "bird_chirp",
        canLand = true
    },
    {
        name = "Rabbit",
        size = Vector3.new(1.5, 1, 2),
        color = Color3.fromRGB(200, 180, 160),
        speed = 10,
        detectionRange = 40,
        behavior = "skittish",
        lifetime = 50,
        sound = "rabbit"
    },
    {
        name = "Deer",
        size = Vector3.new(2, 2.5, 4),
        color = Color3.fromRGB(139, 90, 43),
        speed = 12,
        detectionRange = 60,
        behavior = "cautious",
        lifetime = 70,
        sound = "deer"
    },
    {
        name = "Fox",
        size = Vector3.new(1.8, 1.5, 3),
        color = Color3.fromRGB(210, 105, 30),
        speed = 14,
        detectionRange = 55,
        behavior = "investigative",
        lifetime = 65,
        sound = "fox"
    }
}

local AnimalSystem = {}

-- Helper function to get position from rock (handles Models and Parts)
local function getRockPosition(rock)
    if rock:IsA("Model") then
        return rock:GetBoundingBox().Position
    else
        return rock.Position
    end
end

-- Create a creature that reacts to a rock
function AnimalSystem.spawnCreature(rockPosition)
    local creatureType = CREATURE_TYPES[math.random(1, #CREATURE_TYPES)]
    
    -- Random spawn location around the rock
    local spawnAngle = math.rad(math.random(0, 360))
    local spawnDistance = math.random(40, 80)
    local spawnX = rockPosition.X + math.cos(spawnAngle) * spawnDistance
    local spawnZ = rockPosition.Z + math.sin(spawnAngle) * spawnDistance
    
    local creature = Instance.new("Part")
    creature.Name = creatureType.name
    creature.Size = creatureType.size
    creature.Material = Enum.Material.Plastic
    creature.Color = creatureType.color
    creature.Shape = Enum.PartType.Block
    creature.CanCollide = true
    creature.Position = Vector3.new(spawnX, 5, spawnZ)
    creature.Parent = Workspace
    
    -- Store creature data
    creature:SetAttribute("CreatureType", creatureType.name)
    creature:SetAttribute("Behavior", creatureType.behavior)
    creature:SetAttribute("Speed", creatureType.speed)
    creature:SetAttribute("DetectionRange", creatureType.detectionRange)
    creature:SetAttribute("IsLanded", false)
    creature:SetAttribute("RockTarget", rockPosition)
    creature:SetAttribute("AwarenessLevel", 0) -- 0 = unaware, 1 = investigating, 2 = interacting
    
    -- Add humanoid for ragdoll effect on older behavior
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = creature
    
    -- Add velocity for movement
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = creature
    
    -- Add glow effect for some creatures
    if creatureType.name == "Butterfly" or creatureType.name == "Fox" then
        local pointLight = Instance.new("PointLight")
        pointLight.Brightness = 1
        pointLight.Range = 10
        if creatureType.name == "Butterfly" then
            pointLight.Color = Color3.fromRGB(255, 255, 100)
        else
            pointLight.Color = Color3.fromRGB(255, 150, 50)
        end
        pointLight.Parent = creature
    end
    
    -- Track awareness and interaction
    spawn(function()
        local timeAlive = 0
        while creature.Parent and timeAlive < creatureType.lifetime do
            timeAlive = timeAlive + 0.1
            
            local rockPos = creature:GetAttribute("RockTarget")
            if rockPos then
                local distance = (creature.Position - rockPos).Magnitude
                local detectionRange = creature:GetAttribute("DetectionRange")
                
                -- Creature becomes aware of rock if close enough
                if distance < detectionRange then
                    local awarenessLevel = creature:GetAttribute("AwarenessLevel")
                    
                    if awarenessLevel == 0 then
                        -- Just noticed the rock!
                        creature:SetAttribute("AwarenessLevel", 1)
                        
                        -- React based on behavior
                        local behavior = creature:GetAttribute("Behavior")
                        if behavior == "curious" then
                            -- Approach cautiously
                            AnimalSystem.approachRock(creature, rockPos, 0.5)
                        elseif behavior == "cautious" then
                            -- Hesitate then approach slowly
                            AnimalSystem.circleRock(creature, rockPos, 0.3)
                        elseif behavior == "skittish" then
                            -- Quick investigation
                            AnimalSystem.approachRock(creature, rockPos, 0.7)
                        elseif behavior == "investigative" then
                            -- Slow careful approach
                            AnimalSystem.approachRock(creature, rockPos, 0.4)
                        end
                    end
                    
                    -- Move based on behavior
                    if distance < 15 and creature:GetAttribute("AwarenessLevel") == 1 then
                        creature:SetAttribute("AwarenessLevel", 2)
                        
                        -- Different interactions at close range
                        local behavior = creature:GetAttribute("Behavior")
                        if behavior == "curious" then
                            AnimalSystem.sniffRock(creature, rockPos)
                        elseif behavior == "cautious" and creature:GetAttribute("IsLanded") == false then
                            AnimalSystem.landOnRock(creature, rockPos)
                        elseif behavior == "skittish" then
                            AnimalSystem.runAround(creature, rockPos)
                        elseif behavior == "investigative" then
                            AnimalSystem.inspectRock(creature, rockPos)
                        end
                    end
                    
                elseif creature:GetAttribute("AwarenessLevel") > 0 then
                    -- Rock is out of range, forget about it
                    creature:SetAttribute("AwarenessLevel", 0)
                end
            end
            
            wait(0.1)
        end
        
        -- Remove creature after lifetime expires
        if creature.Parent then
            creature:Destroy()
        end
    end)
    
    return creature
end

-- Creature approaches the rock
function AnimalSystem.approachRock(creature, rockPos, caution)
    local bodyVelocity = creature:FindFirstChild("BodyVelocity")
    if not bodyVelocity then return end
    
    -- Get the rock position (could be Model or Part)
    if typeof(rockPos) ~= "Vector3" then
        -- If rockPos is a Part or Model, get its position
        if rockPos:IsA("Model") then
            rockPos = rockPos:GetBoundingBox().Position
        else
            rockPos = rockPos.Position
        end
    end
    
    local direction = (rockPos - creature.Position).Unit
    local speed = creature:GetAttribute("Speed") * caution
    
    bodyVelocity.Velocity = direction * speed + Vector3.new(0, -0.5, 0) -- slight downward drift
end

-- Creature circles the rock
function AnimalSystem.circleRock(creature, rockPos, caution)
    local bodyVelocity = creature:FindFirstChild("BodyVelocity")
    if not bodyVelocity then return end
    
    local offset = (creature.Position - rockPos)
    local circleDir = Vector3.new(-offset.Z, 0, offset.X).Unit
    local distance = offset.Magnitude
    
    -- Maintain distance while circling
    local moveDir = circleDir
    if distance > 20 then
        moveDir = moveDir + (rockPos - creature.Position).Unit * 0.3
    end
    
    local speed = creature:GetAttribute("Speed") * caution * 0.7
    bodyVelocity.Velocity = moveDir * speed
end

-- Creature sniffs around the rock
function AnimalSystem.sniffRock(creature, rockPos)
    local bodyVelocity = creature:FindFirstChild("BodyVelocity")
    if not bodyVelocity then return end
    
    -- Slow movement, get close to rock
    local direction = (rockPos - creature.Position).Unit
    bodyVelocity.Velocity = direction * 3
end

-- Creature lands on the rock (for birds)
function AnimalSystem.landOnRock(creature, rockPos)
    local bodyVelocity = creature:FindFirstChild("BodyVelocity")
    if not bodyVelocity then return end
    
    creature:SetAttribute("IsLanded", true)
    
    -- Move to top of rock
    local landPos = rockPos + Vector3.new(math.random(-1, 1), 2.5, math.random(-1, 1))
    local direction = (landPos - creature.Position)
    
    if direction.Magnitude > 1 then
        bodyVelocity.Velocity = direction.Unit * 5
    else
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end
end

-- Creature runs around the rock excitedly
function AnimalSystem.runAround(creature, rockPos)
    local bodyVelocity = creature:FindFirstChild("BodyVelocity")
    if not bodyVelocity then return end
    
    local randomAngle = math.rad(math.random(0, 360))
    local randomDist = 12 + math.random(-3, 3)
    
    local targetX = rockPos.X + math.cos(randomAngle) * randomDist
    local targetZ = rockPos.Z + math.sin(randomAngle) * randomDist
    
    local direction = (Vector3.new(targetX, creature.Position.Y, targetZ) - creature.Position)
    bodyVelocity.Velocity = direction.Unit * creature:GetAttribute("Speed")
end

-- Creature inspects the rock closely
function AnimalSystem.inspectRock(creature, rockPos)
    local bodyVelocity = creature:FindFirstChild("BodyVelocity")
    if not bodyVelocity then return end
    
    -- Slow orbit around rock at very close range
    local offset = (creature.Position - rockPos)
    local distance = offset.Magnitude
    
    if distance > 8 then
        -- Move closer
        bodyVelocity.Velocity = (rockPos - creature.Position).Unit * 2
    else
        -- Orbit slowly
        local circleDir = Vector3.new(-offset.Z, 0, offset.X).Unit
        bodyVelocity.Velocity = circleDir * 2
    end
end

return AnimalSystem