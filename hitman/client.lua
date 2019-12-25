local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local hitmanNPC
local hitmanNpcMenu
local hitmanMenu

AddRemoteEvent("SetupHitman", function(hitmannpc) 
    hitmanNPC = hitmannpc
end)

AddEvent("OnTranslationReady", function()
    hitmanNpcMenu = Dialog.create(_("hitman_menu"), nil, _("start_stop_hitman") ,_("cancel"))
    hitmanMenu = Dialog.create(_("hitman_menu"), nil,  _("spawn_despawn_patrol_car"), _("handcuff_player"), _("put_player_in_vehicle"), _("remove_player_from_vehicle"), _("remove_all_weapons"),_("give_player_fine"), _("cancel"))

    hitmanReceiveFineMenu = Dialog.create(_("fine"), _("fine_price").." : {fine_price} ".._("currency").." | ".._("reason").." : {reason}", _("pay"))
    
    hitmanFineMenu = Dialog.create(_("fineHitman"), nil, _("give_fine"), _("cancel"))
    Dialog.addTextInput(hitmanFineMenu, 1, _("amount").." :")
    Dialog.addSelect(hitmanFineMenu, 1, _("player"), 3)
    Dialog.addTextInput(hitmanFineMenu, 1, _("reason").." :")
end)

AddEvent("OnKeyPress", function( key )
    if key == "E" and not onSpawn and not onCharacterCreation then
        local NearestHitman = GetNearestHitman()
        if NearestHitman ~= 0 then
            Dialog.show(hitmanNpcMenu)
		end
    end
    if key == "F3" and not onSpawn and not onCharacterCreation then
        CallRemoteEvent("OpenHitmanMenu")
    end
end)


AddEvent("OnDialogSubmit", function(dialog, button, ...)
    local args = { ... }
    if dialog == hitmanNpcMenu then
	if button == 1 then
	    CallRemoteEvent("StartStopHitman")
	end
    end
    if dialog == hitmanMenu then
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
	    CallRemoteEvent("OpenHitmanFineMenu")
	end
    end

    if dialog == hitmanFineMenu then
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

    if dialog == hitmanReceiveFineMenu then
	if button == 1 then
	    CallRemoteEvent("PayFine")
	end
    end
end)

AddRemoteEvent("HitmanMenu", function()
    Dialog.show(hitmanMenu)
end)

AddRemoteEvent("OpenHitmanFineMenu", function(playerNames)
    Dialog.setSelectLabeledOptions(hitmanFineMenu, 1, 2, playerNames)
    Dialog.show(hitmanFineMenu)
end)

function GetNearestHitman()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(hitmanNPC) do
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
    Dialog.setVariable(hitmanReceiveFineMenu, "fine_price", amount)
    Dialog.setVariable(hitmanReceiveFineMenu, "reason", reason)
    Dialog.show(hitmanReceiveFineMenu)
end)
