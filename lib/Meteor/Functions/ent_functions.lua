
local ent_functions = {}

function ent_functions.getClosestVehicle(myPos)
	local closestDist = 999999999999
	local closestVeh = nil
	for _, veh in pairs(entities.get_all_vehicles_as_pointers()) do--use pointers because handles take more time
	      local vehpos = entities.get_position(veh) --takes pointer
	      local dist = myPos:distance(vehpos)
	      if (dist < closestDist) then
	    	closestDist = dist
	    	closestVeh = veh
	      end
    end
    if closestVeh ~= nil then
        return entities.pointer_to_handle(closestVeh)
    end
end

function ent_functions.request_control(Entity, Time)
	Time = Time or 5000
	if Entity and ENTITY.IS_AN_ENTITY(Entity) then
		if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(Entity) then
			NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(Entity)
			local time =  util.current_time_millis() + Time
			while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(Entity) and time > util.current_time_millis() do
				util.yield(0)
				NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(Entity)
			end
		end
		return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(Entity)
	end
end

function ent_functions.hard_remove_entity(Entity) -- Credits to kektram for this function
	if ENTITY.IS_AN_ENTITY(Entity) then
		::Repeat::
		if ENTITY.IS_ENTITY_ATTACHED(Entity) then
			Entity = ENTITY.GET_ENTITY_ATTACHED_TO(Entity)
			goto Repeat
		end
		if ENTITY.IS_AN_ENTITY(Entity) and not PED.IS_PED_A_PLAYER(Entity) then
			local Attachments = {}
			local peds = entities.get_all_vehicles_as_handles()
			local vehicles = entities.get_all_vehicles_as_handles()
			local objects = entities.get_all_objects_as_handles()
			local pickups = entities.get_all_pickups_as_handles()
			for i = 1, #peds do
				if ENTITY.GET_ENTITY_ATTACHED_TO(peds[i]) == Entity and not PED.IS_PED_A_PLAYER(peds[i]) then
					table.insert(Attachments, peds[i])
				end
			end
			for i = 1, #vehicles do
				if ENTITY.GET_ENTITY_ATTACHED_TO(vehicles[i]) == Entity then
					table.insert(Attachments, vehicles[i])
				end
			end
			for i = 1, #objects do
				if ENTITY.GET_ENTITY_ATTACHED_TO(objects[i]) == Entity then
					table.insert(Attachments, objects[i])
				end
			end
			for i = 1, #pickups do
				if ENTITY.GET_ENTITY_ATTACHED_TO(pickups[i]) == Entity then
					table.insert(Attachments, pickups[i])
				end
			end
			Attachments[#Attachments + 1] = Entity
			for i = 1, #Attachments do
				ent_functions.request_control(Attachments[i], 50)
				if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(Attachments[i]) then
					ENTITY.DETACH_ENTITY(Attachments[i])
					util.remove_blip(HUD.GET_BLIP_FROM_ENTITY(Attachments[i]))
					ENTITY.SET_ENTITY_AS_MISSION_ENTITY(Attachments[i], false, true)
					entities.delete_by_handle(Attachments[i])
				end
			end
		end
	end
end

function ent_functions.request_model(hash)
	local timeout = 3
	STREAMING.REQUEST_MODEL(hash)
	local end_time = os.time() + timeout
	repeat util.yield() until STREAMING.HAS_MODEL_LOADED(hash) or os.time() >= end_time
	return STREAMING.HAS_MODEL_LOADED(hash)
end

function ent_functions.get_distance_between(pos1, pos2) -- Credits to kektram for this function
	if math.type(pos1) == "integer" then
		pos1 = ENTITY.GET_ENTITY_COORDS(pos1)
	end
	if math.type(pos2) == "integer" then 
		pos2 = ENTITY.GET_ENTITY_COORDS(pos2)
	end
	return pos1:distance(pos2)
end

function ent_functions.create_orbital_cannon_explosion(Position)
	local player_ped = players.user_ped()
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z + 1, 59, 1, true, false, 1.0, false)
	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z + 1, 0, 180, 0, 1.0, true, true, true)
	for i = 1, 4 do
		AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "DLC_XM_Explosions_Orbital_Cannon", player_ped, 0, true, false)
	end
