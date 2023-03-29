local QBCore = exports['qb-core']:GetCoreObject()

local spawn = vector4(385.46, 3563.03, 32.78, 269.6)
local pedCoords = vector4(379.09, 3566.47, 33.29, 173.14)
local MinCops = 0
local callCopsChance = 0.20 -- 20%

local sentMessage = false
local journey = GetHashKey('journey')

--- Sends Biochemical smell alert to all police
local sendPoliceAlert = function()
    exports['qb-dispatch']:MobileMeth()
end

--- Toggles producing meth
local StartProducing = function()
    if isProducing then return end
    QBCore.Functions.TriggerCallback('qb-methcamper:server:getCops', function(cops)
        if cops >= MinCops then
            QBCore.Functions.TriggerCallback('qb-methcamper:server:hasItems', function(hasItem)
                local hasItem = QBCore.Functions.HasItem('portable_methlab')
                if hasItem then
                    isProducing = true
                    TriggerServerEvent("QBCore:Server:RemoveItem", "pseudoephedrine", 1, false)
                    TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["pseudoephedrine"], "remove", 1)                    
                    QBCore.Functions.Progressbar("methcamper_part1", "Mixing chemicals..", 14000, false, true, { -- 1
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {}, {}, {}, function() -- Done
                        if not isProducing then return end
                        local temp = nil
                        local input = exports['qb-input']:ShowInput({
                            header = "Set Temperature",
                            submitText = "Enter",
                            inputs = {
                                {
                                    type = 'number',
                                    isRequired = true,
                                    name = 'temperature',
                                    text = '°C.'
                                }
                            }
                        })
                        if not isProducing then return end
                        if input then
                            if not input.temperature then return end
                            temp = tonumber(input.temperature)
                            if temp <= 320 or temp >= 540 then
                                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                                local vehCoords = GetEntityCoords(veh)
                                QBCore.Functions.Notify('The meth is unstable, you need to get out of here!', 'error', 6000)
                                Wait(8000)
                                AddExplosion(vehCoords.x, vehCoords.y, vehCoords.z, 16, 200.0, true, false, 5.0, false)
                                Wait(2000)
                                exports['qb-dispatch']:Explosion()
                                return
                            end
                        else
                            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                            local vehCoords = GetEntityCoords(veh)
                            QBCore.Functions.Notify('The meth is unstable, you need to get out of here!', 'error', 6000)
                            Wait(6000)
                            AddExplosion(vehCoords.x, vehCoords.y, vehCoords.z, 16, 200.0, true, false, 5.0, false)
                            Wait(2000)
                            exports['qb-dispatch']:Explosion()
                            return
                        end
                        if math.random() <= callCopsChance then sendPoliceAlert() end
                        local pos = GetEntityCoords(PlayerPedId())
                        TriggerServerEvent('qb-methcamper:server:ptfx', pos)
                        QBCore.Functions.Progressbar("methcamper_part1", "Cooking meth..", 20000, false, true, { -- 2
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {}, {}, {}, function() -- Done
                            if not isProducing then return end
                            QBCore.Functions.Progressbar("methcamper_part1", "Crystalizing..", 26000, false, true, { -- 3
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            }, {}, {}, {}, function() -- Done
                                if not isProducing then return end
                                TriggerServerEvent('qb-methcamper:server:Reward', temp)
                                isProducing = false
                                sentMessage = false
                            end, function() -- Cancel
                                isProducing = false
                                QBCore.Functions.Notify("Cancelled", "error", 2500)
                            end)
                        end, function() -- Cancel
                            isProducing = false
                            sentMessage = false
                            QBCore.Functions.Notify("Cancelled", "error", 2500)
                        end)
                    end, function() -- Cancel
                        isProducing = false
                        sentMessage = false
                        QBCore.Functions.Notify("Cancelled", "error", 2500)
                    end)
                else
                    isProducing = false
                    sentMessage = false
                end
            end)            
        else
            QBCore.Functions.Notify('Not enough cops', 'error', 2500)
            isProducing = false
            sentMessage = false
        end
    end)
end

RegisterNetEvent('qb-methcamper:client:spawnVehicle', function()
    QBCore.Functions.TriggerCallback('qb-methcamper:server:getCops', function(cops)
        if cops >= MinCops then
            QBCore.Functions.SpawnVehicle('journey', function(veh)
                DoScreenFadeOut(250)
                Wait(250)
                SetEntityHeading(veh, spawn.w)
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                SetEntityAsMissionEntity(veh, true, true)
                TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
                Wait(250)
                DoScreenFadeIn(250)
                exports['qb-fuel']:SetFuel(veh, 50.0)
                SetVehicleEngineOn(veh, true, true)
                isProducing = false
            end, spawn.xyz, true)
        else
            QBCore.Functions.Notify('Not enough cops.', 'error', 2500)
        end
    end)
end)

RegisterNetEvent('qb-methcamper:client:ptfx', function(coords)
    CreateThread(function()
        SetPtfxAssetNextCall("core")
        local smoke = StartParticleFxLoopedAtCoord("exp_grd_bzgas_smoke", coords.x, coords.y, coords.z+1, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
        SetParticleFxLoopedAlpha(smoke, 0.8)
        SetParticleFxLoopedColour(smoke, 0.0, 0.0, 0.0, 0)
        Wait(20000)
        StopParticleFxLooped(smoke, 0)
    end)
end)

CreateThread(function()
    exports['qb-target']:SpawnPed({
        model = 'mp_m_weed_01',
        coords = pedCoords,
        minusOne = true,
        freeze = true,
        invincible = true,
        blockevents = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        target = {
            options = {
                {
                    type = "client",
                    event = "qb-methcamper:client:spawnVehicle",
                    icon = 'fas fa-user-secret',
                    label = 'Rent Journey'
                }
            },
            distance = 1.5
        },
    })
end)

CreateThread(function()
    Wait(1000)
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 and IsVehicleModel(veh, journey) then
            if GetPedInVehicleSeat(veh, -1) == 0 and (GetPedInVehicleSeat(veh, 1) == ped or GetPedInVehicleSeat(veh, 2) == ped) then
                if not sentMessage then
                    exports['qb-core']:DrawText('[E] - Start Producing', 'left')
                    sentMessage = true
                end

                sleep = 1
                if IsControlJustReleased(0, 38) then
                    StartProducing()
                    exports['qb-core']:KeyPressed(38)
                    sentMessage = false
                end

            else
                if sentMessage then
                    exports['qb-core']:HideText()
                    sentMessage = false
                end
                isProducing = false
            end
        else
            if sentMessage then
                exports['qb-core']:HideText()
                sentMessage = false
            end
        end
        Wait(sleep)
    end
end)