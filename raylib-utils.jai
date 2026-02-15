vector2_equal :: (v1: Vector2, v2: Vector2) -> bool {
    return v1.x == v2.x && v1.y == v2.y;
}

vector2_to_string_permanent :: (v: Vector2) -> string {
    key := sprint("%,%", v.x, v.y);
    return key;
}

vector2_to_string_temp :: (v: Vector2) -> string {
    key := tprint("%,%", v.x, v.y);
    return key;
}
