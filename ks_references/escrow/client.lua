local Framework = nil
local ESX, QBCore = nil, nil

CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        Framework = 'esx'
        ESX = exports['es_extended']:getSharedObject()
    elseif GetResourceState('qb-core') == 'started' then
        Framework = 'qb'
        QBCore = exports['qb-core']:GetCoreObject()
    end
end)


RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
end)

RegisterNUICallback('copy', function(data, cb)
	SendNUIMessage({
        type = "copy",
		data = data.code
	})
end)
RegisterNUICallback("TriggerCallback", function(data, cb)
    ESX.TriggerServerCallback(data.name, function(retval)
        cb(retval)
    end, data.code)
end)


function Open()
    SetNuiFocus(true, true)
    SendNUIMessage({type = "show"})
    ESX.TriggerServerCallback("ks_referencias:getcode",function(codigo,usos)
    SendNUIMessage({type = "setcode", code = codigo, use = usos})
    end)
end

RegisterNetEvent("ks_referencias:open", function()
    Open()
end)

if Config.OpenMenu.Command.Enable then 
    RegisterCommand(Config.OpenMenu.Command.Name, function()
        Open()
    end)
end