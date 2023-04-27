local function PlayerKilledByPlayer(killerServerId, killerClientId, deathCause)
    local victimCoords = GetEntityCoords(Neptune.PlayerData.ped)
    local killerCoords = GetEntityCoords(GetPlayerPed(killerClientId))

    local distance = #(victimCoords - killerCoords)

    local data = {
        victimCoords = victimCoords,
        killerCoords = killerCoords,

        killerByPlayer = true,
        deathCause = deathCause,
        distance = distance,

        killerServerId = killerServerId,
        killerClientId = killerClientId
    }

    TriggerEvent('neptune:onPlayerDeath', data)
    TriggerServerEvent('neptune:onPlayerDeath', data)
end

local function PlayerDead(deathCause)
    local coords = GetEntityCoords(Neptune.PlayerData.ped)

    local data = {
        victimCoords = coords,
        deathCause = deathCause,
        killedByPlayer = false
    }

    TriggerEvent('neptune:onPlayerDeath', data)
    TriggerServerEvent('neptune:onPlayerDeath', data)
end

RegisterNetEvent('gameEventTriggered', function(event, data)
    if event == 'CEventNetworkEntityDamage' then
        local victim = data[1]
        local isVictimDied = data[4]

        if IsPedAPlayer(victim) then
            local player = PlayerId()

            if isVictimDied and NetworkGetPlayerIndexFromPed(victim) == player and (IsPedDeadOrDying(victim, true) or IsPedFatallyInjured(victim)) then
                local playerPed = Neptune.PlayerData.ped
                local killer = GetPedSourceOfDeath(playerPed)
                local deathCause = GetPedCauseOfDeath(killer)
                local killerClientId = NetworkGetPlayerIndexFromPed(killer)

                if killer ~= playerPed and killerClientId and NetworkIsPlayerActive(killerClientId) then
                    PlayerKilledByPlayer(GetPlayerServerId(killerClientId), killerClientId, deathCause)
                else
                    PlayerDead(deathCause)
                end
            end
        end
    end
end)

