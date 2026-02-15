#import "Print_Vars";

#load "utils.jai";

main :: () {
    {
        edges : [] Edge = .[
            Edge.{0, 1, 13.37},
            Edge.{0, 2, 90.01},
            Edge.{1, 2, 17.38},
        ];

        shortest_path := dijkstra(0, 2, edges);
        assert(shortest_path.count == 3);
        assert(shortest_path[0] == 0);
        assert(shortest_path[1] == 1);
        assert(shortest_path[2] == 2);
    }

    { // https://youtu.be/_lHSawdgXpI
        A :: 0;
        B :: 1;
        C :: 2;
        D :: 3;
        E :: 4;

        edges : [] Edge = .[
            Edge.{A, B, 4.0},
            Edge.{A, C, 2.0},
            Edge.{B, C, 3.0},
            Edge.{B, D, 2.0},
            Edge.{B, E, 3.0},
            Edge.{C, B, 1.0},
            Edge.{C, D, 4.0},
            Edge.{C, E, 5.0},
            Edge.{E, D, 1.0},
        ];

        shortest_path_A_to_B := dijkstra(A, B, edges);
        assert(shortest_path_A_to_B.count == 3);
        assert(shortest_path_A_to_B[0] == A);
        assert(shortest_path_A_to_B[1] == C);
        assert(shortest_path_A_to_B[2] == B);

        shortest_path_A_to_C := dijkstra(A, C, edges);
        assert(shortest_path_A_to_C.count == 2);
        assert(shortest_path_A_to_C[0] == A);
        assert(shortest_path_A_to_C[1] == C);

        shortest_path_A_to_D := dijkstra(A, D, edges);
        assert(shortest_path_A_to_D.count == 4);
        assert(shortest_path_A_to_D[0] == A);
        assert(shortest_path_A_to_D[1] == C);
        assert(shortest_path_A_to_D[2] == B);
        assert(shortest_path_A_to_D[3] == D);

        shortest_path_A_to_E := dijkstra(A, E, edges);
        assert(shortest_path_A_to_E.count == 4);
        assert(shortest_path_A_to_E[0] == A);
        assert(shortest_path_A_to_E[1] == C);
        assert(shortest_path_A_to_E[2] == B);
        assert(shortest_path_A_to_E[3] == E);
    }

    print("All tests passed!");
}