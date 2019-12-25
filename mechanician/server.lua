local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end
local mechanicianNpc = {
            {
                location = { 211664, 159643, 1320, 90 },
                spawn = { 212956, 160465, 1305, -90 }
            },
          
}
local mechanicianPoint = {
    { 116691, 164243, 3028 },
}

local mechanicianNpcCached = {}
local playerMechanician = {}

AddEvent("OnPackageStart", function()
    for k,v in pairs(mechanicianNpc) do
        mechanicianNpc[k].npc = CreateNPC(mechanicianNpc[k].location[1], mechanicianNpc[k].location[2], mechanicianNpc[k].location[3],mechanicianNpc[k].location[4])
        CreateText3D(_("mechanician_job").."\n".._("press_e"), 18, mechanicianNpc[k].location[1], mechanicianNpc[k].location[2], mechanicianNpc[k].location[3] + 120, 0, 0, 0)
        table.insert(mechanicianNpcCached, mechanicianNpc[k].npc)
    end
end)

AddEvent("OnPlayerQuit", function( player )
    if playerMechanician[player] ~= nil then
        playerMechanician[player] = nil
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "SetupMechanician", mechanicianNpcCached)
end)

AddRemoteEvent("StartMechanicianJob", function(player)
    local nearestMechanician = GetNearestMechanician(player)
    if PlayerData[player].job == "" then
        if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
           
        else
            local isSpawnable = true
            for k,v in pairs(GetAllVehicles()) do
                local x, y, z = GetVehicleLocation(v)
                local dist2 = GetDistance3D(mechanicianNpc[nearestMechanician].spawn[1], mechanicianNpc[nearestMechanician].spawn[2], mechanicianNpc[nearestMechanician].spawn[3], x, y, z)
                if dist2 < 500.0 then
                    isSpawnable = false
                    break
                end
            end
            if isSpawnable  then
                local vehicle = CreateVehicle(8, mechanicianNpc[nearestMechanician].spawn[1], mechanicianNpc[nearestMechanician].spawn[2], mechanicianNpc[nearestMechanician].spawn[3], mechanicianNpc[nearestMechanician].spawn[4])
                PlayerData[player].job_vehicle = vehicle
                CreateVehicleData(player, vehicle, 8)
                SetVehiclePropertyValue(vehicle, "locked", true, true)
                PlayerData[player].job = "mechanician"
                return
            end
        end
    end
end)

AddRemoteEvent("StopMechanicianJob", function(player,spawncar)
  if PlayerData[player].job == "mechanician" then
		if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
        end
        PlayerData[player].job = ""
        playerMechanician[player] = nil
    end
end)

AddEvent("OnPlayerDeath", function(player)
    for k,v in pairs(GetAllPlayers()) do
        if player ~= v and PlayerData[v].job == "mechanician" then
            print(player)
            print(v)
            print(k)
            SetPlayerRespawnTime(player, 120000)
        end
    end
end)

AddRemoteEvent("MechanicianDoRevive", function(player,deadplayer)
    if player ~= deadplayer and PlayerData[player].job == "mechanician" then
        SetPlayerAnimation(player, "REVIVE")

        Delay(5000, function()
            SetPlayerAnimation(player, "STOP")
            SetPlayerRespawnTime(deadplayer, 100)
        end)
    end
end)

function GetNearestMechanician(player)
	local x, y, z = GetPlayerLocation(player)
	
	for k,v in pairs(GetAllNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(mechanicianNpc) do
				if v == i.npc then
					return k
				end
			end
		end
	end

	return 0
end