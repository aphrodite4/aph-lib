aph.functions = {}
aph.serverCallbacks = {}
local framework, ready, ESX, QBCore = nil, false, nil, nil

exports('getLib', function(cb) 
    while not ready do
        Citizen.Wait(0)
    end
    if cb then cb(aph) else return aph end
end)

Citizen.CreateThread(function()
    if cfg.sqlwrapper:lower() == 'oxmysql' or cfg.sqlwrapper:lower() == 'mysql-async' then
        local lib = LoadResourceFile(cfg.sqlwrapper:lower(), 'lib/MySQL.lua')
        load(lib)()

        while not MySQL do
            Citizen.Wait(0)
        end

        if not MySQL.query and (MySQL.Async.execute and MySQL.Sync.execute) then
            MySQL.query = {
                await = function(...)
                    return MySQL.Sync.execute(...)
                end
            }
            setmetatable(MySQL.query, {
                __call = function(_, ...)
                    return MySQL.Async.execute(...)
                end
            })
        end
    else
        local MySQL = {}
        MySQL.query = function(...)
            exports[cfg.sqlwrapper:lower()]:execute(...)
        end
        _ENV.MySQL = MySQL
    end

    
    aph.functions.executeSql = function(query, parameters, callback)
        if callback then
            MySQL.query(query, parameters, function(results)
                callback(results)
            end)
        else
            return MySQL.query.await(query, parameters)
        end
    end

    if cfg.framework:lower() == 'esx' then
        framework = 'esx'
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        ready = true
    elseif cfg.framework:lower() == 'qb' then
        framework = 'qb'
        while not QBCore do
            Citizen.Wait(10)
            pcall(function() QBCore = exports['qb-core']:GetCoreObject() end)
            if not QBCore then
                pcall(function() QBCore = exports['qb-core']:GetSharedObject() end)
            end
            if not QBCore then
                TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
            end
        end
        ready = true
    elseif cfg.framework:lower() == 'custom' then
        framework = 'custom'
        custom.get('getFramework', function(status)
            if status then
                ready = true
            else
                aph.functions.debug('Could not get framework!')
            end
        end)
    end
end)

aph.functions.notification = function(src, type, str, length)
    TriggerClientEvent('aph:client:notification', src, type, str, length)
end

aph.functions.debug = function(text)
    print('[^1Aphrodite^0] - [^1Debug^0]: '..text)
end

aph.functions.registerCallback = function(name, cb)
    aph.serverCallbacks[name] = cb
end

aph.functions.triggerCallback = function(name, src, cb, ...)
    if aph.serverCallbacks[name] then
        aph.serverCallbacks[name](src, cb, ...)
    else
        aph.functions.debug('This callback(^2'..name..'^0) is not registered!')
    end
end

aph.functions.getIdentifier = function(src, identifiertype)
    local identifiers = GetPlayerIdentifiers(src)
    local response = {}
    if identifiertype then
        if type(identifiertype) == 'table' then
            for _, identifiertype2 in pairs(identifiertype) do
                for _, identifier in pairs(identifiers) do
                    if string.find(identifier, identifiertype2) then
                        response[identifiertype2] = identifier
                    end
                end
            end
        else
            for _, identifier in pairs(identifiers) do
                if string.find(identifier, identifiertype) then
                    return identifier
                end
            end
        end
    else
        for _, identifier in pairs(identifiers) do
            if string.find(identifier, 'steam') then
                return identifier
            end
        end
    end
	return response
end

