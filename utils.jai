#import "Basic";
#import "Hash_Table";
#import "Math";
String :: #import "String";

read_then_increment :: (x: *s32, increment: s32 = 1) -> s32 {
    defer x.* += increment;
    return x.*;
}

round_to_int :: (f: float) -> int {
    i := cast(int) f;
    decimal_part := abs(f) - abs(i);

    if decimal_part >= 0.5 {
        if f >= 0 return i + 1;
        else      return i - 1;
    }

    return i;
}

Edge :: struct {
    from     : s32;
    to       : s32;
    distance : float32;
}

/**
 * Finds the shortest path between two nodes in a finite weighted graph.
 * Returns the shortest path in an array starting with the start id and ending with
 * the target id.
 * 
 * Example:
 *   edges : [] Edge = .[
 *     Edge.{0, 1, 13.37},
 *     Edge.{0, 2, 90.01},
 *     Edge.{1, 2, 17.38},
 *   ];
 * 
 *   shortest_path := dijkstra(0, 2, edges);
 *   // shortest_path == [0, 1, 2]
 */
dijkstra :: (start_id: s32, target_id: s32, edges: [] Edge) -> [] s32 {
    ids_to_distances  : Table(Key_Type = s32, Value_Type = float32); // id to distance from start value
    priority_queue    : Table(Key_Type = s32, Value_Type = Any);     // setting Value_Type as Any because we're using this as a Set
    visited_nodes_set : Table(Key_Type = s32, Value_Type = Any);     // setting Value_Type as Any because we're using this as a Set
    predecessors      : Table(Key_Type = s32, Value_Type = s32);

    for edge: edges {
        table_set(*ids_to_distances, edge.from, FLOAT32_INFINITY);
        table_set(*ids_to_distances, edge.to,   FLOAT32_INFINITY);
    }
    table_set(*ids_to_distances, start_id, 0);

    // Push the start node onto the priority queue
    table_set(*priority_queue, start_id, null);

    find_closest_node_id :: (nodes: Table, ids_to_distances: Table) -> found_closest_node: bool, closest_node_id: s32 {
        closest_node_id : s32 = -1;
        closest_node_distance := FLOAT32_INFINITY;

        for nodes {
            node_id := it_index;

            node_distance_exists, node_distance := table_find(*ids_to_distances, node_id);
            assert(node_distance_exists);

            if node_distance < closest_node_distance {
                closest_node_id = node_id;
                closest_node_distance = node_distance;
            }
        }

        return closest_node_id != -1, closest_node_id;
    }

    while priority_queue.count > 0 {
        found_closest_node, current_node_id := find_closest_node_id(priority_queue, ids_to_distances);
        assert(found_closest_node);

        if current_node_id == target_id break;

        // Consider all of its neighbors and update their distances through the current node
        for edge: edges {
            node_id     := edge.from;
            neighbor_id := edge.to;

            if node_id != current_node_id continue;

            neighbor_already_visited, _ := table_find(*visited_nodes_set, neighbor_id);
            if neighbor_already_visited continue;

            current_node_distance_exists, current_node_distance         := table_find(*ids_to_distances, node_id);
            current_neighbor_distance_exists, current_neighbor_distance := table_find(*ids_to_distances, neighbor_id);

            // Pretty sure these should always exist. Although, if you're running into this and realize that they can,
            // don't be afraid to change these asserts.
            assert(current_node_distance_exists);
            assert(current_neighbor_distance_exists);

            potential_neighbor_distance := current_node_distance + edge.distance;

            if potential_neighbor_distance < current_neighbor_distance {
                table_set(*ids_to_distances, neighbor_id, potential_neighbor_distance);
                table_set(*priority_queue, neighbor_id, null);
                table_set(*predecessors, neighbor_id, current_node_id);
            }
        }

        table_remove(*priority_queue, current_node_id);
        table_set(*visited_nodes_set, current_node_id, null);
    }

    // Calculate the path
    reverse_path : [..] s32;
    final_path   : [..] s32;
    current_node_id := target_id;

    while true {
        array_add(*reverse_path, current_node_id);
        next_predecessor_found, next_predecessor := table_find(*predecessors, current_node_id);
        if !next_predecessor_found break;
        current_node_id = next_predecessor;
    }

    for 0..reverse_path.count-1 array_add(*final_path, reverse_path[reverse_path.count-1 - it]);

    return final_path;
}

table_print :: (table: Table, table_name: string = "") {
    if String.equal(table_name, "") {
        print("{\n");
    } else {
        print("%: {\n");
    }

    for table {
        key, value := it_index, it;
        print("[%]: %\n", key, value);
    }

    print("}\n");
}