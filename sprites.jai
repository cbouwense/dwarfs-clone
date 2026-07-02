Sprite :: struct {
    texture     : Texture;
    active      : bool;
    first_frame : int; // Starts from 0
    color       : Color;
}

AnimatedSprite :: struct {
    #as using sprite  : Sprite;
    frame_count       : int;
    frame_duration_ms : int;
    timer_ms          : int;
    loops             : bool;
}

sprite_animation_get_current_frame :: (sprite: $T/Sprite) -> int {
    // if this is not an AnimatedSprite, just use the first "frame"
    #if type_of(sprite) == Sprite { 
        return sprite.first_frame;
    } else {
        if sprite.frame_duration_ms == 0 return 0;
        return ((sprite.timer_ms / sprite.frame_duration_ms) % sprite.frame_count) + sprite.first_frame;
    }
}

// Returns the duration of one full playing of the animation. So, if there are 10 frames, each 50 ms long, the
// duration would be 500ms
sprite_animation_get_total_duration_ms :: (animation: AnimatedSprite) -> int {
    return animation.frame_count * animation.frame_duration_ms;
}

sprite_draw :: (sprite: $T/Sprite, pos: Vector2, sprite_width: int, sprite_height: int, texture_map_tile_width: int, texture_map_tile_height: int) {
    assert(texture_map_tile_width > 0,  "You probably want a positive width. If not, delete this assertion");
    assert(texture_map_tile_height > 0, "You probably want a positive height. If not, delete this assertion");
    if !sprite.active return;

    frame        := sprite_animation_get_current_frame(sprite);
    source_rect  := Rectangle.{xx (frame * texture_map_tile_width), 0.0, xx texture_map_tile_width, xx texture_map_tile_height};
    dest_rect    := Rectangle.{ pos.x, pos.y, xx sprite_width, xx sprite_height }; 

    DrawTexturePro(sprite.texture, source_rect, dest_rect, Vector2.{ 0, 0 }, 0.0, sprite.color);
}

sprite_update :: (sprite: *AnimatedSprite, dt_seconds: float) {
    if sprite.active {
        sprite.timer_ms += xx (dt_seconds * 1000);

        if !sprite.loops && sprite.timer_ms > sprite_animation_get_total_duration_ms(sprite) {
            sprite.timer_ms = 0;
            sprite.active   = false;
        }
    } else {
        sprite.timer_ms = 0;
    }
}
