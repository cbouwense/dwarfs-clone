# In progress

- water flow / conversion to still is choppy
    - condition:
        - reproducible on 78db461, 8e0a223
        - it seems to either get hung up or happen in spurts
    - cause:
        - I'm ticking the cooldown for every water tile
    - correction:
        - Only do it once per frame
    - confirmation:

# Game

- points tracker

# Bugs

- dwarves seem to teleport to cursor when dragging near or on another dwarf
    - condition:
        - reproducible on 8e9702b
    - cause:
    - correction:
    - confirmation:
- flowing liquid can cause actively mined tiles to disappear and crashes game
    - condition:
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
- Use id math to pathing, not positions
