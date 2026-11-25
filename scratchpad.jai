#import "Basic";
#import "Print_Vars";

main :: () {
    TEN :: 10;
    for row: 0..TEN {
        for col: 0..TEN {
            id := (col % TEN) + (row * TEN);
            print_vars(id);
        }
    }
}