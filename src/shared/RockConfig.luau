local RockConfig = {}

-- Rock appearance settings
RockConfig.ROCK_SIZE = {4, 3, 4} -- Rock dimensions (x, y, z)
RockConfig.ROCK_MATERIAL = "Rock"
RockConfig.ROCK_COLOR = {105, 105, 105} -- Dark gray RGB
RockConfig.ROCK_SHAPE = "Block"

-- Rock physics settings
RockConfig.ROCK_ANCHORED = true
RockConfig.ROCK_CAN_COLLIDE = true
RockConfig.ROCK_MASS = 1000 -- Heavy rock!

-- Camera settings
RockConfig.CAMERA_OFFSET = {0, 5, 8} -- Slightly elevated view (x, y, z)
RockConfig.CAMERA_ANGLE = -15 -- Looking down slightly

-- Stats tracking
RockConfig.STATS = {
    TimeExisted = 0,
    EventsWitnessed = 0,
    WeatherChanges = 0,
    VisitorsMetamorphosed = 0 -- NPCs that walked by
}

return RockConfig