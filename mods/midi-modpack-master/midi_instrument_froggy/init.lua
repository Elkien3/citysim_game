----------------------------------------
-- Pitches
----------------------------------------

local pitch_down, pitch_up = (0.5 ^ (1 / 12)), (2 ^ (1 / 12))
local pitches = {
	Gs = {scale = "A",  pitch = pitch_down},
	As = {scale = "A",  pitch = pitch_up},
	D  = {scale = "Ds", pitch = pitch_down},
	E  = {scale = "Ds", pitch = pitch_up},
	F  = {scale = "Fs", pitch = pitch_down},
	G  = {scale = "Fs", pitch = pitch_up},
	B  = {scale = "C",  pitch = pitch_down},
	Cs = {scale = "C",  pitch = pitch_up}
}

----------------------------------------
-- Getting sound functions
----------------------------------------

local function select_velocity_number(velocity)
	local function range(v, lovel, hivel)
		if hivel then
			return (v >= lovel) and (v <= hivel)
		else
			return (v >= lovel)
		end
	end

	return (range(velocity, 1,   22)  and 1)
		or (range(velocity, 23,  45)  and 2)
		or (range(velocity, 46,  67)  and 3)
		or (range(velocity, 68,  89)  and 4)
		or (range(velocity, 80,  103)  and 5)
		or (range(velocity, 104)    and 6)
		or 3 -- Else
end

local function calc_gain(velocity, amp_veltrack)
	--local gain = 20 * math.log(velocity, 10)
	--return gain + (gain * (amp_veltrack / 100))
	return velocity/amp_veltrack
end

local function get_noteon_sounds(sounds, note)
	-- Note
	do
		local scale_with_pitch = midi.get_scale(note.number):gsub("#", "s")
		local scale, scalenumber = scale_with_pitch:match("(.+)(%d)")
		local pitch = 1

		local scaledef = pitches[scale]
		if scaledef then
			if (scale == "B") then
				scalenumber = scalenumber + 1
			end

			scale_with_pitch = scaledef.scale .. scalenumber
			pitch = scaledef.pitch
		end

		local amp_veltrack = 73

		local sound = scale_with_pitch .. "v" .. select_velocity_number(note.velocity)
		local gain = calc_gain(note.velocity, amp_veltrack)

		table.insert(sounds, {name = ("midi_instrument_salamander_" .. sound), gain = gain, pitch = pitch})
	end

	-- HammerNoise
	if minetest.settings:get_bool("midi.salamander.hammernoise") then
		if (note.number >= 21) and (note.number <= 108) then
			local volume = -37
			local amp_veltrack = 82 * (100 / (volume + 150))

			local sound = "rel" .. (note.number - 20)
			local gain = calc_gain(note.velocity, amp_veltrack) / 500

			table.insert(sounds, {name = ("midi_instrument_salamander_" .. sound), gain = gain, pitch = 1})
		end
	end
end

local function get_noteoff_sounds(sounds, note)
	--if true then return end
	-- Pedal
	if minetest.settings:get_bool("midi.salamander.pedal") then
		-- Pedal 1
		do
			local volume = -20
			local amp_veltrack = 100 / (volume + 150)

			local sound = "pedalD" .. math.random(1, 2)
			local gain = calc_gain(note.velocity, amp_veltrack)
			table.insert(sounds, {name = ("midi_instrument_salamander_" .. sound), gain = gain, pitch = 1})
		end

		-- Pedal 2
		do
			local volume = -19
			local amp_veltrack = 100 / (volume + 150)

			local sound = "pedalU" .. math.random(1, 2)
			local gain = calc_gain(note.velocity, amp_veltrack)

			table.insert(sounds, {name = ("midi_instrument_salamander_" .. sound), gain = gain, pitch = 1})
		end
	end
end

local function get_sounds(note)
	local sounds = {}

	if (note.type == "on") then
		get_noteon_sounds(sounds, note)
	elseif (note.type == "off") then
		get_noteoff_sounds(sounds, note)
	end
	
	return sounds
end

----------------------------------------
-- Register
----------------------------------------

for i = 0, 7 do -- 0 ~ 7: Piano
	midi.register_instrument(i, {
		description = "Froggy",
		get_sounds  = get_sounds
	})
end
