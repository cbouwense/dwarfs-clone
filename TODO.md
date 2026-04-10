# In progress

- dwarves can go diagonal while harvesting
    - condition:
        - reproducible on 8f940f1, 88432a1
        - I think it happens when trying to path to either the east or north east in a resource.
        - adding the dwarf pos as the start pos on the path seems to fix it.
        - there seems to be a bit of a stutter step when adding this start pos. It's like the dwarf was in the resource it was mining, and we have to move it back.
        - I'm thinking now that my assert was simply tripping because it was checking positions.
        - Removing the assert and start pos does make it happen again, so it does seem to be caused by the dwarf being slightly within the tile it's mining. I don't think it should be going into the tile it's mining anyways, so let me try to fix that.
        - When a dwarf is on a path, if there is a mineable tile in between it and its target, it will slightly overlap the mineable tile before starting to mine it. This doesn't happen during normal wandering around because there the target is always the next tile over. In such a case, the dwarf was just teleported to its previous target, and therefore no drift occurs. So the problem lies with the way in which we detect whether the next tile in our path has to be mined or not.
        - I've now changed the detection system from a probe to actually doing collision detection, and they're getting hung up halfway through the block they're going through,
        - I'm beginning to think that perhaps I just need to add all of the tile ids on their path and call it a day?
    - cause:
        - 
    - correction:
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
- putting an arrow right up against a resource softlocks the dwarf
    - condition:
        - reproducible on 88432a1
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

# Done

