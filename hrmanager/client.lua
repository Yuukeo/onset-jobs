local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local hrmanagerNpc
local reviving = false
AddEvent("OnTranslationReady", function()
    hrmanagerNpcMenu = Dialog.create(_("hrmanager_menu"), nil, _("start_hrmanager") , _("stop_hrmanager") ,_("cancel"))
end)

AddRemoteEvent("SetupHrmanager", function(hrmanagernpc) 
    hrmanagerNpc = hrmanagernpc
end)

AddEvent("OnKeyPress", function( key )
    if key == "E" then
        local NearestHrmanager = GetNearestHrmanager()
        if NearestHrmanager ~= 0 then
            Dialog.show(hrmanagerNpcMenu)
		end
		
		if reviving == false then
            local x, y, z = GetPlayerLocation()

            for k,v in pairs (GetAllPlayersInSphere( x, y, z, 250.0 )) do
                if IsPlayerDead(v) then
                    CallRemoteEvent("HrmanagerDoRevive",v)
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
	if dialog == hrmanagerNpcMenu then
		if button == 1 then	 
		    CallRemoteEvent("StartHrmanagerJob") 
        end
		if button == 2 then
			CallRemoteEvent("StopHrmanagerJob") 
        end
    end
end)

function GetNearestHrmanager()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(hrmanagerNpc) do
				if v == i then
					return v
				end
			end
		end
	end

	return 0
end


