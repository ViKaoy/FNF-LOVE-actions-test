local codename = {name = "Codename"}

local function parseIndices(s)
	local indices = {}

	for i in s:gmatch("[^,]+") do
		for r_s, r_e in i:gmatch("(%d+)%.%.(%d+)") do
			if r_s ~= nil and r_e ~= nil then
				for j = tonumber(r_s), tonumber(r_e) do
					table.insert(indices, j)
				end
			else
				table.insert(indices, tonumber(i))
			end
		end
	end

	print(unpack(indices)) -- TODO: remove this line when fully tested
	return indices
end

function codename.parse(data, name)
	local char = Parser.getDummyChar()

	for _, anim in ipairs(data.children) do
		if anim.name == "anim" then
			local animation = {
				anim.attrs.name,
				anim.attrs.anim,
				anim.attrs.indices ~= nil and parseIndices(anim.attrs.indices) or {},
				tonumber(anim.attrs.fps),
				anim.attrs.loop == "true",
				{tonumber(anim.attrs.x) or 0, tonumber(anim.attrs.y) or 0}
			}

			table.insert(char.animations, animation)
		end
	end

	Parser.pset(char, "position", {tonumber(data.attrs.x) or 0, tonumber(data.attrs.y) or 0})
	Parser.pset(char, "camera_points", {tonumber(data.attrs.camx) or 0, tonumber(data.attrs.camy) or 0})
	Parser.pset(char, "sing_duration", tonumber(data.attrs.holdTime) or 4)
	Parser.pset(char, "dance_beats", tonumber(data.attrs.interval))

	if data.attrs.flipX ~= nil then
		Parser.pset(char, "flip_x", tobool(data.attrs.flipX))
	end
	Parser.pset(char, "icon", data.attrs.icon or name)
	Parser.pset(char, "sprite", "characters/" .. (data.attrs.sprite or name))
	if data.attrs.antialiasing ~= nil then
		Parser.pset(char, "antialiasing", tobool(data.attrs.antialiasing))
	end
	Parser.pset(char, "scale", tonumber(data.attrs.scale) or 1)

	if data.attrs.color ~= nil then
		char.color = data.attrs.color
	end

	return char
end

return codename
