#import "Basic";
#import "Hash_Table";
#import "Input";
Math :: #import "Math";
#import "Print_Vars";
#import "Random";
#import "Sloppy_Math";
#import "Sort";
#import "String";
#import "System";

#import "raylib";

#load "constants.jai";
#load "utils.jai";
#load "raylib-utils.jai";
#load "controls.jai";
#load "sprites.jai";

window_width  := 1600;
window_height := 800;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////////////////////////

CAMERA_MOVE_SPEED_BASE :: 4;

DIRT_HEALTH :: 100;
IRON_HEALTH :: 200;

DWARF_START_COUNT :: 1;
DWARF_MOVE_SPEED :: 100;
DWARF_MINE_COOLDOWN_MS :: 250;
DWARF_MINE_DAMAGE_PER_SWING :: 50;
DWARF_SPAWN_MS :: 5000;

TILEMAP_GENERAL_MAP_WIDTH    :: 320;
TILEMAP_GENERAL_MAP_HEIGHT   :: 320;
TILEMAP_GENERAL_TILE_WIDTH   :: 32;
TILEMAP_GENERAL_TILE_HEIGHT  :: 32;
TILEMAP_GENERAL_WORLD_WIDTH  :: TILEMAP_GENERAL_TILE_WIDTH  * SCALE;
TILEMAP_GENERAL_WORLD_HEIGHT :: TILEMAP_GENERAL_TILE_HEIGHT * SCALE;

WORLD_COLS :: 2048;
WORLD_ROWS :: 2048;
WORLD_WIDTH  :: WORLD_COLS * TILEMAP_GENERAL_WORLD_WIDTH;
WORLD_HEIGHT :: WORLD_ROWS * TILEMAP_GENERAL_WORLD_HEIGHT;
WORLD_COLS_MASK :: WORLD_COLS - 1;
WORLD_ROWS_MASK :: WORLD_ROWS - 1;
WORLD_COLS_SHIFT :: #run integer_log2(WORLD_COLS);
TILE_WIDTH_F  :: cast(float32) TILEMAP_GENERAL_WORLD_WIDTH;
TILE_HEIGHT_F :: cast(float32) TILEMAP_GENERAL_WORLD_HEIGHT;

SCALE :: 1;

TRANSPARENT_WHITE :: Color.{ 255, 255, 255, 100 };

CHUNK_SIZE :: 32; // 32 x 32 tiles

WATER_FLOW_COOLDOWN_MS :: 1000;
LAVA_FLOW_COOLDOWN_MS  :: 2500;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Metagame state
////////////////////////////////////////////////////////////////////////////////////////////////////

should_quit_game := false;
paused           := false;
debug_mode       := false;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Textures
////////////////////////////////////////////////////////////////////////////////////////////////////

tilemap_texture_general : Texture;
dirt_texture            : Texture;

init_textures :: () {
    tilemap_texture_general = LoadTexture("data/tilemap-general.png");
    dirt_texture = LoadTexture("data/dirt.png");
    // The plan is just to just render a big-ass quad and tile the dirt over it.
    // At this point I'm not even sure why I'm insisting on doing it like this,
    // I guess because I feel like it should be possible to zoom way the fuck
    // out, but, yeah idk this might be stupid.
    SetTextureWrap(dirt_texture, .TEXTURE_WRAP_REPEAT);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Sprites
////////////////////////////////////////////////////////////////////////////////////////////////////

init_sprites :: () {

}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Controls
////////////////////////////////////////////////////////////////////////////////////////////////////

select_is_pressed_once  : bool;
select_is_held_down     : bool;
add_base                : bool;
add_iron                : bool;
add_as_dynamite         : bool;
add_as_obsidian         : bool;
started_to_create_path  : bool;
dragging_to_create_path : bool;
drag_cam_pressed        : bool;
drag_cam_down           : bool;
move_camera_up          : bool;
move_camera_down        : bool;
move_camera_left        : bool;
move_camera_right       : bool;

dragging_to_create_path_prev : bool;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Other
////////////////////////////////////////////////////////////////////////////////////////////////////

mouse_drag_began_at_pos : Vector2;
mouse_pos_when_path_creation_started : Vector2;

GameState :: struct {
    hovered_dwarf_index    : int;
    selected_dwarf_id      : s32;
    water_flow_cooldown_ms : int;
    lava_flow_cooldown_ms  : int;
}

Direction :: enum u8 #specified {
    NORTH      :: 0;
    SOUTH      :: 1;
    EAST       :: 2;
    WEST       :: 3;
    NORTH_EAST :: 4;
    NORTH_WEST :: 5;
    SOUTH_EAST :: 6;
    SOUTH_WEST :: 7;
    CENTER     :: 8;  // essentially no direction
    COUNT      :: 9; // helper value that explicitly stores the enum length
}

TILE_DIRECTION_DELTAS :: [2]float32.[
    .[0.0, -TILEMAP_GENERAL_WORLD_HEIGHT],  // north
    .[0.0, +TILEMAP_GENERAL_WORLD_HEIGHT],  // south
    .[+TILEMAP_GENERAL_WORLD_WIDTH, 0.0],   // east
    .[-TILEMAP_GENERAL_WORLD_WIDTH, 0.0],   // west
    .[+TILEMAP_GENERAL_WORLD_WIDTH, -TILEMAP_GENERAL_WORLD_HEIGHT], // north east
    .[-TILEMAP_GENERAL_WORLD_WIDTH, -TILEMAP_GENERAL_WORLD_HEIGHT], // north west
    .[+TILEMAP_GENERAL_WORLD_WIDTH, +TILEMAP_GENERAL_WORLD_HEIGHT], // south east
    .[-TILEMAP_GENERAL_WORLD_WIDTH, +TILEMAP_GENERAL_WORLD_HEIGHT], // south west
    .[0.0, 0.0], // center
];

TILE_DIRECTION_ID_DELTAS :: [2]s32.[
    .[0, -WORLD_COLS],  // north
    .[0, +WORLD_COLS],  // south
    .[+1, 0],           // east
    .[-1, 0],           // west
    .[+1, -WORLD_COLS], // north east
    .[-1, -WORLD_COLS], // north west
    .[+1, +WORLD_COLS], // south east
    .[-1, +WORLD_COLS], // south west
    .[0, 0],            // center
];

CaveType :: enum u8 {
    EMPTY;
    WATER;
    LAVA;
    TREASURE;
    MINION;
    SHAMAN;
    SPIDER_QUEEN;
}

TileType :: enum u8 {
    DIRT;
    MINED;
    CAVE; // Unrevealed cave
    ENCASED;
    WATER_STILL;
    WATER_FLOWING;
    LAVA_STILL;
    LAVA_FLOWING;
    IRON;
    OBSIDIAN;
    HOLE;
}

Entity :: struct {
    id   : s32;
    pos  : Vector2;

    sprite_rect   : Rectangle;
    bounding_rect : Rectangle; // Used for collision

    texture_map_source_pos : Vector2;
}

// This is the interface thing
HasPos :: struct {
    pos : Vector2;
}

Base :: struct {
    pos : Vector2;
    spawn_dwarf_cooldown_ms : s32;
}

Tile :: struct {
    pos : Vector2;
}

DwarfState :: enum {
    IDLE;
    MOVING;
    MINING;
}

Dwarf :: struct {
    id                 : s32;
    pos                : Vector2;
    state              : DwarfState;
    tile_ids_on_path   : [..] s32;
    mining_cooldown_ms : s32;
    tile_id_mining     : s32;
    direction          : Direction;
}

Path :: struct {
    start_tile_id  : s32;
    middle_tile_id : s32;
    end_tile_id    : s32;
}

Chunk :: struct {
    fully_mined_tile_ids    : [..] s32;
    cave_tile_ids           : [..] s32;
    encased_tile_ids        : [..] s32;
    actively_mined_tile_ids : [..] s32;
    iron_tile_ids           : [..] s32;
    obsidian_tile_ids       : [..] s32;
    water_still_tile_ids    : [..] s32;
    water_flowing_tile_ids  : [..] s32;
    lava_still_tile_ids     : [..] s32;
    lava_flowing_tile_ids   : [..] s32;
    hole_tile_ids           : [..] s32;
    base_ids                : [..] s32;
    // dwarf_ids               : [..] s32;

    // TODO: Will probably want these
    // dynamite : [..] Dwarf;
}

data_folder: string;

// Tile ID's will go row-wise, starting at 1 (zero means invalid or whatever)
// so like
// 1 2 3
// 4 5 6
// 7 8 9
// This means that to get the position of a tile you just have to do some math,
// which also means that we don't need to store that anywhere. Check out
// get_tile_pos_by_id.
actively_mined_tile_ids_to_health_table : Table(s32, s32);
actively_mined_tile_ids_in_viewport     : [..] s32;

fully_mined_tile_ids_set         : Table(s32, Any);
fully_mined_tile_ids_in_viewport : [..] s32;

cave_tile_ids_set         : Table(s32, Any);
cave_tile_ids_in_viewport : [..] s32;

encased_tile_ids_set         : Table(s32, Any);
encased_tile_ids_in_viewport : [..] s32;

iron_tile_ids_set         : Table(s32, Any);
iron_tile_ids_in_viewport : [..] s32;

water_still_tile_ids             : [..] s32;
water_still_tile_ids_set         : Table(s32, Any);
water_still_tile_ids_in_viewport : [..] s32;

water_flowing_tile_ids             : [..] s32;
water_flowing_tile_ids_set         : Table(s32, Any);
water_flowing_tile_ids_in_viewport : [..] s32;

lava_still_tile_ids             : [..] s32;
lava_still_tile_ids_set         : Table(s32, Any);
lava_still_tile_ids_in_viewport : [..] s32;

lava_flowing_tile_ids             : [..] s32;
lava_flowing_tile_ids_set         : Table(s32, Any);
lava_flowing_tile_ids_in_viewport : [..] s32;

obsidian_tile_ids_set         : Table(s32, Any);
obsidian_tile_ids_in_viewport : [..] s32;

bases               : [..] Base;
bases_in_viewport   : [..] Base;

dwarves             : [..] Dwarf;
dwarves_in_viewport : [..] Dwarf;
dwarf_id_to_index   : Table(s32, s64);
dwarf_id_counter    : s32 = 0;

tiles_with_dynamite_ids             : [..] s32;
tiles_with_dynamite_ids_in_viewport : [..] s32;

hole_tile_ids             : [..] s32;
hole_tile_ids_set         : Table(s32, s32);
hole_tile_ids_in_viewport : [..] s32;

path_being_traced : Path;
paths             : [..] Path;
// paths_in_viewport : [..] Path;

active_chunks: Table(u64, *Chunk);

edges : [..] Edge; // List of edges between tiles for pathfinding

