-- The function get_name() should return a single string that is the name of the puzzle.
--
function get_name()
	return "FLOOR OF LOGS"
end

-- Shows in TILE_JOURNAL output
function get_creator()
	return "killerbee13"
end

-- The function get_description() should return an array of strings, where each string is
-- a line of description for the puzzle. The text you return from get_description() will 
-- be automatically formatted and wrapped to fit inside the puzzle information box.
--
function get_description()
	return {
		"FOR EVERY VALUE V OF IN.A,",
		"LET S BE THE PARTIAL SUM UP TO V:",
		"WRITE FLOOR(LOG_2(S)) TO OUT.L    ", -- blank line with no >
		"V IN RANGE [0,999] INCLUSIVE,",
		"S SHALL NOT EXCEED 32,767"
	}
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
function trunc(x)
	return x-math.floor(x)
end

function get_streams()
	input = {}
	output = {}
	--totals = {}
	--bounds = {}
  total = 0
	upperbound = 10
	last_log = 0
	--special = {}
	for i = 1,39 do
		-- print(math.floor(upperbound))
		-- special[i] = 1000*trunc(last_log)
		
		-- When very close to a power of two, this ensures that at least some of the time, it approaches that power by a smaller number, to ensure that even lower bits are tracked accurately by the solution
		if trunc(last_log) > 0.8 and math.random() < 0.5 then
			lb = math.floor((2^math.ceil(math.log(total,2))-total)*0.8)-10
			ub = math.ceil((2^math.ceil(math.log(total,2))-total)*1.2)+10
			if lb < 0 then
				lb = 0
			end
			if ub > upperbound then
				ub = upperbound
			end
			input[i] = math.random(lb, ub)
			-- print("R(" .. lb .. ", " .. ub ..")!!", "-> " .. input[i], 2^math.ceil(math.log(total,2))-total)
		-- when the total is already large, the distribution changes to favor larger numbers, which gives a roughly 18% chance to exceed 2^14 (but never in a fixed test)
		elseif total > 1600 and math.random() < 0.5 then
			input[i] = math.random(750,999)
			-- print("R(750, 999)!", "-> " .. input[i])
		else
			input[i] = math.random(0, math.floor(upperbound))
			-- print("R(0, "..math.floor(upperbound)..")", "-> " .. input[i])
		end
		-- numbers steadily increase over the test, ensuring that the first few powers aren't completely skipped over
		upperbound = 10 + (989/39)*i
		total = total + input[i]
		last_log = math.log(total, 2)
		output[i] = math.floor(last_log)
		-- print(total, last_log, trunc(last_log))
	end
	-- print(total)
	if total > 32767 then
		print(total .. " >= 2^15")
	end
	return {
		{ STREAM_INPUT, "IN.A", 1, input },
		{ STREAM_OUTPUT, "OUT.L", 2, output },
		--{ STREAM_INPUT, "DBG.S", 2, special },
		--{ STREAM_INPUT, "DBG.B", 2, bounds },
		--{ STREAM_INPUT, "DBG.T", 3, totals },
	}
end
-- The function get_layout() should return an array of exactly 12 TILE_* values, which
-- describe the layout and type of tiles found in the puzzle.
--
-- TILE_COMPUTE: A basic execution node (node type T21).
-- TILE_MEMORY: A stack memory node (node type T30).
-- TILE_DAMAGED: A damaged execution node, which acts as an obstacle.
-- TILE_JOURNAL: A damaged execution node, which shows the puzzle creator's name
--
function get_layout()
	return { 
		TILE_COMPUTE,	TILE_COMPUTE,	TILE_COMPUTE,	TILE_COMPUTE,
		TILE_COMPUTE,	TILE_COMPUTE,	TILE_COMPUTE,	TILE_COMPUTE,
		TILE_JOURNAL,	TILE_COMPUTE,	TILE_COMPUTE,	TILE_COMPUTE,
	}
end
