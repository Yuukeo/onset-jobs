local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local bankerNpc
local reviving = false
AddEvent("OnTranslationReady", function()
    bankerNpcMenu = Dialog.create(_("banker_menu"), nil, _("start_banker") , _("stop_banker") ,_("cancel"))
end)

AddRemoteEvent("SetupBanker", function(bankernpc) 
    bankerNpc = bankernpc
end)

AddEvent("OnKeyPress", function( key )
    if key == "E" then
        local NearestBanker = GetNearestBanker()
        if NearestBanker ~= 0 then
            Dialog.show(bankerNpcMenu)
		end
		
		if reviving == false then
            local x, y, z = GetPlayerLocation()

            for k,v in pairs (GetAllPlayersInSphere( x, y, z, 250.0 )) do
                if IsPlayerDead(v) then
                    CallRemoteEvent("BankerDoRevive",v)
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
	if dialog == bankerNpcMenu then
		if button == 1 then	 
		    CallRemoteEvent("StartBankerJob") 
        end
		if button == 2 then
			CallRemoteEvent("StopBankerJob") 
        end
    end
end)

function GetNearestBanker()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(bankerNpc) do
				if v == i then
					return v
				end
			end
		end
	end

	return 0
end