aph.functions.sanitize = function(str)
    if str then
        local replacements = {
            ['&' ] = '&amp;',
            ['<' ] = '&lt;',
            ['>' ] = '&gt;',
            ['\n'] = '<br/>'
        }

        return str:gsub('[&<>\n]', replacements):gsub(' +', function(s) return ' '..('&nbsp;'):rep(#s-1) end)
    else
        return nil
    end
end

aph.functions.sendLog = function(webhookURL, color, str)
    if webhookURL and webhookURL ~= '' then
        local headers = {
            ['Content-Type'] = 'application/json'
        }
        local data = {
            ["username"] = 'aphrodite-logs',
            ["avatar_url"] = 'https://raw.githubusercontent.com/aphrodite4/pp/main/aphrodite.png',
            ["embeds"] = {{
                ["title"] = 'aphrodite.tebex.io',
                ["url"] = 'https://aphrodite.tebex.io/',
                ["color"] = cfg.discordLogColors[color] ~= nil and cfg.discordLogColors[color] or cfg.discordLogColors['default'],
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }},
            ["footer"] = {
                ["text"] = 'aphrodite.tebex.io',
                ["icon_url"] = 'https://raw.githubusercontent.com/aphrodite4/pp/main/aphrodite.png'
            }
        }
        data['embeds'][1]['description'] = str
        PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode(data), headers)
    else
        aph.functions.debug('sendLog - URL is empty!')
    end
end

aph.functions.sendSelfLog = function(src, webhookURL, color, str)
    if webhookURL and webhookURL ~= '' then
        if src then
            local name = aph.functions.sanitize(GetPlayerName(src))
            local identifiers = aph.functions.getIdentifier(src, {'steam', 'discord'})
            local text = '**Steam**: '..identifiers['steam']
            if identifiers['discord'] then
                text = text..'\n**Discord**: <@'..identifiers['discord']:sub(9)..'>\n'
            end
            local headers = {
                ['Content-Type'] = 'application/json'
            }
            local data = {
                ["username"] = 'aphrodite-logs',
                ["avatar_url"] = 'https://raw.githubusercontent.com/aphrodite4/pp/main/aphrodite.png',
                ["embeds"] = {{
                    ["title"] = 'aphrodite.tebex.io',
                    ["url"] = 'https://aphrodite.tebex.io/',
                    ["author"] = {
                        ["name"] = '#'..src..' - '..name,
                        ["url"] = 'https://aphrodite.tebex.io/',
                    },
                    ["color"] = cfg.discordLogColors[color] ~= nil and cfg.discordLogColors[color] or cfg.discordLogColors['default'],
                    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                    ["footer"] = {
                        ["text"] = 'aphrodite.tebex.io',
                        ["icon_url"] = 'https://raw.githubusercontent.com/aphrodite4/pp/main/aphrodite.png'
                    }
                }}
            }
            data['embeds'][1]['description'] = text..''..str
            PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode(data), headers)
        end
    else
        aph.functions.debug('sendSelfLog - URL is empty!')
    end
end

aph.functions.registerItem = function(itemname, cb)
    if framework == 'esx' then
        ESX.RegisterUsableItem(itemname, cb)
    elseif framework == 'qb' then
        QBCore.Functions.CreateUseableItem(itemname, cb)
    elseif framework == 'custom' then
        custom.get('registerItem', cb, {itemname})
    end
end

aph.functions.getItems = function(callback)
    if framework == 'esx' then
        if callback then cb(ESX.Items) else return ESX.Items end
    elseif framework == 'qb' then
        if callback then cb(QBCore.Shared.Items) else return QBCore.Shared.Items end
    elseif framework == 'custom' then
        if callback then custom.get('getItems', callback) else return custom.get('getItems') end
    end
end

aph.functions.registerCallback('aph:server:getInventory', function(src, cb)
    aph.functions.getInventory(src, function(inventory)
        cb(json.encode(inventory))
    end)
end)

RegisterNetEvent('aph:server:triggerCallback', function(name, ...)
	local src = source

	aph.functions.triggerCallback(name, src, function(...)
		TriggerClientEvent('aph:client:triggerCallback', src, name, ...)
	end, ...)
end)

