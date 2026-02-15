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

TILEMAP_GENERAL_MAP_WIDTH    :: 288;
TILEMAP_GENERAL_MAP_HEIGHT   :: 270;
TILEMAP_GENERAL_TILE_WIDTH   :: 18;
TILEMAP_GENERAL_TILE_HEIGHT  :: 18;
TILEMAP_GENERAL_TILE_PADDING :: 2;
TILEMAP_GENERAL_WORLD_WIDTH  :: TILEMAP_GENERAL_TILE_WIDTH * SCALE;
TILEMAP_GENERAL_WORLD_HEIGHT :: TILEMAP_GENERAL_TILE_HEIGHT * SCALE;

tilemap_texture_general : Texture;
dirt_texture            : Texture;

init_textures :: () {
    tilemap_texture_general = LoadTexture("data/Tiles_0.png");
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

chunks : [..] Chunk; // TODO: pointers?
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
    #if false {
        world_width  := 10_000;
        world_height := 10_000;
        chunks_x     := (world_width / CHUNK_SIZE) + 1;
        chunks_y     := (world_height / CHUNK_SIZE) + 1;
        total_chunks := chunks_x * chunks_y;

        // Generate them all (Only happens ONCE at startup)
        for y: 0..chunks_y {
            for x: 0..chunks_x {
                array_add(*chunks, create_chunk(x, y, tilemap_texture_general));
            }
        }
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
        }

        //
        // Update
        //
        if !paused {
            // Update camera
            {
                CAMERA_ZOOM_INCREMENT :: 0.2;
                CAMERA_ZOOM_MIN :: 0.001;
                CAMERA_ZOOM_MAX :: 13.0;

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

                source := Rectangle.{ 
                    0, 
                    0, 
                    dirt_texture.width * 10000.0,  // Repeat 10,000 times horizontally
                    dirt_texture.height * 10000.0  // Repeat 10,000 times vertically
                };

                // destRec: Where to draw it in the world (The giant area)
                dest := Rectangle.{ 
                    0, 
                    0, 
                    dirt_texture.width * 10000.0, 
                    dirt_texture.height * 10000.0 
                };
                
                // Draw base layer of dirt
                DrawTexturePro(dirt_texture, source, dest, Vector2.{0,0}, 0.0, WHITE);

                // Draw tiles (chunks)
                // for chunks {
                //     // TODO: Simple Culling
                //     DrawModel(it.model, Vector3.{ it.position.x, it.position.y, 0.0 }, 1.0, WHITE);
                // }

                // Draw tiles (old)
                // {
                //     for tile: dirt_tiles {
                //         DrawTexturePro(
                //             tilemap_texture_general,
                //             Rectangle.{
                //                 1 * TILEMAP_GENERAL_TILE_WIDTH,
                //                 1 * TILEMAP_GENERAL_TILE_HEIGHT,
                //                 TILEMAP_GENERAL_TILE_WIDTH  - TILEMAP_GENERAL_TILE_PADDING,
                //                 TILEMAP_GENERAL_TILE_HEIGHT - TILEMAP_GENERAL_TILE_PADDING,
                //             },
                //             tile.rect,
                //             Vector2.{ 0, 0 },
                //             0.0,
                //             WHITE,
                //         );

                //         if debug_mode {
                //             DrawText(
                //                 tprint("%\0", it_index).data,
                //                 xx (pos(tile).x),
                //                 xx (pos(tile).y),
                //                 12,
                //                 WHITE,
                //             );
                //         }
                //     }
                // }
            }

            // Draw debug
            DrawFPS(10, 10);
            if debug_mode {
            }
        }
    }
}

CHUNK_SIZE :: 64;   // 64x64 tiles per chunk
TILE_SIZE  :: 16.0; // Size of one tile in pixels

// A generic "Chunk" structure to hold our mesh
Chunk :: struct {
    mesh     : Mesh;
    model    : Model;
    position : Vector2; // World position of this chunk
    active   : bool;
}

