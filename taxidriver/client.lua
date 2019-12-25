local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local taxidriverNpc
local reviving = false
AddEvent("OnTranslationReady", function()
    taxidriverNpcMenu = Dialog.create(_("taxidriver_menu"), nil, _("start_taxidriver") , _("stop_taxidriver") ,_("cancel"))
end)

AddRemoteEvent("SetupTaxidriver", function(taxidrivernpc) 
    taxidriverNpc = taxidrivernpc
end)

AddEvent("OnKeyPress", function( key )
    if key == "E" then
        local NearestTaxidriver = GetNearestTaxidriver()
        if NearestTaxidriver ~= 0 then
            Dialog.show(taxidriverNpcMenu)
		end
		
		if reviving == false then
            local x, y, z = GetPlayerLocation()

            for k,v in pairs (GetAllPlayersInSphere( x, y, z, 250.0 )) do
                if IsPlayerDead(v) then
                    CallRemoteEvent("TaxidriverDoRevive",v)
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
	if dialog == taxidriverNpcMenu then
		if button == 1 then	 
		    CallRemoteEvent("StartTaxidriverJob") 
        end
		if button == 2 then
			CallRemoteEvent("StopTaxidriverJob") 
        end
    end
end)

function GetNearestTaxidriver()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(taxidriverNpc) do
				if v == i then
					return v
				end
			end
		end
	end

	return 0
end


