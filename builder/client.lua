local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local builderNpc
local reviving = false
AddEvent("OnTranslationReady", function()
    builderNpcMenu = Dialog.create(_("builder_menu"), nil, _("start_builder") , _("stop_builder") ,_("cancel"))
end)

AddRemoteEvent("SetupBuilder", function(buildernpc) 
    builderNpc = buildernpc
end)

AddEvent("OnKeyPress", function( key )
    if key == "E" then
        local NearestBuilder = GetNearestBuilder()
        if NearestBuilder ~= 0 then
            Dialog.show(builderNpcMenu)
		end
		
		if reviving == false then
            local x, y, z = GetPlayerLocation()

            for k,v in pairs (GetAllPlayersInSphere( x, y, z, 250.0 )) do
                if IsPlayerDead(v) then
                    CallRemoteEvent("BuilderDoRevive",v)
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
	if dialog == builderNpcMenu then
		if button == 1 then	 
		    CallRemoteEvent("StartBuilderJob") 
        end
		if button == 2 then
			CallRemoteEvent("StopBuilderJob") 
        end
    end
end)

function GetNearestBuilder()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(builderNpc) do
				if v == i then
					return v
				end
			end
		end
	end

	return 0
end


