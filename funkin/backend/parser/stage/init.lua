local f = "funkin.backend.parser.stage."

local vslice = require(f..'vslice')
local codename = require(f..'codename')

local StageParse = {}

function StageParse.get(stage)
	return paths.exists(paths.getPath("data/stages/" .. stage .. ".xml"), "file") and paths.getXML("data/stages/" .. stage).stage
		or paths.getJSON("data/stages/" .. stage)
end

function StageParse.getParser(data)
	if data.version ~= nil then
		return vslice
	elseif data.children ~= nil then
		return codename
	end
	return false
end

return StageParse