main :: () {
    random_seed(123456789);

    InitWindow(1600, 900, "Dwarfs?! Clone");
    defer CloseWindow();

    // TODO
    // HideCursor(); // We render a custom one from a texture.
    SetTargetFPS(144);

    base_path := path_strip_filename(get_path_of_running_executable());
    data_folder = join(base_path, "data");

    init_textures();
    init_sprites();

    // Initialize font
    {
        font := GetFontDefault();
        font.baseSize = 3;
        GuiSetFont(font);
    }

    // Initialize controls
    controls: Controls;
    {
        controls.select[0]              = Control.{ type = MouseButton, value = cast(s32) MouseButton.MOUSE_BUTTON_LEFT   };
        controls.add_base[0]            = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_B               };
        controls.add_iron[0]            = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_I               };
        controls.add_as_dynamite[0]     = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_E               };
        controls.add_as_obsidian[0]     = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_Q               };
        controls.add_as_obsidian[1]     = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_LEFT_SHIFT      };
        controls.add_as_obsidian[2]     = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_RIGHT_SHIFT     };
        controls.drag_as_create_path[0] = Control.{ type = MouseButton, value = cast(s32) MouseButton.MOUSE_BUTTON_LEFT   };
        controls.drag_cam[0]            = Control.{ type = MouseButton, value = cast(s32) MouseButton.MOUSE_BUTTON_RIGHT  };
        controls.drag_cam[1]            = Control.{ type = MouseButton, value = cast(s32) MouseButton.MOUSE_BUTTON_MIDDLE };
        controls.move_camera_up[0]      = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_UP              };
        controls.move_camera_up[1]      = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_W               };
        controls.move_camera_down[0]    = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_DOWN            };
        controls.move_camera_down[1]    = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_S               };
        controls.move_camera_left[0]    = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_LEFT            };
        controls.move_camera_left[1]    = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_A               };
        controls.move_camera_right[0]   = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_RIGHT           };
        controls.move_camera_right[1]   = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_D               };
    }

    // Initialize game
    game_state := GameState.{
        hovered_dwarf_index    = 0,
        selected_dwarf_id   = 0,
        water_flow_cooldown_ms = WATER_FLOW_COOLDOWN_MS,
        lava_flow_cooldown_ms  = LAVA_FLOW_COOLDOWN_MS,
    };

    // Initialize caves
    GENERATE_CAVES_ENABLED :: true;
    #if GENERATE_CAVES_ENABLED {
        CAVE_PERLIN_NOISE_FREQUENCY :: 256; // How many rows / columns
        CAVE_PERLIN_NOISE_AMPLITUDE :: 2;
        CAVE_PERLIN_NOISE_OCTAVES   :: 1;
        CAVE_PERLIN_NOISE_MAX_THRESHOLD :: 0.95;

        cave_noise := perlin_noise_2d(WORLD_COLS, CAVE_PERLIN_NOISE_FREQUENCY, CAVE_PERLIN_NOISE_AMPLITUDE, CAVE_PERLIN_NOISE_OCTAVES);

        for i: 0..(WORLD_COLS * WORLD_COLS)-1 {
            normalized := (cave_noise[i] + 1.0) / 2.0;
            // Clamp just in case floating point math slightly overshoots
            cave_noise[i] = clamp(normalized, 0.0, 1.0);
        }

        for col: 0..WORLD_COLS-1 {
            for row: 0..WORLD_ROWS-1 {
                tile_id := (row * WORLD_COLS) + col + 1;
                noise_index := row * WORLD_COLS + col;
                tile_should_be_part_of_cave := cave_noise[noise_index] >= CAVE_PERLIN_NOISE_MAX_THRESHOLD;

                if tile_should_be_part_of_cave {
                    set_tile_as_type(xx tile_id, .CAVE);
                }
            }
        }
    }

    // Initialize iron
    GENERATE_IRON_ENABLED :: true;
    #if GENERATE_IRON_ENABLED {
        IRON_SPAWN_CHANCE_NUMERATOR   :: 5;
        IRON_SPAWN_CHANCE_DENOMINATOR :: 1000;
        IRON_VEIN_SIZE_MIN :: 8;
        IRON_VEIN_SIZE_MAX :: 15;

        for col: 0..WORLD_COLS-1 {
            for row: 0..WORLD_ROWS-1 {
                tile_id := (row * WORLD_COLS) + col + 1;

                iron_spawn_dice_roll := cast(int) random_get_within_range(IRON_SPAWN_CHANCE_NUMERATOR, IRON_SPAWN_CHANCE_DENOMINATOR);
                if iron_spawn_dice_roll <= IRON_SPAWN_CHANCE_NUMERATOR {
                    spawn_iron(xx tile_id, IRON_VEIN_SIZE_MIN, IRON_VEIN_SIZE_MAX, WORLD_COLS, WORLD_ROWS, *active_chunks, *iron_tile_ids_set);
                }
            }
        }
    }

    // Initialize base
    GENERATE_BASE_ENABLED :: true;
    #if GENERATE_BASE_ENABLED {
        home_base := create_base(
            Vector2.{
                WORLD_COLS * TILEMAP_GENERAL_WORLD_WIDTH  / 2,
                WORLD_ROWS * TILEMAP_GENERAL_WORLD_HEIGHT / 2,
            },
            true
        );
    }

    // Initialize dwarves
    GENERATE_DWARVES_ENABLED :: true;
    #if GENERATE_DWARVES_ENABLED {
        for 1..DWARF_START_COUNT {
            // Figure out where to spawn it based off of the home base
            dx := TILE_DIRECTION_DELTAS[0][0];
            dy := TILE_DIRECTION_DELTAS[0][1];
            assert(bases.count > 0);
            home_base    := bases[0];
            neighbor_pos := Vector2.{ home_base.pos.x + dx, home_base.pos.y + dy };

            create_dwarf(neighbor_pos);
        }
    }

    // Initialize camera
    camera: Camera2D;
    #if GENERATE_BASE_ENABLED {
        camera.target   = bases[0].pos;
    } else {
        camera.target   = Vector2.{
            WORLD_COLS * TILEMAP_GENERAL_WORLD_WIDTH  / 2,
            WORLD_ROWS * TILEMAP_GENERAL_WORLD_HEIGHT / 2,
        };
    }
    camera.offset   = Vector2.{ 800, 450 };
    camera.rotation = 0.0;
    camera.zoom     = 0.2;

    persistent_encasing_obsidian_tile_ids_set: Table(s32, Color);

    while !WindowShouldClose() {
        reset_temporary_storage();

        time := GetTime();
        dt_seconds_raw := GetFrameTime();
        // Cap delta time to prevent teleporting or weird bullshit
        dt_seconds := ifx dt_seconds_raw > 0.033 then 0.033 else dt_seconds_raw;

        mouse_pos_in_ui    := GetMousePosition();
        mouse_pos_in_world := GetScreenToWorld2D(mouse_pos_in_ui, camera);
        mouse_wheel_move   := GetMouseWheelMove();

        derive_entities_in_viewport(camera);

        //
        // Input
        //
        {
            // Metagame controls
            if IsKeyPressed(.KEY_SPACE) paused = !paused;
            if IsKeyPressed(.KEY_G) debug_mode = !debug_mode;

            // Previous controls
            dragging_to_create_path_prev = dragging_to_create_path;

            // Game controls
            select_is_pressed_once  = control_is_pressed(controls.select);
            select_is_held_down     = control_is_down(controls.select);
            add_base                = control_is_pressed(controls.add_base);
            add_iron                = control_is_pressed(controls.add_iron);
            add_as_dynamite         = control_is_down(controls.add_as_dynamite);
            add_as_obsidian         = control_is_down(controls.add_as_obsidian);
            started_to_create_path  = control_is_pressed(controls.drag_as_create_path);
            dragging_to_create_path = control_is_down(controls.drag_as_create_path) && !IsKeyDown(KeyboardKey.KEY_LEFT_CONTROL); // TODO: just a little debug hack
            drag_cam_pressed        = control_is_pressed(controls.drag_cam);
            drag_cam_down           = control_is_down(controls.drag_cam);
            move_camera_up          = control_is_down(controls.move_camera_up);
            move_camera_down        = control_is_down(controls.move_camera_down);
            move_camera_left        = control_is_down(controls.move_camera_left);
            move_camera_right       = control_is_down(controls.move_camera_right);
        }

        //
        // Update
        //
        {
            // Update unpausable things
            {
                // Debug break tiles
                hovered_tile_rect := get_tile_rect_that_pos_is_within(WORLD_WIDTH, WORLD_HEIGHT, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, mouse_pos_in_world);
                if IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT) && IsKeyDown(KeyboardKey.KEY_LEFT_CONTROL) {
                    tile_id := get_tile_id_by_pos(Vector2.{ hovered_tile_rect.x, hovered_tile_rect.y });
                    set_tile_as_type(tile_id, .MINED);
                    reveal_cave_if_necessary(tile_id);
                }

                // Update camera
                {
                    CAMERA_ZOOM_MULTIPLIER :: 1.2;
                    CAMERA_ZOOM_MIN :: 0.01;
                    CAMERA_ZOOM_MAX :: 13.0;

                    if move_camera_up    camera.target.y -= CAMERA_MOVE_SPEED_BASE;
                    if move_camera_down  camera.target.y += CAMERA_MOVE_SPEED_BASE;
                    if move_camera_left  camera.target.x -= CAMERA_MOVE_SPEED_BASE;
                    if move_camera_right camera.target.x += CAMERA_MOVE_SPEED_BASE;

                    camera.offset = Vector2.{ GetScreenWidth() / 2.0, GetScreenHeight() / 2.0 };

                    camera_move_speed := CAMERA_MOVE_SPEED_BASE / 2 * camera.zoom;
                    if drag_cam_pressed {
                        mouse_drag_began_at_pos = mouse_pos_in_world;
                    }

                    if drag_cam_down {
                        world_delta := Vector2Subtract(mouse_drag_began_at_pos, mouse_pos_in_world);
                        
                        // Apply that difference to the camera target.
                        // This effectively "pulls" the world back so the mouse stays where it began.
                        camera.target = Vector2Add(camera.target, world_delta);
                    }

                    // Make sure the camera zooms in towards the mouse pos
                    if mouse_wheel_move != 0 {
                        // Grab the world space position of the mouse before the zoom
                        mouse_world_pos_before := GetScreenToWorld2D(GetMousePosition(), camera);

                        // Apply the zoom
                        zoom_factor := pow(CAMERA_ZOOM_MULTIPLIER, mouse_wheel_move);
                        camera.zoom *= zoom_factor;
                        camera.zoom  = clamp(camera.zoom, CAMERA_ZOOM_MIN, CAMERA_ZOOM_MAX);

                        // Grab the world space position of the mouse AFTER the zoom
                        // (Raylib uses the new camera.zoom but the old camera.target here)
                        mouse_world_pos_after := GetScreenToWorld2D(GetMousePosition(), camera);

                        // Calculate the shift caused by the zoom, and move the target to cancel it out
                        zoom_delta := Vector2Subtract(mouse_world_pos_before, mouse_world_pos_after);
                        camera.target = Vector2Add(camera.target, zoom_delta);
                    }
                }
            }

            // Update pausable things
            if !paused {
                // Update user action
                {        
                    if add_as_obsidian {
                        if select_is_held_down {
                            // Try to turn the selected tile into obsidian
                            tile_id := get_tile_id_by_pos(mouse_pos_in_world);

                            tile_is_iron            := table_contains(*iron_tile_ids_set, tile_id);
                            tile_is_being_mined     := table_contains(*actively_mined_tile_ids_to_health_table, tile_id);
                            tile_is_mined           := table_contains(*fully_mined_tile_ids_set, tile_id);
                            tile_is_mineable        := tile_is_iron || tile_is_being_mined || !tile_is_mined;

                            tile_is_unrevealed_cave := table_contains(*cave_tile_ids_set, tile_id);
                            tile_is_water_still     := table_contains(*water_still_tile_ids_set, tile_id);
                            tile_is_water_flowing   := table_contains(*water_flowing_tile_ids_set, tile_id);
                            tile_is_lava_still      := table_contains(*lava_still_tile_ids_set, tile_id);
                            tile_is_lava_flowing    := table_contains(*lava_flowing_tile_ids_set, tile_id);
                            tile_is_empty           := tile_is_unrevealed_cave || tile_is_water_still || tile_is_water_flowing || tile_is_lava_still || tile_is_lava_flowing;

                            tile_is_obsidian        := table_contains(*obsidian_tile_ids_set, tile_id);

                            tile_is_encased         := table_contains(*encased_tile_ids_set, tile_id);

                            if tile_is_mineable && !tile_is_empty && !tile_is_obsidian && !tile_is_encased {
                                set_tile_as_type(tile_id, .OBSIDIAN);
                                handle_encasement(tile_id, *persistent_encasing_obsidian_tile_ids_set);
                            }
                        }
                    }
                    else if add_as_dynamite {
                        if select_is_pressed_once {
                            // Try to add dynamite to the selected tile
                            tile_id := get_tile_id_by_pos(mouse_pos_in_world);

                            tile_is_mined   := table_contains(*fully_mined_tile_ids_set, tile_id);
                            tile_is_encased := table_contains(*encased_tile_ids_set, tile_id);

                            if tile_is_mined && !tile_is_encased {
                                array_add(*tiles_with_dynamite_ids, tile_id);
                            }
                        }
                    }
                    else {
                        if dragging_to_create_path {
                            if started_to_create_path {
                                for dwarf: dwarves_in_viewport {
                                    if CheckCollisionPointRec(mouse_pos_in_world, get_world_rect_from_pos(dwarf.pos)) {
                                        game_state.selected_dwarf_id = dwarf.id;
                                        break;
                                    }
                                }

                                // If a dwarf was found being clicked
                                if game_state.selected_dwarf_id > 0 {
                                    found, selected_dwarf_index := table_find(*dwarf_id_to_index, game_state.selected_dwarf_id);
                                    assert(found);

                                    // Teleport dwarf to tile we are hovering over and keep it there
                                    tile_rect := get_tile_rect_that_pos_is_within(WORLD_WIDTH, WORLD_HEIGHT, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, mouse_pos_in_world);
                                    dwarves[selected_dwarf_index].pos = get_rect_pos(tile_rect);
                                    
                                    // Stop the dwarf from moving so you can think while dragging a path
                                    dwarves[selected_dwarf_index].state = .IDLE;

                                    // Remove its current pathing
                                    array_reset(*(dwarves[selected_dwarf_index].tile_ids_on_path));
                                }

                                mouse_pos_when_path_creation_started = mouse_pos_in_world;
                            }

                            // Draw out the path that is currently being traced
                            path_being_traced = get_path(mouse_pos_when_path_creation_started, mouse_pos_in_world);
                        } else if dragging_to_create_path_prev {
                            array_add(*paths, path_being_traced);

                            if game_state.selected_dwarf_id > 0 {
                                found, selected_dwarf_index := table_find(*dwarf_id_to_index, game_state.selected_dwarf_id);
                                assert(found);

                                start_pos := get_tile_pos_by_id(path_being_traced.start_tile_id);
                                end_pos   := get_tile_pos_by_id(path_being_traced.end_tile_id);
                                tile_ids_on_path := get_tile_ids_along_path(start_pos, end_pos);

                                array_reset(*(dwarves[selected_dwarf_index].tile_ids_on_path));
                                array_copy(*(dwarves[selected_dwarf_index].tile_ids_on_path), tile_ids_on_path);

                                dwarves[selected_dwarf_index].state = .MOVING;
                                game_state.selected_dwarf_id = 0;
                            }
                        }
                    }
                }

                // Update dwarves
                {
                    for *dwarf: dwarves {
                        if #complete dwarf.state == {
                            case .MOVING;
                                // Add a new target if dwarf does not have one.
                                dwarf_has_target := dwarf.tile_ids_on_path.count > 0;
                                if !dwarf_has_target {
                                    new_direction := dwarf.direction;

                                    // Find a new target by picking a random cardinal direction 1 tile away
                                    change_direction_rng := random_get_within_range(0, 1);
                                    if change_direction_rng < 0.1 {
                                        go_left := change_direction_rng < 0.05;

                                        if dwarf.direction == .NORTH {
                                            new_direction = ifx go_left then .WEST  else .EAST;
                                        }
                                        else if dwarf.direction == .SOUTH {
                                            new_direction = ifx go_left then .EAST  else .WEST;
                                        }
                                        else if dwarf.direction == .EAST  {
                                            new_direction = ifx go_left then .NORTH else .SOUTH;
                                        }
                                        else if dwarf.direction == .WEST  {
                                            new_direction = ifx go_left then .SOUTH else .NORTH;
                                        }
                                        else assert(false);
                                    }

                                    dx := TILE_DIRECTION_DELTAS[new_direction][0];
                                    dy := TILE_DIRECTION_DELTAS[new_direction][1];
                                    dwarf.direction = new_direction;

                                    assert(dx == 0 || dy == 0, "dx: %, dy: %", dx, dy);

                                    new_target_tile_pos := Vector2.{
                                        dwarf.pos.x + dx,
                                        dwarf.pos.y + dy,
                                    };

                                    new_target_tile_id := get_tile_id_by_pos(new_target_tile_pos);
                                    array_add(*dwarf.tile_ids_on_path, new_target_tile_id);
                                }

                                assert(dwarf.tile_ids_on_path.count > 0);
                                target_tile_id  := dwarf.tile_ids_on_path[0];
                                target_tile_pos := get_tile_pos_by_id(target_tile_id);

                                assert(
                                    dwarf.pos.x == target_tile_pos.x || dwarf.pos.y == target_tile_pos.y,
                                    "Dwarf % is going at an angle", it_index
                                );

                                tile_id_next_in_dwarfs_path := dwarf.tile_ids_on_path[0];

                                // If it's mined, then proceed
                                if table_contains(*fully_mined_tile_ids_set, tile_id_next_in_dwarfs_path) {
                                    dwarf_pretty_much_reached_target := values_are_close(dwarf.pos, target_tile_pos, 1);
                                    if dwarf_pretty_much_reached_target {
                                        // Teleport dwarf to the target tile to remove any floating point weirdness.
                                        dwarf.pos = target_tile_pos;

                                        // Remove the target from the tile ids on path
                                        array_ordered_remove_by_index(*(dwarf.tile_ids_on_path), 0);

                                        // Check what the dwarf just stepped on, and deal with it.
                                        {
                                            // TODO: faster walk and mine speed when on a path, I think
                                            // Check if the dwarf just landed on an arrow
                                            for path: paths {
                                                tile_id_with_start_arrow := get_tile_id_with_start_arrow_on_path(path);
                                                if target_tile_id == tile_id_with_start_arrow {
                                                    // If the dwarf just stepped on a start arrow, then we want him to go to the path's middle pos.
                                                    start_pos := get_tile_pos_by_id(path.start_tile_id);
                                                    end_pos   := get_tile_pos_by_id(path.middle_tile_id);
                                                    tile_ids_on_path := get_tile_ids_along_path(start_pos, end_pos);
                                                    // Don't include the tile with the arrow on it, because then we softlock.
                                                    tile_ids_on_path.data  += 1;
                                                    tile_ids_on_path.count -= 1;

                                                    array_reset(*(dwarf.tile_ids_on_path));
                                                    array_copy(*(dwarf.tile_ids_on_path), tile_ids_on_path);

                                                    set_dwarf_direction_to_face_next_target(dwarf);

                                                    break;
                                                }

                                                path_has_middle_arrow, tile_id_with_middle_arrow := find_tile_id_with_middle_arrow_on_path(path);
                                                if path_has_middle_arrow && target_tile_id == tile_id_with_middle_arrow {
                                                    // If the dwarf just stepped on a middle arrow, then we want him to go to the path's end pos.
                                                    // Note that if there is a middle arrow, then that means there is a bend in the path and the
                                                    // end pos is necessarily different than the middle pos.
                                                    start_pos := get_tile_pos_by_id(path.middle_tile_id);
                                                    end_pos   := get_tile_pos_by_id(path.end_tile_id);
                                                    tile_ids_on_path := get_tile_ids_along_path(start_pos, end_pos);
                                                    // Don't include the tile with the arrow on it, because then we softlock.
                                                    tile_ids_on_path.data  += 1;
                                                    tile_ids_on_path.count -= 1;

                                                    array_reset(*(dwarf.tile_ids_on_path));
                                                    array_copy(*(dwarf.tile_ids_on_path), tile_ids_on_path);

                                                    set_dwarf_direction_to_face_next_target(dwarf);

                                                    break;
                                                }
                                            }
                                        }
                                    } else {
                                        // If the dwarf has not reached its target yet, then simply continue on to the target
                                        current_pos     := dwarf.pos;
                                        target_pos      := get_tile_pos_by_id(dwarf.tile_ids_on_path[0]);
                                        delta           := Vector2Subtract(target_pos, current_pos);
                                        direction       := Vector2Normalize(delta);
                                        movement_vector := Vector2Scale(direction, DWARF_MOVE_SPEED * dt_seconds);
                                        new_pos         := Vector2Add(current_pos, movement_vector);

                                        dwarf.pos = new_pos;

                                        // TODO: delete this?...
                                        //
                                        // PERF: Instead of having the full list of tile ids that a dwarf needs to go to, only have
                                        // the middle and end positions.
                                        #if false {
                                            dwarf_center    := get_rect_center(get_world_rect_from_pos(dwarf.pos));
                                            current_tile_id := get_tile_id_by_pos(dwarf_center);

                                            // Get the rect of the tile the dwarf wants to go to next. Importantly, this is not a tile
                                            // in the dwarf's actual stack of tile ids to visit, it's one that's in between 
                                            tile_id_next_in_dwarfs_path : s32;
                                            if      values_are_close(direction, Vector2.{ 0.0, -1.0 }) tile_id_next_in_dwarfs_path = current_tile_id - WORLD_COLS; // North
                                            else if values_are_close(direction, Vector2.{ 0.0,  1.0 }) tile_id_next_in_dwarfs_path = current_tile_id + WORLD_COLS; // South
                                            else if values_are_close(direction, Vector2.{ 1.0,  0.0 }) tile_id_next_in_dwarfs_path = current_tile_id + 1;          // East
                                            else if values_are_close(direction, Vector2.{ -1.0, 0.0 }) tile_id_next_in_dwarfs_path = current_tile_id - 1;          // West
                                            else    assert(false, "Normalized direction (%,%) did not map to a direction", direction.x, direction.y);
                                            tile_pos_next_in_dwarfs_path  := get_tile_pos_by_id(tile_id_next_in_dwarfs_path);
                                            tile_rect_next_in_dwarfs_path := get_world_rect_from_pos(tile_pos_next_in_dwarfs_path);

                                            // If dwarf would collide with the next tile in its path if we just moved it, then we need to check whether
                                            // it has to be dealt with or not.
                                            if CheckCollisionRecs(new_rect, tile_rect_next_in_dwarfs_path) {
                                                // If this tile is mined, then simply keep moving.
                                                tile_is_mined := table_contains(*fully_mined_tile_ids_set, tile_id_next_in_dwarfs_path);
                                                if tile_is_mined {
                                                    dwarf.pos = new_pos;

                                                    CHECK_IF_DWARF_IS_IN_TILE :: true;
                                                    #if CHECK_IF_DWARF_IS_IN_TILE {
                                                        center_of_dwarf       := get_rect_center(get_world_rect_from_pos(dwarf.pos));
                                                        tile_rect_dwarf_is_on := get_tile_rect_that_pos_is_within(WORLD_WIDTH, WORLD_HEIGHT, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, center_of_dwarf);
                                                        tile_id_dwarf_is_on   := get_tile_id_by_pos(get_rect_pos(tile_rect_dwarf_is_on));
                                                        
                                                        assert(table_contains(*fully_mined_tile_ids_set, tile_id_dwarf_is_on), "dwarf is in rock or something lol wtf");
                                                    }
                                                }
                                                // If it's obsidian, then they'll have to do something else, because they can't go through it
                                                else if table_contains(*obsidian_tile_ids_set, tile_id_next_in_dwarfs_path) {
                                                    array_reset(*(dwarf.tile_ids_on_path));
                                                }
                                                // If it's unmined, then they'll have to enter into the mining state before they can proceed.
                                                else {
                                                    dwarf.state = .MINING;
                                                    dwarf.tile_id_mining = tile_id_next_in_dwarfs_path;

                                                    chunk := find_or_create_chunk_by_tile_id(tile_id_next_in_dwarfs_path);
                                                    array_add(*chunk.actively_mined_tile_ids, tile_id_next_in_dwarfs_path);
                                                    table_set(*actively_mined_tile_ids_to_health_table, tile_id_next_in_dwarfs_path, DIRT_HEALTH);
                                                }
                                            }
                                        }
                                    }
                                }
                                // If it's unmineable, then they'll have to do something else, because they can't go through it
                                else if (
                                    table_contains(*obsidian_tile_ids_set, tile_id_next_in_dwarfs_path) ||
                                    table_contains(*hole_tile_ids_set, tile_id_next_in_dwarfs_path)
                                ) {
                                    array_reset(*(dwarf.tile_ids_on_path));
                                }
                                // If it's unmined, then they'll have to enter into the mining state before they can proceed.
                                else {
                                    dwarf.state = .MINING;
                                    dwarf.tile_id_mining = tile_id_next_in_dwarfs_path;

                                    chunk := find_or_create_chunk_by_tile_id(tile_id_next_in_dwarfs_path);
                                    array_add(*chunk.actively_mined_tile_ids, tile_id_next_in_dwarfs_path);
                                    table_set(*actively_mined_tile_ids_to_health_table, tile_id_next_in_dwarfs_path, IRON_HEALTH);
                                }

                            case .MINING;
                                assert(dwarf.tile_id_mining >= 0, "Dwarf tryna mine but he got no gotdamn tile to mine!!!!!!!");

                                // If you try to mine liquid, you're fucking banned
                                if (
                                    table_contains(*water_still_tile_ids_set,   dwarf.tile_id_mining) ||
                                    table_contains(*water_flowing_tile_ids_set, dwarf.tile_id_mining) ||
                                    table_contains(*lava_still_tile_ids_set,    dwarf.tile_id_mining) ||
                                    table_contains(*lava_flowing_tile_ids_set,  dwarf.tile_id_mining)
                                ) {
                                    kill_dwarf_by_index(it_index);
                                }

                                if dwarf.mining_cooldown_ms > 0 {
                                    dwarf.mining_cooldown_ms -= xx (dt_seconds * 1000);
                                } else {
                                    // TODO: swing animation, I guess
                                
                                    // Decrease the tile health by the dwarf mining damage
                                    found_tile_dwarf_is_mining, current_health := table_find(*actively_mined_tile_ids_to_health_table, dwarf.tile_id_mining);
                                    
                                    if found_tile_dwarf_is_mining {
                                        new_health := current_health - DWARF_MINE_DAMAGE_PER_SWING;

                                        if new_health <= 0 {
                                            // TODO: probably will want a function to determine if a tile has a resource
                                            // instead of checking each table manually as we have more. idk.
                                            is_mining_resource := table_find(*iron_tile_ids_set, dwarf.tile_id_mining);
                                            
                                            set_tile_as_type(dwarf.tile_id_mining, .MINED);

                                            // If the dwarf is mining a resource, check if there are any others nearby
                                            if is_mining_resource {
                                                check_for_resource_and_mine_if_present :: (dwarf: *Dwarf, dx: float32, dy: float32, iron_tile_ids_set: *Table) -> bool {
                                                    mined_tile_pos := get_tile_pos_by_id(dwarf.tile_id_mining);
                                                    neighbor_pos   := Vector2.{ mined_tile_pos.x + dx, mined_tile_pos.y + dy };
                                                    neighbor_id    := get_tile_id_by_pos(neighbor_pos);

                                                    is_neighbor_a_resource_tile := table_find(iron_tile_ids_set, neighbor_id);
                                                    if is_neighbor_a_resource_tile {
                                                        // If the tile we mined was a resource like iron (as opposed to dirt),
                                                        // then we want to path towards it.
                                                        tile_ids_on_path := get_tile_ids_along_path(dwarf.pos, neighbor_pos);
                                                        array_reset(*(dwarf.tile_ids_on_path));
                                                        // PERF
                                                        // TODO: Am I leaking stuff here, or...
                                                        array_copy(*(dwarf.tile_ids_on_path), tile_ids_on_path);
                                                    }

                                                    return is_neighbor_a_resource_tile;
                                                }

                                                // TODO: clean this up if you're bored
                                                for TILE_DIRECTION_DELTAS {
                                                    found := check_for_resource_and_mine_if_present(dwarf, it[0] * 1, it[1] * 1, *iron_tile_ids_set);
                                                    if found break;

                                                    for TILE_DIRECTION_DELTAS {
                                                        found = check_for_resource_and_mine_if_present(dwarf, it[0] * 2, it[1] * 2, *iron_tile_ids_set);
                                                        if found break;

                                                        for TILE_DIRECTION_DELTAS {
                                                            found = check_for_resource_and_mine_if_present(dwarf, it[0] * 3, it[1] * 3, *iron_tile_ids_set);
                                                            if found break;
                                                        }
                                                    }
                                                }
                                            }

                                            // If we just cracked into a cave, we'll need to reveal the cave and do anything
                                            // that cave type needs (e.g. spawn water, lava, monsters, etc.).
                                            reveal_cave_if_necessary(dwarf.tile_id_mining);

                                            dwarf.tile_id_mining = 0;
                                            dwarf.state = .MOVING;
                                        } else {
                                            // If the tile just needs to take some damage, well, then damage it ya fuckin jallopy
                                            table_set(*actively_mined_tile_ids_to_health_table, dwarf.tile_id_mining, new_health);
                                        }

                                        // Reset cooldown
                                        dwarf.mining_cooldown_ms = DWARF_MINE_COOLDOWN_MS;
                                    } else {
                                        if debug_mode print("INFO: Dwarf was mining tile % but suddenly it was removed from the table of actively mined tiles.\n", dwarf.tile_id_mining);
                                        // It's possible for the tile the dwarf is mining to suddenly be changed, like into obsidian.
                                        // In this case, the dwarf should abandon the idea of mining its current tile.
                                        array_reset(*(dwarf.tile_ids_on_path));
                                        dwarf.tile_id_mining = 0;
                                        dwarf.state = .MOVING;
                                    }
                                }

                            case .IDLE;
                        }
                    }
                }

                // Update dynamite
                {
                    // Take an array view of the actual state because we mutate the state during the loop
                    // and can cause self referential problems when looping on the actual state.
                    current_tiles_with_dynamite_ids := array_view(tiles_with_dynamite_ids, 0);
                    for current_tiles_with_dynamite_ids {
                        // Kill any dwarves you are coming in contact with
                        for dwarf, dwarf_index: dwarves {
                            dynamite_pos := get_tile_pos_by_id(it);
                            if Vector2Equals(dwarf.pos, dynamite_pos) {
                                kill_dwarf_by_index(dwarf_index);

                                // Destroy the dynamite
                                // TODO: I have a feeling this might cause weird problems. If it does, just mark these
                                // as to-delete and have a delete pass.
                                array_unordered_remove_by_index(*tiles_with_dynamite_ids, it_index);

                                // Create a hole
                                set_tile_as_type(it, .HOLE);
                                handle_encasement(it, *persistent_encasing_obsidian_tile_ids_set);

                                // TODO: animation I guess

                                continue;
                            }
                        }
                    }
                }

                // Update bases
                {
                    if add_base {
                        base_rect := get_tile_rect_that_pos_is_within(WORLD_WIDTH, WORLD_HEIGHT, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, mouse_pos_in_world);
                        create_base(Vector2.{ base_rect.x, base_rect.y });
                    }

                    for *base: bases {
                        if base.spawn_dwarf_cooldown_ms <= 0 {
                            create_dwarf(Vector2.{ base.pos.x, base.pos.y });

                            base.spawn_dwarf_cooldown_ms = DWARF_SPAWN_MS;
                        } else {
                            base.spawn_dwarf_cooldown_ms -= xx (dt_seconds * 1000);
                        }
                    }
                }

                // Update iron
                UPDATE_IRON :: true;
                #if UPDATE_IRON {
                    IRON_VEIN_SIZE_MIN :: 8;
                    IRON_VEIN_SIZE_MAX :: 15;

                    if add_iron {
                        iron_rect := get_tile_rect_that_pos_is_within(WORLD_WIDTH, WORLD_HEIGHT, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, mouse_pos_in_world);
                        tile_pos  := Vector2.{ iron_rect.x, iron_rect.y };
                        tile_id   := get_tile_id_by_pos(tile_pos);
                        spawn_iron(xx tile_id, IRON_VEIN_SIZE_MIN, IRON_VEIN_SIZE_MAX, WORLD_COLS, WORLD_ROWS, *active_chunks, *iron_tile_ids_set);
                    }
                }

                // Update water flowing
                UPDATE_WATER_FLOWING :: true;
                #if UPDATE_WATER_FLOWING {
                    should_spread_this_frame := game_state.water_flow_cooldown_ms <= 0;

                    if should_spread_this_frame {
                        game_state.water_flow_cooldown_ms = WATER_FLOW_COOLDOWN_MS;
                    } else {
                        game_state.water_flow_cooldown_ms -= xx (dt_seconds * 1000);
                    }

                    // Take an array view of the actual state because we mutate the state during the loop
                    // and can cause self referential problems when looping on the actual state.
                    current_water_flowing_tile_ids := array_view(water_flowing_tile_ids, 0);
                    for current_water_flowing_tile_ids {
                        kill_any_dwarves_touching_tile_id(it);

                        if should_spread_this_frame {
                            try_to_set_cardinal_neighbors_as_flowing_tile_type(it, .WATER_FLOWING);

                            // If all surrounding tiles are liquid, then we can mark this tile as
                            // still liquid so we don't have to update it going forward.
                            if are_all_neighbors_liquid(it) {
                                set_tile_as_type(it, .WATER_STILL);
                            }
                        }
                    }
                }

                // Update water still
                UPDATE_WATER_STILL :: true;
                #if UPDATE_WATER_STILL {
                    for water_still_tile_ids kill_any_dwarves_touching_tile_id(it);
                }

                // Update lava flowing
                UPDATE_LAVA_FLOWING :: true;
                #if UPDATE_LAVA_FLOWING {
                    should_spread_water_this_frame := game_state.lava_flow_cooldown_ms <= 0;

                    if should_spread_water_this_frame {
                        game_state.lava_flow_cooldown_ms = LAVA_FLOW_COOLDOWN_MS;
                    } else {
                        game_state.lava_flow_cooldown_ms -= xx (dt_seconds * 1000);
                    }

                    // Take an array view of the actual state because we mutate the state during the loop
                    // and can cause self referential problems when looping on the actual state.
                    current_lava_flowing_tile_ids := array_view(lava_flowing_tile_ids, 0);
                    for current_lava_flowing_tile_ids {
                        kill_any_dwarves_touching_tile_id(it);

                        if should_spread_water_this_frame {
                            try_to_set_cardinal_neighbors_as_flowing_tile_type(it, .LAVA_FLOWING);

                            // If all surrounding tiles are liquid, then we can mark this tile as
                            // still liquid so we don't have to update it going forward.
                            if are_all_neighbors_liquid(it) {
                                set_tile_as_type(it, .LAVA_STILL);
                            }
                        }
                    }
                }

                // Update lava still
                UPDATE_LAVA_STILL :: true;
                #if UPDATE_LAVA_STILL {
                    for lava_still_tile_ids kill_any_dwarves_touching_tile_id(it);
                }
            }
        }

        //
        // Draw
        //
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(BEIGE);

            // Draw world
            {
                BeginMode2D(camera);
                defer EndMode2D();

                // First, draw base layer of dirt which is just one giant quad
                {
                    // This accomplishes the tiling effect when we sample the source
                    // with such a big triangle.
                    source := Rectangle.{ 
                        0, 
                        0, 
                        xx (TILEMAP_GENERAL_WORLD_WIDTH  * WORLD_COLS), // Repeat 10,000 times horizontally
                        xx (TILEMAP_GENERAL_WORLD_HEIGHT * WORLD_ROWS), // Repeat 10,000 times vertically
                    };

                    dest := Rectangle.{ 
                        0, 
                        0, 
                        xx (TILEMAP_GENERAL_WORLD_WIDTH  * WORLD_COLS),
                        xx (TILEMAP_GENERAL_WORLD_HEIGHT * WORLD_ROWS),
                    };
                    
                    DrawTexturePro(dirt_texture, source, dest, Vector2.{0,0}, 0.0, WHITE);
                }

                // Then draw any uncovered tiles over the base layer
                // Draw tiles
                DRAW_TILES :: true;
                #if DRAW_TILES {
                    for fully_mined_tile_ids_in_viewport {
                        DrawRectangleV(
                            get_tile_pos_by_id(it),
                            Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT },
                            BEIGE, // TODO: texture
                        );
                    }

                    for cave_tile_ids_in_viewport {
                        DrawRectangleV(
                            get_tile_pos_by_id(it),
                            Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT },
                            BLACK, // TODO: texture
                        );
                    }

                    for iron_tile_ids_in_viewport {
                        DrawRectangleV(
                            get_tile_pos_by_id(it),
                            Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT },
                            LIGHTGRAY, // TODO: texture
                        );
                    }

                    for obsidian_tile_ids_in_viewport {
                        DrawRectangleV(
                            get_tile_pos_by_id(it),
                            Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT },
                            DARKGRAY, // TODO: texture
                        );
                    }

                    for water_still_tile_ids_in_viewport {
                        DrawRectangleV(
                            get_tile_pos_by_id(it),
                            Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT },
                            BLUE, // TODO: texture
                        );
                    }

                    for water_flowing_tile_ids_in_viewport {
                        DrawRectangleV(
                            get_tile_pos_by_id(it),
                            Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT },
                            SKYBLUE, // TODO: texture
                        );
                    }

                    for lava_still_tile_ids_in_viewport {
                        DrawRectangleV(
                            get_tile_pos_by_id(it),
                            Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT },
                            RED, // TODO: texture
                        );
                    }

                    for lava_flowing_tile_ids_in_viewport {
                        DrawRectangleV(
                            get_tile_pos_by_id(it),
                            Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT },
                            ORANGE, // TODO: texture
                        );
                    }

                    for hole_tile_ids_in_viewport {
                        DrawRectangleV(
                            get_tile_pos_by_id(it),
                            Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT },
                            DARKGRAY, // TODO: texture
                        );
                    }

                    if !debug_mode {
                        for encased_tile_ids_in_viewport {
                            DrawRectangleV(
                                get_tile_pos_by_id(it),
                                Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT },
                                TRANSPARENT_WHITE
                            );
                        }
                    }

                    if debug_mode {
                        for persistent_encasing_obsidian_tile_ids_set {
                            DrawRectangleV(
                                get_tile_pos_by_id(it_index),
                                Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT },
                                it
                            );
                        }
                    }
                }

                // Draw bases
                DRAW_BASES :: true;
                #if DRAW_BASES {
                    for base: bases_in_viewport {
                        source := Rectangle.{
                            0, 0,
                            TILEMAP_GENERAL_TILE_WIDTH,
                            TILEMAP_GENERAL_TILE_HEIGHT,
                        };

                        dest := get_world_rect_from_pos(base.pos);

                        DrawTexturePro(tilemap_texture_general, source, dest, Vector2.{0,0}, 0.0, WHITE);
                    }
                }

                // Draw paths
                {
                    if dragging_to_create_path draw_path(path_being_traced);
                    
                    for path: paths draw_path(path);
                }

                // Draw hovered tile
                {
                    hovered_tile_rect := get_tile_rect_that_pos_is_within(WORLD_WIDTH, WORLD_HEIGHT, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, mouse_pos_in_world);
                    DrawRectangleRec(hovered_tile_rect, TRANSPARENT_WHITE);
                    if debug_mode {
                        found_tile, tile_id := find_tile_id_by_pos(get_rect_pos(hovered_tile_rect));
                        if found_tile {
                            DrawText(tprint("%\0", tile_id).data, xx hovered_tile_rect.x, xx hovered_tile_rect.y, 12, WHITE);
                        }
                    }
                }

                // Draw dwarves
                {
                    for dwarf: dwarves_in_viewport {
                        source := Rectangle.{
                            1 * TILEMAP_GENERAL_TILE_WIDTH,
                            0 * TILEMAP_GENERAL_TILE_HEIGHT,
                            TILEMAP_GENERAL_TILE_WIDTH,
                            TILEMAP_GENERAL_TILE_HEIGHT,
                        };

                        dest := get_world_rect_from_pos(dwarf.pos);

                        DrawTexturePro(tilemap_texture_general, source, dest, Vector2.{0,0}, 0.0, WHITE);
                    }
                }

                // Draw dynamite
                DRAW_DYNAMITE :: true;
                #if DRAW_DYNAMITE {
                    for tiles_with_dynamite_ids_in_viewport {
                        source := Rectangle.{
                            4 * TILEMAP_GENERAL_TILE_WIDTH,
                            0 * TILEMAP_GENERAL_TILE_HEIGHT,
                            TILEMAP_GENERAL_TILE_WIDTH,
                            TILEMAP_GENERAL_TILE_HEIGHT,
                        };

                        pos  := get_tile_pos_by_id(it);
                        dest := get_world_rect_from_pos(pos);

                        DrawTexturePro(tilemap_texture_general, source, dest, Vector2.{0,0}, 0.0, WHITE);
                    }
                }
            }

            // Draw UI
            debug_text_y : s32 = 10;
            INCREMENT_Y :: 20;
            if debug_mode {
                DrawFPS(10, read_then_increment(*debug_text_y, INCREMENT_Y));
                DrawText(tprint("dwarf count: %\0", dwarves.count).data, 10, read_then_increment(*debug_text_y, INCREMENT_Y), 12, WHITE);
            
                // Debug game state
                {
                    DrawText(tprint("hovered_dwarf_index: %\0", game_state.hovered_dwarf_index).data, 10, read_then_increment(*debug_text_y, INCREMENT_Y), 18, WHITE);
                    DrawText(tprint("selected_dwarf_id: %\0", game_state.selected_dwarf_id).data, 10, read_then_increment(*debug_text_y, INCREMENT_Y), 18, WHITE);
                    DrawText(tprint("water_flow_cooldown_ms: %\0", game_state.water_flow_cooldown_ms).data, 10, read_then_increment(*debug_text_y, INCREMENT_Y), 18, WHITE);
                    DrawText(tprint("lava_flow_cooldown_ms: %\0", game_state.lava_flow_cooldown_ms).data, 10, read_then_increment(*debug_text_y, INCREMENT_Y), 18, WHITE);
                }

                debug_text_y = 0;
                for dwarves {
                    if CheckCollisionPointRec(mouse_pos_in_world, Rectangle.{ it.pos.x, it.pos.y, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT }) {
                        DrawText(tprint("id: %\0", it.id).data,                                 xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("pos: %\0", it.pos).data,                               xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("state: %\0", it.state).data,                           xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("tile_ids_on_path: %\0", it.tile_ids_on_path).data,     xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("mining_cooldown_ms: %\0", it.mining_cooldown_ms).data, xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("tile_id_mining: %\0", it.tile_id_mining).data,         xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("direction: %\0", it.direction).data,                   xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                    }
                }
            }

            if paused {

            }
        }
    }
}

