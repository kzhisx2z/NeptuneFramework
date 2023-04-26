function LoadNeptunePlayer(identifier, source, isNew)
    local sqlLoadPlayer = 'SELECT `accounts`, `job`, `job_grade`, `faction`, `faction_grade`, `group`, `position`, `inventory`, `skin`, `loadout`, `metadata`, `firstname`, `lastname`, `dateofbirth`, `sex`, `height` FROM `users` WHERE identifier = ?'
    local userData = {
        accounts = {},
        inventory = {},
        job = {},
        faction = {},
        loadout = {},
        playerName = GetPlayerName(source),
        weight = 0,
        metadata = {}
    }

    local loadPlayerResult = MySQL.prepare.await(sqlLoadPlayer, {identifier})

    local job = loadPlayerResult.job
    local jobGrade = loadPlayerResult.job_grade

    local faction = loadPlayerResult.faction
    local factionGrade = tostring(loadPlayerResult.faction_grade)

    local decode = json.decode

    if loadPlayerResult.accounts then
        local accounts = decode(loadPlayerResult.accounts)

        for account, money in pairs(accounts) do
            userData.accounts[account] = money or 0
        end
    end

    local jobObject
    local jobGradeObject

    if Neptune.DoesJobExist(job, jobGrade) then
        jobObject = Neptune.Jobs[job]
        jobGradeObject = Neptune.Jobs[job].grades[tostring(jobGrade)]
    else
        jobObject = Neptune.Jobs['unemployed']
        jobGradeObject = Neptune.Jobs['unemployed'].grades['0']
    end

    userData.job = {
        id = jobObject.id,
        name = jobObject.name,
        label = jobObject.label,
        grade = jobGrade,
        gradeName = jobGradeObject.name,
        gradeLabel = jobGradeObject.label,
        gradeSalary = jobGradeObject.salary,
        skinMale = jobGradeObject.skin_male and decode(jobGradeObject.skin_male) or {},
        skinFemale = jobGradeObject.skin_female and decode(jobGradeObject.skin_female) or {}
    }

    local factionObject
    local factionGradeObject

    if Neptune.DoesFactionExist(faction, factionGrade) then
        factionObject = Neptune.Factions[faction]
        factionGradeObject = Neptune.Factions[faction].grades[tostring(factionGrade)]
    else
        factionObject = Neptune.Factions['unemployed']
        factionGradeObject = Neptune.Factions['unemployed'].grades['0']
    end

    userData.faction = {
        id = factionObject.id,
        name = factionObject.name,
        label = factionObject.label,
        grade = factionGrade,
        gradeName = factionGradeObject.name,
        gradeLabel = factionGradeObject.label,
        gradeSalary = factionGradeObject.salary,
        skinMale = factionGradeObject.skin_male and decode(factionGradeObject.skin_male) or {},
        skinFemale = factionGradeObject.skin_female and decode(factionGradeObject.skin_female) or {}
    }

    if loadPlayerResult.inventory then
        local inventory = decode(loadPlayerResult.inventory)

        for name, count in pairs(inventory) do
            local item = Neptune.Items[name]

            if item then
                if count > 0 then
                    userData.weight = userData.weight + (item.weight * count)

                    table.insert(userData.inventory, {
                        name = name,
                        count = count,
                        label = item.label,
                        weight = item.weight,
                        usable = nil, --FAIRE,
                        rare = item.rare,
                        canRemove = item.canRemove
                    })
                end
            end
        end

        table.sort(userData.inventory, function(a, b)
            return a.label < b.label
        end)
    end

    userData.group = loadPlayerResult.group
    userData.coords = decode(loadPlayerResult.position) or Config.DefaultSpawn

    userData.firstName = loadPlayerResult.firstname or 'John'
    userData.lastName = loadPlayerResult.lastname or 'Doe'
    userData.identityName = ('%s %s'):format(userData.firstName, userData.lastName)

    userData.dateOfBirth = loadPlayerResult.dateofbirth or '06/20/2000'
    userData.sex = loadPlayerResult.sex or 'm'
    userData.height = loadPlayerResult.height or 170

    if loadPlayerResult.skin then
        userData.skin = decode(loadPlayerResult.skin)
    else
        userData.skin = userData.sex == 'f' and {sex = 1} or {sex = 0}
    end

    userData.metadata = decode(loadPlayerResult.metadata) or {}

    local player = CreatePlayerObject(
            source,
            identifier,
            userData.group,
            userData.accounts,
            userData.inventory,
            userData.weight,
            userData.job,
            userData.faction,
            userData.loadout,
            userData.playerName,
            {
                name = userData.identityName,
                height = userData.height,
                dateOfBirth = userData.dateOfBirth,
                sex = userData.sex
            },
            userData.coords,
            userData.metadata
    )

    Neptune.Players[source] = player
    Uranus.PlayersByIdentifier[identifier] = player

    TriggerEvent('neptune:playerLoaded', source, player, isNew)

    player.triggerEvent('neptune:playerLoaded', {
                accounts = player.getAccounts(),
                coords = player.getCoords(),
                identifier = player.getIdentifier(),
                inventory = player.getInventory(),
                job = player.getJob(),
                ped = player.getPed(),
                faction = player.getFaction(),
                loadout = player.getLoadout(),
                maxWeight = player.getMaxWeight(),
                identity = player.getIdentity(),
                dead = false,
            }, isNew, userData.skin
    )

    player.updateCoords()
end

function CreateNeptunePlayer(identifier, source)
    local sqlCreatePlayer = 'INSERT INTO `users` SET `accounts` = ?, `identifier` = ?, `group` = ?'
    local accounts = {}

    for account, money in pairs(Config.StartingAccountMoney) do
        accounts[account] = money
    end

    local defaultGroup = 'user'

    MySQL.prepare(sqlCreatePlayer, {json.encode(accounts), identifier, defaultGroup}, function(rowsChanged)
        if rowsChanged > 0 then
            LoadNeptunePlayer(identifier, source, true)
        end
    end)
end