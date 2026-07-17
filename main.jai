#import "Basic";
#import "Compiler";
#import "Hash_Table";
#import "Input";
Math :: #import "Math";
#import "Print_Vars";
#import "Program_Print";
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
CAMERA_ZOOM_LOD_MIN :: 0.3;

DIRT_HEALTH :: 100;
IRON_HEALTH :: 200;
WALL_HEALTH :: 200;

DWARF_MOVE_SPEED :: 33;
DWARF_MOVE_SPEED_FAST :: DWARF_MOVE_SPEED * 2;

DWARF_MINER_START_COUNT :: 1;
DWARF_MINER_DIG_COOLDOWN_MS    :: 1000;
DWARF_MINER_ATTACK_COOLDOWN_MS :: 2000;
DWARF_MINER_DAMAGE_DIG_PER_SWING    :: 50;
DWARF_MINER_DAMAGE_ATTACK_PER_SWING :: 25;
DWARF_MINER_HIT_CHANCE :: 0.50; // TODO: will have to be based on level
DWARF_MINER_SPAWN_MS :: 10000;
DWARF_MINER_SPAWN_ENABLED :: true;
DWARF_MINER_STARTING_HP :: 75;

DWARF_MINER_ANIMATION_IDLE_FRAME_DURATION_MS :: 100;
DWARF_MINER_ANIMATION_IDLE_START_FRAME       :: 0;
DWARF_MINER_ANIMATION_IDLE_FRAME_COUNT       :: 8;
DWARF_MINER_ANIMATION_WALK_FRAME_DURATION_MS :: 100;
DWARF_MINER_ANIMATION_WALK_START_FRAME       :: 8;
DWARF_MINER_ANIMATION_WALK_FRAME_COUNT       :: 8;
DWARF_MINER_ANIMATION_MINE_FRAME_DURATION_MS :: 100;
DWARF_MINER_ANIMATION_MINE_START_FRAME       :: 16;
DWARF_MINER_ANIMATION_MINE_FRAME_COUNT       :: 8;
DWARF_MINER_ANIMATION_MINE_FRAME_ACTION      :: 22;
DWARF_MINER_ANIMATION_DIE_FRAME_DURATION_MS  :: 100;
DWARF_MINER_ANIMATION_DIE_START_FRAME        :: 40;
DWARF_MINER_ANIMATION_DIE_FRAME_COUNT        :: 6;

DWARF_WARRIOR_START_COUNT :: 1;
DWARF_WARRIOR_DIG_COOLDOWN_MS    :: 2000;
DWARF_WARRIOR_ATTACK_COOLDOWN_MS :: 1000;
DWARF_WARRIOR_DAMAGE_DIG_PER_SWING    :: 25;
DWARF_WARRIOR_DAMAGE_ATTACK_PER_SWING :: 50;
DWARF_WARRIOR_HIT_CHANCE :: 0.80; // TODO: will have to be based on level
DWARF_WARRIOR_SPAWN_ENABLED :: true;
DWARF_WARRIOR_STARTING_HP :: 100;

GOBLIN_MOVE_SPEED :: 50;
GOBLIN_ATTACK_COOLDOWN_MS :: 1000;
GOBLIN_ATTACK_DAMAGE_PER_SWING :: 0;// 25;
GOBLIN_HIT_CHANCE :: 0.80; // TODO: will have to be based on level
GOBLIN_SPAWN_ENABLED :: true;
GOBLIN_STARTING_HP :: 100;
GOBLIN_LINE_OF_SIGHT_TILE_COUNT :: 15;

PARTICLE_FLOAT_SPEED :: -15.0;

PARTICLE_GOLD_TIME_TO_LIVE_MS   :: 1000;
PARTICLE_GOLD_SPRITE_SOURCE_ROW :: 0;
PARTICLE_GOLD_SPRITE_SOURCE_COL :: 9;

PARTICLE_DWARF_DEATH_TIME_TO_LIVE_MS   :: 1500;
PARTICLE_DWARF_DEATH_SPRITE_SOURCE_ROW :: 0;
PARTICLE_DWARF_DEATH_SPRITE_SOURCE_COL :: 8;

PARTICLE_GOBLIN_DEATH_TIME_TO_LIVE_MS   :: 1500;
PARTICLE_GOBLIN_DEATH_SPRITE_SOURCE_ROW :: 1;
PARTICLE_GOBLIN_DEATH_SPRITE_SOURCE_COL :: 8;

PARTICLE_DWARF_AGGRO_TIME_TO_LIVE_MS   :: 1000;
PARTICLE_DWARF_AGGRO_SPRITE_SOURCE_ROW :: 1;
PARTICLE_DWARF_AGGRO_SPRITE_SOURCE_COL :: 9;

PARTICLE_DWARF_SELECTED_TIME_TO_LIVE_MS   :: 99999999;
PARTICLE_DWARF_SELECTED_SPRITE_SOURCE_ROW :: 1;
PARTICLE_DWARF_SELECTED_SPRITE_SOURCE_COL :: 7;

PARTICLE_DAMAGE_STAR_TIME_TO_LIVE_MS   :: 750;
PARTICLE_DAMAGE_STAR_SPRITE_SOURCE_ROW :: 1;
PARTICLE_DAMAGE_STAR_SPRITE_SOURCE_COL :: 6;
PARTICLE_DAMAGE_STAR_STARTING_SPEED    :: 250;

PARTICLE_DAMAGE_TIME_TO_LIVE_MS :: 1500;

LAVA_DAMAGE_PER_HIT :: 20;
LAVA_SPRITE_SOURCE_ROW :: 1;
LAVA_SPRITE_SOURCE_COL :: 5;
LAVA_FLOWING_FRAME_COUNT :: 8;

WATER_FLOWING_FRAME_COUNT :: LAVA_FLOWING_FRAME_COUNT;

WATER_STILL_FRAME_COUNT :: 4;
WATER_STILL_FRAME_DURATION_MS :: 750;

SCALE :: 1;

TILEMAP_GENERAL_MAP_WIDTH    :: 320;
TILEMAP_GENERAL_MAP_HEIGHT   :: 320;
TILEMAP_GENERAL_TILE_WIDTH   :: 32;
TILEMAP_GENERAL_TILE_HEIGHT  :: 32;
TILEMAP_GENERAL_WORLD_WIDTH  :: TILEMAP_GENERAL_TILE_WIDTH  * SCALE;
TILEMAP_GENERAL_WORLD_HEIGHT :: TILEMAP_GENERAL_TILE_HEIGHT * SCALE;

WORLD_COLS_HUGE   :: 2048;
WORLD_ROWS_HUGE   :: WORLD_COLS_HUGE;
WORLD_COLS_LARGE  :: WORLD_COLS_HUGE   * 0.5;
WORLD_ROWS_LARGE  :: WORLD_COLS_LARGE;
WORLD_COLS_MEDIUM :: WORLD_COLS_LARGE  * 0.5;
WORLD_ROWS_MEDIUM :: WORLD_COLS_MEDIUM;
WORLD_COLS_SMALL  :: WORLD_COLS_MEDIUM * 0.5;
WORLD_ROWS_SMALL  :: WORLD_COLS_SMALL;
WORLD_COLS_TUTORIAL_CONTROLS         :: 32;
WORLD_ROWS_TUTORIAL_CONTROLS         :: 32;
WORLD_COLS_TUTORIAL_LAVA_AND_WATER   :: 128;
WORLD_ROWS_TUTORIAL_LAVA_AND_WATER   :: 128;
WORLD_COLS_TUTORIAL_CAVE_TRAPPING    :: 128;
WORLD_ROWS_TUTORIAL_CAVE_TRAPPING    :: 128;
WORLD_COLS_TUTORIAL_DARK_CAVES       :: 128;
WORLD_ROWS_TUTORIAL_DARK_CAVES       :: 128;
WORLD_COLS_TUTORIAL_FIGHTING_MINIONS :: 128;
WORLD_ROWS_TUTORIAL_FIGHTING_MINIONS :: 128;
WORLD_COLS_TUTORIAL_OUTPOSTS         :: 128;
WORLD_ROWS_TUTORIAL_OUTPOSTS         :: 128;
WORLD_COLS_TUTORIAL_GRADUATION       :: 128;
WORLD_ROWS_TUTORIAL_GRADUATION       :: 128;

TILE_WIDTH_F  :: cast(float32) TILEMAP_GENERAL_WORLD_WIDTH;
TILE_HEIGHT_F :: cast(float32) TILEMAP_GENERAL_WORLD_HEIGHT;

TRANSPARENT_WHITE :: Color.{ 255, 255, 255, 100 };

CHUNK_SIZE :: 32; // 32 x 32 tiles

WATER_FLOW_COOLDOWN_MS :: 1000;
LAVA_FLOW_COOLDOWN_MS  :: 2500;

// TODO: gold and points probably depend on difficulty level

GOLD_FROM_MINE_DIRT :: 1;
GOLD_FROM_MINE_IRON :: 75;
GOLD_FROM_TREASURE  :: 75;

POINTS_FROM_MINE_DIRT :: 1;
POINTS_FROM_MINE_IRON :: 50;
POINTS_FROM_TREASURE  :: 75;

GOLD_COST_BASE      :: 250;
GOLD_COST_DYNAMITE  :: 50;
GOLD_COST_OBSIDIAN  :: 75;
GOLD_COST_PATH_STEP :: 5;
GOLD_COST_WALL      :: 50;

PANIC_PAUSE_DURATION_MS :: 7500;
PANIC_PAUSE_COOLDOWN_MS :: 30000;

ALERT_BANNER_TEXT_MS :: 3000;
HOME_BASE_UNDER_ATTACK_COOLDOWN_MS :: 10000;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Metagame state
////////////////////////////////////////////////////////////////////////////////////////////////////

MetagameThingRunning :: enum {
    MAIN_MENU;
    ROUND;
    TUTORIAL_CONTROLS;
}

MainMenuScreen :: enum {
    ROOT;
    SETTINGS;
    TUTORIAL;
}

MetagameState :: enum {
    RUNNING;
    PAUSED;
    GAME_OVER;
}

PauseState :: enum {
    MENU;
    OPTIONS;
}

GameOverState :: enum {
    MENU;
    LOOK_AROUND;
}

Level :: enum {
    NORMAL;
    TUTORIAL_CONTROLS;
}

Metagame :: struct {
    state            : MetagameState;
    thing_running    : MetagameThingRunning;
    main_menu_screen : MainMenuScreen;
    initialized      : bool;
    should_quit_game : bool;
    debug_mode       : bool;
    pause_state      : PauseState;
    game_over_state  : GameOverState;
    controls         : Controls;
    level            : Level;
}

metagame : Metagame;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Textures
////////////////////////////////////////////////////////////////////////////////////////////////////

TILEMAP_SOURCE_RECT_BASE := Rectangle.{
    0, 0,
    TILEMAP_GENERAL_TILE_WIDTH,
    TILEMAP_GENERAL_TILE_HEIGHT,
};

TILEMAP_SOURCE_RECT_DYNAMITE :: Rectangle.{
    4 * TILEMAP_GENERAL_TILE_WIDTH,
    0 * TILEMAP_GENERAL_TILE_HEIGHT,
    TILEMAP_GENERAL_TILE_WIDTH,
    TILEMAP_GENERAL_TILE_HEIGHT,
};

TILEMAP_SOURCE_RECT_REMOVE :: Rectangle.{
    7 * TILEMAP_GENERAL_TILE_WIDTH,
    0 * TILEMAP_GENERAL_TILE_HEIGHT,
    TILEMAP_GENERAL_TILE_WIDTH,
    TILEMAP_GENERAL_TILE_HEIGHT,
};

TILEMAP_SOURCE_RECT_COIN :: Rectangle.{
    9 * TILEMAP_GENERAL_TILE_WIDTH,
    0 * TILEMAP_GENERAL_TILE_HEIGHT,
    TILEMAP_GENERAL_TILE_WIDTH,
    TILEMAP_GENERAL_TILE_HEIGHT,
};

DWARF_MINER_SCALE :: 1.1;
TILEMAP_DWARF_MINER_MAP_WIDTH    :: 3071;
TILEMAP_DWARF_MINER_MAP_HEIGHT   :: 192;
TILEMAP_DWARF_MINER_TILE_WIDTH   :: 32;
TILEMAP_DWARF_MINER_TILE_HEIGHT  :: 32;
TILEMAP_DWARF_MINER_WORLD_WIDTH  :: TILEMAP_GENERAL_TILE_WIDTH  * DWARF_MINER_SCALE;
TILEMAP_DWARF_MINER_WORLD_HEIGHT :: TILEMAP_GENERAL_TILE_HEIGHT * DWARF_MINER_SCALE;

tilemap_texture_general : Texture;
lava_flowing_texture    : Texture;
water_flowing_texture   : Texture;
water_still_texture     : Texture;
dirt_texture            : Texture;
dwarf_miner_texture     : Texture;

init_textures :: () {
    // TODO: have just one big happy atlas, maybe?
    tilemap_texture_general = LoadTexture("data/tilemap-general.png");
    lava_flowing_texture    = LoadTexture("data/lava-flowing.png");
    water_flowing_texture   = LoadTexture("data/water-flowing.png");
    water_still_texture     = LoadTexture("data/water-still.png");
    dirt_texture            = LoadTexture("data/dirt.png");
    dwarf_miner_texture     = LoadTexture("data/dwarf-miner.png");

    // The plan is just to just render a big-ass quad and tile the dirt over it.
    SetTextureWrap(dirt_texture, .TEXTURE_WRAP_REPEAT);
}

init_sprites :: () {

}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Controls
////////////////////////////////////////////////////////////////////////////////////////////////////

ControlsState :: struct {
    select_is_pressed_once        : bool;
    select_is_held_down           : bool;
    selection_cleared             : bool;
    toggle_base_mode              : bool;
    toggle_dynamite_mode          : bool;
    toggle_obsidian_mode          : bool;
    toggle_wall_mode              : bool;
    toggle_remove_mode            : bool;
    add_iron                      : bool;
    select_as_place_miner_dwarf   : bool;
    select_as_place_warrior_dwarf : bool;
    select_as_place_goblin        : bool;
    started_to_draw_path          : bool;
    drawing_path                  : bool;
    drag_cam_pressed              : bool;
    drag_cam_down                 : bool;
    move_camera_up                : bool;
    move_camera_down              : bool;
    move_camera_left              : bool;
    move_camera_right             : bool;
    panic_pause                   : bool;
    fast_forward                  : bool;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Other
////////////////////////////////////////////////////////////////////////////////////////////////////

// TODO: add this as param in build or something
PAUSE_ON_PANIC :: true;

mouse_drag_began_at_pos : Vector2;
mouse_pos_when_path_creation_started : Vector2;

GameState :: struct {
    hovered_dwarf_index        : int;
    selected_dwarf_id          : s32;
    selected_dwarf_particle_id : s32;
    water_flow_cooldown_ms     : int;
    lava_flow_cooldown_ms      : int;
    time_remaining_ms          : int;
    points                     : int;
    gold                       : int;
    control_mode               : ControlMode;
    panic_pause_timer_ms       : int;
    controls_state_this_frame  : ControlsState;
    controls_state_prev_frame  : ControlsState;
    alert_banner_text          : string;
    alert_banner_text_ms       : int;
    alert_banner_text_color    : Color;
    home_base_under_attack_cooldown_ms : int;
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
    CENTER     :: 8; // essentially no direction
}

DIRECTIONS_CARDINAL :: #run array_view(enum_values_as_enum(Direction), 0, 4);
DIRECTIONS_CORNER   :: #run array_view(enum_values_as_enum(Direction), 4, enum_highest_value(Direction));
DIRECTIONS_COMPASS  :: #run array_view(enum_values_as_enum(Direction), 0, enum_highest_value(Direction));
DIRECTIONS_ALL      :: #run array_view(enum_values_as_enum(Direction), 0, enum_highest_value(Direction) + 1);

TILE_DIRECTION_DELTAS :: [2] float32.[
    .[0.0, -TILEMAP_GENERAL_WORLD_HEIGHT], // north
    .[0.0, +TILEMAP_GENERAL_WORLD_HEIGHT], // south
    .[+TILEMAP_GENERAL_WORLD_WIDTH, 0.0],  // east
    .[-TILEMAP_GENERAL_WORLD_WIDTH, 0.0],  // west
    .[+TILEMAP_GENERAL_WORLD_WIDTH, -TILEMAP_GENERAL_WORLD_HEIGHT], // north east
    .[-TILEMAP_GENERAL_WORLD_WIDTH, -TILEMAP_GENERAL_WORLD_HEIGHT], // north west
    .[+TILEMAP_GENERAL_WORLD_WIDTH, +TILEMAP_GENERAL_WORLD_HEIGHT], // south east
    .[-TILEMAP_GENERAL_WORLD_WIDTH, +TILEMAP_GENERAL_WORLD_HEIGHT], // south west
    .[0.0, 0.0], // center
];

#add_context camera_zoom_min  : float32;
#add_context world_cols       : int;
#add_context world_rows       : int;
#add_context world_cols_mask  : int;  
#add_context world_rows_mask  : int;  
#add_context world_cols_shift : int;  
#add_context world_cols_recip : float;
#add_context world_rows_recip : float;

get_tile_direction_id_deltas :: (direction: Direction) -> [2] s32 {
    if #complete direction == {
        case .NORTH;      return .[ 0, xx -context.world_cols];
        case .SOUTH;      return .[ 0, xx +context.world_cols];
        case .EAST;       return .[+1,  0];
        case .WEST;       return .[-1,  0];
        case .NORTH_EAST; return .[+1, xx -context.world_cols];
        case .NORTH_WEST; return .[-1, xx -context.world_cols];
        case .SOUTH_EAST; return .[+1, xx +context.world_cols];
        case .SOUTH_WEST; return .[-1, xx +context.world_cols];
        case .CENTER;     return .[ 0,  0];
    }
}

CaveType :: enum u8 {
    EMPTY;
    WATER;
    LAVA;
    TREASURE;
    GOBLIN;
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
    WALL;
    HOLE;
}

Particle :: struct {
    id                    : s32;
    pos                   : Vector2;
    vel                   : Vector2;
    damp                  : float;
    text                  : string;
    tint                  : Color;
    fade                  : bool;
    opacity               : float;
    time_left_ms          : int;
    sprite_source_row     : int; // 0 indexed
    sprite_source_col     : int; // 0 indexed
    entity_id_to_follow   : s32;
    entity_kind_to_follow : EntityKind;
}

Entity :: struct {
    id   : s32;
    pos  : Vector2;
    hp   : s32;
    kind : Type;
}

Moveable :: struct {
    direction        : Direction;
    tile_ids_on_path : [..] s32;
}

Base :: struct {
    #as using entity: Entity;

    kind = Base;

    spawn_dwarf_cooldown_ms : s32;
    is_home_base : bool;
}

DwarfState :: enum {
    IDLE;
    DECIDING;
    MOVING;
    ATTACKING;
    MINING;
}

DwarfType :: enum {
    MINER;
    WARRIOR;
}

DwarfAnimation :: enum {
    IDLE :: 0;
    WALK :: 1;
    MINE :: 2;
    DIE  :: 3;
};

Dwarf :: struct {
    #as using entity: Entity;
    using move: Moveable;

    kind = Dwarf;

    state               : DwarfState;
    animations          : [4] AnimatedSprite;
    did_anim_action     : bool;
    attack_cooldown_ms  : s32;
    tile_id_mining      : s32;
    goblin_id_attacking : s32; // TODO: is this right? feels overly specific
    dwarf_type          : DwarfType;
    ignore_goblins_for  : int;
    is_moving_quickly   : bool;
    is_facing_left      : bool;
}

GoblinState :: enum {
    IDLE;
    DECIDING;
    MOVING;
    ATTACKING;
}

Goblin :: struct {
    #as using entity: Entity;
    using move: Moveable;

    kind = Goblin;

    state               : GoblinState;
    attack_cooldown_ms  : s32;
    entity_id_attacking : s32;
}

Path :: struct {
    start_tile_id : s32;
    direction     : Direction;
    tile_count    : int;
}

Chunk :: struct {
    fully_mined_tile_ids    : [..] s32;
    cave_tile_ids           : [..] s32;
    encased_tile_ids        : [..] s32;
    actively_mined_tile_ids : [..] s32;
    iron_tile_ids           : [..] s32;
    obsidian_tile_ids       : [..] s32;
    wall_tile_ids           : [..] s32;
    water_still_tile_ids    : [..] s32;
    water_flowing_tile_ids  : [..] s32;
    lava_still_tile_ids     : [..] s32;
    lava_flowing_tile_ids   : [..] s32;
    hole_tile_ids           : [..] s32;
    base_ids                : [..] s32;

    // TODO: Will probably want these
    // dwarf_ids               : [..] s32;
    // dynamite : [..] Dynamite;
}

NOTIFICATION_RADIUS :: TILEMAP_GENERAL_WORLD_WIDTH;
ALERT_TIME_TO_LIVE_MS :: 5000;

AlertType :: enum {
    WATER;
    LAVA;
    GOBLINS;
    TREASURE;
    BASE_UNDER_ATTACK;
    SHAMAN;
    SPIDER_QUEEN;
}

Alert :: struct {
    pos          : Vector2;
    seen         : bool; // Whether the user has seen it onscreen yet
    color        : Color;
    alert_type   : AlertType;
    time_left_ms : int;
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

// The value in the key-value pair corresponds to the tile column, zero-indexed
fully_mined_tile_ids_set         : Table(s32, s32);
fully_mined_tile_ids_in_viewport : [..] s32;

cave_tile_ids_set         : Table(s32, Any);
cave_tile_ids_in_viewport : [..] s32;

encased_tile_ids_set         : Table(s32, Any);
encased_tile_ids_in_viewport : [..] s32;

iron_tile_ids_set         : Table(s32, Any);
iron_tile_ids_in_viewport : [..] s32;

water_still_tile_ids             : [..] s32;
water_still_tile_ids_to_sprite   : Table(s32, AnimatedSprite); // TODO: can I just have 1 global sprite for water that tiles?
water_still_tile_ids_in_viewport : [..] s32;

water_flowing_tile_ids             : [..] s32;
water_flowing_tile_ids_to_sprite   : Table(s32, AnimatedSprite);
water_flowing_tile_ids_in_viewport : [..] s32;

lava_still_tile_ids             : [..] s32;
lava_still_tile_ids_set         : Table(s32, AnimatedSprite); // NOTE: not storing AnimatedSprites in here yet
lava_still_tile_ids_in_viewport : [..] s32;

lava_flowing_tile_ids             : [..] s32;
lava_flowing_tile_ids_to_sprite   : Table(s32, AnimatedSprite);
lava_flowing_tile_ids_in_viewport : [..] s32;

water_warning_tile_ids             : [..] s32;
water_warning_tile_ids_set         : Table(s32, Any);
water_warning_tile_ids_in_viewport : [..] s32;

water_alert_tile_ids             : [..] s32;
water_alert_tile_ids_set         : Table(s32, Any);
water_alert_tile_ids_in_viewport : [..] s32;

lava_warning_tile_ids              : [..] s32;
lava_warning_tile_ids_set          : Table(s32, Any);
lava_warning_tile_ids_in_viewport  : [..] s32;

lava_alert_tile_ids             : [..] s32;
lava_alert_tile_ids_set         : Table(s32, Any);
lava_alert_tile_ids_in_viewport : [..] s32;

obsidian_tile_ids_set         : Table(s32, Any);
obsidian_tile_ids_in_viewport : [..] s32;

wall_tile_ids_set         : Table(s32, s32);
wall_tile_ids_in_viewport : [..] s32;

entity_id_counter   : s32 = 0;
control_id_counter  : s32 = 0;
particle_id_counter : s32 = 0;

bases             : [..] Base;
base_id_to_index  : Table(s32, s64);
bases_in_viewport : [..] Base;

dwarves             : [..] Dwarf;
dwarf_id_to_index   : Table(s32, s64);
dwarves_in_viewport : [..] Dwarf;

goblins             : [..] Goblin;
goblin_id_to_index  : Table(s32, s64);
goblins_in_viewport : [..] Goblin;

particles             : [..] Particle;
particle_id_to_index  : Table(s32, s64);
particles_in_viewport : [..] Particle;     

tiles_with_dynamite_ids             : [..] s32;
tiles_with_dynamite_ids_in_viewport : [..] s32;

tiles_with_treasure_ids             : [..] s32;
tiles_with_treasure_ids_set         : Table(s32, s32);
tiles_with_treasure_ids_in_viewport : [..] s32;

hole_tile_ids             : [..] s32;
hole_tile_ids_set         : Table(s32, s32);
hole_tile_ids_in_viewport : [..] s32;

path_being_traced_1 : Path;
path_being_traced_2 : Path;

paths             : [..] Path;
paths_in_viewport : [..] Path;

tile_ids_to_dwarfs  : Table(s32, *Dwarf);
tile_ids_to_goblins : Table(s32, *Goblin);
tile_ids_to_bases   : Table(s32, *Base);

alerts             : [..] Alert;
alerts_in_viewport : [..] Alert;

created_chunks: Table(u64, *Chunk);

#insert #run generate_kind_enum_from_base_struct(Entity);

// TODO: remember screen dimension preferences
INITIAL_SCREEN_WIDTH  :: 1600;
INITIAL_SCREEN_HEIGHT :: 900;

main :: () {
    // SetConfigFlags(.FLAG_WINDOW_RESIZABLE | .FLAG_FULLSCREEN_MODE);
    SetConfigFlags(.FLAG_WINDOW_RESIZABLE);

    InitWindow(INITIAL_SCREEN_WIDTH, INITIAL_SCREEN_HEIGHT, "Dwarfs?! Clone");
    defer CloseWindow();

    // HideCursor(); // TODO: render a custom one from a texture.
    SetTargetFPS(144);
    SetExitKey(.KEY_NULL);

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

    game_state : GameState;
    camera     : Camera2D;

    while !metagame.should_quit_game {
        defer metagame.should_quit_game = metagame.should_quit_game || WindowShouldClose();

        if #complete metagame.thing_running == {
            case .MAIN_MENU;
                metagame = update_and_draw_frame_main_menu();
            case .ROUND;
                if metagame.initialized {
                    metagame = update_and_draw_frame_round(*game_state, *camera);
                } else {
                    game_state, metagame, camera = initialize_round();
                }
            case .TUTORIAL_CONTROLS;
        }
    }
}

// Functions

dwarf_maybe_set_active_animation :: (dwarf: *Dwarf, active_animation_index: DwarfAnimation) {
    for dwarf.animations {
        // If there are any animations currently playing, let them finish before moving on
        if it_index != xx active_animation_index && it.active then return;
    }
    dwarf_set_active_animation(dwarf, active_animation_index);
}
    
dwarf_set_active_animation :: (dwarf: *Dwarf, active_animation_index: DwarfAnimation) {
    dwarf.animations[DwarfAnimation.IDLE].active = active_animation_index == DwarfAnimation.IDLE;
    dwarf.animations[DwarfAnimation.WALK].active = active_animation_index == DwarfAnimation.WALK;
    dwarf.animations[DwarfAnimation.MINE].active = active_animation_index == DwarfAnimation.MINE;
    dwarf.animations[DwarfAnimation.DIE].active  = active_animation_index == DwarfAnimation.DIE;
}

draw_trench_walls_if_necessary :: (tile_id: s32) {
    TRENCH_STRAIGHT_SPRITE_SOURCE_ROW :: 2;
    TRENCH_STRAIGHT_SPRITE_SOURCE_COL :: 0;

    for dir: DIRECTIONS_CARDINAL {
        dx := get_tile_direction_id_deltas(dir)[0];
        dy := get_tile_direction_id_deltas(dir)[1];
        neighbor_id := tile_id + dx + dy;

        if is_tile_id_dirt(neighbor_id) {
            source := Rectangle.{
                TRENCH_STRAIGHT_SPRITE_SOURCE_COL * TILEMAP_GENERAL_TILE_WIDTH,
                TRENCH_STRAIGHT_SPRITE_SOURCE_ROW * TILEMAP_GENERAL_TILE_HEIGHT,
                TILEMAP_GENERAL_TILE_WIDTH,
                TILEMAP_GENERAL_TILE_HEIGHT,
            };

            pos  := get_tile_pos_by_id(neighbor_id);
            dest := get_world_rect_from_pos(pos);
            rot  := 0.0;

            if dir == {
                case .SOUTH;
                    rot     = 180.0;
                    dest.x += TILEMAP_GENERAL_TILE_WIDTH;
                    dest.y += TILEMAP_GENERAL_TILE_HEIGHT;
                case .EAST;
                    rot = 90.0;
                    dest.x += TILEMAP_GENERAL_TILE_WIDTH;
                case .WEST;
                    rot = 270.0;
                    dest.y += TILEMAP_GENERAL_TILE_HEIGHT;
            }

            DrawTexturePro(tilemap_texture_general, source, dest, Vector2.{0,0}, rot, WHITE);
        }
    }
}

// TODO: this function is kinda fat
draw_trench_corners_if_necessary :: (tile_id: s32) {
    TRENCH_CORNER_MOSTLY_CRUST_NORTH_EAST_SPRITE_SOURCE_ROW :: 2;
    TRENCH_CORNER_MOSTLY_CRUST_NORTH_EAST_SPRITE_SOURCE_COL :: 1;
    TRENCH_CORNER_MOSTLY_CRUST_NORTH_WEST_SPRITE_SOURCE_ROW :: 2;
    TRENCH_CORNER_MOSTLY_CRUST_NORTH_WEST_SPRITE_SOURCE_COL :: 2;
    TRENCH_CORNER_MOSTLY_CRUST_SOUTH_EAST_SPRITE_SOURCE_ROW :: 2;
    TRENCH_CORNER_MOSTLY_CRUST_SOUTH_EAST_SPRITE_SOURCE_COL :: 3;
    TRENCH_CORNER_MOSTLY_CRUST_SOUTH_WEST_SPRITE_SOURCE_ROW :: 2;
    TRENCH_CORNER_MOSTLY_CRUST_SOUTH_WEST_SPRITE_SOURCE_COL :: 4;

    TRENCH_CORNER_MOSTLY_DIRT_NORTH_EAST_SPRITE_SOURCE_ROW :: 3;
    TRENCH_CORNER_MOSTLY_DIRT_NORTH_EAST_SPRITE_SOURCE_COL :: 1;
    TRENCH_CORNER_MOSTLY_DIRT_NORTH_WEST_SPRITE_SOURCE_ROW :: 3;
    TRENCH_CORNER_MOSTLY_DIRT_NORTH_WEST_SPRITE_SOURCE_COL :: 2;
    TRENCH_CORNER_MOSTLY_DIRT_SOUTH_EAST_SPRITE_SOURCE_ROW :: 3;
    TRENCH_CORNER_MOSTLY_DIRT_SOUTH_EAST_SPRITE_SOURCE_COL :: 3;
    TRENCH_CORNER_MOSTLY_DIRT_SOUTH_WEST_SPRITE_SOURCE_ROW :: 3;
    TRENCH_CORNER_MOSTLY_DIRT_SOUTH_WEST_SPRITE_SOURCE_COL :: 4;

    for dir: DIRECTIONS_CORNER {
        dx := get_tile_direction_id_deltas(dir)[0];
        dy := get_tile_direction_id_deltas(dir)[1];
        neighbor_id := tile_id + dx + dy;

        source_one := Rectangle.{
            1738.0, 1738.0,
            TILEMAP_GENERAL_TILE_WIDTH,
            TILEMAP_GENERAL_TILE_HEIGHT,
        };
        source_two := Rectangle.{
            1738.0, 1738.0,
            TILEMAP_GENERAL_TILE_WIDTH,
            TILEMAP_GENERAL_TILE_HEIGHT,
        };

        pos_one := get_tile_pos_by_id(neighbor_id);
        pos_two : Vector2;

        dest_one := get_world_rect_from_pos(pos_one);
        dest_two : Rectangle;
        
        render_one := true;
        render_two := false;

        if dir == {
            case .NORTH_EAST;
                id_deltas_north      := get_tile_direction_id_deltas(.NORTH);
                id_deltas_east       := get_tile_direction_id_deltas(.EAST);
                id_deltas_north_east := get_tile_direction_id_deltas(.NORTH_EAST);

                neighbor_id_north      := tile_id + id_deltas_north[0] + id_deltas_north[1];
                neighbor_id_east       := tile_id + id_deltas_east[0] + id_deltas_east[1];
                neighbor_id_north_east := tile_id + id_deltas_north_east[0] + id_deltas_north_east[1];

                if is_tile_id_dirt(neighbor_id_north_east) {
                    if is_tile_id_dirt(neighbor_id_north) && is_tile_id_dirt(neighbor_id_east) {
                        source_one.x = TRENCH_CORNER_MOSTLY_DIRT_NORTH_EAST_SPRITE_SOURCE_COL * TILEMAP_GENERAL_TILE_WIDTH;
                        source_one.y = TRENCH_CORNER_MOSTLY_DIRT_NORTH_EAST_SPRITE_SOURCE_ROW * TILEMAP_GENERAL_TILE_HEIGHT;
                    }
                    else if !is_tile_id_dirt(neighbor_id_north) && !is_tile_id_dirt(neighbor_id_east) {
                        source_one.x = TRENCH_CORNER_MOSTLY_CRUST_NORTH_EAST_SPRITE_SOURCE_COL * TILEMAP_GENERAL_TILE_WIDTH;
                        source_one.y = TRENCH_CORNER_MOSTLY_CRUST_NORTH_EAST_SPRITE_SOURCE_ROW * TILEMAP_GENERAL_TILE_HEIGHT;
                    }
                    else {
                        render_one = false;
                    }
                } else {
                    if is_tile_id_dirt(neighbor_id_north) && is_tile_id_dirt(neighbor_id_east) {
                        source_one.x = TRENCH_CORNER_MOSTLY_CRUST_NORTH_WEST_SPRITE_SOURCE_COL * TILEMAP_GENERAL_TILE_WIDTH;
                        source_one.y = TRENCH_CORNER_MOSTLY_CRUST_NORTH_WEST_SPRITE_SOURCE_ROW * TILEMAP_GENERAL_TILE_HEIGHT;
                        pos_one      = get_tile_pos_by_id(neighbor_id_north);
                        dest_one     = get_world_rect_from_pos(pos_one);

                        source_two.x = TRENCH_CORNER_MOSTLY_CRUST_SOUTH_EAST_SPRITE_SOURCE_COL * TILEMAP_GENERAL_TILE_WIDTH;
                        source_two.y = TRENCH_CORNER_MOSTLY_CRUST_SOUTH_EAST_SPRITE_SOURCE_ROW * TILEMAP_GENERAL_TILE_HEIGHT;
                        pos_two      = get_tile_pos_by_id(neighbor_id_east);
                        dest_two     = get_world_rect_from_pos(pos_two);

                        render_two = true;
                    }
                }
            case .NORTH_WEST;
                id_deltas_north      := get_tile_direction_id_deltas(.NORTH);
                id_deltas_west       := get_tile_direction_id_deltas(.WEST);
                id_deltas_north_west := get_tile_direction_id_deltas(.NORTH_WEST);

                neighbor_id_north      := tile_id + id_deltas_north[0] + id_deltas_north[1];
                neighbor_id_west       := tile_id + id_deltas_west[0] + id_deltas_west[1];
                neighbor_id_north_west := tile_id + id_deltas_north_west[0] + id_deltas_north_west[1];

                if is_tile_id_dirt(neighbor_id_north_west) {
                    if is_tile_id_dirt(neighbor_id_north) && is_tile_id_dirt(neighbor_id_west) {
                        source_one.x = TRENCH_CORNER_MOSTLY_DIRT_NORTH_WEST_SPRITE_SOURCE_COL * TILEMAP_GENERAL_TILE_WIDTH;
                        source_one.y = TRENCH_CORNER_MOSTLY_DIRT_NORTH_WEST_SPRITE_SOURCE_ROW * TILEMAP_GENERAL_TILE_HEIGHT;
                    }
                    else if !is_tile_id_dirt(neighbor_id_north) && !is_tile_id_dirt(neighbor_id_west) {
                        source_one.x = TRENCH_CORNER_MOSTLY_CRUST_NORTH_WEST_SPRITE_SOURCE_COL * TILEMAP_GENERAL_TILE_WIDTH;
                        source_one.y = TRENCH_CORNER_MOSTLY_CRUST_NORTH_WEST_SPRITE_SOURCE_ROW * TILEMAP_GENERAL_TILE_HEIGHT;
                    }
                    else {
                        render_one = false;
                    }
                } else {
                    if is_tile_id_dirt(neighbor_id_north) && is_tile_id_dirt(neighbor_id_west) {
                        source_one.x = TRENCH_CORNER_MOSTLY_CRUST_NORTH_EAST_SPRITE_SOURCE_COL * TILEMAP_GENERAL_TILE_WIDTH;
                        source_one.y = TRENCH_CORNER_MOSTLY_CRUST_NORTH_EAST_SPRITE_SOURCE_ROW * TILEMAP_GENERAL_TILE_HEIGHT;
                        pos_one      = get_tile_pos_by_id(neighbor_id_north);
                        dest_one     = get_world_rect_from_pos(pos_one);

                        source_two.x = TRENCH_CORNER_MOSTLY_CRUST_SOUTH_WEST_SPRITE_SOURCE_COL * TILEMAP_GENERAL_TILE_WIDTH;
                        source_two.y = TRENCH_CORNER_MOSTLY_CRUST_SOUTH_WEST_SPRITE_SOURCE_ROW * TILEMAP_GENERAL_TILE_HEIGHT;
                        pos_two      = get_tile_pos_by_id(neighbor_id_west);
                        dest_two     = get_world_rect_from_pos(pos_two);

                        render_two = true;
                    }
                }
            case .SOUTH_EAST;
                id_deltas_south      := get_tile_direction_id_deltas(.SOUTH);
                id_deltas_east       := get_tile_direction_id_deltas(.EAST);
                id_deltas_south_east := get_tile_direction_id_deltas(.SOUTH_EAST);

                neighbor_id_south      := tile_id + id_deltas_south[0] + id_deltas_south[1];
                neighbor_id_east       := tile_id + id_deltas_east[0] + id_deltas_east[1];
                neighbor_id_south_east := tile_id + id_deltas_south_east[0] + id_deltas_south_east[1];

                if is_tile_id_dirt(neighbor_id_south_east) {
                    if is_tile_id_dirt(neighbor_id_south) && is_tile_id_dirt(neighbor_id_east) {
                        source_one.x = TRENCH_CORNER_MOSTLY_DIRT_SOUTH_EAST_SPRITE_SOURCE_COL * TILEMAP_GENERAL_TILE_WIDTH;
                        source_one.y = TRENCH_CORNER_MOSTLY_DIRT_SOUTH_EAST_SPRITE_SOURCE_ROW * TILEMAP_GENERAL_TILE_HEIGHT;
                    }
                    else if !is_tile_id_dirt(neighbor_id_south) && !is_tile_id_dirt(neighbor_id_east) {
                        source_one.x = TRENCH_CORNER_MOSTLY_CRUST_SOUTH_EAST_SPRITE_SOURCE_COL * TILEMAP_GENERAL_TILE_WIDTH;
                        source_one.y = TRENCH_CORNER_MOSTLY_CRUST_SOUTH_EAST_SPRITE_SOURCE_ROW * TILEMAP_GENERAL_TILE_HEIGHT;
                    }
                    else {
                        render_one = false;
                    }
                }
            case .SOUTH_WEST;
                id_deltas_south      := get_tile_direction_id_deltas(.SOUTH);
                id_deltas_west       := get_tile_direction_id_deltas(.WEST);
                id_deltas_south_west := get_tile_direction_id_deltas(.SOUTH_WEST);

                neighbor_id_south      := tile_id + id_deltas_south[0] + id_deltas_south[1];
                neighbor_id_west       := tile_id + id_deltas_west[0] + id_deltas_west[1];
                neighbor_id_south_west := tile_id + id_deltas_south_west[0] + id_deltas_south_west[1];

                if is_tile_id_dirt(neighbor_id_south_west) {
                    if is_tile_id_dirt(neighbor_id_south) && is_tile_id_dirt(neighbor_id_west) {
                        source_one.x = TRENCH_CORNER_MOSTLY_DIRT_SOUTH_WEST_SPRITE_SOURCE_COL * TILEMAP_GENERAL_TILE_WIDTH;
                        source_one.y = TRENCH_CORNER_MOSTLY_DIRT_SOUTH_WEST_SPRITE_SOURCE_ROW * TILEMAP_GENERAL_TILE_HEIGHT;
                    }
                    else if !is_tile_id_dirt(neighbor_id_south) && !is_tile_id_dirt(neighbor_id_west) {
                        source_one.x = TRENCH_CORNER_MOSTLY_CRUST_SOUTH_WEST_SPRITE_SOURCE_COL * TILEMAP_GENERAL_TILE_WIDTH;
                        source_one.y = TRENCH_CORNER_MOSTLY_CRUST_SOUTH_WEST_SPRITE_SOURCE_ROW * TILEMAP_GENERAL_TILE_HEIGHT;
                    }
                    else {
                        render_one = false;
                    }
                }
        }

        if render_one then DrawTexturePro(tilemap_texture_general, source_one, dest_one, Vector2.{0,0}, 0.0, WHITE);
        if render_two then DrawTexturePro(tilemap_texture_general, source_two, dest_two, Vector2.{0,0}, 0.0, WHITE);
    }
}

