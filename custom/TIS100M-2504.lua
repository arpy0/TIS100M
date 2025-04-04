function get_name()
	return "FACTOR SUM"
end

function get_creator()
	return "David"
end

function get_description()
	return {
		"READ A VALUE FROM IN.",
		"WRITE SUM OF DIVISORS TO OUT.",
	}
end

function sum_of_divisors(n)
	if n <= 0 then
		return 0
	end

	local sum = 0
	local sqrt_n = math.sqrt(n)

	for i = 1, sqrt_n do
		if n % i == 0 then
			sum = sum + i
			if i ~= n / i then
				sum = sum + (n / i)
			end
		end
	end

	return sum
end

function get_streams()
	input = {}
	output = {}
	for i = 1, 39 do
		input[i] = math.random(1, 250)
		output[i] = sum_of_divisors(input[i])
	end

	return {
		{ STREAM_INPUT, "IN", 0, input },
		{ STREAM_OUTPUT, "OUT", 3, output },
	}
end

-- stylua: ignore
function get_layout()
	return { 
		TILE_COMPUTE, 	TILE_COMPUTE, 	TILE_COMPUTE, 	TILE_DAMAGED,
		TILE_COMPUTE, 	TILE_COMPUTE,	TILE_COMPUTE, 	TILE_COMPUTE,
		TILE_JOURNAL, 	TILE_COMPUTE,	TILE_COMPUTE, 	TILE_COMPUTE,
	}
end
