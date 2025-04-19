ESX = nil

CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(10)
    end
end)

local onMission = false
local spawnedGuards = {}

CreateThread(function()
    -- Spawn PNJ
    local model = "u_m_m_streetart_01" -- u_m_m_streetart_01
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local pnj = CreatePed(4, model, Config.PNJLocation.x, Config.PNJLocation.y, Config.PNJLocation.z - 1.0, 180.0, false, true)
    SetEntityInvincible(pnj, true)
    SetBlockingOfNonTemporaryEvents(pnj, true)
    FreezeEntityPosition(pnj, true)

    exports.ox_target:addLocalEntity(pnj, {
        {
            name = 'start_casino_heist',
            icon = 'fas fa-mask',
            label = 'Lancer le casse du casino',
            distance = 2.5,
            onSelect = function()
                if not onMission then
                    TriggerServerEvent("casinoheist:startMission")
                    print("[CLIENT] Tentative de démarrage de mission")
                end
            end
        }
    })
end)

RegisterNetEvent("casinoheist:beginHeist", function(vehCoords)
    onMission = true
    local model = Config.CasinoVehicle
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local veh = CreateVehicle(model, vehCoords.x, vehCoords.y, vehCoords.z, vehCoords.w, true, false)
    SetVehicleDoorsLocked(veh, 2)

    SpawnGuards(vehCoords)

    local hacked = false
    while not hacked do
        Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        if #(playerCoords - vector3(vehCoords.x, vehCoords.y, vehCoords.z)) < 3.0 then
            DrawText3D(vehCoords.x, vehCoords.y, vehCoords.z + 1.0, "[E] Lancer le piratage")
            if IsControlJustReleased(0, 38) then
                hacked = true
                FreezeEntityPosition(PlayerPedId(), true)
                TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_STAND_MOBILE", 0, true)
                Wait(Config.HackDuration * 1000)
                ClearPedTasksImmediately(PlayerPedId())
                FreezeEntityPosition(PlayerPedId(), false)
                TriggerServerEvent("casinoheist:rewardPlayer")
                ESX.ShowNotification("~g~Jetons volés avec succès !")
                DeleteEntity(veh)
                for _, guard in pairs(spawnedGuards) do
                    DeleteEntity(guard)
                end
                onMission = false
            end
        end
    end
end)

RegisterNetEvent("casinoheist:notifyCops", function(coords)
    CreateThread(function()
        while not ESX or not ESX.GetPlayerData().job do Wait(10) end

        if ESX.GetPlayerData().job.name == "police" then
            ESX.ShowAdvancedNotification("Central", "Braquage", "Braquage en cours près du casino !", "CHAR_CALL911", 1)
            SetNewWaypoint(coords.x, coords.y)
        end
    end)
end)

function SpawnGuards(location)
    local model = "s_m_m_security_01"
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    for i = 0, 2 do
        local guard = CreatePed(4, model, location.x + i, location.y + i, location.z, 0.0, true, false)
        GiveWeaponToPed(guard, `WEAPON_PISTOL`, 100, false, true)
        TaskCombatPed(guard, PlayerPedId(), 0, 16)
        spawnedGuards[#spawnedGuards + 1] = guard
    end
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(x, y+0.0125, 0.015+ factor, 0.03, 0, 0, 0, 75)
end
