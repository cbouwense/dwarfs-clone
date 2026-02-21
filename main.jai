#import "Basic";
#import "Hash_Table";
#import "Input";
#import "Math";
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
CAMERA_ZOOM_SPEED :: 0.3;

DIRT_HEALTH :: 100;

DWARF_COUNT :: 1;
DWARF_MOVE_SPEED :: 15 * 1;
DWARF_MINE_COOLDOWN_MS :: 250;
DWARF_MINE_DAMAGE_PER_SWING :: 50;

TILEMAP_GENERAL_MAP_WIDTH    :: 320;
TILEMAP_GENERAL_MAP_HEIGHT   :: 320;
TILEMAP_GENERAL_TILE_WIDTH   :: 18;
TILEMAP_GENERAL_TILE_HEIGHT  :: 18;
TILEMAP_GENERAL_TILE_PADDING :: 2;
TILEMAP_GENERAL_WORLD_WIDTH  :: (TILEMAP_GENERAL_TILE_WIDTH - TILEMAP_GENERAL_TILE_PADDING) * SCALE;
TILEMAP_GENERAL_WORLD_HEIGHT :: (TILEMAP_GENERAL_TILE_HEIGHT - TILEMAP_GENERAL_TILE_PADDING) * SCALE;

WORLD_COLS :: 10000;
WORLD_ROWS :: 10000;
WORLD_WIDTH  :: WORLD_COLS * TILEMAP_GENERAL_WORLD_WIDTH;
WORLD_HEIGHT :: WORLD_ROWS * TILEMAP_GENERAL_WORLD_HEIGHT;

SCALE :: 1;

TRANSPARENT_WHITE :: Color.{ 255, 255, 255, 100 };

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

select              : bool;
drag_to_create_path : bool;
drag_cam_pressed    : bool;
drag_cam_down       : bool;
move_camera_up      : bool;
move_camera_down    : bool;
move_camera_left    : bool;
move_camera_right   : bool;

drag_to_create_path_prev : bool;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Other
////////////////////////////////////////////////////////////////////////////////////////////////////

global_id_counter      : s32;
global_tile_id_counter : s32;

global_tile_pos_to_tile     : Table(string, *Tile);
global_tile_id_to_tile      : Table(s32, *Tile);
// TODO: maybe...
// global_tile_id_to_entity    : Table(s32, *Entity);
global_tile_id_to_neighbors : Table(s32, *[..] *Tile);

mouse_drag_began_at_pos : Vector2;

