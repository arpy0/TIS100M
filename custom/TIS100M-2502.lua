-- The function get_name() should return a single string that is the name of the puzzle.
--
function get_name()
return "FIND"
end

function get_creator()
return "Hersmunch"
end

-- The function get_description() should return an array of strings, where each string is
-- a line of description for the puzzle. The text you return from get_description() will 
-- be automatically formatted and wrapped to fit inside the puzzle information box.
--
function get_description()
return { "SEQUENCES ARE ZERO-TERMINATED",
"READ A SEQUENCE FROM IN.V",
"READ VALUE TO FIND FROM IN.X",
"LOOK UP VALUE IN SEQUENCE",
"WRITE INDEX OF VALUE TO OUT, OR -1 IF THE VALUE IS NOT FOUND"}
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

function make_random_array(size, min, max)
array = {}
for i = 1, size do
array[i] = math.random(min, max)
end
return array
end

function get_streams()
for i = 1, 5 do
math.random(0, 42)
end

input_v = make_random_array(10, 100, 999)
input_v[11] = 0
output = make_random_array(39, 0, 9)
input_x = {}
for i = 1, 39 do
if math.random(0,9) == 0 then
input_x[i] = math.random(100, 999)
else
input_x[i] = input_v[output[i]+1]
end
for j = 1, 10 do
if input_v[j] == input_x[i] then
output[i] = j-1
break
end
output[i] = -1
end
end

return {
{ STREAM_INPUT, "IN.X", 1, input_x },
{ STREAM_INPUT, "IN.V", 3, input_v },
{ STREAM_OUTPUT, "OUT", 1, output },
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
TILE_JOURNAL, TILE_COMPUTE, TILE_MEMORY, TILE_COMPUTE,
TILE_COMPUTE, TILE_COMPUTE,TILE_COMPUTE, TILE_COMPUTE,
TILE_COMPUTE, TILE_COMPUTE,TILE_MEMORY, TILE_COMPUTE,
}
end