local isInVehicle = false
local isEnteringVehicle = false
local playerPed = PlayerPedId()

local function GetVehicleData(vehicle)
    if DoesEntityExist(vehicle) then
        local model = GetEntityModel(vehicle)
        local displayName = GetDisplayNameFromVehicleModel(model)
        local networkId = NetworkGetNetworkIdFromEntity(vehicle)

        return displayName, networkId
    end
end

CreateThread(function()
    if not isInVehicle and not IsPlayerDead(playerPed) then
        if DoesEntityExist(GetVehiclePedIsTryingToEnter(playerPed) and not isEnteringVehicle) then
            isEnteringVehicle = true

            local vehicle = GetVehiclePedIsTryingToEnter(playerPed)
            local plate = GetVehicleNumberPlateText(vehicle)
            local seat = GetSeatPedIsTryingToEnter(playerPed)
            local displayName, networkId = GetVehicleData(vehicle)

            TriggerEvent('neptune:enteringVehicle', vehicle, plate, seat, networkId, displayName)
            TriggerServerEvent('neptune:enteringVehicle', vehicle, plate, seat, networkId, displayName)
        end
    end

    _Wait(200)
end)