end

function ent_functions.get_current_aim_velocity_vector()
	local pos = players.get_position(players.user())
	local dir = CAM.GET_GAMEPLAY_CAM_ROT(0)
	dir:toDir()
	dir = dir * 8
	pos = pos + dir
	dir = nil
	local pos_target = player.get_player_coords(player.player_id())
	dir = cam.get_gameplay_cam_rot()
	dir:transformRotToDir()
	dir = dir * 100
	pos_target = pos_target + dir
	local vectorV3 = pos_target - pos
	return vectorV3
end

function ent_functions.create_nuke_explosion(Position, Named)
	local Owner
	if Named then
		Owner = players.user_ped()
	else
		Owner = 0
	end
	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z, 59, 1, true, false, 5.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z, 59, 1, true, false, 1.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)
	
	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)

	FIRE.ADD_EXPLOSION(Position.x+10, Position.y, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x, Position.y+10, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+10, Position.y+10, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x-10, Position.y, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x, Position.y-10, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x-10, Position.y-10, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+10, Position.y-10, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x-10, Position.y+10, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+20, Position.y, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x, Position.y+20, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+20, Position.y+20, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x-20, Position.y, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x, Position.y-20, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x-20, Position.y-20, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+20, Position.y-20, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x-20, Position.y+20, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+30, Position.y, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x, Position.y+30, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+30, Position.y+30, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x-30, Position.y, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x, Position.y-30, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x-30, Position.y-30, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+30, Position.y-30, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x-30, Position.y+30, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+10, Position.y+30, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+30, Position.y+10, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x-30, Position.y-10, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x-10, Position.y-30, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x-10, Position.y+30, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x-30, Position.y+10, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+30, Position.y-10, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+10, Position.y-30, Position.z, 59, 1.0, true, false, 1.0, false)

	for i = 1, 4 do
		AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "DLC_XM_Explosions_Orbital_Cannon", players.user_ped(), 0, true, false)
	end

	for pid = 0, 31 do
		if players.exists(pid) then
			if ent_functions.get_distance_between(players.get_position(pid), players.get_position(players.user())) < 75 then
				local pid_pos = players.get_position(pid)
				FIRE.ADD_EXPLOSION(pid_pos.x, pid_pos.y, pid_pos.z, 59, 1.0, true, false, 1.0, false)
			end
		end
	end

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z-10, 59, 1, true, false, 5.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z-10, 0, 180, 0, 4.5, true, true, true)
	
	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z-10, 0, 180, 0, 4.5, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end

	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+(-10), 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+10, Position.y, Position.z+(-10), 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x, Position.y+10, Position.z+(-10), 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+10, Position.y+10, Position.z+(-10), 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+(-10), Position.y, Position.z+(-10), 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x, Position.y+(-10), Position.z+(-10), 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+(-10), Position.y+(-10), Position.z+(-10), 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+10, Position.y+(-10), Position.z+(-10), 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+(-10), Position.y+10, Position.z+(-10), 59, 1.0, true, false, 1.0, false)
	
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+1, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+3, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+5, 59, 1, true, false, 5.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+5, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+7, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+10, 59, 1, true, false, 5.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+10, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+12, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+15, 59, 1, true, false, 5.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+15, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+17, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+20, 59, 1, true, false, 5.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+20, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+22, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+25, 59, 1, true, false, 5.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+25, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+27, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+30, 59, 1, true, false, 5.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+30, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+32, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+35, 59, 1, true, false, 5.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+35, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+37, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+40, 59, 1, true, false, 5.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+40, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+42, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+45, 59, 1, true, false, 5.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+45, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+47, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+50, 59, 1, true, false, 5.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+50, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+52, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+55, 59, 1, true, false, 5.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+55, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+57, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+59, 59, 1, true, false, 5.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+59, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+61, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+63, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)
	
	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+57, 59, 1, true, false, 5.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+65, 0, 180, 0, 1.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+75, 59, 1, true, false, 5.0, false)
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+75, 0, 0, 0, 3.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+75, 0, 0, 0, 3.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+75, 0, 0, 0, 3.5, true, true, true)
	util.yield(10)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+75, 0, 0, 0, 3.5, true, true, true)
	util.yield(10)
	
	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+80, 0, 0, 0, 3, true, true, true)

	while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
		STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
		util.yield(0)
	end
	GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+80, 0, 0, 0, 3, true, true, true)
	FIRE.ADD_EXPLOSION(Position.x+10, Position.y, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x, Position.y+10, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+10, Position.y+10, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+(-10), Position.y, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x, Position.y+(-10), Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x, Position.y+(-10), Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+10, Position.y+(-10), Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x, Position.y+(-10), Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x+(-10), Position.y+10, Position.z, 59, 1.0, true, false, 1.0, false)
	FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z, 59, 1.0, true, false, 1.0, false)

	for pid = 0, 31 do
		if players.exists(pid) then
			if ent_functions.get_distance_between(players.get_position(pid), Position) < 200 then
				local pid_pos = players.get_position(pid)
				FIRE.ADD_EXPLOSION(pid_pos.x, pid_pos.y, pid_pos.z, 59, 1.0, true, false, 1.0, false)
			end
		end
	end
	local peds = entities.get_all_pickups_as_handles()
	for i = 1, #peds do
		if ent_functions.get_distance_between(peds[i], Position) < 200 and NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(peds[i]) ~= players.user() then
			NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds[i])
			local ped_pos = ENTITY.GET_ENTITY_COORDS(peds[i], false)
			FIRE.ADD_EXPLOSION(ped_pos.x, ped_pos.y, ped_pos.z, 3, 1.0, true, false, 0.1, false)
			PED.SET_PED_TO_RAGDOLL(peds[i], 1000, 1000, 0, false, false, false)
		elseif ent_functions.get_distance_between(peds[i], Position) > 200 and ent_functions.get_distance_between(peds[i], Position) < 400 and NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(peds[i]) ~= players.user() then
			NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds[i])
			local ped_pos = ENTITY.GET_ENTITY_COORDS(peds[i], false)
			FIRE.ADD_EXPLOSION(ped_pos.x, ped_pos.y, ped_pos.z, 3, 1.0, true, false, 0.1, false)
			PED.SET_PED_TO_RAGDOLL(peds[i], 1000, 1000, 0, false, false, false)
		end
	end
	local found_index = false
	local found_train = nil
	local vehicles = entities.get_all_vehicles_as_handles()
	for i = 1, #vehicles do
		if ent_functions.get_distance_between(vehicles[i], Position) < 400 then
			NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicles[i])
			VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicles[i], -999.90002441406)
			VEHICLE.EXPLODE_VEHICLE(vehicles[i], true, false)
		elseif ent_functions.get_distance_between(vehicles[i], Position) > 200 and ent_functions.get_distance_between(vehicles[i], Position) < 400 then
			NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicles[i])
			VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicles[i], -4000)
		end
	end
end

function ent_functions.get_entity_player_is_aiming_at(player)
	if not PLAYER.IS_PLAYER_FREE_AIMING(player) then
		return NULL
	end
	local entity, pEntity = NULL, memory.alloc_int()
	if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(player, pEntity) then
		entity = memory.read_int(pEntity)
	end
	if entity ~= NULL and ENTITY.IS_ENTITY_A_PED(entity) and PED.IS_PED_IN_ANY_VEHICLE(entity, false) then
		entity = PED.GET_VEHICLE_PED_IS_IN(entity, false)
	end
	return entity
end

function ent_functions.offset_coords(pos, heading, distance, rotationorder)
	if rotationorder == 1 then
		heading = math.rad((heading - 180) * -1)
	elseif rotationorder == 2 then
		heading = math.rad((heading + 90) * -1)
	elseif rotationorder == 3 then
		heading = math.rad((heading - 360) * -1)
	else
		heading = math.rad((heading - 90) * -1)
	end
	pos.x = pos.x + (math.sin(heading) * -distance)
	pos.y = pos.y + (math.cos(heading) * -distance)
	return pos
end

return ent_functions