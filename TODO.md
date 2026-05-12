# In progress

- dwarves can move into unmined tiles when gathering treasure
    - condition:
        - reproducible on c4b4832
        - it seems to happen after collecting a treasure that is next to a wall. dwarves end up with a lot of tile ids on their path, face the wrong direction, and move into unmined dirt.
        - the above might be something else entirely. this specific problem seems to be when a dwarf gets a treasure, paths to a next treasure, and the very next tile needs to be mined. at that point, it doesn't decide that it needs to mine the next tile.
    - cause: after picking up treasure, if the very next tile in their path was unmined, the dwarf would not go into the deciding state. Therefore, the dwarf would remain in the moving state and simply move into the unmined tile.
    - correction: after picking up treasure, the dwarf must go into deciding state
    - confirmation:

# Bugs

- cannot move dwarfs out of combat manually
    - condition: reproducible on 279d68e
    - cause:
    - correction:
    - confirmation:
- goblins do not wander around convincingly
    - condition: reproducible on 279d68e
    - cause:
    - correction:
    - confirmation:

# Core

- warriors
- options menu
    - apply changes
    - restore defaults
    - persist preferences
- main menu
- HUD
- fullscreen and resizability
- speed up time button
- temporarily pause time button
- base canons
- base spawn diggers control
- base spawn warriors control
- bases cannot be placed down on caves
- dwarves and goblins should not pass through each other
- mined tile sprites
- mouse icon for what mode you're in (wall, dynamite, etc)

# Performance

# Nitpicks

- Dwarves should move slower by default
- Paths should just be two single paths, not bends

# Miscellaneous

- search feature for tiles, dwarves, etc.
- hotreloading
