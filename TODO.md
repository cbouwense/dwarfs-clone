# In progress

- dwarves and goblins can fail targeting and crash the game?
    - condition:
        - reproducible on d48ab20
        - seems to happen in straightaways
    - cause:
    - correction:
    - confirmation:

# Bugs

## Demo

- cannot move dwarfs out of combat manually
    - condition: reproducible on 279d68e
    - cause:
    - correction:
    - confirmation:


## After demo

- goblins do not wander around convincingly
    - condition: reproducible on 279d68e
    - cause:
    - correction:
    - confirmation:

# Core

## Demo

- HUD
- mouse icon for what mode you're in (wall, dynamite, etc)

## After demo

- dwarf level ups
- base canons
- base spawn diggers control
- base spawn warriors control
- options menu
    - apply changes
    - restore defaults
    - persist preferences
- main menu
- fullscreen and resizability
- bases cannot be placed down on caves
- dwarves and goblins should not pass through each other
- mined tile sprites
- shaman
- spider queen

# Performance

# Nitpicks

## Demo

- Saner defaults for controls

## After demo

- Paths should just be two single paths, not bends

# Miscellaneous

- search feature for tiles, dwarves, etc.
- hotreloading
- pos_by_id cache and vice versa?
