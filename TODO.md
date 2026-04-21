# In progress

- dwarves seem to spawn on cursor when dragging near or on another dwarf
    - condition:
        - reproducible on 8e9702b, a9f528e
        - it seems to be easier to reproduce the more dwarves there are
        - after a while it seems to almost happen every time you select a dwarf, but not 100%
        - it seems to actually teleport an existing dwarf, not create a new one
        - it looks like the ids are being incorrectly selected into the game state
        - changing the game state from an index to an id seems to have worked, need to confirm though
    - cause:
    - correction:
    - confirmation:

# Bugs

- flowing liquid can cause actively mined tiles to disappear and crashes game
    - condition: reproducible on c43b3f5
    - cause:
    - correction:
    - confirmation:
- adding tons of bases at once makes dwarves go diagonal
    - condition: reproducible on 329b3b5
    - cause:
    - correction:
    - confirmation:
- paths can be drawn with one segment
    - condition: reproducible on f232b3f
    - cause:
    - correction:
    - confirmation:

# Core

- gold and points trackers
- fullscreen and resizability
- goblins
- treasure caves
- losing
- speed up time button
- temporarily pause time button
- delete path arrows

# Performance

- Just use math to get neighboring tile ids
- underclock cpu
- Use ids for stuff, not positions

# Nitpicks

- Dwarves should move into the tiles they just mined before pathing to other resource tiles

# Refactor

- Function to tell if a tile is moveable or not
- hotreloading
