#import "Basic";
#import "Compiler";
#import "Print_Vars";
#import "Program_Print";
#import "String";

fn :: () {
    should_stop := false;
    for 0..5 {
        for 0..5 {
            for 6..10 {
                should_stop := some_func();
                if should_stop break;
            }
            if should_stop break;
        }
        if should_stop break;
    }
}