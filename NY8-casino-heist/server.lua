ESX = exports['es_extended']:getSharedObject()

RegisterServerEvent("casinoheist:startMission")
AddEventHandler("casinoheist:startMission", function()
    local src = source
    print("^2[c_h] Mission lancée par l'ID : " .. src)

    -- Position spawn véhicule aléatoire
    local spawnPoints = {
        {x = 973.5, y = 6.3, z = 81.02, w = 147.40}
    }
    local selected = spawnPoints[math.random(#spawnPoints)]
    
    TriggerClientEvent("casinoheist:beginHeist", src, selected)

    -- Alerte police
    TriggerClientEvent("casinoheist:notifyCops", -1, selected)
end)

RegisterServerEvent("casinoheist:rewardPlayer")
AddEventHandler("casinoheist:rewardPlayer", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local amount = math.random(5000, 10000)
    xPlayer.addAccountMoney('black_money', amount)
    print("^3[c_h] Récompense donnée : $" .. amount)
end)
