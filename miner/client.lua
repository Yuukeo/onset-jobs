local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local minerNpc
local reviving = false
AddEvent("OnTranslationReady", function()
    minerNpcMenu = Dialog.create(_("miner_menu"), nil, _("start_miner") , _("stop_miner") ,_("cancel"))
end)

AddRemoteEvent("SetupMiner", function(minernpc) 
    minerNpc = minernpc
end)

AddEvent("OnKeyPress", function( key )
    if key == "E" then
        local NearestMiner = GetNearestMiner()
        if NearestMiner ~= 0 then
            Dialog.show(minerNpcMenu)
		end
		
		if reviving == false then
            local x, y, z = GetPlayerLocation()

            for k,v in pairs (GetAllPlayersInSphere( x, y, z, 250.0 )) do
                if IsPlayerDead(v) then
                    CallRemoteEvent("MinerDoRevive",v)
                    reviving = true
                    Delay(6000,function()
                        reviving = false
                    end)
	                break
		        end
		    end
		end
    end
end)


AddEvent("OnDialogSubmit", function(dialog, button, ...)
	if dialog == minerNpcMenu then
		if button == 1 then	 
		    CallRemoteEvent("StartMinerJob") 
        end
		if button == 2 then
			CallRemoteEvent("StopMinerJob") 
        end
    end
end)

function GetNearestMiner()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(minerNpc) do
				if v == i then
					return v
				end
			end
		end
	end

	return 0
end