set_dwarf_direction_to_face_next_target :: (dwarf: *Dwarf) {
    assert(dwarf.tile_ids_on_path.count > 0);
    target_tile_id := dwarf.tile_ids_on_path[0];
    dwarf_tile_id  := get_tile_id_by_pos(dwarf.pos);
    assert(target_tile_id != dwarf_tile_id, "dwarf is softlocked trying to get it the id it's already on, I think.");

    if      target_tile_id == dwarf_tile_id - WORLD_ROWS dwarf.direction = .NORTH;
    else if target_tile_id == dwarf_tile_id + WORLD_ROWS dwarf.direction = .SOUTH;
    else if target_tile_id == dwarf_tile_id + 1          dwarf.direction = .EAST;
    else if target_tile_id == dwarf_tile_id - 1          dwarf.direction = .WEST;
    else assert(false);
}

create_dwarf :: (pos: Vector2) -> Dwarf {
    dwarf_id  := increment_then_read(*dwarf_id_counter);
    direction := cast(Direction) cast(int) random_get_within_range(0, 3);

    dwarf := Dwarf.{
        id        = dwarf_id,
        pos       = pos,
        state     = .MOVING,
        direction = direction,
        // tile_ids_on_path intentionally not set
    };

    dwarf_tile_id := get_tile_id_by_pos(pos);
    // chunk := find_or_create_chunk_by_tile_id(dwarf_tile_id);
    // array_add(*chunk.dwarf_ids, dwarf_id);
    table_set(*dwarf_id_to_index, dwarf_id, dwarves.count);
    array_add(*dwarves, dwarf);

    return dwarf;
}

