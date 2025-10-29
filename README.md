# 🪨 Rock Simulator Roblox

**A zen-like meditation game where you experience life as a rock.**

## What is Rock Simulator?

Rock Simulator is a unique, contemplative experience where players become a rock and observe the world around them. It's a game about patience, observation, and finding peace in stillness.

## Features

### 🪨 **Core Rock Experience**
- Spawn as a unique rock with your player name
- Immersive rock-eye camera view
- Zen-like UI with philosophical messages
- Persistent rock statistics tracking

### 🌍 **Living World**
- **Weather Events**: Dynamic fog, lighting, and time changes
- **Wildlife & Animal Interactions**: Animals detect and react to your rock!
  - **Butterflies**: Circle and investigate curiously
  - **Birds**: Approach cautiously, can land on your rock
  - **Rabbits**: Quick and skittish, run around excitedly
  - **Deer**: Careful approach and slow investigation
  - **Foxes**: Investigative with glowing effects
- **Mystical Events**: Rainbows, glowing mushrooms, and magical phenomena
- **Wind Effects**: Particle systems and environmental atmosphere

### 📊 **Rock Statistics**
- **Time Existed**: How long you've been a rock
- **Events Witnessed**: Total phenomena observed
- **Weather Changes**: Atmospheric events experienced  
- **Visitors Met**: Creatures that passed by your rock

### 🏆 **Milestones & Personality**
- **Achievements**: Unlock titles like "Ancient Presence" and "Storm Watcher"
- **Rock Personality**: Develop traits (Stoic, Observant, Social, Ancient)
- **Favorite Times**: The game learns your preferred play hours
- **Persistent Progress**: Your rock journey is saved across sessions

### 🎮 **Gameplay Elements**
- **Passive Observation**: Watch the world change around you
- **Random Events**: Weather, creatures, and mystical phenomena
- **Social Rocks**: See other players as rocks nearby
- **Ambient Atmosphere**: Environmental sounds and lighting

## How to Play

1. **Join the game** - You'll automatically become a rock
2. **Observe** - Watch events unfold around you
3. **Exist** - Simply be present and mindful
4. **Accumulate Wisdom** - Gain statistics through patience
5. **Unlock Milestones** - Achieve rock enlightenment over time

## Philosophy

> *"You are a rock. Be still. Observe. Exist."*

Rock Simulator is inspired by:
- **Mindfulness meditation**
- **Environmental observation** 
- **Patience as a virtue**
- **Finding beauty in simplicity**
- **The zen of being present**

## Technical Features

### 🔧 **Built With**
- **Roblox Studio & Luau**
- **TweenService** for smooth animations
- **DataStore** for persistent progress
- **Particle Systems** for environmental effects
- **Dynamic Lighting** for atmospheric changes

### 📁 **Project Structure**
```
src/
├── client/           # Camera, UI, client-side experience
├── server/           # Rock management, world events, data saving
└── shared/           # Rock configurations, data management
```

## Events You Might Witness

### 🌤️ **Weather Phenomena**
- Fog rolling in and out
- Dramatic lighting changes
- Time-of-day transitions
- Wind with particle effects

### 🦋 **Creatures & Interactions** (Now with AI!)
- **Butterflies 🦋**: Curious and drawn to your rock - they circle and investigate closely with glowing effects
- **Birds 🐦**: Cautious approach - they orbit your rock and may land on top of you
- **Rabbits 🐰**: Skittish and energetic - they approach quickly then run around excitedly
- **Deer 🦌**: Careful and graceful - slow investigation and maintain respectful distance
- **Foxes 🦊**: Investigative and intelligent - slow orbits with glowing presence

**Creature Behaviors:**
- Each creature type has unique approach patterns
- Animals can detect your rock from distance and investigate
- Some creatures land on you, others circle or sniff
- Creatures spend 45-70 seconds interacting before moving on
- Multiple creatures can interact with you simultaneously

### ✨ **Mystical Events** (Rare)
- **Rainbows** appearing in the sky
- **Glowing Mushrooms** sprouting nearby
- **Auroras** and celestial phenomena
- **Shooting Stars** (future feature)

## Rock Personalities

Your rock develops personality based on your behavior:

- **🗿 Stoic**: The patient, unmovable observer
- **👁️ Observant**: Witnesses many events per hour
- **🤝 Social**: Attracts many visitors and creatures  
- **⏳ Ancient**: Has existed for extended periods

## Controls

- **Automatic**: The game plays itself - you just observe
- **R Key**: Reset camera position (optional)
- **Patience**: Your only required skill

## Milestones

- **Hour of Stone**: Exist for 1 hour
- **Day of Contemplation**: Exist for 24 hours  
- **Keen Observer**: Witness 100 events
- **Storm Watcher**: Experience 50 weather changes
- **Social Stone**: Meet 200 visitors
- **Ancient Presence**: Exist for 1 week total

## Installation & Setup

1. Open in Roblox Studio
2. Ensure `FilteringEnabled` is true
3. Publish and run in-game
4. Players will automatically become rocks upon joining

## Future Features

- Seasonal changes
- More creature types
- Rock evolution system
- Meditation achievements
- Environmental storytelling
- Sound effects and ambient music

---

*Created with love for those who appreciate the simple joy of just... being.*

**"What dreams may come to those who cannot sleep?"** 🪨
Generated by [Rojo](https://github.com/rojo-rbx/rojo) 7.6.0.

## Getting Started
To build the place from scratch, use:

```bash
rojo build -o "Rock-Simulator-Roblox.rbxlx"
```

Next, open `Rock-Simulator-Roblox.rbxlx` in Roblox Studio and start the Rojo server:

```bash
rojo serve
```

For more help, check out [the Rojo documentation](https://rojo.space/docs).