GameState :: struct {
    dwarf_selected : *Dwarf;
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

Entity :: struct {
    id   : s32;
    pos  : Vector2;

    sprite_rect   : Rectangle;
    bounding_rect : Rectangle; // Used for collision

    texture_map_source_pos : Vector2;
}

// This is the interface thing
HasRect :: struct {
    rect : Rectangle;
}

Base :: struct {
    rect : Rectangle;
}

Tile :: struct {
    rect : Rectangle;
}

DwarfState :: enum {
    IDLE;
    MOVING;
    MINING;
}

Dwarf :: struct {
    rect               : Rectangle;
    state              : DwarfState;
    tile_ids_on_path   : [..] s32;
    mining_cooldown_ms : s32;
    tile_id_mining     : s32;
    direction          : Direction;
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
fully_mined_tile_ids          : [..] s32;
fully_mined_tile_ids_set      : Table(s32, Any); // for fast lookups
fully_mined_tile_ids_viewable : [..] s32;

actively_mined_tile_ids                 : [..] s32;
actively_mined_tile_ids_to_health_table : Table(s32, s32);
actively_mined_tile_ids_viewable        : [..] s32;

bases            : [..] Base;
bases_viewable   : [..] Base;
dwarves          : [..] *Dwarf;
dwarves_viewable : [..] *Dwarf;

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
        controls.drag_to_create_path[0] = Control.{ type = MouseButton, value = cast(s32) MouseButton.MOUSE_BUTTON_LEFT  };

        controls.drag_cam[0]            = Control.{ type = MouseButton, value = cast(s32) MouseButton.MOUSE_BUTTON_RIGHT  };
        controls.drag_cam[1]            = Control.{ type = MouseButton, value = cast(s32) MouseButton.MOUSE_BUTTON_MIDDLE };

        controls.move_camera_up[0]      = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_UP    };
        controls.move_camera_up[1]      = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_W     };

        controls.move_camera_down[0]    = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_DOWN  };
        controls.move_camera_down[1]    = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_S     };

        controls.move_camera_left[0]    = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_LEFT  };
        controls.move_camera_left[1]    = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_A     };

        controls.move_camera_right[0]   = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_RIGHT };
        controls.move_camera_right[1]   = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_D     };
    }

    // Initialize game
    game_state := GameState.{
        dwarf_selected = null,
    };

    // Initialize base
    {
        home_base := New(Base);
        home_base.rect = Rectangle.{
            WORLD_COLS * TILEMAP_GENERAL_WORLD_WIDTH  / 2,
            WORLD_ROWS * TILEMAP_GENERAL_WORLD_HEIGHT / 2,
            TILEMAP_GENERAL_WORLD_WIDTH,
            TILEMAP_GENERAL_WORLD_HEIGHT,
        };

        array_add(*bases, home_base);

        // Carve out some tiles around the base
        for TILE_DIRECTION_DELTAS {
            dx := it[0];
            dy := it[1];

            home_base_pos := get_pos_from_thing_with_rect(home_base);
            neighbor_pos := Vector2.{ home_base_pos.x + dx, home_base_pos.y + dy };
            neighbor_id := get_tile_id_by_pos(neighbor_pos);

            set_tile_as_mined(*fully_mined_tile_ids, *fully_mined_tile_ids_set, neighbor_id);
        }

        // print_vars(fully_mined_tile_ids);
    }

    // Initialize dwarves
    for 1..DWARF_COUNT {
        first_dwarf := New(Dwarf);

        // Figure out where to spawn it based off of the home base
        dx := TILE_DIRECTION_DELTAS[0][0];
        dy := TILE_DIRECTION_DELTAS[0][1];
        home_base_pos := get_pos_from_thing_with_rect(bases[0]);
        neighbor_pos  := Vector2.{ home_base_pos.x + dx, home_base_pos.y + dy };

        first_dwarf.rect = Rectangle.{
            neighbor_pos.x, neighbor_pos.y,
            TILEMAP_GENERAL_WORLD_WIDTH,
            TILEMAP_GENERAL_WORLD_HEIGHT,
        };
        first_dwarf.state = .MOVING;
        first_dwarf.direction = .SOUTH;
        // first_dwarf.direction = cast(Direction) cast(int) random_get_within_range(0, 3);
        // first_dwarf.tile_ids_on_path intentionally not set

        array_add(*dwarves, first_dwarf);
    }

    // Initialize camera
    camera: Camera2D;
    camera.target   = get_pos_from_thing_with_rect(bases[0]);
    camera.offset   = Vector2.{ 800, 450 };
    camera.rotation = 0.0;
    camera.zoom     = 2;

    while !WindowShouldClose() {
        reset_temporary_storage();

        time  := GetTime();
        dt_seconds := GetFrameTime();

        mouse_pos_in_ui    := GetMousePosition();
        mouse_pos_in_world := GetScreenToWorld2D(mouse_pos_in_ui, camera);
        mouse_wheel_move   := GetMouseWheelMove();

        //
        // Input
        //
        {
            // Metagame controls
            if IsKeyPressed(.KEY_P) paused     = !paused;
            if IsKeyPressed(.KEY_G) debug_mode = !debug_mode;

            // Previous controls
            drag_to_create_path_prev = drag_to_create_path;

            // Game controls
            select              = control_is_pressed(controls.drag_to_create_path);
            drag_to_create_path = control_is_down(controls.drag_to_create_path);
            drag_cam_pressed    = control_is_pressed(controls.drag_cam);
            drag_cam_down       = control_is_down(controls.drag_cam);
            move_camera_up      = control_is_down(controls.move_camera_up);
            move_camera_down    = control_is_down(controls.move_camera_down);
            move_camera_left    = control_is_down(controls.move_camera_left);
            move_camera_right   = control_is_down(controls.move_camera_right);

            if drag_to_create_path {
                if select {
                    // TODO: really, what we should do here instead of iterating through every dwarf is
                    // to have a mapping of tile rects to dwarves, and maintain that every frame by finding
                    // the tile a dwarf's center is over, and setting it in the mapping. But, this is fine
                    // for now.
                    for dwarf: dwarves_viewable {
                        if CheckCollisionPointRec(mouse_pos_in_world, dwarf.rect) {
                            game_state.dwarf_selected = dwarf;
                            break;
                        }
                    }

                    // Teleport dwarf to tile we are hovering over
                    game_state.dwarf_selected.rect = get_tile_rect_that_pos_is_within(WORLD_WIDTH, WORLD_HEIGHT, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, mouse_pos_in_world);
                }
            } else if drag_to_create_path_prev {
                assert(game_state.dwarf_selected != null, "Tried to set dwarf's target but got null");
                
                array_reset(*(game_state.dwarf_selected.tile_ids_on_path));

                new_target_tile_rect := get_tile_rect_that_pos_is_within(WORLD_WIDTH, WORLD_HEIGHT, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, mouse_pos_in_world);
                new_target_tile_pos := Vector2.{ new_target_tile_rect.x, new_target_tile_rect.y };
                new_target_tile_id := get_tile_id_by_pos(new_target_tile_pos);

                tile_rect_that_dwarf_is_currently_on := get_tile_rect_that_pos_is_within(WORLD_WIDTH, WORLD_HEIGHT, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, get_pos_from_thing_with_rect(game_state.dwarf_selected));
                tile_id_dwarf_is_currently_on := get_tile_id_by_pos(get_rect_pos(tile_rect_that_dwarf_is_currently_on));
                
                // We need to separate the dx and dy
                dx := new_target_tile_rect.x - tile_rect_that_dwarf_is_currently_on.x;
                dy := new_target_tile_rect.y - tile_rect_that_dwarf_is_currently_on.y;

                // Check which one is larger, that'll be the first leg
                x_is_larger := abs(dx) > abs(dy);

                target_tile_rect := Rectangle.{
                    tile_rect_that_dwarf_is_currently_on.x + ifx x_is_larger then dx else 0,
                    tile_rect_that_dwarf_is_currently_on.y + ifx x_is_larger then 0 else dy,
                    TILEMAP_GENERAL_WORLD_WIDTH,
                    TILEMAP_GENERAL_WORLD_HEIGHT,
                };
                target_tile_id := get_tile_id_by_pos(get_rect_pos(target_tile_rect));
                array_add(*game_state.dwarf_selected.tile_ids_on_path, target_tile_id);
                
                target_tile_rect = Rectangle.{
                    target_tile_rect.x + ifx x_is_larger then 0 else dx,
                    target_tile_rect.y + ifx x_is_larger then dy else 0,
                    TILEMAP_GENERAL_WORLD_WIDTH,
                    TILEMAP_GENERAL_WORLD_HEIGHT,
                };
                target_tile_id = get_tile_id_by_pos(get_rect_pos(target_tile_rect));
                array_add(*game_state.dwarf_selected.tile_ids_on_path, target_tile_id);

                game_state.dwarf_selected = null;
            }
        }

        derive_viewable_entities(
            camera,
            fully_mined_tile_ids,    *fully_mined_tile_ids_viewable,
            actively_mined_tile_ids, *actively_mined_tile_ids_viewable,
            bases,                   *bases_viewable,
            dwarves,                 *dwarves_viewable
        );

        //
        // Update
        //
        if !paused {
            // Update camera
            {
                CAMERA_ZOOM_INCREMENT :: 0.2;
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

                camera.zoom += mouse_wheel_move * CAMERA_ZOOM_INCREMENT;
                camera.zoom = clamp(camera.zoom, CAMERA_ZOOM_MIN, CAMERA_ZOOM_MAX);

                camera.offset = Vector2.{ GetScreenWidth() / 2.0, GetScreenHeight() / 2.0 };
            }

            // Update dwarves
            {
                for dwarf: dwarves {
                    if #complete dwarf.state == {
                        case .MOVING;
                            dwarf_has_target := dwarf.tile_ids_on_path.count > 0;
                            if dwarf_has_target {
                                target_tile_pos := get_tile_pos_by_id(dwarf.tile_ids_on_path[0]);

                                dwarf_reached_target := values_are_close(
                                    get_pos_from_thing_with_rect(dwarf),
                                    target_tile_pos,
                                    1
                                );

                                if dwarf_reached_target {
                                    set_pos_of_thing_with_rect(dwarf, target_tile_pos);
                                    array_ordered_remove_by_index(*(dwarf.tile_ids_on_path), 0);
                                } else {
                                    // If the dwarf has not reached its target yet, then simply continue on to the target

                                    // Calculate the position change that the dwarf can accomplish this frame
                                    current_pos     := get_pos_from_thing_with_rect(dwarf);
                                    target_pos      := get_tile_pos_by_id(dwarf.tile_ids_on_path[0]);
                                    delta           := Vector2Subtract(target_pos, current_pos);
                                    direction       := Vector2Normalize(delta);
                                    movement_vector := Vector2Scale(direction, DWARF_MOVE_SPEED * dt_seconds);
                                    new_pos         := Vector2Add(current_pos, movement_vector);

                                    dwarf_center := get_rect_center(dwarf.rect);

                                    // Create a probe point just outside the dwarf's bounding box.
                                    // We multiply the normalized 'direction' by 8.0 (half the dwarf's size) 
                                    // plus a tiny epsilon (0.1) so it pokes out into the next tile.
                                    PROBE_DISTANCE :: TILEMAP_GENERAL_WORLD_WIDTH / 2 + 0.1; 
                                    probe_offset   := Vector2Scale(direction, PROBE_DISTANCE);
                                    probe_pos      := Vector2Add(dwarf_center, probe_offset);

                                    // Check whether the rect the dwarf may be entering into. If it's dirt, then they'll
                                    // have to enter into the mining state before they can proceed.
                                    tile_rect_dwarf_wants_to_move_to := get_tile_rect_that_pos_is_within(WORLD_WIDTH, WORLD_HEIGHT, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, probe_pos);
                                    tile_id_dwarf_wants_to_move_to   := get_tile_id_by_pos(get_rect_pos(tile_rect_dwarf_wants_to_move_to));
                                    tile_is_mined := table_contains(*fully_mined_tile_ids_set, tile_id_dwarf_wants_to_move_to);

                                    // TODO: Eventually we'll want to check whether the tile is mineable or not.
                                    if !tile_is_mined {
                                        dwarf.state = .MINING;
                                        dwarf.tile_id_mining = tile_id_dwarf_wants_to_move_to;
                                        array_add(*actively_mined_tile_ids, tile_id_dwarf_wants_to_move_to);
                                        table_add(*actively_mined_tile_ids_to_health_table, tile_id_dwarf_wants_to_move_to, DIRT_HEALTH);
                                    } else {
                                        set_pos_of_thing_with_rect(dwarf, new_pos);

                                        center_of_dwarf := get_rect_center(dwarf.rect);
                                        tile_rect_dwarf_is_on := get_tile_rect_that_pos_is_within(WORLD_WIDTH, WORLD_HEIGHT, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, center_of_dwarf);
                                        tile_id_dwarf_is_on   := get_tile_id_by_pos(get_rect_pos(tile_rect_dwarf_is_on));
                                         
                                        assert(table_contains(*fully_mined_tile_ids_set, tile_id_dwarf_is_on), "dwarf is in rock or something lol wtf");
                                    }
                                }
                            } else {
                                change_direction_rng := random_get_within_range(0, 1);
                                // new_direction := ;
                                if change_direction_rng < 0.25 {
                                    // Find a new target by picking a random cardinal direction 1 tile away
                                    new_direction := cast(int) random_get_within_range(1, 4);
                                    dwarf.direction = cast(Direction) new_direction;
                                }

                                dx := TILE_DIRECTION_DELTAS[dwarf.direction][0];
                                dy := TILE_DIRECTION_DELTAS[dwarf.direction][1];

                                print("dwarf.direction: %\n", dwarf.direction);
                                assert(dx == 0 || dy == 0, "dx: %, dy: %", dx, dy);

                                new_target_tile_pos := Vector2.{
                                    dwarf.rect.x + dx,
                                    dwarf.rect.y + dy,
                                };

                                new_target_tile_id := get_tile_id_by_pos(new_target_tile_pos);
                                array_add(*dwarf.tile_ids_on_path, new_target_tile_id);
                            }

                        case .MINING;
                            assert(dwarf.tile_id_mining > 0, "Dwarf tryna mine but he got no gotdamn tile to mine!!!!!!!");
                            if dwarf.mining_cooldown_ms > 0 {
                                dwarf.mining_cooldown_ms -= xx (dt_seconds * 1000);
                            } else {
                                // print("swing! %\n", dwarf.tile_id_mining);
                                // TODO: swing animation, I guess
                            
                                // Decrease the tile health by the dwarf mining damage
                                ok, current_health := table_find(*actively_mined_tile_ids_to_health_table, dwarf.tile_id_mining);
                                assert(ok, "Tried mining a tile that doesn't exist");
                                new_health := current_health - DWARF_MINE_DAMAGE_PER_SWING;
                                // print_vars(current_health, new_health);
                                // If the tile is now fully mined, we need to remove it from the actively mined lists,
                                // and add it to the fully mined lists
                                if new_health <= 0 {
                                    array_unordered_remove_by_value(*actively_mined_tile_ids, dwarf.tile_id_mining);
                                    table_remove(*actively_mined_tile_ids_to_health_table, dwarf.tile_id_mining);

                                    set_tile_as_mined(*fully_mined_tile_ids, *fully_mined_tile_ids_set, dwarf.tile_id_mining);

                                    dwarf.state = .MOVING;
                                    dwarf.tile_id_mining = 0;
                                } else {
                                    // If the tile just needs to take some damage, well, then damage it ya fuckin jallopy
                                    table_set(*actively_mined_tile_ids_to_health_table, dwarf.tile_id_mining, new_health);
                                }

                                // Reset cooldown
                                dwarf.mining_cooldown_ms = DWARF_MINE_COOLDOWN_MS;
                            }

                        case .IDLE;
                    }
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
                        xx (dirt_texture.width * WORLD_COLS),  // Repeat 10,000 times horizontally
                        xx (dirt_texture.height * WORLD_ROWS),   // Repeat 10,000 times vertically
                    };

                    dest := Rectangle.{ 
                        0, 
                        0, 
                        xx (dirt_texture.width * WORLD_COLS),
                        xx (dirt_texture.height * WORLD_ROWS),
                    };
                    
                    DrawTexturePro(dirt_texture, source, dest, Vector2.{0,0}, 0.0, WHITE);
                }

                // Then draw any mined tiles over the base layer
                {
                    for fully_mined_tile_ids_viewable {
                        DrawRectangleV(
                            get_tile_pos_by_id(it),
                            Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT },
                            BEIGE,
                        );
                    }
                }

                // Draw bases
                {
                    for base: bases_viewable {
                        source := Rectangle.{
                            0, 0,
                            TILEMAP_GENERAL_TILE_WIDTH  - TILEMAP_GENERAL_TILE_PADDING,
                            TILEMAP_GENERAL_TILE_HEIGHT - TILEMAP_GENERAL_TILE_PADDING,
                        };

                        dest := base.rect;

                        DrawTexturePro(tilemap_texture_general, source, dest, Vector2.{0,0}, 0.0, WHITE);
                    }
                }

                // Draw hovered tile
                {
                    hovered_tile_rect := get_tile_rect_that_pos_is_within(WORLD_WIDTH, WORLD_HEIGHT, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, mouse_pos_in_world);
                    DrawRectangleRec(hovered_tile_rect, TRANSPARENT_WHITE);
                    tile_id := get_tile_id_by_pos(get_rect_pos(hovered_tile_rect));
                    DrawText(tprint("%\0", tile_id).data, xx hovered_tile_rect.x, xx hovered_tile_rect.y, 12, WHITE);
                }

                // Draw dwarves
                {
                    for dwarf: dwarves_viewable {
                        source := Rectangle.{
                            1 * TILEMAP_GENERAL_TILE_WIDTH,
                            0 * TILEMAP_GENERAL_TILE_HEIGHT,
                            TILEMAP_GENERAL_TILE_WIDTH  - TILEMAP_GENERAL_TILE_PADDING,
                            TILEMAP_GENERAL_TILE_HEIGHT - TILEMAP_GENERAL_TILE_PADDING,
                        };

                        dest := dwarf.rect;

                        DrawTexturePro(tilemap_texture_general, source, dest, Vector2.{0,0}, 0.0, WHITE);
                    }
                }
            }

            // Draw debug
            DrawFPS(10, 10);
            if debug_mode {

            }
        }
    }
}

