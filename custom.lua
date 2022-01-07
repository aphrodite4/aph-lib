custom = {}
if cfg.framework:lower() == 'custom' then
    local frameworkvariable = '' -- your global framework variable, don't forget to fill!

    if IsDuplicityVersion() then --server
        _G[frameworkvariable] = nil

        custom.get = function(fn, cb, args)
            if fn == 'getFramework' then -- only callback
                --edit here

                ----- example: ----- Let's say our framework variable is QBCore.
                -- QBCore = exports['qb-core']:GetCoreObject()
                --------------------

                cb(true)
            elseif fn == 'registerItem' then -- no return required
                local itemname = args[1]
                --edit here

                ----- example: -----
                -- QBCore.Functions.CreateUseableItem(itemname, cb)
            elseif fn == 'getItems' then
                --edit here

                ----- example: -----
                -- if cb then cb(QBCore.Shared.Items) else return QBCore.Shared.Items end
                --------------------
            elseif fn == 'getPlayerData' then -- return if no callback
                local playerData = {
                    charInfo = {},
                    job = {},
                    faction = {}
                }
                --edit here

                ----- example: -----
                -- local player = QBCore.Functions.GetPlayer(src)
                -- if player then
                --     playerData.charInfo.firstname = player.PlayerData.charinfo.firstname
                --     playerData.charInfo.lastname = player.PlayerData.charinfo.lastname
                --     playerData.charInfo.dateofbirth = player.PlayerData.charinfo.birthdate
                --     playerData.charInfo.nationality = player.PlayerData.charinfo.nationality
                --     playerData.charInfo.gender = player.PlayerData.charinfo.gender
                --     playerData.charInfo.phone = player.PlayerData.charinfo.phone

                --     playerData.job.name = player.PlayerData.job.name
                --     playerData.job.label = player.PlayerData.job.label 
                --     playerData.job.grade = player.PlayerData.job.grade.level 
                --     playerData.job.gradeLabel = player.PlayerData.grade.name
                --     playerData.job.onDuty = player.PlayerData.job.onduty

                --     playerData.faction.name = player.PlayerData.gang.name
                --     playerData.faction.label = player.PlayerData.gang.grade.label
                --     playerData.faction.grade = player.PlayerData.gang.grade.level
                --     playerData.faction.gradeLabel = player.PlayerData.gang.grade.name

                --     if cb then cb(playerData) else return playerData end
                -- end
                --------------------
            elseif fn == 'getCitizenIdOrIdentifier' then -- return if no callback
                local src = args[1]
                --edit here

                ----- example: -----
                -- local player = QBCore.Functions.GetPlayer(src)
                -- if player then
                --     if cb then cb(player.PlayerData.citizenid) else return player.PlayerData.citizenid end
                -- end
                --------------------
            elseif fn == 'addMoney' then -- no return required
                local src, type, amount, reason = args[1], args[2], args[3], args[4]
                --edit here

                ----- example: -----
                -- local player = QBCore.Functions.GetPlayer(src)
                -- if player then
                --     player.Functions.AddMoney(type, amount, reason)
                -- end
                --------------------
            elseif fn == 'removeMoney' then -- no return required
                --edit here
            elseif fn == 'setMoney' then -- no return required
                local src, type, amount, reason = args[1], args[2], args[3], args[4]
                --edit here
            elseif fn == 'getMoney' then -- return if no callback
                local src, type = args[1], args[2]
                --edit here
            elseif fn == 'getInventory' then -- return if no callback
                local src = args[1]
                --edit here

                ----- example: -----
                -- local player = QBCore.Functions.GetPlayer(src)
                -- if player then
                --     if cb then cb(player.PlayerData.items) else return player.PlayerData.items end
                -- end
                --------------------
            elseif fn == 'getItemBySlotId' then -- return if no callback
                local src, slotId = args[1], args[2]
                --edit here

                ----- example: -----
                -- local player = QBCore.Functions.GetPlayer(src)
                -- if player then
                --     local item = player.Functions.GetItemBySlot(slotId)
                --     if cb then cb(item) else return item end
                -- end
                --------------------
            elseif fn == 'getFirstItemByName' then -- return if no callback
                local src, itemname = args[1], args[2]
                --edit here

                ----- example: -----
                -- local player = QBCore.Functions.GetPlayer(src)
                -- if player then
                --     local slotId = QBCore.Player.GetFirstSlotByItem(player.PlayerData.items, itemname)
                --     local item = player.Functions.GetItemBySlot(slotId)
                --     if cb then cb(item) else return item end
                -- end
                --------------------
            elseif fn == 'getItem' then -- return if no callback
                local src, itemname = args[1], args[2]
                --edit here -- i use it to get item count, habit from esx :(
                
                ----- example: -----
                -- local player = QBCore.Functions.GetPlayer(src)
                -- if player then
                --     local item = {}
                --     local metadatas = {}
                --     local totalcount = 0
                --     local itemInfo = QBCore.Shared.Items[itemname:lower()]
                --     local items = player.Functions.GetItemsByName(itemname)
                --     for i = 1, #items, 1 do
                --         totalcount = totalcount + items[i].count
                --         table.insert(metadatas, qbitem[i].info)
                --     end
                --     item.name = itemInfo.name
                --     item.count = totalcount
                --     item.label = itemInfo.label
                --     item.weight = itemInfo.weight
                --     item.metadatas = metadatas

                --     if cb then cb(item) else return item end
                -- end
                --------------------
            elseif fn == 'addItem' then -- no return required
                local src, name, amount, metadata = args[1], args[2], args[3], args[4]
                --edit here
            elseif fn == 'removeItem' then -- no return required
                local src, name, amount, slotId = args[1], args[2], args[3], args[4]
                --edit here
            end
        end
    -- else --client

        -- WORK IN PROGRESS --

        -- _G[frameworkvariable] = nil

        -- custom.get = function(fn, cb, ...)

        -- end
    end
end