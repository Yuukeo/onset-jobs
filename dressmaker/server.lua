local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end
local dressmakerNpc = {
            {
                location = { 211664, 159643, 1320, 90 },
                spawn = { 212956, 160465, 1305, -90 }
            },
          
}
local dressmakerPoint = {
    { 116691, 164243, 3028 },
}

local dressmakerNpcCached = {}
local playerDressmaker = {}

AddEvent("OnPackageStart", function()
    for k,v in pairs(dressmakerNpc) do
        dressmakerNpc[k].npc = CreateNPC(dressmakerNpc[k].location[1], dressmakerNpc[k].location[2], dressmakerNpc[k].location[3],dressmakerNpc[k].location[4])
        CreateText3D(_("dressmaker_job").."\n".._("press_e"), 18, dressmakerNpc[k].location[1], dressmakerNpc[k].location[2], dressmakerNpc[k].location[3] + 120, 0, 0, 0)
        table.insert(dressmakerNpcCached, dressmakerNpc[k].npc)
    end
end)

AddEvent("OnPlayerQuit", function( player )
    if playerDressmaker[player] ~= nil then
        playerDressmaker[player] = nil
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "SetupDressmaker", dressmakerNpcCached)
end)

AddRemoteEvent("StartDressmakerJob", function(player)
    local nearestDressmaker = GetNearestDressmaker(player)
    if PlayerData[player].job == "" then
        if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
           
        else
            local isSpawnable = true
            for k,v in pairs(GetAllVehicles()) do
                local x, y, z = GetVehicleLocation(v)
                local dist2 = GetDistance3D(dressmakerNpc[nearestDressmaker].spawn[1], dressmakerNpc[nearestDressmaker].spawn[2], dressmakerNpc[nearestDressmaker].spawn[3], x, y, z)
                if dist2 < 500.0 then
                    isSpawnable = false
                    break
                end
            end
            if isSpawnable  then
                local vehicle = CreateVehicle(8, dressmakerNpc[nearestDressmaker].spawn[1], dressmakerNpc[nearestDressmaker].spawn[2], dressmakerNpc[nearestDressmaker].spawn[3], dressmakerNpc[nearestDressmaker].spawn[4])
                PlayerData[player].job_vehicle = vehicle
                CreateVehicleData(player, vehicle, 8)
                SetVehiclePropertyValue(vehicle, "locked", true, true)
                PlayerData[player].job = "dressmaker"
                return
            end
        end
    end
end)

AddRemoteEvent("StopDressmakerJob", function(player,spawncar)
  if PlayerData[player].job == "dressmaker" then
		if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
        end
        PlayerData[player].job = ""
        playerDressmaker[player] = nil
    end
end)

AddEvent("OnPlayerDeath", function(player)
    for k,v in pairs(GetAllPlayers()) do
        if player ~= v and PlayerData[v].job == "dressmaker" then
            print(player)
            print(v)
            print(k)
            SetPlayerRespawnTime(player, 120000)
        end
    end
end)

AddRemoteEvent("DressmakerDoRevive", function(player,deadplayer)
    if player ~= deadplayer and PlayerData[player].job == "dressmaker" then
        SetPlayerAnimation(player, "REVIVE")

        Delay(5000, function()
            SetPlayerAnimation(player, "STOP")
            SetPlayerRespawnTime(deadplayer, 100)
        end)
    end
end)

function GetNearestDressmaker(player)
	local x, y, z = GetPlayerLocation(player)
	
	for k,v in pairs(GetAllNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(dressmakerNpc) do
				if v == i.npc then
					return k
				end
			end
		end
	end

	return 0
end