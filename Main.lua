local GUI = require("GUI")
local system = require("System")
local component = require("component")
local filesystem = require("Filesystem")
local event = require("Event")
local number = require("Number")
local unicode = require("Unicode")
local screen = require("Screen")
local text = require("Text")
local paths = require("Paths")
------------------------------------------------------------------------------------------

local workspace, window = system.addWindow(GUI.tabbedWindow(50, 22, 100, 40))

local elements={}
local meters={}
local cnames={}
local groups={}

if filesystem.exists(paths.user.applicationData.."/Powerbank/Powerbank.names") then
    cnames=filesystem.readTable(paths.user.applicationData.."/Powerbank/Powerbank.names")
    if filesystem.exists(paths.user.applicationData.."/Powerbank/Powerbank.groups") then
        groups=filesystem.readTable(paths.user.applicationData.."/Powerbank/Powerbank.groups")
    end
else
    filesystem.makeDirectory(paths.user.applicationData.."/Powerbank")
end
function rescan()
    elements={}
    meters={}
    for address, componentType in component.list() do
        if componentType == "filesystem" or componentType =="eeprom" or componentType =="gpu" or componentType == "screen" or componentType =="computer" or componentType == "keyboard" or componentType == "internet" or componentType == "redstone" then
        --elseif string.sub(componentType,0,3) == "ic2" then
        --GUI.alert("ic2")
        elseif componentType=="energy_device" then
            table.insert(elements,address)
        else
            --GUI.alert(address..componentType)
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function drawMYCustomProgressBar(object)
    local activeHeight = math.floor( (100-math.min(object.value, 100)) / 100 * object.height)                                                           
        local percentColor=object.colors.active[math.min(math.floor(object.value/100*(#object.colors.active))+1,#object.colors.active)] --не говнокод, а ГОВНОКОДИЩЩЩЕЕЕ!!!!!!1111
        screen.drawRectangle(object.x, object.y, object.width, object.height, percentColor, 0x0, " ")
        screen.drawRectangle(object.x, object.y, object.width, activeHeight, object.colors.passive, 0x0, " ")

        local stringValue = object.value.." %"
        screen.drawText(math.floor(object.x + object.width / 2 - unicode.len(stringValue) / 2), object.y+object.height - 1, object.colors.value, stringValue)        
    if cnames[object.id]==nil then
        local stringValue2 = text.limit(object.id, 10, "right")
        screen.drawText(math.floor(object.x + object.width / 2 - unicode.len(stringValue2) / 2), object.y, object.colors.value, stringValue2)  
    else 
        local stringValue2 = text.limit(cnames[object.id], 10, "right")
        screen.drawText(math.floor(object.x + object.width / 2 - unicode.len(stringValue2) / 2), object.y, object.colors.value, stringValue2)
    end
    return object

end

local function drawMYCustomGroupProgressBar(object)
    local activeHeight = math.floor( (100-math.min(object.value, 100)) / 100 * object.height)                                                          
        local percentColor=object.colors.active[math.min(math.floor(object.value/100*(#object.colors.active))+1,#object.colors.active)] --не говнокод, а ГОВНОКОДИЩЩЩЕЕЕ!!!!!!1111
        screen.drawRectangle(object.x, object.y, object.width, object.height, percentColor, 0x0, " ")
        screen.drawRectangle(object.x, object.y, object.width, activeHeight, object.colors.passive, 0x0, " ")

        local stringValue = object.value.." %"
        screen.drawText(math.floor(object.x + object.width / 2 - unicode.len(stringValue) / 2), object.y+object.height - 1, object.colors.value, stringValue)        
    if cnames[object.id]==nil then
        local stringValue2 = text.limit(object.id, 10, "right")
        screen.drawText(math.floor(object.x + object.width / 2 - unicode.len(stringValue2) / 2), object.y, object.colors.value, stringValue2)  
    else 
        local stringValue2 = text.limit(cnames[object.id], 10, "right")
        screen.drawText(math.floor(object.x + object.width / 2 - unicode.len(stringValue2) / 2), object.y, object.colors.value, stringValue2)
    end
    return object

end

function MyCustomProgressBar(x, y,width, height, activeColors, passiveColor, valueColor, value,id)
    local object = GUI.object(x, y, width, height)
    object.value = value
    object.colors = {active = activeColors, passive = passiveColor, value = valueColor}
    object.draw = drawMYCustomProgressBar
    object.id=id
    object.update=function() 
        if component.proxy(object.id)==nil then  
        else
            object.value=number.roundToDecimalPlaces(component.proxy(id).getEnergyStored()/component.proxy(id).getMaxEnergyStored()*100,1)
        end
    end
    return object
end

function MyCustomGroupProgressBar(x, y,width, height, activeColors, passiveColor, valueColor, value,ids)
    local object = GUI.object(x, y, width, height)
    object.value = value
    object.colors = {active = activeColors, passive = passiveColor, value = valueColor}
    object.draw = drawMYCustomGroupProgressBar
    object.id=ids["name"]
    object.update=function() 
        local fullvalue=0.1
        local sumvalue=0
        for key, shit in pairs(ids) do
            if shit==object.id then
            else
                --GUI.alert(shit)
                if component.proxy(shit)==nil then  
                else
                    --GUI.alert(component.proxy(shit).getEnergyStored())
                    sumvalue=sumvalue+component.proxy(shit).getEnergyStored()
                    fullvalue=fullvalue+component.proxy(shit).getMaxEnergyStored()
                end
            end
        end
        --GUI.alert((sumvalue/fullvalue)*100)
        object.value=number.roundToDecimalPlaces((sumvalue/fullvalue)*100,1)
    end
    return object
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


local maintabcall=window.tabBar:addItem("Show")
maintabcall.onTouch = function()
    rescan()
    window:removeChildren(4)
    for key, shit in pairs(elements) do
        -----------------------------------------------
        local meter=window:addChild(MyCustomProgressBar( (key%10-1)*11+2, math.floor(key/10)*13+5, 10, 10, {0xFF0000,0xFFFF00,0x00FF00}, 0x1D1D1D, 0x000000, 0,shit))
        meter.update()

        table.insert(meters,meter)
    end
end
window.tabBar:addItem("Config").onTouch = function()
    rescan()
    window:removeChildren(4)
    for key, shit in pairs(elements) do
        local meter=window:addChild(MyCustomProgressBar( (key%10-1)*11+2, math.floor(key/10)*13+5, 10, 10, {0xFF0000,0xFFFF00,0x00FF00}, 0x1D1D1D, 0x000000, 0,shit))
        meter.update()
        table.insert(meters,meter)

        local renamer = window:addChild(GUI.input( (key%10-1)*11+2, math.floor(key/10)*13+15, 10, 1, 0x888888, 0x444444, 0xaa0000, 0xff0000, 0x2D0000, "Rename", "name"))
        renamer.onInputFinished = function(fuck,good)
            cnames[shit]=good.text
            filesystem.writeTable(paths.user.applicationData.."/Powerbank/Powerbank.names",cnames)
        end  

        local mycomboBox = window:addChild(GUI.comboBox((key%10-1)*11+2, math.floor(key/10)*13+16, 10, 1, 0xaaaaaa, 0x2D2D2D, 0xbbbbbb, 0x888888))
        for groupkey, groupshit in pairs(groups) do
            mycomboBox:addItem(text.limit(groupshit["name"], 10, "right")).onTouch = function()
                GUI.alert(mycomboBox.selectedItem)
                table.insert(groups[mycomboBox.selectedItem],shit)
                filesystem.writeTable(paths.user.applicationData.."/Powerbank/Powerbank.groups",groups)
            end
        end
end
end

window.tabBar:addItem("Group").onTouch = function()
    window:removeChildren(4)
    for key, shit in pairs(groups) do
        GUI.alert(shit)
        local meter=window:addChild(MyCustomGroupProgressBar( (key%10-1)*11+2, (math.floor(key/10)*13)+5, 10, 10, {0xFF0000,0xFFFF00,0x00FF00}, 0x1D1D1D, 0x000000, 0,shit))
        meter.update()
        table.insert(meters,meter)
        --

    end
    window:addChild(GUI.framedButton(window.width-5, window.height-2, 5, 3, 0x1D1D1D, 0x1D1D1D, 0x888800, 0x888800, "+")).onTouch = function()
        local myelement={}
        myelement['name']="New Group"
        table.insert(groups,myelement)
        filesystem.writeTable(paths.user.applicationData.."/Powerbank/Powerbank.groups",groups)
    end
end

powerbankapphandler=event.addHandler(function() 
    for eventkey, eventshit in pairs(meters) do
        eventshit.update()
    end
end ,5)
window.actionButtons.close.onTouch = function()
    event.removeHandler(powerbankapphandler)
    window:removeChildren()
    window:remove()
	workspace:draw()
end

maintabcall.onTouch()
workspace:draw()
while true do
    workspace:start(0)
end