create_base :: (pos: Vector2, is_home_base: bool = false) -> Base {
    base := Base.{
        pos = pos,
        spawn_dwarf_cooldown_ms = DWARF_SPAWN_MS,
    };

    base_tile_id := get_tile_id_by_pos(base.pos);
    chunk := find_or_create_chunk_by_tile_id(base_tile_id);
    array_add(*chunk.base_ids, xx bases.count);
    array_add(*bases, base);

    if is_home_base {
        // Give a little breathing room with caves
        BLOCKS_BEFORE_CAVES :: 10;
        for dy_idx: -BLOCKS_BEFORE_CAVES..BLOCKS_BEFORE_CAVES {
            for dx_idx: -BLOCKS_BEFORE_CAVES..BLOCKS_BEFORE_CAVES {
                // A circular clearing looks more natural
                if (dx_idx * dx_idx + dy_idx * dy_idx) > (BLOCKS_BEFORE_CAVES * BLOCKS_BEFORE_CAVES) {
                    continue;
                }

                neighbor_pos := Vector2.{ 
                    base.pos.x + (dx_idx * TILEMAP_GENERAL_WORLD_WIDTH), 
                    base.pos.y + (dy_idx * TILEMAP_GENERAL_WORLD_HEIGHT) 
                };
                
                found, neighbor_id := find_tile_id_by_pos(neighbor_pos);
                if found {
                    set_tile_as_unmined(neighbor_id);
                }
            }
        }
    }

    // Carve out some tiles around the base
    for TILE_DIRECTION_DELTAS {
        dx := it[0];
        dy := it[1];

        neighbor_pos := Vector2.{ base.pos.x + dx, base.pos.y + dy };
        neighbor_id  := get_tile_id_by_pos(neighbor_pos);

        set_tile_as_type(neighbor_id, .MINED);
    }

    return base;
}

kill_any_dwarves_touching_tile_id :: (tile_id: s32) {
    kill_pos  := get_tile_pos_by_id(tile_id);
    kill_rect := Rectangle.{ kill_pos.x, kill_pos.y, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT };
    for dwarf, dwarf_index: dwarves {
        dwarf_rect := Rectangle.{ dwarf.pos.x, dwarf.pos.y, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT };
        if CheckCollisionRecs(dwarf_rect, kill_rect) kill_dwarf_by_index(dwarf_index);
    }
}

