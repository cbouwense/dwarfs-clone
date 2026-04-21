# In progress

- dwarves bounce between the end of a path and the middle arrow
    - condition:
        - reproducible on 714a893
        - doesn't seem immediately reproducible on 9062ef0
    - cause:
    - correction:
    - confirmation:

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
- adding tons of bases at once makes dwarves go diagonal
    - condition: reproducible on 329b3b5
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
