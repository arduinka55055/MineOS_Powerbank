local shitometer = require(filesystem.path(system.getCurrentScript()).."BATSTAT.lua")
--local indus = require("INDUS_STYLE")
GUI.alert(shitometer)
removeus={}
for address, componentType in component.list() do
    if componentType == "filesystem" or componentType =="eeprom" or componentType =="gpu" or componentType == "screen" or componentType =="computer" or componentType == "keyboard" or componentType == "internet" or componentType == "redstone" then
    elseif string.sub(componentType,0,3) == "ic2" then
		    GUI.alert("ic2")
    elseif componentType=="energy_device" then
        truefalse,myfunc,remover=pcall(function()return shitometer.NewWindow(address) end)
        if truefalse then
		        event.addHandler(myfunc,1)
		        table.insert(removeus,remover)
        end
    else
        --GUI.alert(address..componentType)
    end
end

