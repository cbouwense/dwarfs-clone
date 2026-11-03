#import "Basic";
#import "Hash_Table";
#import "Input";
#import "Math";
#import "Print_Vars";
#import "Random";
#import "Sloppy_Math";
#import "Sort";
#import "String";
#import "System";

#import "raylib";

main :: () {
    perlin_noise_result := perlin_noise_1d(100, 4, 5, 3);
    for perlin_noise_result print("%, ", it);
}

perlin_noise_2d :: ($DESIRED_VALUES: s32, starting_frequency: s32 = 1, starting_amplitude: float32 = 1.0, octaves: s32 = 1) -> perlin_2d: [] float {
    assert(DESIRED_VALUES > 0,     "You probably want a positive DESIRED_VALUES. If not, delete this assertion.");
    assert(starting_frequency > 0, "You probably want a positive starting_frequency. If not, delete this assertion.");
    assert(octaves > 0,            "You probably want a positive octaves. If not, delete this assertion.");
    assert(DESIRED_VALUES % starting_frequency == 0, "The perlin noise frequency must be a divisor of the number of desired values.");

    results : [..] float;
    random_grid_gradients: [..] Vector2;
    for i: 0..(DESIRED_VALUES * DESIRED_VALUES - 1) {
        array_add(*results, 0.0);
    }

    for octave: 1..octaves {
        random_grid_gradients.count = 0;

        octave_factor       := pow(2.0, cast(float) octave - 1);
        amplitude           := starting_amplitude / octave_factor;
        frequency           := cast(int) (starting_frequency * octave_factor);
        blocks_per_section  := cast(int) (DESIRED_VALUES / frequency);
        max_raw_noise_value := blocks_per_section * sqrt(2) / 2;

        assert(blocks_per_section > 0, "Got zero blocks per section during 2d perlin noise generation. You probably have too many octaves.");
        
        for row: 0..frequency {
            for col: 0..frequency {
                gradient_x := random_get_within_range(-1.0, 1.0);
                gradient_y := random_get_within_range(-1.0, 1.0);
                gradient   := Vector2Normalize(Vector2.{ gradient_x, gradient_y });

                array_add(*random_grid_gradients, gradient);
            }
        }

        for row: 0..DESIRED_VALUES-1 {
            for col: 0..DESIRED_VALUES-1 {
                curr := Vector2.{ xx col, xx row };
                
                // The absolute coordinates of the current grid's corners that the point is within. 
                north_west := Vector2.{ xx (col - (col % blocks_per_section)), xx (row - (row % blocks_per_section)) }; 
                north_east := Vector2.{ xx (col - (col % blocks_per_section) + blocks_per_section), xx (row - (row % blocks_per_section)) };
                south_west := Vector2.{ xx (col - (col % blocks_per_section)), xx (row - (row % blocks_per_section) + blocks_per_section) };
                south_east := Vector2.{ xx (col - (col % blocks_per_section) + blocks_per_section), xx (row - (row % blocks_per_section) + blocks_per_section) };
                
                // The absolute distance between the current point and the grid's corners.
                north_west_delta := Vector2Subtract(north_west, curr);
                north_east_delta := Vector2Subtract(north_east, curr);
                south_west_delta := Vector2Subtract(south_west, curr);
                south_east_delta := Vector2Subtract(south_east, curr);

                // The indices of the array holding the gradient vectors for each of the grid corners.
                north_west_gradient_index := cast(int) ((north_west.x / blocks_per_section) + (north_west.y / blocks_per_section * (frequency + 1)));
                north_east_gradient_index := cast(int) ((north_east.x / blocks_per_section) + (north_east.y / blocks_per_section * (frequency + 1)));
                south_west_gradient_index := cast(int) ((south_west.x / blocks_per_section) + (south_west.y / blocks_per_section * (frequency + 1)));
                south_east_gradient_index := cast(int) ((south_east.x / blocks_per_section) + (south_east.y / blocks_per_section * (frequency + 1)));

                // The gradient vectors for each of the grid corners.
                north_west_gradient := random_grid_gradients[north_west_gradient_index];
                north_east_gradient := random_grid_gradients[north_east_gradient_index];
                south_west_gradient := random_grid_gradients[south_west_gradient_index];
                south_east_gradient := random_grid_gradients[south_east_gradient_index];

                // The dot product of each gradient vector with the corresponding distance vector.
                north_west_dot := dot_product(north_west_gradient, north_west_delta);
                north_east_dot := dot_product(north_east_gradient, north_east_delta);
                south_west_dot := dot_product(south_west_gradient, south_west_delta);
                south_east_dot := dot_product(south_east_gradient, south_east_delta);

                // Percent traveled the grid in each direction. So if 30% of the way through the x coords,
                // t_x would be 0.300000.
                t_x := abs((curr.x - north_west.x) / blocks_per_section);
                t_y := abs((curr.y - north_west.y) / blocks_per_section);

                north_lerp := lerp(north_west_dot, north_east_dot, smootherstep(t_x));
                south_lerp := lerp(south_west_dot, south_east_dot, smootherstep(t_x));
                perlin     := lerp(north_lerp, south_lerp, smootherstep(t_y));

                results[row * DESIRED_VALUES + col] += amplitude * (perlin / max_raw_noise_value);
            }
        }
    }

    return results;
}

smootherstep :: (x: float) -> float {
    if x <= 0.0 return 0.0;
    if x >= 1.0 return 1.0;
    return (6 * x * x * x * x * x) - (15 * x * x * x * x) + (10 * x * x * x); 
}

perlin_noise_1d :: (desired_values: s32, starting_frequency: s32, starting_amplitude: float32, octaves: s32, min_value := 0.0) -> [..] float {
    assert(desired_values > 0,     "You probably want a positive desired_values. If not, delete this assertion.");
    assert(starting_frequency > 0, "You probably want a positive starting_frequency. If not, delete this assertion.");
    assert(octaves > 0,            "You probably want a positive octaves. If not, delete this assertion.");
    assert(desired_values % starting_frequency == 0, "The perlin noise frequency must be a divisor of the number of desired values.");

    results : [..] float;
    for i: 0..desired_values {
        array_add(*results, 0.0);
    }

    for o: 0..octaves {
        octave_factor      := pow(2.0, cast(float) o);
        amplitude          := starting_amplitude / octave_factor;
        frequency          := starting_frequency * octave_factor;
        ratio              := desired_values / frequency;
        blocks_per_section := cast(int) (desired_values / frequency);

        random_grid_scalars: [..]float;
        for i: 0..(xx frequency-1) {
            array_add(*random_grid_scalars, random_get_within_range(-1, 1));
        }

        // @TODO: maybe loop around to the first section's left gradient?
        for i: 0..(desired_values - (blocks_per_section + 1)) {
            // Get distance from current tile to each grid corner
            f := floor(cast(float) i / ratio);
            delta_l := (i - ratio * f) / blocks_per_section;
            delta_r := (ratio * (f + 1) - i) / blocks_per_section;

            // Get dot products of grid corner vectors and distances
            l_scalar := random_grid_scalars[cast(int) (f)];
            r_scalar := random_grid_scalars[cast(int) (f + 1)];
            l_dot : float = l_scalar * delta_l;
            r_dot : float = r_scalar * delta_r;

            perlin := lerp(l_dot, r_dot, smootherstep(delta_l));
            results[i] += amplitude * perlin;
        }
    }

    // @PERF
    for *results {
        if it.* < min_value {
            it.* = min_value + abs(it.*);
        }
    }

    return results;
}