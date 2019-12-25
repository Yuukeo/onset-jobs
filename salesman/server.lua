local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end
local salesmanNpc = {
            {
                location = { 211664, 159643, 1320, 90 },
                spawn = { 212956, 160465, 1305, -90 }
            },
          
}
local salesmanPoint = {
    { 116691, 164243, 3028 },
}

local salesmanNpcCached = {}
local playerSalesman = {}

AddEvent("OnPackageStart", function()
    for k,v in pairs(salesmanNpc) do
        salesmanNpc[k].npc = CreateNPC(salesmanNpc[k].location[1], salesmanNpc[k].location[2], salesmanNpc[k].location[3],salesmanNpc[k].location[4])
        CreateText3D(_("salesman_job").."\n".._("press_e"), 18, salesmanNpc[k].location[1], salesmanNpc[k].location[2], salesmanNpc[k].location[3] + 120, 0, 0, 0)
        table.insert(salesmanNpcCached, salesmanNpc[k].npc)
    end
end)

AddEvent("OnPlayerQuit", function( player )
    if playerSalesman[player] ~= nil then
        playerSalesman[player] = nil
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "SetupSalesman", salesmanNpcCached)
end)

AddRemoteEvent("StartSalesmanJob", function(player)
    local nearestSalesman = GetNearestSalesman(player)
    if PlayerData[player].job == "" then
        if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
           
        else
            local isSpawnable = true
            for k,v in pairs(GetAllVehicles()) do
                local x, y, z = GetVehicleLocation(v)
                local dist2 = GetDistance3D(salesmanNpc[nearestSalesman].spawn[1], salesmanNpc[nearestSalesman].spawn[2], salesmanNpc[nearestSalesman].spawn[3], x, y, z)
                if dist2 < 500.0 then
                    isSpawnable = false
                    break
                end
            end
            if isSpawnable  then
                local vehicle = CreateVehicle(8, salesmanNpc[nearestSalesman].spawn[1], salesmanNpc[nearestSalesman].spawn[2], salesmanNpc[nearestSalesman].spawn[3], salesmanNpc[nearestSalesman].spawn[4])
                PlayerData[player].job_vehicle = vehicle
                CreateVehicleData(player, vehicle, 8)
                SetVehiclePropertyValue(vehicle, "locked", true, true)
                PlayerData[player].job = "salesman"
                return
            end
        end
    end
end)

AddRemoteEvent("StopSalesmanJob", function(player,spawncar)
  if PlayerData[player].job == "salesman" then
		if PlayerData[player].job_vehicle ~= nil then
            DestroyVehicle(PlayerData[player].job_vehicle)
            DestroyVehicleData(PlayerData[player].job_vehicle)
            PlayerData[player].job_vehicle = nil
        end
        PlayerData[player].job = ""
        playerSalesman[player] = nil
    end
end)

AddEvent("OnPlayerDeath", function(player)
    for k,v in pairs(GetAllPlayers()) do
        if player ~= v and PlayerData[v].job == "salesman" then
            print(player)
            print(v)
            print(k)
            SetPlayerRespawnTime(player, 120000)
        end
    end
end)

AddRemoteEvent("SalesmanDoRevive", function(player,deadplayer)
    if player ~= deadplayer and PlayerData[player].job == "salesman" then
        SetPlayerAnimation(player, "REVIVE")

        Delay(5000, function()
            SetPlayerAnimation(player, "STOP")
            SetPlayerRespawnTime(deadplayer, 100)
        end)
    end
end)

function GetNearestSalesman(player)
	local x, y, z = GetPlayerLocation(player)
	
	for k,v in pairs(GetAllNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(salesmanNpc) do
				if v == i.npc then
					return k
				end
			end
		end
	end

	return 0
end