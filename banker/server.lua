local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end
local bankerNpc = {
            {
                location = { 211664, 159643, 1320, 90 },
                spawn = { 212956, 160465, 1305, -90 }
            },
          
}
local bankerPoint = {
    { 116691, 164243, 3028 },
}

local bankerNpcCached = {}
local playerBanker = {}

AddEvent("OnPackageStart", function()
    for k,v in pairs(bankerNpc) do
        bankerNpc[k].npc = CreateNPC(bankerNpc[k].location[1], bankerNpc[k].location[2], bankerNpc[k].location[3],bankerNpc[k].location[4])
        CreateText3D(_("banker_job").."\n".._("press_e"), 18, bankerNpc[k].location[1], bankerNpc[k].location[2], bankerNpc[k].location[3] + 120, 0, 0, 0)
        table.insert(bankerNpcCached, bankerNpc[k].npc)
    end
end)

AddEvent("OnPlayerQuit", function( player )
    if playerBanker[player] ~= nil then
        playerBanker[player] = nil
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "SetupBanker", bankerNpcCached)
end)

AddRemoteEvent("StartBankerJob", function(player)
    local nearestBanker = GetNearestBanker(player)
    if PlayerData[player].job == "" then
        if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
           
        else
            local isSpawnable = true
            for k,v in pairs(GetAllVehicles()) do
                local x, y, z = GetVehicleLocation(v)
                local dist2 = GetDistance3D(bankerNpc[nearestBanker].spawn[1], bankerNpc[nearestBanker].spawn[2], bankerNpc[nearestBanker].spawn[3], x, y, z)
                if dist2 < 500.0 then
                    isSpawnable = false
                    break
                end
            end
            if isSpawnable  then
                local vehicle = CreateVehicle(8, bankerNpc[nearestBanker].spawn[1], bankerNpc[nearestBanker].spawn[2], bankerNpc[nearestBanker].spawn[3], bankerNpc[nearestBanker].spawn[4])
                PlayerData[player].job_vehicle = vehicle
                CreateVehicleData(player, vehicle, 8)
                SetVehiclePropertyValue(vehicle, "locked", true, true)
                PlayerData[player].job = "banker"
                return
            end
        end
    end
end)

AddRemoteEvent("StopBankerJob", function(player,spawncar)
  if PlayerData[player].job == "banker" then
		if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
        end
        PlayerData[player].job = ""
        playerBanker[player] = nil
    end
end)

AddEvent("OnPlayerDeath", function(player)
    for k,v in pairs(GetAllPlayers()) do
        if player ~= v and PlayerData[v].job == "banker" then
            print(player)
            print(v)
            print(k)
            SetPlayerRespawnTime(player, 120000)
        end
    end
end)

AddRemoteEvent("BankerDoRevive", function(player,deadplayer)
    if player ~= deadplayer and PlayerData[player].job == "banker" then
        SetPlayerAnimation(player, "REVIVE")

        Delay(5000, function()
            SetPlayerAnimation(player, "STOP")
            SetPlayerRespawnTime(deadplayer, 100)
        end)
    end
end)

function GetNearestBanker(player)
	local x, y, z = GetPlayerLocation(player)
	
	for k,v in pairs(GetAllNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(bankerNpc) do
				if v == i.npc then
					return k
				end
			end
		end
	end

	return 0
end