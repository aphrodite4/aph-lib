aph.functions = {}
aph.serverCallbacks = {}

exports('getLib', function(cb) if cb then cb(aph) else return aph end end)

aph.player = {
    playerId = PlayerId()
}

aph.functions.notification = function(type, str, length)
    SetNotificationTextEntry('STRING')
	AddTextComponentString(str)
	DrawNotification(0, 1)
end

aph.functions.copyString = function(str)
    SendNUIMessage({
        action = 'copyString',
        string = str
    })
end

aph.functions.registerKeyMap = function(data, cb, cb2)
	RegisterCommand('+apH_'..data.command, function()
        local useWhileNuiFocus = data.useWhileNuiFocus and data.useWhileNuiFocus or false
        local useWhileFrontendMenu = data.useWhileFrontendMenu and data.useWhileFrontendMenu or false
        local response = true
        if not useWhileFrontendMenu and IsPauseMenuActive() then
            response = false
        end
        if not useWhileNuiFocus and IsNuiFocused() then
            response = false
        end
        if cb then
            cb(response)
        end
	end)
	RegisterCommand('-apH_'..data.command, function()
		if cb2 then
            cb2()
        end
	end)
	if data.key:match('mouse') or data.key:match('iom') then
		RegisterKeyMapping('+apH_'..data.command, data.description, 'mouse_button', data.key:lower())
	else
		RegisterKeyMapping('+apH_'..data.command, data.description, 'keyboard', data.key:lower())
	end
end

aph.functions.addBlip = function(coords, sprite, scale, color, str, cb)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, scale)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(str)
    EndTextCommandSetBlipName(blip)
    if cb then cb(blip) else return blip end
end

aph.functions.drawBusySpinner = function(str)
    SetLoadingPromptTextEntry('STRING')
    AddTextComponentSubstringPlayerName(str)
    ShowLoadingPrompt(3)
end

aph.functions.loadAnimDict = function(dict, cb)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)

        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(1)
        end
    end

    if cb then cb() end
    Citizen.Wait(100)
    RemoveAnimDict(dict)
end

aph.functions.loadPtfxAsset = function(asset, cb)
    if not HasNamedPtfxAssetLoaded(asset) then
        RequestNamedPtfxAsset(asset)

        while not HasNamedPtfxAssetLoaded(asset) do
            Citizen.Wait(1)
        end
    end

    if cb then cb() end
    Citizen.Wait(100)
    RemovePtfxAsset(asset)
end

aph.functions.loadAnimSet = function(set, cb)
    if not HasAnimSetLoaded(set) then
        RequestAnimSet(set)

        while not HasAnimSetLoaded(asset) do
            Citizen.Wait(1)
        end
    end

    if cb then cb() end
    Citizen.Wait(100)
    RemoveAnimSet(asset)
end

aph.functions.requestModel = function(model, cb)
	model = type(model) == 'number' and model or GetHashKey(model)
	if model and IsModelValid(model) then
		if not HasModelLoaded(model) then
			RequestModel(model)

			while not HasModelLoaded(model) do
				Citizen.Wait(0)
			end

			if cb then cb(true) end
			Citizen.Wait(100)
			SetModelAsNoLongerNeeded(model)
		else
			if cb then cb(true) end
			Citizen.Wait(100)
			SetModelAsNoLongerNeeded(model)
		end
	else
		aph.functions.debug('Model('..model..') is not valid!')
		if cb then cb(false) end
	end
end

-- aph.functions.drawText2D = function(x, y, str, scale, r, g, b, a)
--     SetTextFont(4)
--     SetTextProportional(0)
--     SetTextScale(scale or 0.45, scale or 0.45)
--     SetTextColour(r or 185, g or 185, b or 185, a or 255)
--     SetTextDropShadow(0, 0, 0, 0,255)
--     SetTextEdge(2, 0, 0, 0, 255)
--     SetTextDropShadow()
--     SetTextOutline()
--     SetTextEntry('STRING')
-- 	AddTextComponentString(str)
--     DrawText(x, y)
-- end

-- aph.functions.drawText3D = function(x, y, z, str, length, r, g, b, a)
--     local onScreen, _x, _y = World3dToScreen2d(x, y, z)
--     if onScreen then
--         local factor = #str / 370
--         if length then
--             factor = #str / length
--         end
--         SetTextScale(0.30, 0.30)
--         SetTextFont(4)
--         SetTextProportional(1)
--         SetTextColour(r or 255, g or 255, b or 255, a or 215)
--         SetTextEntry('STRING')
--         SetTextCentre(1)
--         AddTextComponentString(str)
--         DrawText(_x, _y)
--         DrawRect(_x, _y + 0.0120, 0.006 + factor, 0.024, 0, 0, 0, 155)
--     end
-- end

aph.functions.triggerCallback = function(name, cb, ...)
	aph.serverCallbacks[name] = cb
    TriggerServerEvent('aph:server:triggerCallback', name, ...)
