local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local lawyerNpc
local reviving = false
AddEvent("OnTranslationReady", function()
    lawyerNpcMenu = Dialog.create(_("lawyer_menu"), nil, _("start_lawyer") , _("stop_lawyer") ,_("cancel"))
end)

AddRemoteEvent("SetupLawyer", function(lawyernpc) 
    lawyerNpc = lawyernpc
end)

AddEvent("OnKeyPress", function( key )
    if key == "E" then
        local NearestLawyer = GetNearestLawyer()
        if NearestLawyer ~= 0 then
            Dialog.show(lawyerNpcMenu)
		end
		
		if reviving == false then
            local x, y, z = GetPlayerLocation()

            for k,v in pairs (GetAllPlayersInSphere( x, y, z, 250.0 )) do
                if IsPlayerDead(v) then
                    CallRemoteEvent("LawyerDoRevive",v)
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
	if dialog == lawyerNpcMenu then
		if button == 1 then	 
		    CallRemoteEvent("StartLawyerJob") 
        end
		if button == 2 then
			CallRemoteEvent("StopLawyerJob") 
        end
    end
end)

function GetNearestLawyer()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(lawyerNpc) do
				if v == i then
					return v
				end
			end
		end
	end

	return 0
end


