local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local cookNpc
local reviving = false
AddEvent("OnTranslationReady", function()
    cookNpcMenu = Dialog.create(_("cook_menu"), nil, _("start_cook") , _("stop_cook") ,_("cancel"))
end)

AddRemoteEvent("SetupCook", function(cooknpc) 
    cookNpc = cooknpc
end)

AddEvent("OnKeyPress", function( key )
    if key == "E" then
        local NearestCook = GetNearestCook()
        if NearestCook ~= 0 then
            Dialog.show(cookNpcMenu)
		end
		
		if reviving == false then
            local x, y, z = GetPlayerLocation()

            for k,v in pairs (GetAllPlayersInSphere( x, y, z, 250.0 )) do
                if IsPlayerDead(v) then
                    CallRemoteEvent("CookDoRevive",v)
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
	if dialog == cookNpcMenu then
		if button == 1 then	 
		    CallRemoteEvent("StartCookJob") 
        end
		if button == 2 then
			CallRemoteEvent("StopCookJob") 
        end
    end
end)

function GetNearestCook()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(cookNpc) do
				if v == i then
					return v
				end
			end
		end
	end

	return 0
end