// Function to generate a single mesh for a specific chunk of the world
create_chunk :: (chunk_x: int, chunk_y: int, texture: Texture2D) -> Chunk {
    chunk : Chunk;
    chunk.position = Vector2.{ xx (chunk_x * CHUNK_SIZE * TILE_SIZE), xx (chunk_y * CHUNK_SIZE * TILE_SIZE) };
    chunk.active = true;

    // 1. Allocate CPU Memory for the Mesh Data
    max_tiles := CHUNK_SIZE * CHUNK_SIZE;
    // chunk.mesh = Mesh.{ 0 }; Jai should zero initialize this I think
    chunk.mesh.vertexCount = xx (max_tiles * 4);   // 4 verts per tile
    chunk.mesh.triangleCount = xx (max_tiles * 2); // 2 triangles per tile

    // Raylib requires us to allocate these arrays
    chunk.mesh.vertices  = alloc(chunk.mesh.vertexCount   * 3 * size_of(float));
    chunk.mesh.texcoords = alloc(chunk.mesh.vertexCount   * 2 * size_of(float));
    chunk.mesh.indices   = alloc(chunk.mesh.triangleCount * 3 * size_of(u16));

    // 2. Fill the Mesh with Data
    v_counter := 0; // Vertex counter
    t_counter := 0; // Triangle (index) counter
 
    for y : 0..CHUNK_SIZE {
        for x : 0..CHUNK_SIZE {
            // Relative position inside the chunk
            posX := x * TILE_SIZE;
            posY := y * TILE_SIZE;

            // --- VERTICES (3 floats per vertex: x, y, z) ---
            // Top-Left
            chunk.mesh.vertices[v_counter * 3 + 0] = posX;
            chunk.mesh.vertices[v_counter * 3 + 1] = posY;
            chunk.mesh.vertices[v_counter * 3 + 2] = 0.0;
            
            // Bottom-Left
            chunk.mesh.vertices[v_counter * 3 + 3] = posX;
            chunk.mesh.vertices[v_counter * 3 + 4] = posY + TILE_SIZE;
            chunk.mesh.vertices[v_counter * 3 + 5] = 0.0;

            // Bottom-Right
            chunk.mesh.vertices[v_counter * 3 + 6] = posX + TILE_SIZE;
            chunk.mesh.vertices[v_counter * 3 + 7] = posY + TILE_SIZE;
            chunk.mesh.vertices[v_counter * 3 + 8] = 0.0;

            // Top-Right
            chunk.mesh.vertices[v_counter * 3 + 9]  = posX + TILE_SIZE;
            chunk.mesh.vertices[v_counter * 3 + 10] = posY;
            chunk.mesh.vertices[v_counter * 3 + 11] = 0.0;

            // --- TEXCOORDS (2 floats per vertex: u, v) ---

            u_tile_len_excluding_padding : float32 = (cast(float) (TILEMAP_GENERAL_TILE_WIDTH  - TILEMAP_GENERAL_TILE_PADDING)) / TILEMAP_GENERAL_MAP_WIDTH;
            v_tile_len_excluding_padding : float32 = (cast(float) (TILEMAP_GENERAL_TILE_HEIGHT - TILEMAP_GENERAL_TILE_PADDING)) / TILEMAP_GENERAL_MAP_HEIGHT;
            u_tile_len_including_padding : float32 = (cast(float) (TILEMAP_GENERAL_TILE_WIDTH))  / TILEMAP_GENERAL_MAP_WIDTH;
            v_tile_len_including_padding : float32 = (cast(float) (TILEMAP_GENERAL_TILE_HEIGHT)) / TILEMAP_GENERAL_MAP_HEIGHT;

            // The scalar before the including_padding variant can be thought of as the zero-indexed placement of the tile in the tilemap.
            chunk.mesh.texcoords[v_counter * 2 + 0] = 0 * u_tile_len_including_padding + u_tile_len_excluding_padding;
            chunk.mesh.texcoords[v_counter * 2 + 1] = 0 * v_tile_len_including_padding + v_tile_len_excluding_padding;
            
            chunk.mesh.texcoords[v_counter * 2 + 2] = 0 * u_tile_len_including_padding + u_tile_len_excluding_padding;
            chunk.mesh.texcoords[v_counter * 2 + 3] = 1 * v_tile_len_including_padding + v_tile_len_excluding_padding;
            
            chunk.mesh.texcoords[v_counter * 2 + 4] = 1 * u_tile_len_including_padding + u_tile_len_excluding_padding;
            chunk.mesh.texcoords[v_counter * 2 + 5] = 1 * v_tile_len_including_padding + v_tile_len_excluding_padding;
            
            chunk.mesh.texcoords[v_counter * 2 + 6] = 1 * u_tile_len_including_padding + u_tile_len_excluding_padding;
            chunk.mesh.texcoords[v_counter * 2 + 7] = 0 * v_tile_len_including_padding + v_tile_len_excluding_padding;


            // --- INDICES (Linking vertices to make triangles) ---
            // Triangle 1 (Top-Left, Bottom-Left, Bottom-Right)
            chunk.mesh.indices[t_counter * 3 + 0] = xx (v_counter + 0);
            chunk.mesh.indices[t_counter * 3 + 1] = xx (v_counter + 1);
            chunk.mesh.indices[t_counter * 3 + 2] = xx (v_counter + 2);

            // Triangle 2 (Top-Left, Bottom-Right, Top-Right)
            chunk.mesh.indices[t_counter * 3 + 3] = xx (v_counter + 0);
            chunk.mesh.indices[t_counter * 3 + 4] = xx (v_counter + 2);
            chunk.mesh.indices[t_counter * 3 + 5] = xx (v_counter + 3);

            v_counter += 4;
            t_counter += 2;
        }
    }

    // 3. Upload to GPU
    // This sends the data to VRAM.
    UploadMesh(*chunk.mesh, false);

    // 4. Create a Model to make it easy to draw
    chunk.model = LoadModelFromMesh(chunk.mesh);
    chunk.model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;

    return chunk;
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
