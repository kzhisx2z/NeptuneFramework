local IsInVehicle = false
local IsEnteringVehicle = false
local CurrentVehicle = {}
local PlayerPed = Neptune.PlayerData.ped

local function GetVehicleData(vehicle)
    if DoesEntityExist(vehicle) then
        local model = GetEntityModel(vehicle)
        local displayName = GetDisplayNameFromVehicleModel(model)
        local networkId = NetworkGetNetworkIdFromEntity(vehicle)

        return displayName, networkId
    end
end

CreateThread(function()
    while true do
        if PlayerPed ~= PlayerPedId() then
            PlayerPed = PlayerPedId()
            Neptune.SetPlayerData('ped', PlayerPed)
            TriggerEvent('neptune:playerPedChanged', PlayerPed)
            TriggerServerEvent('neptune:playerPedChanged', PedToNet(PlayerPed))
        end

        if not IsPlayerDead(PlayerPed) then
            if not IsInVehicle then
                if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPed) and not IsEnteringVehicle) then
                    IsEnteringVehicle = true

                    local vehicle = GetVehiclePedIsTryingToEnter(PlayerPed)
                    local plate = GetVehicleNumberPlateText(vehicle)
                    local seat = GetSeatPedIsTryingToEnter(PlayerPed)
                    local displayName, networkId = GetVehicleData(vehicle)

                    TriggerEvent('neptune:enteringVehicle', vehicle, plate, seat, networkId, displayName)
                    TriggerServerEvent('neptune:enteringVehicle', vehicle, plate, seat, networkId, displayName)
                elseif IsPedInAnyVehicle(PlayerPed) then
                    IsEnteringVehicle = false
                    IsInVehicle = true

                    CurrentVehicle = {
                        Vehicle = GetVehiclePedIsUsing(PlayerPed),
                        Seat = GetPedVehicleSeat,
                        DisplayName, NetworkId = GetVehicleData(CurrentVehicle.Vehicle)
                    }

                    TriggerEvent('neptune:enteredVehicle', CurrentVehicle.Vehicle, CurrentVehicle.Seat, CurrentVehicle.DisplayName, CurrentVehicle.NetworkId)
                    TriggerServerEvent('neptune:enteredVehicle', CurrentVehicle.Vehicle, CurrentVehicle.Seat, CurrentVehicle.DisplayName, CurrentVehicle.NetworkId)
                end
            else
                if not IsPedInAnyVehicle(PlayerPed) then
                    IsInVehicle = false

                    TriggerEvent('neptune:existedVehicle', CurrentVehicle.Vehicle, CurrentVehicle.Seat, CurrentVehicle.DisplayName, CurrentVehicle.NetworkId)
                    TriggerServerEvent('neptune:exitedVehicle', CurrentVehicle.Vehicle, CurrentVehicle.Seat, CurrentVehicle.DisplayName, CurrentVehicle.NetworkId)

                    CurrentVehicle = {}
                end
            end
        end

        _Wait(200)
    end
end)