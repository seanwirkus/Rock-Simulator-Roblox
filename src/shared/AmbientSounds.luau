-- Ambient Sound Manager for Rock Simulator
-- Handles environmental sounds and atmosphere

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local AmbientSounds = {}

-- Sound configuration
local SOUNDS = {
    wind = {
        id = "rbxasset://sounds/wind.mp3", -- You'd replace with actual sound IDs
        volume = 0.3,
        looped = true
    },
    birds = {
        id = "rbxasset://sounds/birds.mp3",
        volume = 0.2,
        looped = true
    },
    rain = {
        id = "rbxasset://sounds/rain.mp3", 
        volume = 0.4,
        looped = true
    },
    footsteps = {
        id = "rbxasset://sounds/footsteps.mp3",
        volume = 0.3,
        looped = false
    }
}

-- Initialize ambient sounds
function AmbientSounds.init()
    -- Create sound objects
    for soundName, config in pairs(SOUNDS) do
        local sound = Instance.new("Sound")
        sound.Name = soundName .. "Sound"
        sound.SoundId = config.id
        sound.Volume = config.volume
        sound.Looped = config.looped
        sound.Parent = SoundService
        
        SOUNDS[soundName].soundObject = sound
    end
    
    -- Start basic ambient sounds
    AmbientSounds.playWind()
    AmbientSounds.playBirds()
end

-- Play wind sounds
function AmbientSounds.playWind()
    local windSound = SOUNDS.wind.soundObject
    if windSound then
        windSound:Play()
    end
end

-- Play bird sounds
function AmbientSounds.playBirds()
    local birdSound = SOUNDS.birds.soundObject
    if birdSound then
        birdSound:Play()
    end
end

-- Play rain (for weather events)
function AmbientSounds.playRain()
    local rainSound = SOUNDS.rain.soundObject
    if rainSound then
        rainSound:Play()
        
        -- Fade out other sounds
        TweenService:Create(SOUNDS.wind.soundObject, TweenInfo.new(2), {Volume = 0.1}):Play()
        TweenService:Create(SOUNDS.birds.soundObject, TweenInfo.new(2), {Volume = 0.05}):Play()
    end
end

-- Stop rain
function AmbientSounds.stopRain()
    local rainSound = SOUNDS.rain.soundObject
    if rainSound then
        rainSound:Stop()
        
        -- Restore other sounds
        TweenService:Create(SOUNDS.wind.soundObject, TweenInfo.new(2), {Volume = SOUNDS.wind.volume}):Play()
        TweenService:Create(SOUNDS.birds.soundObject, TweenInfo.new(2), {Volume = SOUNDS.birds.volume}):Play()
    end
end

-- Play footsteps (when NPCs walk by)
function AmbientSounds.playFootsteps()
    local footstepsSound = SOUNDS.footsteps.soundObject
    if footstepsSound then
        footstepsSound:Play()
    end
end

-- Fade all sounds for dramatic effect
function AmbientSounds.fadeAll(duration, targetVolume)
    duration = duration or 3
    targetVolume = targetVolume or 0
    
    for soundName, config in pairs(SOUNDS) do
        if config.soundObject then
            TweenService:Create(config.soundObject, TweenInfo.new(duration), {Volume = targetVolume}):Play()
        end
    end
end

-- Restore all sounds
function AmbientSounds.restoreAll(duration)
    duration = duration or 3
    
    for soundName, config in pairs(SOUNDS) do
        if config.soundObject then
            TweenService:Create(config.soundObject, TweenInfo.new(duration), {Volume = config.volume}):Play()
        end
    end
end

return AmbientSounds