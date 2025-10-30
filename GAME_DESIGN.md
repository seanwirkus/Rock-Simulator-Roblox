# Rock Simulator - Game Design & Implementation Plan

## Current Status: PLAYABLE PROTOTYPE ✓

### What's Working Now

#### Core Gameplay (✓ Implemented)
- **Free-roaming rock model** - Player controls a physics-enabled rock character
- **Directional jumping** - WASD + SPACE to jump with momentum and rolling physics
- **Full camera control** - Right-click drag to orbit around rock, scroll to zoom
- **Exploration-based movement** - No combat, just movement and exploration

#### World (✓ Implemented)
- **Procedurally generated terrain** - Hills, valleys, varied elevation
- **Water features** - Lake/pond area to explore
- **Cave systems** - Underground exploration
- **Decorative rocks** - Scattered obstacles and visual interest
- **512x512 base world** - Large enough for meaningful exploration

#### Progression Systems (✓ Framework Ready)
- **Rock evolution** - 5 stages from Fresh → Weathered → Mossy → Ancient → Mystical
- **Visual evolution** - Rock changes color, moss grows, gets glowing aura
- **Stats tracking** - Time played, jumps, creatures met, evolution stage
- **Modules created** - RockProgress.luau, RockVisuals.luau ready to integrate

---

## Next Steps to Make it AWESOME

### Phase 1: Polish & Feel (High Impact, Quick)
1. **Integrate progression into gameplay**
   - Call RockVisuals.applyEvolution() when stats update
   - Update UI to show current evolution stage
   
2. **Add collision feedback**
   - Rock lands → particle effect + sound
   - Different surfaces play different sounds
   
3. **Improve movement feel**
   - Add air drag/velocity decay
   - Boost jump power slightly (feels better)
   - Add landing animation

### Phase 2: World Building (Medium Impact, Medium Effort)
1. **Environmental storytelling**
   - Add ruins/ancient structures to discover
   - Create hidden caves with rewards
   - Add mysterious landmarks
   
2. **Biome variety**
   - Sandy desert area (different friction)
   - Frozen icy area (slippery)
   - Forest with trees to navigate
   
3. **Dynamic weather**
   - Rain increases friction
   - Wind pushes rock
   - Lightning storms for drama
   - Affect visibility/music mood

### Phase 3: Creature System (High Impact, High Fun)
1. **Reactivate AnimalSystem**
   - Use existing AnimalSystem.luau
   - Creatures react to rock passing
   - Some friendly, some hostile
   - Passive observation experience
   
2. **Creature types**
   - Birds that flee
   - Rabbits that watch
   - Mysterious spirits that appear
   
3. **Encounter rewards**
   - Meeting creatures adds XP
   - Some give special abilities

### Phase 4: Abilities & Goals (High Impact, High Retention)
1. **Special abilities earned through progression**
   - Super Jump (after 5min)
   - Rolling Dash (after 10min)
   - Time Slowdown (after 30min)
   
2. **Achievement system**
   - "Explorer" - visit all biomes
   - "Ancient One" - reach evolution 5
   - "Spirit Friend" - meet all creatures
   - "Marathon" - play 1 hour straight

### Phase 5: Audio & Atmosphere (Medium Impact, Big Feel)
1. **Ambient music**
   - Calm zen theme
   - Changes with weather/evolution
   
2. **Sound design**
   - Rock rolling on different surfaces
   - Creatures making sounds
   - Wind, rain, thunder
   
3. **Spatial audio**
   - Water sounds near water
   - Wind louder in open areas

### Phase 6: Persistence & Depth (Medium Impact, Long-term)
1. **Save system**
   - Rock state persists
   - Can play for multiple sessions
   - Stats tracked across time
   
2. **Long-term goals**
   - Become the ancient mystical rock
   - Meet every creature
   - Unlock all abilities
   - 100 hour club

---

## Technical Architecture

### Server Side (`src/server/init.server.luau`)
- Player spawn management
- Character template cloning
- Terrain generation
- Environmental events
- Physics simulation authority

### Client Side (`src/client/init.client.luau`)
- Camera control (Scriptable type)
- Player input handling
- Movement input tracking
- UI rendering
- Visual effects

### Shared Modules
- `RockProgress.luau` - Stats & progression tracking
- `RockVisuals.luau` - Visual evolution effects
- `AnimalSystem.luau` - Creature AI (ready to use)
- `RockConfig.luau` - Configuration values

### Models
- `RockPlayer` - The main rock character model (HumanoidRootPart + model)

---

## Recommended Play Order

1. **Test rolling physics** - Jump around, feel the momentum
2. **Explore the terrain** - Find water, caves, rocks
3. **Watch evolution** - Play for 5-10 minutes, see color change
4. **Check progression UI** - See stats updating (ready soon)
5. **Experience atmosphere** - Notice lighting/weather changes

---

## File Structure
```
src/
├── server/
│   └── init.server.luau (game logic, terrain, spawning)
├── client/
│   └── init.client.luau (camera, input, UI)
└── shared/
    ├── RockProgress.luau (stats tracking)
    ├── RockVisuals.luau (visual effects)
    ├── AnimalSystem.luau (creatures - ready)
    ├── RockConfig.luau (settings)
    └── RockDataManager.luau (persistence - ready)
```

---

## Quick Wins (Do These First!)

1. **Enable RockVisuals evolution** (5 min)
   - Import module in client
   - Call updateEvolution on tick
   
2. **Add rolling sound** (10 min)
   - Play sound on jump
   - Different surface = different sound
   
3. **Improve jump feel** (5 min)
   - Increase jump velocity from 18 to 22
   - Add jump success haptic/sound
   
4. **Update UI with stats** (15 min)
   - Show evolution stage
   - Show time played
   - Show jumps performed

---

## Vision Statement

**Rock Simulator is a zen exploration game where you are literally just a rock experiencing the world passing by.** It's not about combat or efficiency—it's about the peaceful journey of a stone rolling through varied landscapes, slowly gaining wisdom (moss, cracks, mystical glow) as time passes. Success is measured in experiences had, creatures met, and how far you've evolved—not in any single goal.

The game should feel like 10 Minutes of guided meditation with exploration.

---

Generated: October 29, 2025
Current Build Status: READY FOR TESTING ✓