end

-- thanks to baziforyou https://github.com/BaziForYou/MugShotBase64
local b64mugshots = {}
aph.functions.getBase64Mugshot = function(ped, transparent, cb)
    if not ped then ped = PlayerPedId() end
    local id = #b64mugshots + 1
    if transparent then
        b64mugshots[id] = RegisterPedheadshotTransparent(ped)
    else
        b64mugshots[id] = RegisterPedheadshot(ped)
    end

    while (not IsPedheadshotReady(b64mugshots[id]) or not IsPedheadshotValid(b64mugshots[id])) do
        Citizen.Wait(0)
    end

    SendNUIMessage({
        action = 'b64Mugshot',
        txd = GetPedheadshotTxdString(b64mugshots[id]),
        id = id
    })

    UnregisterPedheadshot(b64mugshots[id])
    b64mugshots[id] = 'waiting'

    while b64mugshots[id] == 'waiting' do
        Citizen.Wait(0)
    end

    local b64mugshot = b64mugshots[id]
    b64mugshots[id] = nil

    if cb then cb(b64mugshot) else return b64mugshot end
end

RegisterNUICallback('returnB64Mugshot', function(data)
    b64mugshots[data.id] = data.b64mugshot
end)

aph.functions.debug = function(text)
    print('[aphrodite] - [Debug]: '..text)
end

RegisterNetEvent('aph:client:notification', function(...)
    aph.functions.notification(...)
end)

RegisterNetEvent('aph:client:triggerCallback', function(name, ...)
    if aph.serverCallbacks[name] then
		aph.serverCallbacks[name](...)
		aph.serverCallbacks[name] = nil
	end
end)

--player functions
aph.functions.getInventory = function(cb)
    local inventory
    aph.functions.triggerCallback('aph:server:getInventory', function(data)
        local data = json.decode(data)
        if cb then cb(data) else inventory = data end
    end)
    if not cb then return inventory end
end

-- getters thanks qbcore https://github.com/qbcore-framework/qb-core
function aph.functions.getVehicles()
    return GetGamePool('CVehicle')
end

function aph.functions.getObjects()
    return GetGamePool('CObject')
end

function aph.functions.getPlayers()
    return GetActivePlayers()
end

function aph.functions.getPeds(ignoreList)
    local pedPool = GetGamePool('CPed')
    local ignoreList = ignoreList or {}
    local peds = {}
    for i = 1, #pedPool, 1 do
        local found = false
        for j = 1, #ignoreList, 1 do
            if ignoreList[j] == pedPool[i] then
                found = true
            end
        end
        if not found then
            peds[#peds + 1] = pedPool[i]
        end
    end
    return peds
end

function aph.functions.getClosestPed(coords, ignoreList)
    local ped = PlayerPedId()
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    local ignoreList = ignoreList or {}
    local peds = aph.functions.getPeds(ignoreList)
    local closestDistance = -1
    local closestPed = -1
    for i = 1, #peds, 1 do
        local pedCoords = GetEntityCoords(peds[i])
        local distance = #(pedCoords - coords)

        if closestDistance == -1 or closestDistance > distance then
            closestPed = peds[i]
            closestDistance = distance
        end
    end
    return closestPed, closestDistance
end

function aph.functions.getClosestPlayer(coords)
    local ped = PlayerPedId()
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    local closestPlayers = aph.functions.getPlayersFromCoords(coords)
    local closestDistance = -1
    local closestPlayer = -1
    for i = 1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() and closestPlayers[i] ~= -1 then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(pos - coords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

function aph.functions.getPlayersFromCoords(coords, distance)
    local players = aph.functions.getPlayers()
    local ped = PlayerPedId()
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    local distance = distance or 5
    local closePlayers = {}
    for _, player in pairs(players) do
        local target = GetPlayerPed(player)
        local targetCoords = GetEntityCoords(target)
        local targetdistance = #(targetCoords - coords)
        if targetdistance <= distance then
            closePlayers[#closePlayers + 1] = player
        end
    end
    return closePlayers
end

function aph.functions.getClosestVehicle(coords)
    local ped = PlayerPedId()
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestVehicle = -1
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)

        if closestDistance == -1 or closestDistance > distance then
            closestVehicle = vehicles[i]
            closestDistance = distance
        end
    end
    return closestVehicle, closestDistance
end

function aph.functions.getClosestObject(coords)
    local ped = PlayerPedId()
    local objects = GetGamePool('CObject')
    local closestDistance = -1
    local closestObject = -1
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    for i = 1, #objects, 1 do
        local objectCoords = GetEntityCoords(objects[i])
        local distance = #(objectCoords - coords)
        if closestDistance == -1 or closestDistance > distance then
            closestObject = objects[i]
            closestDistance = distance
        end
    end
    return closestObject, closestDistance
end