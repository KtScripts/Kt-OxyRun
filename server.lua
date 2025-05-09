local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent("oxyrun:giveBoxes", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem("oxy_box", 10)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["oxy_box"], "add")
end)

RegisterServerEvent("oxyrun:deliverPackage", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem("oxy_box", 1) then
        Player.Functions.AddItem("oxy", 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["oxy_box"], "remove")
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["oxy"], "add")
    else
        TriggerClientEvent('QBCore:Notify', src, "No boxes left", "error")
    end
end)
