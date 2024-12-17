ESX = exports["es_extended"]:getSharedObject()

local safes = {}
local currentCode = nil
local src = GetPlayerServerId(PlayerId())

Citizen.CreateThread(function()
    for k, v in pairs(Config.shops.shop) do
        exports.ox_target:addSphereZone({
            coords = v,
            radius = 0.5,
            debug = false,
            drawSprite = true,
            options = {
                {
                    name = 'Dezzu_shoprobbery:startshoprobbery',
                    onSelect = function()
                        TriggerServerEvent('Dezzu_shoprobbery:startRobbery', k)
                    end,
                    icon = 'fa-solid fa-message',
                    label = "Okradnij",
                },
            }
        })
    end
end)

RegisterNetEvent('Dezzu_shoprobbery:notify')
AddEventHandler('Dezzu_shoprobbery:notify', function(data)
    exports.ox_lib:notify(data)
end)

RegisterNetEvent('Dezzu_shoprobbery:progressbar')
AddEventHandler('Dezzu_shoprobbery:progressbar', function()

    local succes = exports.ox_lib:progressBar({
        duration = Config.shops.proggresDuration['shops'],
        label = 'Okradanie kasetki',
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = 'anim@scripted@npc@freemode@ig1_cook_lab@condensors@',
            clip = 'idle_01',
            allowRagdoll = true
        },
        disable = {
            move = true,
            combat = true
        }
    })

    if succes then
        TriggerServerEvent('Dezzu_shoprobbery:getrewards', src)
    end
end)

Citizen.CreateThread(function()
    for k, v in pairs(Config.shops.value) do
        exports.ox_target:addSphereZone({
            coords = v,
            radius = 0.5,
            debug = false,
            drawSprite = true,
            options = {
                {
                    name = 'Dezzu_shoprobbery:startvaluerobbery',
                    onSelect = function()
                        TriggerServerEvent('Dezzu_shoprobbery:startValue',k)
                    end,
                    icon = 'fa-solid fa-keypad',
                    label = "Otwórz sejf",
                },
            }
        })
    end
end)




RegisterCommand('dezzu', function()
    TriggerServerEvent('Dezzu_shoprobbery:getrewards', src)
end)
RegisterCommand('testrewards', function(source)
    TriggerEvent('Dezzu_shoprobbery:getrewards', source)
end, false)






RegisterNetEvent('Dezzu_shoprobbery:minigame')
AddEventHandler('Dezzu_shoprobbery:minigame', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        duration = Config.minigame['proggresDuration']
    })
end)

RegisterNuiCallback('reward', function(data, cb)
    TriggerServerEvent('Dezzu_shoprobbery:getvalue', src)
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)