set_tile_as_mined :: (fully_mined_tile_ids: *[..] s32, fully_mined_tile_ids_set : *Table, tile_id: s32) {
    array_add(fully_mined_tile_ids, tile_id);
    table_add(fully_mined_tile_ids_set, tile_id, 0); // 0 is just a throwaway value since Sets don't need values.

    dx, dy : float;
    tile_pos := get_tile_pos_by_id(tile_id);

    for i: 0..3 {
        dx = TILE_DIRECTION_DELTAS[i][0];
        dy = TILE_DIRECTION_DELTAS[i][1];
        neighbor_pos := Vector2.{ tile_pos.x + dx, tile_pos.y + dy };
        neighbor_id := get_tile_id_by_pos(neighbor_pos);

        neighbor_is_mined := table_contains(fully_mined_tile_ids_set, neighbor_id);

        if neighbor_is_mined {
            // TODO: this is pretty fucked up to add these edges both ways, I think
            array_add(*edges, Edge.{ from = tile_id,     to = neighbor_id, distance = 1 });
            array_add(*edges, Edge.{ from = neighbor_id, to = tile_id, distance = 1 });
        }
    }
}

things_with_rects_are_at_the_same_pos :: (rect_enjoyer1: $T/interface HasRect, rect_enjoyer2: T) -> bool {
    return (
        values_are_close(rect_enjoyer1.rect.x, rect_enjoyer2.rect.x) &&
        values_are_close(rect_enjoyer1.rect.y, rect_enjoyer2.rect.y)
    );
}

