# In progress

- encasement

# Bugs

- dwarves seem to spawn on cursor when dragging near or on another dwarf
    - condition: reproducible on 8e9702b, a9f528e
    - cause:
    - correction:
    - confirmation:
- flowing liquid can cause actively mined tiles to disappear and crashes game
    - condition: reproducible on c43b3f5
    - cause:
    - correction:
    - confirmation:
- revealing caves of one tile doesn't do anything
    - condition: reproducible on a9f528e
    - cause:
    - correction:
    - confirmation:
- dwarves can mine still water
    - condition: reproducible on 6c2bb4d
    - cause:
    - correction:
    - confirmation:
- obsidian can be placed in encasement
    - condition: reproducible on 6c2bb4d
    - cause:
    - correction:
    - confirmation:

# Core

- dynamite
- hole tiles
- gold and points trackers
- fullscreen and resizability
- goblins
- losing

# Performance

- Big encasements tank fps
- Add dwarves and bases to chunks
- Liquid kills could be optimized by checking chunks
- Just use math to get neighboring tile ids
- underclock cpu
- Use ids for stuff, not positions

# Nitpicks

- Dwarves should move into the tiles they just mined before pathing to other resource tiles

# Refactor

- Function to tell if a tile is moveable or not
- hotreloading
- Extract flood fill as util
