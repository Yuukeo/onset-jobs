local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end
local builderNpc = {
            {
                location = { 211664, 159643, 1320, 90 },
                spawn = { 212956, 160465, 1305, -90 }
            },
          
}
local builderPoint = {
    { 116691, 164243, 3028 },
}

local builderNpcCached = {}
local playerBuilder = {}

AddEvent("OnPackageStart", function()
    for k,v in pairs(builderNpc) do
        builderNpc[k].npc = CreateNPC(builderNpc[k].location[1], builderNpc[k].location[2], builderNpc[k].location[3],builderNpc[k].location[4])
        CreateText3D(_("builder_job").."\n".._("press_e"), 18, builderNpc[k].location[1], builderNpc[k].location[2], builderNpc[k].location[3] + 120, 0, 0, 0)
        table.insert(builderNpcCached, builderNpc[k].npc)
    end
end)

AddEvent("OnPlayerQuit", function( player )
    if playerBuilder[player] ~= nil then
        playerBuilder[player] = nil
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "SetupBuilder", builderNpcCached)
end)

AddRemoteEvent("StartBuilderJob", function(player)
    local nearestBuilder = GetNearestBuilder(player)
    if PlayerData[player].job == "" then
        if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
           
        else
            local isSpawnable = true
            for k,v in pairs(GetAllVehicles()) do
                local x, y, z = GetVehicleLocation(v)
                local dist2 = GetDistance3D(builderNpc[nearestBuilder].spawn[1], builderNpc[nearestBuilder].spawn[2], builderNpc[nearestBuilder].spawn[3], x, y, z)
                if dist2 < 500.0 then
                    isSpawnable = false
                    break
                end
            end
            if isSpawnable  then
                local vehicle = CreateVehicle(8, builderNpc[nearestBuilder].spawn[1], builderNpc[nearestBuilder].spawn[2], builderNpc[nearestBuilder].spawn[3], builderNpc[nearestBuilder].spawn[4])
                PlayerData[player].job_vehicle = vehicle
                CreateVehicleData(player, vehicle, 8)
                SetVehiclePropertyValue(vehicle, "locked", true, true)
                PlayerData[player].job = "builder"
                return
            end
        end
    end
end)

AddRemoteEvent("StopBuilderJob", function(player,spawncar)
  if PlayerData[player].job == "builder" then
		if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
        end
        PlayerData[player].job = ""
        playerBuilder[player] = nil
    end
end)

AddEvent("OnPlayerDeath", function(player)
    for k,v in pairs(GetAllPlayers()) do
        if player ~= v and PlayerData[v].job == "builder" then
            print(player)
            print(v)
            print(k)
            SetPlayerRespawnTime(player, 120000)
        end
    end
end)

AddRemoteEvent("BuilderDoRevive", function(player,deadplayer)
    if player ~= deadplayer and PlayerData[player].job == "builder" then
        SetPlayerAnimation(player, "REVIVE")

        Delay(5000, function()
            SetPlayerAnimation(player, "STOP")
            SetPlayerRespawnTime(deadplayer, 100)
        end)
    end
end)

function GetNearestBuilder(player)
	local x, y, z = GetPlayerLocation(player)
	
	for k,v in pairs(GetAllNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(builderNpc) do
				if v == i.npc then
					return k
				end
			end
		end
	end

	return 0
end