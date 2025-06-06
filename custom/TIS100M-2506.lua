function get_name()
    return "TLV DATA ROUTER"
end

function get_creator()
    return "Hersmunch"
end

function get_description()
    return {"Route TLV data from IN.TLV to the corresponding output.", 
	        "T: Tag - which output to write to",
            "L: Length - of the sequence",
			"V: Values - the sequence's data",
			"Zero-Terminate output sequences"}
end

function get_streams()
    for i = 1, 5 do
		math.random(0, 42)
	end

    local input = {}
    local outputs = {{}, {}, {}, {}}
    local total_length = 0

    while total_length < 39 do
        local remaining_space = 39 - total_length
        local max_length = math.min(5, remaining_space - 2) -- Ensure room for Tag and Length
        if max_length <= 0 then
            break
        end

        local tag = math.random(0, 3)
        table.insert(input, tag)

        local length = math.random(1, max_length)
        table.insert(input, length)
        total_length = total_length + 2 -- Add 2 for Tag and Length

        local sequence = {}
        for j = 1, length do
            local value = math.random(10, 99)
            table.insert(input, value)
            table.insert(outputs[tag + 1], value)
            total_length = total_length + 1
        end
        table.insert(outputs[tag + 1], 0)
    end

    return {{STREAM_INPUT, "IN.TLV", 1, input}, {STREAM_OUTPUT, "OUT.0", 0, outputs[1]},
            {STREAM_OUTPUT, "OUT.1", 1, outputs[2]}, {STREAM_OUTPUT, "OUT.2", 2, outputs[3]},
            {STREAM_OUTPUT, "OUT.3", 3, outputs[4]}}
end

function get_layout()
    return {TILE_COMPUTE, TILE_COMPUTE, TILE_JOURNAL, TILE_COMPUTE,
	        TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE, 
			TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE, TILE_COMPUTE}
end
