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
    RES :: 512;
    InitWindow(RES, RES, "Perlin Noise Debugger");
    defer CloseWindow();

    noise_data := perlin_noise_2d(RES, starting_frequency=8, starting_amplitude=2, octaves=1);
    defer array_free(noise_data);

    pixels := cast(*Color) alloc(RES * RES * size_of(Color));
    defer free(pixels);

    for i: 0..(RES * RES)-1 {
        // 1. Correctly map raw noise [-1.0, 1.0] to a [0.0, 1.0] range
        normalized := (noise_data[i] + 1.0) / 2.0; 
        
        // 2. Clamp just in case floating point math slightly overshoots
        clamped := clamp(normalized, 0.0, 1.0);

        // 3. Map to colors
        THRESHOLD :: .95; // 0.90 means the top 10% of values.
        
        if clamped >= THRESHOLD {
            // Map the top 90% to pure Red
            pixels[i] = Color.{255, 0, 0, 255}; 
        } else {
            // Map the bottom 10% to standard grayscale
            val := cast(u8) (clamped * 255.0);
            pixels[i] = Color.{val, val, val, 255}; 
        }
    }

    // Load into GPU
    img := Image.{
        data = pixels,
        width = RES,
        height = RES,
        mipmaps = 1,
        format = .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8
    };
    texture := LoadTextureFromImage(img);

    while !WindowShouldClose() {
        BeginDrawing();
        ClearBackground(BLACK);
        
        DrawTexture(texture, 0, 0, WHITE);
        
        DrawRectangle(10, 10, 280, 40, Color.{0, 0, 0, 150});
        DrawText("Press 'S' to save as PNG", 20, 20, 20, RAYWHITE);
        
        if IsKeyPressed(.KEY_S) ExportImage(img, "debug_noise.png");
        
        EndDrawing();
    }
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