--player functions
aph.functions.getPlayerData = function(src, cb)
    local playerData = {
        charInfo = {},
        job = {},
        faction = {}
    }

    if framework == 'esx' then
        local player = ESX.GetPlayerFromId(src)
        if player then
            playerData.charInfo.firstname = player.firstName or player.variables.firstName or player.get('firstName')
            playerData.charInfo.lastname = player.lastName or player.variables.lastName or player.get('lastName')
            playerData.charInfo.dateofbirth = player.dateofbirth or player.variables.dateofbirth or player.get('dateofbirth')
            playerData.charInfo.gender = player.sex or player.variables.sex or player.get('sex')
            playerData.charInfo.phone = player.phoneNumber or player.variables.phoneNumber or player.get('phoneNumber')

            playerData.job.name = player.job.name
            playerData.job.label = player.job.label
            playerData.job.grade = player.job.grade
            playerData.job.gradeLabel = player.job.grade_label
            playerData.job.onDuty = true

            if cb then cb(playerData) else return playerData end
        end
    elseif framework == 'qb' then
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            playerData.charInfo.firstname = player.PlayerData.charinfo.firstname
            playerData.charInfo.lastname = player.PlayerData.charinfo.lastname
            playerData.charInfo.dateofbirth = player.PlayerData.charinfo.birthdate
            playerData.charInfo.nationality = player.PlayerData.charinfo.nationality
            playerData.charInfo.gender = player.PlayerData.charinfo.gender
            playerData.charInfo.phone = player.PlayerData.charinfo.phone

            playerData.job.name = player.PlayerData.job.name
            playerData.job.label = player.PlayerData.job.label 
            playerData.job.grade = player.PlayerData.job.grade.level 
            playerData.job.gradeLabel = player.PlayerData.job.grade.name
            playerData.job.onDuty = player.PlayerData.job.onduty

            playerData.faction.name = player.PlayerData.gang.name
            playerData.faction.label = player.PlayerData.gang.grade.label
            playerData.faction.grade = player.PlayerData.gang.grade.level
            playerData.faction.gradeLabel = player.PlayerData.gang.grade.name

            if cb then cb(playerData) else return playerData end
        end
    elseif framework == 'custom' then
        if cb then custom.get('getPlayerData', cb, {src}) else return custom.get('getPlayerData', false, {src}) end
    end
end

aph.functions.getCitizenIdOrIdentifier = function(src, cb)
    if framework == 'esx' then
        local player = ESX.GetPlayerFromId(src)
        if player then
            if cb then cb(player.identifier) else return player.identifier end
        end
    elseif framework == 'qb' then
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            if cb then cb(player.PlayerData.citizenid) else return player.PlayerData.citizenid end
        end
    elseif framework == 'custom' then
        if cb then custom.get('getCitizenIdOrIdentifier', cb, {src}) else return custom.get('getCitizenIdOrIdentifier', false, {src}) end
    end
end

aph.functions.addMoney = function(src, type, amount, reason)
    if framework == 'esx' then
        local player = ESX.GetPlayerFromId(src)
        if player then
            if type:lower() == 'cash' then
                player.addMoney(amount)
            else
                player.addAccountMoney(type, amount)
            end
        end
    elseif framework == 'qb' then
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            player.Functions.AddMoney(type, amount, reason)
        end
    elseif framework == 'custom' then
        custom.get('addMoney', false, {src, type, amount, reason})
    end
end

aph.functions.removeMoney = function(src, type, amount, reason)
    if framework == 'esx' then
        local player = ESX.GetPlayerFromId(src)
        if player then
            if type:lower() == 'cash' then
                player.removeMoney(amount)
            else
                player.removeAccountMoney(type, amount)
            end
        end
    elseif framework == 'qb' then
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            player.Functions.RemoveMoney(type, amount, reason)
        end
    elseif framework == 'custom' then
        custom.get('removeMoney', false, {src, type, amount, reason})
    end
end

aph.functions.setMoney = function(src, type, amount, reason)
    if framework == 'esx' then
        local player = ESX.GetPlayerFromId(src)
        if player then
            if type:lower() == 'cash' then
                player.setMoney(amount)
            else
                player.setAccountMoney(type, amount)
            end
        end
    elseif framework == 'qb' then
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            player.Functions.SetMoney(type, amount, reason)
        end
    elseif framework == 'custom' then
        custom.get('setMoney', false, {src, type, amount, reason})
    end
end

