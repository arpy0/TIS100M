
function get_name()
    return "FEEDBACK DELAY LINE"
end


function get_creator()
    return "anotak"
end

function get_description()
    return { "OUTPUT = INPUT PLUS OUTPUT FROM THREE SAMPLES AGO DIVIDED BY TWO, ROUNDED DOWN", "", "INPUT IS BETWEEN [0, 8]" }
end


function get_streams()
    local input = {}
    local output = {}
    local previous = {0,0,0}
    
    -- just advancing the seed some so we get a first few values that teach whats going on here better
    -- specifically we want to show the range of the outputs properly
    for i = 1,31 do
        math.random(69, 420)
    end
    
    for i = 1,39 do
        if math.random(0, 100) > 30 or i < 3 then
            input[i] = math.random(0, 8)
        else
            input[i] = 0
        end
        
        local p = math.floor(previous[i] / 2)
        
        if p < 0 then
            p = p + 1
        end
        
        output[i] = input[i] + p
        previous[i+3] = output[i]
    end
    return {
        { STREAM_INPUT, "INPUT", 2, input },
        { STREAM_OUTPUT, "OUTPUT", 1, output },
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
        TILE_COMPUTE,     TILE_COMPUTE,     TILE_COMPUTE,     TILE_MEMORY,
        TILE_COMPUTE,     TILE_MEMORY,      TILE_COMPUTE,     TILE_COMPUTE,
        TILE_COMPUTE,     TILE_COMPUTE,     TILE_COMPUTE,     TILE_MEMORY,
    }
end