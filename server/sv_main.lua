local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-methcamper:server:Reward', function(temp)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local dist = math.abs(temp - 484)
    local pure = 100 - dist

    if pure > 67 then pure = 67 end
    if pure < 8 then pure = 8 end

    local info = {purity = pure}
    Player.Functions.AddItem('meth', 25, false, info)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["meth"], "add", 25)
    TriggerEvent("qb-log:server:CreateLog", 'drugfarming', "Mobilemeth", "turqois", "**"..Player.PlayerData.name .. "** (citizenid: *" .. Player.PlayerData.citizenid .. "* | id: *(" .. Player.PlayerData.source .. "))*: has farmed a 25 bags of meth, purity: "..pure)
end)

RegisterNetEvent('qb-methcamper:server:ptfx', function(coords)
    TriggerClientEvent('qb-methcamper:client:ptfx', -1, coords)
end)

QBCore.Functions.CreateCallback('qb-methcamper:server:getCops', function(source, cb)
	local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for _, Player in pairs(players) do
        if Player.PlayerData.job.type == "leo" and Player.PlayerData.job.onduty then
            amount += 1
        end
    end
    cb(amount)
end)

QBCore.Functions.CreateCallback('qb-methcamper:server:hasItems', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.Functions.GetItemByName('portable_methlab') then 
        if Player.Functions.GetItemByName('pseudoephedrine') then
            cb(true)
        else
            TriggerClientEvent('QBCore:Notify', src, 'You need some pseudo..', 'error', 2500)
            cb(false)
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'You need equipment to start cooking meth..', 'error', 2500)
        cb(false)
    end
end)