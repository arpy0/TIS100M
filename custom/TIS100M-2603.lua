
function get_name()
	return "LOWPASS FILTER"
end

function get_creator()
    return "anotak"
end

function get_description()
	return { "TAKE THE AVERAGE OF THE CURRENT INPUT AND PREVIOUS OUTPUT, ROUNDED DOWN", "", "INPUT IS BETWEEN [0, 8]" }
end

function get_streams()
	local input = {}
    local output = {}
    
    -- just advancing the seed some so we get a first few values that teach whats going on here better
    math.random(69, 420)
    math.random(69, 420)
    math.random(69, 420)
    
    local previous = 0
    
    for i = 1,39 do
        if math.random(0, 100) > 50 then
            input[i] = math.random(0, 8)
        else
            input[i] = 0
        end
        
        output[i] =  math.floor((input[i] + previous) / 2)
        previous = output[i]
    end
	return {
		{ STREAM_INPUT, "IN.A", 3, input },
		{ STREAM_OUTPUT, "OUT.A", 3, output },
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
		TILE_MEMORY, 	TILE_COMPUTE, 	TILE_COMPUTE, 	TILE_COMPUTE,
		TILE_DAMAGED, 	TILE_COMPUTE,	TILE_COMPUTE, 	TILE_DAMAGED,
		TILE_COMPUTE, 	TILE_COMPUTE,	TILE_COMPUTE, 	TILE_COMPUTE,
	}
end