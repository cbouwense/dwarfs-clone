# In progress

# Game

- points tracker

# Bugs

- dwarves can go diagonal while harvesting
    - reproducible on 8f940f1
    - cause:
    - correction:
    - confirmation:
- dwarves seem to teleport to cursor when dragging near or on another dwarf
    - reproducible on 8e9702b
    - cause:
    - correction:
    - confirmation:
- flowing liquid can cause actively mined tiles to disappear and crashes game
    - reproducible on c43b3f5
    - cause:
    - correction:
    - confirmation:

# Tech

- Add dwarves and bases to chunks
- Liquid kills could be optimized by checking chunks
- Function to tell if a tile is moveable or not
- Just use math to get neighboring tile ids
- deprecate set_tile_as_mined to just a wrapper for set_tile_as_type
- fullscreen and resizability
- underclock cpu
- hotreloading

# Done

