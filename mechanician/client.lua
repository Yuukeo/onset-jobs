local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local mechanicianNpc
local reviving = false
AddEvent("OnTranslationReady", function()
    mechanicianNpcMenu = Dialog.create(_("mechanician_menu"), nil, _("start_mechanician") , _("stop_mechanician") ,_("cancel"))
end)

AddRemoteEvent("SetupMechanician", function(mechaniciannpc) 
    mechanicianNpc = mechaniciannpc
end)

AddEvent("OnKeyPress", function( key )
    if key == "E" then
        local NearestMechanician = GetNearestMechanician()
        if NearestMechanician ~= 0 then
            Dialog.show(mechanicianNpcMenu)
		end
		
		if reviving == false then
            local x, y, z = GetPlayerLocation()

            for k,v in pairs (GetAllPlayersInSphere( x, y, z, 250.0 )) do
                if IsPlayerDead(v) then
                    CallRemoteEvent("MechanicianDoRevive",v)
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
	if dialog == mechanicianNpcMenu then
		if button == 1 then	 
		    CallRemoteEvent("StartMechanicianJob") 
        end
		if button == 2 then
			CallRemoteEvent("StopMechanicianJob") 
        end
    end
end)

function GetNearestMechanician()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(mechanicianNpc) do
				if v == i then
					return v
				end
			end
		end
	end

	return 0
end


