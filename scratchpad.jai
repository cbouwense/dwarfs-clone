#import "Basic";
#import "Hash_Table";
#import "Input";
Math :: #import "Math";
#import "Print_Vars";
#import "Random";
#import "Sloppy_Math";
#import "Sort";
#import "String";
#import "System";

main :: () {
    while true {
        derive_entities_in_viewport();
    }
}

derive_entities_in_viewport :: () {    
    for cy: 1..90001 {
        for cx: 1..90001 {
            
            find_chunk_key_tmp :: (chunk_x: s32, chunk_y: s32) -> (found: bool, key: u64) {
                if chunk_x < 0 return false, 0;
                if chunk_y < 0 return false, 0;

                x_u64 : u64 = 0xFFFFFFFF00000000;
                y_u64 : u64 = 0x00000000FFFFFFFF;

                return false, 0xFFFFFFFFFFFFFFFF;
            }

            key_was_valid, key := find_chunk_key_tmp(xx cx, xx cy);
            // This happens if the camera is looking out of bounds.
            if !key_was_valid continue;
        }
    }
}
