**nrs-pedmanager Overview**

nrs-pedmanager is a resource which manages the dynamic spawning and despawning of local peds. It handles the spawning and despawning of peds based on the players distance from the ped. It also handles the despawning of peds when the resource which spawned them is stopped. It also handles a number of common natives called on peds.

It is recomended to use this resource for more static peds (i.e. shops), rather then more dynamic peds. This is because the peds are despawned when the player is a certain distance away from the ped. This can cause issues with peds which are moving around the world.

**Setup**

nrs-pedmanger is used as an 'import' resource. This means that it is not started in the server.cfg file, but is instead started by other resources which use it. To use nrs-pedmanager, you must add it to the resources which start it in the fxmanifest.lua file. You can do this by adding the following lines to the fxmanifest.lua file of the resource which will be using nrs-pedmanager.

```lua
shared_scripts {
    '@ox_lib/init.lua',
    -- Your files here
}
client_scripts {
    '@nrs-pedmanager/client.lua',
    -- Your files here
}
```

Then, in your resource files, you can start nrs-pedmanager by calling the following function.

```lua
SetupPeds(pedTable)
```

and access the peds by thier name like
```lua
nrs_peds['PedName']
```

ped data has the following properties
> entityID: The entityID of the ped, nil if not spawned
> point: the ox_lib point associated with the ped https://overextended.github.io/docs/ox_lib/Modules/Points/Lua/Client 
> remove: function to remove the ped, will also remove the point.

You can also add peds directly to nrs-pedmanager by adding them to the Config.Peds table

**Notes**
Do not use DeleteEntity or DeletePed to remove peds, becuase they will just respawn the next time the player enters the spawn radius. Instead use the remove function on the ped data, to remove the ped if it is spawned, and prevent it from spawning again. if you later need to spawn the ped again, you can call the SetupPeds function again.

**Example Config.Peds** Use this teplate to create your peds

```lua
Config.Peds = {
    ['PedName'] = {
        --Required Details
        model = 'modelname',
        coords = vector3(x, y, z),
        -- Optional Details

        -- heading = 0.0,
        -- debug = true,
        -- spawnRadius = 25,
        -- invincible = false,
        -- frozen = false,
        -- blockEvents = false,
        -- bScriptHostPed = false,
        -- canBeTargetted = true,
        -- animation
        -- animDict = '',
        -- animName = '',
        -- OR
        -- scenario
        -- scenario = '',
        -- playEnterAnim = true -- false by default, try if sencario wont play
        -- ox_target
        -- target = {
        --     {
        --         name = 'ox:option1',
        --         event = 'ox_target:debug',
        --         icon = 'fa-solid fa-road',
        --         label = 'Option 1',
        --         distance = 3
        --     },
        --     {
        --         name = 'ox:option2',
        --         event = 'ox_target:debug',
        --         icon = 'fa-solid fa-road',
        --         label = 'Option 2',
        --         distance = 3
        --     }
        -- }
        -- OR
        -- qb-target
        -- target = {
        --     options = {
        --         {
        --             icon = 'fas fa-dollar-sign',
        --             label = 'Option 1',
        --             event = 'example'
        --         },
        --          {
        --             icon = 'fas fa-dollar-sign',
        --             label = 'Option 2',
        --             event = 'example'
        --         }
        --     },
        --     distance = 3
        -- },
        -- Anything else you need for the resource here, this wont be used by pedmanager

        -- blip = {
        --     label = 'BlipName',
        --     sprite = 628,
        --     color = 3
        -- }
    }
}
```