derive_viewable_entities :: (
    camera: Camera2D,
    fully_mined_tile_ids: [..] s32, fully_mined_tile_ids_viewable: *[..] s32, 
    actively_mined_tile_ids: [..] s32, actively_mined_tile_ids_viewable: *[..] s32, 
    bases: [..] Base, bases_viewable: *[..] Base,
    dwarves: [..] *Dwarf, dwarves_viewable: *[..] *Dwarf
) {
    window_start := GetScreenToWorld2D(Vector2.{ 0, 0 }, camera);
    window_end   := GetScreenToWorld2D(Vector2.{ cast(float) GetScreenWidth(), cast(float) GetScreenHeight()}, camera);

    array_reset(fully_mined_tile_ids_viewable);
    array_reset(actively_mined_tile_ids_viewable);
    array_reset(bases_viewable);
    array_reset(dwarves_viewable);
    
    // Derive viewable tiles
    // NOTE: The order in which tiles are added to viewable_tiles matters!
    // The first will be furthest away in the z ordering.
    {
        for tile_id: fully_mined_tile_ids {
            pos := get_tile_pos_by_id(tile_id);

            // print_vars(tile_id, pos);

            if pos.x + TILEMAP_GENERAL_WORLD_WIDTH < window_start.x continue;
            if pos.x - TILEMAP_GENERAL_WORLD_WIDTH > window_end.x continue;
            
            if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y continue;
            if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

            array_add(fully_mined_tile_ids_viewable, tile_id);
            // array_add(collidable_blocks, block);
        }
    }

    {
        for tile_id: actively_mined_tile_ids {
            pos := get_tile_pos_by_id(tile_id);

            if pos.x + TILEMAP_GENERAL_WORLD_WIDTH < window_start.x continue;
            if pos.x - TILEMAP_GENERAL_WORLD_WIDTH > window_end.x continue;
            
            if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y continue;
            if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

            array_add(actively_mined_tile_ids_viewable, tile_id);
        }
    }

    // Derive viewable bases
    {
        for base: bases {
            pos := get_pos_from_thing_with_rect(base);

            if pos.x + TILEMAP_GENERAL_WORLD_WIDTH < window_start.x continue;
            if pos.x - TILEMAP_GENERAL_WORLD_WIDTH > window_end.x continue;
            
            if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y continue;
            if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

            array_add(bases_viewable, base);
            // array_add(collidable_blocks, block);
        }
    }

    // Derive viewable dwarves
    {
        for dwarf: dwarves {
            pos := get_pos_from_thing_with_rect(dwarf);

            if pos.x + TILEMAP_GENERAL_WORLD_WIDTH < window_start.x continue;
            if pos.x - TILEMAP_GENERAL_WORLD_WIDTH > window_end.x continue;
            
            if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y continue;
            if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

            array_add(dwarves_viewable, dwarf);
            // array_add(collidable_blocks, block);
        }
    }

    // print_vars(
    //     fully_mined_tile_ids,
    //     fully_mined_tile_ids_viewable.*,
    //     actively_mined_tile_ids,
    //     actively_mined_tile_ids_viewable.*
    // );
}

