local playr_functions = {}

function playr_functions.is_player_driver(player_ped)
    local veh = entities.get_user_vehicle_as_handle(player_ped)
    local veh_seat_ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, true)
    if veh_seat_ped == player_ped then
	    return true
    else return false
    end
end

function playr_functions.is_player_driving_train(pid)
	if PED.IS_PED_IN_ANY_VEHICLE(pid) and (entities.get_user_vehicle_as_handle(false) == 1030400667 or entities.get_user_vehicle_as_handle(false) == 868868440) then
		return true
	else
		return false
	end
end
--credit to lance for this--
function playr_functions.get_offset_from_gameplay_camera(distance)
	local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(0)
	local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
	local direction = v3.toDir(cam_rot)
	local destination = {
	  x = cam_pos.x + direction.x * distance, 
	  y = cam_pos.y + direction.y * distance, 
	  z = cam_pos.z + direction.z * distance 
	}
	return destination
  end

function playr_functions.get_current_shooting_direction()
	if players.exists(players.user()) then
		local timeout = util.current_time_millis() + 1000
		local success, v3_start = PED.GET_PED_BONE_COORDS(players.user_ped(), 0x67f2, 0, 0, 0)
		while timeout > util.current_time_millis() and not success do
			success, v3_start = PED.GET_PED_BONE_COORDS(players.user_ped(), 0x67f2, 0, 0, 0)
			util.yield(0)
		end
		if not success then
			v3_start = players.get_position(players.user())
		end
		local dir = CAM.GET_GAMEPLAY_CAM_ROT(0)
		dir:toDir()
		return v3_start.x, v3_start.y, v3_start.z, dir.x * 150, dir.y * 150, dir.z * 150
	end
end

return playr_functions