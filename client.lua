local QBCore = exports['qb-core']:GetCoreObject()
local oxyRun = false
local currentDrop = 0
local oxyVan = nil
local dropBlip = nil
local dropPed = nil
local packagePed = nil

RegisterNetEvent("oxyrun:start")
AddEventHandler("oxyrun:start", function()
    if oxyRun then return end

    oxyRun = true
    currentDrop = 0

    -- Spawn van
    local veh = Config.VehicleSpawn
    QBCore.Functions.SpawnVehicle(veh.model, function(vehicle)
        SetEntityHeading(vehicle, veh.heading)
        SetVehicleNumberPlateText(vehicle, "OXYRUN")
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(vehicle))
        oxyVan = vehicle
        QBCore.Functions.Notify("Oxy van is ready. Go get the package!", "success")
        SetNewWaypoint(Config.PackagePed.coords.x, Config.PackagePed.coords.y)
    end, veh.coords, true)

    -- Spawn Package Ped
    local pedData = Config.PackagePed
    RequestModel(pedData.model)
    while not HasModelLoaded(pedData.model) do Wait(10) end
    packagePed = CreatePed(0, pedData.model, pedData.coords.x, pedData.coords.y, pedData.coords.z - 1.0, pedData.coords.w, false, true)
    FreezeEntityPosition(packagePed, true)
    SetEntityInvincible(packagePed, true)
    SetBlockingOfNonTemporaryEvents(packagePed, true)

    exports.ox_target:addLocalEntity(packagePed, {
        {
            icon = "fa-solid fa-box",
            label = "Get Package",
            onSelect = function()
                TriggerServerEvent("oxyrun:giveBoxes")
                DeleteEntity(packagePed)
                packagePed = nil
                QBCore.Functions.Notify("You got the packages. Deliver them!", "success")
                setNextDrop()
            end,
        },
    })
end)

function setNextDrop()
    currentDrop = currentDrop + 1
    if currentDrop > #Config.DropOffs then
        QBCore.Functions.Notify("All deliveries complete!", "success")
        ClearGpsMultiRoute()
        oxyRun = false
        return
    end

    local coords = Config.DropOffs[currentDrop]
    if dropBlip then RemoveBlip(dropBlip) end
    dropBlip = AddBlipForCoord(coords)
    SetBlipRoute(dropBlip, true)
    SetNewWaypoint(coords.x, coords.y)

    -- Delay and spawn NPC car
    CreateThread(function()
        Wait(5000)
        local carModel = `emperor`
        RequestModel(carModel)
        while not HasModelLoaded(carModel) do Wait(10) end

        local heading = 0.0
        local npcCar = CreateVehicle(carModel, coords.x + 10.0, coords.y + 10.0, coords.z, heading, true, false)
        TaskVehicleDriveToCoord(GetPedInVehicleSeat(npcCar, -1), npcCar, coords.x, coords.y, coords.z, 10.0, 1, carModel, 16777216, 1.0)

        Wait(3000)

        exports.ox_target:addLocalEntity(npcCar, {
            {
                icon = "fa-solid fa-box",
                label = "Drop off box",
                onSelect = function()
                    TriggerServerEvent("oxyrun:deliverPackage")
                    DeleteEntity(npcCar)
                    setNextDrop()
                end,
            },
        })
    end)
end

-- Setup ox_target for starting ped
CreateThread(function()
    local pedData = Config.StartPed
    RequestModel(pedData.model)
    while not HasModelLoaded(pedData.model) do Wait(0) end

    local ped = CreatePed(0, pedData.model, pedData.coords.x, pedData.coords.y, pedData.coords.z - 1.0, pedData.coords.w, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports.ox_target:addLocalEntity(ped, {
        {
            icon = "fa-solid fa-play",
            label = "Start Oxy Run",
            onSelect = function()
                TriggerEvent("oxyrun:start")
            end,
        },
    })

    print("Oxy Start Ped Spawned") -- for debugging
end)

