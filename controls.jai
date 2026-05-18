Bind :: struct {
    type  : Type;   // KeyboardKey | MouseButton;
    value : s32;
    is_being_rebound : bool;
}

Control :: struct {
    name  : string; // What shows up in the keybind menu.
    binds : [3] Bind;
    rebindable_by_user : bool; // Some controls really ought not to be rebindable.
}

Controls :: struct {
    select                        : Control;
    toggle_base_mode                 : Control;
    add_iron                      : Control;
    select_as_place_digger_dwarf  : Control;
    select_as_place_warrior_dwarf : Control;
    toggle_dynamite_mode      : Control;
    select_as_place_goblin        : Control;
    toggle_obsidian_mode      : Control;
    toggle_wall_mode          : Control;
    drag_as_create_path           : Control;
    drag_cam                      : Control;
    move_camera_up                : Control;
    move_camera_down              : Control;
    move_camera_left              : Control;
    move_camera_right             : Control;
    toggle_remove_mode         : Control;
    panic_pause                   : Control;
    fast_forward                  : Control;
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