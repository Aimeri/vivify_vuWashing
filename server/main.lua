local QBCore = exports['qb-core']:GetCoreObject()
local activeTippingSessions = {}

RegisterNetEvent('vivify_vuTipping:tipPlayer', function(targetPlayerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(targetPlayerId)

    if not Target or not Player then return end

    if Target.PlayerData.job.name == Config.JobName then
        local currencyItem = Player.Functions.GetItemByName(Config.Currency)
        
        if currencyItem and currencyItem.amount and currencyItem.amount >= 10 then
            activeTippingSessions[src] = true
            
            for i = 1, currencyItem.amount // 10 do
                Citizen.Wait(Config.TipInterval)
                
                if not activeTippingSessions[src] then
                    break
                end

                local currentCurrency = Player.Functions.GetItemByName(Config.Currency)
                if currentCurrency and currentCurrency.amount >= 10 then
                    Player.Functions.RemoveItem(Config.Currency, 10)

                    Player.Functions.AddMoney('cash', 6)

                    Target.Functions.AddItem(Config.Currency, 4)
                else
                    TriggerClientEvent('QBCore:Notify', src, 'Not enough currency to continue tipping.', 'error')
                    break
                end
            end
            
            activeTippingSessions[src] = nil
        else
            TriggerClientEvent('QBCore:Notify', src, 'You don\'t have enough ' .. Config.Currency .. ' to tip!', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'The selected person does not have the required job.', 'error')
    end
end)

RegisterNetEvent('vivify_vuTipping:stopTipping', function()
    local src = source
    activeTippingSessions[src] = nil
end)

QBCore.Functions.CreateCallback('QBCore:GetPlayerBlackMoney', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local currencyItem = Player.Functions.GetItemByName(Config.Currency)
        cb(currencyItem and currencyItem.amount or 0)
    else
        cb(0)
    end
end)


QBCore.Functions.CreateCallback('getWorkersByJob', function(source, cb, jobName, playerCoords, radius)
    local workers = {}

    for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
        local player = QBCore.Functions.GetPlayer(playerId)
        if player and player.PlayerData.job.name == jobName then
            local workerCoords = GetEntityCoords(GetPlayerPed(playerId))
            local distance = #(playerCoords - workerCoords)

            if distance <= radius then
                table.insert(workers, player)
            end
        end
    end
    cb(workers)
end)
