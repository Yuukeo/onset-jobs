local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end
local hrmanagerNpc = {
            {
                location = { 211664, 159643, 1320, 90 },
                spawn = { 212956, 160465, 1305, -90 }
            },
          
}
local hrmanagerPoint = {
    { 116691, 164243, 3028 },
}

local hrmanagerNpcCached = {}
local playerHrmanager = {}

AddEvent("OnPackageStart", function()
    for k,v in pairs(hrmanagerNpc) do
        hrmanagerNpc[k].npc = CreateNPC(hrmanagerNpc[k].location[1], hrmanagerNpc[k].location[2], hrmanagerNpc[k].location[3],hrmanagerNpc[k].location[4])
        CreateText3D(_("hrmanager_job").."\n".._("press_e"), 18, hrmanagerNpc[k].location[1], hrmanagerNpc[k].location[2], hrmanagerNpc[k].location[3] + 120, 0, 0, 0)
        table.insert(hrmanagerNpcCached, hrmanagerNpc[k].npc)
    end
end)

AddEvent("OnPlayerQuit", function( player )
    if playerHrmanager[player] ~= nil then
        playerHrmanager[player] = nil
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "SetupHrmanager", hrmanagerNpcCached)
end)

AddRemoteEvent("StartHrmanagerJob", function(player)
    local nearestHrmanager = GetNearestHrmanager(player)
    if PlayerData[player].job == "" then
        if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
           
        else
            local isSpawnable = true
            for k,v in pairs(GetAllVehicles()) do
                local x, y, z = GetVehicleLocation(v)
                local dist2 = GetDistance3D(hrmanagerNpc[nearestHrmanager].spawn[1], hrmanagerNpc[nearestHrmanager].spawn[2], hrmanagerNpc[nearestHrmanager].spawn[3], x, y, z)
                if dist2 < 500.0 then
                    isSpawnable = false
                    break
                end
            end
            if isSpawnable  then
                local vehicle = CreateVehicle(8, hrmanagerNpc[nearestHrmanager].spawn[1], hrmanagerNpc[nearestHrmanager].spawn[2], hrmanagerNpc[nearestHrmanager].spawn[3], hrmanagerNpc[nearestHrmanager].spawn[4])
                PlayerData[player].job_vehicle = vehicle
                CreateVehicleData(player, vehicle, 8)
                SetVehiclePropertyValue(vehicle, "locked", true, true)
                PlayerData[player].job = "hrmanager"
                return
            end
        end
    end
end)

AddRemoteEvent("StopHrmanagerJob", function(player,spawncar)
  if PlayerData[player].job == "hrmanager" then
		if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
        end
        PlayerData[player].job = ""
        playerHrmanager[player] = nil
    end
end)

AddEvent("OnPlayerDeath", function(player)
    for k,v in pairs(GetAllPlayers()) do
        if player ~= v and PlayerData[v].job == "hrmanager" then
            print(player)
            print(v)
            print(k)
            SetPlayerRespawnTime(player, 120000)
        end
    end
end)

AddRemoteEvent("HrmanagerDoRevive", function(player,deadplayer)
    if player ~= deadplayer and PlayerData[player].job == "hrmanager" then
        SetPlayerAnimation(player, "REVIVE")

        Delay(5000, function()
            SetPlayerAnimation(player, "STOP")
            SetPlayerRespawnTime(deadplayer, 100)
        end)
    end
end)

function GetNearestHrmanager(player)
	local x, y, z = GetPlayerLocation(player)
	
	for k,v in pairs(GetAllNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(hrmanagerNpc) do
				if v == i.npc then
					return k
				end
			end
		end
	end

	return 0
end