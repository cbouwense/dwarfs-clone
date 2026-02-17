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

CAMERA_MOVE_SPEED_BASE :: 4;
CAMERA_ZOOM_SPEED :: 0.3;

// MAP_ROW_COUNT :: 1_000_000;
// MAP_COL_COUNT :: 1_000_000;

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

TILEMAP_GENERAL_MAP_WIDTH    :: 320;
TILEMAP_GENERAL_MAP_HEIGHT   :: 320;
TILEMAP_GENERAL_TILE_WIDTH   :: 18;
TILEMAP_GENERAL_TILE_HEIGHT  :: 18;
TILEMAP_GENERAL_TILE_PADDING :: 2;
TILEMAP_GENERAL_WORLD_WIDTH  :: TILEMAP_GENERAL_TILE_WIDTH * SCALE;
TILEMAP_GENERAL_WORLD_HEIGHT :: TILEMAP_GENERAL_TILE_HEIGHT * SCALE;

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

drag_cam_pressed  : bool;
drag_cam_down     : bool;
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

mouse_drag_began_at_pos : Vector2;

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

HasRect :: struct {
    rect : Rectangle;
}

Base :: struct {
    rect : Rectangle;
}

Tile :: struct {
    rect : Rectangle;
}

data_folder: string;

WORLD_COLS :: 10000;
WORLD_ROWS :: 10000;

// Tile ID's will go row-wise, starting at 1 (zero means invalid or whatever)
// so like
// 1 2 3
// 4 5 6
// 7 8 9
// This means that to get the position of a tile you just have to do some math,
// which also means that we don't need to store that anywhere. Check out
// get_tile_pos_by_id.
mined_tile_ids : [..] s32;
mined_tile_ids_viewable : [..] s32;
bases : [..] Base;
bases_viewable : [..] Base;

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

    // Initialize game
    game_state := GameState.{};

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
    }

    // Initialize camera
    camera: Camera2D;
    camera.target   = get_pos_from_thing_with_rect(bases[0]);
    camera.offset   = Vector2.{ 800, 450 };
    camera.rotation = 0.0;
    camera.zoom     = 2;

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
            drag_cam_pressed  = control_is_pressed(controls.drag_cam);
            drag_cam_down     = control_is_down(controls.drag_cam);
            move_camera_up    = control_is_down(controls.move_camera_up);
            move_camera_down  = control_is_down(controls.move_camera_down);
            move_camera_left  = control_is_down(controls.move_camera_left);
            move_camera_right = control_is_down(controls.move_camera_right);
        }

        derive_viewable_entities(
            camera,
            mined_tile_ids, *mined_tile_ids_viewable,
            bases,          *bases_viewable
        );

        //
        // Update
        //
        if !paused {
            // Update camera
            {
                CAMERA_ZOOM_INCREMENT :: 0.2;
                CAMERA_ZOOM_MIN :: 0.001;
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
                // camera.target = new_camera_target;
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
                    for mined_tile_ids_viewable {
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
                    world_width  := WORLD_COLS * TILEMAP_GENERAL_WORLD_WIDTH;
                    world_height := WORLD_ROWS * TILEMAP_GENERAL_WORLD_HEIGHT;
                    hovered_tile_rect := get_tile_mouse_is_hovering_over(world_width, world_height, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, mouse_pos_in_world);
                    DrawRectangleRec(hovered_tile_rect, TRANSPARENT_WHITE);
                }
            }

            // Draw debug
            DrawFPS(10, 10);
            if debug_mode {

            }
        }
    }
}

derive_viewable_entities :: (
    camera: Camera2D,
    mined_tile_ids: [..] s32, mined_tile_ids_viewable: *[..] s32, 
    bases: [..] Base,         bases_viewable: *[..] Base
) {
    window_start := GetScreenToWorld2D(Vector2.{ 0, 0 }, camera);
    window_end   := GetScreenToWorld2D(Vector2.{ cast(float) GetScreenWidth(), cast(float) GetScreenHeight()}, camera);

    array_reset(mined_tile_ids_viewable);
    array_reset(bases_viewable);
    
    // Derive viewable tiles
    // NOTE: The order in which tiles are added to viewable_tiles matters!
    // The first will be furthest away in the z ordering.
    {
        for tile_id: mined_tile_ids {
            pos := get_tile_pos_by_id(tile_id);

            if pos.x + TILEMAP_GENERAL_WORLD_WIDTH < window_start.x continue;
            if pos.x - TILEMAP_GENERAL_WORLD_WIDTH > window_end.x continue;
            
            if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y continue;
            if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

            array_add(mined_tile_ids_viewable, tile_id);
            // array_add(collidable_blocks, block);
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

    // print_vars(mined_tile_ids_viewable.*, bases_viewable.*);
}

get_pos_from_thing_with_rect :: (x: $T/interface HasRect) -> Vector2 {
    return Vector2.{ x.rect.x, x.rect.y };
}

get_tile_mouse_is_hovering_over :: (world_width: int, world_height: int, tile_width: int, tile_height: int, mouse_pos_in_world: Vector2) -> Rectangle {
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
