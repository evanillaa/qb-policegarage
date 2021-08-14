QBCore = nil

Citizen.CreateThread(function()
    while QBCore == nil do
        TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
        Citizen.Wait(200)
    end
end)

local cam
local lastpos
--local veh
PlayerJob = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
    end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

AddEventHandler('onClientResourceStart',function()
    Citizen.CreateThread(function()
        while true do
            if QBCore ~= nil and QBCore.Functions.GetPlayerData ~= nil then
                QBCore.Functions.GetPlayerData(function(PlayerData)
                    if PlayerData.job then
                        PlayerJob = PlayerData.job
                    end
                end)
                break
            end
            Citizen.Wait(500)
        end
        Citizen.Wait(500)
    end)
end)

CreateThread(function()
    while true do
        Citizen.Wait(3)
        if PlayerJob.name == "police" then
            local inRange = false
            local pos = GetEntityCoords(PlayerPedId())
            local coords = vector3(459.0, -1017.19, 28.16)

            if #(pos - coords) < 1.5 then
                inRange = true
                DrawText3D(459.0, -1017.19, 28.16 , '~g~[E]~s~ - Police Garage')
                if IsControlJustPressed(0, 38) then
                    TriggerEvent("qb-policegarage:openUI")
                end
            end

            if not inRange then
                Citizen.Wait(2000)
            end
        else
            Citizen.Wait(10000)
        end
    end
end)

function openUI(data,index,cb)
    local plyPed = PlayerPedId()
    lastpos = GetEntityCoords(plyPed)
    SetEntityCoords(plyPed, 453.16662, -1024.837, 28.514112)
    SetEntityVisible(plyPed, false)
    SetNuiFocus(true, true)
end

RegisterNUICallback("showVeh", function(data,cb)
    -- CLEAR SPACE
    local vehinarea = QBCore.Functions.GetVehiclesInArea(vector3(452.06686, -1023.903, 28.76457), 1)
    if #vehinarea ~= 0 then
        QBCore.Functions.DeleteVehicle(vehinarea[1])
    end

    -- SPAWN VEHICLE
    QBCore.Functions.SpawnVehicle(data.model, function(veh)
        SetEntityCoords(veh, 452.06686, -1023.903, 28.76457)
        SetEntityHeading(veh, 94.47)
        SetEntityAlpha(veh, 85)
    end)
end)

RegisterNetEvent("qb-policegarage:client:spawn",function(model,spawnLoc,spawnHeading)
    -- CLEAR SPACE
    local vehinarea = QBCore.Functions.GetVehiclesInArea(vector3(452.06686, -1023.903, 28.76457), 1)
    if #vehinarea ~= 0 then
        QBCore.Functions.DeleteVehicle(vehinarea[1])
    end

    -- SPAWN VEHICLE
    QBCore.Functions.SpawnVehicle(model, function(veh)
        SetEntityCoords(veh, spawnLoc.x, spawnLoc.y, spawnLoc.z)
        SetEntityHeading(veh, spawnHeading)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
        SetVehicleEngineOn(veh, true, true)
        -- ADD GARGE
        local props = QBCore.Functions.GetVehicleProperties(veh)
        local hash = props.model
        TriggerServerEvent('qb-policegarage:server:AddGarage', model, hash)
    end)
end)

RegisterNetEvent('qb-policegarage:client:AddGarage')
AddEventHandler('qb-policegarage:client:AddGarage',function(plate)
    local veh = GetVehiclePedIsIn(PlayerPedId())
    SetVehicleNumberPlateText(veh, plate:gsub("%s+", ""))
end)

RegisterNUICallback("buy", function(data,cb)
    SendNUIMessage({
        action = 'close'
    })
    TriggerServerEvent('qb-policegarage:server:takemoney', data)
    SetEntityCoords(PlayerPedId(), lastpos.x, lastpos.y, lastpos.z)
    SetEntityVisible(PlayerPedId(), true)
    local vehinarea = QBCore.Functions.GetVehiclesInArea(vector3(452.06686, -1023.903, 28.76457), 1)
    if #vehinarea ~= 0 then
        QBCore.Functions.DeleteVehicle(vehinarea[1])
    end
    DoScreenFadeOut(500)
    Wait(500)
    RenderScriptCams(false, false, 1, true, true)
    DestroyAllCams(true)
    SetNuiFocus(false, false)
    DoScreenFadeIn(500)
    Wait(500)
end)

RegisterNUICallback("close", function()
    SetEntityCoords(PlayerPedId(), lastpos.x, lastpos.y, lastpos.z)
    SetEntityVisible(PlayerPedId(), true)
    local vehinarea = QBCore.Functions.GetVehiclesInArea(vector3(452.06686, -1023.903, 28.76457), 1)
    if #vehinarea ~= 0 then
        QBCore.Functions.DeleteVehicle(vehinarea[1])
    end
    DoScreenFadeOut(500)
    Wait(500)
    RenderScriptCams(false, false, 1, true, true)
    DestroyAllCams(true)
    SetNuiFocus(false, false)
    DoScreenFadeIn(500)
    Wait(500)
end)

RegisterNetEvent("qb-policegarage:openUI",function()
    changeCam()
    for i = 1,#Config.Garage do
        SendNUIMessage({
            action = true,
            index = i,
            vehicleInfo = Config.Garage[i].vehicles
        })
        openUI(Config.Garage[i].vehicles, i)
    end
end)

function changeCam()
    DoScreenFadeOut(500)
    Wait(1000)
    if not DoesCamExist(cam) then
        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    end
    SetCamActive(cam, true)
    SetCamRot(cam,vector3(-10.0,0.0, -155.999), true)
    SetCamFov(cam,70.0)
    SetCamCoord(cam, vector3(449.84777, -1018.808, 29.673933))
    PointCamAtCoord(cam,vector3(449.84777, -1018.808, 29.673933))
    RenderScriptCams(true, false, 2500.0, true, true)
    DoScreenFadeIn(1000)
    Wait(1000)
end

DrawText3D = function(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end