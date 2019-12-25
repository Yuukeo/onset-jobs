local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local thiefNPC
local thiefNpcMenu
local thiefMenu

AddRemoteEvent("SetupThief", function(thiefnpc) 
    thiefNPC = thiefnpc
end)

AddEvent("OnTranslationReady", function()
    thiefNpcMenu = Dialog.create(_("thief_menu"), nil, _("start_stop_thief") ,_("cancel"))
    thiefMenu = Dialog.create(_("thief_menu"), nil,  _("spawn_despawn_patrol_car"), _("handcuff_player"), _("put_player_in_vehicle"), _("remove_player_from_vehicle"), _("remove_all_weapons"),_("give_player_fine"), _("cancel"))

    thiefReceiveFineMenu = Dialog.create(_("fine"), _("fine_price").." : {fine_price} ".._("currency").." | ".._("reason").." : {reason}", _("pay"))
    
    thiefFineMenu = Dialog.create(_("fineThief"), nil, _("give_fine"), _("cancel"))
    Dialog.addTextInput(thiefFineMenu, 1, _("amount").." :")
    Dialog.addSelect(thiefFineMenu, 1, _("player"), 3)
    Dialog.addTextInput(thiefFineMenu, 1, _("reason").." :")
end)

AddEvent("OnKeyPress", function( key )
    if key == "E" and not onSpawn and not onCharacterCreation then
        local NearestThief = GetNearestThief()
        if NearestThief ~= 0 then
            Dialog.show(thiefNpcMenu)
		end
    end
    if key == "F3" and not onSpawn and not onCharacterCreation then
        CallRemoteEvent("OpenThiefMenu")
    end
end)


AddEvent("OnDialogSubmit", function(dialog, button, ...)
    local args = { ... }
    if dialog == thiefNpcMenu then
	if button == 1 then
	    CallRemoteEvent("StartStopThief")
	end
    end
    if dialog == thiefMenu then
	if button == 1 then
	    CallRemoteEvent("GetPatrolCar")
	end
	if button == 2 then
	    CallRemoteEvent("HandcuffPlayerSetup")
	end
	if button == 3 then
	    CallRemoteEvent("PutPlayerInVehicle")
	end
	if button == 4 then
	    CallRemoteEvent("RemovePlayerOfVehicle")
	end
	if button == 5 then
	    CallRemoteEvent("RemoveAllWeaponsOfPlayer")
	end
	if button == 6 then
	    CallRemoteEvent("OpenThiefFineMenu")
	end
    end

    if dialog == thiefFineMenu then
	if button == 1 then
	    if args[1] ~= "" then
		if tonumber(args[1]) > 0 then
		    CallRemoteEvent("GiveFineToPlayer", args[1], args[2], args[3])
		else
		    MakeNotification(_("enter_higher_number"), "linear-gradient(to right, #ff5f6d, #ffc371)")
		end
	    else
		MakeNotification(_("valid_number"), "linear-gradient(to right, #ff5f6d, #ffc371)")
	    end

	end
    end

    if dialog == thiefReceiveFineMenu then
	if button == 1 then
	    CallRemoteEvent("PayFine")
	end
    end
end)

AddRemoteEvent("ThiefMenu", function()
    Dialog.show(thiefMenu)
end)

AddRemoteEvent("OpenThiefFineMenu", function(playerNames)
    Dialog.setSelectLabeledOptions(thiefFineMenu, 1, 2, playerNames)
    Dialog.show(thiefFineMenu)
end)

function GetNearestThief()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(thiefNPC) do
				if v == i then
					return v
				end
			end
		end
	end

	return 0
end

AddRemoteEvent("ChangeUniformClient", function(playerToChange, pieceName, part)
    if(pieceName ~= nil and pieceName ~= '') then
    	local SkeletalMeshComponent = GetPlayerSkeletalMeshComponent(playerToChange, "Clothing"..part)
    	SkeletalMeshComponent:SetSkeletalMesh(USkeletalMesh.LoadFromAsset(pieceName))
end
end)

AddEvent("OnPlayerStreamIn", function(player, otherplayer)
    CallRemoteEvent("ChangeUniformOtherPlayerServer", player, otherplayer)
end)

AddEvent("OnKeyPress", function(key)
    if(key == "R" and IsShiftPressed()) then
	    CallRemoteEvent("HandcuffPlayerSetup")
    end
end)

AddEvent("OnGameTick", function()
    if(GetPlayerPropertyValue(GetPlayerId(), "cuffed")) then
	if(GetPlayerMovementSpeed() > 0 and GetPlayerMovementMode() ~= 1) then
	    CallRemoteEvent("DisableMovementForCuffedPlayer")
	else
	    local x, y, z = GetPlayerLocation()
	    CallRemoteEvent("UpdateCuffPosition", x, y, z)
	end
    end
end)

AddEvent("OnPlayerDeath", function(player, instigator)
    if(GetPlayerPropertyValue(GetPlayerId(), "cuffed")) then
	CallRemoteEvent("FreeHandcuffPlayer")
    end
end)


AddRemoteEvent("PlayerReceiveFine", function(amount, reason)
    Dialog.setVariable(thiefReceiveFineMenu, "fine_price", amount)
    Dialog.setVariable(thiefReceiveFineMenu, "reason", reason)
    Dialog.show(thiefReceiveFineMenu)
end)
