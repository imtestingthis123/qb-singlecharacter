local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-singlecharacter:client:loadSkin', function(clothingData)
    local PlayerData = QBCore.Functions.GetPlayerData()
    DoScreenFadeOut(10)
    local playerModel = clothingData and tonumber(clothingData.model) or 1885233650
    local clothingData = clothingData and clothingData.skin

    RequestModel(playerModel)
    while not HasModelLoaded(playerModel) do Wait(20) end
    SetPlayerModel(PlayerId(), playerModel)


    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    local position = PlayerData.position
    local positionsCoords = vector3(position.x, position.y, position.z)
    SetEntityCoords(PlayerPedId(), positionsCoords)
    PlaceObjectOnGroundProperly(PlayerPedId())
    TriggerEvent('qb-weathersync:client:EnableSync')
    if GetIsLoadingScreenActive() then
        ShutdownLoadingScreen()
        ShutdownLoadingScreenNui()
    end
    local hasLanded = false
    local timeOut = 30
    while not hasLanded and timeOut > 0 do
        local distance = #(GetEntityCoords(PlayerPedId()) - positionsCoords)
        timeOut = timeOut - 1
        hasLanded = distance < 0.1 and true or false
        Wait(100)
    end
    if not clothingData or PlayerData.charinfo.firstname == "Firstname" or PlayerData.charinfo.lastname == "Lastname" then
        NewCharacter()
    else
        TriggerEvent('qb-clothing:client:loadPlayerClothing', json.decode(clothingData))
    end
        DoScreenFadeIn(2500)
end)


CreateThread(function()
	while true do
		Wait(0)
		if NetworkIsSessionStarted() then
			return TriggerServerEvent("qb-singlecharacter:server:playerConnected")
		end
	end
end)

--[[
    REMOVE WHEN SCRIPT COMPLETE
]]
RegisterCommand('playerdata', function()
    print(json.encode(QBCore.Functions.GetPlayerData(),{indent=true}))
    print(GetIsLoadingScreenActive())
end)

RegisterCommand('closeload', function()
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
end)

RegisterCommand('NewPlayer', function(source, args)
    NewCharacter()
end)