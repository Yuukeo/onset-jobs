local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end
local minerNpc = {
            {
                location = { 211664, 159643, 1320, 90 },
                spawn = { 212956, 160465, 1305, -90 }
            },
          
}
local minerPoint = {
    { 116691, 164243, 3028 },
}

local minerNpcCached = {}
local playerMiner = {}

AddEvent("OnPackageStart", function()
    for k,v in pairs(minerNpc) do
        minerNpc[k].npc = CreateNPC(minerNpc[k].location[1], minerNpc[k].location[2], minerNpc[k].location[3],minerNpc[k].location[4])
        CreateText3D(_("miner_job").."\n".._("press_e"), 18, minerNpc[k].location[1], minerNpc[k].location[2], minerNpc[k].location[3] + 120, 0, 0, 0)
        table.insert(minerNpcCached, minerNpc[k].npc)
    end
end)

AddEvent("OnPlayerQuit", function( player )
    if playerMiner[player] ~= nil then
        playerMiner[player] = nil
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "SetupMiner", minerNpcCached)
end)

AddRemoteEvent("StartMinerJob", function(player)
    local nearestMiner = GetNearestMiner(player)
    if PlayerData[player].job == "" then
        if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
           
        else
            local isSpawnable = true
            for k,v in pairs(GetAllVehicles()) do
                local x, y, z = GetVehicleLocation(v)
                local dist2 = GetDistance3D(minerNpc[nearestMiner].spawn[1], minerNpc[nearestMiner].spawn[2], minerNpc[nearestMiner].spawn[3], x, y, z)
                if dist2 < 500.0 then
                    isSpawnable = false
                    break
                end
            end
            if isSpawnable  then
                local vehicle = CreateVehicle(8, minerNpc[nearestMiner].spawn[1], minerNpc[nearestMiner].spawn[2], minerNpc[nearestMiner].spawn[3], minerNpc[nearestMiner].spawn[4])
                PlayerData[player].job_vehicle = vehicle
                CreateVehicleData(player, vehicle, 8)
                SetVehiclePropertyValue(vehicle, "locked", true, true)
                PlayerData[player].job = "miner"
                return
            end
        end
    end
end)

AddRemoteEvent("StopMinerJob", function(player,spawncar)
  if PlayerData[player].job == "miner" then
		if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
        end
        PlayerData[player].job = ""
        playerMiner[player] = nil
    end
end)

AddEvent("OnPlayerDeath", function(player)
    for k,v in pairs(GetAllPlayers()) do
        if player ~= v and PlayerData[v].job == "miner" then
            print(player)
            print(v)
            print(k)
            SetPlayerRespawnTime(player, 120000)
        end
    end
end)

AddRemoteEvent("MinerDoRevive", function(player,deadplayer)
    if player ~= deadplayer and PlayerData[player].job == "miner" then
        SetPlayerAnimation(player, "REVIVE")

        Delay(5000, function()
            SetPlayerAnimation(player, "STOP")
            SetPlayerRespawnTime(deadplayer, 100)
        end)
    end
end)

function GetNearestMiner(player)
	local x, y, z = GetPlayerLocation(player)
	
	for k,v in pairs(GetAllNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(minerNpc) do
				if v == i.npc then
					return k
				end
			end
		end
	end

	return 0
end