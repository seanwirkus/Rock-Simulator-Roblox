local RockConfig = require(script.Parent.RockConfig)

local Rock = {}
Rock.__index = Rock

function Rock.new(player)
    local self = setmetatable({}, Rock)
    
    self.player = player
    self.rockPart = nil
    self.spawnPosition = Vector3.new(0, 10, 0) -- Default spawn position
    self.stats = {
        TimeExisted = 0,
        EventsWitnessed = 0,
        WeatherChanges = 0,
        VisitorsMetamorphosed = 0
    }
    self.startTime = tick()
    
    return self
end

function Rock:CreateRockModel()
    -- Create the main rock part
    local rock = Instance.new("Part")
    rock.Name = "PlayerRock_" .. self.player.Name
    rock.Size = Vector3.new(unpack(RockConfig.ROCK_SIZE))
    rock.Material = Enum.Material[RockConfig.ROCK_MATERIAL]
    rock.Color = Color3.fromRGB(unpack(RockConfig.ROCK_COLOR))
    rock.Shape = Enum.PartType[RockConfig.ROCK_SHAPE]
    rock.Anchored = RockConfig.ROCK_ANCHORED
    rock.CanCollide = RockConfig.ROCK_CAN_COLLIDE
    rock.Position = self.spawnPosition
    
    -- Add some texture variation
    rock.TopSurface = Enum.SurfaceType.Smooth
    rock.BottomSurface = Enum.SurfaceType.Smooth
    
    -- Add a subtle mesh for more rock-like appearance
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Sphere
    mesh.Scale = Vector3.new(1.2, 0.8, 1.1) -- Slightly irregular
    mesh.Parent = rock
    
    -- Add a name tag above the rock
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = rock
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = self.player.Name .. " the Rock"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 18
    nameLabel.Parent = billboard
    
    self.rockPart = rock
    return rock
end

function Rock:GetPosition()
    if self.rockPart then
        return self.rockPart.Position
    end
    return self.spawnPosition
end

function Rock:UpdateStats()
    self.stats.TimeExisted = tick() - self.startTime
end

function Rock:WitnessEvent(eventType)
    self.stats.EventsWitnessed = self.stats.EventsWitnessed + 1
    
    if eventType == "weather" then
        self.stats.WeatherChanges = self.stats.WeatherChanges + 1
    elseif eventType == "visitor" then
        self.stats.VisitorsMetamorphosed = self.stats.VisitorsMetamorphosed + 1
    end
end

function Rock:GetStats()
    self:UpdateStats()
    return self.stats
end

function Rock:Destroy()
    if self.rockPart then
        self.rockPart:Destroy()
        self.rockPart = nil
    end
end

return Rock