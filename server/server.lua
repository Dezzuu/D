ESX = exports["es_extended"]:getSharedObject()
local cooldowns = {}
local webhook = Config.webhook.url

local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function getShopKey(coords)
    if coords then
        local key = string.format("%s:%s:%s", round(coords.x, 2), round(coords.y, 2), round(coords.z, 2))
        return key
    else
        return nil
    end
end



local function getValueKey(coords)
    if coords then
        return string.format("%s:%s:%s", coords.x, coords.y, coords.z)
    else
        return nil
    end
end

function setCooldown(key, type)
    local time = Config.shops.cooldownTime[type] or 0
    cooldowns[key] = os.time() + time
end

function hasCooldown(key)
    local currentTime = os.time()
    local cooldownEnd = cooldowns[key]
    if cooldownEnd then
        print("Cooldown for key:", key, "ends at:", cooldownEnd, "Current time:", currentTime)
    else
        print("No cooldown for key:", key)
    end
    return cooldownEnd and currentTime < cooldownEnd
end


RegisterNetEvent('Dezzu_shoprobbery:startRobbery')
AddEventHandler('Dezzu_shoprobbery:startRobbery', function(shopIndex)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local shopCoords = Config.shops.shop[shopIndex]
    local shopKey = getShopKey(shopCoords)

    if not hasCooldown(shopKey) then
        TriggerClientEvent('Dezzu_shoprobbery:notify', source,
            {
                title = 'Powiadomienie',
                description = 'Rozpoczynasz napad na sklep',
                type = 'Success'
            })
        TriggerClientEvent('Dezzu_shoprobbery:progressbar', source)
        
    else
        TriggerClientEvent('Dezzu_shoprobbery:notify', source,
            {
                title = 'Okradanie zakończone',
                description = 'Poczekaj ' .. (cooldowns[shopKey] - os.time()) .. ' sekund zanim rozpoczniesz następny napad',
                type = 'error'
            })
    end
end)

RegisterNetEvent('Dezzu_shoprobbery:getrewards')
AddEventHandler('Dezzu_shoprobbery:getrewards', function(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    local money = math.random(Config.shops.reward['shops']['min'], Config.shops.reward['shops']['max'])
    local shopCoords = Config.shops.shop[math.random(#Config.shops.shop)]
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local distance = #(playerCoords - shopCoords)
    local check = false
    if distance <= Config.shops.distance['shops'] then

        if not hasCooldown(getShopKey(shopCoords)) then
            check = true
            xPlayer.addInventoryItem('money', money)
            local shopKey = getShopKey(shopCoords)
            sendLog(webhook, 66666, 'Shoprobbery', '[ID ' .. src .. '] ' .. GetPlayerName(src) .. ' ukradł ' .. money .. '$ z sklepu')
            setCooldown(shopKey, 'shops')
        end
    end

    if not check then
        sendLog(webhook, 66666, 'Shoprobbery', '[ID ' .. src .. '] ' .. GetPlayerName(src) .. ' Gracz próbował oszukać skrypt')
        DropPlayer(src, 'Cheater')
    end

end)



RegisterNetEvent('Dezzu_shoprobbery:startValue')
AddEventHandler('Dezzu_shoprobbery:startValue', function(valueIndex)
    local valueCoords = Config.shops.value[valueIndex]
    local valueKey = getValueKey(valueCoords)

    if not hasCooldown(valueKey) then
        TriggerClientEvent('Dezzu_shoprobbery:notify', source,
            {
                title = 'Powiadomienie',
                description = 'Rozpoczynasz napad na sklep',
                type = 'Success'
            })
        TriggerClientEvent('Dezzu_shoprobbery:minigame', source)

    else
        TriggerClientEvent('Dezzu_shoprobbery:notify', source,
            {
                title = 'Okradanie zakończone',
                description = 'Poczekaj ' .. (cooldowns[valueKey] - os.time()) .. ' sekund zanim rozpoczniesz następny napad',
                type = 'error'
            })
    end 
end)

RegisterNetEvent('Dezzu_shoprobbery:getvalue')
AddEventHandler('Dezzu_shoprobbery:getvalue', function(src)
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local withinTarget = false
    local money = math.random(Config.shops.reward['value']['min'], Config.shops.reward['value']['max'])
    
    for i, targetCoords in ipairs(Config.shops.value) do
        local distance = #(playerCoords - targetCoords)
        if distance < Config.shops.distance['value'] then
            local xPlayer = ESX.GetPlayerFromId(src)
            local valueKey = getValueKey(targetCoords)
            
            if not hasCooldown(valueKey) then
                withinTarget = true
                xPlayer.addInventoryItem('money', money)
                sendLog(webhook, 66666, 'Shoprobbery', '[ID ' .. src .. '] ' .. GetPlayerName(src) .. ' ukradł ' .. money .. '$ ze sejfu')
                setCooldown(valueKey, 'value')
                break
            end
        end
    end

    if not withinTarget then
        sendLog(webhook, 66666, 'Shoprobbery', '[ID ' .. src .. '] ' .. GetPlayerName(src) .. ' Gracz próbował oszukać skrypt')
        DropPlayer(src, 'Cheater')
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) 
        
        local currentTime = os.time()
        for key, cooldownEnd in pairs(cooldowns) do
            if currentTime >= cooldownEnd then
                cooldowns[key] = nil
            end
        end
    end
end)

function sendLog(webhook, color, name, message)
    local currentDate = os.date("%Y-%m-%d")
    local currentTime = os.date("%H:%M:%S")
    local embed = {
        {
            ["color"] = color,
            ["title"] = "**" .. tostring(name) .. "**",
            ["description"] = tostring(message),
            ["footer"] = {
                ["text"] = currentTime .. " " .. currentDate,
            },
        }
    }
    
    PerformHttpRequest(webhook, function(err, text, headers)
    end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end


