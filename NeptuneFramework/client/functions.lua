Neptune = {}

Neptune.PlayerData = {}
Neptune.PlayerLoaded = false

Neptune.Game = {}

Neptune.Streaming = {}

exports('getObject', function()
    return Neptune
end)

function Neptune.IsPlayerLoaded()
    return Neptune.PlayerLoaded
end

function Neptune.GetPlayerData()
    return Neptune.PlayerData
end

function Neptune.SetPlayerData(key, value)
    local current = Neptune.PlayerData[key]
    Neptune[key] = value

    if key ~= 'inventory' and key ~= 'loadout' then
        if value ~= current then
            TriggerEvent('neptune:setPlayerData', key, value, current)
        end
    end
end

function Neptune.Notify(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end

function Neptune.AdvancedNotify(sender, subject, message, textureDict, iconType, flash, saveToBrief, hudColorIndex)
    saveToBrief = not saveToBrief and true or saveToBrief

    AddTextEntry('advancedNotification', message)
    BeginTextCommandThefeedPost('advancedNotification')

    if hudColorIndex then
        ThefeedSetNextPostBackgroundColor(hudColorIndex)
    end

    EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
    EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
end

function Neptune.ShowHelpNotification(message, thisFrame, beep, duration)
    AddTextEntry('helpNotification', message)

    if thisFrame then
        DisplayHelpTextThisFrame('helpNotification', false)
    else
        if beep == nil then
            beep = true
        end
        BeginTextCommandDisplayHelp('helpNotification')
        EndTextCommandDisplayHelp(0, false, beep, duration or -1)
    end
end



