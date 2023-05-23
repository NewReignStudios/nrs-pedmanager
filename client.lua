local peds = {}
local oxTarget = GetResourceState('ox_target') == 'started'

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

local function GetPedIds()
    local resourceName = GetInvokingResource()
    local retval = {}
    for _, ped in pairs(peds[resourceName]) do retval[#retval + 1] = ped.pedId end
    return retval
end

local function GetPedIdFromName(pedName)
    local resourceName = GetInvokingResource()
    if peds?[resourceName]?[pedName] then return peds[resourceName][pedName].pedId end
end

local function RemovePedsByID(id)
    local resourceName = GetInvokingResource()
    if not peds[resourceName] then error('Could not find ped with id ' .. id) end
    if type(id) == "table" then
        for _, pedID in ipairs(id) do
            RemovePedsByID(pedID)
        end
    end
    local pedToDelete
    for _, ped in pairs(peds) do
        if ped.pedId == id then pedToDelete = ped break end
    end
    if not pedToDelete then error('Could not find ped with id ' .. id) end
    if pedToDelete.pedId then DeletePed(pedToDelete.pedId) end
    if pedToDelete.point then pedToDelete.point.remove() end
end

local function RemovePedsByName(name)
    local resourceName = GetInvokingResource()
    if not peds[resourceName] then error('Could not find ped with name ' .. name) end
    if type(name) == "table" then
        for _, pedName in ipairs(name) do
            RemovePedsByName(pedName)
        end
    end
    local pedToDelete = peds[resourceName][name]
    if not pedToDelete then error('Could not find ped with name ' .. name) end
    if pedToDelete.pedId then DeletePed(pedToDelete.pedId) end
    if pedToDelete.point then pedToDelete.point.remove() end
end

local function SetupPoints(resourceName, ped, pedName)
    if not ped.coords or not ped.model then
        error(("Missing %s"):format(ped.coords and 'model' or 'coords'), 0)
        return
    end
    if not ped.model then
        error("Missing ped model", 0)
        return
    end
    if not pedName then
        error("Missing ped name", 0)
        return
    end
    peds[resourceName] = peds[resourceName] or {}
    local point = lib.points.new({
        coords = ped.coords,
        distance = ped.spawnRadius or 50,
    })
    function point:onEnter()
        local success, pedId = pcall(CreateAPed, ped)
        if not success then error(pedId) end
        ped.pedId = pedId
    end
    function point:onExit()
        DeletePed(ped.pedId)
        ped.pedId = nil
    end
    ped.point = point
    peds[resourceName][pedName] = ped
end

local function SetupPeds(newPeds)
    local resourceName = GetInvokingResource() or GetCurrentResourceName()
    if not next(newPeds) then
        error('Invalid ped table', 0)
        return
    end
    for pedName, ped in pairs(newPeds) do
        SetupPoints(resourceName, ped, pedName)
    end
end

local function DeleteResourcePeds(resource)
    resource = not GetInvokingResource() and resource or GetInvokingResource()
    for _, ped in pairs(peds[resource]) do
        if ped.pedId then DeletePed(ped.pedId) ped.pedId = nil end
        if ped.point then ped.point:remove() end
    end
    peds[resource] = nil
end

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        for _, table in pairs(peds) do
            for _, ped in pairs(table) do
                if ped.pedId then DeletePed(ped.pedId) end
                if ped.point then ped.point:remove() end
            end
        end
        peds = nil
    elseif peds[resource] then
        DeleteResourcePeds(resource)
    end
end)

RegisterNetEvent("nr-pedmanager:client:RefreshPeds", function ()
    for _, resource in pairs(peds) do
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

exports("SetupPeds", SetupPeds)
exports("GetPedIdFromName", GetPedIdFromName)
exports("GetPedIds", GetPedIds)
exports("RemovePedsByID", RemovePedsByID)
exports("RemovePedsByName", RemovePedsByName)
exports("DeleteResourcePeds", DeleteResourcePeds)
