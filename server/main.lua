local QBCore = exports['qb-core']:GetCoreObject()
local hasDonePreloading = {}

RegisterNetEvent('QBCore:Server:PlayerLoaded', function(Player)
    Wait(1000)
    hasDonePreloading[Player.PlayerData.source] = true
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(src)
    hasDonePreloading[src] = false
end)

RegisterNetEvent('qb-singlecharacter:server:disconnect', function()
    local src = source
    DropPlayer(src, "Player Dropped")
end)

RegisterNetEvent('qb-singlecharacter:server:LogIn', function(citizenid)
    local src = source
    if QBCore.Player.Login(src, citizenid) then
        repeat
            Wait(10)
        until hasDonePreloading[src]
        QBCore.Commands.Refresh(src)
    end
    if citizenid then
        local result = MySQL.Sync.fetchAll("SELECT * FROM playerskins WHERE citizenid = @citizenid AND active = @active", {
            ['@citizenid'] = citizenid,
            ['@active'] = 1
        })
    end
    TriggerClientEvent('qb-singlecharacter:client:loadSkin', src, result[1].model, result[1].skin)
end)

RegisterNetEvent("qb-singlecharacter:server:playerConnected", function()
    local src = source
    local license = QBCore.Functions.GetIdentifier(src, 'license')
    local Clothing = nil
    MySQL.query('SELECT * FROM players WHERE license = ?', {license}, function(PlayerData)
        local CitizenId = PlayerData[1] and PlayerData[1].citizenid or nil
        if QBCore.Player.Login(src, CitizenId) then
            repeat
                Wait(10)
            until hasDonePreloading[src]
            QBCore.Commands.Refresh(src)
        end
        if CitizenId then
            Clothing = MySQL.query.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', {CitizenId, 1})[1]
        end
        TriggerClientEvent('qb-singlecharacter:client:loadSkin', src, Clothing)
    end)
end)

RegisterNetEvent('qb-singlecharacter:server:createCharacter', function(data)
    local Player = QBCore.Functions.GetPlayer(source)
    local PlayerData = Player.PlayerData
    local CharInfo = PlayerData.charinfo
        CharInfo.firstname = data["First Name"]
        CharInfo.lastname = data["Last Name"]
        CharInfo.gender = data["Gender"]
    Player.Functions.SetPlayerData('charinfo', CharInfo)
    Player.Functions.Save()
end)