# In progress

- goblins

# Bugs

- adding tons of bases at once makes dwarves go diagonal
    - condition:
        - reproducible on 329b3b5, f32fdea, 2d6a86c
        - got a case where a dwarf was on {33088.0, 31296.0}, target tile id was 2001932, which has a position of {33120, 31264}.
        - I implemented pausing instead of crashing and it looks like, at least in this one case, a dwarf found a treaure cave and started pathing straight to a treasure that was diagonal to him.
        - when the dwarves' target tiles were being set, I believe sometimes they were a bit off axis before they started moving towards that new target tile. After instituting a fix for that, this issue has not recurred, but I'm not convinced I've fixed it for sure. I also think this fix has broken other things. Going to go to a previous commit to see if I can fix there too, before treasure spawns.
        - it did break other things, but I fixed that
    - cause:
    - correction:
    - confirmation:
- flowing liquid can cause actively mined tiles to disappear and crashes game
    - condition: reproducible on c43b3f5
    - cause:
    - correction:
    - confirmation:
- zooming out really far makes dwarves jiggle in place
    - condition: reproducible on dee71bc
    - cause:
    - correction:
    - confirmation:

# Core

- losing
- fullscreen and resizability
- speed up time button
- temporarily pause time button
- base canons
- base spawn diggers
- base spawn warriors
- bases cannot be placed down on caves

- mined tile sprites

# Performance

- Just use math to get neighboring tile ids
- underclock cpu
- Use ids for stuff, not positions

# Nitpicks

- Dwarves should move into the tiles they just mined before pathing to other resource tiles

# Refactor

- Refactor dwarf decisions into actual state
- Function to tell if a tile is moveable or not
- hotreloading
