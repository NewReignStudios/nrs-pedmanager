local oxTarget = GetResourceState('ox_target') == 'started'
nrs_peds = {}

local function CreateAPed(ped)
    lib.requestModel(ped.model)
    for property, default in pairs(Config.Defaults) do
        if ped[property] == nil then ped[property] = default end
    end
    local spawnedped = CreatePed(0, joaat(ped.model), ped.coords.x, ped.coords.y, ped.coords.z, ped.heading or 0, false, ped.bScriptHostPed)
    if not spawnedped then return false end
    FreezeEntityPosition(spawnedped, ped.frozen)
    SetEntityInvincible(spawnedped, ped.invincible)
    SetBlockingOfNonTemporaryEvents(spawnedped, ped.blockEvents)
    SetPedCanBeTargetted(spawnedped, ped.canBeTargetted)
    if ped.scenario then
        TaskStartScenarioInPlace(spawnedped, ped.scenario, 0, ped.playEnterAnim)
    elseif ped.animDict and ped.animName then
        lib.requestAnimDict(ped.animDict)
        TaskPlayAnim(spawnedped, ped.animDict, ped.animName, 8.0, 0, -1, ped.animFlag or 1, 0, false, false)
    end
    if ped.target then
        if oxTarget then
            exports.ox_target:addLocalEntity(spawnedped, ped.target)
        else
            exports["qb-target"]:AddTargetEntity(spawnedped, {options = ped.target.options, distance = ped.target.distance})
        end
    end
    if ped.onSpawn then ped.onSpawn(spawnedped) end
    return spawnedped
end

local function SetupPoints(pedName, pedData)
    if not pedData.coords then
        error("Missing ped coords", 0)
        return
    end
    if not pedData.model then
        error("Missing ped model", 0)
        return
    end
    if not pedName then
        error("Missing ped name", 0)
        return
    end
    local point = lib.points.new({
        coords = pedData.coords,
        distance = pedData.spawnRadius or 50,
    })
    local entityID
    function point:onEnter()
        nrs_peds[pedName].entityID = CreateAPed(pedData)
    end
    function point:onExit()
        ped = nrs_peds[pedName]
        DeletePed(ped.entityID)
        ped.entityID = nil
    end
    nrs_peds[pedName] = {
        entityID = entityID,
        point = point,
        remove = function ()
            local ped = nrs_peds[pedName]
            ped.point:remove()
            if ped.entityID then
                DeletePed(ped.entityID)
            end
            nrs_peds[pedName] = nil
        end
    }
end

function SetupPeds(newPeds)
    if not next(newPeds) then
        error('Invalid ped table', 0)
        return
    end
    for pedName, pedData in pairs(newPeds) do
        SetupPoints(pedName, pedData)
    end
end

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        for _, table in pairs(nrs_peds) do
            for _, ped in pairs(table) do
                if ped.pedId then DeletePed(ped.pedId) end
                if ped.point then ped.point:remove() end
            end
        end
        nrs_peds = nil
    end
end)

RegisterNetEvent("nr-pedmanager:client:RefreshPeds", function ()
    for _, resource in pairs(nrs_peds) do
        for _, ped in pairs(resource) do
            if ped.pedId then DeletePed(ped.pedId) end
            if ped.point.distance <= ped.spawnRadius then
                ped.pedId = CreateAPed(ped)
            end
        end
    end
end)

CreateThread(function ()
    SetupPeds(Config.Peds)
end)
