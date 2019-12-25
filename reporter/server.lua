local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end
local reporterNpc = {
            {
                location = { 211664, 159643, 1320, 90 },
                spawn = { 212956, 160465, 1305, -90 }
            },
          
}
local reporterPoint = {
    { 116691, 164243, 3028 },
}

local reporterNpcCached = {}
local playerReporter = {}

AddEvent("OnPackageStart", function()
    for k,v in pairs(reporterNpc) do
        reporterNpc[k].npc = CreateNPC(reporterNpc[k].location[1], reporterNpc[k].location[2], reporterNpc[k].location[3],reporterNpc[k].location[4])
        CreateText3D(_("reporter_job").."\n".._("press_e"), 18, reporterNpc[k].location[1], reporterNpc[k].location[2], reporterNpc[k].location[3] + 120, 0, 0, 0)
        table.insert(reporterNpcCached, reporterNpc[k].npc)
    end
end)

AddEvent("OnPlayerQuit", function( player )
    if playerReporter[player] ~= nil then
        playerReporter[player] = nil
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "SetupReporter", reporterNpcCached)
end)

AddRemoteEvent("StartReporterJob", function(player)
    local nearestReporter = GetNearestReporter(player)
    if PlayerData[player].job == "" then
        if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
           
        else
            local isSpawnable = true
            for k,v in pairs(GetAllVehicles()) do
                local x, y, z = GetVehicleLocation(v)
                local dist2 = GetDistance3D(reporterNpc[nearestReporter].spawn[1], reporterNpc[nearestReporter].spawn[2], reporterNpc[nearestReporter].spawn[3], x, y, z)
                if dist2 < 500.0 then
                    isSpawnable = false
                    break
                end
            end
            if isSpawnable  then
                local vehicle = CreateVehicle(8, reporterNpc[nearestReporter].spawn[1], reporterNpc[nearestReporter].spawn[2], reporterNpc[nearestReporter].spawn[3], reporterNpc[nearestReporter].spawn[4])
                PlayerData[player].job_vehicle = vehicle
                CreateVehicleData(player, vehicle, 8)
                SetVehiclePropertyValue(vehicle, "locked", true, true)
                PlayerData[player].job = "reporter"
                return
            end
        end
    end
end)

AddRemoteEvent("StopReporterJob", function(player,spawncar)
  if PlayerData[player].job == "reporter" then
		if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
        end
        PlayerData[player].job = ""
        playerReporter[player] = nil
    end
end)

AddEvent("OnPlayerDeath", function(player)
    for k,v in pairs(GetAllPlayers()) do
        if player ~= v and PlayerData[v].job == "reporter" then
            print(player)
            print(v)
            print(k)
            SetPlayerRespawnTime(player, 120000)
        end
    end
end)

AddRemoteEvent("ReporterDoRevive", function(player,deadplayer)
    if player ~= deadplayer and PlayerData[player].job == "reporter" then
        SetPlayerAnimation(player, "REVIVE")

        Delay(5000, function()
            SetPlayerAnimation(player, "STOP")
            SetPlayerRespawnTime(deadplayer, 100)
        end)
    end
end)

function GetNearestReporter(player)
	local x, y, z = GetPlayerLocation(player)
	
	for k,v in pairs(GetAllNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(reporterNpc) do
				if v == i.npc then
					return k
				end
			end
		end
	end

	return 0
end