
function get_name()
	return "PRNG ATTACK"
end

function get_creator()
    return "anotak"
end

function get_description()
    return {
    "EVERY INPUT IS EQUAL TO THE PREVIOUS INPUT TIMES M PLUS C, MODULO 16",
    "M IS EITHER 3, 5, 11, or 13.",
    "C IS AN ODD NUMBER 1-15."}
end

function get_streams()
    local input = {}
    
    local max = 16
    local seed = math.random(5, max-1)
    local possibilities = {3, 5, 11, 13}
    
    -- bump the prng some to get a result that teaches the mechanisms better
    for i = 1,4 do
        math.random(1, 2)
    end
    local multiplier = possibilities[math.random(1, #possibilities)]
    
    
    
    local c = math.random(1, max-1)
    
    if c % 2 == 0 then
        c = c + 1
    end
    
    for i = 1,39 do
        seed = (seed * multiplier + c) % max
        
        input[i] = seed
    end
    
    return {
        { STREAM_INPUT, "IN.A", 1, input },
        { STREAM_OUTPUT, "OUT.M", 2, {multiplier} },
        { STREAM_OUTPUT, "OUT.C", 3, {c} },
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
		TILE_JOURNAL, 	TILE_COMPUTE,	TILE_COMPUTE, 	TILE_COMPUTE,
		TILE_COMPUTE, 	TILE_COMPUTE,	TILE_COMPUTE, 	TILE_COMPUTE,
	}
end