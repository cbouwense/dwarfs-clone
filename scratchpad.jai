#import "Basic";
#import "Hash_Table";
#import "Input";
#import "Math";
#import "Print_Vars";
#import "Random";
#import "Sort";
String :: #import "String";
#import "System";

#load "utils.jai";

main :: () {
    edges : [] Edge = .[
      Edge.{0, 1, 13.37},
      Edge.{0, 2, 90.01},
      Edge.{1, 2, 17.38},
    ];

    shortest_path := dijkstra(0, 2, edges);
    print_vars(shortest_path);
}