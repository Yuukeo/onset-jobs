local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local realestateagentNpc
local reviving = false
AddEvent("OnTranslationReady", function()
    realestateagentNpcMenu = Dialog.create(_("realestateagent_menu"), nil, _("start_realestateagent") , _("stop_realestateagent") ,_("cancel"))
end)

AddRemoteEvent("SetupRealestateagent", function(realestateagentnpc) 
    realestateagentNpc = realestateagentnpc
end)

AddEvent("OnKeyPress", function( key )
    if key == "E" then
        local NearestRealestateagent = GetNearestRealestateagent()
        if NearestRealestateagent ~= 0 then
            Dialog.show(realestateagentNpcMenu)
		end
		
		if reviving == false then
            local x, y, z = GetPlayerLocation()

            for k,v in pairs (GetAllPlayersInSphere( x, y, z, 250.0 )) do
                if IsPlayerDead(v) then
                    CallRemoteEvent("RealestateagentDoRevive",v)
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
	if dialog == realestateagentNpcMenu then
		if button == 1 then	 
		    CallRemoteEvent("StartRealestateagentJob") 
        end
		if button == 2 then
			CallRemoteEvent("StopRealestateagentJob") 
        end
    end
end)

function GetNearestRealestateagent()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(realestateagentNpc) do
				if v == i then
					return v
				end
			end
		end
	end

	return 0
end