kill_dwarf_by_index :: (dwarf_index: s64) {
    dwarf_id_being_swapped := dwarves[dwarves.count - 1].id;
    dwarf_id_being_killed  := dwarves[dwarf_index].id;

    if dwarf_id_being_swapped != dwarf_id_being_killed {
        table_set(*dwarf_id_to_index, dwarf_id_being_swapped, dwarf_index);
    }
    table_remove(*dwarf_id_to_index, dwarf_id_being_killed);

    // TODO: I kinda think we need something similar to derive_entities_in_viewport, but for chunk membership
    // dwarf         := dwarves[dwarf_index];
    // dwarf_center  := get_rect_center(get_world_rect_from_pos(dwarf.pos));
    // dwarf_tile_id := get_tile_id_by_pos(dwarf_center);
    // chunk         := find_or_create_chunk_by_tile_id(dwarf_tile_id);

    // found := false;
    // for chunk.dwarf_ids {
    //     if it == dwarf.id {
    //         found = true;
    //         array_unordered_remove_by_index(*chunk.dwarf_ids, it_index);
    //     }
    // }
    // assert(found);

    array_unordered_remove_by_index(*dwarves, dwarf_index);
}

kill_dwarf_by_id :: (dwarf_id: s32) {
    found, dwarf_index := table_find(*dwarf_id_to_index, dwarf_id);
    assert(found);
    kill_dwarf_by_index(dwarf_index);
}

get_neighbor_tile_ids :: (tile_id: s32) -> [..] s32 {
    neighbor_tile_ids : [..] s32;
    dx, dy : s32;

    for i: 0..7 {
        dx = TILE_DIRECTION_ID_DELTAS[i][0];
        dy = TILE_DIRECTION_ID_DELTAS[i][1];

        array_add(*neighbor_tile_ids, tile_id + dx + dy);
    }

    return neighbor_tile_ids;
}

get_neighbor_tile_ids_of_type :: (tile_id: s32, tile_type: TileType) -> [..] s32 {
    neighbor_tile_ids : [..] s32;
    dx, dy : s32;

    for i: 0..7 {
        dx = TILE_DIRECTION_ID_DELTAS[i][0];
        dy = TILE_DIRECTION_ID_DELTAS[i][1];

        neighbor_id := tile_id + dx + dy;

        is_fully_mined   := table_contains(*fully_mined_tile_ids_set, neighbor_id);
        is_cave          := table_contains(*cave_tile_ids_set, neighbor_id);
        is_encased       := table_contains(*encased_tile_ids_set, neighbor_id);
        is_iron          := table_contains(*iron_tile_ids_set, neighbor_id);
        is_water_still   := table_contains(*water_still_tile_ids_set, neighbor_id);
        is_water_flowing := table_contains(*water_flowing_tile_ids_set, neighbor_id);
        is_lava_still    := table_contains(*lava_still_tile_ids_set, neighbor_id);
        is_lava_flowing  := table_contains(*lava_flowing_tile_ids_set, neighbor_id);
        is_obsidian      := table_contains(*obsidian_tile_ids_set, neighbor_id);
        is_hole          := table_contains(*hole_tile_ids_set, neighbor_id);

        // TODO: make utilities for these, probably
        should_add_neighbor_to_list := false;
        if #complete tile_type == {
            case .DIRT; {
                should_add_neighbor_to_list = (
                    !is_fully_mined && 
                    !is_cave && 
                    !is_iron && 
                    is_water_still && 
                    is_water_flowing && 
                    is_lava_still && 
                    is_lava_flowing && 
                    is_obsidian
                );
            }
            case .MINED; {
                should_add_neighbor_to_list = is_fully_mined;
            }
            case .CAVE; {
                should_add_neighbor_to_list = is_cave;
            }
            case .ENCASED; {
                should_add_neighbor_to_list = is_encased;
            }
            case .WATER_STILL; {
                should_add_neighbor_to_list = is_water_still;
            }
            case .WATER_FLOWING; {
                should_add_neighbor_to_list = is_water_flowing;
            }
            case .LAVA_STILL; {
                should_add_neighbor_to_list = is_lava_still;
            }
            case .LAVA_FLOWING; {
                should_add_neighbor_to_list = is_lava_flowing;
            }
            case .IRON; {
                should_add_neighbor_to_list = is_iron;
            }
            case .OBSIDIAN; {
                should_add_neighbor_to_list = is_obsidian;
            }
            case .HOLE; {
                should_add_neighbor_to_list = is_hole;
            }
        }

        if should_add_neighbor_to_list array_add(*neighbor_tile_ids, neighbor_id);
    }

    return neighbor_tile_ids;
}

handle_encasement :: (tile_id: s32, persistent_encasing_obsidian_tile_ids_set: *Table) {
    encasing_obsidian_tile_ids_set: Table(s32, s32);
    did_encase := check_encasement(tile_id, *encasing_obsidian_tile_ids_set, persistent_encasing_obsidian_tile_ids_set);

    // If we did encase a section, find the inside portion that is encased.
    // Start by casting a ray north, the first tile *needs* to be non-obsidian. If we don't,
    // cast in the next cardinal direction. Once we find a cardinal direction that starts
    // with non-obsidian, go until out of bounds. Tally up the amount of times we intersect
    // *visited* obsidian tiles. If the crossings is odd, then this direction is inside the
    // encasement. If it is even, it is not.
    if did_encase {
        // We may have multiple directions of encasement. Consider a block being placed in
        // the middle of two, three, or even four diamonds that were only missing the spot
        // that was just placed.
        directions_of_encasement : [..]Direction;

        tile_pos := get_tile_pos_by_id(tile_id);
        dx, dy: float32;
        for i: 0..3 {
            dx = TILE_DIRECTION_DELTAS[i][0];
            dy = TILE_DIRECTION_DELTAS[i][1];

            multiplier := 1;
            encasing_hits := 0;
            should_continue_looking_in_this_direction := true;
            is_intersecting_encasing_tile := false;
            while should_continue_looking_in_this_direction {
                neighbor_pos := Vector2.{ tile_pos.x + dx * multiplier, tile_pos.y + dy * multiplier };
                found_neighbor, neighbor_id := find_tile_id_by_pos(neighbor_pos);

                if !found_neighbor { // Hit out of bounds
                    should_continue_looking_in_this_direction = false;
                } else if table_contains(*encasing_obsidian_tile_ids_set, neighbor_id) {
                    if multiplier == 1 {
                        // If we hit obsidian as the very first tile, it's cooked.
                        should_continue_looking_in_this_direction = false;
                    } else if !is_intersecting_encasing_tile {
                        is_intersecting_encasing_tile = true;
                        encasing_hits += 1;
                    }
                } else {
                    is_intersecting_encasing_tile = false;
                }
        
                multiplier += 1;
            }

            if encasing_hits % 2 == 1 array_add(*directions_of_encasement, cast(Direction) i);
        }

        for directions_of_encasement {
            tile_to_start_encasing_id := tile_id;
            if it == .NORTH tile_to_start_encasing_id -= WORLD_COLS;
            if it == .SOUTH tile_to_start_encasing_id += WORLD_COLS;
            if it == .EAST  tile_to_start_encasing_id += 1;
            if it == .WEST  tile_to_start_encasing_id -= 1;

            try_to_encase_tiles(tile_to_start_encasing_id);
        }
    }
}

check_encasement :: (tile_id: s32, encasing_obsidian_tile_ids_set: *Table, persistent_encasing_obsidian_tile_ids_set: *Table) -> (did_encase: bool) {
    encaseable_neighbor_ids := get_neighbor_tile_ids_of_type(tile_id, TileType.OBSIDIAN);
    hole_neighbor_ids       := get_neighbor_tile_ids_of_type(tile_id, TileType.HOLE);
    for hole_neighbor_ids array_add(*encaseable_neighbor_ids, it);

    // We need at least 2 adjacent obsidian tiles to form a loop
    if encaseable_neighbor_ids.count < 2 return false;

    found_any_loop := false;

    // Check pairs of neighbors to see if they connect through the existing wall.
    for i: 0..encaseable_neighbor_ids.count-2 {
        // Exclude the second neighbor from being within the orbit of the first.
        // This excludes neighbor patterns for which we couldn't have created a
        // new encasement.
        neighbor_ids_to_exclude := get_neighbor_tile_ids_of_type(encaseable_neighbor_ids[i], TileType.OBSIDIAN);

        for j: i+1..encaseable_neighbor_ids.count-1 {
            if array_find(neighbor_ids_to_exclude, encaseable_neighbor_ids[j]) continue;

            start_id := encaseable_neighbor_ids[i];
            end_id   := encaseable_neighbor_ids[j];

            // Run BFS to get an ordered array of tile IDs.
            found_at_least_one_hole, path := find_shortest_obsidian_path(start_id, end_id, tile_id);
            path_has_hole := found_at_least_one_hole || table_contains(*hole_tile_ids_set, tile_id);
            if path.count > 0 && path_has_hole {
                cycle_points: [..] Vector2;
                
                // Only build the cycle points first
                for tile: path {
                    array_add(*cycle_points, get_tile_pos_by_id(tile));
                }

                // If it actually has volume, THEN add it to the encasement table
                if check_interior_volume(cycle_points) > 0 {
                    color := Color.{
                        cast(u8) random_get_within_range(0, 255),
                        cast(u8) random_get_within_range(0, 255),
                        cast(u8) random_get_within_range(0, 255),
                        255
                    };
                    for tile: path {
                        table_set(encasing_obsidian_tile_ids_set, tile, 1738);
                        table_add(persistent_encasing_obsidian_tile_ids_set, tile, color);
                    }
                    found_any_loop = true;
                }
            }
        }
    }

    return found_any_loop;
}

// BFS of the two obsidian blocks neighboring 
find_shortest_obsidian_path :: (start_id: s32, end_id: s32, ignore_id: s32) -> found_at_least_one_hole: bool, path: [..] s32 {
    path: [..] s32;
    found_at_least_one_hole := false;

    // Track which tiles we've seen so we don't loop infinitely
    visited: Table(s32, bool);
    defer deinit(*visited);

    // Track the "parent" of each tile to reconstruct the path later
    came_from: Table(s32, s32);
    defer deinit(*came_from);

    // The BFS queue
    queue: [..] s32;
    defer array_free(queue);

    // Initialize BFS with our starting neighbor
    array_add(*queue, start_id);
    table_set(*visited, start_id, true);

    found_path := false;

    while queue.count > 0 {
        curr_id := pop_front(*queue);

        // If we reached the target neighbor, we're done searching.
        if curr_id == end_id {
            found_path = true;
            break;
        }

        for i: 0..7 {
            dx := TILE_DIRECTION_ID_DELTAS[i][0];
            dy := TILE_DIRECTION_ID_DELTAS[i][1];
            
            neighbor_id := curr_id + dx + dy; 

            // Don't step on the tile we just placed. If we could, then we wouldn't actually
            // be detecting any loops. Think about it.
            if neighbor_id == ignore_id continue;
            if !table_contains(*obsidian_tile_ids_set, neighbor_id) && !table_contains(*hole_tile_ids_set, neighbor_id) continue;
            if table_contains(*visited, neighbor_id) continue;

            if table_contains(*hole_tile_ids_set, neighbor_id) found_at_least_one_hole = true;
            table_set(*visited, neighbor_id, true);
            table_set(*came_from, neighbor_id, curr_id);
            array_add(*queue, neighbor_id);
        }
    }

    // Reconstruct the path. This is important because the Shoelace thing needs the points to be in order.
    if found_path {
        // Walk backwards from end_id to start_id using our came_from map
        curr := end_id;
        while curr != start_id {
            array_add(*path, curr);
            
            success, parent := table_find(*came_from, curr);
            assert(success, "Path reconstruction failed to find parent!");
            curr = parent;
        }
        array_add(*path, start_id);
    }

    return found_at_least_one_hole, path;
}

check_interior_volume :: (cycle: [] Vector2) -> float {
    area: float = 0;
    n := cycle.count;
    
    // Shoelace Formula
    for i: 0..n-1 {
        j := (i + 1) % n;
        area += (cycle[i].x * cycle[j].y) - (cycle[j].x * cycle[i].y);
    }
    area = abs(area) / 2.0;

    // Pick's Theorem
    boundary_points := cast(float) n;
    interior_points := area - (boundary_points / 2.0) + 1.0;

    return interior_points;
}

try_to_encase_tiles :: (starting_tile_id: s32) {
    found_liquid   : bool = false;
    ids_processed  : Table(s32, s32);
    ids_to_process : [..] s32;
    encased_ids    : [..] s32;
    array_add(*ids_to_process, starting_tile_id);

    while ids_to_process.count > 0 {
        // Get the next id to process
        id := pop_front_fast(*ids_to_process);

        // Make sure the id is valid and hasn't already been processed
        id_already_processed := table_contains(*ids_processed, id);
        if id_already_processed continue;
        if table_contains(*obsidian_tile_ids_set, id) continue;
        if table_contains(*hole_tile_ids_set, id) continue;

        // Check if this tile is liquid
        if table_contains(*water_still_tile_ids_set, id) {
            found_liquid = true;
        }

        if table_contains(*water_flowing_tile_ids_set, id) {
            found_liquid = true;
            set_tile_as_type(id, .WATER_STILL);
        }

        if table_contains(*lava_still_tile_ids_set, id) {
            found_liquid = true;
        }

        if table_contains(*lava_flowing_tile_ids_set, id) {
            found_liquid = true;
            set_tile_as_type(id, .LAVA_STILL);
        }

        // Mark it as processed and encased
        array_add(*encased_ids, id);
        table_set(*ids_processed, id, 1738);

        // Add neighbors as needing to be processed
        array_add(*ids_to_process, id - WORLD_COLS);
        array_add(*ids_to_process, id + WORLD_COLS);
        array_add(*ids_to_process, id + 1);
        array_add(*ids_to_process, id - 1);
    }

    // If we found a liquid, mark the tiles as encased
    if found_liquid {
        for encased_ids {
            chunk := find_or_create_chunk_by_tile_id(it);
            array_add(*chunk.encased_tile_ids, it);
            table_set(*encased_tile_ids_set, it, 1738);
        }
    }
}

