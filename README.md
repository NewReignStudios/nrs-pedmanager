**nrs-pedmanager Overview**

nrs-pedmanager is a resource which manages the dynamic spawning and despawning of local peds. It handles the spawning and despawning of peds based on the players distance from the ped. It also handles the despawning of peds when the resource which spawned them is stopped. It also handles a number of common natives called on peds.

It is recomended to use this resource for more static peds (i.e. shops), rather then more dynamic peds. This is because the peds are despawned when the player is a certain distance away from the ped. This can cause issues with peds which are moving around the world.

nrs-pedmanager exports 6 funtions for use in your resources

**SetupPeds()** adds a ped or peds to be managed and spawned when in range
```lua
exports['nrs-pedmanager']:SetupPeds(Config.Peds)
```

**RemovePedsByID** takes a peds entity ID, removes it from the manged list, and deletes it
```lua
exports['nrs-pedmanager']:RemovePedsById({pedId1, pedId2, pedId3})
-- OR
exports['nrs-pedmanager']:RemovePedsById(pedId1)
```

**RemovePedsByName** takes a peds name, removes it from the manged list, and deletes it
```lua
exports['nrs-pedmanager']:RemovePedsByName({'Name1', 'Name2', 'Name3'})
-- OR
exports['nrs-pedmanager']:RemovePedsByName('Name')
```

**GetPedIdFromName** returns the entity id of a given ped if it exists
```lua
local pedId = exports['nrs-pedmanager']:GetPedIdFromName('Name')
```
**GetPedIds** returns all the pedIds of peds from a given resource if they exist
```lua
local pedIds = exports['nrs-pedmanager']:GetPedIds()
```

**GetPedIDs** returns the entity ids of all peds spawned from the invoking resource
```lua
local pedIds = exports['nrs-pedmanager']:GetPedIDs()
```

**DeleteResourcePeds** deletes all peds spawned from the invoking resource
```lua
exports['nrs-pedmanager']:DeleteResourcePeds()
```

**Notes**
If you want peds to start with the resource, you will want the following code

```lua
local function SpawnPeds()
    exports['nrs-pedmanager']:SetupPeds(Config.Peds)
end

AddEventHandler('onResourceStart', function(resource)
    if resource == 'nrs-pedmanager' then
        SpawnPeds()
    end
end)

CreateThread(SpawnPeds)
```

**Example Config.Peds** Use this teplate to create your peds
```lua
Example.Peds = {
    --Required Details
    ['PedName'] = {
        model = 'modelname',
        coords = vector3(x, y, z),
        -- Optional Details
        heading = 0.0,
        debug = true,
        spawnRadius = 25,
        invincible = false,
        frozen = false,
        blockEvents = false,
        bScriptHostPed = false,
        canBeTargetted = true,
        -- animation
        animDict = '',
        animName = '',
        -- OR
        -- scenario
        scenario = '',
        playEnterAnim = true -- false by default, try if sencario wont play
        -- ox_target
        target = {
            {
                name = 'ox:option1',
                event = 'ox_target:debug',
                icon = 'fa-solid fa-road',
                label = 'Option 1',
                distance = 3
            }
            {
                name = 'ox:option2',
                event = 'ox_target:debug',
                icon = 'fa-solid fa-road',
                label = 'Option 2',
                distance = 3
            }
        }
        -- OR
        -- qb-target
        target = {
            options = {
                {
                    icon = 'fas fa-dollar-sign',
                    label = 'Option 1',
                    event = 'example'
                },
                 {
                    icon = 'fas fa-dollar-sign',
                    label = 'Option 2',
                    event = 'example'
                }
            },
            distance = 3
        },
        -- Anything else you need for the resource here, this wont be used by pedmanager
        blip = {
            label = 'BlipName',
            sprite = 628,
            color = 3
        }
    }
}
```
