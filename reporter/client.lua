local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local reporterNpc
local reviving = false
AddEvent("OnTranslationReady", function()
    reporterNpcMenu = Dialog.create(_("reporter_menu"), nil, _("start_reporter") , _("stop_reporter") ,_("cancel"))
end)

AddRemoteEvent("SetupReporter", function(reporternpc) 
    reporterNpc = reporternpc
end)

AddEvent("OnKeyPress", function( key )
    if key == "E" then
        local NearestReporter = GetNearestReporter()
        if NearestReporter ~= 0 then
            Dialog.show(reporterNpcMenu)
		end
		
		if reviving == false then
            local x, y, z = GetPlayerLocation()

            for k,v in pairs (GetAllPlayersInSphere( x, y, z, 250.0 )) do
                if IsPlayerDead(v) then
                    CallRemoteEvent("ReporterDoRevive",v)
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
	if dialog == reporterNpcMenu then
		if button == 1 then	 
		    CallRemoteEvent("StartReporterJob") 
        end
		if button == 2 then
			CallRemoteEvent("StopReporterJob") 
        end
    end
end)

function GetNearestReporter()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(reporterNpc) do
				if v == i then
					return v
				end
			end
		end
	end

	return 0
end