LiquidType :: enum {
    WATER;
    LAVA;
}

determine_rotation_of_liquid_flowing_sprite :: (tile_id: s32, liquid_type: LiquidType) -> float {
    north_tile_id : s32 = tile_id - xx context.world_rows;
    south_tile_id : s32 = tile_id + xx context.world_rows;
    east_tile_id  : s32 = tile_id + 1;
    west_tile_id  : s32 = tile_id - 1;

    liquid_still_tile_ids_set : Table(s32, AnimatedSprite);

    if #complete liquid_type == {
        case .WATER; liquid_still_tile_ids_set = water_still_tile_ids_to_sprite;
        case .LAVA;  liquid_still_tile_ids_set = lava_still_tile_ids_set;
    }

    is_neighbor_north_liquid_still := table_contains(*liquid_still_tile_ids_set, north_tile_id);
    is_neighbor_south_liquid_still := table_contains(*liquid_still_tile_ids_set, south_tile_id);
    is_neighbor_east_liquid_still  := table_contains(*liquid_still_tile_ids_set, east_tile_id);
    is_neighbor_west_liquid_still  := table_contains(*liquid_still_tile_ids_set, west_tile_id);

    if (
        is_neighbor_north_liquid_still  &&
        !is_neighbor_south_liquid_still &&
        !is_neighbor_east_liquid_still  &&
        !is_neighbor_west_liquid_still
    ) return 0;

    if (
        !is_neighbor_north_liquid_still &&
        is_neighbor_south_liquid_still  &&
        !is_neighbor_east_liquid_still  &&
        !is_neighbor_west_liquid_still
    ) return 180; // Flow to the left if the only lava around is to the right

    if is_neighbor_east_liquid_still return 90;
    if is_neighbor_west_liquid_still return 270;

    return 0;
}

update_and_draw_frame_main_menu :: () -> metagame: Metagame {
    screen_width  := GetScreenWidth();
    screen_height := GetScreenHeight();

    BeginDrawing();
    defer EndDrawing();

    ClearBackground(BEIGE);

    if #complete metagame.main_menu_screen == {
        case .ROOT;
            // Button shared sizing stuff
            main_menu_button_width  := screen_width  * 0.15;
            main_menu_button_height := screen_height * 0.10;
            main_menu_button_margin :: 20;
            main_menu_button_gap    :: 10;

            MAIN_MENU_BUTTON_COUNT :: 4;

            get_main_button_rectangle :: (button_gap: int, button_y: float, button_width: float, button_height: float) -> Rectangle {
                screen_width := GetScreenWidth();

                return Rectangle.{
                    screen_width * 0.5 - button_width * 0.5,
                    button_y,
                    button_width,
                    button_height
                };
            }

            main_menu_button_y := screen_height * 0.5 - (MAIN_MENU_BUTTON_COUNT * 0.5 * main_menu_button_height) - (MAIN_MENU_BUTTON_COUNT * 0.5 - 0.5) * main_menu_button_gap;

            // Start new round button
            {
                defer main_menu_button_y += main_menu_button_height + main_menu_button_gap;

                start_new_button := get_main_button_rectangle(main_menu_button_gap, main_menu_button_y, main_menu_button_width, main_menu_button_height);

                clicked := GuiButton(start_new_button, "Start new round");

                if clicked {
                    metagame.thing_running = .ROUND;
                    metagame.initialized   = false;
                    metagame.level         = .NORMAL;
                }
            }

            // Tutorial button
            {
                defer main_menu_button_y += main_menu_button_height + main_menu_button_gap;

                tutorial_button := get_main_button_rectangle(main_menu_button_gap, main_menu_button_y, main_menu_button_width, main_menu_button_height);

                clicked := GuiButton(tutorial_button, "Tutorial");

                if clicked {
                    metagame.thing_running = .ROUND;
                    metagame.initialized   = false;
                    metagame.level         = .TUTORIAL_CONTROLS;
                }
            }

            // Settings
            {
                defer main_menu_button_y += main_menu_button_height + main_menu_button_gap;

                settings_button := get_main_button_rectangle(main_menu_button_gap, main_menu_button_y, main_menu_button_width, main_menu_button_height);

                clicked := GuiButton(settings_button, "Settings");

                if clicked {
                    // TODO
                }
            }

            // Quit to desktop button
            {
                defer main_menu_button_y += main_menu_button_height + main_menu_button_gap;

                quit_button := get_main_button_rectangle(main_menu_button_gap, main_menu_button_y, main_menu_button_width, main_menu_button_height);

                clicked := GuiButton(quit_button, "Quit");

                if clicked then metagame.should_quit_game = true;
            }
        case .SETTINGS;
        case .TUTORIAL;
    }

    return metagame;
}

