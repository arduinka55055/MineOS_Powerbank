local GUI = require("GUI")
local system = require("System")
local component = require("component")
local event = require("Event")
local number = require("Number")
local unicode = require("Unicode")
local screen = require("Screen")
--local indus = require("INDUS_STYLE")
local BATSTAT={}
function BATSTAT.NewWindow(device)

	local battery = component.proxy(device)
	local workspace, window = system.addWindow(GUI.window(0, 0, 10, 10, 0xF0F0F0))

	--копипиздинг + очумелые ручки == программирование
	local function drawCustomProgressBar(object)
		local activeHeight = math.floor( (100-math.min(object.value, 100)) / 100 * object.height)                                                             --не говнокод, а ГОВНОКОДИЩЩЩЕЕЕ!!!!!!1111
		screen.drawRectangle(object.x, object.y, object.width, object.height, object.colors.active[math.min(math.floor(object.value/100*(#object.colors.active))+1,#object.colors.active)], 0x0, " ")
		screen.drawRectangle(object.x, object.y, object.width, activeHeight, object.colors.passive, 0x0, " ")

		local stringValue = object.value.." %"
		screen.drawText(math.floor(object.x + object.width / 2 - unicode.len(stringValue) / 2), object.y+object.height - 1, object.colors.value, stringValue)
		return object
	end


	function CustomProgressBar(x, y,width, height, activeColors, passiveColor, valueColor, value)
		local object = GUI.object(x, y, width, height)
		object.value = value
		object.colors = {active = activeColors, passive = passiveColor, value = valueColor}
		object.draw = drawCustomProgressBar
		return object
	end


	local meter=window:addChild(CustomProgressBar(1,1,10, 10, {0xFF0000,0xFFFF00,0x00FF00}, 0x1D1D1D, 0x000000, 0))
	--hello
	meter.value=0
	return function()
		meter.value=number.roundToDecimalPlaces(battery.getEnergyStored()/battery.getMaxEnergyStored()*100,1)
		workspace:draw()
	end,function()
		GUI.alert("goodbye world")
	end
end

return BATSTAT