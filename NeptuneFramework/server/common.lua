Neptune = {}
Neptune.Players = {}

Neptune.Jobs = {}
Neptune.Factions = {}
Neptune.Items = {}

Uranus = {}
Uranus.DatabaseConnected = false
Uranus.PlayersByIdentifier = {}

exports('getObject', function()
    return Neptune
end)

local function StartAutomaticSave()
    CreateThread(function()
        while true do
            _Wait(10 * 60 * 1000)
            Uranus.SavePlayers()
        end
    end)
end

MySQL.ready(function()
    Uranus.DatabaseConnected = true

    local items = MySQL.query.await('SELECT * FROM items')

    for k, v in ipairs(items) do
        Neptune.Items[v.name] = {
            label = v.label,
            weight = v.weight,
            rare = v.rare,
            canRemove = v.can_remove
        }
    end

    Neptune.RefreshJobs()
    Neptune.RefreshFactions()

    print(('[^5Neptune Framework^7] initialized'))

    StartAutomaticSave()
end)