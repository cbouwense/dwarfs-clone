# In progress



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
- treasure caves
- goblins
- losing
- fullscreen and resizability
- speed up time button
- temporarily pause time button

# Performance

- Just use math to get neighboring tile ids
- underclock cpu
- Use ids for stuff, not positions

# Nitpicks

- Dwarves should move into the tiles they just mined before pathing to other resource tiles

# Refactor

- Function to tell if a tile is moveable or not
- hotreloading
