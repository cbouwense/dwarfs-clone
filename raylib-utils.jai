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

// debug_struct_runtime :: (thing: Any, name_prefix: string) #expand {
//     if thing.type.type != .STRUCT return;
//     tis := cast(*Type_Info_Struct) thing.type;

//     for tis.members {
//         // Calculate where this field lives in memory
//         field_ptr := thing.value_pointer + it.offset_in_bytes;
        
//         // Construct an 'Any' so tprint knows how to format it
//         field_any: Any;
//         field_any.type = it.type;
//         field_any.value_pointer = field_ptr;

//         // Format the string dynamically
//         text := tprint("%.%: %\0", name_prefix, it.name, field_any);
        
//         DrawText(text.data, 10, read_then_increment(*`debug_text_y, INCREMENT_Y), 18, WHITE);
//     }
// }

// debug_struct_fields_with_raylib_draw_text :: (c: Code) #expand {
//     code_to_string :: (c: Code) -> string {
//         root := compiler_get_nodes(c);

//         builder: String_Builder;
//         builder.allocator = temp; // TODO: parameter?

//         print_expression(*builder, root);

//         return builder_to_string(*builder);
//     }

//     var_name := #run code_to_string(c);
//     var_val  := #insert c;
    
//     debug_struct_runtime(var_val, var_name);
// }