MyCheckCollisionPointRec :: (point: Vector2, rec: Rectangle) -> bool {
    collision := false;

    print_vars(point, rec);

    print("point.x >= rec.x: %\n", point.x >= rec.x);
    print("point.x < (rec.x + rec.width): %\n", point.x < (rec.x + rec.width));
    print("point.y >= rec.y: %\n", point.y >= rec.y);
    print("point.y < (rec.y + rec.height): %\n", point.y < (rec.y + rec.height));

    if (
        (point.x >= rec.x) && (point.x < (rec.x + rec.width)) &&
        (point.y >= rec.y) && (point.y < (rec.y + rec.height))
    ) {
        collision = true;
    }

    return collision;
}

get_rect_center :: (rect: Rectangle) -> Vector2 {
    return Vector2.{ rect.x + rect.width/2, rect.y + rect.height/2 };
}

get_pos_from_thing_with_rect :: (rect_enjoyer: $T/interface HasRect) -> Vector2 {
    return Vector2.{ rect_enjoyer.rect.x, rect_enjoyer.rect.y };
}

set_pos_of_thing_with_rect :: (rect_enjoyer: *$T/interface HasRect, x: float, y: float) {
    rect_enjoyer.rect.x = x;
    rect_enjoyer.rect.y = y;
}