aph.functions.getMoney = function(src, type, cb)
    if framework == 'esx' then
        local player = ESX.GetPlayerFromId(src)
        if player then
            if type:lower() == 'cash' then
                local amount = player.getMoney()
                if cb then cb(amount) else return amount end
            else
                local amount = player.getAccount(type).money
                if cb then cb(amount) else return amount end
            end
        end
    elseif framework == 'qb' then
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            local amount = player.Functions.GetMoney(type)
            if cb then cb(amount) else return amount end
        end
    elseif framework == 'custom' then
        if cb then custom.get('getMoney', cb, {src, type}) else return custom.get('getMoney', false, {src, type}) end
    end
end

aph.functions.getInventory = function(src, cb)
    if framework == 'esx' then
        local player = ESX.GetPlayerFromId(src)
        if player then
            if cb then cb(player.inventory) else return player.inventory end
        end
    elseif framework == 'qb' then
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            if cb then cb(player.PlayerData.items) else return player.PlayerData.items end
        end
    elseif framework == 'custom' then
        if cb then custom.get('getInventory', cb, {src}) else return custom.get('getInventory', false, {src}) end
    end
end

aph.functions.getItem = function(src, name, cb)
    local item = {
        name = nil,
        count = nil,
        label = nil,
        weight = nil
    }
    if framework == 'esx' then
        local player = ESX.GetPlayerFromId(src)
        if player then
            local esxitem = player.getInventoryItem(name)
            item.name = esxitem.name
            item.count = esxitem.count
            item.label = esxitem.label
            item.weight = esxitem.weight
            
            if cb then cb(item) else return item end
        end
    elseif framework == 'qb' then
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            local totalcount = 0
            local metadatas = {}
            local itemInfo = QBCore.Shared.Items[name:lower()]
            local qbitem = player.Functions.GetItemsByName(name)
            for i = 1, #qbitem, 1 do
                totalcount = totalcount + qbitem[i].amount
                table.insert(metadatas, qbitem[i].info)
            end
            item.name = itemInfo.name
            item.count = totalcount
            item.label = itemInfo.label
            item.weight = itemInfo.weight
            item.metadatas = metadatas

            if cb then cb(item) else return item end
        end
    elseif framework == 'custom' then
        if cb then custom.get('getItem', cb, {src, name}) else return custom.get('getItem', false, {src, name}) end
    end
end

aph.functions.getItemBySlotId = function(src, slotId, cb)
    if framework == 'esx' then
        if cb then cb(nil) else return nil end --esx :(
    elseif framework == 'qb' then
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            local item = player.Functions.GetItemBySlot(slotId)
            if cb then cb(item) else return item end
        end
    elseif framework == 'custom' then
        custom.get('getItemBySlotId', cb, {src, slotId})
    end
end

aph.functions.getFirstItemByName = function(src, name, cb)
    if framework == 'esx' then
        aph.functions.getItem(src, name, cb) --esx :(
    elseif framework == 'qb' then
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            aph.functions.getInventory(src, function(inventory)
                if inventory then
                    local slotId = QBCore.Player.GetFirstSlotByItem(inventory, name)
                    aph.functions.getItemBySlotId(src, slotId, cb)
                end
            end)
        end
    elseif framework == 'custom' then
        custom.get('getFirstItemByName', cb, {src, name})
    end
end

aph.functions.addItem = function(src, name, amount, metadata)
    if framework == 'esx' then
        local player = ESX.GetPlayerFromId(src)
        if player then
            player.addInventoryItem(name, amount)
        end
    elseif framework == 'qb' then
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            player.Functions.AddItem(name, amount, metadata)
        end
    elseif framework == 'custom' then
        custom.get('addItem', cb, {src, name, amount, metadata})
    end
end

aph.functions.removeItem = function(src, name, amount, slotId)
    if framework == 'esx' then
        local player = ESX.GetPlayerFromId(src)
        if player then
            player.removeInventoryItem(name, amount)
        end
    elseif framework == 'qb' then
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            player.Functions.RemoveItem(name, amount, slotId)
        end
    elseif framework == 'custom' then
        custom.get('removeItem', cb, {src, name, amount, slotId})
    end
end
