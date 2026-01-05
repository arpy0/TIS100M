-- The function get_name() should return a single string that is the name of the puzzle.
--
function get_name()
    return "JUGGLING VISUALISER"
end

function get_creator()
	return "Hersmunch"
end

-- The function get_description() should return an array of strings, where each string is
-- a line of description for the puzzle. The text you return from get_description() will 
-- be automatically formatted and wrapped to fit inside the puzzle information box.
--
function get_description()
    return {"Draw a space-time diagram of input sequences.",
	        "Values indicate the height an object is thrown at each time step.",
		    "0 means the hand is empty."}
end

function generate_random_juggling_sequence(num_objects, pattern_length, max_throw, num_swaps)
    local sequence = {}
    for i = 1, pattern_length do
        sequence[i] = num_objects
    end

    for _ = 1, num_swaps do
        while 1 do
            local idx1 = math.random(1, pattern_length)
            local idx2 = idx1
            while idx1 == idx2 do
                idx2 = math.random(1, pattern_length)
            end

            local new_throw1 = idx2 + sequence[idx2] - idx1
            local new_throw2 = idx1 + sequence[idx1] - idx2

            if new_throw1 >= 0 and new_throw1 <= max_throw and new_throw2 >= 0 and new_throw2 <= max_throw then
                sequence[idx1] = new_throw1
                sequence[idx2] = new_throw2
                break
            end  
        end
    end

    return sequence
end

function draw_spacetime_diagram(num_objects, sequence)
    local image = {}
    local objects = {}

    for i = 1, 30 * 18 do
        image[i] = 0
    end
    for i = 1, num_objects do
        objects[i] = i
    end

    for time = 1, #sequence do
        local throw = sequence[time]
        if throw > 0 then
            local colour = 0
            for i = 1, num_objects do
                if time == objects[i] then
                    colour = i
                    break
                end
            end
            local landing_time = (time + throw)
            objects[colour] = landing_time

            local scaled_time = 2 * time - 1
            local scaled_landing_time = 2 * landing_time - 1
            for t = scaled_time, scaled_landing_time - 1 do
                if t > 30 then
                    break
                end
                local row_offset = (t - scaled_time)
                if t >= scaled_time + throw then
                    row_offset = (scaled_landing_time - t - 1)
                end
                local row = 17 - row_offset
                local pixel_index = t + row * 30
                image[pixel_index] = colour
            end
        end
    end

    return image
end

-- The function get_streams() should return an array of streams. Each stream is described
-- by an array with exactly four values: a STREAM_* value, a name, a position, and an array
-- of integer values between -999 and 999 inclusive.
--
-- STREAM_INPUT: An input stream containing up to 39 numerical values.
-- STREAM_OUTPUT: An output stream containing up to 39 numerical values.
-- STREAM_IMAGE: An image output stream, containing exactly 30*18 numerical values between 0
--               and 4, representing the full set of "pixels" for the target image.
--
-- NOTE: Arrays in Lua are implemented as tables (dictionaries) with integer keys that start
--       at 1 by convention. The sample code below creates an input array of 39 random values
--       and an output array that doubles all of the input values.
--
-- NOTE: To generate random values you should use math.random(). However, you SHOULD NOT seed
--       the random number generator with a new seed value, as that is how TIS-100 ensures that
--       the first test run is consistent for all users, and thus something that allows for the
--       comparison of cycle scores.
--
-- NOTE: Position values for streams should be between 0 and 3, which correspond to the far
--       left and far right of the TIS-100 segment grid. Input streams will be automatically
--       placed on the top, while output and image streams will be placed on the bottom.
--
function get_streams()
    for i = 1, 5 do
		math.random(0, 42)
	end

    local num_objects = math.random(2, 4)
    local pattern_length = 15
    local max_throw = 8
    local num_swaps = pattern_length

    local sequence = generate_random_juggling_sequence(num_objects, pattern_length, max_throw, num_swaps)
    local image = draw_spacetime_diagram(num_objects, sequence)

    return {{STREAM_INPUT, "IN.A", 1, sequence},
            {STREAM_IMAGE, "OUT.A", 2, image}
    }
end

-- The function get_layout() should return an array of exactly 12 TILE_* values, which
-- describe the layout and type of tiles found in the puzzle.
--
-- TILE_COMPUTE: A basic execution node (node type T21).
-- TILE_MEMORY: A stack memory node (node type T30).
-- TILE_DAMAGED: A damaged execution node, which acts as an obstacle.
--
function get_layout()
	return { 
		TILE_MEMORY, 	TILE_COMPUTE, 	TILE_COMPUTE, 	TILE_JOURNAL,
		TILE_COMPUTE, 	TILE_COMPUTE,	TILE_COMPUTE, 	TILE_COMPUTE,
		TILE_MEMORY, 	TILE_COMPUTE,	TILE_COMPUTE, 	TILE_COMPUTE
	}
end
