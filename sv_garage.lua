QBCore = nil


NumberCharset = {}
Charset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end
for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)
RegisterServerEvent('qb-policegarage:server:takemoney', function(data)
    xPlayer = QBCore.Functions.GetPlayer(source)
    if xPlayer.PlayerData.money['cash'] >= data.price then
        xPlayer.Functions.RemoveMoney('cash', data.price)
        TriggerClientEvent('qb-policegarage:client:spawn', source, data.model, vector3(443.1918, -1022.256, 28.567802), 93.38)
    elseif xPlayer.PlayerData.money['bank'] >= data.price then
        xPlayer.Functions.RemoveMoney('bank', data.price)
        TriggerClientEvent('qb-policegarage:client:spawn', source, data.model, vector3(443.1918, -1022.256, 28.567802), 93.38)
    else
        TriggerClientEvent('chatMessage', source, "Insufficient Funds", "error", "You don't have enough money..")
    end
end)

RegisterNetEvent('qb-policegarage:server:AddGarage')
AddEventHandler('qb-policegarage:server:AddGarage', function(vehmodel, hash)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player ~= nil then
        local newplate = GeneratePlate()
        newplate = newplate:gsub("%s+", "")
        QBCore.Functions.ExecuteSql(false, "INSERT INTO `player_vehicles` (`steam`, `citizenid`, `vehicle`, `hash`, `mods`, `plate`, `state`) VALUES ('"..Player.PlayerData.steam.."', '"..Player.PlayerData.citizenid.."', '"..vehmodel.."', '"..hash.."', '{}', '"..newplate.."', 0)")
        TriggerClientEvent('qb-policegarage:client:AddGarage', src, newplate)
    end
end)

function GeneratePlate()
    local plate = tostring(GetRandomNumber(1)) .. GetRandomLetter(2) .. tostring(GetRandomNumber(3)) .. GetRandomLetter(2)
    QBCore.Functions.ExecuteSql(true, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        while (result[1] ~= nil) do
            plate = tostring(GetRandomNumber(1)) .. GetRandomLetter(2) .. tostring(GetRandomNumber(3)) .. GetRandomLetter(2)
        end
        return plate
    end)
    return plate:upper()
end

function GetRandomNumber(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
		return ''
	end
end

function GetRandomLetter(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end