are_all_neighbors_liquid :: (tile_id: s32) -> bool {
    north_tile_id := tile_id - WORLD_ROWS;
    south_tile_id := tile_id + WORLD_ROWS;
    east_tile_id  := tile_id + 1;
    west_tile_id  := tile_id - 1;

    is_neighbor_north_water_still := table_contains(*water_still_tile_ids_set, north_tile_id);
    is_neighbor_south_water_still := table_contains(*water_still_tile_ids_set, south_tile_id);
    is_neighbor_east_water_still  := table_contains(*water_still_tile_ids_set, east_tile_id);
    is_neighbor_west_water_still  := table_contains(*water_still_tile_ids_set, west_tile_id);

    is_neighbor_north_water_flowing := table_contains(*water_flowing_tile_ids_set, north_tile_id);
    is_neighbor_south_water_flowing := table_contains(*water_flowing_tile_ids_set, south_tile_id);
    is_neighbor_east_water_flowing  := table_contains(*water_flowing_tile_ids_set, east_tile_id);
    is_neighbor_west_water_flowing  := table_contains(*water_flowing_tile_ids_set, west_tile_id);

    is_neighbor_north_lava_still := table_contains(*lava_still_tile_ids_set, north_tile_id);
    is_neighbor_south_lava_still := table_contains(*lava_still_tile_ids_set, south_tile_id);
    is_neighbor_east_lava_still  := table_contains(*lava_still_tile_ids_set, east_tile_id);
    is_neighbor_west_lava_still  := table_contains(*lava_still_tile_ids_set, west_tile_id);

    is_neighbor_north_lava_flowing := table_contains(*lava_flowing_tile_ids_set, north_tile_id);
    is_neighbor_south_lava_flowing := table_contains(*lava_flowing_tile_ids_set, south_tile_id);
    is_neighbor_east_lava_flowing  := table_contains(*lava_flowing_tile_ids_set, east_tile_id);
    is_neighbor_west_lava_flowing  := table_contains(*lava_flowing_tile_ids_set, west_tile_id);

    is_neighbor_north_liquid := (
        is_neighbor_north_water_still   ||
        is_neighbor_north_water_flowing ||
        is_neighbor_north_lava_still    ||
        is_neighbor_north_lava_flowing
    );

    is_neighbor_south_liquid := (
        is_neighbor_south_water_still   ||
        is_neighbor_south_water_flowing ||
        is_neighbor_south_lava_still    ||
        is_neighbor_south_lava_flowing
    );

    is_neighbor_east_liquid := (
        is_neighbor_east_water_still   ||
        is_neighbor_east_water_flowing ||
        is_neighbor_east_lava_still    ||
        is_neighbor_east_lava_flowing
    );

    is_neighbor_west_liquid := (
        is_neighbor_west_water_still   ||
        is_neighbor_west_water_flowing ||
        is_neighbor_west_lava_still    ||
        is_neighbor_west_lava_flowing
    );

    return is_neighbor_north_liquid && is_neighbor_south_liquid && is_neighbor_east_liquid && is_neighbor_west_liquid;
}

try_to_set_cardinal_neighbors_as_flowing_tile_type :: (tile_id: s32, as_type: TileType) {
    tile_pos := get_tile_pos_by_id(tile_id);
    dx, dy : float;

    for i: 0..3 {
        dx = TILE_DIRECTION_DELTAS[i][0];
        dy = TILE_DIRECTION_DELTAS[i][1];
        neighbor_pos := Vector2.{ tile_pos.x + dx, tile_pos.y + dy };
        found_neighbor, neighbor_id := find_tile_id_by_pos(neighbor_pos);
        if !found_neighbor {
            print("WARN: Couldn't find neighbor for tile at pos (%,%). This either means it's on the edge of the world, or that something might be wrong.\n", neighbor_pos.x, neighbor_pos.y);
            continue;
        }

        // TODO: this is kind of terrible because if/when I add new things, I'm going to have to remember
        // to add them here. Would be good to have this automated somehow.

        tile_is_still_water := table_contains(*water_still_tile_ids_set, neighbor_id);
        if tile_is_still_water continue;

        tile_is_still_lava := table_contains(*lava_still_tile_ids_set, neighbor_id);
        if tile_is_still_lava continue;

        tile_is_flowing_water := table_contains(*water_flowing_tile_ids_set, neighbor_id);
        if tile_is_flowing_water continue;

        tile_is_flowing_lava := table_contains(*lava_flowing_tile_ids_set, neighbor_id);

        tile_is_iron := table_contains(*iron_tile_ids_set, neighbor_id);
        if tile_is_iron continue;

        tile_is_obsidian := table_contains(*obsidian_tile_ids_set, neighbor_id);
        if tile_is_obsidian continue;

        tile_is_being_mined := table_contains(*actively_mined_tile_ids_to_health_table, neighbor_id);
        if tile_is_being_mined continue;

        tile_is_empty := table_contains(*fully_mined_tile_ids_set, neighbor_id);
        if !tile_is_empty continue;

        set_tile_as_type(neighbor_id, as_type);
    }
}

FindOrCreateChunkReturnStatus :: enum u16 {
    CHUNK_WOULD_BE_OUT_OF_BOUNDS;
    CHUNK_CREATED;
    CHUNK_FOUND;
}

find_or_create_chunk_by_tile_id :: (tile_id: s32) -> *Chunk {
    world_pos := get_tile_pos_by_id(tile_id);
    chunk_x   := world_to_chunk_pos(world_pos.x, TILEMAP_GENERAL_WORLD_WIDTH);
    chunk_y   := world_to_chunk_pos(world_pos.y, TILEMAP_GENERAL_WORLD_HEIGHT);
    result, chunk := find_or_create_chunk(chunk_x, chunk_y);

    if #complete result == {
        case .CHUNK_WOULD_BE_OUT_OF_BOUNDS;
            assert(false, "Expected to find chunk for tile id %, but didn't!", tile_id);
            return null;
        case .CHUNK_CREATED; #through;
        case .CHUNK_FOUND;
            return chunk;
    }
}

find_or_create_chunk :: (chunk_x: s32, chunk_y: s32) -> (status: FindOrCreateChunkReturnStatus, chunk: *Chunk) {
    key_is_within_map_bounds, key := find_chunk_key(chunk_x, chunk_y);
    if !key_is_within_map_bounds return .CHUNK_WOULD_BE_OUT_OF_BOUNDS, null;

    found_chunk, chunk := table_find(*active_chunks, key);
    if found_chunk return .CHUNK_FOUND, chunk;

    // The chunk doesn't exist yet, so let's make a new one.
    new_chunk := New(Chunk);
    
    table_set(*active_chunks, key, new_chunk);
    
    return .CHUNK_CREATED, new_chunk;
}

find_chunk_key :: (chunk_x: s32, chunk_y: s32) -> (found: bool, key: u64) {
    if chunk_x < 0 return false, 0;
    if chunk_y < 0 return false, 0;

    x_u64 := cast(u64) cast(u32) chunk_x;
    y_u64 := cast(u64) cast(u32) chunk_y;
    
    // TODO: does endian-ness matter? Probably not?...
    // x occupies the top 32 bits, y occupies the bottom 32 bits.
    return true, (x_u64 << 32) | y_u64;
}

get_chunk_key :: (chunk_x: s32, chunk_y: s32) -> u64 {
    found, key := find_chunk_key(chunk_x, chunk_y);
    assert(found, "Expected to find chunk key, but didn't!");
    return key;
}

world_to_chunk_pos :: (world_pos: float, tile_pixel_size: float) -> s32 {
    chunk_size_in_pixels := cast(float)(CHUNK_SIZE) * tile_pixel_size;
    return cast(s32) floor(world_pos / chunk_size_in_pixels);
}

// Helper function that just uses the default width and height from globals
get_world_rect_from_pos :: (pos: Vector2) -> Rectangle {
    return Rectangle.{
        pos.x, pos.y, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT,
    };
}

get_tile_id_with_start_arrow_on_path :: (path: Path) -> s32{
    return path.start_tile_id;
}

find_tile_id_with_middle_arrow_on_path :: (path: Path) -> path_has_middle_arrow: bool, tile_id: s32 {
    is_path_straight := path.middle_tile_id == path.end_tile_id;
    if is_path_straight {
        return false, -1;
    } else {
        return true, path.middle_tile_id;
    }
}

draw_path :: (path: Path) {
    start_pos  := get_tile_pos_by_id(path.start_tile_id);
    middle_pos := get_tile_pos_by_id(path.middle_tile_id);
    end_pos    := get_tile_pos_by_id(path.end_tile_id);

    arrow_source := Rectangle.{
        2 * TILEMAP_GENERAL_TILE_WIDTH,
        0 * TILEMAP_GENERAL_TILE_HEIGHT,
        TILEMAP_GENERAL_TILE_WIDTH,
        TILEMAP_GENERAL_TILE_HEIGHT,
    };

    start_arrow_dest := Rectangle.{
        start_pos.x + TILEMAP_GENERAL_WORLD_WIDTH  * 0.5,
        start_pos.y + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5,
        TILEMAP_GENERAL_WORLD_WIDTH,
        TILEMAP_GENERAL_WORLD_HEIGHT,
    };

    start_arrow_rotation  := get_arrow_rotation(start_pos,  middle_pos);

    DrawTexturePro(tilemap_texture_general, arrow_source, start_arrow_dest, Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH * 0.5, TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 }, start_arrow_rotation,  WHITE);
    
    DrawLineEx(
        Vector2.{ start_pos.x  + TILEMAP_GENERAL_WORLD_WIDTH * 0.5, start_pos.y  + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 },
        Vector2.{ middle_pos.x + TILEMAP_GENERAL_WORLD_WIDTH * 0.5, middle_pos.y + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 },
        2.0,
        GREEN
    );

    is_path_straight := Vector2Equals(middle_pos, end_pos);

    if !is_path_straight {
        middle_arrow_dest := Rectangle.{
            middle_pos.x + TILEMAP_GENERAL_WORLD_WIDTH  * 0.5,
            middle_pos.y + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5,
            TILEMAP_GENERAL_WORLD_WIDTH,
            TILEMAP_GENERAL_WORLD_HEIGHT,
        };

        middle_arrow_rotation := get_arrow_rotation(middle_pos, end_pos);

        DrawTexturePro(tilemap_texture_general, arrow_source, middle_arrow_dest, Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH * 0.5, TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 }, middle_arrow_rotation, WHITE);

        DrawLineEx(
            Vector2.{ middle_pos.x + TILEMAP_GENERAL_WORLD_WIDTH * 0.5, middle_pos.y + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 },
            Vector2.{ end_pos.x    + TILEMAP_GENERAL_WORLD_WIDTH * 0.5, end_pos.y    + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 },
            2.0,
            GREEN
        );
    }

    END_SIDE_LENGTH :: 6.5;
    DrawRectangleV(
        Vector2.{
            end_pos.x + TILEMAP_GENERAL_WORLD_WIDTH * 0.5 - END_SIDE_LENGTH * 0.5,
            end_pos.y + TILEMAP_GENERAL_WORLD_WIDTH * 0.5 - END_SIDE_LENGTH * 0.5,
        },
        Vector2.{ END_SIDE_LENGTH, END_SIDE_LENGTH },
        GREEN
    );
}

get_path :: (from_pos: Vector2, to_pos: Vector2) -> Path {
    new_target_tile_rect := get_tile_rect_that_pos_is_within(WORLD_WIDTH, WORLD_HEIGHT, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, to_pos);
    new_target_tile_pos  := Vector2.{ new_target_tile_rect.x, new_target_tile_rect.y };
    new_target_tile_id   := get_tile_id_by_pos(new_target_tile_pos);

    tile_rect_mouse_started_on := get_tile_rect_that_pos_is_within(WORLD_WIDTH, WORLD_HEIGHT, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, from_pos);
    tile_id_mouse_started_on   := get_tile_id_by_pos(get_rect_pos(tile_rect_mouse_started_on));

    // We need to separate the dx and dy
    dx := new_target_tile_rect.x - tile_rect_mouse_started_on.x;
    dy := new_target_tile_rect.y - tile_rect_mouse_started_on.y;
    
    // Check which one is larger, that'll be the first leg
    x_is_larger := abs(dx) > abs(dy);

    middle_tile_rect := Rectangle.{
        tile_rect_mouse_started_on.x + ifx x_is_larger then dx else 0,
        tile_rect_mouse_started_on.y + ifx x_is_larger then 0 else dy,
        TILEMAP_GENERAL_WORLD_WIDTH,
        TILEMAP_GENERAL_WORLD_HEIGHT,
    };
    middle_tile_id := get_tile_id_by_pos(get_rect_pos(middle_tile_rect));

    end_tile_rect := Rectangle.{
        middle_tile_rect.x + ifx x_is_larger then 0 else dx,
        middle_tile_rect.y + ifx x_is_larger then dy else 0,
        TILEMAP_GENERAL_WORLD_WIDTH,
        TILEMAP_GENERAL_WORLD_HEIGHT,
    };
    end_tile_id := get_tile_id_by_pos(get_rect_pos(end_tile_rect));

    return Path.{
        start_tile_id  = tile_id_mouse_started_on,
        middle_tile_id = middle_tile_id,
        end_tile_id    = end_tile_id,
    };
}

get_tile_ids_along_path :: (from_pos: Vector2, to_pos: Vector2) -> [..] s32 {
    path_ids: [..] s32;

    target_rect := get_tile_rect_that_pos_is_within(WORLD_WIDTH, WORLD_HEIGHT, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, to_pos);
    from_rect   := get_tile_rect_that_pos_is_within(WORLD_WIDTH, WORLD_HEIGHT, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, from_pos);

    dx := target_rect.x - from_rect.x;
    dy := target_rect.y - from_rect.y;

    // Determine the step directions in world units
    step_x := ifx dx > 0 then TILEMAP_GENERAL_WORLD_WIDTH  else -TILEMAP_GENERAL_WORLD_WIDTH;
    step_y := ifx dy > 0 then TILEMAP_GENERAL_WORLD_HEIGHT else -TILEMAP_GENERAL_WORLD_HEIGHT;

    // Calculate the number of discrete tile steps required 
    // (+ 0.5 prevents float truncation issues if your tile widths aren't perfect integers)
    steps_x := cast(int)(abs(dx) / TILEMAP_GENERAL_WORLD_WIDTH + 0.5);
    steps_y := cast(int)(abs(dy) / TILEMAP_GENERAL_WORLD_HEIGHT + 0.5);

    x_is_larger := abs(dx) > abs(dy);

    // Start traversing from the origin of the initial tile
    current_pos := Vector2.{from_rect.x, from_rect.y};

    // 1. Add the starting tile
    array_add(*path_ids, get_tile_id_by_pos(current_pos));

    // 2. Traverse the grid, maintaining L-shaped path
    if x_is_larger {
        // Move along X axis first
        for 1..steps_x {
            current_pos.x += step_x;
            array_add(*path_ids, get_tile_id_by_pos(current_pos));
        }
        // Then move along Y axis
        for 1..steps_y {
            current_pos.y += step_y;
            array_add(*path_ids, get_tile_id_by_pos(current_pos));
        }
    } else {
        // Move along Y axis first
        for 1..steps_y {
            current_pos.y += step_y;
            array_add(*path_ids, get_tile_id_by_pos(current_pos));
        }
        // Then move along X axis
        for 1..steps_x {
            current_pos.x += step_x;
            array_add(*path_ids, get_tile_id_by_pos(current_pos));
        }
    }

    return path_ids;
}

