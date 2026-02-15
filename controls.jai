Control :: struct {
    type:  Type;
    value: s32; // KeyboardKey | MouseButton;
}

Controls :: struct {
    move_camera_up    : [3] Control;
    move_camera_down  : [3] Control;
    move_camera_left  : [3] Control;
    move_camera_right : [3] Control;
}

control_is_down :: (haystack: [] Control) -> bool {
    for haystack {
        if it.type == KeyboardKey && IsKeyDown(xx it.value) return true;
        if it.type == MouseButton && IsMouseButtonDown(xx it.value) return true;
    }

    return false;
}

control_is_pressed :: (haystack: [] Control) -> bool {
    for haystack {
        if it.type == KeyboardKey && IsKeyPressed(xx it.value) return true;
        if it.type == MouseButton && IsMouseButtonPressed(xx it.value) return true;
    }

    return false;
}