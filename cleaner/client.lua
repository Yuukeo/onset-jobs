local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local cleanerNpc
local reviving = false
AddEvent("OnTranslationReady", function()
    cleanerNpcMenu = Dialog.create(_("cleaner_menu"), nil, _("start_cleaner") , _("stop_cleaner") ,_("cancel"))
end)

AddRemoteEvent("SetupCleaner", function(cleanernpc) 
    cleanerNpc = cleanernpc
end)

AddEvent("OnKeyPress", function( key )
    if key == "E" then
        local NearestCleaner = GetNearestCleaner()
        if NearestCleaner ~= 0 then
            Dialog.show(cleanerNpcMenu)
		end
		
		if reviving == false then
            local x, y, z = GetPlayerLocation()

            for k,v in pairs (GetAllPlayersInSphere( x, y, z, 250.0 )) do
                if IsPlayerDead(v) then
                    CallRemoteEvent("CleanerDoRevive",v)
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
	if dialog == cleanerNpcMenu then
		if button == 1 then	 
		    CallRemoteEvent("StartCleanerJob") 
        end
		if button == 2 then
			CallRemoteEvent("StopCleanerJob") 
        end
    end
end)

function GetNearestCleaner()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(cleanerNpc) do
				if v == i then
					return v
				end
			end
		end
	end

	return 0
end


