# In progress

- cave generation

# Game

- zoom out is too aggressive

# Bugs

- Dwarves can go diagonal sometimes
    - reproducible on bd697f8, when mining resources

- Seeing the edge of the world makes the game crash
    - reproducible on a8da110
    - it seems that when deriving entities to render, when getting chunks, there is an assumption that the coordinates will always be positive. If you see the negative edge of the world, though, this assumption is broken and a runtime assertion trips. 

# Tech

- fullscreen and resizability
- underclock cpu
- hotreloading
