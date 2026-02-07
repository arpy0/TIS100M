function get_name()
	return "SAWTOOTH GENERATOR"
end

function get_creator()
	return "EASONE"
end

function get_description()
	return { "Read amplitude \"A\" from IN", "Read period \"P\" from IN", "Output a repeating signal which ramps linearly from 0 to \"A\", taking \"P\" total steps", "Round non-integer values down" }
end

function get_streams()

	for i = 1,17 do
		math.random(0,100)
	end

	amplitude = math.random(0,50)
	period = math.random(3,13)
	output = {}

	for i = 1,39 do
		output[i] = ((i-1)%period)*amplitude/(period-1)
	end
	return {
		{ STREAM_INPUT, "IN", 1, {amplitude, period} },
		{ STREAM_OUTPUT, "OUT", 1, output },
	}
end

function get_layout()	
	return { 
		TILE_MEMORY, 	TILE_COMPUTE, 	TILE_COMPUTE, 	TILE_COMPUTE,
		TILE_COMPUTE, 	TILE_COMPUTE,	TILE_COMPUTE, 	TILE_COMPUTE,
		TILE_MEMORY, 	TILE_COMPUTE,	TILE_COMPUTE, 	TILE_JOURNAL,
	}
end