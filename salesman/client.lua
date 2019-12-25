local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local salesmanNpc
local reviving = false
AddEvent("OnTranslationReady", function()
    salesmanNpcMenu = Dialog.create(_("salesman_menu"), nil, _("start_salesman") , _("stop_salesman") ,_("cancel"))
end)

AddRemoteEvent("SetupSalesman", function(salesmannpc) 
    salesmanNpc = salesmannpc
end)

AddEvent("OnKeyPress", function( key )
    if key == "E" then
        local NearestSalesman = GetNearestSalesman()
        if NearestSalesman ~= 0 then
            Dialog.show(salesmanNpcMenu)
		end
		
		if reviving == false then
            local x, y, z = GetPlayerLocation()

            for k,v in pairs (GetAllPlayersInSphere( x, y, z, 250.0 )) do
                if IsPlayerDead(v) then
                    CallRemoteEvent("SalesmanDoRevive",v)
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
	if dialog == salesmanNpcMenu then
		if button == 1 then	 
		    CallRemoteEvent("StartSalesmanJob") 
        end
		if button == 2 then
			CallRemoteEvent("StopSalesmanJob") 
        end
    end
end)

function GetNearestSalesman()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(salesmanNpc) do
				if v == i then
					return v
				end
			end
		end
	end

	return 0
end


