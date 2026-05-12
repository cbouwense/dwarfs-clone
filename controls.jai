Bind :: struct {
    type  : Type;   // KeyboardKey | MouseButton;
    value : s32;
    is_being_rebound : bool;
}

Control :: struct {
    name  : string; // What shows up in the keybind menu;
    binds : [3] Bind;
}

Controls :: struct {
    select                   : Control;
    add_base_mode            : Control;
    add_iron                 : Control;
    select_as_place_dwarf    : Control;
    select_as_place_dynamite : Control;
    select_as_place_goblin   : Control;
    select_as_place_obsidian : Control;
    select_as_place_wall     : Control;
    drag_as_create_path      : Control;
    drag_cam                 : Control;
    move_camera_up           : Control;
    move_camera_down         : Control;
    move_camera_left         : Control;
    move_camera_right        : Control;
    select_as_remove_path    : Control;
    panic_pause              : Control;
}

control_is_down :: (control: Control) -> bool {
    for control.binds {
        if it.type == KeyboardKey && IsKeyDown(xx it.value) return true;
        if it.type == MouseButton && IsMouseButtonDown(xx it.value) return true;
    }

    return false;
}

control_is_pressed :: (control: Control) -> bool {
    for control.binds {
        if it.type == KeyboardKey && IsKeyPressed(xx it.value) return true;
        if it.type == MouseButton && IsMouseButtonPressed(xx it.value) return true;
    }

    return false;
}