local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local dressmakerNpc
local reviving = false
AddEvent("OnTranslationReady", function()
    dressmakerNpcMenu = Dialog.create(_("dressmaker_menu"), nil, _("start_dressmaker") , _("stop_dressmaker") ,_("cancel"))
end)

AddRemoteEvent("SetupDressmaker", function(dressmakernpc) 
    dressmakerNpc = dressmakernpc
end)

AddEvent("OnKeyPress", function( key )
    if key == "E" then
        local NearestDressmaker = GetNearestDressmaker()
        if NearestDressmaker ~= 0 then
            Dialog.show(dressmakerNpcMenu)
		end
		
		if reviving == false then
            local x, y, z = GetPlayerLocation()

            for k,v in pairs (GetAllPlayersInSphere( x, y, z, 250.0 )) do
                if IsPlayerDead(v) then
                    CallRemoteEvent("DressmakerDoRevive",v)
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
	if dialog == dressmakerNpcMenu then
		if button == 1 then	 
		    CallRemoteEvent("StartDressmakerJob") 
        end
		if button == 2 then
			CallRemoteEvent("StopDressmakerJob") 
        end
    end
end)

function GetNearestDressmaker()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(dressmakerNpc) do
				if v == i then
					return v
				end
			end
		end
	end

	return 0
end


