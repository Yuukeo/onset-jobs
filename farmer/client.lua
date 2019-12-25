local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local farmerNpc
local reviving = false
AddEvent("OnTranslationReady", function()
    farmerNpcMenu = Dialog.create(_("farmer_menu"), nil, _("start_farmer") , _("stop_farmer") ,_("cancel"))
end)

AddRemoteEvent("SetupFarmer", function(farmernpc) 
    farmerNpc = farmernpc
end)

AddEvent("OnKeyPress", function( key )
    if key == "E" then
        local NearestFarmer = GetNearestFarmer()
        if NearestFarmer ~= 0 then
            Dialog.show(farmerNpcMenu)
		end
		
		if reviving == false then
            local x, y, z = GetPlayerLocation()

            for k,v in pairs (GetAllPlayersInSphere( x, y, z, 250.0 )) do
                if IsPlayerDead(v) then
                    CallRemoteEvent("FarmerDoRevive",v)
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
	if dialog == farmerNpcMenu then
		if button == 1 then	 
		    CallRemoteEvent("StartFarmerJob") 
        end
		if button == 2 then
			CallRemoteEvent("StopFarmerJob") 
        end
    end
end)

function GetNearestFarmer()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(farmerNpc) do
				if v == i then
					return v
				end
			end
		end
	end

	return 0
end


