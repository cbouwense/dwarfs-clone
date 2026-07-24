#import "Basic";
#import "Compiler";
#import "Print_Vars";
#import "Program_Print";

TrenchDirections :: enum_flags u8 {
    NORTH      :: 0b00000001; // 1
    SOUTH      :: 0b00000010; // 2
    EAST       :: 0b00000100; // 4
    WEST       :: 0b00001000; // 8
    NORTH_EAST :: 0b00010000; // 16
    NORTH_WEST :: 0b00100000; // 32
    SOUTH_EAST :: 0b01000000; // 64
    SOUTH_WEST :: 0b10000000; // 128
}

main :: () {
    a : TrenchDirections = 0;
    b := TrenchDirections.NORTH;

    c := a & ~b;
    a &= ~b;

    print_vars(a, b, c);
}
