```lua
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