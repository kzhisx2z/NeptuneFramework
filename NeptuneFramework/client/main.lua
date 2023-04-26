CreateThread(function()
    while true do
        _Wait(100)

        if NetworkIsPlayerActive(PlayerId()) then
            exports.spawnmanager:setAutoSpawn(false)
            DoScreenFadeOut(0)
            TriggerServerEvent('neptune:onPlayerJoined')
            break
        end
    end
end)



RegisterNetEvent('neptune:playerLoaded', function(player, isNew, skin)
    Neptune.PlayerData = player

    exports.spawnmanager:spawnPlayer({
        x = Neptune.PlayerData.coords.x,
        y = Neptune.PlayerData.coords.y,
        z = Neptune.PlayerData.coords.z + 0.25,
        heading = Neptune.PlayerData.coords.heading,
        model = 'mp_m_freemode_01',
        skipFade = false
    }, function()
        TriggerServerEvent('neptune:onPlayerSpawn')
        TriggerEvent('neptune:onPlayerSpawn')
        TriggerEvent('neptune:restoreLoadout')

        if isNew then
            TriggerEvent('skinchanger:loadDefaultModel', skin.sex == 0)
        elseif skin then
            TriggerEvent('skinchanger:loadSkin', skin)
        end


        --TriggerEvent('neptune:loadingScreenOff')
        ShutdownLoadingScreen()
        ShutdownLoadingScreenNui()
    end)

    Neptune.PlayerLoaded = true

    local playerId = PlayerId()

    if Config.DisableNPCDrops then
        local weaponPickups = { 'PICKUP_WEAPON_CARBINERIFLE', 'PICKUP_WEAPON_PISTOL', 'PICKUP_WEAPON_PUMPSHOTGUN' }
        for i = 1, #weaponPickups do
            ToggleUsePickupsForPlayer(playerId, weaponPickups[i], false)
        end
    end

    if Config.DisableVehicleRewards then
        CreateThread(function()
            DisablePlayerVehicleRewards(playerId)
            _Wait(0)
        end)
    end

    if Config.DisableDispatchServices then
        for i = 1, 15 do
            EnableDispatchService(i, false)
        end
    end

    if Config.DisablePoliceAudioFlag then
        SetAudioFlag('PoliceScannerDisabled', true)
    end
end)

RegisterNetEvent('neptune:onPlayerLogout', function()
    Neptune.PlayerLoaded = false
end)
--
--local function OnPlayerSpawn()
--    Neptune.SetPlayerData('dead', false)
--end
--
--RegisterNetEvent('playerSpawned', OnPlayerSpawn())

RegisterNetEvent('neptune:onPlayerDeath', function()
    Neptune.SetPlayerData('dead', true)
end)

RegisterNetEvent('skinchanger:modelLoaded', function()
    while not Neptune.PlayerLoaded do
        _Wait(100)
    end

    TriggerEvent('neptune:restoreLoadout')
end)

RegisterNetEvent('neptune:restoreLoadout', function()
    local ammoTypes = {}
    local playerPed = Neptune.PlayerData.ped

    RemoveAllPedWeapons(playerPed, true)

    for k, v in ipairs(Neptune.PlayerData.loadout) do
        local weaponName = v.name
        local weaponHash = GetHashKey(weaponName)

        GiveWeaponToPed(playerPed, weaponHash, 0, false)
        SetPedWeaponTintIndex(playerPed, weaponHash, v.tintIndex)
        --
        --for k2, v2 in ipairs(v.components) do
        --    local componentHash = Neptune.GetWeaponComponent(weaponName, v2).hash
        --    GiveWeaponComponentToPed(PlayerPedId(), weaponHash, componentHash)
        --end

        local ammoType = GetPedAmmoTypeFromWeapon(playerPed, weaponHash)

        if not ammoTypes[ammoType] then
            AddAmmoToPed(playerPed, weaponHash, v.ammo)
            ammoTypes[ammoType] = true
        end
    end
end)

AddStateBagChangeHandler('VehicleProperties', nil, function(bagName, key, value)
    if not value then
        return
    end

    local networkId = bagName:gsub('entity:', '')
    local timer = GetGameTimer()

    while not NetworkDoesEntityExistWithNetworkId(tonumber(networkId)) do
        _Wait(0)

        if GetGameTimer() - timer > 10000 then
            return
        end
    end

    local vehicle = NetToVeh(tonumber(networkId))
    local timer = GetGameTimer()

    while NetworkGetEntityOwner(vehicle) ~= PlayerId() do
        _Wait(0)

        if GetGameTimer() - timer > 10000 then
            return
        end
    end

    Neptune.Game.SetVehicleProperties(vehicle, value)
end)


RegisterNetEvent('neptune:setAccountMoney', function(account)
    for i = 1, #Neptune.PlayerData.Accounts do
        if Neptune.PlayerData.Accounts[i].name == account.name then
            Neptune.PlayerData.Accounts[i] = account
            break
        end
    end

    Neptune.SetPlayerData('accounts', Neptune.PlayerData.Accounts)
end)


