function Neptune.RefreshJobs()
    local jobs = {}
    local sqlJobs = MySQL.query.await('SELECT * FROM jobs')

    for k, v in ipairs(sqlJobs) do
        jobs[v.name] = v
        jobs[v.name].grades = {}
    end

    local sqlJobsGrades = MySQL.query.await('SELECT * FROM job_grades')

    for k, v in ipairs(sqlJobsGrades) do
        if jobs[v.job_name] then
            jobs[v.job_name].grades[tostring(v.grade)] = v
        end
    end

    Neptune.Jobs = jobs or {}
end

function Neptune.RefreshFactions()
    local factions = {}
    local sqlFactions = MySQL.query.await('SELECT * FROM factions')

    for k, v in ipairs(sqlFactions) do
        factions[v.name] = v
        factions[v.name].grades = {}
    end

    local sqlFactionsGrades = MySQL.query.await('SELECT * FROM faction_grades')

    for k, v in ipairs(sqlFactionsGrades) do
        if factions[v.faction_name] then
            factions[v.faction_name].grades[tostring(v.grade)] = v
        end
    end

    Neptune.Factions = factions or {}
end

function Uranus.SavePlayer(player, callback)
    local encode = json.encode

    MySQL.prepare(
            'UPDATE `users` SET `accounts` = ?, `job` = ?, `job_grade` = ?, `faction` = ?, `faction_grade` = ?, `group` = ?, `position` = ?, `inventory` = ?, `loadout` = ?, `metadata` = ? WHERE `identifier` = ?',
            {
                encode(player.getAccounts()),
                player.getJob().name,
                player.getJob().grade,
                player.getFaction().name,
                player.getFaction().grade,
                player.getGroup(),
                encode(player.getCoords()),
                encode(player.getInventory()),
                encode(player.getLoadout()),
                encode(player.getMeta()),
                player.getIdentifier()
            },
            function(rowsChanged)
                if rowsChanged > 0 then
                    TriggerEvent('neptune:playerSaved', player)
                    print('cc')
                    print(('Saved player ^5%s'):format(player.getName()))
                end

                if callback then
                    callback()
                end
            end
    )
end

function Uranus.SavePlayers(callback)
    local players = Neptune.Players

    if not next(players) then
        return
    end

    local saveParameters = {}
    local encode = json.encode

    for k, player in pairs(players) do
        table.insert(saveParameters, {
            encode(player.getAccounts()),
            player.getJob().name,
            player.getJob().grade,
            player.getFaction().name,
            player.getFaction().grade,
            player.getGroup(),
            encode(player.getCoords()),
            encode(player.getInventory()),
            encode(player.getLoadout()),
            encode(player.getMeta()),
            player.getIdentifier()
        })
    end

    MySQL.prepare(
            'UPDATE `users` SET `accounts` = ?, `job` = ?, `job_grade` = ?, `faction` = ?, `faction_grade` = ?, `group` = ?, `position` = ?, `inventory` = ?, `loadout` = ?, `metadata` = ? WHERE `identifier` = ?',
            saveParameters,
            function(rowsChanged)
                if rowsChanged > 0 then
                    TriggerEvent('neptune:playersSaved')
                end

                if callback then
                    callback()
                end
            end
    )
end

function Neptune.GetPlayerFromId(source)
    return Neptune.Players[source]
end

function Neptune.GetPlayerFromIdentifier(identifier)
    return Uranus.PlayersByIdentifier[identifier]
end

function Neptune.DoesJobExist(job, grade)
    grade = tostring(grade)

    if job and grade then
        return Neptune.Jobs[job] and Neptune.Jobs[job].grades[grade]
    end

    return false
end

function Neptune.DoesFactionExist(faction, grade)
    grade = tostring(grade)

    if faction and grade then
        return Neptune.Factions[faction] and Neptune.Factions[faction].grades[grade]
    end

    return false
end

function Neptune.GetIdentifier(source)
    for k, v in ipairs(GetPlayerIdentifiers(source)) do
        if v:match('license:') then
            return v:gsub('license:', '')
        end
    end
end