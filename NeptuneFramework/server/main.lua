local OneSyncState = GetConvar('onesync', false)

if not OneSyncState then
    error('OneSync must be activated')
end

local function OnPlayerJoined(source)
    local identifier = Neptune.GetIdentifier(source)

    if identifier then
        if Neptune.GetPlayerFromIdentifier(identifier) then
            DropPlayer(source, ('Un joueur est déjà connecté avec la même license que vous.\n\nLicense: %s'):format(identifier))
        else
            local isRegistered = MySQL.scalar.await('SELECT 1 FROM users WHERE identifier = ?', {identifier})

            if isRegistered then
                LoadNeptunePlayer(identifier, source, false)
            else
                CreateNeptunePlayer(identifier, source)
            end
        end
    end
end

RegisterNetEvent('neptune:onPlayerJoined', function()
    local _source = source

    while not next(Neptune.Jobs) or not next(Neptune.Factions) do
        _Wait(50)
    end

    if not Neptune.Players[_source] then
        OnPlayerJoined(_source)
    end
end)

