# In progress

- Placing obsidian

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

# Game core

- points tracker

# Game nitpicks

- Dwarves should move into the tiles they just mined before pathing to other resource tiles

# Performance

- Add dwarves and bases to chunks
- Liquid kills could be optimized by checking chunks
- Just use math to get neighboring tile ids
- underclock cpu
- Use id math to pathing, not positions

# Refactor

- Function to tell if a tile is moveable or not
- deprecate set_tile_as_mined to just a wrapper for set_tile_as_type
- fullscreen and resizability
- hotreloading