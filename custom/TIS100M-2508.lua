-- The function get_name() should return a single string that is the name of the puzzle.
--
function get_name()
	return "TIS-SCM"
end

-- The function get_description() should return an array of strings, where each string is
-- a line of description for the puzzle. The text you return from get_description() will 
-- be automatically formatted and wrapped to fit inside the puzzle information box.
--
function get_description()
	--return {"WARNING: You are attempting to interface with the TIS SECURE COMMUNICATIONS MODULE", "This subsystem is proprietary and highly classified. Tampering will be reported to the authorities."}
	return {"LOADING MODULE @ 0x1A3F5C", "MODULE: SECURE COMMS MODULE","ID: TIS-SCM-X9F4 | STATUS: RED ","ACCESS VIOLATION DETECTED","REPORT SENT TO CENTRAL NODE", "TRACE IN PROGRESS..."}
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

-- Shows in TILE_JOURNAL output
function get_creator()
	return "Raniem & Hummingbird"
end

keys = {
	{21,8,6,4,13,4,17,4},
	{18,4,2,17,4,19},
	{10,4,24},
	{18,4,2,17,4,19},
	{18,4,18,0,12,4},
	{19,8,18},
	{19,7,4,5,14,17,2,4},
	{15,11,0,2,4,7,14,11,3,4,17} 
	}

plaintexts = {
		{11,14,17,4,12,8,15,18,20,12,3,14,11,14,17,18,8,19,0,12,4,19,2,14,13,18,4,2,19,4,19,20,17,0,3,8,15,8,18},
		{13,6,1,8,17,3,0,13,3,17,0,13,8,4,12,22,0,18,7,4,17,4},
		{19,8,18,1,20,19,0,18,2,17,0,19,2,7,0,18,2,17,0,19,2,7,24,14,20,17,0,17,12,18,14,5,5},
		{19,8,18,8,18,0,15,17,14,6,17,0,12,12,8,13,6,6,0,12,4,1,24,25,0,2,7,19,17,14,13,8,2,18},
		{18,0,12,15,11,4,19,4,23,19,18,0,12,15,11,4,3,5,17,14,12,19,4,23,19},
		{19,7,4,21,8,6,4,13,4,17,4,2,8,15,7,4,17,8,18,0,12,4,19,7,14,3,14,5,4,13,2,17,24,15,19,8,13,6}
	}



function get_streams()
	test = math.random()
	if test == 0.920463917274244 then --test 1
		key=keys[1]
		--key=keys[2]
		plain=plaintexts[6]
		cipher=decode()
	elseif test == 0.3668545910002918 then --test 2
		key=keys[6]
		plain=plaintexts[4]
		cipher=decode()
	elseif test == 0.8132452647263395 then --test 3
		key=keys[2]
		plain=plaintexts[2]
		cipher=decode()
	else --Random
		plain = selectRandomText()
		key = selectRandomKey()
		cipher = decode()
	end
	

    keyout = {unpack(key)}
	keyout[#keyout + 1] = -1

	return {
		{ STREAM_INPUT, "IN.C", 1, cipher },
		{ STREAM_INPUT, "IN.K", 3, keyout },
		{ STREAM_OUTPUT, "OUT.P", 1, plain },
	}
end

function selectRandomKey()
	k = keys[math.random(#keys)]
	return k
end

function selectRandomText()
	t = plaintexts[math.random(#plaintexts)]
	return t
end


function decode()
	c = {}
	for i = 1, #plain do
		imod = (i-1) %#key + 1
		c[i] = ((plain[i] + key[imod] )%26 )
	end
	return c
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
		TILE_JOURNAL, 	TILE_COMPUTE, 	TILE_COMPUTE, 	TILE_COMPUTE,
		TILE_COMPUTE, 	TILE_COMPUTE,	TILE_COMPUTE, 	TILE_MEMORY,
		TILE_MEMORY, 	TILE_COMPUTE,	TILE_MEMORY, 	TILE_COMPUTE,
	}
end