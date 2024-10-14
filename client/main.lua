local QBCore = exports['qb-core']:GetCoreObject()
local isTipping = false

local function CheckDistanceAndStopIfNeeded(targetPlayerId)
    local playerPed = PlayerPedId()
    
    Citizen.CreateThread(function()
        while isTipping do
            Citizen.Wait(1000)
            
            local targetPed = GetPlayerPed(GetPlayerFromServerId(targetPlayerId))
            if not DoesEntityExist(targetPed) then
                QBCore.Functions.Notify('Target is no longer available.', 'error')
                TriggerServerEvent('vivify_vuTipping:stopTipping')
                break
            end

            local playerCoords = GetEntityCoords(playerPed)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)

            if distance > Config.TipRadius then
                TriggerServerEvent('vivify_vuTipping:stopTipping')
                QBCore.Functions.Notify('Tipping stopped: Target moved too far away.', 'error')
                break
            end
        end
    end)
end

local function GetWorkersWithJobAndRadius(callback)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    QBCore.Functions.TriggerCallback('getWorkersByJob', function(workers)
        local validWorkers = {}

        for _, worker in pairs(workers) do
            table.insert(validWorkers, worker)
        end

        callback(validWorkers)
    end, Config.JobName, playerCoords, Config.TipRadius)
end

local function StartTippingProcess(targetPlayerId)
    local src = PlayerId()

    if targetPlayerId == GetPlayerServerId(src) then
        QBCore.Functions.Notify('You cannot tip yourself!', 'error')
        return
    end

    isTipping = true
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    QBCore.Functions.TriggerCallback('QBCore:GetPlayerBlackMoney', function(blackMoneyAmount)
        if blackMoneyAmount < 10 then
            QBCore.Functions.Notify('Not enough black money to tip!', 'error')
            isTipping = false
            return
        end

        local totalTipDuration = (blackMoneyAmount // 10) * Config.TipInterval

        RequestAnimDict("anim@mp_player_intupperraining_cash")
        while not HasAnimDictLoaded("anim@mp_player_intupperraining_cash") do
            Wait(100)
        end

        TaskPlayAnim(playerPed, "anim@mp_player_intupperraining_cash", "idle_a", 8.0, -8.0, -1, 49, 0, false, false, false)  -- Start the animation

        exports['progressbar']:Progress({
            name = "tipping",
            duration = totalTipDuration,
            label = "Tipping in progress...",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
        }, function(cancelled)
            ClearPedTasks(playerPed)
            if cancelled then
                TriggerServerEvent('vivify_vuTipping:stopTipping')
                QBCore.Functions.Notify('Tipping process canceled.', 'error')
            end
        end)

        TriggerServerEvent('vivify_vuTipping:tipPlayer', targetPlayerId)

        Wait(totalTipDuration)
        ClearPedTasks(playerPed)
    end)

    CheckDistanceAndStopIfNeeded(targetPlayerId)
end

RegisterCommand('starttip', function(source, args, rawCommand)
    GetWorkersWithJobAndRadius(function(workers)
        if #workers == 0 then
            QBCore.Functions.Notify('No eligible workers found!', 'error')
            return
        end

        local worker = workers[1]

        QBCore.Functions.Notify('Started tipping: ' .. worker.PlayerData.charinfo.firstname .. ' ' .. worker.PlayerData.charinfo.lastname)
        StartTippingProcess(worker.PlayerData.source)

    end)
end, false)