update_and_draw_frame_round :: (game_state: *GameState, camera: *Camera2D) -> metagame: Metagame {
    // PERF: can this be keep_memory?
    table_reset(*tile_ids_to_dwarfs);
    table_reset(*tile_ids_to_goblins);
    table_reset(*tile_ids_to_bases);
    reset_temporary_storage();

    DT_MULTIPLIER_FAST_FORWARD :: 5;
    dt_seconds_raw := GetFrameTime();
    // Cap delta time to prevent teleporting or weird bullshit
    dt_seconds : float;
    if dt_seconds_raw > 0.033 {
        dt_seconds = 0.033;
    } else {
        dt_seconds = dt_seconds_raw;
        if game_state.controls_state_this_frame.fast_forward {
            dt_seconds *= DT_MULTIPLIER_FAST_FORWARD;
        }
    }

    panic_pause_is_active := game_state.panic_pause_timer_ms > 0 && game_state.panic_pause_timer_ms >= PANIC_PAUSE_COOLDOWN_MS - PANIC_PAUSE_DURATION_MS;
    panic_pause_is_cooling_down := game_state.panic_pause_timer_ms > 0;

    mouse_pos_in_ui    := GetMousePosition();
    mouse_pos_in_world := GetScreenToWorld2D(mouse_pos_in_ui, camera);
    mouse_wheel_move   := GetMouseWheelMove();

    window_start := GetScreenToWorld2D(Vector2.{ 0, 0 }, camera);
    window_end   := GetScreenToWorld2D(Vector2.{ cast(float) GetScreenWidth(), cast(float) GetScreenHeight()}, camera);

    // TODO: save this in game_state or something
    dwarf_miner_count   := 0;
    dwarf_warrior_count := 0;

    // Populate caches
    {
        for *dwarf: dwarves {
            dwarf_tile_id: s32;

            if #complete dwarf.state == {
                // If the dwarf is dead center on a tile and not moving, it's on that tile.
                case .IDLE;      #through;
                case .DECIDING;  #through;
                case .ATTACKING; #through;
                case .MINING;
                    dwarf_tile_id = get_tile_id_by_pos(dwarf.pos);

                // If the dwarf is moving, then they're "on" the tile that they're moving to.
                case .MOVING;
                    assert_soft(dwarf.tile_ids_on_path.count > 0, "Dwarf was in move state but had nowhere to go\n");
                    dwarf_tile_id = dwarf.tile_ids_on_path[0];
            }

            assert_soft(dwarf_tile_id > 0, "Expected dwarf_tile_id to have been set, but got %\n", dwarf_tile_id);
            table_set(*tile_ids_to_dwarfs, dwarf_tile_id, dwarf);

            if      dwarf.dwarf_type == .MINER   dwarf_miner_count += 1;
            else if dwarf.dwarf_type == .WARRIOR dwarf_warrior_count += 1;
            else    assert_soft(false, "Dwarf % was neither a miner nor warrior\n", dwarf.id);
        }

        for *goblin: goblins {
            if #complete goblin.state == {
                // If the goblin is dead center on a tile and not moving, it's on that tile.
                case .IDLE;     #through;
                case .DECIDING; #through;
                case .ATTACKING;
                    goblin_tile_id := get_tile_id_by_pos(goblin.pos);

                    assert_soft(goblin_tile_id > 0, "Expected goblin_tile_id to have been set, but got % \n", goblin_tile_id);

                    table_set(*tile_ids_to_goblins, goblin_tile_id, goblin);

                // If the goblin is moving, then count both the tile they're moving from and to.
                case .MOVING;
                    assert_soft(goblin.tile_ids_on_path.count > 0, "Goblin was in move state but had nowhere to go\n");

                    goblin_tile_id_from := get_previous_tile_id(goblin);
                    goblin_tile_id_to   := goblin.tile_ids_on_path[0];

                    assert_soft(goblin_tile_id_from > 0, "Expected goblin_tile_id_from to have been set, but got % \n", goblin_tile_id_from);
                    assert_soft(goblin_tile_id_to > 0,   "Expected goblin_tile_id_to to have been set, but got % \n",   goblin_tile_id_to);

                    table_set(*tile_ids_to_goblins, goblin_tile_id_to,   goblin);
                    table_set(*tile_ids_to_goblins, goblin_tile_id_from, goblin);
            }
        }

        // PERF: caching this might not even be faster
        for *base: bases {
            base_center  := get_rect_center(get_world_rect_from_pos(base.pos));
            base_tile_id := get_tile_id_by_pos(base_center);
            table_set(*tile_ids_to_bases, base_tile_id, base);
        }
    }

    //
    // Input
    //
    {
        // TODO: codify metagame controls/
        //
        // Metagame controls
        if IsKeyPressed(.KEY_ESCAPE) {
            if #complete metagame.state == {
                case .RUNNING;
                    metagame.state = .PAUSED;
                case .PAUSED;
                    if #complete metagame.pause_state == {
                        case .MENU;
                            metagame.state = .RUNNING;
                        case .OPTIONS;
                            // TODO: do this somewhat intelligently
                            //
                            // Set any binds currently being set to not being set
                            for *metagame.controls.select.binds                        it.is_being_rebound = false;
                            for *metagame.controls.clear_selection.binds               it.is_being_rebound = false;
                            for *metagame.controls.toggle_base_mode.binds              it.is_being_rebound = false;
                            for *metagame.controls.add_iron.binds                      it.is_being_rebound = false;
                            for *metagame.controls.select_as_place_miner_dwarf.binds   it.is_being_rebound = false;
                            for *metagame.controls.select_as_place_warrior_dwarf.binds it.is_being_rebound = false;
                            for *metagame.controls.toggle_dynamite_mode.binds          it.is_being_rebound = false;
                            for *metagame.controls.select_as_place_goblin.binds        it.is_being_rebound = false;
                            for *metagame.controls.toggle_obsidian_mode.binds          it.is_being_rebound = false;
                            for *metagame.controls.toggle_wall_mode.binds              it.is_being_rebound = false;
                            for *metagame.controls.drag_as_create_path.binds           it.is_being_rebound = false;
                            for *metagame.controls.drag_cam.binds                      it.is_being_rebound = false;
                            for *metagame.controls.move_camera_up.binds                it.is_being_rebound = false;
                            for *metagame.controls.move_camera_down.binds              it.is_being_rebound = false;
                            for *metagame.controls.move_camera_left.binds              it.is_being_rebound = false;
                            for *metagame.controls.move_camera_right.binds             it.is_being_rebound = false;
                            for *metagame.controls.toggle_remove_mode.binds            it.is_being_rebound = false;
                            for *metagame.controls.panic_pause.binds                   it.is_being_rebound = false;
                            for *metagame.controls.fast_forward.binds                  it.is_being_rebound = false;

                            metagame.pause_state = .MENU;
                    }
                case .GAME_OVER;
                    if #complete metagame.game_over_state == {
                        case .MENU; // Pressing escape does nothing in the game over menu
                        case .LOOK_AROUND; metagame.game_over_state = .MENU;
                    }
            }
        }

        if IsKeyPressed(.KEY_G) metagame.debug_mode = !metagame.debug_mode;

        // Update previous controls state
        game_state.controls_state_prev_frame = game_state.controls_state_this_frame;

        // Update controls this frame
        {
            game_state.controls_state_this_frame.select_is_pressed_once        = control_is_pressed(metagame.controls.select);
            game_state.controls_state_this_frame.select_is_held_down           = control_is_down(metagame.controls.select);
            game_state.controls_state_this_frame.selection_cleared             = control_is_pressed(metagame.controls.clear_selection);
            game_state.controls_state_this_frame.toggle_base_mode              = control_is_pressed(metagame.controls.toggle_base_mode);
            game_state.controls_state_this_frame.toggle_dynamite_mode          = control_is_pressed(metagame.controls.toggle_dynamite_mode);
            game_state.controls_state_this_frame.toggle_obsidian_mode          = control_is_pressed(metagame.controls.toggle_obsidian_mode);
            game_state.controls_state_this_frame.toggle_wall_mode              = control_is_pressed(metagame.controls.toggle_wall_mode);
            game_state.controls_state_this_frame.toggle_remove_mode            = control_is_pressed(metagame.controls.toggle_remove_mode);
            game_state.controls_state_this_frame.add_iron                      = control_is_pressed(metagame.controls.add_iron);
            game_state.controls_state_this_frame.select_as_place_miner_dwarf   = control_is_down(metagame.controls.select_as_place_miner_dwarf);
            game_state.controls_state_this_frame.select_as_place_warrior_dwarf = control_is_down(metagame.controls.select_as_place_warrior_dwarf);
            game_state.controls_state_this_frame.select_as_place_goblin        = control_is_down(metagame.controls.select_as_place_goblin);
            game_state.controls_state_this_frame.drag_cam_pressed              = control_is_pressed(metagame.controls.drag_cam);
            game_state.controls_state_this_frame.drag_cam_down                 = control_is_down(metagame.controls.drag_cam);
            game_state.controls_state_this_frame.move_camera_up                = control_is_down(metagame.controls.move_camera_up);
            game_state.controls_state_this_frame.move_camera_down              = control_is_down(metagame.controls.move_camera_down);
            game_state.controls_state_this_frame.move_camera_left              = control_is_down(metagame.controls.move_camera_left);
            game_state.controls_state_this_frame.move_camera_right             = control_is_down(metagame.controls.move_camera_right);
            game_state.controls_state_this_frame.panic_pause                   = control_is_pressed(metagame.controls.panic_pause);
            game_state.controls_state_this_frame.fast_forward                  = control_is_down(metagame.controls.fast_forward);

            game_state.controls_state_this_frame.started_to_draw_path = (
                game_state.controls_state_this_frame.select_is_pressed_once         &&
                !game_state.controls_state_this_frame.select_as_place_miner_dwarf   &&
                !game_state.controls_state_this_frame.select_as_place_warrior_dwarf &&
                !game_state.controls_state_this_frame.select_as_place_goblin        &&
                game_state.control_mode == .NORMAL                                  &&
                !IsKeyDown(KeyboardKey.KEY_LEFT_CONTROL) // debug control to mine blocks
            );

            game_state.controls_state_this_frame.drawing_path = (
                game_state.controls_state_this_frame.select_is_held_down &&
                (game_state.controls_state_prev_frame.drawing_path || game_state.controls_state_prev_frame.started_to_draw_path)
            );
        }

        // TODO: should this go here?
        //
        // Update control mode
        {
            if game_state.controls_state_this_frame.selection_cleared {
                game_state.control_mode = .NORMAL;
            }

            if game_state.controls_state_this_frame.toggle_base_mode {
                game_state.control_mode = ifx game_state.control_mode == .ADD_BASE then .NORMAL else .ADD_BASE;
            }

            if game_state.controls_state_this_frame.toggle_dynamite_mode {
                game_state.control_mode = ifx game_state.control_mode == .ADD_DYNAMITE then .NORMAL else .ADD_DYNAMITE;
            }
            
            if game_state.controls_state_this_frame.toggle_obsidian_mode {
                game_state.control_mode = ifx game_state.control_mode == .ADD_OBSIDIAN then .NORMAL else .ADD_OBSIDIAN;
            }
        
            if game_state.controls_state_this_frame.toggle_wall_mode {
                game_state.control_mode = ifx game_state.control_mode == .ADD_WALL then .NORMAL else .ADD_WALL;
            }

            if game_state.controls_state_this_frame.toggle_remove_mode {
                game_state.control_mode = ifx game_state.control_mode == .REMOVE then .NORMAL else .REMOVE;
            }
        }
    }

    //
    // Update
    //
    {
        // Update unpausable things
        {
            // Debug break tiles
            hovered_tile_rect := get_tile_rect_that_pos_is_within(get_world_width(), get_world_height(), TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, mouse_pos_in_world);
            if IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT) && IsKeyDown(KeyboardKey.KEY_LEFT_CONTROL) {
                tile_id := get_tile_id_by_pos(Vector2.{ hovered_tile_rect.x, hovered_tile_rect.y });
                set_tile_as_type(tile_id, .MINED, false, false, game_state);
                reveal_cave_if_necessary(tile_id, false, false, game_state);
            }

            // Update camera
            {
                CAMERA_ZOOM_MULTIPLIER :: 1.2;
                CAMERA_ZOOM_MIN_DEBUG  :: 0.01;
                CAMERA_ZOOM_MAX        :: 13.0;

                camera_zoom_min := ifx metagame.debug_mode then CAMERA_ZOOM_MIN_DEBUG else context.camera_zoom_min;

                can_move_camera := metagame.debug_mode || metagame.state == .RUNNING || (metagame.state == .GAME_OVER && metagame.game_over_state == .LOOK_AROUND);

                if can_move_camera && game_state.controls_state_this_frame.move_camera_up    camera.target.y -= CAMERA_MOVE_SPEED_BASE;
                if can_move_camera && game_state.controls_state_this_frame.move_camera_down  camera.target.y += CAMERA_MOVE_SPEED_BASE;
                if can_move_camera && game_state.controls_state_this_frame.move_camera_left  camera.target.x -= CAMERA_MOVE_SPEED_BASE;
                if can_move_camera && game_state.controls_state_this_frame.move_camera_right camera.target.x += CAMERA_MOVE_SPEED_BASE;

                camera.offset = Vector2.{ GetScreenWidth() / 2.0, GetScreenHeight() / 2.0 };

                camera_move_speed := CAMERA_MOVE_SPEED_BASE / 2 * camera.zoom;
                if game_state.controls_state_this_frame.drag_cam_pressed {
                    mouse_drag_began_at_pos = mouse_pos_in_world;
                }

                if game_state.controls_state_this_frame.drag_cam_down && can_move_camera {
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
                    camera.zoom  = clamp(camera.zoom, camera_zoom_min, CAMERA_ZOOM_MAX);

                    // Grab the world space position of the mouse AFTER the zoom
                    // (Raylib uses the new camera.zoom but the old camera.target here)
                    mouse_world_pos_after := GetScreenToWorld2D(GetMousePosition(), camera);

                    // Calculate the shift caused by the zoom, and move the target to cancel it out
                    zoom_delta := Vector2Subtract(mouse_world_pos_before, mouse_world_pos_after);
                    camera.target = Vector2Add(camera.target, zoom_delta);
                }
            }

            // Update timers
            {
                if game_state.panic_pause_timer_ms > 0 {
                    game_state.panic_pause_timer_ms -= xx (dt_seconds * 1000);
                }

                if game_state.home_base_under_attack_cooldown_ms > 0 {
                    game_state.home_base_under_attack_cooldown_ms -= xx (dt_seconds * 1000);
                }
            }
        }

        // Update time remaining for game
        if metagame.state == .RUNNING {
            game_state.time_remaining_ms -= xx (dt_seconds_raw * 1000);

            if game_state.time_remaining_ms <= 0 {
                game_state.time_remaining_ms = 0;
                metagame.state = .GAME_OVER;
            }
        }

        // Update pausable things
        if metagame.state == .RUNNING {
            // Update user action
            {
                if game_state.controls_state_this_frame.panic_pause {
                    if !panic_pause_is_cooling_down {
                        game_state.panic_pause_timer_ms = PANIC_PAUSE_COOLDOWN_MS;
                    }
                }

                if #complete game_state.control_mode == {
                    case .NORMAL;
                        if game_state.controls_state_this_frame.select_as_place_miner_dwarf {
                            if game_state.controls_state_this_frame.select_is_pressed_once {
                                if metagame.debug_mode {
                                    tile_id := get_tile_id_by_pos(mouse_pos_in_world);
                                    create_dwarf(get_tile_pos_by_id(tile_id), .MINER);
                                }
                            }
                        }
                        else if game_state.controls_state_this_frame.select_as_place_warrior_dwarf {
                            if game_state.controls_state_this_frame.select_is_pressed_once {
                                if metagame.debug_mode {
                                    tile_id := get_tile_id_by_pos(mouse_pos_in_world);
                                    create_dwarf(get_tile_pos_by_id(tile_id), .WARRIOR);
                                }
                            }
                        }
                        else if game_state.controls_state_this_frame.select_as_place_goblin {
                            if game_state.controls_state_this_frame.select_is_pressed_once {
                                tile_id := get_tile_id_by_pos(mouse_pos_in_world);
                                create_goblin(get_tile_pos_by_id(tile_id));
                            }
                        }
                        else {
                            // When a dwarf is currently selected from last frame
                            if game_state.selected_dwarf_id > 0 {
                                // If select is let go this frame, deselect the dwarf.
                                if game_state.controls_state_prev_frame.select_is_held_down && !game_state.controls_state_this_frame.select_is_held_down {
                                    found, selected_dwarf_index := table_find(*dwarf_id_to_index, game_state.selected_dwarf_id);
                                    assert(found);

                                    kill_particle_by_id(game_state.selected_dwarf_particle_id);

                                    dwarves[selected_dwarf_index].state = .DECIDING;
                                    dwarves[selected_dwarf_index].ignore_goblins_for = 2;

                                    game_state.selected_dwarf_id = 0;
                                }
                            } else {
                                if game_state.controls_state_this_frame.select_is_pressed_once {
                                    // PERF: would massively benefit from chunking
                                    for dwarf: dwarves {
                                        if CheckCollisionPointRec(mouse_pos_in_world, get_world_rect_from_pos(dwarf.pos)) {
                                            game_state.selected_dwarf_id = dwarf.id;
                                            break;
                                        }
                                    }
                                }

                                // If we found a dwarf this frame, pin down selected dwarf.
                                if game_state.selected_dwarf_id > 0 && game_state.controls_state_this_frame.select_is_held_down {
                                    found, selected_dwarf_index := table_find(*dwarf_id_to_index, game_state.selected_dwarf_id);
                                    assert(found);

                                    particle := create_dwarf_selected_particle(dwarves[selected_dwarf_index].pos, dwarves[selected_dwarf_index].id);
                                    game_state.selected_dwarf_particle_id = particle.id;

                                    // Teleport dwarf to tile we are hovering over and keep it there
                                    tile_rect := get_tile_rect_that_pos_is_within(get_world_width(), get_world_height(), TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, mouse_pos_in_world);
                                    dwarves[selected_dwarf_index].pos = get_rect_pos(tile_rect);
                                    
                                    // Stop the dwarf from moving so you can think while dragging a path
                                    dwarves[selected_dwarf_index].state = .IDLE;

                                    // Remove its current pathing
                                    array_reset(*(dwarves[selected_dwarf_index].tile_ids_on_path));
                                }
                            }

                            if game_state.controls_state_this_frame.started_to_draw_path {
                                mouse_pos_when_path_creation_started = mouse_pos_in_world;
                            }

                            if game_state.controls_state_this_frame.drawing_path {
                                // Draw out the path that is currently being traced, if it is more than 1 tile long.
                                potential_path_being_traced_1, potential_path_being_traced_2 := get_paths(mouse_pos_when_path_creation_started, mouse_pos_in_world);

                                if !metagame.debug_mode {
                                    potential_path_cost := get_path_cost(potential_path_being_traced_1) + get_path_cost(potential_path_being_traced_2);

                                    unaffordable_tile_count := cast(int) ceil((cast(float) (potential_path_cost - game_state.gold)) / cast(float)GOLD_COST_PATH_STEP);

                                    for 0..unaffordable_tile_count {
                                        if potential_path_being_traced_2.tile_count > 0 {
                                            potential_path_being_traced_2.tile_count -= 1;
                                        } else if potential_path_being_traced_1.tile_count > 0 {
                                            potential_path_being_traced_1.tile_count -= 1;
                                        } else {
                                            break;
                                        }
                                    }
                                }

                                if potential_path_being_traced_1.tile_count > 0 {
                                    path_being_traced_1 = potential_path_being_traced_1;
                                } else {
                                    path_being_traced_1 = Path.{};
                                }
                                if potential_path_being_traced_2.tile_count > 0 {
                                    path_being_traced_2 = potential_path_being_traced_2;
                                } else {
                                    path_being_traced_2 = Path.{};
                                }
                            }
                            // If we were drawing a path, but just let go, then create the path as a real thing.
                            else if game_state.controls_state_prev_frame.drawing_path {
                                // Destroy any arrows these paths might be overlapping
                                {
                                    if path_being_traced_1.start_tile_id > 0 {
                                        path_1_tile_ids := get_tile_ids_on_path(path_being_traced_1);
                                        for path_1_tile_id: path_1_tile_ids {
                                            // The last tile id of a path does not destroy path arrows
                                            if it_index == path_1_tile_ids.count continue;

                                            for path: paths {
                                                if path_1_tile_id == path.start_tile_id {
                                                    array_unordered_remove_by_index(*paths, xx it_index);
                                                }
                                            }
                                        }
                                    }

                                    if path_being_traced_2.start_tile_id > 0 {
                                        path_2_tile_ids := get_tile_ids_on_path(path_being_traced_2);
                                        for path_2_tile_id: path_2_tile_ids {
                                            // The last tile id of a path does not destroy path arrows
                                            if it_index == path_2_tile_ids.count continue;

                                            for path: paths {
                                                if path_2_tile_id == path.start_tile_id {
                                                    array_unordered_remove_by_index(*paths, xx it_index);
                                                }
                                            }
                                        }
                                    }
                                }

                                if path_being_traced_1.start_tile_id > 0 array_add(*paths, path_being_traced_1);
                                if path_being_traced_2.start_tile_id > 0 array_add(*paths, path_being_traced_2);

                                // Debit the gold cost.
                                {
                                    gold_cost := get_path_cost(path_being_traced_1) + get_path_cost(path_being_traced_2);

                                    if !metagame.debug_mode game_state.gold -= gold_cost;
                                    if gold_cost > 0 create_gold_particle(mouse_pos_in_world, -1 * gold_cost);
                                }
                            }
                        }
                    case .ADD_BASE;
                        // TODO: check if placement is valid
                        if game_state.controls_state_this_frame.select_is_pressed_once {
                            if metagame.debug_mode || game_state.gold >= GOLD_COST_BASE {
                                tile_id         := get_tile_id_by_pos(mouse_pos_in_world);
                                tile_is_mined   := table_contains(*fully_mined_tile_ids_set, tile_id);
                                tile_is_encased := table_contains(*encased_tile_ids_set, tile_id);

                                if metagame.debug_mode || (tile_is_mined && !tile_is_encased) {
                                    // Add base.
                                    base_rect := get_tile_rect_that_pos_is_within(get_world_width(), get_world_height(), TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, mouse_pos_in_world);
                                    base_pos  := Vector2.{ base_rect.x, base_rect.y };
                                    base_tile_id := get_tile_id_by_pos(base_pos);

                                    create_base(base_pos, false, game_state);

                                    // Debit the gold cost.
                                    if !metagame.debug_mode game_state.gold -= GOLD_COST_BASE;
                                    create_gold_particle(base_pos, -1 * GOLD_COST_BASE);

                                    // Reset control mode.
                                    game_state.control_mode = .NORMAL;
                                }
                            }
                        }
                    case .ADD_DYNAMITE;
                        if game_state.controls_state_this_frame.select_is_pressed_once {
                            if metagame.debug_mode || game_state.gold >= GOLD_COST_DYNAMITE {
                                // Try to add dynamite to the selected tile
                                tile_id         := get_tile_id_by_pos(mouse_pos_in_world);
                                tile_is_mined   := table_contains(*fully_mined_tile_ids_set, tile_id);
                                tile_is_encased := table_contains(*encased_tile_ids_set, tile_id);

                                if tile_is_mined && !tile_is_encased {
                                    // Place down the dynamite.
                                    array_add(*tiles_with_dynamite_ids, tile_id);

                                    // Debit the gold cost.
                                    if !metagame.debug_mode game_state.gold -= GOLD_COST_DYNAMITE;
                                    create_gold_particle(mouse_pos_in_world, -1 * GOLD_COST_DYNAMITE);

                                    // Reset control mode.
                                    game_state.control_mode = .NORMAL;
                                }
                            }
                        }
                    case .ADD_OBSIDIAN;
                        if game_state.controls_state_this_frame.select_is_held_down {
                            if metagame.debug_mode || game_state.gold >= GOLD_COST_OBSIDIAN {
                                // Try to turn the selected tile into obsidian
                                tile_id := get_tile_id_by_pos(mouse_pos_in_world);

                                tile_is_iron            := table_contains(*iron_tile_ids_set, tile_id);
                                tile_is_being_mined     := table_contains(*actively_mined_tile_ids_to_health_table, tile_id);
                                tile_is_mined           := table_contains(*fully_mined_tile_ids_set, tile_id);
                                tile_is_mineable        := tile_is_iron || tile_is_being_mined || !tile_is_mined;

                                tile_is_unrevealed_cave := table_contains(*cave_tile_ids_set, tile_id);
                                tile_is_water_still     := table_contains(*water_still_tile_ids_to_sprite, tile_id);
                                tile_is_water_flowing   := table_contains(*water_flowing_tile_ids_to_sprite, tile_id);
                                tile_is_lava_still      := table_contains(*lava_still_tile_ids_set, tile_id);
                                tile_is_lava_flowing    := table_contains(*lava_flowing_tile_ids_to_sprite, tile_id);
                                tile_is_empty           := tile_is_unrevealed_cave || tile_is_water_still || tile_is_water_flowing || tile_is_lava_still || tile_is_lava_flowing;

                                tile_is_obsidian        := table_contains(*obsidian_tile_ids_set, tile_id);
                                tile_is_wall            := table_contains(*wall_tile_ids_set, tile_id);
                                tile_is_placed_object   := tile_is_obsidian || tile_is_wall;

                                tile_is_encased         := table_contains(*encased_tile_ids_set, tile_id);

                                if tile_is_mineable && !tile_is_empty && !tile_is_placed_object && !tile_is_encased {
                                    // Place down the obsidian.
                                    set_tile_as_type(tile_id, .OBSIDIAN, false, false, game_state);

                                    remove_warning_marker_on_tile_id :: (tile_id: s32) {
                                        table_remove(*water_warning_tile_ids_set, tile_id);
                                        table_remove(*lava_warning_tile_ids_set, tile_id);
                                        array_unordered_remove_by_value(*water_warning_tile_ids, tile_id);
                                        array_unordered_remove_by_value(*lava_warning_tile_ids, tile_id);
                                    }

                                    remove_alert_marker_on_tile_id :: (tile_id: s32) {
                                        table_remove(*water_alert_tile_ids_set, tile_id);
                                        table_remove(*lava_alert_tile_ids_set, tile_id);
                                        array_unordered_remove_by_value(*water_alert_tile_ids, tile_id);
                                        array_unordered_remove_by_value(*lava_alert_tile_ids, tile_id);
                                    }

                                    remove_warning_and_alert_markers_that_are_no_longer_valid :: (tile_id: s32) {
                                        // The tile that the obsidian / hole was placed on definitely doesn't need to count
                                        // as a warning or alert anymore;
                                        remove_warning_marker_on_tile_id(tile_id);
                                        remove_alert_marker_on_tile_id(tile_id);

                                        // Update warnings in the surrounding area
                                        for direction_level_1: DIRECTIONS_CARDINAL {
                                            neighbor_tile_id_level_1 := get_neighbor_tile_id_by_direction(tile_id, direction_level_1);

                                            found_alert_cardinal_neighbor := false;

                                            for direction_level_2: DIRECTIONS_CARDINAL {
                                                neighbor_tile_id_level_2 := get_neighbor_tile_id_by_direction(neighbor_tile_id_level_1, direction_level_2);

                                                is_alert_lava  := table_contains(*lava_alert_tile_ids_set, neighbor_tile_id_level_2);
                                                is_alert_water := table_contains(*water_alert_tile_ids_set, neighbor_tile_id_level_2);
                                                
                                                if is_alert_lava || is_alert_water {
                                                    found_alert_cardinal_neighbor = true;
                                                    break;
                                                }
                                            }

                                            if !found_alert_cardinal_neighbor then remove_warning_marker_on_tile_id(neighbor_tile_id_level_1);
                                        }
                                    }

                                    remove_warning_and_alert_markers_that_are_no_longer_valid(tile_id);

                                    // Encase any lava or water if we've made a full loop.
                                    handle_encasement(tile_id, game_state);

                                    // Debit the gold cost.
                                    if !metagame.debug_mode game_state.gold -= GOLD_COST_OBSIDIAN;
                                    create_gold_particle(mouse_pos_in_world, -1 * GOLD_COST_OBSIDIAN);
                                }
                            }
                        }
                    case .ADD_WALL;
                        if game_state.controls_state_this_frame.select_is_held_down {
                            if metagame.debug_mode || game_state.gold >= GOLD_COST_WALL {
                                // Try to turn the selected tile into a wall
                                tile_id := get_tile_id_by_pos(mouse_pos_in_world);
                                tile_is_fully_mined   := table_contains(*fully_mined_tile_ids_set, tile_id);
                                tile_has_base_on_it   := table_contains(*tile_ids_to_bases, tile_id);
                                tile_has_dwarf_on_it  := table_contains(*tile_ids_to_dwarfs, tile_id);
                                tile_has_goblin_on_it := table_contains(*tile_ids_to_goblins, tile_id);

                                can_place_wall_on_desired_tile := (
                                    tile_is_fully_mined   &&
                                    !tile_has_base_on_it  &&
                                    !tile_has_dwarf_on_it &&
                                    !tile_has_goblin_on_it
                                );

                                if tile_is_fully_mined && can_place_wall_on_desired_tile { 
                                    // Place down the wall.
                                    set_tile_as_type(tile_id, .WALL, false, false, game_state);

                                    // Debit the gold cost.
                                    if !metagame.debug_mode game_state.gold -= GOLD_COST_WALL;
                                    create_gold_particle(mouse_pos_in_world, -1 * GOLD_COST_WALL);
                                }
                            }
                        }
                    case .REMOVE;
                        if game_state.controls_state_this_frame.select_is_held_down {
                            tile_id := get_tile_id_by_pos(mouse_pos_in_world);

                            for path: paths_in_viewport {
                                if tile_id == path.start_tile_id {
                                    array_unordered_remove_by_index(*paths, it_index);
                                }
                            }
                        }
                }
            }

            if !panic_pause_is_active {
                // Update dwarves
                {
                    dwarf_ids_to_kill_this_frame : [..] s32;

                    for *dwarf, dwarf_index: dwarves {
                        print_vars(dwarf.did_anim_action);
                        is_dwarf_done_updating := false;

                        dwarf_center   := get_rect_center(get_world_rect_from_pos(dwarf.pos));
                        dwarf_tile_id  := get_tile_id_by_pos(dwarf_center);
                        dwarf_tile_pos := get_tile_pos_by_id(dwarf_tile_id);

                        if #complete dwarf.state == {
                            // You've just landed on a tile, now figure out what to do next
                            case .DECIDING;
                                is_dwarf_done_deciding := false;

                                // By default, we're going to expect that this dwarf decises what to do this frame
                                // (i.e. moves out of the deciding state). However, there are some cases where a dwarf
                                // can remain in the deciding state - like if he is somehow completely unable to move.
                                dwarf_can_remain_undecided := false;

                                // Regardless of the type of dwarf, if there's a goblin right on your ass, defend yourself unless you're
                                // under strict orders to stand down.
                                if dwarf.ignore_goblins_for == 0 {
                                    detected, goblin, direction_of_goblin := detect_neighbor_cardinal(dwarf_tile_id, Goblin);
                                    if detected {
                                        create_dwarf_aggro_particle(dwarf.pos, dwarf.id);

                                        dwarf.goblin_id_attacking = goblin.id;
                                        dwarf.direction = direction_of_goblin;
                                        dwarf_transition_state(dwarf, .ATTACKING);

                                        is_dwarf_done_deciding = true;
                                    }
                                } else {
                                    dwarf.ignore_goblins_for -= 1;
                                }

                                // TODO: faster walk and mine speed when on a path, I think
                                //
                                // Check if the dwarf is on a path arrow. If he is, then his new mission is to follow it.
                                if !is_dwarf_done_deciding {
                                    for path: paths {
                                        if dwarf_tile_id == path.start_tile_id {
                                            tile_ids_on_path := get_tile_ids_on_path(path);

                                            // Don't include the start tile, because then we softlock.
                                            tile_ids_on_path.data  += 1;
                                            tile_ids_on_path.count -= 1;

                                            // TODO: extract this
                                            array_reset(*(dwarf.tile_ids_on_path));
                                            array_copy(*(dwarf.tile_ids_on_path), tile_ids_on_path);
                                            set_entity_direction_to_face_next_target(dwarf);

                                            dwarf.is_moving_quickly = true;

                                            is_dwarf_done_deciding = true;
                                            break;
                                        }
                                    }
                                }

                                if !is_dwarf_done_deciding {
                                    // PERF: is this too expensive to do every frame?
                                    //
                                    // If the dwarf is a warrior, actively seek out goblins
                                    if dwarf.dwarf_type == .WARRIOR {
                                        dwarf_warrior_wander :: (dwarf: *Dwarf) {
                                            dwarf_center  := get_rect_center(get_world_rect_from_pos(dwarf.pos));
                                            dwarf_tile_id := get_tile_id_by_pos(dwarf_center);

                                            on_top_of_base, base := table_find(*tile_ids_to_bases, dwarf_tile_id);
                                            // If we're standing on a base right now, just keep walking in the direction you're currently going.
                                            if on_top_of_base {
                                                try_to_set_dwarf_target_to_one_block_in_the_direction_its_facing(dwarf);
                                            } else {
                                                base_neighbor_detected, base, base_direction := detect_neighbor_cardinal(dwarf_tile_id, Base);

                                                // If we have a base within a cardinal direction, just keep walking in the direction you're currently going.
                                                if base_neighbor_detected {
                                                    try_to_set_dwarf_target_to_one_block_in_the_direction_its_facing(dwarf);
                                                } else {
                                                    base_neighbor_detected, base, base_direction := detect_neighbor(dwarf_tile_id, Base);

                                                    // If we have a base within a diagonal direction, turn clockwise and then walk forward.
                                                    if base_neighbor_detected {
                                                        dwarf.direction = get_next_direction_to_face_from_base_neighbor_direction(base_direction);
                                                        result := try_to_set_dwarf_target_to_one_block_in_the_direction_its_facing(dwarf);
                                                        if result == .NO_DIRECTION_FOUND {
                                                            dwarf.direction = opposite_cardinal_direction(dwarf.direction);
                                                            try_to_set_dwarf_target_to_one_block_in_the_direction_its_facing(dwarf);
                                                        }
                                                    } else {
                                                        // TODO: wander somewhat towards the nearest base
                                                    }
                                                }
                                            }
                                        }

                                        dealing_with_goblin := deal_with_nearby_goblins(dwarf);

                                        if dealing_with_goblin == .NEARBY_GOBLIN_NOT_FOUND dwarf_warrior_wander(dwarf);
                                    }

                                    // If the dwarf has no targets, give him a new one
                                    if dwarf.tile_ids_on_path.count == 0 {
                                        dwarf.is_moving_quickly = false;

                                        result := try_to_set_dwarf_random_new_target(dwarf);

                                        // If there are no directions for this dwarf to go this frame,
                                        // just do nothing and then check again the next frame.
                                        if result == .NO_DIRECTION_FOUND {
                                            dwarf_can_remain_undecided = true;
                                            is_dwarf_done_deciding     = true;
                                        }
                                    }
                                }

                                if dwarf.tile_ids_on_path.count > 0 {
                                    tile_id_next_in_dwarfs_path := dwarf.tile_ids_on_path[0];

                                    // If it's walkable, proceed
                                    if is_tile_id_walkable_for_entity(tile_id_next_in_dwarfs_path, dwarf.id) {
                                        dwarf_transition_state(dwarf, .MOVING);
                                    }
                                    // If it's unmined, then they'll have to mine it
                                    else {
                                        if is_tile_id_mineable(tile_id_next_in_dwarfs_path) {
                                            dwarf_transition_state(dwarf, .MINING);
                                            dwarf.tile_id_mining = tile_id_next_in_dwarfs_path;

                                            // Set up the world state to accomodate the fact that the dwarf is about to mine this tile.
                                            // Plus, do some sanity checks to make sure that everything looks good.
                                            {
                                                // Add the tile the dwarf is about to mine to the chunk's list of actively mined tiles.
                                                _result, chunk := find_or_create_chunk_by_tile_id(tile_id_next_in_dwarfs_path);
                                                array_add(*chunk.actively_mined_tile_ids, tile_id_next_in_dwarfs_path);

                                                // Add the tile the dwarf is about to mine to the global table of actively mined tiles and,
                                                // in doing so, set its health.
                                                new_health: s32;
                                                if      is_tile_id_dirt(tile_id_next_in_dwarfs_path) new_health = xx DIRT_HEALTH;
                                                else if is_tile_id_iron(tile_id_next_in_dwarfs_path) new_health = xx IRON_HEALTH;
                                                else if is_tile_id_wall(tile_id_next_in_dwarfs_path) new_health = xx WALL_HEALTH;
                                                else if (
                                                    table_contains(*water_still_tile_ids_to_sprite, dwarf.tile_id_mining) ||
                                                    table_contains(*water_flowing_tile_ids_to_sprite, dwarf.tile_id_mining) ||
                                                    table_contains(*lava_still_tile_ids_set, dwarf.tile_id_mining) ||
                                                    table_contains(*lava_flowing_tile_ids_to_sprite, dwarf.tile_id_mining)
                                                ) {
                                                    // If you try to mine liquid, you're fucking banned
                                                    array_add(*dwarf_ids_to_kill_this_frame, dwarf.id);
                                                    is_dwarf_done_deciding = true;
                                                }
                                                else {
                                                    is_fully_mined    := table_contains(*fully_mined_tile_ids_set, tile_id_next_in_dwarfs_path);
                                                    is_actively_mined := table_contains(*fully_mined_tile_ids_set, tile_id_next_in_dwarfs_path);
                                                    is_cave           := table_contains(*cave_tile_ids_set, tile_id_next_in_dwarfs_path);
                                                    is_encased        := table_contains(*encased_tile_ids_set, tile_id_next_in_dwarfs_path);
                                                    is_iron           := table_contains(*iron_tile_ids_set, tile_id_next_in_dwarfs_path);
                                                    is_water_still    := table_contains(*water_still_tile_ids_to_sprite, tile_id_next_in_dwarfs_path);
                                                    is_water_flowing  := table_contains(*water_flowing_tile_ids_to_sprite, tile_id_next_in_dwarfs_path);
                                                    is_lava_still     := table_contains(*lava_still_tile_ids_set, tile_id_next_in_dwarfs_path);
                                                    is_lava_flowing   := table_contains(*lava_flowing_tile_ids_to_sprite, tile_id_next_in_dwarfs_path);
                                                    is_obsidian       := table_contains(*obsidian_tile_ids_set, tile_id_next_in_dwarfs_path);
                                                    is_wall           := table_contains(*wall_tile_ids_set, tile_id_next_in_dwarfs_path);
                                                    is_hole           := table_contains(*hole_tile_ids_set, tile_id_next_in_dwarfs_path);
                                                    print_vars(
                                                        is_fully_mined,
                                                        is_cave,
                                                        is_encased,
                                                        is_iron,
                                                        is_water_still,
                                                        is_water_flowing,
                                                        is_lava_still,
                                                        is_lava_flowing,
                                                        is_obsidian,
                                                        is_wall,
                                                        is_hole
                                                    );
                                                    assert_soft(false, "Dwarf % tryna mine some weird ass shit (tile id %)", dwarf.id, tile_id_next_in_dwarfs_path);
                                                }

                                                table_set(*actively_mined_tile_ids_to_health_table, tile_id_next_in_dwarfs_path, new_health);
                                            }
                                        }
                                        // If it's unmineable, first of all I'm pretty sure this shouldn't have been on their path,
                                        // but second of all, they're going to have to figure something else out then because this
                                        // is a dead end.
                                        else {
                                            try_to_set_dwarf_random_new_target(dwarf);
                                            dwarf_can_remain_undecided = true;
                                            dwarf.is_moving_quickly    = false;
                                        }
                                    }
                                }

                                assert_soft(dwarf.state != .DECIDING || dwarf_can_remain_undecided, "Dwarf % got to end of DECIDING state without making a decision", dwarf.id);

                            case .MOVING;
                                assert_soft(dwarf.tile_ids_on_path.count > 0, "Dwarf % wanted to move, but has nowhere to go", dwarf.id);

                                target_tile_id  := dwarf.tile_ids_on_path[0];
                                target_tile_pos := get_tile_pos_by_id(target_tile_id);

                                assert_soft(dwarf.pos.x == target_tile_pos.x || dwarf.pos.y == target_tile_pos.y, "Dwarf % is going at an angle", dwarf.id);

                                // TODO: #if DEBUG
                                if !is_tile_id_walkable_for_entity(target_tile_id, dwarf.id) {
                                    is_fully_mined    := table_contains(*fully_mined_tile_ids_set, target_tile_id);
                                    is_actively_mined := table_contains(*actively_mined_tile_ids_to_health_table, target_tile_id);
                                    is_cave           := table_contains(*cave_tile_ids_set, target_tile_id);
                                    is_encased        := table_contains(*encased_tile_ids_set, target_tile_id);
                                    is_iron           := table_contains(*iron_tile_ids_set, target_tile_id);
                                    is_water_still    := table_contains(*water_still_tile_ids_to_sprite, target_tile_id);
                                    is_water_flowing  := table_contains(*water_flowing_tile_ids_to_sprite, target_tile_id);
                                    is_lava_still     := table_contains(*lava_still_tile_ids_set, target_tile_id);
                                    is_lava_flowing   := table_contains(*lava_flowing_tile_ids_to_sprite, target_tile_id);
                                    is_obsidian       := table_contains(*obsidian_tile_ids_set, target_tile_id);
                                    is_wall           := table_contains(*wall_tile_ids_set, target_tile_id);
                                    is_hole           := table_contains(*hole_tile_ids_set, target_tile_id);
                                    is_dwarf          := table_contains(*tile_ids_to_dwarfs, target_tile_id);
                                    is_goblin         := table_contains(*tile_ids_to_goblins, target_tile_id);
                                    print_vars(
                                        is_fully_mined,
                                        is_actively_mined,
                                        is_cave,
                                        is_encased,
                                        is_iron,
                                        is_water_still,
                                        is_water_flowing,
                                        is_lava_still,
                                        is_lava_flowing,
                                        is_obsidian,
                                        is_wall,
                                        is_hole,
                                        is_dwarf,
                                        is_goblin
                                    );
                                    // assert_soft(false, "Dwarf % is trying to move into the invalid tile %\n", dwarf.id, target_tile_id);
                                }

                                // Turn the dwarf sprite to face whatever way it should be
                                if dwarf.is_facing_left  && target_tile_pos.x > dwarf_tile_pos.x then dwarf.is_facing_left = false;
                                if !dwarf.is_facing_left && target_tile_pos.x < dwarf_tile_pos.x then dwarf.is_facing_left = true;

                                // Calculate the squared distance (use squared distances so we can avoid a sqrtf).
                                dx := target_tile_pos.x - dwarf.pos.x;
                                dy := target_tile_pos.y - dwarf.pos.y;
                                distance_squared := (dx * dx) + (dy * dy);

                                // Calculate the squared step size
                                speed := ifx dwarf.is_moving_quickly then DWARF_MOVE_SPEED_FAST else DWARF_MOVE_SPEED;
                                step_size := speed * dt_seconds;
                                step_size_squared := step_size * step_size;

                                dwarf_pretty_much_reached_target := distance_squared <= step_size_squared;

                                if dwarf_pretty_much_reached_target {
                                    // Teleport dwarf to the target tile to remove any floating point weirdness.
                                    dwarf.pos = target_tile_pos;

                                    // Remove the target from the tile ids on path
                                    array_ordered_remove_by_index(*(dwarf.tile_ids_on_path), 0);

                                    // Figure out what to do next
                                    dwarf_transition_state(dwarf, .DECIDING);
                                } else {
                                    move_one_step_towards_its_next_target_cardinal(dwarf, speed, dt_seconds);

                                    // Remain in the .MOVING state, since we didn't reach the target yet
                                }

                            case .MINING;
                                assert(dwarf.tile_id_mining > 0, "Dwarf tryna mine but he got no gotdamn tile to mine!!!!!!!");

                                frame := sprite_animation_get_current_frame(dwarf.animations[DwarfAnimation.MINE]);

                                if frame == DWARF_MINER_ANIMATION_MINE_FRAME_ACTION && !dwarf.did_anim_action {
                                    dwarf.did_anim_action = true;

                                    // Decrease the tile health by the dwarf mining damage
                                    found_tile_dwarf_is_mining, current_health := table_find(*actively_mined_tile_ids_to_health_table, dwarf.tile_id_mining);
                                    
                                    if found_tile_dwarf_is_mining {
                                        dmg := dwarf_get_dig_damage(dwarf);
                                        new_health := current_health - dwarf_get_dig_damage(dwarf);

                                        if new_health <= 0 {
                                            just_mined_iron := table_contains(*iron_tile_ids_set, dwarf.tile_id_mining);
                                            
                                            set_tile_as_type(dwarf.tile_id_mining, .MINED, true, true, game_state);

                                            if just_mined_iron && dwarf.dwarf_type == .MINER {
                                                found_next_iron_in_deposit, next_iron_tile_id := detect_iron_tile_id_within_radius(dwarf_tile_id, 3);
                                                if found_next_iron_in_deposit {
                                                    tile_ids_to_next_iron_tile := get_tile_ids_from_pos_to_pos(get_tile_pos_by_id(dwarf_tile_id), get_tile_pos_by_id(next_iron_tile_id));
                                                    array_reset(*dwarf.tile_ids_on_path);
                                                    array_copy(*dwarf.tile_ids_on_path, tile_ids_to_next_iron_tile);
                                                }
                                            }

                                            // If we just cracked into a cave, we'll need to reveal the cave and do anything
                                            // that cave type needs (e.g. spawn water, lava, monsters, etc.).
                                            revealed_cave, cave_type := reveal_cave_if_necessary(dwarf.tile_id_mining, true, false, game_state);

                                            if revealed_cave && cave_type == .TREASURE {
                                                found, new_treasure_tile_id := detect_treasure_tile_id_within_radius(dwarf.tile_id_mining, 10);
                                                if found {
                                                    // Teleport dwarf to the center of the tile he's standing on before changing his pathing.
                                                    // Without doing this, the dwarf can end up being misaligned.
                                                    dwarf_center   := get_rect_center(get_world_rect_from_pos(dwarf.pos));
                                                    dwarf_tile_id  := get_tile_id_by_pos(dwarf_center);
                                                    dwarf_tile_pos := get_tile_pos_by_id(dwarf_tile_id);
                                                    dwarf.pos = dwarf_tile_pos;

                                                    tile_ids_to_new_treasure := get_tile_ids_from_pos_to_pos(get_tile_pos_by_id(dwarf.tile_id_mining), get_tile_pos_by_id(new_treasure_tile_id));
                                                    array_reset(*dwarf.tile_ids_on_path);
                                                    array_copy(*dwarf.tile_ids_on_path, tile_ids_to_new_treasure);
                                                }
                                            }

                                            dwarf_transition_state(dwarf, .DECIDING);
                                        } else {
                                            // If the tile just needs to take some damage, well, then damage it ya fuckin jallopy
                                            table_set(*actively_mined_tile_ids_to_health_table, dwarf.tile_id_mining, new_health);
                                        }

                                        // Reset cooldown
                                        // dwarf.mining_cooldown_ms = dwarf_get_mining_cooldown(dwarf);
                                    } else {
                                        if metagame.debug_mode print("INFO: Dwarf was mining tile % but suddenly it was removed from the table of actively mined tiles.\n", dwarf.tile_id_mining);
                                        // It's possible for the tile the dwarf is mining to suddenly be changed, like into obsidian.
                                        // In this case, the dwarf should abandon the idea of mining its current tile.
                                        array_reset(*(dwarf.tile_ids_on_path));

                                        dwarf_transition_state(dwarf, .DECIDING);
                                    }
                                }

                            case .ATTACKING;
                                // Make sure the goblin is still alive, it's possible that other dwarves have killed it this frame.
                                found, goblin_index := table_find(*goblin_id_to_index, dwarf.goblin_id_attacking);
                                if found {
                                    goblin         := *goblins[goblin_index];
                                    goblin_center  := get_rect_center(get_world_rect_from_pos(goblin.pos));
                                    goblin_tile_id := get_tile_id_by_pos(goblin_center);

                                    // Turn the dwarf to face whichever way it should be.
                                    if dwarf.is_facing_left  && goblin.pos.x > dwarf_tile_pos.x then dwarf.is_facing_left = false;
                                    if !dwarf.is_facing_left && goblin.pos.x < dwarf_tile_pos.x then dwarf.is_facing_left = true;

                                    if is_tile_id_neighbor_of_tile_id_cardinal(dwarf_tile_id, goblin_tile_id) {
                                        assert_soft(dwarf.goblin_id_attacking == goblin.id, "Dwarf % thinks he's attacking goblin % but really found goblin %", dwarf.id, dwarf.goblin_id_attacking, goblin.id);
                                        
                                        // TODO: different animation for attacking?
                                        frame := sprite_animation_get_current_frame(dwarf.animations[DwarfAnimation.MINE]);

                                        if frame == DWARF_MINER_ANIMATION_MINE_FRAME_ACTION && !dwarf.did_anim_action {
                                            dwarf.did_anim_action = true;

                                            // Hit check
                                            rng := random_get_within_range(0, 1);
                                            swing_connected := rng <= dwarf_get_hit_chance(dwarf);

                                            if swing_connected {
                                                damage := dwarf_get_attack_damage(dwarf);

                                                // TODO: probably extract this
                                                direction_stars_should_fly: Direction;
                                                found_direction := false;
                                                for DIRECTIONS_CARDINAL {
                                                    neighbor_tile_id := get_neighbor_tile_id_by_direction(dwarf_tile_id, it);
                                                    if neighbor_tile_id == goblin_tile_id {
                                                        direction_stars_should_fly = it;
                                                        found_direction = true;
                                                        break;
                                                    }
                                                }
                                                assert_soft(found_direction, "Was trying to figure out what direction the damage star should fly when dwarf % connected an attack on goblin %, but didn't detect the goblin as a cardinal neighbor of the dwarf\n", dwarf.id, goblin.id);

                                                create_damage_particles(goblin.pos, damage, direction_stars_should_fly);

                                                goblin.hp -= damage;

                                                if goblin.hp <= 0 {
                                                    kill_goblin_by_id(goblin.id);

                                                    dwarf_transition_state(dwarf, .DECIDING);
                                                }
                                            } else {
                                                create_miss_particles(goblin.pos);
                                            }
                                        }
                                    } else {
                                        dwarf_transition_state(dwarf, .DECIDING);
                                    }
                                } else {
                                    dwarf_transition_state(dwarf, .DECIDING);
                                }
                            case .IDLE;
                        }

                        // TODO: maintain active animation index so we don't need to search for it
                        //
                        // Update animations
                        for *anim: dwarf.animations {
                            reset_anim := sprite_update(anim, dt_seconds);
                            if reset_anim then dwarf.did_anim_action = false;
                        }
                    }

                    for dwarf_ids_to_kill_this_frame kill_dwarf_by_id(it);
                }

                // Update goblins
                {
                    for *goblin: goblins {
                        goblin_center   := get_rect_center(get_world_rect_from_pos(goblin.pos));
                        goblin_tile_id  := get_tile_id_by_pos(goblin_center);
                        goblin_tile_pos := get_tile_pos_by_id(goblin_tile_id);

                        if #complete goblin.state == {
                            case .DECIDING;
                                is_goblin_done_deciding     := false;
                                goblin_can_remain_undecided := false;

                                assert_soft(xx Vector2Equals(goblin.pos, goblin_tile_pos), "Goblin % was not precisely on its tile while deciding what to do next.", goblin.id);

                                // If there are any cardinal neighbor dwarves, turn and attack them.
                                if !is_goblin_done_deciding {
                                    detected, dwarf := find_cardinal_neighbor_entity(goblin_tile_id, Dwarf);

                                    if detected {
                                        // TODO: set goblin direction
                                        goblin.state = .ATTACKING;
                                        goblin.entity_id_attacking = dwarf.id;

                                        is_goblin_done_deciding = true;
                                    }
                                }

                                // If there are any cardinal neighbor bases, turn and fight them.
                                if !is_goblin_done_deciding {
                                    detected, base := find_cardinal_neighbor_entity(goblin_tile_id, Base);

                                    if detected {
                                        // TODO: set goblin direction
                                        goblin.state = .ATTACKING;
                                        goblin.entity_id_attacking = base.id;

                                        is_goblin_done_deciding = true;
                                    }
                                }

                                // If there are any dwarves within line of sight, move towards the tile they're spotted on.
                                if !is_goblin_done_deciding {
                                    detected, _, tile_ids_path := find_line_of_sight_entity(goblin_tile_id, Dwarf, GOBLIN_LINE_OF_SIGHT_TILE_COUNT);

                                    if detected {
                                        set_tile_ids_on_path(goblin, *tile_ids_path);
                                        is_goblin_done_deciding = true;
                                    }
                                }

                                // If there are any dwarves within 3 tiles, move towards them.
                                if !is_goblin_done_deciding {
                                    detected, dwarf, tile_ids_path := detect_entity_within_radius(Dwarf, goblin_tile_id, 3);

                                    if detected {
                                        if goblin_tile_id != get_tile_id_by_pos(dwarf.pos) {
                                            set_tile_ids_on_path(goblin, *tile_ids_path);
                                        }
                                        is_goblin_done_deciding = true;
                                    }
                                }

                                // If there are any bases within line of sight, move towards the tile they're spotted on.
                                if !is_goblin_done_deciding {
                                    detected, _, tile_ids_path := find_line_of_sight_entity(goblin_tile_id, Base, GOBLIN_LINE_OF_SIGHT_TILE_COUNT);
                                    
                                    if detected {
                                        set_tile_ids_on_path(goblin, *tile_ids_path);
                                        is_goblin_done_deciding = true;
                                    }
                                }

                                // If there are any bases within 10 tiles, move towards them.
                                if !is_goblin_done_deciding {
                                    detected, base, tile_ids_path := detect_entity_within_radius(Base, goblin_tile_id, 10);

                                    if detected {
                                        if goblin_tile_id != get_tile_id_by_pos(base.pos) {
                                            set_tile_ids_on_path(goblin, *tile_ids_path);
                                        }
                                        is_goblin_done_deciding = true;
                                    }
                                }

                                if goblin.state == .DECIDING {
                                    if can_entity_make_progress(goblin) {
                                        goblin.state = .MOVING;
                                    } else {
                                        result := try_to_set_goblin_random_new_target(goblin);
                                        if result == .DIRECTION_FOUND {
                                            goblin.state = .MOVING;
                                        } else {
                                            goblin_can_remain_undecided = true;
                                        }
                                    }
                                }

                                assert_soft(goblin.state != .DECIDING || goblin_can_remain_undecided, "Goblin % got to end of DECIDING state without making a decision\n", goblin.id);

                            case .MOVING;
                                assert_soft(goblin.tile_ids_on_path.count > 0, "Goblin % was moving somewhere but has no target\n", goblin.id);

                                target_tile_id  := goblin.tile_ids_on_path[0];
                                target_tile_pos := get_tile_pos_by_id(target_tile_id);

                                // assert_soft(goblin.pos.x == target_tile_pos.x || goblin.pos.y == target_tile_pos.y, "Goblin id % is going at an angle", goblin.id);

                                tile_id_next_in_goblin_path := goblin.tile_ids_on_path[0];

                                goblin_pretty_much_reached_target := values_are_close(goblin.pos, target_tile_pos, 1);
                                if goblin_pretty_much_reached_target {
                                    // Teleport goblin to the target tile to remove any floating point weirdness.
                                    goblin.pos = target_tile_pos;

                                    // Remove the target from the tile ids on path
                                    // PERF: These would be a lot faster if we just stored the paths backwards so we didn't
                                    // need to do an ordered remove here.
                                    array_ordered_remove_by_index(*goblin.tile_ids_on_path, 0);

                                    // Figure out what to do next
                                    goblin.state = .DECIDING;
                                } else {
                                    move_one_step_towards_its_next_target_cardinal(goblin, GOBLIN_MOVE_SPEED, dt_seconds);
                                }

                            case .ATTACKING;
                                assert_soft(goblin.entity_id_attacking > 0, "Goblin % is in attack state but has no target\n", goblin.id);

                                if goblin.attack_cooldown_ms > 0 {
                                    goblin.attack_cooldown_ms -= xx (dt_seconds * 1000);
                                } else {
                                    goblin.attack_cooldown_ms = GOBLIN_ATTACK_COOLDOWN_MS;

                                    // TODO: this blows, fix this!
                                    //
                                    // Make sure the entity is still alive, it's possible that other goblins have killed it this frame.
                                    found: bool;
                                    entity_index: s64;
                                    entity: *Entity;
                                    is_dwarf := false; // TODO: fix this!!!!!!!!!!!!!!!

                                    set_entity_id_to_index(Dwarf);
                                    found, entity_index = table_find(*entity_id_to_index, goblin.entity_id_attacking);
                                    if found {
                                        is_dwarf = true;
                                        entity = *dwarves[entity_index];
                                    } else {
                                        set_entity_id_to_index(Base);
                                        found, entity_index = table_find(*entity_id_to_index, goblin.entity_id_attacking);
                                        if found {
                                            entity = *bases[entity_index];

                                            // If this goblin is attacking the home base
                                            if entity_index == 0 && game_state.home_base_under_attack_cooldown_ms <= 0 {
                                                create_alert(.BASE_UNDER_ATTACK, entity.pos, game_state);
                                                game_state.home_base_under_attack_cooldown_ms = HOME_BASE_UNDER_ATTACK_COOLDOWN_MS;
                                            }
                                        }
                                    }

                                    if (found) {
                                        assert_soft(goblin.entity_id_attacking == entity.id, "Goblin % thinks he's attacking entity % but really found entity %", goblin.id, goblin.entity_id_attacking, entity.id);

                                        stop_trying_to_attack := false;
                                        // If attacking a dwarf, make sure it's still in reach
                                        if is_dwarf {
                                            detected, dwarf, direction := find_cardinal_neighbor_entity(goblin_tile_id, Dwarf);

                                            if !detected {
                                                goblin.state = .DECIDING;
                                                goblin.entity_id_attacking = 0;
                                                stop_trying_to_attack = true;
                                            }
                                        }

                                        if !stop_trying_to_attack {
                                            rng := random_get_within_range(0, 1);
                                            swing_connected := rng <= GOBLIN_HIT_CHANCE;

                                            if swing_connected {
                                                
                                                target_entity_center   := get_rect_center(get_world_rect_from_pos(entity.pos));
                                                target_entity_tile_id  := get_tile_id_by_pos(target_entity_center);

                                                direction_stars_should_fly: Direction;
                                                found_direction := false;
                                                for DIRECTIONS_CARDINAL {
                                                    neighbor_tile_id := get_neighbor_tile_id_by_direction(goblin_tile_id, it);
                                                    if neighbor_tile_id == target_entity_tile_id {
                                                        direction_stars_should_fly = it;
                                                        found_direction = true;
                                                        break;
                                                    }
                                                }
                                                assert_soft(found_direction, "Was trying to figure out what direction the damage star should fly when goblin % connected an attack on entity %, but didn't detect the entity as a cardinal neighbor of the dwarf\n", goblin.id, entity.id);

                                                create_damage_particles(entity.pos, GOBLIN_ATTACK_DAMAGE_PER_SWING, direction_stars_should_fly);

                                                entity.hp -= GOBLIN_ATTACK_DAMAGE_PER_SWING;

                                                if entity.hp <= 0 {
                                                    if is_dwarf kill_dwarf_by_id(entity.id);
                                                    else        kill_base_by_id(entity.id);

                                                    goblin.state = .DECIDING;
                                                    goblin.entity_id_attacking = 0;
                                                }
                                            } else {
                                                create_miss_particles(entity.pos);
                                            }
                                        }
                                    } else {
                                        goblin.state = .DECIDING;
                                        goblin.entity_id_attacking = 0;
                                    }

                                }
                            case .IDLE;
                        }
                    }
                }

                // Update dynamite
                {
                    tile_ids_to_remove_dynamite_from: [..] s32;
                    tile_ids_to_remove_dynamite_from.allocator = temp;

                    for tiles_with_dynamite_ids {
                        // Kill any dwarves you are coming in contact with
                        for dwarf, dwarf_index: dwarves {
                            dynamite_pos := get_tile_pos_by_id(it);
                            if Vector2Equals(dwarf.pos, dynamite_pos) {
                                kill_dwarf_by_index(dwarf_index);

                                // Mark the dynamite as to be destroyed
                                array_add(*tile_ids_to_remove_dynamite_from, it);

                                // Create a hole
                                set_tile_as_type(it, .HOLE, false, false, game_state);
                                handle_encasement(it, game_state);

                                // TODO: animation I guess

                                break;
                            }
                        }
                    }

                    for tile_ids_to_remove_dynamite_from {
                        array_unordered_remove_by_value(*tiles_with_dynamite_ids, it);
                    }
                }

                // Update treasure
                {
                    tile_ids_to_remove_treasure_from : [..] s32;
                    tile_ids_to_remove_treasure_from.allocator = temp;

                    // PERF: this double loop looks sus
                    for tiles_with_treasure_ids {
                        for *dwarf, dwarf_index: dwarves {
                            treasure_pos := get_tile_pos_by_id(it);
                            dwarf_is_pretty_much_touching_treasure := values_are_close(dwarf.pos, treasure_pos, 1);
                            if dwarf_is_pretty_much_touching_treasure {
                                // Credit the gold.
                                game_state.gold += GOLD_FROM_TREASURE;
                                create_gold_particle(treasure_pos, GOLD_FROM_TREASURE);

                                // Remove the treasure
                                array_unordered_remove_by_value(*tiles_with_treasure_ids, it);
                                table_remove(*tiles_with_treasure_ids_set, it);

                                // Look for more treasure
                                found, new_treasure_tile_id := detect_treasure_tile_id_within_radius(it, 10);
                                if found {
                                    tile_ids_to_new_treasure := get_tile_ids_from_pos_to_pos(get_tile_pos_by_id(it), get_tile_pos_by_id(new_treasure_tile_id));
                                    tile_ids_to_new_treasure.count -= 1;
                                    tile_ids_to_new_treasure.data  += 1;

                                    // Teleport dwarf to the center of the tile he's standing on before changing his pathing.
                                    // Without doing this, the dwarf can end up being misaligned.
                                    dwarf_center   := get_rect_center(get_world_rect_from_pos(dwarf.pos));
                                    dwarf_tile_id  := get_tile_id_by_pos(dwarf_center);
                                    dwarf_tile_pos := get_tile_pos_by_id(dwarf_tile_id);
                                    dwarf.pos = dwarf_tile_pos;

                                    array_reset(*dwarf.tile_ids_on_path);
                                    array_copy(*dwarf.tile_ids_on_path, tile_ids_to_new_treasure);
                                    set_entity_direction_to_face_next_target(dwarf);

                                    dwarf_transition_state(dwarf, .DECIDING);
                                }

                                break;
                            }
                        }
                    }

                    for tile_ids_to_remove_treasure_from {
                        array_unordered_remove_by_value(*tiles_with_treasure_ids, it);
                        table_remove(*tiles_with_treasure_ids_set, it);
                    }
                }

                // Update bases
                {
                    #if DWARF_MINER_SPAWN_ENABLED {
                        for *base: bases {
                            if base.spawn_dwarf_cooldown_ms <= 0 {
                                create_dwarf(Vector2.{ base.pos.x, base.pos.y }, .MINER);

                                base.spawn_dwarf_cooldown_ms = DWARF_MINER_SPAWN_MS;
                            } else {
                                base.spawn_dwarf_cooldown_ms -= xx (dt_seconds * 1000);
                            }
                        }
                    }
                }

                // Update iron
                UPDATE_IRON :: true;
                #if UPDATE_IRON {
                    IRON_VEIN_SIZE_MIN :: 8;
                    IRON_VEIN_SIZE_MAX :: 15;

                    if game_state.controls_state_this_frame.add_iron {
                        iron_rect := get_tile_rect_that_pos_is_within(get_world_width(), get_world_height(), TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, mouse_pos_in_world);
                        tile_pos  := Vector2.{ iron_rect.x, iron_rect.y };
                        tile_id   := get_tile_id_by_pos(tile_pos);
                        spawn_iron(xx tile_id, IRON_VEIN_SIZE_MIN, IRON_VEIN_SIZE_MAX, xx context.world_cols, xx context.world_rows, *created_chunks, *iron_tile_ids_set);
                    }
                }

                should_spread_water_this_frame := game_state.water_flow_cooldown_ms <= 0;
                if should_spread_water_this_frame {
                    game_state.water_flow_cooldown_ms = WATER_FLOW_COOLDOWN_MS;
                } else {
                    game_state.water_flow_cooldown_ms -= xx (dt_seconds * 1000);
                }

                // Update water flowing
                UPDATE_WATER_FLOWING :: true;
                #if UPDATE_WATER_FLOWING {
                    // Take an array view of the actual state because we mutate the state during the loop
                    // and can cause self referential problems when looping on the actual state.
                    current_water_flowing_tile_ids := array_view(water_flowing_tile_ids, 0);
                    for current_water_flowing_tile_ids {
                        inflict_liquid_consequences(it);

                        sprite := table_find_pointer(*water_flowing_tile_ids_to_sprite, it);
                        assert(sprite != null);
                        sprite_update(sprite, dt_seconds);

                        if should_spread_water_this_frame {
                            try_to_set_cardinal_neighbors_as_flowing_tile_type(it, .WATER_FLOWING, game_state);

                            if are_all_neighbors_unable_to_be_spread_to(it) {
                                set_tile_as_type(it, .WATER_STILL, false, false, game_state);
                            }
                        }
                    }
                }

                // Update water still
                UPDATE_WATER_STILL :: true;
                #if UPDATE_WATER_STILL {
                    // Take an array view of the actual state because we mutate the state during the loop
                    // and can cause self referential problems when looping on the actual state.
                    current_water_still_tile_ids := array_view(water_still_tile_ids, 0);
                    for current_water_still_tile_ids {
                        inflict_liquid_consequences(it);

                        sprite := table_find_pointer(*water_still_tile_ids_to_sprite, it);
                        assert(sprite != null);
                        sprite_update(sprite, dt_seconds);

                        if should_spread_water_this_frame {
                            try_to_set_cardinal_neighbors_as_flowing_tile_type(it, .WATER_FLOWING, game_state);
                        }
                    }
                }

                should_spread_lava_this_frame := game_state.lava_flow_cooldown_ms <= 0;
                if should_spread_lava_this_frame {
                    game_state.lava_flow_cooldown_ms = LAVA_FLOW_COOLDOWN_MS;
                } else {
                    game_state.lava_flow_cooldown_ms -= xx (dt_seconds * 1000);
                }

                // Update lava flowing
                UPDATE_LAVA_FLOWING :: true;
                #if UPDATE_LAVA_FLOWING {
                    // Take an array view of the actual state because we mutate the state during the loop
                    // and can cause self referential problems when looping on the actual state.
                    current_lava_flowing_tile_ids := array_view(lava_flowing_tile_ids, 0);
                    for current_lava_flowing_tile_ids {
                        inflict_liquid_consequences(it);

                        sprite := table_find_pointer(*lava_flowing_tile_ids_to_sprite, it);
                        assert(sprite != null);
                        sprite_update(sprite, dt_seconds);

                        if should_spread_lava_this_frame {
                            try_to_set_cardinal_neighbors_as_flowing_tile_type(it, .LAVA_FLOWING, game_state);

                            if are_all_neighbors_unable_to_be_spread_to(it) {
                                set_tile_as_type(it, .LAVA_STILL, false, false, game_state);
                            }
                        }
                    }
                }

                // Update lava still
                UPDATE_LAVA_STILL :: true;
                #if UPDATE_LAVA_STILL {
                    // Take an array view of the actual state because we mutate the state during the loop
                    // and can cause self referential problems when looping on the actual state.
                    current_lava_still_tile_ids := array_view(lava_still_tile_ids, 0);
                    for current_lava_still_tile_ids {
                        inflict_liquid_consequences(it);

                        if should_spread_lava_this_frame {
                            try_to_set_cardinal_neighbors_as_flowing_tile_type(it, .LAVA_FLOWING, game_state);
                        }
                    }
                }

                // Update particles
                UPDATE_PARTICLES :: true;
                #if UPDATE_PARTICLES {
                    particle_ids_to_kill_this_frame: [..] s32;
                    particle_ids_to_kill_this_frame.allocator = temp;

                    for *particle: particles {
                        // Update timer
                        particle.time_left_ms -= xx (dt_seconds * 1000);

                        // Mark particle for death if it's out of time
                        if particle.time_left_ms <= 0 {
                            array_add(*particle_ids_to_kill_this_frame, particle.id);
                            continue;
                        }

                        // PERF: there's probably an intelligent way of doing this.
                        if particle.fade {
                            if particle.time_left_ms > 1000 {
                                particle.opacity = 1;
                            } else {
                                particle.opacity = particle.time_left_ms * 0.001;
                            }

                            if particle.opacity < 0 particle.opacity = 0;
                        } else {
                            particle.opacity = 1;
                        }

                        // TODO: this logic is a little fishy. It assumes that if there is an entity to follow then we wouldn't want
                        // to also move the particle by its velocity. I guess we'll see ¯\_(ツ)_/¯
                        if particle.entity_id_to_follow > 0 {
                            found, entity := get_entity_by_id(particle.entity_kind_to_follow, particle.entity_id_to_follow);
                            if (found) {
                                particle.pos.x = entity.pos.x;
                                particle.pos.y = entity.pos.y - TILEMAP_GENERAL_WORLD_HEIGHT;
                            } else {
                                print("WARN: Particle % was trying to reference entity % (kind %) that it's supposed to follow, but didn't find it. Destroying particle.\n", particle.id, particle.entity_id_to_follow, particle.entity_kind_to_follow);
                                array_add(*particle_ids_to_kill_this_frame, particle.id);
                            }
                        } else {
                            particle.pos.x += particle.vel.x * dt_seconds_raw;
                            particle.pos.y += particle.vel.y * dt_seconds_raw;
                            
                            if particle.damp > 0 {
                                particle.vel.x *= particle.damp;
                                particle.vel.y *= particle.damp;
                            }
                        }
                    }

                    for particle_ids_to_kill_this_frame kill_particle_by_id(it);
                }
            }

            // Update alerts
            {
                alert_indices_to_remove_this_frame : [..] s64;
                alert_indices_to_remove_this_frame.allocator = temp;

                for *alert, i: alerts {
                    if alert.seen {
                        if alert.time_left_ms > 0 {
                            alert.time_left_ms -= xx (dt_seconds * 1000);
                        } else {
                            array_add(*alert_indices_to_remove_this_frame, i);
                        }
                    } else {
                        if (
                            alert.pos.x + TILEMAP_GENERAL_WORLD_WIDTH  * 0.5 > window_start.x &&
                            alert.pos.x - TILEMAP_GENERAL_WORLD_WIDTH  * 0.5 < window_end.x   &&
                            alert.pos.y - TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 < window_end.y   &&
                            alert.pos.y + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 > window_start.y
                        ) {
                            alert.seen = true;
                        }
                    }
                }

                for alert_indices_to_remove_this_frame {
                    array_unordered_remove_by_index(*alerts, it);
                }
            }

            // Update alert banner text
            if game_state.alert_banner_text_ms > 0 {
                game_state.alert_banner_text_ms -=  xx (dt_seconds * 1000);
            } else {
                game_state.alert_banner_text_ms =  0;
                game_state.alert_banner_text = "";
            }
        }
    }

    //
    // Draw
    //
    {
        derive_entities_in_viewport(camera);

        BeginDrawing();
        defer EndDrawing();

        ClearBackground(BEIGE);

        // Draw world
        {
            BeginMode2D(camera);
            defer EndMode2D();

            // First, draw base layer of dirt which is just one giant quad
            {
                dest := Rectangle.{ 
                    0,
                    0,
                    xx (TILEMAP_GENERAL_WORLD_WIDTH  * context.world_cols),
                    xx (TILEMAP_GENERAL_WORLD_HEIGHT * context.world_rows),
                };

                if camera.zoom >= CAMERA_ZOOM_LOD_MIN {
                    // This accomplishes the tiling effect when we sample the source
                    // with such a big triangle.
                    source := Rectangle.{ 
                        0, 
                        0, 
                        xx (TILEMAP_GENERAL_WORLD_WIDTH  * context.world_cols), // Repeat 10,000 times horizontally
                        xx (TILEMAP_GENERAL_WORLD_HEIGHT * context.world_rows), // Repeat 10,000 times vertically
                    };

                    DrawTexturePro(dirt_texture, source, dest, Vector2.{0,0}, 0.0, WHITE);
                } else {
                    DrawRectangleRec(dest, Color.{ 113, 65, 59, 255 });
                }
            }

            // Then draw any uncovered tiles over the base layer
            // Draw tiles
            DRAW_TILES :: true;
            DRAW_TRENCH_STRAGHT :: true;
            #if DRAW_TILES {
                for fully_mined_tile_ids_in_viewport {
                    found, tile_column := table_find(*fully_mined_tile_ids_set, it);
                    if !found {
                        metagame.state == .PAUSED;
                        print("tile % had no associated tilemap column", it);
                    }
                    // LOD
                    if camera.zoom < CAMERA_ZOOM_LOD_MIN tile_column = 3;

                    source := Rectangle.{
                        xx (tile_column * TILEMAP_GENERAL_TILE_WIDTH),
                        1 * TILEMAP_GENERAL_TILE_HEIGHT,
                        TILEMAP_GENERAL_TILE_WIDTH,
                        TILEMAP_GENERAL_TILE_HEIGHT,
                    };

                    pos  := get_tile_pos_by_id(it);
                    dest := get_world_rect_from_pos(pos);

                    DrawTexturePro(tilemap_texture_general, source, dest, Vector2.{0,0}, 0.0, WHITE);

                    // TODO: put this check inside the function
                    if DRAW_TRENCH_STRAGHT && camera.zoom >= CAMERA_ZOOM_LOD_MIN then draw_trench_walls_if_necessary(it);
                }

                for cave_tile_ids_in_viewport {
                    DrawRectangleV(
                        get_tile_pos_by_id(it),
                        Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT },
                        BLACK, // TODO: texture
                    );

                    if DRAW_TRENCH_STRAGHT && camera.zoom >= CAMERA_ZOOM_LOD_MIN then draw_trench_walls_if_necessary(it);
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

                for wall_tile_ids_in_viewport {
                    source := Rectangle.{
                        4.0 * TILEMAP_GENERAL_TILE_WIDTH,
                        1.0 * TILEMAP_GENERAL_TILE_HEIGHT,
                        TILEMAP_GENERAL_TILE_WIDTH,
                        TILEMAP_GENERAL_TILE_HEIGHT,
                    };

                    pos  := get_tile_pos_by_id(it);
                    dest := get_world_rect_from_pos(pos);

                    DrawTexturePro(tilemap_texture_general, source, dest, Vector2.{0,0}, 0.0, WHITE);

                    if DRAW_TRENCH_STRAGHT && camera.zoom >= CAMERA_ZOOM_LOD_MIN then draw_trench_walls_if_necessary(it);
                }

                for water_still_tile_ids_in_viewport {
                    sprite := table_find_pointer(*water_still_tile_ids_to_sprite, it);
                    assert(sprite != null);

                    sprite_draw(
                        sprite,
                        get_tile_pos_by_id(it),
                        TILEMAP_GENERAL_WORLD_WIDTH,
                        TILEMAP_GENERAL_WORLD_HEIGHT,
                        TILEMAP_GENERAL_TILE_WIDTH,
                        TILEMAP_GENERAL_TILE_HEIGHT,
                        false,
                    );

                    if DRAW_TRENCH_STRAGHT && camera.zoom >= CAMERA_ZOOM_LOD_MIN then draw_trench_walls_if_necessary(it);
                }

                for water_flowing_tile_ids_in_viewport {
                    // First, draw a fully mined tile underneath
                    {
                        tile_column := it % 3;
                        // LOD
                        if camera.zoom < CAMERA_ZOOM_LOD_MIN tile_column = 3;

                        source := Rectangle.{
                            xx (tile_column * TILEMAP_GENERAL_TILE_WIDTH),
                            1 * TILEMAP_GENERAL_TILE_HEIGHT,
                            TILEMAP_GENERAL_TILE_WIDTH,
                            TILEMAP_GENERAL_TILE_HEIGHT,
                        };

                        pos  := get_tile_pos_by_id(it);
                        dest := get_world_rect_from_pos(pos);

                        DrawTexturePro(tilemap_texture_general, source, dest, Vector2.{0,0}, 0.0, WHITE);
                    }

                    sprite := table_find_pointer(*water_flowing_tile_ids_to_sprite, it);
                    assert(sprite != null);

                    sprite.rotation = determine_rotation_of_liquid_flowing_sprite(it, .WATER); 

                    sprite_draw(
                        sprite,
                        get_tile_pos_by_id(it),
                        TILEMAP_GENERAL_WORLD_WIDTH,
                        TILEMAP_GENERAL_WORLD_HEIGHT,
                        TILEMAP_GENERAL_TILE_WIDTH,
                        TILEMAP_GENERAL_TILE_HEIGHT,
                        false,
                    );

                    if DRAW_TRENCH_STRAGHT && camera.zoom >= CAMERA_ZOOM_LOD_MIN then draw_trench_walls_if_necessary(it);
                }

                // Draw lava still
                for lava_still_tile_ids_in_viewport {
                    source := Rectangle.{
                        LAVA_SPRITE_SOURCE_COL * TILEMAP_GENERAL_TILE_WIDTH,
                        LAVA_SPRITE_SOURCE_ROW * TILEMAP_GENERAL_TILE_HEIGHT,
                        TILEMAP_GENERAL_TILE_WIDTH,
                        TILEMAP_GENERAL_TILE_HEIGHT,
                    };

                    pos  := get_tile_pos_by_id(it);
                    dest := get_world_rect_from_pos(pos);

                    DrawTexturePro(tilemap_texture_general, source, dest, Vector2.{0,0}, 0.0, WHITE);

                    if DRAW_TRENCH_STRAGHT && camera.zoom >= CAMERA_ZOOM_LOD_MIN then draw_trench_walls_if_necessary(it);
                }

                // Draw lava flowing
                for lava_flowing_tile_ids_in_viewport {
                    // First, draw a fully mined tile underneath
                    {
                        tile_column := it % 3;
                        // LOD
                        if camera.zoom < CAMERA_ZOOM_LOD_MIN tile_column = 3;

                        source := Rectangle.{
                            xx (tile_column * TILEMAP_GENERAL_TILE_WIDTH),
                            1 * TILEMAP_GENERAL_TILE_HEIGHT,
                            TILEMAP_GENERAL_TILE_WIDTH,
                            TILEMAP_GENERAL_TILE_HEIGHT,
                        };

                        pos  := get_tile_pos_by_id(it);
                        dest := get_world_rect_from_pos(pos);

                        DrawTexturePro(tilemap_texture_general, source, dest, Vector2.{0,0}, 0.0, WHITE);
                    }

                    sprite := table_find_pointer(*lava_flowing_tile_ids_to_sprite, it);
                    assert(sprite != null);

                    sprite.rotation = determine_rotation_of_liquid_flowing_sprite(it, .LAVA); 

                    sprite_draw(
                        sprite,
                        get_tile_pos_by_id(it),
                        TILEMAP_GENERAL_WORLD_WIDTH,
                        TILEMAP_GENERAL_WORLD_HEIGHT,
                        TILEMAP_GENERAL_TILE_WIDTH,
                        TILEMAP_GENERAL_TILE_HEIGHT,
                        false,
                    );

                    if DRAW_TRENCH_STRAGHT && camera.zoom >= CAMERA_ZOOM_LOD_MIN then draw_trench_walls_if_necessary(it);
                }

                for hole_tile_ids_in_viewport {
                    DrawRectangleV(
                        get_tile_pos_by_id(it),
                        Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT },
                        DARKGRAY, // TODO: texture
                    );

                    if DRAW_TRENCH_STRAGHT && camera.zoom >= CAMERA_ZOOM_LOD_MIN then draw_trench_walls_if_necessary(it);
                }

                if metagame.debug_mode {
                    for water_warning_tile_ids_in_viewport {
                        pos := get_tile_pos_by_id(it);
                        real_pos := Vector2.{ pos.x + TILEMAP_GENERAL_WORLD_WIDTH * 0.5, pos.y + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 };
                        DrawCircleV(real_pos, 4.0, WHITE);
                        DrawCircleV(real_pos, 3.0, ORANGE);
                    }

                    for lava_warning_tile_ids_in_viewport {
                        pos := get_tile_pos_by_id(it);
                        real_pos := Vector2.{ pos.x + TILEMAP_GENERAL_WORLD_WIDTH * 0.5, pos.y + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 };
                        DrawCircleV(real_pos, 4.0, WHITE);
                        DrawCircleV(real_pos, 3.0, ORANGE);
                    }

                    for water_alert_tile_ids_in_viewport {
                        pos := get_tile_pos_by_id(it);
                        real_pos := Vector2.{ pos.x + TILEMAP_GENERAL_WORLD_WIDTH * 0.5, pos.y + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 };
                        DrawCircleV(real_pos, 4.0, WHITE);
                        DrawCircleV(real_pos, 3.0, RED);
                    }

                    for lava_alert_tile_ids_in_viewport {
                        pos := get_tile_pos_by_id(it);
                        real_pos := Vector2.{ pos.x + TILEMAP_GENERAL_WORLD_WIDTH * 0.5, pos.y + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 };
                        DrawCircleV(real_pos, 4.0, WHITE);
                        DrawCircleV(real_pos, 3.0, RED);
                    }
                }

                if !metagame.debug_mode {
                    for encased_tile_ids_in_viewport {
                        DrawRectangleV(
                            get_tile_pos_by_id(it),
                            Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT },
                            TRANSPARENT_WHITE
                        );
                    }
                }
            }

            // Draw corners
            DRAW_TRENCH_CORNERS :: true;
            if DRAW_TRENCH_CORNERS && camera.zoom >= CAMERA_ZOOM_LOD_MIN {
                for fully_mined_tile_ids_in_viewport draw_trench_corners_if_necessary(it);
                for cave_tile_ids_in_viewport draw_trench_corners_if_necessary(it);
                for wall_tile_ids_in_viewport draw_trench_corners_if_necessary(it);
                for water_still_tile_ids_in_viewport draw_trench_corners_if_necessary(it);
                for water_flowing_tile_ids_in_viewport draw_trench_corners_if_necessary(it);
                for lava_still_tile_ids_in_viewport draw_trench_corners_if_necessary(it);
                for lava_flowing_tile_ids_in_viewport draw_trench_corners_if_necessary(it);
                for hole_tile_ids_in_viewport draw_trench_corners_if_necessary(it);
            }

            // Draw bases
            DRAW_BASES :: true;
            #if DRAW_BASES {
                for base: bases_in_viewport {
                    dest := get_world_rect_from_pos(base.pos);

                    DrawTexturePro(tilemap_texture_general, TILEMAP_SOURCE_RECT_BASE, dest, Vector2.{0,0}, 0.0, WHITE);
                }
            }

            // Draw paths
            {
                if game_state.controls_state_this_frame.drawing_path {
                    if path_being_traced_1.start_tile_id > 0 draw_path(path_being_traced_1);
                    if path_being_traced_2.start_tile_id > 0 draw_path(path_being_traced_2);
                }

                for path: paths_in_viewport draw_path(path);
            }

            // Draw dwarves
            {
                for dwarf: dwarves_in_viewport {
                    // PERF: would it be faster to store the active index?
                    found := false;
                    for anim: dwarf.animations {
                        if !anim.active continue;
                        found = true;

                        sprite_draw(
                            anim,
                            dwarf.pos,
                            xx TILEMAP_DWARF_MINER_WORLD_WIDTH,
                            xx TILEMAP_DWARF_MINER_WORLD_HEIGHT,
                            TILEMAP_DWARF_MINER_TILE_WIDTH,
                            TILEMAP_DWARF_MINER_TILE_HEIGHT,
                            dwarf.is_facing_left,
                        );
                    }
                    assert_soft(found, "Dwarf % had no animation active\n", dwarf.id);
                }
            }

            // Draw goblins
            {
                for goblin: goblins_in_viewport {
                    dest := get_world_rect_from_pos(goblin.pos);
                    DrawRectangleV(
                        Vector2.{ dest.x, dest.y },
                        Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT },
                        LIME, // TODO: texture
                    );
                }
            }

            // Draw dynamite
            DRAW_DYNAMITE :: true;
            #if DRAW_DYNAMITE {
                for tiles_with_dynamite_ids_in_viewport {
                    pos  := get_tile_pos_by_id(it);
                    dest := get_world_rect_from_pos(pos);

                    DrawTexturePro(tilemap_texture_general, TILEMAP_SOURCE_RECT_DYNAMITE, dest, Vector2.{0,0}, 0.0, WHITE);
                }
            }

            // Draw treasure
            DRAW_TREASURE :: true;
            #if DRAW_TREASURE {
                for tiles_with_treasure_ids_in_viewport {
                    source := Rectangle.{
                        5 * TILEMAP_GENERAL_TILE_WIDTH,
                        0 * TILEMAP_GENERAL_TILE_HEIGHT,
                        TILEMAP_GENERAL_TILE_WIDTH,
                        TILEMAP_GENERAL_TILE_HEIGHT,
                    };

                    pos  := get_tile_pos_by_id(it);
                    dest := get_world_rect_from_pos(pos);

                    DrawTexturePro(tilemap_texture_general, source, dest, Vector2.{0,0}, 0.0, WHITE);
                }
            }

            // Draw hovered tile
            {
                hovered_tile_rect := get_tile_rect_that_pos_is_within(get_world_width(), get_world_height(), TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, mouse_pos_in_world);
                DrawRectangleRec(hovered_tile_rect, TRANSPARENT_WHITE);
                if metagame.debug_mode {
                    found_tile, tile_id := find_tile_id_by_pos(get_rect_pos(hovered_tile_rect));
                    if found_tile {
                        DrawText(tprint("%\0", tile_id).data, xx hovered_tile_rect.x, xx hovered_tile_rect.y, 12, WHITE);
                    }
                }
            }

            // Draw particles
            DRAW_PARTICLES :: true;
            #if DRAW_PARTICLES {
                for particle: particles_in_viewport {
                    TEXT_SIZE     :: 20;
                    dest_text := get_world_rect_from_pos(particle.pos);
                    draw_outlined_text(tprint("%\0", particle.text).data, xx dest_text.x, xx dest_text.y, TEXT_SIZE, Color.{ particle.tint.r, particle.tint.g, particle.tint.b, xx (particle.opacity * 255) }, 1, BLACK);

                    if particle.sprite_source_col > -1 && particle.sprite_source_row > -1 {
                        measured_text_size := poor_mans_measure_text(particle.text, TEXT_SIZE);
                        dest_sprite := Rectangle.{
                            dest_text.x + measured_text_size.x,
                            dest_text.y - measured_text_size.y * 0.25,
                            dest_text.width,
                            dest_text.height,
                        };
                        source := Rectangle.{
                            xx (particle.sprite_source_col * TILEMAP_GENERAL_TILE_WIDTH),
                            xx (particle.sprite_source_row * TILEMAP_GENERAL_TILE_HEIGHT),
                            TILEMAP_GENERAL_TILE_WIDTH,
                            TILEMAP_GENERAL_TILE_HEIGHT,
                        };
                        DrawTexturePro(tilemap_texture_general, source, dest_sprite, Vector2.{0,0}, 0.0, Color.{ WHITE.r, WHITE.g, WHITE.b, xx (particle.opacity * 255) });
                    }
                }
            }
        }

        // Draw UI
        {
            screen_width  := GetScreenWidth();
            screen_height := GetScreenHeight();

            // Draw warnings onscreen
            for dwarf: dwarves {
                dest     := get_world_rect_from_pos(dwarf.pos);
                dest_pos := Vector2.{ dest.x, dest.y };
                radius   := 30.0;
                center   := GetWorldToScreen2D(Vector2.{ dest_pos.x + TILEMAP_GENERAL_WORLD_WIDTH * 0.5, dest_pos.y + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 }, camera);

                dwarf_center  := get_rect_center(get_world_rect_from_pos(dwarf.pos));
                dwarf_tile_id := get_tile_id_by_pos(dwarf_center);

                // Draw warnings onscreen
                {
                    dwarf_is_getting_dangerously_close_to_water := table_contains(*water_warning_tile_ids_set, dwarf_tile_id);
                    if dwarf_is_getting_dangerously_close_to_water {
                        DrawRing(center, radius, radius + 3.0, 0, 360, 0, ORANGE);
                    }
                    
                    dwarf_is_getting_dangerously_close_to_lava := table_contains(*lava_warning_tile_ids_set, dwarf_tile_id);
                    if dwarf_is_getting_dangerously_close_to_lava {
                        DrawRing(center, radius, radius + 3.0, 0, 360, 0, ORANGE);
                    }
                }

                // Draw warnings offscreen
                {
                    // If the dwarf is on screen, then there's nothing to do.
                    if (
                        dwarf_center.x + TILEMAP_GENERAL_WORLD_WIDTH  * 0.5 > window_start.x &&
                        dwarf_center.x - TILEMAP_GENERAL_WORLD_WIDTH  * 0.5 < window_end.x   &&
                        dwarf_center.y - TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 < window_end.y   &&
                        dwarf_center.y + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 > window_start.y
                    ) {
                        continue;
                    }

                    draw_warning_rings_if_necessary(dwarf_center, *water_warning_tile_ids_set, camera);
                    draw_warning_rings_if_necessary(dwarf_center, *lava_warning_tile_ids_set, camera);
                }
            }

            // Draw alerts
            for alert: alerts {
                radius := 30.0;
                center := Vector2.{ alert.pos.x + TILEMAP_GENERAL_WORLD_WIDTH * 0.5, alert.pos.y + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 };

                if (
                    center.x + TILEMAP_GENERAL_WORLD_WIDTH  * 0.5 > window_start.x &&
                    center.x - TILEMAP_GENERAL_WORLD_WIDTH  * 0.5 < window_end.x   &&
                    center.y - TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 < window_end.y   &&
                    center.y + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 > window_start.y
                ) {
                    DrawRing(GetWorldToScreen2D(center, camera), radius, radius + 3.0, 0, 360, 0, alert.color);
                } else {
                    draw_offscreen_notification(center, camera, false, alert.color);
                }
            }
            
            // Draw alert banner text
            if game_state.alert_banner_text_ms > 0 {
                assert(game_state.alert_banner_text.count > 0, "Tried drawing alert banner text but found no string to draw.");

                FONT_SIZE :: 56;
                draw_outlined_text(
                    to_c_string(game_state.alert_banner_text),
                    xx (GetScreenWidth() * 0.5 - MeasureText(to_c_string(game_state.alert_banner_text),
                    FONT_SIZE) * 0.5), 20, FONT_SIZE, game_state.alert_banner_text_color, 3, WHITE);
            }

            // Draw path being drawn cost
            if game_state.controls_state_this_frame.drawing_path {
                TEXT_SIZE :: 24;

                gold_cost := get_path_cost(path_being_traced_1) + get_path_cost(path_being_traced_2);
                measured_text_size := poor_mans_measure_text(tprint("%", gold_cost), TEXT_SIZE);

                text_x := mouse_pos_in_ui.x;
                text_y := mouse_pos_in_ui.y - measured_text_size.y;

                draw_outlined_text(tprint("%\0", gold_cost).data, xx text_x, xx text_y, TEXT_SIZE, RED, 1, WHITE);

                dest_sprite := Rectangle.{
                    text_x + measured_text_size.x,
                    text_y - measured_text_size.y,
                    TILEMAP_GENERAL_WORLD_WIDTH,
                    TILEMAP_GENERAL_WORLD_HEIGHT,
                };
                source := Rectangle.{
                    xx (PARTICLE_GOLD_SPRITE_SOURCE_COL * TILEMAP_GENERAL_TILE_WIDTH),
                    xx (PARTICLE_GOLD_SPRITE_SOURCE_ROW * TILEMAP_GENERAL_TILE_HEIGHT),
                    TILEMAP_GENERAL_TILE_WIDTH,
                    TILEMAP_GENERAL_TILE_HEIGHT,
                };
                DrawTexturePro(tilemap_texture_general, source, dest_sprite, Vector2.{0,0}, 0.0, WHITE);
            }

            debug_text_y : s32 = 10;
            INCREMENT_Y :: 20;
            if metagame.debug_mode {
                DrawFPS(10, read_then_increment(*debug_text_y, INCREMENT_Y));
                DrawText(tprint("dwarf count: %\0", dwarves.count).data, 10, read_then_increment(*debug_text_y, INCREMENT_Y), 12, WHITE);

                debug_struct_runtime :: (thing: Any, name_prefix: string, render_struct_name_prefix: bool) #expand {
                    if thing.type.type != .STRUCT return;
                    tis := cast(*Type_Info_Struct) thing.type;

                    for tis.members {
                        // Calculate where this field lives in memory
                        field_ptr := thing.value_pointer + it.offset_in_bytes;
                        
                        // Construct an 'Any' so tprint knows how to format it
                        field_any: Any;
                        field_any.type = it.type;
                        field_any.value_pointer = field_ptr;

                        // Format the string dynamically
                        text := ifx render_struct_name_prefix
                            then tprint("%.%: %\0", name_prefix, it.name, field_any)
                            else tprint("%: %\0", it.name, field_any);
                        
                        DrawText(text.data, 10, read_then_increment(*debug_text_y, INCREMENT_Y), 18, WHITE);
                    }
                }

                debug_variable_runtime :: (thing: Any, thing_symbol_as_string: string) #expand {
                    // Format the string dynamically
                    text := tprint("%: %\0", thing_symbol_as_string, thing);
                    
                    DrawText(text.data, 10, read_then_increment(*debug_text_y, INCREMENT_Y), 18, WHITE);
                }

                // TODO: recursive struct drawing?
                // TODO: way to label fields as not wanted as debuggable
                debug_with_raylib_draw_text :: (c: Code, render_struct_name_prefix := false) #expand {
                    var_name := #run code_to_string(c);
                    var_val  := #insert c;
                    
                    ti := type_info(type_of(var_val));
                    if #complete ti.type == {
                        case .STRUCT; debug_struct_runtime(var_val, var_name, render_struct_name_prefix);

                        case .INTEGER; #through;   
                        case .FLOAT;   #through; 
                        case .BOOL;    #through;
                        case .STRING;  #through;  
                        case .ANY;     #through;
                        case .POINTER; debug_variable_runtime(var_val, var_name);

                        case .PROCEDURE;            #through;
                        case .VOID;                 #through;
                        case .ARRAY;                #through;
                        case .OVERLOAD_SET;         #through;
                        case .ENUM;                 #through;
                        case .POLYMORPHIC_VARIABLE; #through;
                        case .TYPE;                 #through;
                        case .CODE;                 #through;
                        case .UNTYPED_LITERAL;      #through;
                        case .UNTYPED_ENUM;         #through;
                        case .VARIANT;              assert(false, "Unsupported debug thing");
                    }
                    
                }

                debug_with_raylib_draw_text(#code game_state.*);
                debug_with_raylib_draw_text(#code game_state.controls_state_this_frame);
                debug_with_raylib_draw_text(#code camera.*);

                debug_text_y = 0;
                for dwarves {
                    if CheckCollisionPointRec(mouse_pos_in_world, Rectangle.{ it.pos.x, it.pos.y, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT }) {
                        // TODO: parametrize debug_with_draw_text positions
                        DrawText(tprint("id: %\0", it.id).data,                                 xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("pos: %\0", it.pos).data,                               xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("state: %\0", it.state).data,                           xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("tile_ids_on_path: %\0", it.tile_ids_on_path).data,     xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("goblin_id_attacking: %\0", it.goblin_id_attacking).data, xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("tile_id_mining: %\0", it.tile_id_mining).data,         xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("direction: %\0", it.direction).data,                   xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("dwarf_type: %\0", it.dwarf_type).data,                 xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("hp: %\0", it.hp).data,                                 xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("ignore_goblins_for: %\0", it.ignore_goblins_for).data, xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                    }
                }
                
                for goblins {
                    if CheckCollisionPointRec(mouse_pos_in_world, Rectangle.{ it.pos.x, it.pos.y, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT }) {
                        DrawText(tprint("id: %\0", it.id).data,                                 xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("pos: %\0", it.pos).data,                               xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("state: %\0", it.state).data,                           xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("tile_ids_on_path: %\0", it.tile_ids_on_path).data,     xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("direction: %\0", it.direction).data,                   xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("hp: %\0", it.hp).data,                                 xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                        DrawText(tprint("attack_cooldown_ms: %\0", it.attack_cooldown_ms).data, xx (mouse_pos_in_ui.x + 20), xx (mouse_pos_in_ui.y + read_then_increment(*debug_text_y, INCREMENT_Y)), 18, WHITE);
                    }
                }
            }

            // Draw HUD
            DRAW_HUD :: true;
            #if DRAW_HUD {
                // Draw information
                {
                    HUD_INFO_FONT_SIZE     :: 18;
                    HUD_INFO_PADDING       :: 10;
                    HUD_INFO_SEGMENT_COUNT :: 7;
                    HUD_INFO_SEGMENT_WIDTH := GetScreenWidth() / HUD_INFO_SEGMENT_COUNT;
                    HUD_INFO_INCREMENT_X   := HUD_INFO_SEGMENT_WIDTH;
                    hud_info_x             := HUD_INFO_SEGMENT_WIDTH;
                    
                    time_remaining_seconds := game_state.time_remaining_ms / 1000;
                    time_remaining_minutes := time_remaining_seconds / 60;

                    draw_outlined_text(
                        tprint("Miner dwarves: %\0", dwarf_miner_count).data,
                        xx (read_then_increment(*hud_info_x, HUD_INFO_INCREMENT_X) + HUD_INFO_PADDING), xx (HUD_INFO_PADDING), HUD_INFO_FONT_SIZE, WHITE, 1, BLACK
                    );
                    draw_outlined_text(
                        tprint("Warrior dwarves: %\0", dwarf_warrior_count).data,
                        xx (read_then_increment(*hud_info_x, HUD_INFO_INCREMENT_X) + HUD_INFO_PADDING), xx (HUD_INFO_PADDING), HUD_INFO_FONT_SIZE, WHITE, 1, BLACK
                    );
                    draw_outlined_text(
                        tprint("Gold: %\0", game_state.gold).data,
                        xx (read_then_increment(*hud_info_x, HUD_INFO_INCREMENT_X) + HUD_INFO_PADDING), xx (HUD_INFO_PADDING), HUD_INFO_FONT_SIZE, WHITE, 1, BLACK
                    );
                    draw_outlined_text(
                        tprint("Points: %\0", game_state.points).data,
                        xx (read_then_increment(*hud_info_x, HUD_INFO_INCREMENT_X) + HUD_INFO_PADDING), xx (HUD_INFO_PADDING), HUD_INFO_FONT_SIZE, WHITE, 1, BLACK
                    );
                    draw_outlined_text(
                        tprint("%min %sec\0", time_remaining_minutes, time_remaining_seconds % 60).data,
                        xx (read_then_increment(*hud_info_x, HUD_INFO_INCREMENT_X) + HUD_INFO_PADDING), xx (HUD_INFO_PADDING), HUD_INFO_FONT_SIZE, WHITE, 1, BLACK
                    );
                }

                // Draw controls
                {
                    HUD_CONTROLS_PADDING       :: 10;
                    HUD_CONTROLS_SEGMENT_COUNT :: 10;
                    HUD_CONTROLS_SEGMENT_WIDTH := GetScreenWidth() / HUD_CONTROLS_SEGMENT_COUNT;
                    HUD_CONTROLS_INCREMENT_X   := HUD_CONTROLS_SEGMENT_WIDTH;
                    HUD_CONTROLS_GAP_X         :: 10;
                    HUD_CONTROLS_HEIGHT        :: 50;
                    hud_controls_x             := HUD_CONTROLS_SEGMENT_WIDTH;
                    HUD_CONTROLS_LABEL_Y       := GetScreenHeight()    - HUD_CONTROLS_PADDING * 2;
                    HUD_CONTROLS_Y             := HUD_CONTROLS_LABEL_Y - HUD_CONTROLS_HEIGHT;

                    draw_hud_control :: (control: Control) -> dest_recangle: Rectangle, is_hovered: bool #expand {
                        DrawText(
                            bind_to_readable_name_cstr(control.binds[0]),
                            xx (hud_controls_x + HUD_CONTROLS_PADDING), xx (HUD_CONTROLS_LABEL_Y), 18, WHITE
                        );

                        dest_rectangle := Rectangle.{
                            xx read_then_increment(*`hud_controls_x, HUD_CONTROLS_INCREMENT_X),
                            xx HUD_CONTROLS_Y,
                            xx HUD_CONTROLS_HEIGHT,
                            xx HUD_CONTROLS_HEIGHT,
                        };

                        is_hovered := false;

                        if CheckCollisionPointRec(`mouse_pos_in_ui, dest_rectangle) {
                            is_hovered = true;

                            // TODO: isn't this really bad to mutate state in the draw part or whatever?
                            if game_state.controls_state_this_frame.select_is_pressed_once {
                                has_control_mode := (
                                    control.id == metagame.controls.select.id ||                 
                                    control.id == metagame.controls.toggle_base_mode.id ||       
                                    control.id == metagame.controls.toggle_dynamite_mode.id ||   
                                    control.id == metagame.controls.toggle_obsidian_mode.id ||   
                                    control.id == metagame.controls.toggle_wall_mode.id ||       
                                    control.id == metagame.controls.toggle_remove_mode.id
                                );

                                if has_control_mode {
                                    game_state.control_mode = get_control_mode_from_control(control);
                                }

                                if control.id ==metagame.controls.panic_pause.id {
                                    if game_state.panic_pause_timer_ms <= 0 {
                                        game_state.panic_pause_timer_ms = PANIC_PAUSE_COOLDOWN_MS;
                                    }
                                }
                            }

                            if game_state.controls_state_this_frame.select_is_held_down {
                                if control.id ==metagame.controls.fast_forward.id {
                                    game_state.controls_state_this_frame.fast_forward = true;
                                }
                            }
                        }

                        return dest_rectangle, is_hovered;
                    }

                    draw_control_tooltip_text :: (control: Control, rect: Rectangle, gold_cost := 0) {
                        GuiSetStyle(xx GuiControl.DEFAULT, xx GuiDefaultProperty.TEXT_SIZE, 6);
                        GuiSetStyle(xx GuiControl.TEXTBOX, xx GuiControlProperty.TEXT_COLOR_NORMAL, ColorToInt(WHITE));
                        GuiSetStyle(xx GuiControl.TEXTBOX, xx GuiTextBoxProperty.TEXT_READONLY, 1);
                        GuiSetStyle(xx GuiControl.DEFAULT, xx GuiDefaultProperty.TEXT_WRAP_MODE, xx GuiTextWrapMode.TEXT_WRAP_WORD);
                        GuiSetStyle(xx GuiControl.DEFAULT, xx GuiDefaultProperty.TEXT_ALIGNMENT_VERTICAL, xx GuiTextAlignmentVertical.TEXT_ALIGN_TOP);

                        if gold_cost > 0 {
                            GuiTextBox(rect, tprint("%\n\nGold cost: %\0", control.tooltip_text, gold_cost).data, xx control.tooltip_text.count, false);
                        } else {
                            GuiTextBox(rect, tprint("%\0", control.tooltip_text).data, xx control.tooltip_text.count, false);
                        }

                        GuiSetStyle(xx GuiControl.DEFAULT, xx GuiDefaultProperty.TEXT_SIZE, 10);
                        GuiSetStyle(xx GuiControl.DEFAULT, xx GuiDefaultProperty.TEXT_ALIGNMENT_VERTICAL, xx GuiTextAlignmentVertical.TEXT_ALIGN_MIDDLE);
                        GuiSetStyle(xx GuiControl.DEFAULT, xx GuiDefaultProperty.TEXT_WRAP_MODE, xx GuiTextWrapMode.TEXT_WRAP_NONE);
                        GuiSetStyle(xx GuiControl.TEXTBOX, xx GuiTextBoxProperty.TEXT_READONLY, 0);
                    }

                    draw_hud_control_icon :: (control: Control, icon_source_rect: Rectangle, gold_cost := 0) #expand {
                        dest_rect, is_hovered := draw_hud_control(control);

                        DrawTexturePro(tilemap_texture_general, icon_source_rect, dest_rect, Vector2.{0,0}, 0.0, WHITE);

                        if is_hovered {
                            DrawText(tprint("%\0", control.name).data, xx (mouse_pos_in_ui.x), xx (mouse_pos_in_ui.y - HUD_CONTROLS_PADDING), 18, WHITE);
                            
                            tooltip_rect := Rectangle.{ dest_rect.x, dest_rect.y - dest_rect.height * 3, dest_rect.width * 6, dest_rect.height * 3 };
                            draw_control_tooltip_text(control, tooltip_rect, gold_cost);
                        }
                    }

                    draw_hud_control_color :: (control: Control, color: Color, gold_cost := 0) #expand {
                        dest_rect, is_hovered := draw_hud_control(control);

                        DrawRectangleRec(dest_rect, color);

                        if is_hovered {
                            DrawText(tprint("%\0", control.name).data, xx (mouse_pos_in_ui.x), xx (mouse_pos_in_ui.y - HUD_CONTROLS_PADDING), 18, WHITE);
                            
                            tooltip_rect := Rectangle.{ dest_rect.x, dest_rect.y - dest_rect.height * 3, dest_rect.width * 6, dest_rect.height * 3 };
                            draw_control_tooltip_text(control, tooltip_rect, gold_cost);
                        }
                    }

                    draw_hud_control_icon(metagame.controls.toggle_remove_mode, TILEMAP_SOURCE_RECT_REMOVE);
                    draw_hud_control_icon(metagame.controls.toggle_dynamite_mode, TILEMAP_SOURCE_RECT_DYNAMITE, GOLD_COST_DYNAMITE);
                    draw_hud_control_icon(metagame.controls.toggle_base_mode, TILEMAP_SOURCE_RECT_BASE, GOLD_COST_BASE);
                    draw_hud_control_color(metagame.controls.toggle_wall_mode, DARKPURPLE, GOLD_COST_WALL);
                    draw_hud_control_color(metagame.controls.toggle_obsidian_mode, DARKGRAY, GOLD_COST_OBSIDIAN);
                    draw_hud_control_color(metagame.controls.panic_pause, GRAY);
                    draw_hud_control_color(metagame.controls.fast_forward, SKYBLUE);
                }
            }

            // Draw menus
            if #complete metagame.state == {
                case .RUNNING; // no op

                case .PAUSED;
                    PAUSED_TEXT :: "PAUSED";
                    PAUSED_FONT_SIZE :: 56;
                    DrawText(PAUSED_TEXT, xx (GetScreenWidth() * 0.5 - MeasureText(PAUSED_TEXT, PAUSED_FONT_SIZE) * 0.5), 20, PAUSED_FONT_SIZE, WHITE);

                    if #complete metagame.pause_state == {
                        case .MENU;
                            // Button shared sizing stuff
                            pause_menu_button_width  := screen_width  * 0.15;
                            pause_menu_button_height := screen_height * 0.10;

                            pause_menu_button_margin :: 20;
                            pause_menu_button_gap    :: 10;

                            // TODO: would be cool to generate this constant at compile time somehow
                            PAUSE_MENU_BUTTON_COUNT :: 4;

                            get_pause_button_rectangle :: (button_gap: int, pause_button_y: float, button_width: float, button_height: float) -> Rectangle {
                                // TODO: use existing stuff here
                                screen_width  := GetScreenWidth();

                                return Rectangle.{
                                    screen_width * 0.5 - button_width * 0.5,
                                    pause_button_y,
                                    button_width,
                                    button_height
                                };
                            }

                            pause_menu_button_y := screen_height * 0.5 - (PAUSE_MENU_BUTTON_COUNT * 0.5 * pause_menu_button_height) - (PAUSE_MENU_BUTTON_COUNT * 0.5 - 0.5) * pause_menu_button_gap;

                            // TODO: DRY these up

                            // Resume button
                            {
                                defer pause_menu_button_y += pause_menu_button_height + pause_menu_button_gap;

                                resume_button := get_pause_button_rectangle(pause_menu_button_gap, pause_menu_button_y, pause_menu_button_width, pause_menu_button_height);

                                clicked := GuiButton(resume_button, "RESUME");

                                if clicked then metagame.state = .RUNNING;
                            }

                            // Options button
                            {
                                defer pause_menu_button_y += pause_menu_button_height + pause_menu_button_gap;

                                options_button := get_pause_button_rectangle(pause_menu_button_gap, pause_menu_button_y, pause_menu_button_width, pause_menu_button_height);

                                clicked := GuiButton(options_button, "OPTIONS");

                                if clicked then metagame.pause_state = .OPTIONS;
                            }

                            // Main menu button
                            {
                                defer pause_menu_button_y += pause_menu_button_height + pause_menu_button_gap;

                                main_menu_button := get_pause_button_rectangle(pause_menu_button_gap, pause_menu_button_y, pause_menu_button_width, pause_menu_button_height);

                                clicked := GuiButton(main_menu_button, "MAIN MENU");

                                if clicked {
                                    metagame.state            = .RUNNING;
                                    metagame.thing_running    = .MAIN_MENU;
                                    metagame.main_menu_screen = .ROOT;
                                    metagame.initialized      = false;
                                }
                            }

                            // Quit to desktop button
                            {
                                defer pause_menu_button_y += pause_menu_button_height + pause_menu_button_gap;

                                quit_button := get_pause_button_rectangle(pause_menu_button_gap, pause_menu_button_y, pause_menu_button_width, pause_menu_button_height);

                                clicked := GuiButton(quit_button, "QUIT");

                                if clicked then metagame.should_quit_game = true;
                            }

                        case .OPTIONS;
                            OPTIONS_HEADER_FONT_SIZE :: 40;
                    
                            ACTION_COLUMN_X     : s32 = xx (screen_width * 0);
                            BIND_ONE_COLUMN_X   := screen_width * 0.25;
                            BIND_TWO_COLUMN_X   := screen_width * 0.50;
                            BIND_THREE_COLUMN_X := screen_width * 0.75;

                            OPTIONS_HEADER_Y :: 75;

                            // Options menu headers
                            {
                                DrawText("ACTION", ACTION_COLUMN_X, OPTIONS_HEADER_Y, OPTIONS_HEADER_FONT_SIZE, WHITE);
                                DrawText("BIND ONE", xx BIND_ONE_COLUMN_X, OPTIONS_HEADER_Y, OPTIONS_HEADER_FONT_SIZE, WHITE);
                                DrawText("BIND TWO", xx BIND_TWO_COLUMN_X, OPTIONS_HEADER_Y, OPTIONS_HEADER_FONT_SIZE, WHITE);
                                DrawText("BIND THREE", xx BIND_THREE_COLUMN_X, OPTIONS_HEADER_Y, OPTIONS_HEADER_FONT_SIZE, WHITE);
                            }

                            // Option menu rows
                            {
                                OPTIONS_Y_INCREMENT :: 65;
                                options_row_y : float32 = OPTIONS_HEADER_Y + OPTIONS_Y_INCREMENT;

                                OPTIONS_ROW_FONT_SIZE : s32 : xx (OPTIONS_HEADER_FONT_SIZE * 0.75);
                                
                                BIND_BUTTON_WIDTH  := screen_width * 0.25;
                                BIND_BUTTON_HEIGHT := BIND_BUTTON_WIDTH * 0.15;

                                keybind_row :: (control: *Control) #expand {
                                    DrawText(to_c_string(control.name), `ACTION_COLUMN_X, xx `options_row_y, `OPTIONS_ROW_FONT_SIZE, WHITE);

                                    bind_one_current   := bind_to_readable_name_cstr(control.binds[0]);
                                    bind_two_current   := bind_to_readable_name_cstr(control.binds[1]);
                                    bind_three_current := bind_to_readable_name_cstr(control.binds[2]);

                                    bind_one_clicked   := GuiButton(Rectangle.{ `BIND_ONE_COLUMN_X,   `options_row_y, `BIND_BUTTON_WIDTH, `BIND_BUTTON_HEIGHT }, bind_one_current);
                                    bind_two_clicked   := GuiButton(Rectangle.{ `BIND_TWO_COLUMN_X,   `options_row_y, `BIND_BUTTON_WIDTH, `BIND_BUTTON_HEIGHT }, bind_two_current);
                                    bind_three_clicked := GuiButton(Rectangle.{ `BIND_THREE_COLUMN_X, `options_row_y, `BIND_BUTTON_WIDTH, `BIND_BUTTON_HEIGHT }, bind_three_current);

                                    if bind_one_clicked   control.binds[0].is_being_rebound = !control.binds[0].is_being_rebound;
                                    if bind_two_clicked   control.binds[1].is_being_rebound = !control.binds[1].is_being_rebound;
                                    if bind_three_clicked control.binds[2].is_being_rebound = !control.binds[2].is_being_rebound;  

                                    bind_index_currently_being_rebound := -1;
                                    if control.binds[0].is_being_rebound bind_index_currently_being_rebound = 0;
                                    if control.binds[1].is_being_rebound bind_index_currently_being_rebound = 1;
                                    if control.binds[2].is_being_rebound bind_index_currently_being_rebound = 2;

                                    if bind_index_currently_being_rebound > -1 {
                                        // NOTE: usually you have GetKeyPressed in a queue because there can be multiple keys
                                        // pressed per frame. Here, we just take the first one and call it a day.
                                        key_pressed := GetKeyPressed();
                                        
                                        if key_pressed {
                                            control.binds[bind_index_currently_being_rebound].type  = KeyboardKey;
                                            control.binds[bind_index_currently_being_rebound].value = key_pressed;
                                            control.binds[bind_index_currently_being_rebound].is_being_rebound = false;
                                        } else {
                                            mouse_value : s32 = -1;
                                            // TODO: can't I use type_info here or something
                                            //
                                            // Intentionally leaving out MOUSE_BUTTON_LEFT, I don't think we ever want to rebind that.
                                            if IsMouseButtonPressed(.MOUSE_BUTTON_RIGHT)   mouse_value = 1;
                                            if IsMouseButtonPressed(.MOUSE_BUTTON_MIDDLE)  mouse_value = 2;
                                            if IsMouseButtonPressed(.MOUSE_BUTTON_SIDE)    mouse_value = 3;
                                            if IsMouseButtonPressed(.MOUSE_BUTTON_EXTRA)   mouse_value = 4;
                                            if IsMouseButtonPressed(.MOUSE_BUTTON_FORWARD) mouse_value = 5;
                                            if IsMouseButtonPressed(.MOUSE_BUTTON_BACK)    mouse_value = 6;

                                            if mouse_value > -1 {
                                                control.binds[bind_index_currently_being_rebound].type  = MouseButton;
                                                control.binds[bind_index_currently_being_rebound].value = mouse_value;
                                                control.binds[bind_index_currently_being_rebound].is_being_rebound = false;
                                            }
                                        }
                                    }

                                    `options_row_y += `OPTIONS_Y_INCREMENT;
                                }

                                keybind_row(*(metagame.controls).toggle_base_mode);
                                keybind_row(*(metagame.controls).toggle_dynamite_mode);
                                keybind_row(*(metagame.controls).toggle_obsidian_mode);
                                keybind_row(*(metagame.controls).toggle_wall_mode);
                                keybind_row(*(metagame.controls).drag_cam);
                                keybind_row(*(metagame.controls).move_camera_up);
                                keybind_row(*(metagame.controls).move_camera_down);
                                keybind_row(*(metagame.controls).move_camera_left);
                                keybind_row(*(metagame.controls).move_camera_right);
                                keybind_row(*(metagame.controls).toggle_remove_mode);
                                keybind_row(*(metagame.controls).panic_pause);
                                keybind_row(*(metagame.controls).fast_forward);
                            }
                    }

                case .GAME_OVER;
                    TEXT :: "GAME OVER";
                    FONT_SIZE :: 56;
                    DrawText(TEXT, xx (GetScreenWidth() * 0.5 - MeasureText(TEXT, FONT_SIZE) * 0.5), 20, FONT_SIZE, WHITE);
                    if #complete metagame.game_over_state == {
                        case .MENU;
                            // Button shared sizing stuff
                            game_over_menu_button_width  := screen_width  * 0.15;
                            game_over_menu_button_height := screen_height * 0.10;

                            game_over_menu_button_margin :: 20;
                            game_over_menu_button_gap    :: 10;

                            GAME_OVER_MENU_BUTTON_COUNT :: 4;

                            get_game_over_button_rectangle :: (button_gap: int, button_y: float, button_width: float, button_height: float) -> Rectangle {
                                // TODO: use existing stuff here
                                screen_width := GetScreenWidth();

                                return Rectangle.{
                                    screen_width * 0.5 - button_width * 0.5,
                                    button_y,
                                    button_width,
                                    button_height
                                };
                            }

                            game_over_menu_button_y := screen_height * 0.5 - (GAME_OVER_MENU_BUTTON_COUNT * 0.5 * game_over_menu_button_height) - (GAME_OVER_MENU_BUTTON_COUNT * 0.5 - 0.5) * game_over_menu_button_gap;

                            // TODO: DRY these up

                            // Look around button
                            {
                                defer game_over_menu_button_y += game_over_menu_button_height + game_over_menu_button_gap;

                                look_around_button := get_game_over_button_rectangle(game_over_menu_button_gap, game_over_menu_button_y, game_over_menu_button_width, game_over_menu_button_height);

                                clicked := GuiButton(look_around_button, "LOOK AROUND");

                                if clicked metagame.game_over_state = .LOOK_AROUND;
                            }

                            // Restart button
                            {
                                defer game_over_menu_button_y += game_over_menu_button_height + game_over_menu_button_gap;

                                restart_button := get_game_over_button_rectangle(game_over_menu_button_gap, game_over_menu_button_y, game_over_menu_button_width, game_over_menu_button_height);

                                clicked := GuiButton(restart_button, "RESTART");

                                if clicked {
                                    game_state.*, metagame, camera.* = initialize_round();
                                }
                            }

                            // Main menu button
                            {
                                defer game_over_menu_button_y += game_over_menu_button_height + game_over_menu_button_gap;

                                main_menu_button := get_game_over_button_rectangle(game_over_menu_button_gap, game_over_menu_button_y, game_over_menu_button_width, game_over_menu_button_height);

                                clicked := GuiButton(main_menu_button, "MAIN MENU");

                                if clicked {
                                    // TODO
                                }
                            }

                            // Quit to desktop button
                            {
                                defer game_over_menu_button_y += game_over_menu_button_height + game_over_menu_button_gap;

                                quit_button := get_game_over_button_rectangle(game_over_menu_button_gap, game_over_menu_button_y, game_over_menu_button_width, game_over_menu_button_height);

                                clicked := GuiButton(quit_button, "QUIT");

                                if clicked metagame.should_quit_game = true;
                            }
                        
                        case .LOOK_AROUND; // Don't render anything
                    }       
            }

            // Draw control mode cursor icon
            cursor_mode_icon_rect := Rectangle.{ mouse_pos_in_ui.x + 15, mouse_pos_in_ui.y + 15, 40, 40 };

            if #complete game_state.control_mode == {
                case .NORMAL;       // no op
                case .ADD_BASE;     DrawTexturePro(tilemap_texture_general, TILEMAP_SOURCE_RECT_BASE, cursor_mode_icon_rect, Vector2.{0,0}, 0.0, WHITE);
                case .ADD_DYNAMITE; DrawTexturePro(tilemap_texture_general, TILEMAP_SOURCE_RECT_DYNAMITE, cursor_mode_icon_rect, Vector2.{0,0}, 0.0, WHITE);
                case .ADD_OBSIDIAN; DrawRectangleRec(cursor_mode_icon_rect, DARKGRAY); // TODO: draw actual icon
                case .ADD_WALL;     DrawRectangleRec(cursor_mode_icon_rect, DARKPURPLE); // TODO: draw actual icon
                case .REMOVE;       DrawTexturePro(tilemap_texture_general, TILEMAP_SOURCE_RECT_REMOVE, cursor_mode_icon_rect, Vector2.{0,0}, 0.0, WHITE);
            }
        }
    }

    return metagame;
}

create_alert :: (alert_type: AlertType, pos: Vector2, game_state: *GameState) -> Alert {
    color: Color;

    if #complete alert_type == {
        case .WATER;    
            game_state.alert_banner_text = "Water has been released!";
            color = RED;
        case .LAVA;     
            game_state.alert_banner_text = "Lava has been released!";
            color = RED;
        case .GOBLINS;  
            game_state.alert_banner_text = "A dwarf revealed a goblin cave!";
            color = RED;
        case .TREASURE; 
            game_state.alert_banner_text = "A dwarf revealed a treasure cave!";
            color = GREEN;
        case .BASE_UNDER_ATTACK;
            game_state.alert_banner_text = "Your base is under attack!";
            color = RED;
        case .SHAMAN;
            game_state.alert_banner_text = "A dwarf has disturbed a shaman!";
            color = RED;
        case .SPIDER_QUEEN;
            game_state.alert_banner_text = "A dwarf has disturbed a spider queen!";
            color = RED;
    }
    game_state.alert_banner_text_ms    = ALERT_BANNER_TEXT_MS;
    game_state.alert_banner_text_color = color;
        
    alert := Alert.{
        pos          = pos,
        seen         = false,
        color        = color,
        alert_type   = alert_type,
        time_left_ms = ALERT_TIME_TO_LIVE_MS,
    };

    array_add(*alerts, alert);

    return alert;
}

// Returns the screen-space coordinate to draw the warning indicator
get_indicator_pos :: (warning_pos_in_screen_space: Vector2, padding: float) -> (is_event_offscreen: bool, indicator_pos: Vector2) {
    screen_center := Vector2.{ GetScreenWidth() * 0.5, GetScreenHeight() * 0.5 };
    
    // Direction vector from center to target
    dx := warning_pos_in_screen_space.x - screen_center.x;
    dy := warning_pos_in_screen_space.y - screen_center.y;
    
    // If the target is exactly at the center, return center to avoid division by zero
    if dx == 0.0 && dy == 0.0 return false, Vector2.{};
    
    // Calculate the bounded area (half-extents minus the sprite padding)
    bound_x := screen_center.x - padding;
    bound_y := screen_center.y - padding;
    
    // Calculate scale factors to hit the X and Y edges
    // Use an arbitrarily large number if dx or dy is 0 to simulate infinity
    scale_x := ifx dx != 0.0 then bound_x / abs(dx) else 1000000.0;
    scale_y := ifx dy != 0.0 then bound_y / abs(dy) else 1000000.0;
    
    // The intersection is determined by whichever axis is hit first
    scale := ifx scale_x < scale_y then scale_x else scale_y;
    
    // If scale > 1.0, the target is already ON screen (inside the padded area)
    if scale > 1.0 return false, Vector2.{};
    
    return true, Vector2.{ screen_center.x + (dx * scale), screen_center.y + (dy * scale)};
}

draw_warning_rings_if_necessary :: (dwarf_center: Vector2, tile_ids_set: *Table, camera: Camera2D) {
    dwarf_tile_id := get_tile_id_by_pos(dwarf_center);
    dwarf_is_getting_dangerously_close_to_water := table_contains(tile_ids_set, dwarf_tile_id);
    
    if dwarf_is_getting_dangerously_close_to_water {
        draw_offscreen_notification(dwarf_center, camera, true, ORANGE);
    }
}

draw_offscreen_notification :: (center_pos: Vector2, camera: Camera2D, is_warning: bool, color: Color) {
    center_pos_in_screen_space := GetWorldToScreen2D(center_pos, camera);
    is_offscreen, indicator_pos := get_indicator_pos(center_pos_in_screen_space, NOTIFICATION_RADIUS);
    // assert(is_offscreen);
    if !is_offscreen then return;

    // Draw main warning bubble
    DrawCircleV(indicator_pos, NOTIFICATION_RADIUS, color);

    get_pulse_parameters :: (t: int) -> (radius: float, alpha: u8) {
        d : int   = t % 31;
        r : float = xx (NOTIFICATION_RADIUS + d);
        a : u8    = xx (255 - 8.5 * d);

        return r, a;
    }

    r1, a1 := get_pulse_parameters(xx (GetTime() * 100) + 0);
    r2, a2 := get_pulse_parameters(xx (GetTime() * 100) + 20);
    r3, a3 := get_pulse_parameters(xx (GetTime() * 100) + 40);

    // Draw pulses
    DrawRing(indicator_pos, r1, r1 + 2.0, 0, 360, 0, Color.{ color.r, color.g, color.b, a1 });
    DrawRing(indicator_pos, r2, r2 + 2.0, 0, 360, 0, Color.{ color.r, color.g, color.b, a2 });
    DrawRing(indicator_pos, r3, r3 + 2.0, 0, 360, 0, Color.{ color.r, color.g, color.b, a3 });
}

inflict_liquid_consequences :: (tile_id: s32) {
    game_over_if_touching_home_base(tile_id);
    kill_any_dwarves_touching_tile_id(tile_id);
    kill_any_goblins_touching_tile_id(tile_id);
    kill_any_dynamite_touching_tile_id(tile_id);
}

poor_mans_measure_text :: (text: string, font_size: int) -> Vector2 {
    if text.count == 0 return Vector2.{ 0, 0 };
    if text.count == 1 return Vector2.{ font_size * 0.25, xx font_size };
    return Vector2.{ text.count * font_size * 0.5, xx font_size };
}

get_previous_tile_id :: (entity: Goblin) -> s32 {
    assert_soft(entity.tile_ids_on_path.count > 0, "Tried getting entity %'s previous tile id, but entity wasn't even going anywhere\n", entity.id);

    if #complete entity.state == {
        case .IDLE;      #through;
        case .DECIDING;  #through;
        case .ATTACKING; return get_tile_id_by_pos(entity.pos);

        case .MOVING;
            for DIRECTIONS_CARDINAL {
                if entity.direction == it {
                    opposite_direction := opposite_cardinal_direction(it);
                    return get_neighbor_tile_id_by_direction(entity.tile_ids_on_path.data[0], opposite_direction);
                }
            }
    }

    assert_soft(false, "Tried getting entity %'s previous tile id but didn't find shit\n", entity.id);
    return -1;
}

get_previous_tile_id :: (entity: Dwarf) -> s32 {
    assert_soft(entity.tile_ids_on_path.count > 0, "Tried getting entity %'s previous tile id, but entity wasn't even going anywhere\n", entity.id);

    if #complete entity.state == {
        case .MINING;    #through;
        case .IDLE;      #through;
        case .DECIDING;  #through;
        case .ATTACKING; return get_tile_id_by_pos(entity.pos);

        case .MOVING;
            for DIRECTIONS_CARDINAL {
                if entity.direction == it {
                    opposite_direction := opposite_cardinal_direction(it);
                    return get_neighbor_tile_id_by_direction(entity.tile_ids_on_path.data[0], opposite_direction);
                }
            }
    }

    assert_soft(false, "Tried getting entity %'s previous tile id but didn't find shit\n", entity.id);
    return -1;
}

// TODO: use this everywhere
set_tile_ids_on_path :: (entity: *$T/interface Moveable, tile_ids: *[] s32) {
    assert(tile_ids.count > 0, "Tried to set entity % tile ids to an empty path\n", entity.id);
    // TODO: assert right on tile

    goblin_tile_id := get_tile_id_by_pos(entity.pos);

    if tile_ids.data[0] == goblin_tile_id {
        tile_ids.data  += 1;
        tile_ids.count -= 1;
    }
    
    array_reset(*entity.tile_ids_on_path);
    array_copy(*entity.tile_ids_on_path, tile_ids.*);
}

DealWithNearbyGoblinResult :: enum {
    NEARBY_GOBLIN_FOUND;
    NEARBY_GOBLIN_NOT_FOUND;
}

deal_with_nearby_goblins :: (dwarf: *Dwarf) -> DealWithNearbyGoblinResult {
    // TODO: assert dwarf is directly on tile, I think
    dwarf_center  := get_rect_center(get_world_rect_from_pos(dwarf.pos));
    dwarf_tile_id := get_tile_id_by_pos(dwarf_center);
    detected, goblin, tile_ids_to_goblin_target := detect_entity_within_radius(Goblin, dwarf_tile_id, 3);
    
    if detected {
        create_dwarf_aggro_particle(dwarf.pos, dwarf.id);

        dwarf.goblin_id_attacking = goblin.id;

        assert_soft(tile_ids_to_goblin_target.count > 0, "Dwarf % detected goblin % is right on top of him, or is moving right on top of him\n", dwarf.id, goblin.id);
        if tile_ids_to_goblin_target.count > 0 {
            goblin_tile_id := tile_ids_to_goblin_target[tile_ids_to_goblin_target.count - 1];

            // If the dwarf is right up against where it's going to attack the goblin already, then start fighting
            if is_tile_id_neighbor_of_tile_id_cardinal(dwarf_tile_id, goblin_tile_id) {
                dwarf_transition_state(dwarf, .ATTACKING);
                dwarf.is_moving_quickly = false;
            } else if dwarf.dwarf_type == .WARRIOR {
                array_reset(*dwarf.tile_ids_on_path);
                array_copy(*dwarf.tile_ids_on_path, tile_ids_to_goblin_target);

                dwarf_transition_state(dwarf, .MOVING);
                dwarf.is_moving_quickly = true;
            }
        }
    }

    return ifx detected then .NEARBY_GOBLIN_FOUND else .NEARBY_GOBLIN_NOT_FOUND;
}

// TODO: Different file?
// TODO: fancy macro or metaprogram or something to generate these?
dwarf_get_dig_damage :: (dwarf: Dwarf) -> s32 {
    if #complete dwarf.dwarf_type == {
        case .MINER;   return DWARF_MINER_DAMAGE_DIG_PER_SWING;
        case .WARRIOR; return DWARF_WARRIOR_DAMAGE_DIG_PER_SWING;
    }
}

dwarf_get_attack_damage :: (dwarf: Dwarf) -> s32 {
    if #complete dwarf.dwarf_type == {
        case .MINER;   return DWARF_MINER_DAMAGE_ATTACK_PER_SWING;
        case .WARRIOR; return DWARF_WARRIOR_DAMAGE_ATTACK_PER_SWING;
    }
}

dwarf_get_hit_chance :: (dwarf: Dwarf) -> float {
    if #complete dwarf.dwarf_type == {
        case .MINER;   return DWARF_MINER_HIT_CHANCE;
        case .WARRIOR; return DWARF_WARRIOR_HIT_CHANCE;
    }
}

dwarf_get_mining_cooldown :: (dwarf: Dwarf) -> s32 {
    if #complete dwarf.dwarf_type == {
        case .MINER;   return DWARF_MINER_DIG_COOLDOWN_MS;
        case .WARRIOR; return DWARF_WARRIOR_DIG_COOLDOWN_MS;
    }
}

dwarf_get_attack_cooldown :: (dwarf: Dwarf) -> s32 {
    if #complete dwarf.dwarf_type == {
        case .MINER;   return DWARF_MINER_ATTACK_COOLDOWN_MS;
        case .WARRIOR; return DWARF_WARRIOR_ATTACK_COOLDOWN_MS;
    }
}

dwarf_get_attack_cooldown_by_type :: (dwarf_type: DwarfType) -> s32 {
    if #complete dwarf_type == {
        case .MINER;   return DWARF_MINER_ATTACK_COOLDOWN_MS;
        case .WARRIOR; return DWARF_WARRIOR_ATTACK_COOLDOWN_MS;
    }
}

dwarf_starting_hp_by_type :: (dwarf_type: DwarfType) -> s32 {
    if #complete dwarf_type == {
        case .MINER;   return DWARF_MINER_STARTING_HP;
        case .WARRIOR; return DWARF_WARRIOR_STARTING_HP;
    }
}

is_cardinal_direction :: (direction: Direction) -> bool {
    return direction == .NORTH || direction == .SOUTH || direction == .EAST || direction == .WEST;
}

opposite_cardinal_direction :: (direction: Direction) -> Direction {
    if direction == .NORTH return .SOUTH;
    if direction == .SOUTH return .NORTH;
    if direction == .EAST  return .WEST;
    if direction == .WEST  return .EAST;
    assert_soft(false, "I don't think this should happen idk (direction: %)\n", direction);
    return .CENTER; // return center to keep the compiler happy
}

get_next_direction_to_face_from_base_neighbor_direction :: (direction: Direction) -> Direction {
    if #complete direction == {
        case .NORTH;      return .EAST;
        case .SOUTH;      return .WEST;
        case .EAST;       return .SOUTH;
        case .WEST;       return .NORTH;
        case .NORTH_EAST; return .NORTH;
        case .NORTH_WEST; return .WEST;
        case .SOUTH_EAST; return .EAST;
        case .SOUTH_WEST; return .SOUTH;
        case .CENTER;
            assert_soft(false, "I don't think this should happen idk (direction: %)\n", direction);
            return .CENTER; // return center to keep the compiler happy
    }
}

reset_memory :: () {
    table_reset(*actively_mined_tile_ids_to_health_table);
    table_reset(*fully_mined_tile_ids_set);
    table_reset(*cave_tile_ids_set);
    table_reset(*encased_tile_ids_set);
    table_reset(*iron_tile_ids_set);

    array_reset(*water_still_tile_ids);
    table_reset(*water_still_tile_ids_to_sprite);

    array_reset(*water_flowing_tile_ids);
    table_reset(*water_flowing_tile_ids_to_sprite);

    array_reset(*lava_still_tile_ids);
    table_reset(*lava_still_tile_ids_set);

    array_reset(*lava_flowing_tile_ids);
    table_reset(*lava_flowing_tile_ids_to_sprite);

    array_reset(*water_warning_tile_ids);
    table_reset(*water_warning_tile_ids_set);

    array_reset(*water_alert_tile_ids);
    table_reset(*water_alert_tile_ids_set);

    array_reset(*lava_warning_tile_ids);
    table_reset(*lava_warning_tile_ids_set);

    array_reset(*lava_alert_tile_ids);
    table_reset(*lava_alert_tile_ids_set);

    table_reset(*obsidian_tile_ids_set);

    table_reset(*wall_tile_ids_set);

    array_reset(*bases);
    table_reset(*base_id_to_index);

    array_reset(*dwarves);
    table_reset(*dwarf_id_to_index);

    array_reset(*goblins);
    table_reset(*goblin_id_to_index);

    array_reset(*tiles_with_dynamite_ids);

    array_reset(*tiles_with_treasure_ids);
    table_reset(*tiles_with_treasure_ids_set);

    array_reset(*hole_tile_ids);
    table_reset(*hole_tile_ids_set);

    array_reset(*paths);

    table_reset(*created_chunks);

    array_reset(*particles);
    table_reset(*particle_id_to_index);

    entity_id_counter   = 0;
    control_id_counter  = 0;
    particle_id_counter = 0;
}

get_world_width :: inline () -> int {
    return context.world_cols * TILEMAP_GENERAL_WORLD_WIDTH;
}

get_world_height :: inline () -> int {
    return context.world_rows * TILEMAP_GENERAL_WORLD_HEIGHT;
}

initialize_round :: () -> GameState, Metagame, Camera2D {
    GAME_TIME_REMAINING_MS    :: 900_000; // 15 minutes
    GAME_STARTING_GOLD_HARD   :: 0;
    GAME_STARTING_GOLD_MEDIUM :: 150;
    GAME_STARTING_GOLD_EASY   :: 250;

    if #complete metagame.level == {
        case .NORMAL;
            context.world_rows = WORLD_COLS_HUGE;
            context.world_cols = WORLD_ROWS_HUGE;
            context.camera_zoom_min = 0.07428;
        case .TUTORIAL_CONTROLS;
            context.world_rows = WORLD_COLS_TUTORIAL_CONTROLS;
            context.world_cols = WORLD_ROWS_TUTORIAL_CONTROLS;
            context.camera_zoom_min = 1.728;
    }

    // Set world dimension caches
    context.world_cols_mask  = context.world_cols - 1;
    context.world_rows_mask  = context.world_rows - 1;
    context.world_cols_shift = integer_log2(xx context.world_cols);
    context.world_cols_recip = 1.0 / context.world_cols;
    context.world_rows_recip = 1.0 / context.world_rows;

    // Set temp allocator for various things.
    {
        fully_mined_tile_ids_in_viewport.allocator    = temp;
        actively_mined_tile_ids_in_viewport.allocator = temp;
        cave_tile_ids_in_viewport.allocator           = temp;
        encased_tile_ids_in_viewport.allocator        = temp;
        iron_tile_ids_in_viewport.allocator           = temp;
        water_still_tile_ids_in_viewport.allocator    = temp;
        water_flowing_tile_ids_in_viewport.allocator  = temp;
        lava_still_tile_ids_in_viewport.allocator     = temp;
        lava_flowing_tile_ids_in_viewport.allocator   = temp;
        obsidian_tile_ids_in_viewport.allocator       = temp;
        wall_tile_ids_in_viewport.allocator           = temp;
        dwarves_in_viewport.allocator                 = temp;
        goblins_in_viewport.allocator                 = temp;
        tiles_with_dynamite_ids_in_viewport.allocator = temp;
        tiles_with_treasure_ids_in_viewport.allocator = temp;
        hole_tile_ids_in_viewport.allocator           = temp;
        paths_in_viewport.allocator                   = temp;
        alerts_in_viewport.allocator                  = temp;
        bases_in_viewport.allocator                   = temp;
        tile_ids_to_dwarfs.allocator                  = temp;
        tile_ids_to_goblins.allocator                 = temp;
        tile_ids_to_bases.allocator                   = temp;
    }

    // TODO: parametrize
    random_seed(123456789);

    // TODO: Defaults to fall back on
    // TODO: Put in a config file, but keep as jai, and then parse and #insert or something?
    // Initialize controls
    controls: Controls;
    {
        controls.select.binds[0] = Bind.{ type = MouseButton, value = cast(s32) MouseButton.MOUSE_BUTTON_LEFT };

        controls.clear_selection.id   = read_then_increment(*control_id_counter);
        controls.clear_selection.name = "Clear selection";
        controls.clear_selection.control_mode = .NORMAL;
        controls.clear_selection.rebindable_by_user = true;
        controls.clear_selection.binds[0] = Bind.{ type = MouseButton, value = cast(s32) MouseButton.MOUSE_BUTTON_RIGHT };

        controls.toggle_base_mode.id   = read_then_increment(*control_id_counter);
        controls.toggle_base_mode.name = "Build base mode";
        // TODO: This text needs to change dynamically ("Cost: % (Next will cost %)")
        controls.toggle_base_mode.tooltip_text = "Bases increase your max amount of warriors, and allow you to spawn additional miners. Must be built on a path. Cost more each time you build one.";
        controls.toggle_base_mode.control_mode = .ADD_BASE;
        controls.toggle_base_mode.rebindable_by_user = true;
        controls.toggle_base_mode.binds[0] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_B };

        controls.add_iron.id   = read_then_increment(*control_id_counter);
        controls.add_iron.name = "DEBUG: Add iron deposit";
        controls.add_iron.rebindable_by_user = false;
        controls.add_iron.binds[0] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_I };

        controls.select_as_place_miner_dwarf.id   = read_then_increment(*control_id_counter);
        controls.select_as_place_miner_dwarf.name = "DEBUG: Add miner dwarf";
        controls.select_as_place_miner_dwarf.rebindable_by_user = false;
        controls.select_as_place_miner_dwarf.binds[0] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_D };

        controls.select_as_place_warrior_dwarf.id   = read_then_increment(*control_id_counter);
        controls.select_as_place_warrior_dwarf.name = "DEBUG: Add warrior dwarf";
        controls.select_as_place_warrior_dwarf.rebindable_by_user = false;
        controls.select_as_place_warrior_dwarf.binds[0] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_A };

        controls.toggle_dynamite_mode.id   = read_then_increment(*control_id_counter);
        controls.toggle_dynamite_mode.name = "Place dynamite mode";
        controls.toggle_dynamite_mode.tooltip_text = "Blows up a dwarf when stepped on, creating a hole. Holes stop water and lava flows permanently.";
        controls.toggle_dynamite_mode.control_mode = .ADD_DYNAMITE;
        controls.toggle_dynamite_mode.rebindable_by_user = true;
        controls.toggle_dynamite_mode.binds[0] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_E };

        controls.select_as_place_goblin.id   = read_then_increment(*control_id_counter);
        controls.select_as_place_goblin.name = "DEBUG: Place goblin";
        controls.select_as_place_goblin.rebindable_by_user = false;
        controls.select_as_place_goblin.binds[0] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_T };
        
        controls.toggle_obsidian_mode.id   = read_then_increment(*control_id_counter);
        controls.toggle_obsidian_mode.name = "Obsidian mode";
        controls.toggle_obsidian_mode.tooltip_text = "Turns soil into solid obsidian, making it impenetrable to almost anything.";
        controls.toggle_obsidian_mode.control_mode = .ADD_OBSIDIAN;
        controls.toggle_obsidian_mode.rebindable_by_user = true;
        controls.toggle_obsidian_mode.binds[0] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_Q           };
        controls.toggle_obsidian_mode.binds[1] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_LEFT_SHIFT  };
        controls.toggle_obsidian_mode.binds[2] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_RIGHT_SHIFT };
        
        controls.toggle_wall_mode.id   = read_then_increment(*control_id_counter);
        controls.toggle_wall_mode.name = "Build wall mode";
        controls.toggle_wall_mode.tooltip_text = "Place a wall that permanently stops water, slows down lava, and blocks warriors and certain enemies. Miners, some enemies, and lava can destroy walls.";
        controls.toggle_wall_mode.control_mode = .ADD_WALL;
        controls.toggle_wall_mode.rebindable_by_user = true;
        controls.toggle_wall_mode.binds[0] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_W };
        
        controls.drag_cam.id   = read_then_increment(*control_id_counter);
        controls.drag_cam.name = "Drag camera";
        controls.drag_cam.rebindable_by_user = true;
        controls.drag_cam.binds[0] = Bind.{ type = MouseButton, value = cast(s32) MouseButton.MOUSE_BUTTON_RIGHT  };
        controls.drag_cam.binds[1] = Bind.{ type = MouseButton, value = cast(s32) MouseButton.MOUSE_BUTTON_MIDDLE };
        
        controls.move_camera_up.id   = read_then_increment(*control_id_counter);
        controls.move_camera_up.name = "Move camera up";
        controls.move_camera_up.rebindable_by_user = true;
        controls.move_camera_up.binds[0] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_UP };
        
        controls.move_camera_down.id   = read_then_increment(*control_id_counter);
        controls.move_camera_down.name = "Move camera down";
        controls.move_camera_down.rebindable_by_user = true; 
        controls.move_camera_down.binds[0] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_DOWN };
        
        controls.move_camera_left.id   = read_then_increment(*control_id_counter);
        controls.move_camera_left.name = "Move camera left";
        controls.move_camera_left.rebindable_by_user = true; 
        controls.move_camera_left.binds[0] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_LEFT };
        
        controls.move_camera_right.id   = read_then_increment(*control_id_counter);
        controls.move_camera_right.name = "Move camera right";
        controls.move_camera_right.rebindable_by_user = true; 
        controls.move_camera_right.binds[0] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_RIGHT };
        
        controls.toggle_remove_mode.id   = read_then_increment(*control_id_counter);
        controls.toggle_remove_mode.name = "Remove mode";
        controls.toggle_remove_mode.control_mode = .REMOVE;
        controls.toggle_remove_mode.tooltip_text = "While active, you can select a created object to destroy it, like dynamite and path arrows.";
        controls.toggle_remove_mode.rebindable_by_user = true; 
        controls.toggle_remove_mode.binds[0] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_R };

        controls.panic_pause.id   = read_then_increment(*control_id_counter);
        controls.panic_pause.name = "Panic pause";
        controls.panic_pause.tooltip_text = "Forces time to a halt for a short duration, but has a decently-long cooldown.";
        controls.panic_pause.rebindable_by_user = true;
        controls.panic_pause.binds[0] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_SPACE };

        controls.fast_forward.id   = read_then_increment(*control_id_counter);
        controls.fast_forward.name = "Fast forward";
        controls.fast_forward.tooltip_text = "Speeds up the action, takes on resources to do, and has no cooldown.";
        controls.fast_forward.rebindable_by_user = true;
        controls.fast_forward.binds[0] = Bind.{ type = KeyboardKey, value = cast(s32) KeyboardKey.KEY_S };
    }

    reset_memory();

    // Initialize game
    game_state := GameState.{
        hovered_dwarf_index        = 0,
        selected_dwarf_id          = 0,
        selected_dwarf_particle_id = 0,
        water_flow_cooldown_ms     = WATER_FLOW_COOLDOWN_MS,
        lava_flow_cooldown_ms      = LAVA_FLOW_COOLDOWN_MS,
        time_remaining_ms          = GAME_TIME_REMAINING_MS,
        points                     = 0,
        gold                       = GAME_STARTING_GOLD_EASY,
        control_mode               = .NORMAL,
        alert_banner_text          = "",
        alert_banner_text_ms       = 0,
    };

    metagame.state            = .RUNNING;
    metagame.thing_running    = .ROUND;
    metagame.initialized      = true;
    metagame.should_quit_game = false;
    metagame.debug_mode       = false;
    metagame.pause_state      = .MENU;
    metagame.game_over_state  = .MENU;
    metagame.main_menu_screen = .ROOT;
    metagame.controls         = controls;

    camera: Camera2D;

    GENERATE_CAVES_ENABLED :: true;

    if #complete metagame.level == {
        case .NORMAL;
            // Initialize caves
            #if GENERATE_CAVES_ENABLED {
                CAVE_PERLIN_NOISE_FREQUENCY :: 256; // How many rows / columns
                CAVE_PERLIN_NOISE_AMPLITUDE :: 2;
                CAVE_PERLIN_NOISE_OCTAVES   :: 1;
                CAVE_PERLIN_NOISE_MAX_THRESHOLD :: 0.95;

                cave_noise := perlin_noise_2d(xx context.world_cols, CAVE_PERLIN_NOISE_FREQUENCY, CAVE_PERLIN_NOISE_AMPLITUDE, CAVE_PERLIN_NOISE_OCTAVES);

                for i: 0..(context.world_cols * context.world_cols)-1 {
                    normalized := (cave_noise[i] + 1.0) / 2.0;
                    // Clamp just in case floating point math slightly overshoots
                    cave_noise[i] = clamp(normalized, 0.0, 1.0);
                }

                for col: 0..context.world_cols-1 {
                    for row: 0..context.world_rows-1 {
                        tile_id := (row * context.world_cols) + col + 1;
                        noise_index := row * context.world_cols + col;
                        tile_should_be_part_of_cave := cave_noise[noise_index] >= CAVE_PERLIN_NOISE_MAX_THRESHOLD;

                        if tile_should_be_part_of_cave {
                            set_tile_as_type(xx tile_id, .CAVE, false, false, *game_state);
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

                for col: 0..context.world_cols-1 {
                    for row: 0..context.world_rows-1 {
                        tile_id := (row * context.world_cols) + col + 1;

                        iron_spawn_dice_roll := cast(int) random_get_within_range(IRON_SPAWN_CHANCE_NUMERATOR, IRON_SPAWN_CHANCE_DENOMINATOR);
                        if iron_spawn_dice_roll <= IRON_SPAWN_CHANCE_NUMERATOR {
                            spawn_iron(xx tile_id, IRON_VEIN_SIZE_MIN, IRON_VEIN_SIZE_MAX, xx context.world_cols, xx context.world_rows, *created_chunks, *iron_tile_ids_set);
                        }
                    }
                }
            }

            // Initialize bases
            GENERATE_BASE_ENABLED :: true;
            #if GENERATE_BASE_ENABLED {
                home_base := create_base(
                    Vector2.{
                        context.world_cols * TILEMAP_GENERAL_WORLD_WIDTH  * 0.5,
                        context.world_rows * TILEMAP_GENERAL_WORLD_HEIGHT * 0.5,
                    },
                    true,
                    *game_state
                );
            }

            // Initialize dwarves
            GENERATE_DWARVES_ENABLED :: true;
            #if GENERATE_DWARVES_ENABLED {
                dx, dy : float;
                neighbor_pos: Vector2;
                assert(bases.count > 0);

                for 1..DWARF_MINER_START_COUNT {
                    // Initialize miner dwarves
                    dx = TILE_DIRECTION_DELTAS[xx Direction.NORTH][0];
                    dy = TILE_DIRECTION_DELTAS[xx Direction.NORTH][1];
                    neighbor_pos = Vector2.{ home_base.pos.x + dx, home_base.pos.y + dy };

                    create_dwarf(neighbor_pos, .MINER);
                }
                
                for 1..DWARF_WARRIOR_START_COUNT {
                    // Initialize warrior dwarf
                    dx = TILE_DIRECTION_DELTAS[xx Direction.EAST][0];
                    dy = TILE_DIRECTION_DELTAS[xx Direction.EAST][1];
                    neighbor_pos = Vector2.{ home_base.pos.x + dx, home_base.pos.y + dy };

                    create_dwarf(neighbor_pos, .WARRIOR);
                }
            }

            // Initialize camera
            #if GENERATE_BASE_ENABLED {
                camera.target   = bases[0].pos;
            } else {
                camera.target   = Vector2.{
                    context.world_cols * TILEMAP_GENERAL_WORLD_WIDTH  / 2,
                    context.world_rows * TILEMAP_GENERAL_WORLD_HEIGHT / 2,
                };
            }

        case .TUTORIAL_CONTROLS;
            // Initialize camera
            camera.target = Vector2.{
                context.world_cols * TILEMAP_GENERAL_WORLD_WIDTH  * 0.5,
                context.world_rows * TILEMAP_GENERAL_WORLD_HEIGHT * 0.5,
            };
    }

    camera.offset   = Vector2.{ GetScreenWidth() * 0.5, GetScreenHeight() * 0.5 };
    camera.rotation = 0.0;
    camera.zoom     = 2.0;

    return game_state, metagame, camera;
}

dwarf_transition_state :: (dwarf: *Dwarf, new_state: DwarfState) {
    // What to do when exiting these states
    if #complete dwarf.state == {
        case .ATTACKING;
            dwarf.goblin_id_attacking = 0;
        case .DECIDING;
        case .IDLE;
        case .MINING;
            dwarf.tile_id_mining = 0;
        case .MOVING;
    }

    dwarf.state = new_state;

    // What to do when entering these states
    if #complete new_state == {
        case .ATTACKING; dwarf_set_active_animation(dwarf, .MINE);
        case .DECIDING;  
        case .IDLE;      dwarf_set_active_animation(dwarf, .IDLE);
        case .MINING;    dwarf_set_active_animation(dwarf, .MINE);
        case .MOVING;    dwarf_set_active_animation(dwarf, .WALK);
    }
}

SetDwarfRandomNewTargetReturnStatus :: enum {
    DIRECTION_FOUND;
    NO_DIRECTION_FOUND;
}

try_to_set_dwarf_random_new_target :: (dwarf: *Dwarf) -> SetDwarfRandomNewTargetReturnStatus {
    dwarf_tile_id_current := get_tile_id_by_pos(dwarf.pos);
    can_target_unmined_tiles := dwarf.dwarf_type == .MINER;

    // Enumerate the different directions the dwarf can go
    is_north_valid := ifx can_target_unmined_tiles
        then is_tile_id_walkable_or_mineable_for_entity(get_neighbor_tile_id_by_direction(dwarf_tile_id_current, .NORTH), dwarf.id)
        else             is_tile_id_walkable_for_entity(get_neighbor_tile_id_by_direction(dwarf_tile_id_current, .NORTH), dwarf.id);

    is_south_valid := ifx can_target_unmined_tiles
        then is_tile_id_walkable_or_mineable_for_entity(get_neighbor_tile_id_by_direction(dwarf_tile_id_current, .SOUTH), dwarf.id)
        else             is_tile_id_walkable_for_entity(get_neighbor_tile_id_by_direction(dwarf_tile_id_current, .SOUTH), dwarf.id);

    is_east_valid  := ifx can_target_unmined_tiles
        then is_tile_id_walkable_or_mineable_for_entity(get_neighbor_tile_id_by_direction(dwarf_tile_id_current, .EAST), dwarf.id)
        else             is_tile_id_walkable_for_entity(get_neighbor_tile_id_by_direction(dwarf_tile_id_current, .EAST), dwarf.id);

    is_west_valid  := ifx can_target_unmined_tiles
        then is_tile_id_walkable_or_mineable_for_entity(get_neighbor_tile_id_by_direction(dwarf_tile_id_current, .WEST), dwarf.id)
        else             is_tile_id_walkable_for_entity(get_neighbor_tile_id_by_direction(dwarf_tile_id_current, .WEST), dwarf.id);

    if !is_north_valid && !is_south_valid && !is_east_valid && !is_west_valid return .NO_DIRECTION_FOUND;

    new_direction := dwarf.direction;

    change_direction_rng := random_get_within_range(0, 1);
    if change_direction_rng < 0.1 || !can_target_unmined_tiles {

        go_left := change_direction_rng < 0.05;

        if dwarf.direction == .NORTH {
            if go_left {
                if      is_west_valid  new_direction = .WEST;
                else if is_east_valid  new_direction = .EAST;
                else if is_north_valid new_direction = .NORTH;
                else                   new_direction = .SOUTH;
            } else {
                if      is_east_valid  new_direction = .EAST;
                else if is_west_valid  new_direction = .WEST;
                else if is_north_valid new_direction = .NORTH;
                else                   new_direction = .SOUTH;
            }
        }
        else if dwarf.direction == .SOUTH {
            if go_left {
                if      is_east_valid  new_direction = .EAST;
                else if is_west_valid  new_direction = .WEST;
                else if is_south_valid new_direction = .SOUTH;
                else                   new_direction = .NORTH;
            } else {
                if      is_west_valid  new_direction = .WEST;
                else if is_east_valid  new_direction = .EAST;
                else if is_south_valid new_direction = .SOUTH;
                else                   new_direction = .NORTH;
            }
        }
        else if dwarf.direction == .EAST  {
            if go_left {
                if      is_south_valid new_direction = .SOUTH;
                else if is_north_valid new_direction = .NORTH;
                else if is_east_valid  new_direction = .EAST;
                else                   new_direction = .WEST;
            } else {
                if      is_north_valid new_direction = .NORTH;
                else if is_south_valid new_direction = .SOUTH;
                else if is_east_valid  new_direction = .EAST;
                else                   new_direction = .WEST;
            }
        }
        else if dwarf.direction == .WEST  {
            if go_left {
                if      is_south_valid new_direction = .SOUTH;
                else if is_north_valid new_direction = .NORTH;
                else if is_west_valid  new_direction = .WEST;
                else                   new_direction = .EAST;
            } else {
                if      is_south_valid new_direction = .SOUTH;
                else if is_north_valid new_direction = .NORTH;
                else if is_west_valid  new_direction = .WEST;
                else                   new_direction = .EAST;
            }
        }
        // TODO: #complete this somehow so we don't need this assert
        else {
            print_vars(is_north_valid, is_south_valid, is_east_valid, is_west_valid, dwarf.*);
            assert_soft(false, "Expected at least one direction to be valid, but found none for dwarf %\n", dwarf.id);
        }

    }

    if new_direction == .NORTH && !is_north_valid return .NO_DIRECTION_FOUND;
    if new_direction == .SOUTH && !is_south_valid return .NO_DIRECTION_FOUND;
    if new_direction == .EAST &&  !is_east_valid  return .NO_DIRECTION_FOUND;
    if new_direction == .WEST &&  !is_west_valid  return .NO_DIRECTION_FOUND;

    dwarf.direction = new_direction;
    dwarf_tile_id := get_tile_id_by_pos(dwarf.pos);
    new_target_tile_id := get_neighbor_tile_id_by_direction(dwarf_tile_id, new_direction);

    // TODO: extract
    array_reset(*dwarf.tile_ids_on_path);
    array_add(*dwarf.tile_ids_on_path, new_target_tile_id);
    set_entity_direction_to_face_next_target(dwarf);

    return .DIRECTION_FOUND;
}

try_to_set_dwarf_target_to_one_block_in_the_direction_its_facing :: (dwarf: *Dwarf) -> SetDwarfRandomNewTargetReturnStatus {
    dwarf_tile_id_current := get_tile_id_by_pos(dwarf.pos);

    is_tile_valid := ifx dwarf.dwarf_type == .MINER
        then is_tile_id_walkable_or_mineable_for_entity(get_neighbor_tile_id_by_direction(dwarf_tile_id_current, dwarf.direction), dwarf.id)
        else is_tile_id_walkable_for_entity(get_neighbor_tile_id_by_direction(dwarf_tile_id_current, dwarf.direction), dwarf.id);
    if !is_tile_valid return .NO_DIRECTION_FOUND;

    new_target_tile_id := get_neighbor_tile_id_by_direction(dwarf_tile_id_current, dwarf.direction);

    // TODO: extract
    array_reset(*dwarf.tile_ids_on_path);
    array_add(*dwarf.tile_ids_on_path, new_target_tile_id);

    return .DIRECTION_FOUND;
}

try_to_set_goblin_random_new_target :: (goblin: *Goblin) -> SetDwarfRandomNewTargetReturnStatus {
    goblin_tile_id_current := get_tile_id_by_pos(goblin.pos);

    // Enumerate the different directions the goblin can go
    is_north_valid := is_tile_id_walkable_for_entity(get_neighbor_tile_id_by_direction(goblin_tile_id_current, .NORTH), goblin.id);
    is_south_valid := is_tile_id_walkable_for_entity(get_neighbor_tile_id_by_direction(goblin_tile_id_current, .SOUTH), goblin.id);
    is_east_valid  := is_tile_id_walkable_for_entity(get_neighbor_tile_id_by_direction(goblin_tile_id_current, .EAST),  goblin.id);
    is_west_valid  := is_tile_id_walkable_for_entity(get_neighbor_tile_id_by_direction(goblin_tile_id_current, .WEST),  goblin.id);
    if !is_north_valid && !is_south_valid && !is_east_valid && !is_west_valid return .NO_DIRECTION_FOUND;

    new_direction := goblin.direction;

    change_direction_rng := random_get_within_range(0, 1);
    if change_direction_rng < 0.1 {
        go_left := change_direction_rng < 0.05;

        if goblin.direction == .NORTH {
            if go_left {
                if      is_west_valid  new_direction = .WEST;
                else if is_east_valid  new_direction = .EAST;
                else if is_north_valid new_direction = .NORTH;
                else                   new_direction = .SOUTH;
            } else {
                if      is_east_valid  new_direction = .EAST;
                else if is_west_valid  new_direction = .WEST;
                else if is_north_valid new_direction = .NORTH;
                else                   new_direction = .SOUTH;
            }
        }
        else if goblin.direction == .SOUTH {
            if go_left {
                if      is_east_valid  new_direction = .EAST;
                else if is_west_valid  new_direction = .WEST;
                else if is_south_valid new_direction = .SOUTH;
                else                   new_direction = .NORTH;
            } else {
                if      is_west_valid  new_direction = .WEST;
                else if is_east_valid  new_direction = .EAST;
                else if is_south_valid new_direction = .SOUTH;
                else                   new_direction = .NORTH;
            }
        }
        else if goblin.direction == .EAST  {
            if go_left {
                if      is_south_valid new_direction = .SOUTH;
                else if is_north_valid new_direction = .NORTH;
                else if is_east_valid  new_direction = .EAST;
                else                   new_direction = .WEST;
            } else {
                if      is_north_valid new_direction = .NORTH;
                else if is_south_valid new_direction = .SOUTH;
                else if is_east_valid  new_direction = .EAST;
                else                   new_direction = .WEST;
            }
        }
        else if goblin.direction == .WEST  {
            if go_left {
                if      is_south_valid new_direction = .SOUTH;
                else if is_north_valid new_direction = .NORTH;
                else if is_west_valid  new_direction = .WEST;
                else                   new_direction = .EAST;
            } else {
                if      is_south_valid new_direction = .SOUTH;
                else if is_north_valid new_direction = .NORTH;
                else if is_west_valid  new_direction = .WEST;
                else                   new_direction = .EAST;
            }
        }
        // TODO: #complete this somehow so we don't need this assert
        else {
            print_vars(is_north_valid, is_south_valid, is_east_valid, is_west_valid, goblin.*);
            assert_soft(false, "Expected at least one direction to be valid, but found none for goblin %\n", goblin.id);
        }

    }

    if new_direction == .NORTH && !is_north_valid return .NO_DIRECTION_FOUND;
    if new_direction == .SOUTH && !is_south_valid return .NO_DIRECTION_FOUND;
    if new_direction == .EAST &&  !is_east_valid  return .NO_DIRECTION_FOUND;
    if new_direction == .WEST &&  !is_west_valid  return .NO_DIRECTION_FOUND;

    goblin.direction = new_direction;
    goblin_tile_id := get_tile_id_by_pos(goblin.pos);
    new_target_tile_id := get_neighbor_tile_id_by_direction(goblin_tile_id, new_direction);

    // TODO: extract
    array_reset(*goblin.tile_ids_on_path);
    array_add(*goblin.tile_ids_on_path, new_target_tile_id);
    set_goblin_direction_to_face_next_target(goblin);

    return .DIRECTION_FOUND;
}

can_entity_make_progress :: (entity: *$T/interface Moveable) -> bool {
    if entity.tile_ids_on_path.count == 0 return false;

    target_tile_id := entity.tile_ids_on_path[0];
    entity_tile_id := get_tile_id_by_pos(entity.pos);
    assert_soft(target_tile_id != entity_tile_id, "Entity is softlocked trying to get it the id it's already on, I think.", entity.id);

    return is_tile_id_walkable_for_entity(target_tile_id, entity_tile_id);
}

// TODO: DRY
set_goblin_direction_to_face_next_target :: (goblin: *Goblin) {
    assert(goblin.tile_ids_on_path.count > 0);
    target_tile_id := goblin.tile_ids_on_path[0];
    goblin_tile_id  := get_tile_id_by_pos(goblin.pos);
    assert(target_tile_id != goblin_tile_id, "goblin is softlocked trying to get it the id it's already on, I think.");

    if      target_tile_id == goblin_tile_id - xx context.world_rows goblin.direction = .NORTH;
    else if target_tile_id == goblin_tile_id + xx context.world_rows goblin.direction = .SOUTH;
    else if target_tile_id == goblin_tile_id + 1          goblin.direction = .EAST;
    else if target_tile_id == goblin_tile_id - 1          goblin.direction = .WEST;
    else assert(false);
}

detect_neighbor :: (tile_id: s32, $T: Type) -> base_neighbor_detected: bool, entity: *T, direction: Direction
#modify { return uses_entity_with_as(cast(*Type_Info) T, Entity); }
{
    for DIRECTIONS_COMPASS {
        dx := get_tile_direction_id_deltas(it)[0];
        dy := get_tile_direction_id_deltas(it)[1];

        neighbor_id := tile_id + dx + dy;

        set_tile_ids_to_entity(T);

        found, entity := table_find(*tile_ids_to_entity, neighbor_id);
        if (found) return true, entity, it;
    }

    return false, null, .CENTER;
}

detect_neighbor_cardinal :: (tile_id: s32, $T: Type) -> neighbor_detected: bool, entity: *T, direction: Direction
#modify { return uses_entity_with_as(cast(*Type_Info) T, Entity); }
{
    for DIRECTIONS_CARDINAL {
        dx := get_tile_direction_id_deltas(it)[0];
        dy := get_tile_direction_id_deltas(it)[1];

        neighbor_id := tile_id + dx + dy;

        set_tile_ids_to_entity(T);

        found, base := table_find(*tile_ids_to_entity, neighbor_id);
        if (found) return true, base, it;
    }

    return false, null, .CENTER;
}

is_tile_id_neighbor_of_tile_id_cardinal :: (my_tile_id: s32, your_tile_id: s32) -> bool {
    return (
        my_tile_id == your_tile_id - xx context.world_cols || // north
        my_tile_id == your_tile_id + xx context.world_cols || // south
        my_tile_id == your_tile_id + 1          || // east
        my_tile_id == your_tile_id - 1             // west
    );
}

taunt_dwarf :: (dwarf_id: s32, taunter_tile_id: s32) {
    found, dwarf_index := table_find(*dwarf_id_to_index, dwarf_id);
    assert(found);
    
    dwarf_center  := get_rect_center(get_world_rect_from_pos(dwarves[dwarf_index].pos));
    dwarf_tile_id := get_tile_id_by_pos(dwarf_center);
    direction_to_face_taunter : Direction;
    if      taunter_tile_id == dwarf_tile_id - xx context.world_rows direction_to_face_taunter = .NORTH;
    else if taunter_tile_id == dwarf_tile_id + xx context.world_rows direction_to_face_taunter = .SOUTH;
    else if taunter_tile_id == dwarf_tile_id + 1          direction_to_face_taunter = .EAST;
    else if taunter_tile_id == dwarf_tile_id - 1          direction_to_face_taunter = .WEST;
    else assert(false);

    array_reset(*dwarves[dwarf_index].tile_ids_on_path);
    dwarves[dwarf_index].state     = .ATTACKING;
    dwarves[dwarf_index].direction = direction_to_face_taunter;
}

move_one_step_towards_its_next_target_cardinal :: (entity: *$T/interface Moveable, speed: int, dt_seconds: float) {
    target_pos := get_tile_pos_by_id(entity.tile_ids_on_path[0]);
    step_size  := cast(float) speed * dt_seconds;

    // Since movement is strictly cardinal, we only need to change X *or* Y.
    // (i.e. no vectors, no normalization, no square roots).
    if entity.pos.x < target_pos.x {
        entity.pos.x += step_size;
    } else if entity.pos.x > target_pos.x {
        entity.pos.x -= step_size;
    } else if entity.pos.y < target_pos.y {
        entity.pos.y += step_size;
    } else if entity.pos.y > target_pos.y {
        entity.pos.y -= step_size;
    } else {
        assert_soft(false, "Entity % had nowhere to go, even though it should have", entity.id);
    }
}

set_entity_direction_to_face_next_target :: (entity: *$T/interface Moveable) {
    assert_soft(entity.tile_ids_on_path.count > 0, "Tried setting entity % direction to face next target, but entity has no target.\n", entity.id);

    target_tile_id   := entity.tile_ids_on_path[0];
    previous_tile_id := get_previous_tile_id(entity);

    assert_soft(
        target_tile_id != previous_tile_id,
        "entity % is softlocked trying to get it the id it's already on, I think. that, or this was called before the entity moved.\n",
        entity.id
    );

    if      target_tile_id == previous_tile_id - xx context.world_rows entity.direction = .NORTH;
    else if target_tile_id == previous_tile_id + xx context.world_rows entity.direction = .SOUTH;
    else if target_tile_id == previous_tile_id + 1          entity.direction = .EAST;
    else if target_tile_id == previous_tile_id - 1          entity.direction = .WEST;
    else assert(false);
}

create_gold_particle :: (pos: Vector2, amount: int) -> Particle {
    particle_id  := increment_then_read(*particle_id_counter);

    particle := Particle.{
        id                = particle_id,
        pos               = pos,
        vel               = Vector2.{ 0.0, PARTICLE_FLOAT_SPEED },
        tint              = ifx amount < 0 then RED else GREEN,
        text              = sprint("%", amount),
        fade              = false,
        opacity           = 1,
        time_left_ms      = PARTICLE_GOLD_TIME_TO_LIVE_MS,
        sprite_source_row = PARTICLE_GOLD_SPRITE_SOURCE_ROW,
        sprite_source_col = PARTICLE_GOLD_SPRITE_SOURCE_COL,
    };

    table_set(*particle_id_to_index, particle_id, particles.count);
    array_add(*particles, particle);

    return particle;
}

create_dwarf_death_particle :: (pos: Vector2) -> Particle {
    particle_id  := increment_then_read(*particle_id_counter);

    particle := Particle.{
        id                = particle_id,
        pos               = pos,
        vel               = Vector2.{ 0.0, PARTICLE_FLOAT_SPEED },
        tint              = WHITE,
        fade              = true,
        opacity           = 1,
        time_left_ms      = PARTICLE_DWARF_DEATH_TIME_TO_LIVE_MS,
        sprite_source_row = PARTICLE_DWARF_DEATH_SPRITE_SOURCE_ROW,
        sprite_source_col = PARTICLE_DWARF_DEATH_SPRITE_SOURCE_COL,
        // text
    };

    table_set(*particle_id_to_index, particle_id, particles.count);
    array_add(*particles, particle);

    return particle;
}

create_goblin_death_particle :: (pos: Vector2) -> Particle {
    particle_id  := increment_then_read(*particle_id_counter);

    particle := Particle.{
        id                = particle_id,
        pos               = pos,
        vel               = Vector2.{ 0.0, PARTICLE_FLOAT_SPEED },
        tint              = WHITE,
        fade              = true,
        opacity           = 1,
        time_left_ms      = PARTICLE_GOBLIN_DEATH_TIME_TO_LIVE_MS,
        sprite_source_row = PARTICLE_GOBLIN_DEATH_SPRITE_SOURCE_ROW,
        sprite_source_col = PARTICLE_GOBLIN_DEATH_SPRITE_SOURCE_COL,
        // text
    };

    table_set(*particle_id_to_index, particle_id, particles.count);
    array_add(*particles, particle);

    return particle;
}

create_dwarf_aggro_particle :: (pos: Vector2, dwarf_id: s32) -> Particle {
    particle_id  := increment_then_read(*particle_id_counter);

    particle := Particle.{
        id                    = particle_id,
        pos                   = pos,
        vel                   = Vector2.{ 0.0, 0.0 },
        tint                  = WHITE,
        fade                  = false,
        opacity               = 1,
        time_left_ms          = PARTICLE_DWARF_AGGRO_TIME_TO_LIVE_MS,
        sprite_source_row     = PARTICLE_DWARF_AGGRO_SPRITE_SOURCE_ROW,
        sprite_source_col     = PARTICLE_DWARF_AGGRO_SPRITE_SOURCE_COL,
        entity_id_to_follow   = dwarf_id,
        entity_kind_to_follow = .Dwarf,
        // text
    };

    table_set(*particle_id_to_index, particle_id, particles.count);
    array_add(*particles, particle);

    return particle;
}

create_dwarf_selected_particle :: (pos: Vector2, dwarf_id: s32) -> Particle {
    particle_id  := increment_then_read(*particle_id_counter);

    particle := Particle.{
        id                    = particle_id,
        pos                   = pos,
        vel                   = Vector2.{ 0.0, 0.0 },
        tint                  = WHITE,
        fade                  = false,
        opacity               = 1,
        time_left_ms          = PARTICLE_DWARF_SELECTED_TIME_TO_LIVE_MS, // This really should just be infinite
        sprite_source_row     = PARTICLE_DWARF_SELECTED_SPRITE_SOURCE_ROW,
        sprite_source_col     = PARTICLE_DWARF_SELECTED_SPRITE_SOURCE_COL,
        entity_id_to_follow   = dwarf_id,
        entity_kind_to_follow = .Dwarf,
        // text
    };

    table_set(*particle_id_to_index, particle_id, particles.count);
    array_add(*particles, particle);

    return particle;
}

create_damage_particles :: (pos: Vector2, amount: int, direction_stars_should_fly: Direction) {
    // Damage text
    {
        particle_id  := increment_then_read(*particle_id_counter);

        particle := Particle.{
            id                    = particle_id,
            pos                   = pos,
            vel                   = Vector2.{ 0.0, PARTICLE_FLOAT_SPEED },
            text                  = sprint("%", amount),
            tint                  = RED,
            fade                  = true,
            opacity               = 1,
            time_left_ms          = PARTICLE_DAMAGE_TIME_TO_LIVE_MS,
            sprite_source_row     = -1,
            sprite_source_col     = -1,
        };

        table_set(*particle_id_to_index, particle_id, particles.count);
        array_add(*particles, particle);
    }

    // Damage star 1
    {
        particle_id  := increment_then_read(*particle_id_counter);

        secondary_speed_modifier := random_get_within_range(-0.1, 0.1);

        velocity     : Vector2;
        acceleration : Vector2;
        if direction_stars_should_fly == {
            case .NORTH;
                velocity = Vector2.{
                    PARTICLE_DAMAGE_STAR_STARTING_SPEED * secondary_speed_modifier,
                    PARTICLE_DAMAGE_STAR_STARTING_SPEED * -1,
                };
            case .SOUTH;
                velocity = Vector2.{
                    PARTICLE_DAMAGE_STAR_STARTING_SPEED * secondary_speed_modifier,
                    PARTICLE_DAMAGE_STAR_STARTING_SPEED * 1,
                };
            case .EAST; 
                velocity = Vector2.{
                    PARTICLE_DAMAGE_STAR_STARTING_SPEED * 1,
                    PARTICLE_DAMAGE_STAR_STARTING_SPEED * secondary_speed_modifier,
                };
            case .WEST; 
                velocity = Vector2.{
                    PARTICLE_DAMAGE_STAR_STARTING_SPEED * -1,
                    PARTICLE_DAMAGE_STAR_STARTING_SPEED * secondary_speed_modifier,
                };
            case;
                assert_soft(false, "When creating damage star particles, got a weird direction for them to fly. Expected a cardinal direction, but got %\n", direction_stars_should_fly);
        }

        particle := Particle.{
            id                = particle_id,
            pos               = pos,
            vel               = velocity,
            damp              = 0.95,
            tint              = WHITE,
            fade              = true,
            opacity           = 1,
            time_left_ms      = PARTICLE_DAMAGE_STAR_TIME_TO_LIVE_MS,
            sprite_source_row = PARTICLE_DAMAGE_STAR_SPRITE_SOURCE_ROW,
            sprite_source_col = PARTICLE_DAMAGE_STAR_SPRITE_SOURCE_COL,
        };

        table_set(*particle_id_to_index, particle_id, particles.count);
        array_add(*particles, particle);
    }

    // Damage star 2
    {
        particle_id  := increment_then_read(*particle_id_counter);

        secondary_speed_modifier := random_get_within_range(-0.2, 0.2);

        velocity     : Vector2;
        acceleration : Vector2;
        if direction_stars_should_fly == {
            case .NORTH;
                velocity = Vector2.{
                    PARTICLE_DAMAGE_STAR_STARTING_SPEED * secondary_speed_modifier,
                    PARTICLE_DAMAGE_STAR_STARTING_SPEED * -1,
                };
            case .SOUTH;
                velocity = Vector2.{
                    PARTICLE_DAMAGE_STAR_STARTING_SPEED * secondary_speed_modifier,
                    PARTICLE_DAMAGE_STAR_STARTING_SPEED * 1,
                };
            case .EAST; 
                velocity = Vector2.{
                    PARTICLE_DAMAGE_STAR_STARTING_SPEED * 1,
                    PARTICLE_DAMAGE_STAR_STARTING_SPEED * secondary_speed_modifier,
                };
            case .WEST; 
                velocity = Vector2.{
                    PARTICLE_DAMAGE_STAR_STARTING_SPEED * -1,
                    PARTICLE_DAMAGE_STAR_STARTING_SPEED * secondary_speed_modifier,
                };
            case;
                assert_soft(false, "When creating damage star particles, got a weird direction for them to fly. Expected a cardinal direction, but got %\n", direction_stars_should_fly);
        }

        particle := Particle.{
            id                = particle_id,
            pos               = pos,
            vel               = velocity,
            damp              = 0.95,
            tint              = WHITE,
            fade              = true,
            opacity           = 1,
            time_left_ms      = PARTICLE_DAMAGE_STAR_TIME_TO_LIVE_MS,
            sprite_source_row = PARTICLE_DAMAGE_STAR_SPRITE_SOURCE_ROW,
            sprite_source_col = PARTICLE_DAMAGE_STAR_SPRITE_SOURCE_COL,
        };

        table_set(*particle_id_to_index, particle_id, particles.count);
        array_add(*particles, particle);
    }
}

create_miss_particles :: (pos: Vector2) {
    particle_id  := increment_then_read(*particle_id_counter);

    particle := Particle.{
        id                    = particle_id,
        pos                   = pos,
        vel                   = Vector2.{ 0.0, PARTICLE_FLOAT_SPEED },
        text                  = "Miss",
        tint                  = RED,
        fade                  = true,
        opacity               = 1,
        time_left_ms          = PARTICLE_DAMAGE_TIME_TO_LIVE_MS,
        sprite_source_row     = -1,
        sprite_source_col     = -1,
    };

    table_set(*particle_id_to_index, particle_id, particles.count);
    array_add(*particles, particle);
}

create_dwarf :: (pos: Vector2, dwarf_type: DwarfType) -> Dwarf {
    dwarf_id   := increment_then_read(*entity_id_counter);
    direction  := cast(Direction) cast(int) random_get_within_range(0, 3);

    dwarf_miner_animated_sprite_base := AnimatedSprite.{
        texture     = dwarf_miner_texture,
        active      = false,
        first_frame = 0,
        color       = WHITE,
        rotation    = 0.0,
        frame_count       = 8,
        frame_duration_ms = 100,
        timer_ms          = 0,
        loops             = true,
    };

    dwarf_miner_animated_sprite_idle := dwarf_miner_animated_sprite_base;
    dwarf_miner_animated_sprite_idle.first_frame = 0;
    dwarf_miner_animated_sprite_idle.active = true;

    dwarf_miner_animated_sprite_walk := dwarf_miner_animated_sprite_base;
    dwarf_miner_animated_sprite_walk.first_frame = 8;

    dwarf_miner_animated_sprite_mine := dwarf_miner_animated_sprite_base;
    dwarf_miner_animated_sprite_mine.first_frame = 16;

    dwarf_miner_animated_sprite_die := dwarf_miner_animated_sprite_base;
    dwarf_miner_animated_sprite_die.first_frame = 40;

    animations := AnimatedSprite.[
        dwarf_miner_animated_sprite_idle,
        dwarf_miner_animated_sprite_walk,
        dwarf_miner_animated_sprite_mine,
        dwarf_miner_animated_sprite_die,
    ];

    dwarf := Dwarf.{
        id                    = dwarf_id,
        pos                   = pos,
        hp                    = dwarf_starting_hp_by_type(dwarf_type),
        state                 = .DECIDING,
        animations            = animations,
        direction             = direction,
        dwarf_type            = dwarf_type,
        tile_id_mining        = 0,
        goblin_id_attacking   = 0,
        attack_cooldown_ms    = dwarf_get_attack_cooldown_by_type(dwarf_type),
        is_facing_left        = false,
        // direction intentionally not set
        // tile_ids_on_path intentionally not set
    };

    dwarf_tile_id := get_tile_id_by_pos(pos);
    // TODO
    // chunk := find_or_create_chunk_by_tile_id(dwarf_tile_id);
    // array_add(*chunk.dwarf_ids, dwarf_id);
    table_set(*dwarf_id_to_index, dwarf_id, dwarves.count);
    array_add(*dwarves, dwarf);

    return dwarf;
}

create_goblin :: (pos: Vector2) -> Goblin {
    goblin_id := increment_then_read(*entity_id_counter);
    // direction := cast(Direction) cast(int) random_get_within_range(0, 3);

    goblin := Goblin.{
        id        = goblin_id,
        pos       = pos,
        hp        = GOBLIN_STARTING_HP,
        state     = .DECIDING,
        direction = .NORTH,
        // tile_ids_on_path intentionally not set
        attack_cooldown_ms = GOBLIN_ATTACK_COOLDOWN_MS,
    };

    tile_id := get_tile_id_by_pos(pos);
    // chunk := find_or_create_chunk_by_tile_id(dwarf_tile_id);
    // array_add(*chunk.dwarf_ids, dwarf_id);
    table_set(*goblin_id_to_index, goblin_id, goblins.count);
    array_add(*goblins, goblin);

    return goblin;
}

create_base :: (pos: Vector2, is_home_base: bool, game_state: *GameState) -> Base {
    base_id := increment_then_read(*entity_id_counter);

    base := Base.{
        id  = base_id,
        pos = pos,
        spawn_dwarf_cooldown_ms = DWARF_MINER_SPAWN_MS,
        is_home_base = is_home_base,
        hp = 1000
    };

    base_tile_id := get_tile_id_by_pos(base.pos);
    _result, chunk := find_or_create_chunk_by_tile_id(base_tile_id);
    array_add(*chunk.base_ids, base_id);

    table_set(*base_id_to_index, base_id, bases.count);
    array_add(*bases, base);

    // Give a little breathing room with caves for the home base
    if is_home_base {
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

    // Carve out some tiles around the base (including the base tile itself)
    for DIRECTIONS_ALL {
        tile_id := get_neighbor_tile_id_by_direction(base_tile_id, it);
        set_tile_as_type(tile_id, .MINED, false, false, game_state);
        reveal_cave_if_necessary(tile_id, false, false, game_state);
    }

    return base;
}

game_over_if_touching_home_base :: (tile_id: s32) {
    kill_pos  := get_tile_pos_by_id(tile_id);
    kill_rect := Rectangle.{ kill_pos.x, kill_pos.y, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT };
    // PERF: can just save home base id at start up
    for base: bases {
        if !base.is_home_base continue;

        home_base_rect := Rectangle.{ base.pos.x, base.pos.y, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT };
        if CheckCollisionRecs(home_base_rect, kill_rect) {
            metagame.state = .GAME_OVER;
        }
    }
}

// PERF: this functions looks pretty brutal
kill_any_dwarves_touching_tile_id :: (tile_id: s32) {
    kill_pos  := get_tile_pos_by_id(tile_id);
    kill_rect := Rectangle.{ kill_pos.x, kill_pos.y, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT };
    for dwarf, dwarf_index: dwarves {
        dwarf_rect := Rectangle.{ dwarf.pos.x, dwarf.pos.y, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT };
        if CheckCollisionRecs(dwarf_rect, kill_rect) {
            kill_dwarf_by_index(dwarf_index);
        }
    }
}

// PERF: this functions looks pretty brutal
kill_any_goblins_touching_tile_id :: (tile_id: s32) {
    kill_pos  := get_tile_pos_by_id(tile_id);
    kill_rect := Rectangle.{ kill_pos.x, kill_pos.y, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT };
    for goblin, goblin_index: goblins {
        goblin_rect := Rectangle.{ goblin.pos.x, goblin.pos.y, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT };
        if CheckCollisionRecs(goblin_rect, kill_rect) {
            kill_goblin_by_index(goblin_index);
        }
    }
}

// PERF: this functions looks pretty brutal
kill_any_dynamite_touching_tile_id :: (tile_id: s32) {
    kill_pos  := get_tile_pos_by_id(tile_id);
    kill_rect := Rectangle.{ kill_pos.x, kill_pos.y, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT };
    for dynamite_tile_id, dynamite_index: tiles_with_dynamite_ids {
        dynamite_pos := get_tile_pos_by_id(dynamite_tile_id);
        dynamite_rect := Rectangle.{ dynamite_pos.x, dynamite_pos.y, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT };
        if CheckCollisionRecs(dynamite_rect, kill_rect) {
            array_unordered_remove_by_value(*tiles_with_dynamite_ids, tile_id);
        }
    }
}

kill_particle_by_index :: (particle_index: s64) {
    particle_id_being_swapped := particles[particles.count - 1].id;
    particle_id_being_killed  := particles[particle_index].id;

    if particle_id_being_swapped != particle_id_being_killed {
        table_set(*particle_id_to_index, particle_id_being_swapped, particle_index);
    }
    table_remove(*particle_id_to_index, particle_id_being_killed);

    array_unordered_remove_by_index(*particles, particle_index);
}

kill_particle_by_id :: (particle_id: s32) {
    found, particle_index := table_find(*particle_id_to_index, particle_id);
    assert(found);
    kill_particle_by_index(particle_index);
}

// TODO: refactor to entity probably
kill_dwarf_by_index :: (dwarf_index: s64) {
    dwarf_being_swapped_id := dwarves[dwarves.count - 1].id;
    dwarf_being_killed_id  := dwarves[dwarf_index].id;
    dwarf_being_killed_pos := dwarves[dwarf_index].pos;

    if dwarf_being_swapped_id != dwarf_being_killed_id {
        table_set(*dwarf_id_to_index, dwarf_being_swapped_id, dwarf_index);
    }
    table_remove(*dwarf_id_to_index, dwarf_being_killed_id);

    create_dwarf_death_particle(dwarf_being_killed_pos);

    array_unordered_remove_by_index(*dwarves, dwarf_index);
}

kill_dwarf_by_id :: (dwarf_id: s32) {
    found, dwarf_index := table_find(*dwarf_id_to_index, dwarf_id);
    assert(found);
    kill_dwarf_by_index(dwarf_index);
}

// TODO: refactor to entity probably
kill_goblin_by_index :: (goblin_index: s64) {
    goblin_being_swapped_id := goblins[goblins.count - 1].id;
    goblin_being_killed_id  := goblins[goblin_index].id;
    goblin_being_killed_pos := goblins[goblin_index].pos;

    if goblin_being_swapped_id != goblin_being_killed_id {
        table_set(*goblin_id_to_index, goblin_being_swapped_id, goblin_index);
    }
    table_remove(*goblin_id_to_index, goblin_being_killed_id);

    create_goblin_death_particle(goblin_being_killed_pos);

    array_unordered_remove_by_index(*goblins, goblin_index);
}

kill_goblin_by_id :: (goblin_id: s32) {
    found, goblin_index := table_find(*goblin_id_to_index, goblin_id);
    assert(found);
    kill_goblin_by_index(goblin_index);
}

// TODO: refactor to entity probably
kill_base_by_index :: (base_index: s64) {
    base_being_killed := bases[base_index];
    if base_being_killed.is_home_base {
        metagame.state = .GAME_OVER;
    }

    base_id_being_swapped := bases[bases.count - 1].id;
    base_id_being_killed  := bases[base_index].id;

    tile_id_of_base_being_killed := get_tile_id_by_pos(base_being_killed.pos);

    _result, chunk := find_or_create_chunk_by_tile_id(tile_id_of_base_being_killed);
    array_unordered_remove_by_value(*chunk.base_ids, base_id_being_killed);

    if base_id_being_swapped != base_id_being_killed {
        table_set(*base_id_to_index, base_id_being_swapped, base_index);
    }
    table_remove(*base_id_to_index, base_id_being_killed);

    array_unordered_remove_by_index(*bases, base_index);
}

kill_base_by_id :: (base_id: s32) {
    found, base_index := table_find(*base_id_to_index, base_id);
    assert(found);
    kill_base_by_index(base_index);
}

// get_neighbor_tile_id_by_index :: (tile_id: s32, direction_index: s64) -> s32 {
//     dx := get_tile_direction_id_deltas(direction_index)[0];
//     dy := get_tile_direction_id_deltas(direction_index)[1];
//     return tile_id + dx + dy;
// }

get_neighbor_tile_id_by_direction :: (tile_id: s32, direction: Direction) -> s32 {
    dx := get_tile_direction_id_deltas(direction)[0];
    dy := get_tile_direction_id_deltas(direction)[1];
    return tile_id + dx + dy;
}

get_neighbor_tile_ids :: (tile_id: s32) -> [..] s32 {
    neighbor_tile_ids : [..] s32;
    neighbor_tile_ids.allocator = temp;

    for DIRECTIONS_CARDINAL {
        array_add(*neighbor_tile_ids, get_neighbor_tile_id_by_direction(tile_id, it));
    }

    return neighbor_tile_ids;
}

is_tile_id_fully_mined :: (tile_id: s32) -> bool {
    return table_contains(*fully_mined_tile_ids_set, tile_id);
}

is_tile_id_actively_mined :: (tile_id: s32) -> bool {
    return table_contains(*actively_mined_tile_ids_to_health_table, tile_id);
}

is_tile_id_cave :: (tile_id: s32) -> bool {
    return table_contains(*cave_tile_ids_set, tile_id);
}

is_tile_id_encased :: (tile_id: s32) -> bool {
    return table_contains(*encased_tile_ids_set, tile_id);
}

is_tile_id_iron :: (tile_id: s32) -> bool {
    return table_contains(*iron_tile_ids_set, tile_id);
}

is_tile_id_water_still :: (tile_id: s32) -> bool {
    return table_contains(*water_still_tile_ids_to_sprite, tile_id);
}

is_tile_id_water_flowing :: (tile_id: s32) -> bool {
    return table_contains(*water_flowing_tile_ids_to_sprite, tile_id);
}

is_tile_id_lava_still :: (tile_id: s32) -> bool {
    return table_contains(*lava_still_tile_ids_set, tile_id);
}

is_tile_id_lava_flowing :: (tile_id: s32) -> bool {
    return table_contains(*lava_flowing_tile_ids_to_sprite, tile_id);
}

is_tile_id_obsidian :: (tile_id: s32) -> bool {
    return table_contains(*obsidian_tile_ids_set, tile_id);
}

is_tile_id_wall :: (tile_id: s32) -> bool {
    return table_contains(*wall_tile_ids_set, tile_id);
}

is_tile_id_hole :: (tile_id: s32) -> bool {
    return table_contains(*hole_tile_ids_set, tile_id);
}

is_tile_id_dirt :: (tile_id: s32) -> bool {
    // TODO: is there some way I can have a metaprogram do some sort of #complete on
    // a generated enum of these? I just realized I missed is_hole in this boolean,
    // and I would like a way to know I'm not missing anything from this list at 
    // compile time.
    return (
        !is_tile_id_fully_mined(tile_id)   &&
        !is_tile_id_cave(tile_id)          && 
        !is_tile_id_iron(tile_id)          && 
        !is_tile_id_water_still(tile_id)   && 
        !is_tile_id_water_flowing(tile_id) && 
        !is_tile_id_lava_still(tile_id)    && 
        !is_tile_id_lava_flowing(tile_id)  && 
        !is_tile_id_obsidian(tile_id)      &&
        !is_tile_id_wall(tile_id)          &&
        !is_tile_id_hole(tile_id)
    );
}

does_tile_id_need_wall_sprites :: (tile_id: s32) -> bool {
    return (
        is_tile_id_cave(tile_id)          ||
        is_tile_id_fully_mined(tile_id)   ||
        is_tile_id_water_still(tile_id)   ||
        is_tile_id_water_flowing(tile_id) ||
        is_tile_id_lava_still(tile_id)    ||
        is_tile_id_lava_flowing(tile_id)
    );
}

// TODO: entity kind, probably
is_tile_id_walkable :: (tile_id: s32) -> bool {
    found_dwarf := table_contains(*tile_ids_to_dwarfs, tile_id);
    if found_dwarf return false;

    found_goblin := table_contains(*tile_ids_to_goblins, tile_id);
    if found_goblin return false;

    return (
        is_tile_id_fully_mined(tile_id)   ||
        is_tile_id_water_still(tile_id)   ||
        is_tile_id_water_flowing(tile_id) ||
        is_tile_id_lava_still(tile_id)    ||
        is_tile_id_lava_flowing(tile_id)
    );
}

// TODO: entity kind, probably
is_tile_id_walkable_for_entity :: (tile_id: s32, entity_id: s32) -> bool {
    found_dwarf, dwarf := table_find(*tile_ids_to_dwarfs, tile_id);
    if found_dwarf && dwarf.id != entity_id return false;

    found_goblin, goblin := table_find(*tile_ids_to_goblins, tile_id);
    if found_goblin && goblin.id != entity_id return false;

    return (
        is_tile_id_fully_mined(tile_id)   ||
        is_tile_id_water_still(tile_id)   ||
        is_tile_id_water_flowing(tile_id) ||
        is_tile_id_lava_still(tile_id)    ||
        is_tile_id_lava_flowing(tile_id)
    );
}

is_tile_id_mineable :: (tile_id: s32) -> bool {
    return (
        is_tile_id_dirt(tile_id) ||
        is_tile_id_iron(tile_id) ||
        is_tile_id_wall(tile_id)
    );
}

is_tile_id_walkable_or_mineable :: (tile_id: s32) -> bool {
    return is_tile_id_walkable(tile_id) || is_tile_id_mineable(tile_id);
}

is_tile_id_walkable_or_mineable_for_entity :: (tile_id: s32, entity_id: s32) -> bool {
    return is_tile_id_walkable_for_entity(tile_id, entity_id) || is_tile_id_mineable(tile_id);
}

get_neighbor_tile_ids_of_type :: (tile_id: s32, tile_type: TileType) -> [..] s32 {
    neighbor_tile_ids : [..] s32;
    neighbor_tile_ids.allocator = temp;
    
    dx, dy : s32;

    for DIRECTIONS_COMPASS {
        dx = get_tile_direction_id_deltas(it)[0];
        dy = get_tile_direction_id_deltas(it)[1];

        neighbor_id := tile_id + dx + dy;

        should_add_neighbor_to_list := false;
        if #complete tile_type == {
            case .DIRT;          should_add_neighbor_to_list = is_tile_id_dirt(neighbor_id);
            case .MINED;         should_add_neighbor_to_list = is_tile_id_fully_mined(neighbor_id);
            case .CAVE;          should_add_neighbor_to_list = is_tile_id_cave(neighbor_id);
            case .ENCASED;       should_add_neighbor_to_list = is_tile_id_encased(neighbor_id);
            case .WATER_STILL;   should_add_neighbor_to_list = is_tile_id_water_still(neighbor_id);
            case .WATER_FLOWING; should_add_neighbor_to_list = is_tile_id_water_flowing(neighbor_id);
            case .LAVA_STILL;    should_add_neighbor_to_list = is_tile_id_lava_still(neighbor_id);
            case .LAVA_FLOWING;  should_add_neighbor_to_list = is_tile_id_lava_flowing(neighbor_id);
            case .IRON;          should_add_neighbor_to_list = is_tile_id_iron(neighbor_id);
            case .OBSIDIAN;      should_add_neighbor_to_list = is_tile_id_obsidian(neighbor_id);
            case .WALL;          should_add_neighbor_to_list = is_tile_id_wall(neighbor_id);
            case .HOLE;          should_add_neighbor_to_list = is_tile_id_hole(neighbor_id);
        }

        if should_add_neighbor_to_list array_add(*neighbor_tile_ids, neighbor_id);
    }

    return neighbor_tile_ids;
}

handle_encasement :: (tile_id: s32, game_state: *GameState) {
    encasing_obsidian_tile_ids_set: Table(s32, s32);
    did_encase := check_encasement(tile_id, *encasing_obsidian_tile_ids_set);

    // If we did encase a section, find the inside portion that is encased.
    // Start by casting a ray north, the first tile *needs* to be non-obsidian. If it isn't,
    // cast in the next cardinal direction. Once we find a cardinal direction that starts
    // with non-obsidian, go until out of bounds. Tally up the amount of times we intersect
    // *visited* obsidian tiles. If the crossings is odd, then this direction is inside the
    // encasement. If it is even, it is not.
    if did_encase {
        // We may have multiple directions of encasement. Consider a block being placed in
        // the middle of two, three, or even four diamonds that were only missing the spot
        // that was just placed.
        directions_of_encasement: [..] Direction;
        directions_of_encasement.allocator = temp;

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

            if encasing_hits % 2 == 1 then array_add(*directions_of_encasement, cast(Direction) i);
        }

        for directions_of_encasement {
            tile_to_start_encasing_id := tile_id;
            if it == .NORTH tile_to_start_encasing_id -= xx context.world_cols;
            if it == .SOUTH tile_to_start_encasing_id += xx context.world_cols;
            if it == .EAST  tile_to_start_encasing_id += 1;
            if it == .WEST  tile_to_start_encasing_id -= 1;

            try_to_encase_tiles(tile_to_start_encasing_id, game_state);
        }
    }
}

check_encasement :: (tile_id: s32, encasing_obsidian_tile_ids_set: *Table) -> (did_encase: bool) {
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
                cycle_points.allocator = temp;
                
                // Only build the cycle points first
                for tile: path {
                    array_add(*cycle_points, get_tile_pos_by_id(tile));
                }

                // If it actually has volume, THEN add it to the encasement table
                if check_interior_volume(cycle_points) > 0 {
                    for tile: path {
                        table_set(encasing_obsidian_tile_ids_set, tile, 1738);
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
    path.allocator = temp;

    found_at_least_one_hole := false;

    // Track which tiles we've seen so we don't loop infinitely
    visited: Table(s32, bool);
    visited.allocator = temp;
    // defer deinit(*visited);

    // Track the "parent" of each tile to reconstruct the path later
    came_from: Table(s32, s32);
    came_from.allocator = temp;
    // defer deinit(*came_from);

    // The BFS queue
    queue: [..] s32;
    queue.allocator = temp;
    // defer array_free(queue);

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

        for DIRECTIONS_COMPASS {
            dx := get_tile_direction_id_deltas(it)[0];
            dy := get_tile_direction_id_deltas(it)[1];
            
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

try_to_encase_tiles :: (starting_tile_id: s32, game_state: *GameState) {
    found_liquid: bool = false;

    ids_processed: Table(s32, s32);
    ids_processed.allocator = temp;

    ids_to_process: [..] s32;
    ids_to_process.allocator = temp;

    encased_ids: [..] s32;
    encased_ids.allocator = temp;

    array_add(*ids_to_process, starting_tile_id);

    while ids_to_process.count > 0 {
        // Get the next id to process
        id := pop_front_unordered_fast(*ids_to_process);

        // Make sure the id is valid and hasn't already been processed
        id_already_processed := table_contains(*ids_processed, id);
        if id_already_processed continue;
        if table_contains(*obsidian_tile_ids_set, id) continue;
        if table_contains(*hole_tile_ids_set, id) continue;

        // Check if this tile is liquid
        if table_contains(*water_still_tile_ids_to_sprite, id) {
            found_liquid = true;
        }

        if table_contains(*water_flowing_tile_ids_to_sprite, id) {
            found_liquid = true;
            set_tile_as_type(id, .WATER_STILL, false, false, game_state);
        }

        if table_contains(*lava_still_tile_ids_set, id) {
            found_liquid = true;
        }

        if table_contains(*lava_flowing_tile_ids_to_sprite, id) {
            found_liquid = true;
            set_tile_as_type(id, .LAVA_STILL, false, false, game_state);
        }

        // Mark it as processed and encased
        array_add(*encased_ids, id);
        table_set(*ids_processed, id, 1738);

        // Add neighbors as needing to be processed
        array_add(*ids_to_process, id - xx context.world_cols);
        array_add(*ids_to_process, id + xx context.world_cols);
        array_add(*ids_to_process, id + 1);
        array_add(*ids_to_process, id - 1);
    }

    // If we found a liquid, mark the tiles as encased
    if found_liquid {
        for encased_ids {
            _result, chunk := find_or_create_chunk_by_tile_id(it);
            array_add(*chunk.encased_tile_ids, it);
            table_set(*encased_tile_ids_set, it, 1738);
        }
    }
}

are_all_neighbors_unable_to_be_spread_to :: (tile_id: s32) -> bool {
    north_tile_id : s32 = tile_id - xx context.world_rows;
    south_tile_id : s32 = tile_id + xx context.world_rows;
    east_tile_id  : s32 = tile_id + 1;
    west_tile_id  : s32 = tile_id - 1;

    // "Walkable" means "mined and not liquid". "Mineable" means dirt, iron, or wall.
    is_neighbor_north_spreadable := is_tile_id_fully_mined(north_tile_id);
    is_neighbor_south_spreadable := is_tile_id_fully_mined(south_tile_id);
    is_neighbor_east_spreadable  := is_tile_id_fully_mined(east_tile_id);
    is_neighbor_west_spreadable  := is_tile_id_fully_mined(west_tile_id);

    return (
        !is_neighbor_north_spreadable &&
        !is_neighbor_south_spreadable &&
        !is_neighbor_east_spreadable &&
        !is_neighbor_west_spreadable
    );
}

are_all_neighbors_liquid :: (tile_id: s32) -> bool {
    north_tile_id : s32 = tile_id - xx context.world_rows;
    south_tile_id : s32 = tile_id + xx context.world_rows;
    east_tile_id  : s32 = tile_id + 1;
    west_tile_id  : s32 = tile_id - 1;

    is_neighbor_north_water_still := table_contains(*water_still_tile_ids_to_sprite, north_tile_id);
    is_neighbor_south_water_still := table_contains(*water_still_tile_ids_to_sprite, south_tile_id);
    is_neighbor_east_water_still  := table_contains(*water_still_tile_ids_to_sprite, east_tile_id);
    is_neighbor_west_water_still  := table_contains(*water_still_tile_ids_to_sprite, west_tile_id);

    is_neighbor_north_water_flowing := table_contains(*water_flowing_tile_ids_to_sprite, north_tile_id);
    is_neighbor_south_water_flowing := table_contains(*water_flowing_tile_ids_to_sprite, south_tile_id);
    is_neighbor_east_water_flowing  := table_contains(*water_flowing_tile_ids_to_sprite, east_tile_id);
    is_neighbor_west_water_flowing  := table_contains(*water_flowing_tile_ids_to_sprite, west_tile_id);

    is_neighbor_north_lava_still := table_contains(*lava_still_tile_ids_set, north_tile_id);
    is_neighbor_south_lava_still := table_contains(*lava_still_tile_ids_set, south_tile_id);
    is_neighbor_east_lava_still  := table_contains(*lava_still_tile_ids_set, east_tile_id);
    is_neighbor_west_lava_still  := table_contains(*lava_still_tile_ids_set, west_tile_id);

    is_neighbor_north_lava_flowing := table_contains(*lava_flowing_tile_ids_to_sprite, north_tile_id);
    is_neighbor_south_lava_flowing := table_contains(*lava_flowing_tile_ids_to_sprite, south_tile_id);
    is_neighbor_east_lava_flowing  := table_contains(*lava_flowing_tile_ids_to_sprite, east_tile_id);
    is_neighbor_west_lava_flowing  := table_contains(*lava_flowing_tile_ids_to_sprite, west_tile_id);

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

try_to_set_cardinal_neighbors_as_flowing_tile_type :: (tile_id: s32, as_type: TileType, game_state: *GameState) -> (directions_flowed: [4] bool) {
    directions_flowed := bool.[false, false, false, false];

    for DIRECTIONS_CARDINAL {
        neighbor_id := get_neighbor_tile_id_by_direction(tile_id, it);

        // TODO: this is kind of terrible because if/when I add new things, I'm going to have to remember
        // to add them here. Would be good to have this automated somehow.

        tile_is_still_water := table_contains(*water_still_tile_ids_to_sprite, neighbor_id);
        if tile_is_still_water continue;

        tile_is_still_lava := table_contains(*lava_still_tile_ids_set, neighbor_id);
        if tile_is_still_lava continue;

        tile_is_flowing_water := table_contains(*water_flowing_tile_ids_to_sprite, neighbor_id);

        tile_is_flowing_lava := table_contains(*lava_flowing_tile_ids_to_sprite, neighbor_id);

        tile_is_iron := table_contains(*iron_tile_ids_set, neighbor_id);
        if tile_is_iron continue;

        tile_is_obsidian := table_contains(*obsidian_tile_ids_set, neighbor_id);
        if tile_is_obsidian continue;

        // If the tile is a wall and you are lava, damage it a bit.
        tile_is_wall := table_contains(*wall_tile_ids_set, neighbor_id);
        as_lava := as_type == .LAVA_STILL || as_type == .LAVA_FLOWING;

        if tile_is_wall && as_lava {
            found, current_health := table_find(*actively_mined_tile_ids_to_health_table, neighbor_id);
            // If we don't see the wall in the actively mined tile list, then it's full health
            if (!found) current_health = WALL_HEALTH;

            new_health := current_health - LAVA_DAMAGE_PER_HIT;

            if new_health <= 0 {
                set_tile_as_type(neighbor_id, .MINED, false, false, game_state);
            } else {
                table_set(*actively_mined_tile_ids_to_health_table, neighbor_id, new_health);
            }

            continue;
        }

        tile_is_being_mined := table_contains(*actively_mined_tile_ids_to_health_table, neighbor_id);
        if tile_is_being_mined continue;

        tile_is_empty := table_contains(*fully_mined_tile_ids_set, neighbor_id);
        if !tile_is_empty continue;

        set_tile_as_type(neighbor_id, as_type, false, false, game_state);
        directions_flowed[it_index] = true;
    }

    return directions_flowed;
}

FindOrCreateChunkReturnStatus :: enum u16 {
    CHUNK_WOULD_BE_OUT_OF_BOUNDS;
    CHUNK_CREATED;
    CHUNK_FOUND;
}

find_or_create_chunk_by_tile_id :: (tile_id: s32) -> (status: FindOrCreateChunkReturnStatus, chunk: *Chunk) {
    world_pos := get_tile_pos_by_id(tile_id);
    chunk_x   := world_to_chunk_pos(world_pos.x, TILEMAP_GENERAL_WORLD_WIDTH);
    chunk_y   := world_to_chunk_pos(world_pos.y, TILEMAP_GENERAL_WORLD_HEIGHT);
    result, chunk := find_or_create_chunk(chunk_x, chunk_y);
    return result, chunk;
    // if #complete result == {
    //     case .CHUNK_WOULD_BE_OUT_OF_BOUNDS;
    //         assert(false, "Expected to find chunk for tile id %, but didn't!", tile_id);
    //         return null;
    //     case .CHUNK_CREATED; #through;
    //     case .CHUNK_FOUND;
    //         return chunk;
    // }
}

find_or_create_chunk :: (chunk_x: s32, chunk_y: s32) -> (status: FindOrCreateChunkReturnStatus, chunk: *Chunk) {
    key_is_within_map_bounds, key := find_chunk_key(chunk_x, chunk_y);
    if !key_is_within_map_bounds return .CHUNK_WOULD_BE_OUT_OF_BOUNDS, null;

    found_chunk, chunk := table_find(*created_chunks, key);
    if found_chunk return .CHUNK_FOUND, chunk;

    // The chunk doesn't exist yet, so let's make a new one.
    new_chunk := New(Chunk);
    
    table_set(*created_chunks, key, new_chunk);
    
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

get_world_rect_from_pos :: (pos: Vector2) -> Rectangle {
    return Rectangle.{
        pos.x, pos.y, TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT,
    };
}

draw_path :: (path: Path) {
    start_pos := get_tile_pos_by_id(path.start_tile_id);
    end_pos   := get_tile_pos_by_id(get_path_end_tile_id(path));

    ARROW_SOURCE :: Rectangle.{
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

    start_arrow_rotation := get_angle_from_north(start_pos, end_pos);

    DrawTexturePro(tilemap_texture_general, ARROW_SOURCE, start_arrow_dest, Vector2.{ TILEMAP_GENERAL_WORLD_WIDTH * 0.5, TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 }, start_arrow_rotation,  WHITE);
    
    DrawLineEx(
        Vector2.{ start_pos.x + TILEMAP_GENERAL_WORLD_WIDTH * 0.5, start_pos.y + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 },
        Vector2.{ end_pos.x + TILEMAP_GENERAL_WORLD_WIDTH * 0.5, end_pos.y + TILEMAP_GENERAL_WORLD_HEIGHT * 0.5 },
        2.0,
        GREEN
    );

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

get_paths :: (from_pos: Vector2, to_pos: Vector2) -> (path_1: Path, path_2: Path) {
    new_target_tile_rect := get_tile_rect_that_pos_is_within(get_world_width(), get_world_height(), TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, to_pos);
    new_target_tile_pos  := Vector2.{ new_target_tile_rect.x, new_target_tile_rect.y };
    new_target_tile_id   := get_tile_id_by_pos(new_target_tile_pos);

    tile_rect_mouse_started_on := get_tile_rect_that_pos_is_within(get_world_width(), get_world_height(), TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, from_pos);
    tile_pos_mouse_started_on  := get_rect_pos(tile_rect_mouse_started_on);
    tile_id_mouse_started_on   := get_tile_id_by_pos(tile_pos_mouse_started_on);

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
    middle_tile_pos := get_rect_pos(middle_tile_rect);
    middle_tile_id  := get_tile_id_by_pos(middle_tile_pos);

    end_tile_rect := Rectangle.{
        middle_tile_rect.x + ifx x_is_larger then 0 else dx,
        middle_tile_rect.y + ifx x_is_larger then dy else 0,
        TILEMAP_GENERAL_WORLD_WIDTH,
        TILEMAP_GENERAL_WORLD_HEIGHT,
    };
    end_tile_pos := get_rect_pos(end_tile_rect);
    end_tile_id  := get_tile_id_by_pos(end_tile_pos);

    path_1 := Path.{
        start_tile_id = tile_id_mouse_started_on,
        direction     = get_direction_of_vector(tile_pos_mouse_started_on, middle_tile_pos),
        tile_count    = get_tile_id_count_from_tile_to_tile_cardinal(tile_id_mouse_started_on, middle_tile_id),
    };

    path_2 := Path.{
        start_tile_id = middle_tile_id,
        direction     = get_direction_of_vector(middle_tile_pos, end_tile_pos),
        tile_count    = get_tile_id_count_from_tile_to_tile_cardinal(middle_tile_id, end_tile_id),
    };

    return path_1, path_2;
}

get_path_cost :: (path: Path) -> int {
    return path.tile_count * GOLD_COST_PATH_STEP;
}

get_path_end_tile_id :: (path: Path) -> s32 {
    dx := get_tile_direction_id_deltas(path.direction)[0];
    dy := get_tile_direction_id_deltas(path.direction)[1];

    return path.start_tile_id + xx (path.tile_count * dx) + xx (path.tile_count * dy);
}

get_tile_ids_on_path :: (path: Path) -> [..] s32 {
    tile_ids: [..] s32;
    tile_ids.allocator = temp;

    cursor: s32;
    for 0..path.tile_count {
        dx := get_tile_direction_id_deltas(path.direction)[0];
        dy := get_tile_direction_id_deltas(path.direction)[1];

        tile_id := path.start_tile_id + xx (it * dx) + xx (it * dy);

        array_add(*tile_ids, tile_id);
    }

    return tile_ids;
}

get_tile_id_count_from_tile_to_tile_cardinal :: (from_tile_id: s32, to_tile_id: s32) -> int {
    on_same_col, dir_col := are_tile_ids_on_same_world_column(from_tile_id, to_tile_id);
    on_same_row, dir_row := are_tile_ids_on_same_world_row(from_tile_id, to_tile_id);
    
    assert(on_same_col || on_same_row);

    if on_same_col {
        foo := abs(from_tile_id - to_tile_id) * context.world_cols_recip;
        return cast(int) foo;
    }

    if on_same_row {
        return cast(int) abs(from_tile_id - to_tile_id);
    }

    assert(false);
    return -1;
}

are_tile_ids_on_same_world_column :: (tile_id_a: s32, tile_id_b: s32) -> (same: bool, direction: Direction) {
    direction : Direction = ifx tile_id_a < tile_id_b then .NORTH else .SOUTH;
    same := abs(tile_id_a - tile_id_b) % context.world_cols == 0;
    return same, direction;
}

are_tile_ids_on_same_world_row :: (tile_id_a: s32, tile_id_b: s32) -> (same: bool, direction: Direction) {
    direction : Direction = ifx tile_id_a < tile_id_b then .WEST else .EAST;
    same := abs(tile_id_a - tile_id_b) < context.world_cols;
    return same, direction;
}

get_tile_ids_from_pos_to_pos :: (from_pos: Vector2, to_pos: Vector2) -> (path_1_tile_ids: [..] s32, path_2_tile_ids: [..] s32) {
    path_1_tile_ids: [..] s32;
    path_1_tile_ids.allocator = temp;

    path_2_tile_ids: [..] s32;
    path_2_tile_ids.allocator = temp;

    target_rect := get_tile_rect_that_pos_is_within(get_world_width(), get_world_height(), TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, to_pos);
    from_rect   := get_tile_rect_that_pos_is_within(get_world_width(), get_world_height(), TILEMAP_GENERAL_WORLD_WIDTH, TILEMAP_GENERAL_WORLD_HEIGHT, from_pos);

    dx := target_rect.x - from_rect.x;
    dy := target_rect.y - from_rect.y;

    // Determine the step directions in world units
    step_x := ifx dx > 0 then TILEMAP_GENERAL_WORLD_WIDTH  else -TILEMAP_GENERAL_WORLD_WIDTH;
    step_y := ifx dy > 0 then TILEMAP_GENERAL_WORLD_HEIGHT else -TILEMAP_GENERAL_WORLD_HEIGHT;

    // Calculate the number of discrete tile steps required 
    // (+ 0.5 prevents float truncation issues if tile widths aren't perfect integers)
    //
    // TODO: do we really need that 0.5 shit?
    steps_x := cast(int)(abs(dx) / TILEMAP_GENERAL_WORLD_WIDTH + 0.5);
    steps_y := cast(int)(abs(dy) / TILEMAP_GENERAL_WORLD_HEIGHT + 0.5);

    x_is_larger := abs(dx) > abs(dy);

    // Start traversing from the origin of the initial tile
    current_pos := Vector2.{from_rect.x, from_rect.y};

    // 1. Add the starting tile
    array_add(*path_1_tile_ids, get_tile_id_by_pos(current_pos));

    // 2. Traverse the grid, maintaining L-shaped path
    if x_is_larger {
        // Move along X axis first
        for 1..steps_x {
            current_pos.x += step_x;
            array_add(*path_1_tile_ids, get_tile_id_by_pos(current_pos));
        }
        // Then move along Y axis
        for 1..steps_y {
            current_pos.y += step_y;
            array_add(*path_2_tile_ids, get_tile_id_by_pos(current_pos));
        }
    } else {
        // Move along Y axis first
        for 1..steps_y {
            current_pos.y += step_y;
            array_add(*path_1_tile_ids, get_tile_id_by_pos(current_pos));
        }
        // Then move along X axis
        for 1..steps_x {
            current_pos.x += step_x;
            array_add(*path_2_tile_ids, get_tile_id_by_pos(current_pos));
        }
    }

    return path_1_tile_ids, path_2_tile_ids;
}

get_direction_of_vector :: (start_pos: Vector2, end_pos: Vector2) -> Direction {
    if      start_pos.x == end_pos.x && start_pos.y > end_pos.y  return .NORTH;
    else if start_pos.x == end_pos.x && start_pos.y < end_pos.y  return .SOUTH;
    else if start_pos.x < end_pos.x  && start_pos.y == end_pos.y return .EAST;
    else if start_pos.x > end_pos.x  && start_pos.y == end_pos.y return .WEST;
    else return .NORTH;
}

get_angle_from_north :: (start_pos: Vector2, end_pos: Vector2) -> float32 {
    if      start_pos.x == end_pos.x && start_pos.y > end_pos.y  return 0.0;   // north
    else if start_pos.x == end_pos.x && start_pos.y < end_pos.y  return 180.0; // south
    else if start_pos.x < end_pos.x  && start_pos.y == end_pos.y return 90.0;  // east
    else if start_pos.x > end_pos.x  && start_pos.y == end_pos.y return 270.0; // west
    else return 0.0;
}    

set_cave_as_mined :: (tile_id: s32, cave_type: CaveType, grant_points: bool, grant_gold: bool, game_state: *GameState) {
    tile_type : TileType;

    if #complete cave_type == {
        case .EMPTY;
            tile_type = .MINED;
        case .WATER;
            tile_type = .WATER_STILL;
        case .LAVA;
            tile_type = .LAVA_STILL;
        case .TREASURE;
            tile_type = .MINED;

            rng := random_get_within_range(0, 1);
            is_treasure := rng <= 0.333;
            if is_treasure {
                array_add(*tiles_with_treasure_ids, tile_id);
                table_set(*tiles_with_treasure_ids_set, tile_id, 1738);
            }

        case .GOBLIN;
            tile_type = .MINED;

            #if GOBLIN_SPAWN_ENABLED {
                rng := random_get_within_range(0, 1);
                is_goblin := rng <= 0.25;
                if is_goblin create_goblin(get_tile_pos_by_id(tile_id));
            }

        case .SHAMAN;
            tile_type = .MINED;
        case .SPIDER_QUEEN;
            tile_type = .MINED;
    }

    set_tile_as_type(tile_id, tile_type, grant_points, grant_gold, game_state);

    // Recursively go through neighbors and set them as mined as well.
    for DIRECTIONS_CARDINAL {
        neighbor_id := get_neighbor_tile_id_by_direction(tile_id, it);

        tile_is_unrevealed_cave := table_contains(*cave_tile_ids_set, neighbor_id);
        if !tile_is_unrevealed_cave continue;

        set_cave_as_mined(neighbor_id, cave_type, grant_points, grant_gold, game_state);
    }
}

set_tile_as_type :: (tile_id: s32, as_type : TileType, grant_points: bool, grant_gold: bool, game_state: *GameState) {
    _result, chunk := find_or_create_chunk_by_tile_id(tile_id);

    tile_was_fully_mined := table_contains(*fully_mined_tile_ids_set, tile_id);
    tile_was_iron        := table_contains(*iron_tile_ids_set, tile_id);
    tile_was_dirt        := !tile_was_iron && !table_contains(*fully_mined_tile_ids_set, tile_id);
    tile_was_alert_water := table_contains(*water_alert_tile_ids_set, tile_id);
    tile_was_alert_lava  := table_contains(*lava_alert_tile_ids_set, tile_id);

    // PERF: removing by value has to iterate to find where the tile is, removing by index feels like it'd be a
    // lot faster, especially considering we do this function a shit ton.
    //
    // Remove the tile from all of the tile trackers. We will even remove it from lists that it should
    // stick around in. We put it into the one it should be right below this.
    {
        // TODO: why do I even check whether it was iron or not?
        //
        // If the tile was a resource remove the resource from the map
        if tile_was_iron {
            array_unordered_remove_by_value(*chunk.iron_tile_ids, tile_id);
            table_remove(*iron_tile_ids_set, tile_id);
        }

        array_unordered_remove_by_value(*chunk.obsidian_tile_ids, tile_id);
        table_remove(*obsidian_tile_ids_set, tile_id);

        array_unordered_remove_by_value(*chunk.wall_tile_ids, tile_id);
        table_remove(*wall_tile_ids_set, tile_id);
        
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
        table_remove(*water_still_tile_ids_to_sprite, tile_id);

        array_unordered_remove_by_value(*water_flowing_tile_ids, tile_id);
        array_unordered_remove_by_value(*chunk.water_flowing_tile_ids, tile_id);
        table_remove(*water_flowing_tile_ids_to_sprite, tile_id);

        array_unordered_remove_by_value(*lava_still_tile_ids, tile_id);
        array_unordered_remove_by_value(*chunk.lava_still_tile_ids, tile_id);
        table_remove(*lava_still_tile_ids_set, tile_id);

        array_unordered_remove_by_value(*lava_flowing_tile_ids, tile_id);
        array_unordered_remove_by_value(*chunk.lava_flowing_tile_ids, tile_id);
        table_remove(*lava_flowing_tile_ids_to_sprite, tile_id);

        array_unordered_remove_by_value(*hole_tile_ids, tile_id);
        array_unordered_remove_by_value(*chunk.hole_tile_ids, tile_id);
        table_remove(*hole_tile_ids_set, tile_id);
    }

    try_to_add_warning_and_alert_markers :: (tile_id: s32, alert_tile_ids_set: *Table, warning_tile_ids_set: *Table, alert_tile_ids: *[..]s32, warning_tile_ids: *[..]s32) {
        for direction: DIRECTIONS_COMPASS {
            dx := get_tile_direction_id_deltas(direction)[0];
            dy := get_tile_direction_id_deltas(direction)[1];

            neighbor_id_1 := tile_id + dx + dy;
            
            if is_cardinal_direction(direction) {
                if !is_tile_id_obsidian(neighbor_id_1) && !is_tile_id_hole(neighbor_id_1) {
                    table_set(alert_tile_ids_set, neighbor_id_1, 1738);
                    array_add(alert_tile_ids, neighbor_id_1);

                    neighbor_id_2 := tile_id + (2 * dx) + (2* dy);

                    table_set(warning_tile_ids_set, neighbor_id_2, 1738);
                    array_add(warning_tile_ids, neighbor_id_2);
                }
            } else {
                table_set(warning_tile_ids_set, neighbor_id_1, 1738);
                array_add(warning_tile_ids, neighbor_id_1);
            }
        }
    }

    if #complete as_type == {
        case .CAVE; {
            array_add(*chunk.cave_tile_ids, tile_id);
            table_set(*cave_tile_ids_set, tile_id, 1738);
        }
        case .MINED; {
            array_add(*chunk.fully_mined_tile_ids, tile_id);
            tile_column := cast(s32) random_get_within_range(0, 2);
            table_set(*fully_mined_tile_ids_set, tile_id, tile_column);

            tile_pos := get_tile_pos_by_id(tile_id);

            if tile_was_iron {
                if grant_gold {
                    game_state.gold += GOLD_FROM_MINE_IRON;
                    create_gold_particle(tile_pos, GOLD_FROM_MINE_IRON);
                }

                if grant_points game_state.points += POINTS_FROM_MINE_IRON;
            }

            if tile_was_dirt {
                if grant_gold {
                    game_state.gold += GOLD_FROM_MINE_DIRT;
                    create_gold_particle(tile_pos, GOLD_FROM_MINE_DIRT);
                }

                if grant_points game_state.points += POINTS_FROM_MINE_DIRT;
            }

            // TODO: It would be better if we had a parameter that explicitly was called mined_manually tbh.
            // Check whether this grants gold or not because that indicates whether or not it was mined manually.
            if grant_gold && tile_was_alert_water {
                pos := get_tile_pos_by_id(tile_id);

                create_alert(.WATER, pos, game_state);
            }

            // TODO: It would be better if we had a parameter that explicitly was called mined_manually tbh.
            // Check whether this grants gold or not because that indicates whether or not it was mined manually.
            if grant_gold && tile_was_alert_lava {
                pos := get_tile_pos_by_id(tile_id);
                
                create_alert(.LAVA, pos, game_state);
            }
        }
        case .ENCASED; {
            array_add(*chunk.encased_tile_ids, tile_id);
            table_set(*encased_tile_ids_set, tile_id, 1738);
        }
        case .WATER_STILL; {
            water_still_animated_sprite := AnimatedSprite.{
                texture           = water_still_texture,
                active            = true,
                color             = WHITE,
                first_frame       = 0,
                frame_count       = WATER_STILL_FRAME_COUNT,
                frame_duration_ms = WATER_STILL_FRAME_DURATION_MS,
                timer_ms          = 0,
                loops             = true,
            };

            array_add(*water_still_tile_ids, tile_id);
            array_add(*chunk.water_still_tile_ids, tile_id);
            table_set(*water_still_tile_ids_to_sprite, tile_id, water_still_animated_sprite);

            try_to_add_warning_and_alert_markers(tile_id, *water_alert_tile_ids_set, *water_warning_tile_ids_set, *water_alert_tile_ids, *water_warning_tile_ids);
        }
        case .WATER_FLOWING; {
            water_flowing_animated_sprite := AnimatedSprite.{
                texture           = water_flowing_texture,
                active            = true,
                color             = WHITE,
                first_frame       = 0,
                frame_count       = WATER_FLOWING_FRAME_COUNT,
                frame_duration_ms = WATER_FLOW_COOLDOWN_MS / WATER_FLOWING_FRAME_COUNT,
                timer_ms          = 0,
                loops             = true,
            };

            array_add(*water_flowing_tile_ids, tile_id);
            array_add(*chunk.water_flowing_tile_ids, tile_id);
            table_set(*water_flowing_tile_ids_to_sprite, tile_id, water_flowing_animated_sprite);

            try_to_add_warning_and_alert_markers(tile_id, *water_alert_tile_ids_set, *water_warning_tile_ids_set, *water_alert_tile_ids, *water_warning_tile_ids);
        }
        case .LAVA_STILL; {
            array_add(*lava_still_tile_ids, tile_id);
            array_add(*chunk.lava_still_tile_ids, tile_id);
            table_set(*lava_still_tile_ids_set, tile_id, AnimatedSprite.{});

            try_to_add_warning_and_alert_markers(tile_id, *lava_alert_tile_ids_set, *lava_warning_tile_ids_set, *lava_alert_tile_ids, *lava_warning_tile_ids);
        }
        case .LAVA_FLOWING; {
            lava_flowing_animated_sprite := AnimatedSprite.{
                texture           = lava_flowing_texture,
                active            = true,
                color             = WHITE,
                first_frame       = 0,
                frame_count       = LAVA_FLOWING_FRAME_COUNT,
                frame_duration_ms = LAVA_FLOW_COOLDOWN_MS / LAVA_FLOWING_FRAME_COUNT,
                timer_ms          = 0,
                loops             = true,
            };

            array_add(*lava_flowing_tile_ids, tile_id);
            array_add(*chunk.lava_flowing_tile_ids, tile_id);
            table_set(*lava_flowing_tile_ids_to_sprite, tile_id, lava_flowing_animated_sprite);

            try_to_add_warning_and_alert_markers(tile_id, *lava_alert_tile_ids_set, *lava_warning_tile_ids_set, *lava_alert_tile_ids, *lava_warning_tile_ids);
        }
        case .OBSIDIAN; {
            array_add(*chunk.obsidian_tile_ids, tile_id);
            table_set(*obsidian_tile_ids_set, tile_id, 1738);
        }
        case .WALL; {
            array_add(*chunk.wall_tile_ids, tile_id);
            table_set(*wall_tile_ids_set, tile_id, 1738);
        }
        case .HOLE; {
            array_add(*hole_tile_ids, tile_id);
            array_add(*chunk.hole_tile_ids, tile_id);
            table_set(*hole_tile_ids_set, tile_id, 1738);
        }
        case .DIRT; #through;
        case .IRON; assert(false, "Tried setting block as type %, but that doesn't really make sense.", as_type);
    }
}

set_tile_as_unmined :: (tile_id: s32) {
    _result, chunk := find_or_create_chunk_by_tile_id(tile_id);

    // Remove from the fully mined lists, turning it back into solid dirt
    array_unordered_remove_by_value(*chunk.fully_mined_tile_ids, tile_id);
    array_unordered_remove_by_value(*chunk.cave_tile_ids, tile_id);
    table_remove(*fully_mined_tile_ids_set, tile_id);
    table_remove(*cave_tile_ids_set, tile_id);
}

// Flood fill
spawn_iron :: (
    starting_tile_id: s32, 
    vein_size_min: s32, 
    vein_size_max: s32, 
    world_columns: s32, 
    world_rows: s32, 
    created_chunks: *Table,
    iron_tile_ids_set : *Table
) {
    size := cast(int) random_get_within_range(xx vein_size_min, xx vein_size_max);
    max_tile_id := world_columns * world_rows;

    ids_to_process: [..] s32;
    ids_to_process.allocator = temp;

    ids_processed_set: Table(s32, s32);
    ids_processed_set.allocator = temp;

    array_add(*ids_to_process, starting_tile_id);

    while ids_to_process.count > 0 && size > 0 {
        // Get the next id to process
        id := pop_front(*ids_to_process);

        // Make sure the id is valid and hasn't already been processed
        id_already_processed := table_contains(*ids_processed_set, id);
        if id_already_processed continue;
        if id <= 0 continue;
        if id > max_tile_id continue;

        // Get the chunk this happened in
        _result, chunk := find_or_create_chunk_by_tile_id(id);

        // Mark the tile id as iron
        array_add(*chunk.iron_tile_ids, id);
        table_set(iron_tile_ids_set, id, 0);

        // Mark it as processed
        table_add(*ids_processed_set, id, 1738);
        size -= 1;

        // Add neighbors as needing to be processed
        array_add(*ids_to_process, id - world_columns);
        array_add(*ids_to_process, id + world_columns);
        array_add(*ids_to_process, id + 1);
        array_add(*ids_to_process, id - 1);
    }
}

// TODO: probably want to DRY up these detector functions
detect_treasure_tile_id_within_radius :: (
    starting_tile_id: s32,
    radius: s32
) -> found: bool, tile_id: s32 {
    max_tile_id := context.world_cols * context.world_rows;

    ids_to_process: [..] s32;
    ids_to_process.allocator = temp;

    ids_processed_set: Table(s32, s32);
    ids_processed_set.allocator = temp;

    array_add(*ids_to_process, starting_tile_id);

    while ids_to_process.count > 0 {
        // Get the next id to process
        id := pop_front(*ids_to_process);

        // Make sure the id is valid and hasn't already been processed
        if table_contains(*ids_processed_set, id) continue;
        if id <= 0 continue;
        if id > max_tile_id continue;
        if !table_contains(*fully_mined_tile_ids_set, id) continue;
        if id == starting_tile_id - (context.world_rows * (radius + 1)) continue; // north
        if id == starting_tile_id + (context.world_rows * (radius + 1)) continue; // south
        if id == starting_tile_id + (radius + 1)                continue; // east
        if id == starting_tile_id - (radius + 1)                continue; // west

        // If treasure is found, return
        if table_contains(*tiles_with_treasure_ids_set, id) return true, id;

        // Mark it as processed
        table_set(*ids_processed_set, id, 1738);

        // Add neighbors as needing to be processed
        array_add(*ids_to_process, id - xx context.world_rows);
        array_add(*ids_to_process, id + xx context.world_rows);
        array_add(*ids_to_process, id + 1);
        array_add(*ids_to_process, id - 1);
    }

    return false, 0;
}

detect_entity_within_radius :: ($T: Type, starting_tile_id: s32, max_depth: s32) -> found: bool, entity: T, tile_id_path_to_dwarf: [..] s32
#modify { return uses_entity_with_as(cast(*Type_Info) T, Entity); }
{
    max_tile_id := context.world_cols * context.world_rows;
    empty_path: [..] s32; 

    Queue_Item :: struct {
        id: s32;
        depth: s32;
    }

    ids_to_process : [..] Queue_Item;
    ids_to_process.allocator = temp;

    came_from_map : Table(s32, s32);
    came_from_map.allocator = temp;

    set_tile_ids_to_entity(T);

    array_add(*ids_to_process, .{starting_tile_id, 0});
    table_set(*came_from_map, starting_tile_id, -1); 

    while ids_to_process.count > 0 {
        item  := pop_front(*ids_to_process);
        id    := item.id;
        depth := item.depth;

        if depth > max_depth                              continue; 
        if id <= 0                                        continue;
        if id > max_tile_id                               continue;
        if !table_contains(*fully_mined_tile_ids_set, id) continue;

        detected, entity := table_find(*tile_ids_to_entity, id);
        if detected {
            path: [..] s32;
            path.allocator = temp;
            
            current_id := id;
            while current_id != starting_tile_id {
                array_add(*path, current_id);
                found_parent, parent_id := table_find(*came_from_map, current_id);
                if !found_parent break; 
                
                current_id = parent_id;
            }
            
            for i: 0..path.count / 2 - 1 {
                temp_val := path[i];
                path[i] = path[path.count - 1 - i];
                path[path.count - 1 - i] = temp_val;
            }
            
            return true, entity, path;
        }

        queue_neighbor :: (neighbor_id: s32, parent_id: s32, next_depth: s32) #expand {
            if !table_contains(*came_from_map, neighbor_id) {
                table_set(*came_from_map, neighbor_id, parent_id);
                array_add(*ids_to_process, .{neighbor_id, next_depth});
            }
        }

        // Add neighbors, incrementing the distance by 1
        queue_neighbor(id - xx context.world_rows, id, depth + 1);
        queue_neighbor(id + xx context.world_rows, id, depth + 1);
        queue_neighbor(id + 1, id, depth + 1);
        queue_neighbor(id - 1, id, depth + 1);
    }

    return false, T.{}, empty_path;
}

// TODO: general version that also returns the Type
find_cardinal_neighbor_entity :: (tile_id: s32, $T: Type) -> found_entity: bool, entity: *T, direction: Direction
#modify { return uses_entity_with_as(cast(*Type_Info) T, Entity); }
{
    for DIRECTIONS_CARDINAL {
        neighbor_id := get_neighbor_tile_id_by_direction(tile_id, it);

        set_tile_ids_to_entity(T);

        neighbor_has_entity, entity := table_find(*tile_ids_to_entity, neighbor_id);
        if neighbor_has_entity return true, entity, it;
    }

    return false, null, .CENTER;
}

find_line_of_sight_entity :: (tile_id: s32, $T: Type, line_of_sight_tile_count: int) -> bool, *T, tile_ids_path: [] s32
#modify { return uses_entity_with_as(cast(*Type_Info) T, Entity); }
{
    for direction: DIRECTIONS_CARDINAL {
        tile_ids_path : [..] s32;
        tile_ids_path.allocator = temp;

        dx := get_tile_direction_id_deltas(direction)[0];
        dy := get_tile_direction_id_deltas(direction)[1];

        for distance_multiplier: 1..line_of_sight_tile_count {
            neighbor_id := tile_id + (distance_multiplier * dx) + (distance_multiplier * dy);
            array_add(*tile_ids_path, xx neighbor_id);

            set_tile_ids_to_entity(T);

            neighbor_has_entity, entity := table_find(*tile_ids_to_entity, xx neighbor_id);
            if neighbor_has_entity return true, entity, tile_ids_path;

        }
    }

    return false, null, s32.[];
}

// TODO: probably want to DRY up these detector functions 
detect_iron_tile_id_within_radius :: (
    starting_tile_id: s32,
    radius: s32
) -> found: bool, tile_id: s32 {
    max_tile_id := context.world_cols * context.world_rows;

    ids_to_process: [..] s32;
    ids_to_process.allocator = temp;

    ids_processed_set: Table(s32, s32);
    ids_processed_set.allocator = temp;

    array_add(*ids_to_process, starting_tile_id);

    while ids_to_process.count > 0 {
        // Get the next id to process
        id := pop_front(*ids_to_process);

        // Make sure the id is valid and hasn't already been processed
        if table_contains(*ids_processed_set, id) continue;
        if id <= 0 continue;
        if id > max_tile_id continue;
        // if table_contains(*fully_mined_tile_ids_set, id) continue;
        // if table_contains(*actively_mined_tile_ids_to_health_table, id) continue;
        if id == starting_tile_id - (context.world_rows * (radius + 1)) continue; // north
        if id == starting_tile_id + (context.world_rows * (radius + 1)) continue; // south
        if id == starting_tile_id + (radius + 1)                continue; // east
        if id == starting_tile_id - (radius + 1)                continue; // west

        // If iron is found, return
        if table_contains(*iron_tile_ids_set, id) return true, id;

        // Mark it as processed
        table_set(*ids_processed_set, id, 1738);

        // Add neighbors as needing to be processed
        array_add(*ids_to_process, id - xx context.world_rows);
        array_add(*ids_to_process, id + xx context.world_rows);
        array_add(*ids_to_process, id + 1);
        array_add(*ids_to_process, id - 1);
    }

    return false, 0;
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
    array_reset(*wall_tile_ids_in_viewport);
    array_reset(*water_still_tile_ids_in_viewport);
    array_reset(*water_flowing_tile_ids_in_viewport);
    array_reset(*lava_still_tile_ids_in_viewport);
    array_reset(*lava_flowing_tile_ids_in_viewport);
    array_reset(*water_warning_tile_ids_in_viewport);
    array_reset(*lava_warning_tile_ids_in_viewport);
    array_reset(*water_alert_tile_ids_in_viewport);
    array_reset(*lava_alert_tile_ids_in_viewport);
    array_reset(*alerts_in_viewport);
    array_reset(*bases_in_viewport);
    array_reset(*dwarves_in_viewport);
    array_reset(*goblins_in_viewport);
    array_reset(*tiles_with_dynamite_ids_in_viewport);
    array_reset(*tiles_with_treasure_ids_in_viewport);
    array_reset(*hole_tile_ids_in_viewport);
    array_reset(*paths_in_viewport);
    array_reset(*particles_in_viewport);
    
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

            found, chunk := table_find(*created_chunks, key);
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
            // TODO: do we need to do this?
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

            // Wall tiles
            for tile_id: chunk.wall_tile_ids {
                pos := get_tile_pos_by_id(tile_id);

                if pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
                if pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
                if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
                if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

                array_add(*wall_tile_ids_in_viewport, tile_id);
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
                found, base_index := table_find(*base_id_to_index, base_id);
                assert(found);
                base := bases[base_index];

                if base.pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
                if base.pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
                if base.pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
                if base.pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

                array_add(*bases_in_viewport, base);
            }

            // TODO
            // Dwarves
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

    // Derive viewable goblins
    {
        for goblin: goblins {
            pos := goblin.pos;

            if pos.x + TILEMAP_GENERAL_WORLD_WIDTH < window_start.x continue;
            if pos.x - TILEMAP_GENERAL_WORLD_WIDTH > window_end.x continue;
            
            if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y continue;
            if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

            array_add(*goblins_in_viewport, goblin);
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

    // Derive viewable treasure
    {
        for treasure_tile_id: tiles_with_treasure_ids {
            pos := get_tile_pos_by_id(treasure_tile_id);

            if pos.x + TILEMAP_GENERAL_WORLD_WIDTH < window_start.x continue;
            if pos.x - TILEMAP_GENERAL_WORLD_WIDTH > window_end.x continue;
            
            if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y continue;
            if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

            array_add(*tiles_with_treasure_ids_in_viewport, treasure_tile_id);
        }
    }

    // Derive viewable water warning tiles
    for water_warning_tile_ids {
        pos := get_tile_pos_by_id(it);

        if pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
        if pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
        if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
        if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

        array_add(*water_warning_tile_ids_in_viewport, it);
    }

    // Derive viewable lava warning tiles
    for lava_warning_tile_ids {
        pos := get_tile_pos_by_id(it);

        if pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
        if pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
        if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
        if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

        array_add(*lava_warning_tile_ids_in_viewport, it);
    }

    // Derive viewable water alert tiles
    for water_alert_tile_ids {
        pos := get_tile_pos_by_id(it);

        if pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
        if pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
        if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
        if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

        array_add(*water_alert_tile_ids_in_viewport, it);
    }

    // Derive viewable lava alert tiles
    for lava_alert_tile_ids {
        pos := get_tile_pos_by_id(it);

        if pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
        if pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
        if pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
        if pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

        array_add(*lava_alert_tile_ids_in_viewport, it);
    }

    // Derive alerts in viewport
    for alerts {
        if it.pos.x + TILEMAP_GENERAL_WORLD_WIDTH  < window_start.x continue;
        if it.pos.x - TILEMAP_GENERAL_WORLD_WIDTH  > window_end.x   continue;
        if it.pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y   continue;
        if it.pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

        array_add(*alerts_in_viewport, it);
    }

    // Derive viewable paths
    {
        for path: paths {
            start_tile_pos  := get_tile_pos_by_id(path.start_tile_id);
            end_tile_pos    := get_tile_pos_by_id(get_path_end_tile_id(path));

            if (
                start_tile_pos.x  + TILEMAP_GENERAL_WORLD_WIDTH < window_start.x &&
                end_tile_pos.x    + TILEMAP_GENERAL_WORLD_WIDTH < window_start.x
            ) continue;

            if (
                start_tile_pos.x  - TILEMAP_GENERAL_WORLD_WIDTH > window_end.x &&
                end_tile_pos.x    - TILEMAP_GENERAL_WORLD_WIDTH > window_end.x
            ) continue;

            if (
                start_tile_pos.y  - TILEMAP_GENERAL_WORLD_WIDTH > window_end.y &&
                end_tile_pos.y    - TILEMAP_GENERAL_WORLD_WIDTH > window_end.y
            ) continue;
                
            if (
                start_tile_pos.y  + TILEMAP_GENERAL_WORLD_WIDTH < window_start.y &&
                end_tile_pos.y    + TILEMAP_GENERAL_WORLD_WIDTH < window_start.y
            ) continue;

            array_add(*paths_in_viewport, path);
        }
    }

    // Derive viewable particles
    {
        for particle: particles {
            if particle.pos.x + TILEMAP_GENERAL_WORLD_WIDTH < window_start.x continue;
            if particle.pos.x - TILEMAP_GENERAL_WORLD_WIDTH > window_end.x continue;
            
            if particle.pos.y - TILEMAP_GENERAL_WORLD_HEIGHT > window_end.y continue;
            if particle.pos.y + TILEMAP_GENERAL_WORLD_HEIGHT < window_start.y continue;

            array_add(*particles_in_viewport, particle);
        }
    }
}

reveal_cave_if_necessary :: (tile_id: s32, grant_points: bool, grant_gold: bool, game_state: *GameState) -> revealed_cave: bool, cave_type: CaveType {
    check_is_neighbor_unreavealed_cave :: (tile_id: s32) -> found_cave_neighbor: bool, cave_neighbor_id: s32 {
        for DIRECTIONS_CARDINAL {
            neighbor_id := get_neighbor_tile_id_by_direction(tile_id, it);
            neighbor_is_unrevealed_cave := table_contains(*cave_tile_ids_set, neighbor_id);

            if neighbor_is_unrevealed_cave return true, neighbor_id;
        }

        return false, 1738;
    }

    cave_type: CaveType;

    neighbor_is_unrevealed_cave, cave_tile_id := check_is_neighbor_unreavealed_cave(tile_id);
    if neighbor_is_unrevealed_cave {
        // First, decide what kind of cave this will be.
        cave_type = cast(CaveType) cast(int) random_get_within_range(0, xx enum_count(CaveType));

        // Second, spawn any alerts you might need
        alert_type: AlertType;
        if #complete cave_type == {
            case .EMPTY;        // no op
            case .WATER;        create_alert(.WATER, get_tile_pos_by_id(tile_id), game_state);
            case .LAVA;         create_alert(.LAVA, get_tile_pos_by_id(tile_id), game_state);
            case .TREASURE;     create_alert(.TREASURE, get_tile_pos_by_id(tile_id), game_state);
            case .GOBLIN;       create_alert(.GOBLINS, get_tile_pos_by_id(tile_id), game_state);
            case .SHAMAN;       create_alert(.SHAMAN, get_tile_pos_by_id(tile_id), game_state);
            case .SPIDER_QUEEN; create_alert(.SPIDER_QUEEN, get_tile_pos_by_id(tile_id), game_state);
        }

        // Third, recursively reveal the tiles of the cave.
        set_cave_as_mined(cave_tile_id, cave_type, grant_points, grant_gold, game_state);

        // Lastly, if this cave has liquid in it, we'll need to kick off the flowing by spawning a flowing tile
        // in place of the tile the dwdarf just mined. Otherwise, the liquid wouldn't start flowing, since we
        // need to spawn still liquid.
        if #complete cave_type == {
            case .EMPTY;        // no op
            case .TREASURE;     // no op
            case .GOBLIN;       // no op
            case .SHAMAN;       // no op
            case .SPIDER_QUEEN; // no op
            case .WATER; set_tile_as_type(tile_id, .WATER_FLOWING, false, false, game_state);
            case .LAVA;  set_tile_as_type(tile_id, .LAVA_FLOWING, false, false, game_state);
        }
    }

    return neighbor_is_unrevealed_cave, cave_type;
}

get_rect_center :: (rect: Rectangle) -> Vector2 {
    return Vector2.{ rect.x + rect.width/2, rect.y + rect.height/2 };
}

get_tile_rect_that_pos_is_within :: (world_width: int, world_height: int, tile_width: int, tile_height: int, mouse_pos_in_world: Vector2) -> Rectangle {
    grid_col := cast(int)(mouse_pos_in_world.x / tile_width);
    grid_row := cast(int)(mouse_pos_in_world.y / tile_height);

    // Calculate the top-left pixel position of that specific tile
    tile_x := grid_col * tile_width;
    tile_y := grid_row * tile_height;

    return Rectangle.{ xx tile_x, xx tile_y, xx tile_width, xx tile_height };
}

get_tile_pos_by_id :: inline (id: s32) -> Vector2 {
    index := id - 1;

    // Bitwise AND (&) acts as Modulo to get the X column
    grid_x := index & context.world_cols_mask; 
    
    // Right Shift (>>) acts as Division to get the Y row
    grid_y := index >> context.world_cols_shift; 

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

    if grid_x < 0 || grid_x >= context.world_cols return false, 0;
    if grid_y < 0 || grid_y >= context.world_rows return false, 0;

    index : s32 = (grid_y * xx context.world_cols) + grid_x;

    return true, index + 1;
}

get_rect_pos :: (rect: Rectangle) -> Vector2 {
    return { rect.x, rect.y };
}

/**
 * frequency: how many blocks before the next gradient. The higher the frequency, the less blocks in between gradients
 */
perlin_noise_2d :: (desired_values: s32, starting_frequency: s32 = 1, starting_amplitude: float32 = 1.0, octaves: s32 = 1) -> perlin_2d: [] float {
    assert(desired_values > 0,     "You probably want a positive DESIRED_VALUES. If not, delete this assertion.");
    assert(starting_frequency > 0, "You probably want a positive starting_frequency. If not, delete this assertion.");
    assert(octaves > 0,            "You probably want a positive octaves. If not, delete this assertion.");
    assert(desired_values % starting_frequency == 0, "The perlin noise frequency must be a divisor of the number of desired values.");

    // TODO: temp allocator?
    results : [..] float;

    random_grid_gradients: [..] Vector2;
    random_grid_gradients.allocator = temp;

    for i: 0..(desired_values * desired_values - 1) {
        array_add(*results, 0.0);
    }

    for octave: 1..octaves {
        random_grid_gradients.count = 0;

        octave_factor       := pow(2.0, cast(float) octave - 1);
        amplitude           := starting_amplitude / octave_factor;
        frequency           := cast(int) (starting_frequency * octave_factor);
        blocks_per_section  := cast(int) (desired_values / frequency);
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

        for row: 0..desired_values-1 {
            for col: 0..desired_values-1 {
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

                results[row * desired_values + col] += amplitude * (perlin / max_raw_noise_value);
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

set_tile_ids_to_entity :: (T: Type) #expand
// #modify { return uses_entity_with_as(cast(*Type_Info) T, Entity); }
{
    `tile_ids_to_entity : Table(s32, *T);
    #if      T == Dwarf  `tile_ids_to_entity = tile_ids_to_dwarfs;
    else #if T == Goblin `tile_ids_to_entity = tile_ids_to_goblins;
    else #if T == Base   `tile_ids_to_entity = tile_ids_to_bases;
    else assert(false); // TODO: what if we didn't need this somehow
}

set_entity_id_to_index :: ($T: Type) #expand
#modify { return uses_entity_with_as(cast(*Type_Info) T, Entity); }
{
    `entity_id_to_index : Table(s32, s64);
    #if      T == Dwarf  `entity_id_to_index = dwarf_id_to_index;
    else #if T == Goblin `entity_id_to_index = goblin_id_to_index;
    else #if T == Base   `entity_id_to_index = base_id_to_index;
    else assert(false); // TODO: what if we didn't need this somehow
}

get_entity_kind_to_type :: (entity_kind: EntityKind) -> Type {
    if #complete entity_kind == {
        case .Base;   return Base;
        case .Dwarf;  return Dwarf;
        case .Goblin; return Goblin;
    }
}

get_entity_by_id :: (entity_kind: EntityKind, id: s32) -> (found: bool, entity: *Entity)
{
    entity_id_to_index : Table(s32, s64);
    if #complete entity_kind == {
        case .Base;   entity_id_to_index = base_id_to_index;
        case .Dwarf;  entity_id_to_index = dwarf_id_to_index;
        case .Goblin; entity_id_to_index = goblin_id_to_index;
    }

    found, index := table_find(*entity_id_to_index, id);

    if !found return false, null;

    entity := get_entity_by_index(entity_kind, index);
    
    return found, entity;
}

get_entity_by_index :: (entity_kind: EntityKind, index: s64) -> *Entity
{
    if #complete entity_kind == {
        case .Base;   return *(bases[index]);
        case .Dwarf;  return *(dwarves[index]);
        case .Goblin; return *(goblins[index]);
    }
}