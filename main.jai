#import "Basic";
#import "Hash_Table";
#import "Input";
#import "Math";
#import "Print_Vars";
#import "Random";
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

CAMERA_MOVE_SPEED :: 4;
CAMERA_ZOOM_SPEED :: 0.3;

MAP_ROW_COUNT :: 100;
MAP_COL_COUNT :: 100;

SCALE :: 2;

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

TILEMAP_GENERAL_MAP_WIDTH    :: 320;
TILEMAP_GENERAL_MAP_HEIGHT   :: 320;
TILEMAP_GENERAL_TILE_WIDTH   :: 18;
TILEMAP_GENERAL_TILE_HEIGHT  :: 18;
TILEMAP_GENERAL_TILE_PADDING :: 2;
TILEMAP_GENERAL_WORLD_WIDTH  :: TILEMAP_GENERAL_TILE_WIDTH * SCALE;
TILEMAP_GENERAL_WORLD_HEIGHT :: TILEMAP_GENERAL_TILE_HEIGHT * SCALE;

tilemap_texture_general : Texture;

init_textures :: () {
    tilemap_texture_general = LoadTexture("data/Tiles_0.png");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Sprites
////////////////////////////////////////////////////////////////////////////////////////////////////

init_sprites :: () {

}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Controls
////////////////////////////////////////////////////////////////////////////////////////////////////

drag_cam          : bool;
move_camera_up    : bool;
move_camera_down  : bool;
move_camera_left  : bool;
move_camera_right : bool;

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

GameState :: struct {
}

Direction :: enum u8 #specified {
    NORTH      :: 1;
    NORTH_EAST :: 2;
    NORTH_WEST :: 3;
    SOUTH      :: 4;
    SOUTH_EAST :: 5;
    SOUTH_WEST :: 6;
    EAST       :: 7;
    WEST       :: 8;
    CENTER     :: 9;  // essentially no direction
    COUNT      :: 10; // helper value that explicitly stores the enum length
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

Tile :: struct {
    rect : Rectangle;
}

data_folder: string;

dirt_tiles : [..] *Tile;
// edges : [..] Edge; // List of edges between tiles for pathfinding

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
        controls.drag_cam[0]          = Control.{ type = MouseButton, value = cast(s32) MouseButton.MOUSE_BUTTON_RIGHT };

        controls.move_camera_up[0]    = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_UP    };
        controls.move_camera_up[1]    = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_W     };

        controls.move_camera_down[0]  = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_DOWN  };
        controls.move_camera_down[1]  = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_S     };

        controls.move_camera_left[0]  = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_LEFT  };
        controls.move_camera_left[1]  = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_A     };

        controls.move_camera_right[0] = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_RIGHT };
        controls.move_camera_right[1] = Control.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_D     };
    }

    // Initialize tiles
    {
        for col: 0..MAP_COL_COUNT-1 {
            for row: 0..MAP_ROW_COUNT-1 {
                tile := New(Tile);
                tile.rect = Rectangle.{
                    xx (col * TILEMAP_GENERAL_WORLD_WIDTH),
                    xx (row * TILEMAP_GENERAL_WORLD_HEIGHT),
                    TILEMAP_GENERAL_WORLD_WIDTH,
                    TILEMAP_GENERAL_WORLD_HEIGHT,
                };

                tile_index := cast(s32) (col * MAP_ROW_COUNT + row);

                array_add(*dirt_tiles, tile);
                table_add(*global_tile_pos_to_tile, vector2_to_string_permanent(pos(tile)), tile);
                table_add(*global_tile_id_to_tile, tile_index, tile); // TODO: seems flimsy

                // neighbor_list := New([..] *Tile);
                // table_add(*global_tile_id_to_neighbors, tile_index, neighbor_list); // TODO: seems flimsy
            }
        }

        // // Initialize tile neighbor table
        // for tile: tiles {
        //     neighbor_list_exists, neighbor_list := table_find(*global_tile_id_to_neighbors, tile.id);
        //     assert(neighbor_list_exists, "Could not find neighbor list for tile id %\n", tile.id);

        //     add_neighbor_if_it_exists :: (tile: *Tile, neighbor_list: *[..] *Tile, dx: float32, dy: float32) {
        //         neighbor_pos := Vector2.{ pos(tile).x + dx, pos(tile).y + dy };
        //         neighbor_exists, neighbor := table_find(*global_tile_pos_to_tile, vector2_to_string_temp(neighbor_pos));
        //         if neighbor_exists array_add(neighbor_list, neighbor);
        //     }
 
        //     add_neighbor_if_it_exists(tile, neighbor_list, 0.0, -TILEMAP_GENERAL_WORLD_HEIGHT); // north
        //     add_neighbor_if_it_exists(tile, neighbor_list, 0.0, +TILEMAP_GENERAL_WORLD_HEIGHT); // south
        //     add_neighbor_if_it_exists(tile, neighbor_list, +TILEMAP_GENERAL_WORLD_WIDTH, 0.0);  // east
        //     add_neighbor_if_it_exists(tile, neighbor_list, -TILEMAP_GENERAL_WORLD_WIDTH, 0.0);  // west
        //     add_neighbor_if_it_exists(tile, neighbor_list, +TILEMAP_GENERAL_WORLD_WIDTH * 0.50, -TILEMAP_GENERAL_WORLD_HEIGHT * 0.50); // north east
        //     add_neighbor_if_it_exists(tile, neighbor_list, -TILEMAP_GENERAL_WORLD_WIDTH * 0.50, -TILEMAP_GENERAL_WORLD_HEIGHT * 0.50); // north west
        //     add_neighbor_if_it_exists(tile, neighbor_list, +TILEMAP_GENERAL_WORLD_WIDTH * 0.50, +TILEMAP_GENERAL_WORLD_HEIGHT * 0.50); // south east
        //     add_neighbor_if_it_exists(tile, neighbor_list, -TILEMAP_GENERAL_WORLD_WIDTH * 0.50, +TILEMAP_GENERAL_WORLD_HEIGHT * 0.50); // south west
        // }

        // // Initialize edge list
        // {
        //     for global_tile_id_to_neighbors {
        //         tile_id, neighbors := it_index, it;
        //         for neighbor: neighbors.* {
        //             distance := 1.0;

        //             // Cardinal neighbors are actually farther away than diagonal neighbors
        //             if neighbor.id == tile_id - 1  distance = 1.414; // north
        //             if neighbor.id == tile_id + 1  distance = 1.414; // south
        //             if neighbor.id == tile_id + 2 * MAP_ROW_COUNT distance = 1.414; // east
        //             if neighbor.id == tile_id - 2 * MAP_ROW_COUNT distance = 1.414; // west

        //             array_add(*edges, Edge.{ from = tile_id, to = neighbor.id, distance = distance });
        //         }
        //     }
        // }
    }

    // Initialize camera
    camera: Camera2D;
    camera.target   = Vector2.{ 200, 180 };
    camera.offset   = Vector2.{ 800, 450 };
    camera.rotation = 0.0;
    camera.zoom     = 2;

    // Initialize game
    game_state := GameState.{};

    while !WindowShouldClose() {
        reset_temporary_storage();

        time := GetTime();
        dt   := GetFrameTime();

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

            // Game controls
            drag_cam          = control_is_down(controls.drag_cam);
            move_camera_up    = control_is_down(controls.move_camera_up);
            move_camera_down  = control_is_down(controls.move_camera_down);
            move_camera_left  = control_is_down(controls.move_camera_left);
            move_camera_right = control_is_down(controls.move_camera_right);

            camera.zoom += mouse_wheel_move * CAMERA_ZOOM_SPEED;
        }

        //
        // Update
        //
        if !paused {
            // Update camera
            {
                CAMERA_ZOOM_INCREMENT :: 0.2;
                CAMERA_ZOOM_MIN :: 0.1;
                CAMERA_ZOOM_MAX :: 3.0;

                if move_camera_up    camera.target.y -= CAMERA_MOVE_SPEED;
                if move_camera_down  camera.target.y += CAMERA_MOVE_SPEED;
                if move_camera_left  camera.target.x -= CAMERA_MOVE_SPEED;
                if move_camera_right camera.target.x += CAMERA_MOVE_SPEED;

                camera.offset = Vector2.{ GetScreenWidth() / 2.0, GetScreenHeight() / 2.0 };

                new_camera_target := camera.target;

                if drag_cam {
                    new_camera_target = Vector2Add(new_camera_target, Vector2Scale(GetMouseDelta(), -1.0 * CAMERA_MOVE_SPEED));
                }

                camera.zoom += mouse_wheel_move * CAMERA_ZOOM_INCREMENT;
                camera.zoom = clamp(camera.zoom, CAMERA_ZOOM_MIN, CAMERA_ZOOM_MAX);

                camera.offset = Vector2.{ GetScreenWidth() / 2.0, GetScreenHeight() / 2.0 };
                camera.target = new_camera_target;
            }

            // Update tiles
            {

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

                // Draw tiles
                {
                    for tile: dirt_tiles {
                        DrawTexturePro(
                            tilemap_texture_general,
                            Rectangle.{
                                1 * TILEMAP_GENERAL_TILE_WIDTH,
                                1 * TILEMAP_GENERAL_TILE_HEIGHT,
                                TILEMAP_GENERAL_TILE_WIDTH  - TILEMAP_GENERAL_TILE_PADDING,
                                TILEMAP_GENERAL_TILE_HEIGHT - TILEMAP_GENERAL_TILE_PADDING,
                            },
                            tile.rect,
                            Vector2.{ 0, 0 },
                            0.0,
                            WHITE,
                        );

                        if debug_mode {
                            DrawText(
                                tprint("%\0", it_index).data,
                                xx (pos(tile).x),
                                xx (pos(tile).y),
                                12,
                                WHITE,
                            );
                        }
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

// TODO: maybe have this accept anything with a rect field on it?
pos :: (tile: Tile) -> Vector2 {
    return Vector2.{ tile.rect.x, tile.rect.y };
}

check_if_neighbor_can_be_to_moved_to :: (tile: *Tile, dx: float32, dy: float32) -> (is_valid: bool, neighbor: *Tile) {
    neighbor_pos := Vector2.{ pos(tile).x + dx, pos(tile).y + dy };

    // First get a pointer to the thing if it exists
    neighbor_exists, neighbor := table_find(*global_tile_pos_to_tile, vector2_to_string_temp(neighbor_pos));

    if !neighbor_exists { return false, null; }

    return true, neighbor;
}

try_to_move_to_tile :: (entity: *Entity, tile: Tile, tile_id_to_move_count_remaining: *Table) {
    assert(entity != null, "Tried to move a null entity!!!!!!");

    starting_tile := get_tile_by_pos(entity.pos);
    has_entry, move_count_remaining := table_find(tile_id_to_move_count_remaining, tile.id);

    // Check if this tile is even within the active entity's range
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
    return entity.pos.x == pos(tile).x && entity.pos.y == pos(tile).y;
}

get_tile_pos_by_id :: (id: s32) -> Vector2 {
    return pos(dirt_tiles[id]); // TODO: feels sus
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
