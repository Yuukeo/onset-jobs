local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end
local realestateagentNpc = {
            {
                location = { 211664, 159643, 1320, 90 },
                spawn = { 212956, 160465, 1305, -90 }
            },
          
}
local realestateagentPoint = {
    { 116691, 164243, 3028 },
}

local realestateagentNpcCached = {}
local playerRealestateagent = {}

AddEvent("OnPackageStart", function()
    for k,v in pairs(realestateagentNpc) do
        realestateagentNpc[k].npc = CreateNPC(realestateagentNpc[k].location[1], realestateagentNpc[k].location[2], realestateagentNpc[k].location[3],realestateagentNpc[k].location[4])
        CreateText3D(_("realestateagent_job").."\n".._("press_e"), 18, realestateagentNpc[k].location[1], realestateagentNpc[k].location[2], realestateagentNpc[k].location[3] + 120, 0, 0, 0)
        table.insert(realestateagentNpcCached, realestateagentNpc[k].npc)
    end
end)

AddEvent("OnPlayerQuit", function( player )
    if playerRealestateagent[player] ~= nil then
        playerRealestateagent[player] = nil
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "SetupRealestateagent", realestateagentNpcCached)
end)

AddRemoteEvent("StartRealestateagentJob", function(player)
    local nearestRealestateagent = GetNearestRealestateagent(player)
    if PlayerData[player].job == "" then
        if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
           
        else
            local isSpawnable = true
            for k,v in pairs(GetAllVehicles()) do
                local x, y, z = GetVehicleLocation(v)
                local dist2 = GetDistance3D(realestateagentNpc[nearestRealestateagent].spawn[1], realestateagentNpc[nearestRealestateagent].spawn[2], realestateagentNpc[nearestRealestateagent].spawn[3], x, y, z)
                if dist2 < 500.0 then
                    isSpawnable = false
                    break
                end
            end
            if isSpawnable  then
                local vehicle = CreateVehicle(8, realestateagentNpc[nearestRealestateagent].spawn[1], realestateagentNpc[nearestRealestateagent].spawn[2], realestateagentNpc[nearestRealestateagent].spawn[3], realestateagentNpc[nearestRealestateagent].spawn[4])
                PlayerData[player].job_vehicle = vehicle
                CreateVehicleData(player, vehicle, 8)
                SetVehiclePropertyValue(vehicle, "locked", true, true)
                PlayerData[player].job = "realestateagent"
                return
            end
        end
    end
end)

AddRemoteEvent("StopRealestateagentJob", function(player,spawncar)
  if PlayerData[player].job == "realestateagent" then
		if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
        end
        PlayerData[player].job = ""
        playerRealestateagent[player] = nil
    end
end)

AddEvent("OnPlayerDeath", function(player)
    for k,v in pairs(GetAllPlayers()) do
        if player ~= v and PlayerData[v].job == "realestateagent" then
            print(player)
            print(v)
            print(k)
            SetPlayerRespawnTime(player, 120000)
        end
    end
end)

AddRemoteEvent("RealestateagentDoRevive", function(player,deadplayer)
    if player ~= deadplayer and PlayerData[player].job == "realestateagent" then
        SetPlayerAnimation(player, "REVIVE")

        Delay(5000, function()
            SetPlayerAnimation(player, "STOP")
            SetPlayerRespawnTime(deadplayer, 100)
        end)
    end
end)

function GetNearestRealestateagent(player)
	local x, y, z = GetPlayerLocation(player)
	
	for k,v in pairs(GetAllNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(realestateagentNpc) do
				if v == i.npc then
					return k
				end
			end
		end
	end

	return 0
end