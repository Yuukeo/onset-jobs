local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end
local cleanerNpc = {
            {
                location = { 211664, 159643, 1320, 90 },
                spawn = { 212956, 160465, 1305, -90 }
            },
          
}
local cleanerPoint = {
    { 116691, 164243, 3028 },
}

local cleanerNpcCached = {}
local playerCleaner = {}

AddEvent("OnPackageStart", function()
    for k,v in pairs(cleanerNpc) do
        cleanerNpc[k].npc = CreateNPC(cleanerNpc[k].location[1], cleanerNpc[k].location[2], cleanerNpc[k].location[3],cleanerNpc[k].location[4])
        CreateText3D(_("cleaner_job").."\n".._("press_e"), 18, cleanerNpc[k].location[1], cleanerNpc[k].location[2], cleanerNpc[k].location[3] + 120, 0, 0, 0)
        table.insert(cleanerNpcCached, cleanerNpc[k].npc)
    end
end)

AddEvent("OnPlayerQuit", function( player )
    if playerCleaner[player] ~= nil then
        playerCleaner[player] = nil
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "SetupCleaner", cleanerNpcCached)
end)

AddRemoteEvent("StartCleanerJob", function(player)
    local nearestCleaner = GetNearestCleaner(player)
    if PlayerData[player].job == "" then
        if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
           
        else
            local isSpawnable = true
            for k,v in pairs(GetAllVehicles()) do
                local x, y, z = GetVehicleLocation(v)
                local dist2 = GetDistance3D(cleanerNpc[nearestCleaner].spawn[1], cleanerNpc[nearestCleaner].spawn[2], cleanerNpc[nearestCleaner].spawn[3], x, y, z)
                if dist2 < 500.0 then
                    isSpawnable = false
                    break
                end
            end
            if isSpawnable  then
                local vehicle = CreateVehicle(8, cleanerNpc[nearestCleaner].spawn[1], cleanerNpc[nearestCleaner].spawn[2], cleanerNpc[nearestCleaner].spawn[3], cleanerNpc[nearestCleaner].spawn[4])
                PlayerData[player].job_vehicle = vehicle
                CreateVehicleData(player, vehicle, 8)
                SetVehiclePropertyValue(vehicle, "locked", true, true)
                PlayerData[player].job = "cleaner"
                return
            end
        end
    end
end)

AddRemoteEvent("StopCleanerJob", function(player,spawncar)
  if PlayerData[player].job == "cleaner" then
		if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
        end
        PlayerData[player].job = ""
        playerCleaner[player] = nil
    end
end)

AddEvent("OnPlayerDeath", function(player)
    for k,v in pairs(GetAllPlayers()) do
        if player ~= v and PlayerData[v].job == "cleaner" then
            print(player)
            print(v)
            print(k)
            SetPlayerRespawnTime(player, 120000)
        end
    end
end)

AddRemoteEvent("CleanerDoRevive", function(player,deadplayer)
    if player ~= deadplayer and PlayerData[player].job == "cleaner" then
        SetPlayerAnimation(player, "REVIVE")

        Delay(5000, function()
            SetPlayerAnimation(player, "STOP")
            SetPlayerRespawnTime(deadplayer, 100)
        end)
    end
end)

function GetNearestCleaner(player)
	local x, y, z = GetPlayerLocation(player)
	
	for k,v in pairs(GetAllNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(cleanerNpc) do
				if v == i.npc then
					return k
				end
			end
		end
	end

	return 0
end