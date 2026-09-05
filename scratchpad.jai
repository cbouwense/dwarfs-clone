#import "Basic";
#import "Compiler";
#import "Print_Vars";
#import "Program_Print";
#import "String";

main :: () {
    str := tprint("%", 123);
    substr := slice(str, 0, 1);
    advance(str, 3);
    print_vars(str, substr);
}
