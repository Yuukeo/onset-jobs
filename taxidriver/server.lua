local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end
local taxidriverNpc = {
            {
                location = { 211664, 159643, 1320, 90 },
                spawn = { 212956, 160465, 1305, -90 }
            },
          
}
local taxidriverPoint = {
    { 116691, 164243, 3028 },
}

local taxidriverNpcCached = {}
local playerTaxiDriver = {}

AddEvent("OnPackageStart", function()
    for k,v in pairs(taxidriverNpc) do
        taxidriverNpc[k].npc = CreateNPC(taxidriverNpc[k].location[1], taxidriverNpc[k].location[2], taxidriverNpc[k].location[3],taxidriverNpc[k].location[4])
        CreateText3D(_("taxidriver_job").."\n".._("press_e"), 18, taxidriverNpc[k].location[1], taxidriverNpc[k].location[2], taxidriverNpc[k].location[3] + 120, 0, 0, 0)
        table.insert(taxidriverNpcCached, taxidriverNpc[k].npc)
    end
end)

AddEvent("OnPlayerQuit", function( player )
    if playerTaxiDriver[player] ~= nil then
        playerTaxiDriver[player] = nil
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "SetupTaxiDriver", taxidriverNpcCached)
end)

AddRemoteEvent("StartTaxiDriverJob", function(player)
    local nearestTaxiDriver = GetNearestTaxiDriver(player)
    if PlayerData[player].job == "" then
        if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
           
        else
            local isSpawnable = true
            for k,v in pairs(GetAllVehicles()) do
                local x, y, z = GetVehicleLocation(v)
                local dist2 = GetDistance3D(taxidriverNpc[nearestTaxiDriver].spawn[1], taxidriverNpc[nearestTaxiDriver].spawn[2], taxidriverNpc[nearestTaxiDriver].spawn[3], x, y, z)
                if dist2 < 500.0 then
                    isSpawnable = false
                    break
                end
            end
            if isSpawnable  then
                local vehicle = CreateVehicle(8, taxidriverNpc[nearestTaxiDriver].spawn[1], taxidriverNpc[nearestTaxiDriver].spawn[2], taxidriverNpc[nearestTaxiDriver].spawn[3], taxidriverNpc[nearestTaxiDriver].spawn[4])
                PlayerData[player].job_vehicle = vehicle
                CreateVehicleData(player, vehicle, 8)
                SetVehiclePropertyValue(vehicle, "locked", true, true)
                PlayerData[player].job = "taxidriver"
                return
            end
        end
    end
end)

AddRemoteEvent("StopTaxiDriverJob", function(player,spawncar)
  if PlayerData[player].job == "taxidriver" then
		if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
        end
        PlayerData[player].job = ""
        playerTaxiDriver[player] = nil
    end
end)

AddEvent("OnPlayerDeath", function(player)
    for k,v in pairs(GetAllPlayers()) do
        if player ~= v and PlayerData[v].job == "taxidriver" then
            print(player)
            print(v)
            print(k)
            SetPlayerRespawnTime(player, 120000)
        end
    end
end)

AddRemoteEvent("TaxiDriverDoRevive", function(player,deadplayer)
    if player ~= deadplayer and PlayerData[player].job == "taxidriver" then
        SetPlayerAnimation(player, "REVIVE")

        Delay(5000, function()
            SetPlayerAnimation(player, "STOP")
            SetPlayerRespawnTime(deadplayer, 100)
        end)
    end
end)

function GetNearestTaxiDriver(player)
	local x, y, z = GetPlayerLocation(player)
	
	for k,v in pairs(GetAllNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(taxidriverNpc) do
				if v == i.npc then
					return k
				end
			end
		end
	end

	return 0
end