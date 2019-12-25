local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end
local lawyerNpc = {
            {
                location = { 211664, 159643, 1320, 90 },
                spawn = { 212956, 160465, 1305, -90 }
            },
          
}
local lawyerPoint = {
    { 116691, 164243, 3028 },
}

local lawyerNpcCached = {}
local playerLawyer = {}

AddEvent("OnPackageStart", function()
    for k,v in pairs(lawyerNpc) do
        lawyerNpc[k].npc = CreateNPC(lawyerNpc[k].location[1], lawyerNpc[k].location[2], lawyerNpc[k].location[3],lawyerNpc[k].location[4])
        CreateText3D(_("lawyer_job").."\n".._("press_e"), 18, lawyerNpc[k].location[1], lawyerNpc[k].location[2], lawyerNpc[k].location[3] + 120, 0, 0, 0)
        table.insert(lawyerNpcCached, lawyerNpc[k].npc)
    end
end)

AddEvent("OnPlayerQuit", function( player )
    if playerLawyer[player] ~= nil then
        playerLawyer[player] = nil
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "SetupLawyer", lawyerNpcCached)
end)

AddRemoteEvent("StartLawyerJob", function(player)
    local nearestLawyer = GetNearestLawyer(player)
    if PlayerData[player].job == "" then
        if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
           
        else
            local isSpawnable = true
            for k,v in pairs(GetAllVehicles()) do
                local x, y, z = GetVehicleLocation(v)
                local dist2 = GetDistance3D(lawyerNpc[nearestLawyer].spawn[1], lawyerNpc[nearestLawyer].spawn[2], lawyerNpc[nearestLawyer].spawn[3], x, y, z)
                if dist2 < 500.0 then
                    isSpawnable = false
                    break
                end
            end
            if isSpawnable  then
                local vehicle = CreateVehicle(8, lawyerNpc[nearestLawyer].spawn[1], lawyerNpc[nearestLawyer].spawn[2], lawyerNpc[nearestLawyer].spawn[3], lawyerNpc[nearestLawyer].spawn[4])
                PlayerData[player].job_vehicle = vehicle
                CreateVehicleData(player, vehicle, 8)
                SetVehiclePropertyValue(vehicle, "locked", true, true)
                PlayerData[player].job = "lawyer"
                return
            end
        end
    end
end)

AddRemoteEvent("StopLawyerJob", function(player,spawncar)
  if PlayerData[player].job == "lawyer" then
		if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
        end
        PlayerData[player].job = ""
        playerLawyer[player] = nil
    end
end)

AddEvent("OnPlayerDeath", function(player)
    for k,v in pairs(GetAllPlayers()) do
        if player ~= v and PlayerData[v].job == "lawyer" then
            print(player)
            print(v)
            print(k)
            SetPlayerRespawnTime(player, 120000)
        end
    end
end)

AddRemoteEvent("LawyerDoRevive", function(player,deadplayer)
    if player ~= deadplayer and PlayerData[player].job == "lawyer" then
        SetPlayerAnimation(player, "REVIVE")

        Delay(5000, function()
            SetPlayerAnimation(player, "STOP")
            SetPlayerRespawnTime(deadplayer, 100)
        end)
    end
end)

function GetNearestLawyer(player)
	local x, y, z = GetPlayerLocation(player)
	
	for k,v in pairs(GetAllNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(lawyerNpc) do
				if v == i.npc then
					return k
				end
			end
		end
	end

	return 0
end