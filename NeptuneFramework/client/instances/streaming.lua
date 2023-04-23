function Neptune.Streaming.RequestModel(model, callback)
    if IsModelInCdimage(model) then
        RequestModel(model)

        while not HasModelLoaded(model) do
            Wait(0)
        end
    end
end

function Neptune.Streaming.RequestCollision(entity, coords)
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)

    while not HasCollisionLoadedAroundEntity(entity) do
        Wait(0)
    end
end