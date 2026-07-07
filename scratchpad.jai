GameState :: struct {
    foo: int;
    bar: float;
    baz: string;
}

#add_context game_state : GameState;

main :: () {
    context.game_state = GameState.{
        42,
        13.37,
        "remy boyz",
    };
    print_vars(context);
}

#import "Basic";
#import "Compiler";
#import "Print_Vars";
#import "Program_Print";
