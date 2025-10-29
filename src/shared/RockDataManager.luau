-- Rock Data Manager
-- Handles saving and loading player rock statistics

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local RockDataStore = DataStoreService:GetDataStore("RockSimulatorData")

local RockDataManager = {}

-- Default data structure
local defaultData = {
    totalTimeAsRock = 0,
    totalEventsWitnessed = 0,
    totalWeatherChanges = 0,
    totalVisitors = 0,
    rockPersonality = "Stoic", -- Could be: Stoic, Observant, Mysterious, Ancient
    favoriteTimeOfDay = "Sunset",
    milestonesUnlocked = {},
    lastPlayTime = 0
}

-- Load player data
function RockDataManager.loadPlayerData(player)
    local success, playerData = pcall(function()
        return RockDataStore:GetAsync(player.UserId)
    end)
    
    if success and playerData then
        -- Merge with defaults in case new fields were added
        for key, defaultValue in pairs(defaultData) do
            if playerData[key] == nil then
                playerData[key] = defaultValue
            end
        end
        return playerData
    else
        -- Return default data if load failed or player is new
        local newData = {}
        for key, value in pairs(defaultData) do
            newData[key] = value
        end
        return newData
    end
end

-- Save player data
function RockDataManager.savePlayerData(player, rockStats)
    if not rockStats then return end
    
    local playerData = RockDataManager.loadPlayerData(player)
    
    -- Update cumulative stats
    playerData.totalTimeAsRock = playerData.totalTimeAsRock + (rockStats.TimeExisted or 0)
    playerData.totalEventsWitnessed = playerData.totalEventsWitnessed + (rockStats.EventsWitnessed or 0)
    playerData.totalWeatherChanges = playerData.totalWeatherChanges + (rockStats.WeatherChanges or 0)
    playerData.totalVisitors = playerData.totalVisitors + (rockStats.VisitorsMetamorphosed or 0)
    playerData.lastPlayTime = tick()
    
    -- Check for milestones
    RockDataManager.checkMilestones(playerData)
    
    -- Determine rock personality based on behavior
    RockDataManager.updatePersonality(playerData)
    
    local success = pcall(function()
        RockDataStore:SetAsync(player.UserId, playerData)
    end)
    
    if success then
        print("Saved data for " .. player.Name .. " the Rock")
    else
        warn("Failed to save data for " .. player.Name)
    end
end

-- Check for milestone achievements
function RockDataManager.checkMilestones(playerData)
    local milestones = {
        {id = "first_hour", name = "Hour of Stone", requirement = 3600, stat = "totalTimeAsRock"},
        {id = "first_day", name = "Day of Contemplation", requirement = 86400, stat = "totalTimeAsRock"},
        {id = "witness_100", name = "Keen Observer", requirement = 100, stat = "totalEventsWitnessed"},
        {id = "weather_50", name = "Storm Watcher", requirement = 50, stat = "totalWeatherChanges"},
        {id = "social_rock", name = "Social Stone", requirement = 200, stat = "totalVisitors"},
        {id = "ancient_rock", name = "Ancient Presence", requirement = 604800, stat = "totalTimeAsRock"} -- 1 week
    }
    
    for _, milestone in ipairs(milestones) do
        if not playerData.milestonesUnlocked[milestone.id] and 
           playerData[milestone.stat] >= milestone.requirement then
            playerData.milestonesUnlocked[milestone.id] = {
                name = milestone.name,
                unlockedAt = tick()
            }
            print("🎉 " .. milestone.name .. " milestone unlocked!")
        end
    end
end

-- Update rock personality based on behavior
function RockDataManager.updatePersonality(playerData)
    local timeRatio = playerData.totalTimeAsRock
    local eventRatio = playerData.totalEventsWitnessed > 0 and playerData.totalEventsWitnessed / (playerData.totalTimeAsRock / 3600) or 0
    
    if timeRatio > 604800 then -- More than a week
        playerData.rockPersonality = "Ancient"
    elseif eventRatio > 10 then -- Witnesses many events per hour
        playerData.rockPersonality = "Observant"
    elseif playerData.totalVisitors > playerData.totalWeatherChanges * 2 then
        playerData.rockPersonality = "Social"
    else
        playerData.rockPersonality = "Stoic"
    end
    
    -- Determine favorite time based on when they play most
    local currentTime = tonumber(os.date("%H"))
    if currentTime >= 6 and currentTime < 12 then
        playerData.favoriteTimeOfDay = "Morning"
    elseif currentTime >= 12 and currentTime < 18 then
        playerData.favoriteTimeOfDay = "Afternoon"
    elseif currentTime >= 18 and currentTime < 22 then
        playerData.favoriteTimeOfDay = "Evening"
    else
        playerData.favoriteTimeOfDay = "Night"
    end
end

-- Get formatted stats for display
function RockDataManager.getFormattedStats(playerData)
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
    
    return {
        totalTime = formatTime(playerData.totalTimeAsRock),
        totalEvents = tostring(playerData.totalEventsWitnessed),
        totalWeather = tostring(playerData.totalWeatherChanges),
        totalVisitors = tostring(playerData.totalVisitors),
        personality = playerData.rockPersonality,
        favoriteTime = playerData.favoriteTimeOfDay,
        milestonesCount = #playerData.milestonesUnlocked
    }
end

return RockDataManager