get_arrow_rotation :: (start_pos: Vector2, end_pos: Vector2) -> float32 {
    if      start_pos.x == end_pos.x && start_pos.y > end_pos.y  return 0.0;   // north
    else if start_pos.x == end_pos.x && start_pos.y < end_pos.y  return 180.0; // south
    else if start_pos.x < end_pos.x  && start_pos.y == end_pos.y return 90.0;  // east
    else if start_pos.x > end_pos.x  && start_pos.y == end_pos.y return 270.0; // west
    else return 0.0;
}    

set_cave_as_mined :: (tile_id: s32, cave_type: CaveType) {
    tile_type : TileType;
    if #complete cave_type == {
        case .EMPTY;        tile_type = .MINED;
        case .WATER;        tile_type = .WATER_FLOWING;
        case .LAVA;         tile_type = .LAVA_FLOWING;
        case .TREASURE;     tile_type = .MINED;
        case .MINION;       tile_type = .MINED;
        case .SHAMAN;       tile_type = .MINED;
        case .SPIDER_QUEEN; tile_type = .MINED;
    }

    set_tile_as_type(tile_id, tile_type);

    // Recursively go through neighbors and set them as mined as well.
    dx, dy : float;
    tile_pos := get_tile_pos_by_id(tile_id);

    for i: 0..3 {
        dx = TILE_DIRECTION_DELTAS[i][0];
        dy = TILE_DIRECTION_DELTAS[i][1];
        neighbor_pos := Vector2.{ tile_pos.x + dx, tile_pos.y + dy };
        found_neighbor, neighbor_id := find_tile_id_by_pos(neighbor_pos);
        if !found_neighbor {
            print("WARN: Couldn't find neighbor for tile at pos (%,%). This either means it's on the edge of the world, or that something might be wrong.\n", neighbor_pos.x, neighbor_pos.y);
            continue;
        }

        tile_is_unrevealed_cave := table_contains(*cave_tile_ids_set, neighbor_id);
        if !tile_is_unrevealed_cave continue;

        set_cave_as_mined(neighbor_id, cave_type);
    }
}

set_tile_as_type :: (tile_id: s32, as_type : TileType) {
    chunk := find_or_create_chunk_by_tile_id(tile_id);

    // Remove the tile from all of the tile trackers. We will even remove it from lists that it should
    // stick around in. We put it into the one it should be right below this.
    // TODO: maybe don't do it like this? For some reason, this seems like a good idea to me right now,
    // but I could easily see this being stupid and wasteful. I guess we'll see.
    {
        // If the tile was a resource, then keep track of the gain and also remove the resource
        // from the map
        tile_was_iron := table_find(*iron_tile_ids_set, tile_id);
        if tile_was_iron {
            // TODO: give the player resources?
            array_unordered_remove_by_value(*chunk.iron_tile_ids, tile_id);
            table_remove(*iron_tile_ids_set, tile_id);
        }

        array_unordered_remove_by_value(*chunk.obsidian_tile_ids, tile_id);
        table_remove(*obsidian_tile_ids_set, tile_id);
        
        array_unordered_remove_by_value(*chunk.actively_mined_tile_ids, tile_id);
        table_remove(*actively_mined_tile_ids_to_health_table, tile_id);
        
        array_unordered_remove_by_value(*chunk.fully_mined_tile_ids, tile_id);
        table_remove(*fully_mined_tile_ids_set, tile_id);

        array_unordered_remove_by_value(*chunk.encased_tile_ids, tile_id);
        table_remove(*encased_tile_ids_set, tile_id);

        array_unordered_remove_by_value(*chunk.cave_tile_ids, tile_id);
        table_remove(*cave_tile_ids_set, tile_id);

        array_unordered_remove_by_value(*water_still_tile_ids, tile_id);
        array_unordered_remove_by_value(*chunk.water_still_tile_ids, tile_id);
        table_remove(*water_still_tile_ids_set, tile_id);

        array_unordered_remove_by_value(*water_flowing_tile_ids, tile_id);
        array_unordered_remove_by_value(*chunk.water_flowing_tile_ids, tile_id);
        table_remove(*water_flowing_tile_ids_set, tile_id);

        array_unordered_remove_by_value(*lava_still_tile_ids, tile_id);
        array_unordered_remove_by_value(*chunk.lava_still_tile_ids, tile_id);
        table_remove(*lava_still_tile_ids_set, tile_id);

        array_unordered_remove_by_value(*lava_flowing_tile_ids, tile_id);
        array_unordered_remove_by_value(*chunk.lava_flowing_tile_ids, tile_id);
        table_remove(*lava_flowing_tile_ids_set, tile_id);

        array_unordered_remove_by_value(*hole_tile_ids, tile_id);
        array_unordered_remove_by_value(*chunk.hole_tile_ids, tile_id);
        table_remove(*hole_tile_ids_set, tile_id);
    }

    // Add the tile to whatever new list it should be a part of.
    if #complete as_type == {
        case .CAVE; {
            array_add(*chunk.cave_tile_ids, tile_id);
            table_set(*cave_tile_ids_set, tile_id, 1738);
        }
        case .MINED; {
            array_add(*chunk.fully_mined_tile_ids, tile_id);
            table_set(*fully_mined_tile_ids_set, tile_id, 1738);
        }
        case .ENCASED; {
            array_add(*chunk.encased_tile_ids, tile_id);
            table_set(*encased_tile_ids_set, tile_id, 1738);
        }
        case .WATER_STILL; {
            array_add(*water_still_tile_ids, tile_id);
            array_add(*chunk.water_still_tile_ids, tile_id);
            table_set(*water_still_tile_ids_set, tile_id, 1738);
        }
        case .WATER_FLOWING; {
            array_add(*water_flowing_tile_ids, tile_id);
            array_add(*chunk.water_flowing_tile_ids, tile_id);
            table_set(*water_flowing_tile_ids_set, tile_id, 1738);
        }
        case .LAVA_STILL; {
            array_add(*lava_still_tile_ids, tile_id);
            array_add(*chunk.lava_still_tile_ids, tile_id);
            table_set(*lava_still_tile_ids_set, tile_id, 1738);
        }
        case .LAVA_FLOWING; {
            array_add(*lava_flowing_tile_ids, tile_id);
            array_add(*chunk.lava_flowing_tile_ids, tile_id);
            table_set(*lava_flowing_tile_ids_set, tile_id, 1738);
        }
        case .DIRT; #through;
        case .IRON; {
            assert(false, "Tried setting block as type %, but that doesn't really make sense.", as_type);
        }
        case .OBSIDIAN; {
            array_add(*chunk.obsidian_tile_ids, tile_id);
            table_set(*obsidian_tile_ids_set, tile_id, 1738);
        }
        case .HOLE; {
            array_add(*hole_tile_ids, tile_id);
            array_add(*chunk.hole_tile_ids, tile_id);
            table_set(*hole_tile_ids_set, tile_id, 1738);
        }
    }

    if #complete as_type == {
        // Add edges for pathing to any neighbors who are also open
        case .CAVE; #through;
        case .MINED;
            dx, dy : float;
            tile_pos := get_tile_pos_by_id(tile_id);

            for i: 0..3 {
                dx = TILE_DIRECTION_DELTAS[i][0];
                dy = TILE_DIRECTION_DELTAS[i][1];
                neighbor_pos := Vector2.{ tile_pos.x + dx, tile_pos.y + dy };
                found_neighbor, neighbor_id := find_tile_id_by_pos(neighbor_pos);
                if !found_neighbor {
                    print("WARN: Couldn't find neighbor for tile at pos (%,%). This either means it's on the edge of the world, or that something might be wrong.\n", neighbor_pos.x, neighbor_pos.y);
                    continue;
                }

                neighbor_is_mined := table_contains(*fully_mined_tile_ids_set, neighbor_id);

                if neighbor_is_mined {
                    // TODO: this is pretty fucked up to add these edges both ways, I think
                    array_add(*edges, Edge.{ from = tile_id,     to = neighbor_id, distance = 1 });
                    array_add(*edges, Edge.{ from = neighbor_id, to = tile_id, distance = 1 });
                }
            }

        // Remove edges for pathing to all neighbors
        case .ENCASED;  #through;
        case .OBSIDIAN; #through;
        case .HOLE; #through;
        case .DIRT;     #through;
        case .IRON;
            dx, dy : float;
            tile_pos := get_tile_pos_by_id(tile_id);

            for edges {
                if it.from == tile_id || it.to == tile_id {
                    array_unordered_remove_by_index(*edges, it_index);
                }
            }

        // No op
        case .WATER_STILL;   #through;
        case .WATER_FLOWING; #through;
        case .LAVA_STILL;    #through;
        case .LAVA_FLOWING;
    }
}

set_tile_as_unmined :: (tile_id: s32) {
    chunk := find_or_create_chunk_by_tile_id(tile_id);

    // Remove from the fully mined lists, turning it back into solid dirt
    array_unordered_remove_by_value(*chunk.fully_mined_tile_ids, tile_id);
    array_unordered_remove_by_value(*chunk.cave_tile_ids, tile_id);
    table_remove(*fully_mined_tile_ids_set, tile_id);
    table_remove(*cave_tile_ids_set, tile_id);

    // Clean up pathfinding edges connected to this tile.
    // We iterate backwards (`for <`) because we are removing elements from the array inline.
    for < i: 0..edges.count-1 {
        if edges[i].from == tile_id || edges[i].to == tile_id {
            array_unordered_remove_by_index(*edges, i);
        }
    }
}

// Flood fill
spawn_iron :: (
    starting_tile_id: s32, 
    vein_size_min: s32, 
    vein_size_max: s32, 
    world_columns: s32, 
    world_rows: s32, 
    active_chunks: *Table,
    iron_tile_ids_set : *Table
) {
    size := cast(int) random_get_within_range(xx vein_size_min, xx vein_size_max);
    max_tile_id := world_columns * world_rows;

    ids_to_process : [..] s32;
    array_add(*ids_to_process, starting_tile_id);
    ids_processed  : [..] s32;

    while ids_to_process.count > 0 && size > 0 {
        // Get the next id to process
        id := pop_front(*ids_to_process);

        // Make sure the id is valid and hasn't already been processed
        id_already_processed := array_find(ids_processed, id);
        if id_already_processed continue;
        if id <= 0 continue;
        if id > max_tile_id continue;

        // Get the chunk this happened in
        chunk := find_or_create_chunk_by_tile_id(id);

        // Mark the tile id as iron
        array_add(*chunk.iron_tile_ids, id);
        table_set(iron_tile_ids_set, id, 0);

        // Mark it as processed
        array_add(*ids_processed, id);
        size -= 1;

        // Add neighbors as needing to be processed
        array_add(*ids_to_process, id - world_columns);
        array_add(*ids_to_process, id + world_columns);
        array_add(*ids_to_process, id + 1);
        array_add(*ids_to_process, id - 1);
    }
}

