ESX = exports['es_extended']:getSharedObject()

RegisterCommand('battlepass', function(source, args, rawCommand)
    ESX.TriggerServerCallback('almez-battlepass:GetPlayerPassDetails', function(data)
        SendNUIMessage({
            type = 'open',
            data = data,
            config = Config,
            nextxp = Config.XPToLevelUp[data.level],
        })
        SetNuiFocus(true, true)
    end)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    ESX.TriggerServerCallback('almez-battlepass:GetPlayerPassDetails', function(cb)
        return
    end)
end)

RegisterNetEvent('almez-battlepass:client:LevelUp', function(level, premium)
    SendNUIMessage({
        type = 'levelup',
        level = level,
        premium = premium
    })
end)

RegisterNUICallback('GetPassReward', function(data, cb)
    if data.index ~= nil then
        index = ESX.Math.Round(data.index + 1)
        ESX.TriggerServerCallback('almez-battlepass:server:GetReward', function(data)
            print(data)
            Wait(5000)
            if data then
                cb(true)
            else
                cb(false)
            end
            cb(data)
        end, index, data.premium)
        cb(true)
    else
        cb(false)
    end
end)

RegisterNUICallback('Close', function(data, cb)
    SetNuiFocus(false, false)
end)