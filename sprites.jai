Sprite :: struct {
    tilemap     : Texture;
    active      : bool;
    first_frame : s32; // Starts from 0
    color       : Color;
}

AnimatedSprite :: struct {
    #as using sprite  : Sprite;
    frame_count       : s32;
    frame_duration_ms : s32;
    timer_ms          : s32;
    loops             : bool;
}

sprite_animation_get_current_frame :: (sprite: $T/Sprite) -> s32 {
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
sprite_animation_get_total_duration_ms :: (animation: AnimatedSprite) -> s32 {
    return animation.frame_count * animation.frame_duration_ms;
}

sprite_draw :: (sprite: $T/Sprite, entity: Entity, texture_map_tile_width: s32, texture_map_tile_height: s32) {
    assert(texture_map_tile_width > 0,  "You probably want a positive width. If not, delete this assertion");
    assert(texture_map_tile_height > 0, "You probably want a positive height. If not, delete this assertion");
    if !sprite.active return;

    frame        := sprite_animation_get_current_frame(sprite);
    source_width : float = ifx entity.is_facing_left then cast(float) texture_map_tile_width * -1 else cast(float) texture_map_tile_width;
    source_rect  := Rectangle.{xx (frame * texture_map_tile_width), 0.0, source_width, xx texture_map_tile_height};
    dest_rect    := Rectangle.{ entity.sprite_rect.x, entity.sprite_rect.y, entity.sprite_rect.width, entity.sprite_rect.height }; 

    DrawTexturePro(sprite.tilemap, source_rect, dest_rect, Vector2.{ 0, 0 }, 0.0, sprite.color);
}