derive_entities_in_viewport :: (camera: Camera2D) {
    window_start := GetScreenToWorld2D(Vector2.{ 0, 0 }, camera);
    window_end   := GetScreenToWorld2D(Vector2.{ cast(float) GetScreenWidth(), cast(float) GetScreenHeight()}, camera);

    array_reset(*fully_mined_tile_ids_in_viewport);
    array_reset(*cave_tile_ids_in_viewport);
    array_reset(*encased_tile_ids_in_viewport);
    array_reset(*actively_mined_tile_ids_in_viewport);
    array_reset(*iron_tile_ids_in_viewport);
    array_reset(*obsidian_tile_ids_in_viewport);
    array_reset(*water_still_tile_ids_in_viewport);
    array_reset(*water_flowing_tile_ids_in_viewport);
    array_reset(*lava_still_tile_ids_in_viewport);
    array_reset(*lava_flowing_tile_ids_in_viewport);
    array_reset(*bases_in_viewport);
    array_reset(*dwarves_in_viewport);
    array_reset(*tiles_with_dynamite_ids_in_viewport);
    array_reset(*hole_tile_ids_in_viewport);
    
    // Calculate chunk dimensions in pixels
    chunk_pixel_width  := cast(float)(CHUNK_SIZE) * TILEMAP_GENERAL_WORLD_WIDTH;
    chunk_pixel_height := cast(float)(CHUNK_SIZE) * TILEMAP_GENERAL_WORLD_HEIGHT;

    // Convert camera world bounds to chunk coordinates
    // NOTE Using floor() is critical here so negative world coordinates map to the correct chunks.
    start_chunk_x := cast(s32) floor(window_start.x / chunk_pixel_width);
    end_chunk_x   := cast(s32) floor(window_end.x   / chunk_pixel_width);
    
    start_chunk_y := cast(s32) floor(window_start.y / chunk_pixel_height);
    end_chunk_y   := cast(s32) floor(window_end.y   / chunk_pixel_height);

    for cy: start_chunk_y..end_chunk_y {
        for cx: start_chunk_x..end_chunk_x {
            
            key_was_valid, key := find_chunk_key(cx, cy);
            // This happens if the camera is looking out of bounds.
            if !key_was_valid continue;

            found, chunk := table_find(*active_chunks, key);
            // If the chunk doesn't exist, nobody has mined or walked here, so just move on.
            if !found continue; 

            // Fully mined tiles
            for tile_id: chunk.fully_mined_tile_ids {
                pos := get_tile_pos_by_id(tile_id);

                if pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
                if pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
                if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
                if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

                array_add(*fully_mined_tile_ids_in_viewport, tile_id);
            }

            // Cave tiles
            for tile_id: chunk.cave_tile_ids {
                pos := get_tile_pos_by_id(tile_id);

                if pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
                if pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
                if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
                if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

                array_add(*cave_tile_ids_in_viewport, tile_id);
            }

            // Encased tiles
            for tile_id: chunk.encased_tile_ids {
                pos := get_tile_pos_by_id(tile_id);

                if pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
                if pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
                if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
                if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

                array_add(*encased_tile_ids_in_viewport, tile_id);
            }

            // Actively mined tiles
            for tile_id: chunk.actively_mined_tile_ids {
                pos := get_tile_pos_by_id(tile_id);

                if pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
                if pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
                if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
                if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

                array_add(*actively_mined_tile_ids_in_viewport, tile_id);
            }

            // Iron tiles
            for tile_id: chunk.iron_tile_ids {
                pos := get_tile_pos_by_id(tile_id);

                if pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
                if pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
                if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
                if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

                array_add(*iron_tile_ids_in_viewport, tile_id);
            }

            // Obsidian tiles
            for tile_id: chunk.obsidian_tile_ids {
                pos := get_tile_pos_by_id(tile_id);

                if pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
                if pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
                if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
                if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

                array_add(*obsidian_tile_ids_in_viewport, tile_id);
            }

            // Water still tiles
            for tile_id: chunk.water_still_tile_ids {
                pos := get_tile_pos_by_id(tile_id);

                if pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
                if pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
                if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
                if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

                array_add(*water_still_tile_ids_in_viewport, tile_id);
            }

            // Water flowing tiles
            for tile_id: chunk.water_flowing_tile_ids {
                pos := get_tile_pos_by_id(tile_id);

                if pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
                if pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
                if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
                if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

                array_add(*water_flowing_tile_ids_in_viewport, tile_id);
            }

            // Lava still tiles
            for tile_id: chunk.lava_still_tile_ids {
                pos := get_tile_pos_by_id(tile_id);

                if pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
                if pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
                if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
                if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

                array_add(*lava_still_tile_ids_in_viewport, tile_id);
            }

            // Lava flowing tiles
            for tile_id: chunk.lava_flowing_tile_ids {
                pos := get_tile_pos_by_id(tile_id);

                if pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
                if pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
                if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
                if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

                array_add(*lava_flowing_tile_ids_in_viewport, tile_id);
            }

            // Hole tiles
            for tile_id: chunk.hole_tile_ids {
                pos := get_tile_pos_by_id(tile_id);

                if pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
                if pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
                if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
                if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

                array_add(*hole_tile_ids_in_viewport, tile_id);
            }

            // Bases
            for base_id: chunk.base_ids {
                base := bases[base_id];

                if base.pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
                if base.pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
                if base.pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
                if base.pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

                array_add(*bases_in_viewport, base);
            }

            // // Dwarves
            // for dwarf_id: chunk.dwarf_ids {
            //     found, dwarf_index := table_find(*dwarf_id_to_index, dwarf_id);
            //     assert(found);
            //     dwarf := dwarves[dwarf_index];

            //     if dwarf.pos.x + TILEMAP_GENERAL_WORLD_WIDTH < window_start.x continue;
            //     if dwarf.pos.x - TILEMAP_GENERAL_WORLD_WIDTH > window_end.x continue;
            //     if dwarf.pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y continue;
            //     if dwarf.pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

            //     array_add(*dwarves_in_viewport, dwarf);
            // }

            // TODO
            // // --- Dynamite ---
            // for dwarf: chunk.dwarves {
            //     pos := dwarf.pos;

            //     if pos.x + TILEMAP_GENERAL_WORLD_WIDTH < window_start.x continue;
            //     if pos.x - TILEMAP_GENERAL_WORLD_WIDTH > window_end.x continue;
            //     if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y continue;
            //     if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

            //     array_add(*dwarves_in_viewport, dwarf);
            // }
        }
    }

    // // Derive viewable bases
    // {
    //     for base: bases {
    //         pos := base.pos;

    //         if pos.x + TILEMAP_GENERAL_WORLD_WIDTH < window_start.x continue;
    //         if pos.x - TILEMAP_GENERAL_WORLD_WIDTH > window_end.x continue;
            
    //         if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y continue;
    //         if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

    //         array_add(*bases_in_viewport, base);
    //     }
    // }

    // Derive viewable dwarves
    {
        for dwarf: dwarves {
            pos := dwarf.pos;

            if pos.x + TILEMAP_GENERAL_WORLD_WIDTH < window_start.x continue;
            if pos.x - TILEMAP_GENERAL_WORLD_WIDTH > window_end.x continue;
            
            if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y continue;
            if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

            array_add(*dwarves_in_viewport, dwarf);
        }
    }

    // Derive viewable dynamite
    {
        for dynamite_tile_id: tiles_with_dynamite_ids {
            pos := get_tile_pos_by_id(dynamite_tile_id);

            if pos.x + TILEMAP_GENERAL_WORLD_WIDTH < window_start.x continue;
            if pos.x - TILEMAP_GENERAL_WORLD_WIDTH > window_end.x continue;
            
            if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y continue;
            if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

            array_add(*tiles_with_dynamite_ids_in_viewport, dynamite_tile_id);
        }
    }
}

reveal_cave_if_necessary :: (tile_id: s32) {
    check_is_neighbor_unreavealed_cave :: (tile_id: s32) -> found_cave_neighbor: bool, cave_neighbor_id: s32 {
        for i: 0..3 {
            dx := TILE_DIRECTION_DELTAS[i][0];
            dy := TILE_DIRECTION_DELTAS[i][1];
            
            tile_pos     := get_tile_pos_by_id(tile_id);
            neighbor_pos := Vector2.{ tile_pos.x + dx, tile_pos.y + dy };
            neighbor_id  := get_tile_id_by_pos(neighbor_pos);

            neighbor_is_unrevealed_cave := table_contains(*cave_tile_ids_set, neighbor_id);
            if neighbor_is_unrevealed_cave return true, neighbor_id;
        }

        return false, 1738;
    }

    neighbor_is_unrevealed_cave, cave_tile_id := check_is_neighbor_unreavealed_cave(tile_id);
    if neighbor_is_unrevealed_cave {
        // First, decide what kind of cave this will be.
        cave_type : CaveType = cast(CaveType) cast(int) random_get_within_range(0, xx enum_count(CaveType));

        // Second, recursively reveal the tiles of the cave.
        set_cave_as_mined(cave_tile_id, cave_type);
    }
}

get_rect_center :: (rect: Rectangle) -> Vector2 {
    return Vector2.{ rect.x + rect.width/2, rect.y + rect.height/2 };
}

get_pos_from_thing_with_rect :: (rect_enjoyer: $T/interface HasPos) -> Vector2 {
    return Vector2.{ rect_enjoyer.rect.x, rect_enjoyer.rect.y };
}

set_pos_of_thing_with_rect :: (rect_enjoyer: *$T/interface HasPos, x: float, y: float) {
    rect_enjoyer.rect.x = x;
    rect_enjoyer.rect.y = y;
}

set_pos_of_thing_with_rect :: (rect_enjoyer: *$T/interface HasPos, pos: Vector2) {
    rect_enjoyer.rect.x = pos.x;
    rect_enjoyer.rect.y = pos.y;
}

get_tile_rect_that_pos_is_within :: (world_width: int, world_height: int, tile_width: int, tile_height: int, mouse_pos_in_world: Vector2) -> Rectangle {
    grid_col := cast(int)(mouse_pos_in_world.x / tile_width);
    grid_row := cast(int)(mouse_pos_in_world.y / tile_height);

    // Calculate the top-left pixel position of that specific tile
    tile_x := grid_col * tile_width;
    tile_y := grid_row * tile_height;

    return Rectangle.{ xx tile_x, xx tile_y, xx tile_width, xx tile_height };
}

get_tile_pos_by_id_slow :: (id: s32) -> Vector2 {
    index := id - 1; 

    grid_x := index % WORLD_COLS; // Remainder = Column
    grid_y := index / WORLD_COLS; // Integer Div = Row

    pixel_x := cast(float32) grid_x * TILEMAP_GENERAL_WORLD_WIDTH;
    pixel_y := cast(float32) grid_y * TILEMAP_GENERAL_WORLD_HEIGHT;

    return Vector2.{ pixel_x, pixel_y };
}

get_tile_pos_by_id :: inline (id: s32) -> Vector2 {
    index := id - 1;

    // Bitwise AND (&) acts as Modulo to get the X column
    grid_x := index & WORLD_COLS_MASK; 
    
    // Right Shift (>>) acts as Division to get the Y row
    grid_y := index >> WORLD_COLS_SHIFT; 

    pixel_x := cast(float32) grid_x * TILE_WIDTH_F;
    pixel_y := cast(float32) grid_y * TILE_HEIGHT_F;

    return Vector2.{ pixel_x, pixel_y };
}

get_tile_id_by_pos :: (pos: Vector2) -> s32 {
    found_tile, tile_id := find_tile_id_by_pos(pos);
    assert(found_tile);
    return tile_id;
}

find_tile_id_by_pos :: (pos: Vector2) -> found_tile: bool, tile_id: s32 {
    grid_x := cast(s32) (pos.x / TILEMAP_GENERAL_WORLD_WIDTH);
    grid_y := cast(s32) (pos.y / TILEMAP_GENERAL_WORLD_HEIGHT);

    if grid_x < 0 || grid_x >= WORLD_COLS return false, 0;
    if grid_y < 0 || grid_y >= WORLD_ROWS return false, 0;

    index := (grid_y * WORLD_COLS) + grid_x;

    return true, index + 1;
}

get_rect_pos :: (rect: Rectangle) -> Vector2 {
    return { rect.x, rect.y };
}

/**
 * frequency: how many blocks before the next gradient. The higher the frequency, the less blocks in between gradients
 */
perlin_noise_2d :: ($DESIRED_VALUES: s32, starting_frequency: s32 = 1, starting_amplitude: float32 = 1.0, octaves: s32 = 1) -> perlin_2d: [] float {
    assert(DESIRED_VALUES > 0,     "You probably want a positive DESIRED_VALUES. If not, delete this assertion.");
    assert(starting_frequency > 0, "You probably want a positive starting_frequency. If not, delete this assertion.");
    assert(octaves > 0,            "You probably want a positive octaves. If not, delete this assertion.");
    assert(DESIRED_VALUES % starting_frequency == 0, "The perlin noise frequency must be a divisor of the number of desired values.");

    results : [..] float;
    random_grid_gradients: [..] Vector2;
    for i: 0..(DESIRED_VALUES * DESIRED_VALUES - 1) {
        array_add(*results, 0.0);
    }

    for octave: 1..octaves {
        random_grid_gradients.count = 0;

        octave_factor       := pow(2.0, cast(float) octave - 1);
        amplitude           := starting_amplitude / octave_factor;
        frequency           := cast(int) (starting_frequency * octave_factor);
        blocks_per_section  := cast(int) (DESIRED_VALUES / frequency);
        max_raw_noise_value := blocks_per_section * sqrt(2) / 2;

        assert(blocks_per_section > 0, "Got zero blocks per section during 2d perlin noise generation. You probably have too many octaves.");
        
        for row: 0..frequency {
            for col: 0..frequency {
                gradient_x := random_get_within_range(-1.0, 1.0);
                gradient_y := random_get_within_range(-1.0, 1.0);
                gradient   := Vector2Normalize(Vector2.{ gradient_x, gradient_y });

                array_add(*random_grid_gradients, gradient);
            }
        }

        for row: 0..DESIRED_VALUES-1 {
            for col: 0..DESIRED_VALUES-1 {
                curr := Vector2.{ xx col, xx row };
                
                // The absolute coordinates of the current grid's corners that the point is within. 
                north_west := Vector2.{ xx (col - (col % blocks_per_section)), xx (row - (row % blocks_per_section)) }; 
                north_east := Vector2.{ xx (col - (col % blocks_per_section) + blocks_per_section), xx (row - (row % blocks_per_section)) };
                south_west := Vector2.{ xx (col - (col % blocks_per_section)), xx (row - (row % blocks_per_section) + blocks_per_section) };
                south_east := Vector2.{ xx (col - (col % blocks_per_section) + blocks_per_section), xx (row - (row % blocks_per_section) + blocks_per_section) };
                
                // The absolute distance between the current point and the grid's corners.
                north_west_delta := Vector2Subtract(north_west, curr);
                north_east_delta := Vector2Subtract(north_east, curr);
                south_west_delta := Vector2Subtract(south_west, curr);
                south_east_delta := Vector2Subtract(south_east, curr);

                // The indices of the array holding the gradient vectors for each of the grid corners.
                north_west_gradient_index := cast(int) ((north_west.x / blocks_per_section) + (north_west.y / blocks_per_section * (frequency + 1)));
                north_east_gradient_index := cast(int) ((north_east.x / blocks_per_section) + (north_east.y / blocks_per_section * (frequency + 1)));
                south_west_gradient_index := cast(int) ((south_west.x / blocks_per_section) + (south_west.y / blocks_per_section * (frequency + 1)));
                south_east_gradient_index := cast(int) ((south_east.x / blocks_per_section) + (south_east.y / blocks_per_section * (frequency + 1)));

                // The gradient vectors for each of the grid corners.
                north_west_gradient := random_grid_gradients[north_west_gradient_index];
                north_east_gradient := random_grid_gradients[north_east_gradient_index];
                south_west_gradient := random_grid_gradients[south_west_gradient_index];
                south_east_gradient := random_grid_gradients[south_east_gradient_index];

                // The dot product of each gradient vector with the corresponding distance vector.
                north_west_dot := dot_product(north_west_gradient, north_west_delta);
                north_east_dot := dot_product(north_east_gradient, north_east_delta);
                south_west_dot := dot_product(south_west_gradient, south_west_delta);
                south_east_dot := dot_product(south_east_gradient, south_east_delta);

                // Percent traveled the grid in each direction. So if 30% of the way through the x coords,
                // t_x would be 0.300000.
                t_x := abs((curr.x - north_west.x) / blocks_per_section);
                t_y := abs((curr.y - north_west.y) / blocks_per_section);

                north_lerp := lerp(north_west_dot, north_east_dot, smootherstep(t_x));
                south_lerp := lerp(south_west_dot, south_east_dot, smootherstep(t_x));
                perlin     := lerp(north_lerp, south_lerp, smootherstep(t_y));

                results[row * DESIRED_VALUES + col] += amplitude * (perlin / max_raw_noise_value);
            }
        }
    }

    return results;
}

smootherstep :: (x: float) -> float {
    if x <= 0.0 return 0.0;
    if x >= 1.0 return 1.0;
    return (6 * x * x * x * x * x) - (15 * x * x * x * x) + (10 * x * x * x); 
}
