Bind :: struct {
    type  : Type;   // KeyboardKey | MouseButton;
    value : s32;
    is_being_rebound : bool;
}

ControlMode :: enum {
    NONE :: 0;
    NORMAL;
    ADD_BASE;
    ADD_DYNAMITE;
    ADD_OBSIDIAN;
    ADD_WALL;
    REMOVE;
}

Control :: struct {
    id                 : s32;
    name               : string;      // What shows up in the keybind menu.
    binds              : [3] Bind;
    rebindable_by_user : bool;        // Some controls really ought not to be rebindable.
    control_mode       : ControlMode;
    tooltip_text       : string;
}

Controls :: struct {
    select                        : Control;
    clear_selection               : Control;
    toggle_base_mode              : Control;
    add_iron                      : Control;
    select_as_place_miner_dwarf   : Control;
    select_as_place_warrior_dwarf : Control;
    toggle_dynamite_mode          : Control;
    select_as_place_goblin        : Control;
    toggle_obsidian_mode          : Control;
    toggle_wall_mode              : Control;
    drag_as_create_path           : Control;
    drag_cam                      : Control;
    move_camera_up                : Control;
    move_camera_down              : Control;
    move_camera_left              : Control;
    move_camera_right             : Control;
    toggle_remove_mode            : Control;
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

bind_to_readable_name_cstr :: (bind: Bind) -> *u8 {
    if bind.is_being_rebound return to_c_string("...");
    if bind.value == 0 return to_c_string("<None>");

    mouse_info    := type_info(MouseButton);
    keyboard_info := type_info(KeyboardKey);

    info := ifx bind.type == MouseButton then mouse_info else keyboard_info;
    found, index := array_find(info.values, bind.value);
    assert(found);

    return to_c_string(info.names[index]);
}

get_control_mode_from_control :: (control: Control) -> ControlMode {
    assert(control.control_mode != .NONE, "Tried to get a control mode from control \"%\" that doesn't have one.", control.name);
    return control.control_mode;
}

find_control_mode_from_control :: (control: Control) -> bool, ControlMode {
    if control.control_mode == .NONE return false, .NONE;
    return true, control.control_mode;
}

get_tooltip_text_from_control :: (control: Control) -> string {
    assert(control.tooltip_text.count > 0, "Tried to get tooltip text from control \"%\" that doesn't have one.", control.name);
    return control.tooltip_text;
}