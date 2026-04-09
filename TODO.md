# In progress

- water behavior
- lava behavior

# Game

- paths on the ground should affect dwarves
- points tracker

# Bugs

- paths have an arrow at the end
    - reproducible on 8e9702b
    - cause:
    - correction:
    - confirmation:
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

# Tech

- Function to tell if a tile is moveable or not
- Just use math to get neighboring tile ids
- deprecate set_tile_as_mined to just a wrapper for set_tile_as_type
- fullscreen and resizability
- underclock cpu
- hotreloading
