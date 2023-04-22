Neptune = {}
Neptune.PlayerData = {}
Neptune.PlayerLoaded = false

function Neptune.IsPlayerLoaded()
    return Neptune.PlayerLoaded
end

function Neptune.GetPlayerData()
    return Neptune.PlayerData
end

function Neptune.ShowNotification(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end