set_pos_of_thing_with_rect :: (rect_enjoyer: *$T/interface HasRect, pos: Vector2) {
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

check_if_neighbor_can_be_to_moved_to :: (tile: *Tile, dx: float32, dy: float32) -> (is_valid: bool, neighbor: *Tile) {
    neighbor_pos := Vector2.{ get_pos_from_thing_with_rect(tile).x + dx, get_pos_from_thing_with_rect(tile).y + dy };

    // First get a pointer to the thing if it exists
    neighbor_exists, neighbor := table_find(*global_tile_pos_to_tile, vector2_to_string_temp(neighbor_pos));

    if !neighbor_exists { return false, null; }

    return true, neighbor;
}

try_to_move_to_tile :: (entity: *Entity, tile: Tile, tile_id_to_move_count_remaining: *Table) {
    assert(entity != null, "Tried to move a null entity!!!!!!");

    starting_tile := get_tile_by_pos(entity.pos);
    has_entry, move_count_remaining := table_find(tile_id_to_move_count_remaining, tile.id);

    // Check if this tile is even within the viewable entity's range
    if has_entry {
        // Change tile before movement back to default
        starting_tile.tile_state = .DEFAULT; // TODO: terrible

        // Then, move the entity to the target tile
        move_entity_instantaneously(entity, tile.id);

        // Remove the amount of tiles moved from the entity's current count
        entity.tile_moves_per_turn_current = move_count_remaining;
    }
}

is_entity_on_tile :: (entity: Entity, tile: Tile) -> bool {
    return entity.pos.x == get_pos_from_thing_with_rect(tile).x && entity.pos.y == get_pos_from_thing_with_rect(tile).y;
}

get_tile_pos_by_id :: (id: s32) -> Vector2 {
    index := id - 1; 

    grid_x := index % WORLD_COLS; // Remainder = Column
    grid_y := index / WORLD_COLS; // Integer Div = Row

    pixel_x := cast(float32) grid_x * TILEMAP_GENERAL_WORLD_WIDTH;
    pixel_y := cast(float32) grid_y * TILEMAP_GENERAL_WORLD_HEIGHT;

    return Vector2.{ pixel_x, pixel_y };
}

get_tile_id_by_pos :: (pos: Vector2) -> s32 {
    grid_x := cast(s32) (pos.x / TILEMAP_GENERAL_WORLD_WIDTH);
    grid_y := cast(s32) (pos.y / TILEMAP_GENERAL_WORLD_HEIGHT);

    if grid_x < 0 || grid_x >= WORLD_COLS assert(false);
    if grid_y < 0 || grid_y >= WORLD_ROWS assert(false);

    index := (grid_y * WORLD_COLS) + grid_x;

    return index + 1;
}

find_tile_by_pos :: (pos: Vector2) -> (tile_exists: bool, tile: *Tile) {
    tile_exists, tile := table_find(*global_tile_pos_to_tile, vector2_to_string_temp(pos));
    return tile_exists, tile;
}

get_tile_by_pos :: (pos: Vector2) -> *Tile {
    tile_exists, tile := table_find(*global_tile_pos_to_tile, vector2_to_string_temp(pos));
    assert(tile_exists);
    return tile;
}

get_rect_pos :: (rect: Rectangle) -> Vector2 {
    return { rect.x, rect.y };
}

find_entity_on_tile_by_pos :: (tile_pos: Vector2, entities: []*Entity) -> (found: bool, entity: *Entity) {
    for entities {
        if it.pos.x == tile_pos.x && it.pos.y == tile_pos.y {
            return true, it;
        }
    }

    return false, null;
}

get_entity_on_tile_by_tile_id :: (tile_id: s32, entities: []*Entity) -> (found: bool, entity: *Entity) {
    tile_pos := get_tile_pos_by_id(tile_id);

    found, entity := find_entity_on_tile_by_pos(tile_pos, entities);
    return found, entity;
}

get_colliding_by_rect :: (subject_rect: Rectangle, collidables: [] $T/interface *Entity) -> *Entity {
    for collidables {
        if CheckCollisionRecs(it.bounding_rect, subject_rect) {
            return it;
        }
    }

    return null;
}

get_colliding_entity_by_vec2 :: (subject_vec2: Vector2, collidables: [] *$T/interface Entity) -> result: *T {
    for collidables {
        if CheckCollisionPointRec(subject_vec2, it.bounding_rect) {
            return it;
        }
    }

    return null;
}

array_unordered_remove_entity_by_id :: inline (array: *[] $Entity, item: Entity, $stop_after_first := false) -> s64 {
    removed := 0;
    for array.*  if it.id == item.id {
        removed += 1;
        remove it;

        #if stop_after_first  break;   // Early-out optimization.
    }

    return removed;
}
