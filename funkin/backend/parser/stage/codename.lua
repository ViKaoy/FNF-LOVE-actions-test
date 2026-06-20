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

local characterSwitch = {
    [{"boyfriend", "bf", "player"}] = function() return "bf" end,
    [{"dad", "opponent"}] = function() return "dad" end,
    [{"girlfriend", "gf"}] = function() return "gf" end
}

function codename.parse(data)
    local stage = Parser.getDummyStage()

    Parser.pset(stage, "name", data.attrs.name)
    Parser.pset(stage, "cameraZoom", tonumber(data.attrs.zoom))
    Parser.pset(stage, "version", "1.0.0")

    local props = {}
    local characters = {}

    for k, v in pairs(data.children) do
        local p = {}
        local character = ""

        if v.name == "sprite" then
            p.name = v.attrs.name
            p.position = {tonumber(v.attrs.x) or 0, tonumber(v.attrs.y) or 0}
            p.scroll = {tonumber(v.attrs.scrollx ~= nil and v.attrs.scrollx or v.attrs.scroll) or 0, tonumber(v.attrs.scrolly ~= nil and v.attrs.scrolly or v.attrs.scroll) or 0}
            p.animType = "sparrow"
            p.assetPath = v.attrs.sprite
            p.scale = {tonumber(v.attrs.scalex ~= nil and v.attrs.scalex or v.attrs.scale) or 1, tonumber(v.attrs.scaley ~= nil and v.attrs.scaley or v.attrs.scale) or 1}
            if v.attrs.antialiasing ~= nil then
                p.isPixel = not tobool(v.attrs.antialiasing)
            end
            if v.attrs.alpha ~= nil then
                p.alpha = tonumber(v.attrs.alpha) or 1
            end

            if v.children then
                p.animations = {}
                for _, anim in ipairs(v.children) do
                    if anim.name == "anim" then
                        local animation = {}
                        animation.name = anim.attrs.name
                        animation.prefix = anim.attrs.anim
                        animation.looped = anim.attrs.loop == "true"
                        if anim.attrs.fps ~= nil then
                            animation.frameRate = tonumber(anim.attrs.fps)
                        end
                        if anim.attrs.x ~= nil or anim.attrs.y ~= nil then
                            animation.offsets = {tonumber(anim.attrs.x) or 0, tonumber(anim.attrs.y) or 0}
                        end
                        if anim.attrs.indices then
                            animation.frameIndices = parseIndices(anim.attrs.indices)
                        end
                    end
                end
            end
        elseif v.name == "solid" or v.name == "box" then
            p.name = v.attrs.name
            p.position = {tonumber(v.attrs.x) or 0, tonumber(v.attrs.y) or 0}
            p.scale = {tonumber(v.attrs.width) or 1, tonumber(v.attrs.height) or 1}
            p.scroll = {tonumber(v.attrs.scrollx ~= nil and v.attrs.scrollx or v.attrs.scroll) or 0, tonumber(v.attrs.scrolly ~= nil and v.attrs.scrolly or v.attrs.scroll) or 0}
            p.assetPath = v.attrs.color
            if v.attrs.alpha ~= nil then
                p.alpha = tonumber(v.attrs.alpha) or 1
            end
        elseif switch(v.name, characterSwitch) ~= nil then
            character = switch(v.name, characterSwitch)
            p.position = {tonumber(v.attrs.x) or 0, tonumber(v.attrs.y) or 0}
            if v.attrs.camxoffset ~= nil or v.attrs.camyoffset ~= nil then
                p.cameraOffsets = {tonumber(v.attrs.camxoffset) or 0, tonumber(v.attrs.camyoffset) or 0}
            end
            if v.attrs.alpha ~= nil then
                p.alpha = tonumber(v.attrs.alpha) or 1
            end
            if v.attrs.scale ~= nil then
                p.scale = tonumber(v.attrs.scale) or 1
            end
        end
        p.zIndex = k

        if character ~= "" then
            characters[character] = p
        else
            table.insert(props, p)
        end
    end

    Parser.pset(stage, "props", props)
    Parser.pset(stage, "characters", characters)

    return stage
end

return codename
