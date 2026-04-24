# In progress

# Bugs

- flowing liquid can cause actively mined tiles to disappear and crashes game
    - condition: reproducible on c43b3f5
    - cause:
    - correction:
    - confirmation:
- adding tons of bases at once makes dwarves go diagonal
    - condition: reproducible on 329b3b5, f32fdea
    - cause:
    - correction:
    - confirmation:

# Core

- goblins
- losing
- fullscreen and resizability
- speed up time button
- temporarily pause time button
- base canons
- base spawn diggers
- base spawn warriors
- bases cannot be placed down on caves

# Performance

- Just use math to get neighboring tile ids
- underclock cpu
- Use ids for stuff, not positions

# Nitpicks

- Dwarves should move into the tiles they just mined before pathing to other resource tiles

# Refactor

- Function to tell if a tile is moveable or not
- hotreloading
