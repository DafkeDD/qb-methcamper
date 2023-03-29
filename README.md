```lua
-- methcamper
['meth'] 					 	 = {['name'] = 'meth', 							['label'] = 'Bag of Meth', 				['weight'] = 100, 		['type'] = 'item', 		['image'] = 'meth.png', 				['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,    	['combinable'] = nil,   ['description'] = 'A baggie of Meth'},
['portable_methlab'] 			 = {['name'] = 'portable_methlab', 				['label'] = 'Portable Methlab', 		['weight'] = 10000, 	['type'] = 'item', 		['image'] = 'portable_methlab.png', 	['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,    	['combinable'] = nil,   ['description'] = 'All you need to start your own drug empire..'},
['pseudoephedrine'] 			 = {['name'] = "pseudoephedrine", 				['label'] = "Pseudoephedrine", 			['weight'] = 1000, 		['type'] = "item", 		['image'] = "pseudoephedrine.png", 		['unique'] = false, 	['useable'] = false, 	['shouldClose'] = false,	['combinable'] = nil,   ['description'] = "Pseudoephedrine, also known as Pseudo or Sudo for short, commonly found in anti-allergy medicines."},

local function MobileMeth(vehicle)
    local vehdata = vehicleData(vehicle)
    local currentPos = GetEntityCoords(PlayerPedId())
    local locationInfo = getStreetandZone(currentPos)
    local gender = GetPedGender()
    TriggerServerEvent("dispatch:server:notify",{
        dispatchcodename = "mobilemeth", -- has to match the codes in sv_dispatchcodes.lua so that it generates the right blip
        dispatchCode = "10-83",
        firstStreet = locationInfo,
        gender = gender,
        model = vehdata.name,
        plate = vehdata.plate,
        priority = 2,
        firstColor = vehdata.colour,
        automaticGunfire = false,
        origin = {
            x = currentPos.x,
            y = currentPos.y,
            z = currentPos.z
        },
        dispatchMessage = "Biochemical Smell", -- message
        job = {"lspd", "bcso", "sapr", "sasp"} -- jobs that will get the alerts
    })
end exports('MobileMeth', MobileMeth)

["mobilemeth"] =  {displayCode = '10-83', description = "Biochemical smell", radius = 50, recipientList = {'police'}, blipSprite = 205, blipColour = 1, blipScale = 1.5, blipLength = 2, sound = "Lose_1st", sound2 = "GTAO_FM_Events_Soundset"},
```