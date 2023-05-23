lib.addCommand('refreshpeds', {
    help = "Refresh any NPCs that seem to be missing",
}, function (source)
    TriggerClientEvent("nr-pedmanager:client:RefreshPeds", source)
end)