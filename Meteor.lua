--this is the 2take1 Meteor script i recoded it and removed ALOT options bc they were banable bc the latest version of this script was around a half year back and there were alot of money drop options or give rp
--options that i didnt want to mess with also alot logging i also didnt do bc useless tbh also alot of spawn maps etc options removed bc we got contructor script already for stand thats way better also like 500 line
--code with crashes that i RLLY didnt wanna mess with ban reasons whatever you know the shit also some stuff that just isnt posible with out mod api thats basicly it so this is kinda the smaller version of the origial
--with all options i could recode and didnt leave out bc useless, to risky, isnt even posible anymore with gta itself

--i got permision of the original owner of the script (RulyPancake) and alot credit to him hes a amazing coder
--so yeah i hope u injoy of what i made--
util.keep_running()
util.require_natives(1663599433)

-----------------
--update system--
-----------------
local status, auto_updater = pcall(require, "auto-updater")
if not status then
    local auto_update_complete = nil util.toast("Installing auto-updater...", TOAST_ALL)
    async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
        function(result, headers, status_code)
            local function parse_auto_update_result(result, headers, status_code)
                local error_prefix = "Error downloading auto-updater: "
                if status_code ~= 200 then util.toast(error_prefix..status_code, TOAST_ALL) return false end
                if not result or result == "" then util.toast(error_prefix.."Found empty file.", TOAST_ALL) return false end
                filesystem.mkdir(filesystem.scripts_dir() .. "lib")
                local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
                if file == nil then util.toast(error_prefix.."Could not open file for writing.", TOAST_ALL) return false end
                file:write(result) file:close() util.toast("Successfully installed auto-updater lib", TOAST_ALL) return true
            end
            auto_update_complete = parse_auto_update_result(result, headers, status_code)
        end, function() util.toast("Error downloading auto-updater lib. Update failed to download.", TOAST_ALL) end)
    async_http.dispatch() local i = 1 while (auto_update_complete == nil and i < 40) do util.yield(250) i = i + 1 end
    if auto_update_complete == nil then error("Error downloading auto-updater lib. HTTP Request timeout") end
    auto_updater = require("auto-updater")
end
if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end

local default_check_interval = 604800
local auto_update_config = {
    source_url="https://raw.githubusercontent.com/NovaPlays134/Meteor/main/Meteor.lua",
    script_relpath=SCRIPT_RELPATH,
    switch_to_branch=selected_branch,
    verify_file_begins_with="--",
    check_interval=86400,
    silent_updates=true,
    dependencies={
        {
            name="ent_functions",
            source_url="https://raw.githubusercontent.com/NovaPlays134/Meteor/main/lib/Meteor/Functions/ent_functions.lua",
            script_relpath="lib/Meteor/Functions/ent_functions.lua",
            check_interval=default_check_interval,
        },

        {
            name="functions",
            source_url="https://raw.githubusercontent.com/NovaPlays134/Meteor/main/lib/Meteor/Functions/functions.lua",
            script_relpath="lib/Meteor/Functions/functions.lua",
            check_interval=default_check_interval,
        },

        {
            name="playr_functions",
            source_url="https://raw.githubusercontent.com/NovaPlays134/Meteor/main/lib/Meteor/Functions/playr_functions.lua",
            script_relpath="lib/Meteor/Functions/playr_functions.lua",
            check_interval=default_check_interval,
        },

        {
            name="weapon_hashes",
            source_url="https://raw.githubusercontent.com/NovaPlays134/Meteor/main/lib/Meteor/Functions/weapon_hashes.lua",
            script_relpath="lib/Meteor/Functions/weapon_hashes.lua",
            check_interval=default_check_interval,
        },

        {
            name="Playerblip",
            source_url="https://raw.githubusercontent.com/NovaPlays134/Meteor/main/lib/Meteor/sprite1.png",
            script_relpath="lib/Meteor/sprite1.png",
            check_interval=default_check_interval,
        },
    }
}
auto_updater.run_auto_update(auto_update_config)

--requiring files--
local func = require "Meteor.Functions.functions"
local ent_func = require "Meteor.Functions.ent_functions"
local playr_func = require "Meteor.Functions.playr_functions"
local wep_hashes = require "Meteor.Functions.weapon_hashes"

--MAINS--
local main_local = menu.list(menu.my_root(), "Local")
local main_online = menu.list(menu.my_root(), "Online")
local main_spawner = menu.list(menu.my_root(), "Spawner")
local main_settings = menu.list(menu.my_root(), "Settings")
--LOCAL LISTS--
local player_options = menu.list(main_local, "Player Options")
local vehicle_options = menu.list(main_local, "Vehicle Options")
local world_options = menu.list(main_local, "World")
local utilities_options = menu.list(main_local, "Utilities")
local weapon_modifiers_options = menu.list(main_local, "Weapon Modifiers")
local misc_options = menu.list(main_local, "Misc")
--ONLINE LISTS--
local all_player_options = menu.list(main_online, "All Players")
local lobby_options = menu.list(main_online, "Lobby")


local godmode_features = {"Off", "v1", "v2"}
menu.textslider(player_options, "Godmode", {}, "", godmode_features, function(index, name)
	if index == 2 then
		ENTITY.SET_ENTITY_PROOFS(players.user_ped(), true, true, true, true, true, true, true, true)
	else
		ENTITY.SET_ENTITY_ONLY_DAMAGED_BY_RELATIONSHIP_GROUP(players.user_ped(), true, 0)
    end
	if index == 1 then
	    ENTITY.SET_ENTITY_PROOFS(players.user_ped(), false, false, false, false, false, false, false, false)
	    ENTITY.SET_ENTITY_ONLY_DAMAGED_BY_RELATIONSHIP_GROUP(players.user_ped(), false, 0)
	end
end)

----------
--PROOFS--
----------
--credit to prism for this code--
local proofs = {
    bullet = memory.alloc(),
    fire = memory.alloc(),
    expl = memory.alloc(),
    coll = memory.alloc(),
    melee = memory.alloc(),
    steam = memory.alloc(),
    p7 = memory.alloc(),
    drown = memory.alloc()
}

local proofs1 = {
	bullet1 = func.convert_value(memory.read_short(proofs.bullet)),
    fire1 = func.convert_value(memory.read_short(proofs.fire)),
    expl1 = func.convert_value(memory.read_short(proofs.expl)),
    coll1 = func.convert_value(memory.read_short(proofs.coll)),
    melee1 = func.convert_value(memory.read_short(proofs.melee)),
    steam1 = func.convert_value(memory.read_short(proofs.steam)),
    p71 = func.convert_value(memory.read_short(proofs.p7)),
    drown1 = func.convert_value(memory.read_short(proofs.drown))
}

local custom_proofs = menu.list(player_options, "Custom Proofs")
local proofs = {
    bullet = {name="Bullets",on=false},
    fire = {name="Fire",on=false},
    explosion = {name="Explosions",on=false},
    collision = {name="Collision",on=false},
    melee = {name="Melee",on=false},
    steam = {name="Steam",on=false},
    drown = {name="Drowning",on=false},
}
local immortalityCmd = menu.ref_by_path("Self>Immortality")
for _,data in pairs(proofs) do
    menu.toggle(custom_proofs, data.name, {data.name:lower().."proof"}, "Makes you invulnerable to "..data.name:lower()..".", function(toggle)
        data.on = toggle
    end)
end
util.create_tick_handler(function()
    local local_player = players.user_ped()
    if not menu.get_value(immortalityCmd) then
        ENTITY.SET_ENTITY_PROOFS(local_player, proofs.bullet.on, proofs.fire.on, proofs.explosion.on, proofs.collision.on, proofs.melee.on, proofs.steam.on, false, proofs.drown.on)
    end
end)
--end proofs--

menu.action(player_options, "Resurrect", {}, "", function()
	if ENTITY.IS_ENTITY_DEAD(players.user_ped()) then
		NETWORK.NETWORK_RESURRECT_LOCAL_PLAYER(players.get_position(players.user()).x, players.get_position(players.user()).y, players.get_position(players.user()).z, ENTITY.GET_ENTITY_HEADING(players.user_ped()), false, false, 0, 0, 0)
	else
		func.toast("Meteor", "You need to be dead.")
	end
end)

menu.toggle(player_options, "Auto Resurrect", {}, "", function(on)
	while on do
		if ENTITY.IS_ENTITY_DEAD(players.user_ped()) then
			NETWORK.NETWORK_RESURRECT_LOCAL_PLAYER(players.get_position(players.user()).x, players.get_position(players.user()).y, players.get_position(players.user()).z, ENTITY.GET_ENTITY_HEADING(players.user_ped()), false, false, 0, 0, 0)
			for i = 1, 50 do
				ENTITY.SET_ENTITY_COORDS_NO_OFFSET(players.user_ped(), players.get_position(players.user()).x, players.get_position(players.user()).y, players.get_position(players.user()).z, false, false, false)
			end
		end
		util.yield(0)
	end
end)

menu.action(player_options, "Ragdoll", {}, "", function()
	PED.SET_PED_TO_RAGDOLL(players.user_ped(), 2500, 0, 0, false, false, false) 
end)

menu.toggle(player_options, "Ragdoll Loop", {}, "", function(on)
	while on do
		PED.SET_PED_TO_RAGDOLL(players.user_ped(), 2500, 0, 0, false, false, false)
		util.yield(0)
	end
end)

menu.toggle(player_options, "RP Crouch", {}, "", function(on)
	if on then
		if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) and not PED.IS_PED_RAGDOLL(players.user_ped()) and not ENTITY.IS_ENTITY_DEAD(players.user_ped()) then
			PED.RESET_PED_MOVEMENT_CLIPSET(players.user_ped(), 0.0)
			CAM.DISABLE_AIM_CAM_THIS_UPDATE()
			PED.SET_PED_CAN_PLAY_AMBIENT_ANIMS(players.user_ped(), false)
			PED.SET_PED_CAN_PLAY_AMBIENT_BASE_ANIMS(players.user_ped(), false)
			CAM.SET_THIRD_PERSON_AIM_CAM_NEAR_CLIP_THIS_UPDATE(-10.0)
			STREAMING.REQUEST_ANIM_SET("move_ped_crouched")
			PED.SET_PED_MOVEMENT_CLIPSET(players.user_ped(), "move_ped_crouched", 1.0)
			STREAMING.REQUEST_ANIM_SET("move_ped_crouched_strafing")
			PED.SET_PED_STRAFE_CLIPSET(players.user_ped(), "move_ped_crouched_strafing")
			util.yield(100)
			while on and not ENTITY.IS_ENTITY_DEAD(players.user_ped()) do
				util.yield(0)
			end
		end
	end
	on = false
	if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) and not PED.IS_PED_RAGDOLL(players.user_ped()) and not ENTITY.IS_ENTITY_DEAD(players.user_ped()) then
		PED.SET_PED_CAN_PLAY_AMBIENT_ANIMS(players.user_ped(), true)
		PED.SET_PED_CAN_PLAY_AMBIENT_BASE_ANIMS(players.user_ped(), true)
		STREAMING.REMOVE_ANIM_SET("move_ped_crouched")
		STREAMING.REMOVE_ANIM_SET("move_ped_crouched_strafing")
		PED.RESET_PED_MOVEMENT_CLIPSET(players.user_ped(), 1.0)
		PED.RESET_PED_STRAFE_CLIPSET(players.user_ped())
	end
end)

menu.toggle(player_options, "RP Prone", {}, "", function(on)
	if on then
		if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) and not PED.IS_PED_RAGDOLL(players.user_ped()) and not ENTITY.IS_ENTITY_DEAD(players.user_ped()) then
			STREAMING.REQUEST_ANIM_DICT("missfbi3_sniping")
			STREAMING.REQUEST_ANIM_SET("prone_michael")
			TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
			TASK.TASK_PLAY_ANIM(players.user_ped(), "missfbi3_sniping", "prone_michael", 1, 0, 1000, 1, 0, true, true, true)
			util.yield(100)
			while on and not ENTITY.IS_ENTITY_DEAD(players.user_ped()) do
				util.yield(0)
			end
		end
	end
	on = false
	if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) and not PED.IS_PED_RAGDOLL(players.user_ped()) and not ENTITY.IS_ENTITY_DEAD(players.user_ped()) then
		TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
	end
end)

menu.toggle(player_options, "Get Drunk", {}, "", function(on)
	if on then
		CAM.SHAKE_GAMEPLAY_CAM("DRUNK_SHAKE", 1)
		GRAPHICS.SET_TIMECYCLE_MODIFIER("Drunk")
		STREAMING.REQUEST_ANIM_SET("move_m@drunk@verydrunk")
		while not STREAMING.HAS_ANIM_SET_LOADED("move_m@drunk@verydrunk") do
			STREAMING.REQUEST_ANIM_SET("move_m@drunk@verydrunk")
			util.yield(0)
		end
		PED.SET_PED_MOVEMENT_CLIPSET(players.user_ped(), "move_m@drunk@verydrunk", 0.0)
		AUDIO.SET_PED_IS_DRUNK(players.user_ped(), true)
		ENTITY.SET_ENTITY_MOTION_BLUR(players.user_ped(), true)
		while on do
			if not PED.IS_PED_RAGDOLL(players.user_ped()) then
				PED.SET_PED_RAGDOLL_ON_COLLISION(players.user_ped(), true)
			else
				PED.SET_PED_RAGDOLL_ON_COLLISION(players.user_ped(), false)
				util.yield(5000)
			end
			util.yield(0)
		end
	end
	if not on then
		PED.RESET_PED_MOVEMENT_CLIPSET(players.user_ped(), 0.0)
		GRAPHICS.SET_TIMECYCLE_MODIFIER("DEFAULT")
		CAM.SHAKE_GAMEPLAY_CAM("DRUNK_SHAKE", 0)
	    AUDIO.SET_PED_IS_DRUNK(players.user_ped(), false)
		PED.SET_PED_RAGDOLL_ON_COLLISION(players.user_ped(), false)
		ENTITY.SET_ENTITY_MOTION_BLUR(players.user_ped(), false)
	end
end)

menu.action(player_options, "Take A Shit", {}, "", function(on)
	if on then
		if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
			STREAMING.REQUEST_ANIM_DICT("missfbi3ig_0")
			STREAMING.REQUEST_ANIM_SET("shit_loop_trev")
			while not STREAMING.HAS_ANIM_DICT_LOADED("missfbi3ig_0") do
				util.yield(0)
				STREAMING.REQUEST_ANIM_DICT("missfbi3ig_0")
				STREAMING.REQUEST_ANIM_SET("shit_loop_trev")
			end
			TASK.TASK_PLAY_ANIM(players.user_ped(), "missfbi3ig_0", "shit_loop_trev", 8.0, 8.0, 2000, 0.0, 0.0, true, true, true)
			util.yield(1000)
			local poophash = util.joaat("prop_big_shit_02")
			local player_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 0.0, -0.5)
			local poop = OBJECT.CREATE_OBJECT_NO_OFFSET(poophash, player_pos.x, player_pos.y, player_pos.z, true, false, false)
			ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(poop, players.user_ped(), false)
			ENTITY.APPLY_FORCE_TO_ENTITY(poop, 3, 0, 0, -10, 0, 0, 0, 0, false, false, false, false, false)
		end
	end
end)

local special_ability = menu.list(player_options, "Special Ability")

menu.action(special_ability, "Recharge Bar", {}, "", function()
	if not util.is_session_started() then
		PLAYER.SPECIAL_ABILITY_CHARGE_ABSOLUTE(players.user(), 30, true, 0)
	end
end)

menu.action(special_ability, "Reset Bar", {}, "", function()
	if not util.is_session_started() then
		PLAYER.SPECIAL_ABILITY_RESET(players.user(), 0)
	end
end)

menu.toggle(special_ability, "Insta Recharge Bar", {}, "", function(on)
	while on do
		util.yield(100)
	    if not util.is_session_started() then
			PLAYER.SPECIAL_ABILITY_CHARGE_ABSOLUTE(players.user(), 30, true, 0)
	    end
	end
end)

menu.toggle(special_ability, "Toggle Special Ability", {}, "", function(on)
	if not util.is_session_started() then
	    if on then
			PLAYER.SPECIAL_ABILITY_ACTIVATE(players.user(), 0)
	    end
		if not on then
			PLAYER.SPECIAL_ABILITY_DEACTIVATE(players.user(), 0)
		end
	end
end)

-------------------
--VEHICLE OPTIONS--
-------------------
local veh_godmode_features = {"Off", "v1", "v2"}
menu.textslider(vehicle_options, "Vehicle Godmode", {}, "", veh_godmode_features, function(index, name)
	if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
	    if index == 2 then
	    	ENTITY.SET_ENTITY_PROOFS(entities.get_user_vehicle_as_handle(true), true, true, true, true, true, true, true, true)
	    else
	    	ENTITY.SET_ENTITY_ONLY_DAMAGED_BY_RELATIONSHIP_GROUP(entities.get_user_vehicle_as_handle(true), true, 0)
	    end
	    if index == 1 then
	        ENTITY.SET_ENTITY_PROOFS(entities.get_user_vehicle_as_handle(true), false, false, false, false, false, false, false, false)
	        ENTITY.SET_ENTITY_ONLY_DAMAGED_BY_RELATIONSHIP_GROUP(entities.get_user_vehicle_as_handle(true), false, 0)
	    end
	else
		func.toast("Meteor", "Ur not in any vehicle.")
	end
end)

--veh proofs--
--also credit to prism for this code--
local veh_custom_proofs = menu.list(vehicle_options, "Custom Proofs")
local proofs = {
    bullet = {name="Bullets",on=false},
    fire = {name="Fire",on=false},
    explosion = {name="Explosions",on=false},
    collision = {name="Collision",on=false},
    melee = {name="Melee",on=false},
    steam = {name="Steam",on=false},
    drown = {name="Drowning",on=false},
}
for _,data in pairs(proofs) do
    menu.toggle(veh_custom_proofs, data.name, {data.name:lower().."proof"}, "Makes you invulnerable to "..data.name:lower()..".", function(toggle)
        data.on = toggle
    end)
end
util.create_tick_handler(function()
    local vehicle = entities.get_user_vehicle_as_handle(true)
        ENTITY.SET_ENTITY_PROOFS(vehicle, proofs.bullet.on, proofs.fire.on, proofs.explosion.on, proofs.collision.on, proofs.melee.on, proofs.steam.on, false, proofs.drown.on)
end)
--end veh proofs--

menu.action(vehicle_options, "Enter Nearest Vehicle", {}, "", function()
	if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
		local player_pos = players.get_position(players.user())

		local veh = ent_func.getClosestVehicle(player_pos)
		local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, true)
		if PED.IS_PED_A_PLAYER(ped) then
			util.yield("Vehicle has player driving.")
		else
		    entities.delete_by_handle(ped)
			PED.SET_PED_INTO_VEHICLE(players.user_ped(), veh, -1)
		end
	end
end)

menu.action(vehicle_options, "Hard Remove Vehicle", {}, "", function()
	if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
		if ent_func.request_control(entities.get_user_vehicle_as_handle(false)) then
			ent_func.hard_remove_entity(entities.get_user_vehicle_as_handle(false))
		end
	end
end)

menu.action(vehicle_options, "Force Leave Vehicle", {}, "", function()
	if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
		TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
	end
end)

menu.toggle(vehicle_options, "Remove Plane Turbulence", {}, "", function(on)
	if on then
		while on do
			util.yield(1000)
			if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) and VEHICLE.IS_THIS_MODEL_A_PLANE(entities.get_user_vehicle_as_handle(players.user())) then
				NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entities.get_user_vehicle_as_handle(players.user()))
				VEHICLE.SET_PLANE_TURBULENCE_MULTIPLIER(entities.get_user_vehicle_as_handle(players.user()), 0.0)
			end
		end
	end
end)

local horn_boost_speed = 100
horn_boost_toggle = menu.toggle_loop(vehicle_options, "Horn boost", {}, "If you have this on then 'Boost' wont work", function()
	if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
	    local vehicle = entities.get_user_vehicle_as_handle(players.user())
	    if not (AUDIO.IS_HORN_ACTIVE(vehicle)) then return end
	        local speed = horn_boost_speed
	    	VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, speed)
	    	local velocity = ENTITY.GET_ENTITY_VELOCITY(vehicle)
            ENTITY.SET_ENTITY_VELOCITY(vehicle, velocity.x, velocity.y, velocity.z)
    else
		func.toast("Meteor", "you are not in any vehicle.")
        menu.set_value(horn_boost_toggle, false)
    end
end)

menu.slider(vehicle_options, "Boost speed", {}, "", 10, 400, 100, 10, function(count)
	horn_boost_speed = count
end)

--train controls--
local train_controls = menu.list(vehicle_options, "Train Controls")

menu.action(train_controls, "Enter Nearest Train", {}, "", function()
	local vehicles = entities.get_all_vehicles_as_handles()
	local found_index = false
	for i = 1, #vehicles do
		if ENTITY.GET_ENTITY_MODEL(vehicles[i]) == 1030400667 or ENTITY.GET_ENTITY_MODEL(vehicles[i]) == 868868440 then
			if not found_index then
				ent_func.request_control(vehicles[i])
				local ped_in_seat = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicles[i], -1, true)
				if ped_in_seat and not PED.IS_PED_A_PLAYER(ped_in_seat) then
					entities.delete_by_handle(ped_in_seat)
				end
				PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicles[i], -1)
			end
			found_index = true
		end
	end
	if not found_index then
		func.toast("Meteor", "Couldn't find a train!")
	end
end)

menu.toggle_loop(train_controls, "Train Key Control", {}, "", function()
	local TrainSpeed = VEHICLE.GET_VEHICLE_ESTIMATED_MAX_SPEED(entities.get_user_vehicle_as_handle(false))
	util.yield(10)
		if PED.IS_PED_IN_ANY_TRAIN(players.user_ped()) then
			local New_Request = false
			if PAD.IS_DISABLED_CONTROL_PRESSED(2, 32) then
				TrainSpeed = TrainSpeed + 10
				New_Request = true
			end
			if PAD.IS_DISABLED_CONTROL_PRESSED(2, 33) then
				TrainSpeed = TrainSpeed - 20
				New_Request = true
			end
			if New_Request then
				VEHICLE.SET_TRAIN_SPEED(entities.get_user_vehicle_as_handle(false), TrainSpeed)
				VEHICLE.SET_TRAIN_CRUISE_SPEED(entities.get_user_vehicle_as_handle(false), TrainSpeed)
			end
		end
end)

menu.toggle_loop(train_controls, "Halt Train", {}, "", function()
	max_speed = VEHICLE.GET_VEHICLE_ESTIMATED_MAX_SPEED(entities.get_user_vehicle_as_handle(false))
		if PED.IS_PED_IN_ANY_TRAIN(players.user_ped()) then
			VEHICLE.SET_TRAIN_SPEED(entities.get_user_vehicle_as_handle(false), 0.0)
			VEHICLE.SET_TRAIN_CRUISE_SPEED(entities.get_user_vehicle_as_handle(false), 0.0)
		end
	util.yield(0)
end, function()
	VEHICLE.SET_TRAIN_SPEED(entities.get_user_vehicle_as_handle(false), max_speed)
	VEHICLE.SET_TRAIN_CRUISE_SPEED(entities.get_user_vehicle_as_handle(false), max_speed)
end)

menu.action(train_controls, "Force Leave Train", {}, "", function()
	if PED.IS_PED_IN_ANY_TRAIN(players.user_ped()) then
		TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
	end
end)

menu.toggle_loop(train_controls, "Derail", {}, "", function()
	if PED.IS_PED_IN_ANY_TRAIN(players.user_ped()) then
		max_speed = VEHICLE.GET_VEHICLE_ESTIMATED_MAX_SPEED(entities.get_user_vehicle_as_handle(false))
		VEHICLE.SET_RENDER_TRAIN_AS_DERAILED(entities.get_user_vehicle_as_handle(false), true)
		VEHICLE.SET_TRAIN_SPEED(entities.get_user_vehicle_as_handle(false), 0.0)
		VEHICLE.SET_TRAIN_CRUISE_SPEED(entities.get_user_vehicle_as_handle(false), 0.0)
	end
end, function()
		VEHICLE.SET_RENDER_TRAIN_AS_DERAILED(entities.get_user_vehicle_as_handle(false), false)
		VEHICLE.SET_TRAIN_SPEED(entities.get_user_vehicle_as_handle(false), max_speed)
		VEHICLE.SET_TRAIN_CRUISE_SPEED(entities.get_user_vehicle_as_handle(false), max_speed)
end)

menu.toggle_loop(train_controls, "Disable Random Train Spawning", {}, "", function()
	util.yield(0)
	VEHICLE.SET_DISABLE_RANDOM_TRAINS_THIS_FRAME(true)
end)

-----------------
--WORLD OPTIONS--
-----------------
menu.toggle_loop(world_options, "Unload Map", {}, "", function()
	STREAMING.SET_FOCUS_POS_AND_VEL(-8292.664, -4596.8257, 14358.0, 0.0, 0.0, 0.0)
	local pos = players.get_position(players.user())
	STREAMING.REQUEST_ADDITIONAL_COLLISION_AT_COORD(pos.x, pos.y, pos.z)
	util.yield(0)
end, function()
	STREAMING.CLEAR_FOCUS()
end)

local entity_control_list = menu.list(world_options, "Entity Control")
local control_peds_list = menu.list(entity_control_list, "Peds")

menu.toggle_loop(control_peds_list, "Disable Ped Spawning", {}, "This should take affect but i dont really know.", function()
	PED.SET_PED_DENSITY_MULTIPLIER_THIS_FRAME(0.0)
	util.yield(0)
end)

local control_Vehicles_list = menu.list(entity_control_list, "Vehicles")

menu.toggle_loop(control_Vehicles_list, "Disable Vehicle Spawning", {}, "This should take affect but i dont really know.", function()
	VEHICLE.SET_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME(0.0)
	util.yield(0)
end)

local control_objects_list = menu.list(entity_control_list, "Objects")
local clear_area_list = menu.list(control_objects_list, "Clear Area")

local clear_radius = 50
menu.slider(clear_area_list, "Clear Area Radius", {}, "Counts for all clears.", 10, 1000, 50, 10, function(count)
	clear_radius = count
end)
--full clear--
menu.action(clear_area_list, "Full Clear", {}, "", function()
	menu.trigger_commands("cleararea")
end)
--peds--
menu.action(clear_area_list, "Clear AreaClear Area Of Peds", {}, "", function()
	local pos = players.get_position(players.user())
	MISC.CLEAR_AREA_OF_PEDS(pos.x, pos.y, pos.z, clear_radius, 0)
end)
menu.toggle_loop(clear_area_list, "Clear AreaClear Area Of Peds", {}, "", function()
	local pos = players.get_position(players.user())
	MISC.CLEAR_AREA_OF_PEDS(pos.x, pos.y, pos.z, clear_radius, 0)
	util.yield(1000)
end)
--vehicles--
menu.action(clear_area_list, "Clear Area Of Vehicles", {}, "", function()
	local pos = players.get_position(players.user())
	MISC.CLEAR_AREA_OF_VEHICLES(pos.x, pos.y, pos.z, clear_radius, false, false, false, false, false, false, false)
end)
menu.toggle_loop(clear_area_list, "Clear Area Of Vehicles", {}, "", function()
	local pos = players.get_position(players.user())
	MISC.CLEAR_AREA_OF_VEHICLES(pos.x, pos.y, pos.z, clear_radius, false, false, false, false, false, false, false)
	util.yield(1000)
end)
--objects--
menu.action(clear_area_list, "Clear Area Of Objects", {}, "", function()
	local pos = players.get_position(players.user())
	MISC.CLEAR_AREA_OF_OBJECTS(pos.x, pos.y, pos.z, clear_radius, 0)
end)
menu.toggle_loop(clear_area_list, "Clear Area Of Objects", {}, "", function()
	local pos = players.get_position(players.user())
	MISC.CLEAR_AREA_OF_OBJECTS(pos.x, pos.y, pos.z, clear_radius, 0)
	util.yield(1000)
end)
--cops--
menu.action(clear_area_list, "Clear Area Of Cops", {}, "", function()
	local pos = players.get_position(players.user())
	MISC.CLEAR_AREA_OF_COPS(pos.x, pos.y, pos.z, clear_radius, 0)
end)
menu.toggle_loop(clear_area_list, "Clear Area Of Cops", {}, "", function()
	local pos = players.get_position(players.user())
	MISC.CLEAR_AREA_OF_COPS(pos.x, pos.y, pos.z, clear_radius, 0)
	util.yield(1000)
end)
--projectiles--
menu.action(clear_area_list, "Clear Area Of Projectiles", {}, "", function()
	local pos = players.get_position(players.user())
	MISC.CLEAR_AREA_OF_PROJECTILES(pos.x, pos.y, pos.z, clear_radius, 0)
end)
menu.toggle_loop(clear_area_list, "Clear Area Of Projectiles", {}, "", function()
	local pos = players.get_position(players.user())
	MISC.CLEAR_AREA_OF_PROJECTILES(pos.x, pos.y, pos.z, clear_radius, 0)
	util.yield(1000)
end)
--
local bounce_height = 15
menu.slider(world_options, "Bounce Height", {}, "", 1, 100, 15, 1, function(count)
	bounce_height = count
end)

menu.toggle_loop(world_options, "Bouncy Water", {}, "", function()
	if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
		if ENTITY.IS_ENTITY_IN_WATER(entities.get_user_vehicle_as_handle(false)) then
			local vel = v3.new(ENTITY.GET_ENTITY_VELOCITY(entities.get_user_vehicle_as_handle(false)))
			ENTITY.SET_ENTITY_VELOCITY(entities.get_user_vehicle_as_handle(false), vel.x, vel.y, bounce_height)
		end
	else
		if ENTITY.IS_ENTITY_IN_WATER(players.user_ped()) then
			local vel = v3.new(ENTITY.GET_ENTITY_VELOCITY(entities.get_user_vehicle_as_handle(false)))
			ENTITY.SET_ENTITY_VELOCITY(players.user_ped(), vel.x, vel.y, bounce_height)
		end
	end
end)

--removed all weather and time options bc i dont wanna mess with them--
menu.toggle_loop(utilities_options, "Instant Respawn", {}, "", function()
	if util.is_session_started() then
		if ENTITY.IS_ENTITY_DEAD(players.user_ped()) then
			local Coords = v3.new()
			local pos = players.get_position(players.user())
			local forward_vect = ENTITY.GET_ENTITY_FORWARD_VECTOR(players.user_ped())
			MISC.FIND_SPAWN_POINT_IN_DIRECTION(pos.x, pos.y, pos.z, forward_vect.x, forward_vect.y, forward_vect.z, math.random(200.0, 400.0), Coords)
			if Coords ~= nil then
				NETWORK.NETWORK_RESURRECT_LOCAL_PLAYER(Coords.x, Coords.y, Coords.z, ENTITY.GET_ENTITY_HEADING(players.user_ped()), false, false, 0, 0, 0)
				util.yield(100)
			end
		end
	end
end)
--------------------
--WEAPON MODIFIERS--
--------------------
menu.toggle(weapon_modifiers_options, "Rapid Fire", {}, "", function(on)
	if on then
		menu.trigger_commands("rapidfire" .. " on")
	else
		menu.trigger_commands("rapidfire" .. " off")
	end
end)

menu.toggle(weapon_modifiers_options, "Vehicle Rapid Fire", {}, "", function(on)
	if on then
		menu.trigger_commands("vehiclerapidfire" .. " on")
	else
		menu.trigger_commands("vehiclerapidfire" .. " off")
	end
end)

menu.toggle_loop(weapon_modifiers_options, "Melee Knockback", {} , "", function()
	if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped()) then
		local pWeapon = memory.alloc_int()
		ENTITY.GET_ENTITY_PROOFS(players.user_ped(), proofs.bullet, proofs.fire, proofs.expl, proofs.coll, proofs.melee, proofs.steam, proofs.p7, proofs.drown)
		WEAPON.GET_CURRENT_PED_WEAPON(players.user_ped(), pWeapon, true)
		local weaponHash = memory.read_int(pWeapon)
		if WEAPON.IS_PED_ARMED(players.user_ped(), 1) or weaponHash == util.joaat("weapon_unarmed") then
			local pImpactCoords = v3.new()
			local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped(), false)
			if WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(players.user_ped(), pImpactCoords) then
				ENTITY.SET_ENTITY_PROOFS(players.user_ped(), proofs1.bullet1, proofs1.fire1, true, proofs1.coll1, proofs1.melee1, proofs1.steam1, proofs1.p71, proofs1.drown1)
				util.yield(0)
				FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z - 1.0, 29, 5.0, false, true, 0.0, true)
	
			elseif not FIRE.IS_EXPLOSION_IN_SPHERE(29, pos.x, pos.y, pos.z, 2.0) then
				ENTITY.SET_ENTITY_PROOFS(players.user_ped(), proofs.bullet1, proofs.fire1, proofs.expl1, proofs.coll1, proofs.melee1, proofs.steam1, proofs.p71, proofs.drown1)
			end
		end
	end
end)

local flamesize = 1
menu.slider(weapon_modifiers_options, "Flamethrower Size", {} , "", 1, 10, 1, 1, function(value)
	flamesize = value
end)

local flameThrower = {
	colour = {["r"] = 255/255, ["g"] = 127/255, ["b"] = 80/255}
}
menu.toggle_loop(weapon_modifiers_options, "Flamethrower", {}, "", function()
		if PAD.IS_DISABLED_CONTROL_PRESSED(2, 25) or PAD.IS_DISABLED_CONTROL_PRESSED(2, 24) then
		PLAYER.DISABLE_PLAYER_FIRING(players.user_ped(), true)
		    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("weap_xs_vehicle_weapons") do
			    STREAMING.REQUEST_NAMED_PTFX_ASSET("weap_xs_vehicle_weapons")
			    util.yield(0)
		    end
		GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_vehicle_weapons")
		    if flameThrower.ptfx == nil then
			    flameThrower.ptfx = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("muz_xs_turret_flamethrower_looping", WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(players.user_ped()), 0.8, 0, 0, 0, 0, 270.0, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(players.user_ped()), 'Gun_Nuzzle'), flamesize, false, false, false)
			    GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(flameThrower.ptfx, flameThrower.colour.r, flameThrower.colour.g, flameThrower.colour.b)
		    end
	    else
		    if not flameThrower.ptfx then return end
		    GRAPHICS.REMOVE_PARTICLE_FX(flameThrower.ptfx, true)
		    STREAMING.REMOVE_NAMED_PTFX_ASSET("weap_xs_vehicle_weapons")
		    flameThrower.ptfx = nil
		    return
        end
end)

local explosion_modifier_list = menu.list(weapon_modifiers_options, "Explosion Modifier")

local size_multiplier = 1
menu.slider(explosion_modifier_list, "Multiplier Amound", {} , "", 1, 200, 1, 5, function(value)
	size_multiplier = value
end)

menu.toggle_loop(explosion_modifier_list, "Size Multiplier", {}, "", function()
	for k,v in pairs(wep_hashes.all_weapon_hashes) do
		WEAPON.SET_WEAPON_AOE_MODIFIER(v.hash, size_multiplier / 10)
	end
	util.yield(10)
end, function()
	for k,v in pairs(wep_hashes.all_weapon_hashes) do
		WEAPON.SET_WEAPON_AOE_MODIFIER(v.hash, 1.0)
	end
end)

--it works so idc about the code--
local mine = {64, 65, 66, 67, 68}
local mine_features = {"Kenitic", "EMP", "Spike", "Slick", "Tar"}
local mines = 64
menu.list_action(explosion_modifier_list, "Mine's", {}, "", mine_features, function(mine_feat)
	mines = (mine[mine_feat])
end)

menu.toggle_loop(explosion_modifier_list, "Mine Impact Gun", {}, "", function()
	local hitCoords = v3.new()
	WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(players.user_ped(), hitCoords)
	FIRE.ADD_EXPLOSION(hitCoords.x, hitCoords.y, hitCoords.z + 1, mines or 64, 1, true, false, 0.5, false)
end)

menu.toggle_loop(explosion_modifier_list, "Orbital Strike Gun", {}, "", function()
	local last_hit_coords = v3.new()
	if WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(players.user_ped(), last_hit_coords) then
		ent_func.create_orbital_cannon_explosion(last_hit_coords)
	end
end)

menu.toggle_loop(explosion_modifier_list, "Nuke Gun", {}, "", function()
	if PED.IS_PED_SHOOTING(players.user_ped()) then
		local hash = util.joaat("prop_military_pickup_01")
		ent_func.request_model(hash)
		local player_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 5.0, 3.0)
		local dir = {}
		local c2 = {}
		  c2 = playr_func.get_offset_from_gameplay_camera(1000)
		  dir.x = (c2.x - player_pos.x) * 1000
		  dir.y = (c2.y - player_pos.y) * 1000
		  dir.z = (c2.z - player_pos.z) * 1000
		local nuke = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, player_pos.x, player_pos.y, player_pos.z, true, false, false)
		  ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(nuke, players.user_ped(), false)
		  ENTITY.APPLY_FORCE_TO_ENTITY(nuke, 0, dir.x, dir.y, dir.z, 0.0, 0.0, 0.0, 0, true, false, true, false, true)
		  ENTITY.SET_ENTITY_HAS_GRAVITY(nuke, true)

		  while not ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(nuke) and not ENTITY.IS_ENTITY_IN_WATER(nuke) do
			util.yield(0)
		  end
		local nukePos = ENTITY.GET_ENTITY_COORDS(nuke, true)
		entities.delete_by_handle(nuke)
		ent_func.create_nuke_explosion(nukePos)
	end
end)

local cam_dist_from_ped = 30
menu.slider(misc_options, "Change Cam Distance", {}, "", 1, 50, 30, 1, function (value)
	cam_dist_from_ped = value
end)

menu.toggle(misc_options, "GTA1 Mode", {}, "", function(on)
	if on then
		local player_pos = players.get_position(players.user())
		cam = CAM.CREATE_CAM_WITH_PARAMS("DEFAULT_SCRIPTED_CAMERA", player_pos.x, player_pos.y, player_pos.z, -90.0, 0.0, 0.0, 70.0, false, false)
		CAM.SET_CAM_ACTIVE(cam, true)
		CAM.RENDER_SCRIPT_CAMS(true, true, 0, true, true, 0)
		CAM.ATTACH_CAM_TO_ENTITY(cam, players.user_ped(), 0.0, 0.0, cam_dist_from_ped, false)
		while on do
			CAM.SET_CAM_ROT(cam, -90.0, 0.0, ENTITY.GET_ENTITY_HEADING(players.user_ped()), 2)
			util.yield(0)
		end
	end
	if not on then
		CAM.SET_CAM_ACTIVE(cam, false)
		CAM.RENDER_SCRIPT_CAMS(false, false, 0, false, false, false)
		CAM.DESTROY_CAM(cam, false)
	end
end)

local phone_number = {0, 1, 2, 3, 4}
local phone_features = {"Michael's Phone", "Trevor's Phone", "Franklin's Phone", "unk", "Prologue Phone"}
local phone = 0
menu.list_action(misc_options, "Phone's", {}, "", phone_features, function(phones)
	phone = (phone_number[phones])
end)

menu.toggle(misc_options, "Change Phone Style", {}, "", function(on)
	local is_open = false
	while on do
		if func.is_phone_open() then
			if phone ~= 3 then
				MOBILE.CREATE_MOBILE_PHONE(phone)
			end
			is_open = true
		elseif is_open then
			MOBILE.DESTROY_MOBILE_PHONE()
			is_open = false
		end
		util.yield(0)
	end
	if not on then
	MOBILE.CREATE_MOBILE_PHONE(0)
	MOBILE.DESTROY_MOBILE_PHONE()
	end
end)

menu.action(misc_options, "Freecam", {}, "", function()
	local path = menu.ref_by_path("Game>Camera>Freecam")
		menu.trigger_command(path, "")
end)

local fake_money_modifier_list = menu.list(misc_options, "Fake Money Modifier")

menu.toggle_loop(fake_money_modifier_list, "Display Current Balance", {}, "Only in online.", function()
	HUD.SET_MULTIPLAYER_WALLET_CASH()
	HUD.SET_MULTIPLAYER_BANK_CASH()
end, function()
	HUD.REMOVE_MULTIPLAYER_WALLET_CASH()
	HUD.REMOVE_MULTIPLAYER_BANK_CASH()
end)

local moneys_wallet = {100000, 250000, 500000, 750000, 1000000, 2147483647, math.random(2147483, 2147483647)}
local money_amound_wallet = {"$100k", "$250k", "$500k", "$750k", "$1000k", "2147483647", "Random"}
local money_wallet = 1000000
menu.list_action(fake_money_modifier_list, "Wallet Amount", {}, "", money_amound_wallet, function(money_am)
	money_wallet = (moneys_wallet[money_am])
end)
menu.toggle_loop(fake_money_modifier_list, "Wallet Money Loop", {}, "Only in online.", function()
	util.yield(100)
	HUD.CHANGE_FAKE_MP_CASH(money_wallet, 0)
end)


local moneys_bank = {100000, 250000, 500000, 750000, 1000000, 2147483647, math.random(2147483, 2147483647)}
local money_amound_bank = {"$100k", "$250k", "$500k", "$750k", "$1000k", "2147483647", "Random"}
local money_bank = 1000000
menu.list_action(fake_money_modifier_list, "Bank Amount", {}, "", money_amound_bank, function(money_am)
	money_bank = (moneys_bank[money_am])
end)
menu.toggle_loop(fake_money_modifier_list, "Bank Money Loop", {}, "", function()
	util.yield(100)
	HUD.CHANGE_FAKE_MP_CASH(0, money_bank)
end)
-------------------------------------------------
-------------------------------------------------
---------------------ONLINE----------------------
-------------------------------------------------
-------------------------------------------------
--all player options--
local malicious_list = menu.list(all_player_options, "Malicious")
local trolling_list = menu.list(all_player_options, "Trolling")

menu.action(trolling_list, "Earrape Everyone", {}, "", function()
	for i = 0, 100 do
		for _, pid in players.list(false, true, true) do
			local player_pos = players.get_position(pid)
			AUDIO.PLAY_SOUND_FROM_COORD(-1, "BED", player_pos.x, player_pos.y, player_pos.z, "WASTEDSOUNDS", true, 9999, false)
		end
	end
end)

menu.toggle(trolling_list, "Play Ringtone", {}, "", function(on)
	if on then
        	for _, pid in players.list(false, true, true) do
        	    if players.exists(pid) then
        		    AUDIO.PLAY_PED_RINGTONE("Remote_Ring", PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        	    end
        	end
        if not on then
        	for _, pid in players.list(false, true, true) do
        	    if players.exists(pid) then
        		    AUDIO.STOP_PED_RINGTONE(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid))
        	    end
            end
        end
	end
end)

menu.toggle(trolling_list, "POV: Black Friday", {}, "", function(on)
	MISC.SET_RIOT_MODE_ENABLED(on)
end)

--lobby opions--
menu.action(lobby_options, "Join New Session", {}, "", function()
	menu.trigger_commands("go public")
end)


menu.action(lobby_options, "Force To Singleplayer", {}, "", function()
	menu.trigger_commands("quittosp")
end)

menu.action(lobby_options, "Joining/Leaving Players", {}, "", function()
	local path = menu.ref_by_path("Online>Reactions>Player Join Reactions")
		menu.trigger_command(path, "")
end)

menu.action(lobby_options, "Player History", {}, "", function()
	local path = menu.ref_by_path("Online>Player History")
		menu.trigger_command(path, "")
end)

menu.toggle(lobby_options, "Block Join Requests", {}, "", function(on)
	if on then
		menu.trigger_commands("blockjoins" .. " on")
	else
		menu.trigger_commands("blockjoins" .. " off")
	end
end)

menu.toggle(lobby_options, "Block SH Migration", {}, "Only works when you are the host.", function(on)
	if util.is_session_started() and NETWORK.NETWORK_IS_HOST() then
		NETWORK.NETWORK_PREVENT_SCRIPT_HOST_MIGRATION()
	end
end)

menu.action(lobby_options, "Block Join Requests", {}, "", function()
	menu.trigger_commands("scripthost")
end)

local notify_seccion_activity_list = menu.list(lobby_options, "Notify Session Activity")

menu.toggle_loop(notify_seccion_activity_list, "Session Host Migration", {}, "", function()
	local sh
	local sh_name
	if util.is_session_started() then
		if players.get_host() ~= -1 and players.get_host() ~= nil then
			sh = players.get_host()
			sh_name = players.get_name(sh)
			util.yield(2000)
			if sh ~= -1 and sh ~= nil then
				local new_sh = players.get_host()
				if sh ~= new_sh and new_sh ~= -1 and new_sh ~= nil then
					if players.exists(new_sh) then
						func.toast("Meteor", "Session Host migrated from " .. sh_name .. " to " .. players.get_name(new_sh))
					end
				end
			end
		end
	end
end)

menu.toggle_loop(notify_seccion_activity_list, "Script Host Migration", {}, "", function()
	local sh
	local sh_name
	if util.is_session_started() then
		if players.get_script_host() ~= -1 and players.get_script_host() ~= nil then
			sh = players.get_script_host()
			sh_name = players.get_name(sh)
			util.yield(2000)
			if sh ~= -1 and sh ~= nil then
				local new_sh = players.get_script_host()
				if sh ~= new_sh and new_sh ~= -1 and new_sh ~= nil then
					if players.exists(new_sh) then
						func.toast("Meteor", "Script Host migrated from " .. sh_name .. " to " .. players.get_name(new_sh))
					end
				end
			end
		end
	end
end)

menu.toggle_loop(notify_seccion_activity_list, "Launcher Host Migration", {}, "", function()
    local sh
    local sh_name
    if util.is_session_started() then
		if NETWORK.NETWORK_GET_HOST_OF_SCRIPT("am_launcher", -1, 0) ~= -1 and NETWORK.NETWORK_GET_HOST_OF_SCRIPT("am_launcher", -1, 0) ~= nil then
			sh = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("am_launcher", -1, 0)
			sh_name = players.get_name(sh)
			util.yield(2000)
		    if sh ~= -1 and sh ~= nil then
				local new_sh = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("am_launcher", -1, 0)
			    if sh ~= new_sh and new_sh ~= -1 and new_sh ~= nil then
				    if players.exists(new_sh) then
					    func.toast("Meteor", "Launcher Host migrated from " .. sh_name .. " to " .. players.get_name(new_sh))
				    end
			    end
		    end
	    end
	end
end)



local editor_mode_list = menu.list(main_spawner, "Editor Mode")

editor_on = false
menu.toggle(editor_mode_list, "Enable Editor Mode", {}, "", function(on)
	editor_on = on
end)

menu.action(editor_mode_list, "Enter", {}, "", function()
	if editor_on then
		local Entity = ent_func.get_entity_player_is_aiming_at(players.user())
		if Entity ~= nil then
			if ENTITY.IS_ENTITY_A_PED(Entity) and PED.IS_PED_IN_ANY_VEHICLE(Entity, false) then
				Entity = PED.GET_VEHICLE_PED_IS_USING(Entity)
			end
			if ENTITY.IS_ENTITY_A_VEHICLE(Entity) then
				if ENTITY.IS_ENTITY_A_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(Entity, -1, true)) then
					PED.SET_PED_INTO_VEHICLE(players.user_ped(), Entity, -2)
				else
					ent_func.request_control(VEHICLE.GET_PED_IN_VEHICLE_SEAT(Entity, -1, true))
					ent_func.request_control(Entity)
					PED.SET_PED_INTO_VEHICLE(VEHICLE.GET_PED_IN_VEHICLE_SEAT(Entity, -1, true), Entity, -2)
					PED.SET_PED_INTO_VEHICLE(players.user_ped(), Entity, -1)
				end
			end
		end
	end
end)

menu.action(editor_mode_list, "Delete", {}, "", function()
	if editor_on then
		local Entity = ent_func.get_entity_player_is_aiming_at(players.user())
		if Entity ~= nil then
			if ENTITY.IS_ENTITY_A_PED(Entity) and PED.IS_PED_IN_ANY_VEHICLE(Entity, false) then
				Entity = PED.GET_VEHICLE_PED_IS_USING(Entity)
			end
			if ENTITY.IS_AN_ENTITY(Entity) then
				ent_func.request_control(Entity, 1000)
				entities.delete_by_handle(Entity)
			end
		end
	end
end)

menu.action(editor_mode_list, "Rape", {}, "", function()
	if editor_on then
		local Entity = ent_func.get_entity_player_is_aiming_at(players.user())
		if Entity ~= nil then
			if ENTITY.IS_AN_ENTITY(Entity) and ENTITY.IS_ENTITY_A_PED(Entity) and not PED.IS_PED_IN_ANY_VEHICLE(Entity) and not PED.IS_PED_A_PLAYER(Entity) and not ENTITY.IS_ENTITY_DEAD(Entity) then
				STREAMING.REQUEST_ANIM_DICT("rcmpaparazzo_2")
				STREAMING.REQUEST_ANIM_SET("shag_loop_poppy")
				while not STREAMING.HAS_ANIM_DICT_LOADED("rcmpaparazzo_2") do
					util.yield(0)
					STREAMING.REQUEST_ANIM_DICT("rcmpaparazzo_2")
					STREAMING.REQUEST_ANIM_SET("shag_loop_poppy")
				end
				if ent_func.request_control(Entity) then
					ENTITY.SET_ENTITY_HEADING(Entity, ENTITY.GET_ENTITY_HEADING(players.user_ped()))
					TASK.TASK_PLAY_ANIM(Entity, "rcmpaparazzo_2", "shag_loop_poppy", 1, 0, 20000, 9, 0, true, true, util.is_session_started())
					ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(players.user_ped(), Entity, false)
					local offset_coords = ent_func.offset_coords(ENTITY.GET_ENTITY_COORDS(Entity), ENTITY.GET_ENTITY_HEADING(Entity), 0.3, 3)
					ENTITY.SET_ENTITY_COORDS_NO_OFFSET(players.user_ped(), offset_coords.x , offset_coords.y, offset_coords.z, false, false, false)
					STREAMING.REQUEST_ANIM_DICT("rcmpaparazzo_2")
					STREAMING.REQUEST_ANIM_SET("shag_loop_a")
					while not STREAMING.HAS_ANIM_DICT_LOADED("rcmpaparazzo_2") do
						util.yield(0)
						STREAMING.REQUEST_ANIM_DICT("rcmpaparazzo_2")
						STREAMING.REQUEST_ANIM_SET("shag_loop_a")
					end
					ENTITY.FREEZE_ENTITY_POSITION(Entity, true)
					ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(players.user_ped(), Entity, false)
					for i = 1, 40 do
						ENTITY.SET_ENTITY_COORDS_NO_OFFSET(players.user_ped(), offset_coords.x , offset_coords.y, offset_coords.z, false, false, false)
						ENTITY.SET_ENTITY_HEADING(Entity, ENTITY.GET_ENTITY_HEADING(players.user_ped()) - 8)
						util.yield(10)
					end
					ENTITY.SET_ENTITY_COORDS_NO_OFFSET(players.user_ped(), offset_coords.x , offset_coords.y, offset_coords.z, false, false, false)
					ENTITY.SET_ENTITY_HEADING(players.user_ped(), ENTITY.GET_ENTITY_HEADING(Entity) - 8)
					TASK.TASK_PLAY_ANIM(players.user_ped(), "rcmpaparazzo_2", "shag_loop_a", 1, 0, 20000, 9, 0, true, true, util.is_session_started())
					func.toast("Meteor", "Get some bitches smh")
					local time = util.current_time_millis() + 20000
					while time > util.current_time_millis() and not ENTITY.IS_ENTITY_DEAD(players.user_ped()) and not ENTITY.IS_ENTITY_DEAD(Entity) do
						if ENTITY.IS_ENTITY_PLAYING_ANIM(Entity, "rcmpaparazzo_2", "shag_loop_poppy", 3) then
							if math.random(1, 100) == 1 then
								AUDIO.PLAY_PAIN(Entity, math.random(6, 7), 0, 0)
							end
						end
						ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(players.user_ped(), Entity, true)
						util.yield(0)
					end
					ENTITY.FREEZE_ENTITY_POSITION(Entity, false)
					TASK.STOP_ANIM_TASK(Entity, "rcmpaparazzo_2", "shag_loop_poppy", 1.0)
					TASK.CLEAR_PED_TASKS(Entity)
					TASK.CLEAR_PED_SECONDARY_TASK(Entity)
					TASK.STOP_ANIM_TASK(players.user_ped(), "rcmpaparazzo_2", "shag_loop_a", 1.0)
					TASK.CLEAR_PED_TASKS(players.user_ped())
					TASK.CLEAR_PED_SECONDARY_TASK(players.user_ped())
				end
			end
		end
	end
end)

menu.toggle(editor_mode_list, "Remote Spectate", {}, "", function(on)
	if on then
		IsRemoteControllingVehicle = false
		if editor_on then
			local Entity = ent_func.get_entity_player_is_aiming_at(players.user())
			if Entity ~= nil then
				if ENTITY.IS_ENTITY_A_PED(Entity) and PED.IS_PED_IN_ANY_VEHICLE(Entity) then
					Entity = PED.GET_VEHICLE_PED_IS_USING(Entity)
				end
				if ENTITY.IS_AN_ENTITY(Entity) then
					IsRemoteControllingVehicle = true
					local ent_coords = ENTITY.GET_ENTITY_COORDS(Entity)
					RemoteControlCam = CAM.CREATE_CAM_WITH_PARAMS("DEFAULT_SCRIPTED_CAMERA", ent_coords.x, ent_coords.y, ent_coords.z, 0.0, 0.0, 0.0, 70.0, false, false)
					CAM.SET_CAM_ACTIVE(RemoteControlCam, true)
					CAM.RENDER_SCRIPT_CAMS(true, true, 0, true, true, 0)
					CAM.ATTACH_CAM_TO_ENTITY(RemoteControlCam, Entity, 0.0, -12.0, 5.0, true)
					func.toast("Meteor", "Spectating Entity")
					while on do
						local ent_rot = ENTITY.GET_ENTITY_ROTATION(Entity)
						CAM.SET_CAM_ROT(RemoteControlCam, ent_rot.x, ent_rot.y, ent_rot.z, 2)
						util.yield(0)
				    end
				end
			end
		end
	end
	if not on then
		CAM.SET_CAM_ACTIVE(RemoteControlCam, false)
		CAM.RENDER_SCRIPT_CAMS(false, false, 0, false, false, false)
		CAM.DESTROY_CAM(RemoteControlCam, false)
		IsRemoteControllingVehicle = false
	end
end)


menu.toggle_loop(editor_mode_list, "Quick Entity Actions", {}, "", function()
	if PLAYER.IS_PLAYER_FREE_AIMING(players.user()) then
		local controls_entity_aimed_at = ent_func.get_entity_player_is_aiming_at(players.user())
		if ENTITY.IS_ENTITY_A_PED(controls_entity_aimed_at) and not PED.IS_PED_IN_ANY_VEHICLE(controls_entity_aimed_at) and not PED.IS_PED_A_PLAYER(controls_entity_aimed_at) then
			func.SF_PED_ACTION()
			if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 323) then
				ent_func.request_control(controls_entity_aimed_at)
				ent_func.hard_remove_entity(controls_entity_aimed_at)
			elseif PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 304) then
				ent_func.request_control(controls_entity_aimed_at)
				util.create_tick_handler(function()
					if ENTITY.IS_ENTITY_DEAD(controls_entity_aimed_at, true) then
						while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_rcbarry1") do
							STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry1")
							util.yield(0)
						end
						local pos = ENTITY.GET_ENTITY_COORDS(controls_entity_aimed_at)
						GRAPHICS.USE_PARTICLE_FX_ASSET("scr_rcbarry1")
						GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_alien_teleport", pos.x, pos.y, pos.z-2, 0, 0, 0, 4, true, true, true)
						util.yield(1000)
						PED.RESURRECT_PED(controls_entity_aimed_at)
						TASK.CLEAR_PED_TASKS_IMMEDIATELY(controls_entity_aimed_at)
						ENTITY.SET_ENTITY_COLLISION(controls_entity_aimed_at, true, true)
						for i = 1, 500 do
							TASK.CLEAR_PED_TASKS_IMMEDIATELY(controls_entity_aimed_at)
						end
						util.yield(100)
						local health = PED.GET_PED_MAX_HEALTH(controls_entity_aimed_at)
						PED.SET_PED_MAX_HEALTH(controls_entity_aimed_at, health)
						util.yield(100)
						PED.CLEAR_PED_BLOOD_DAMAGE(controls_entity_aimed_at)
						STREAMING.REMOVE_NAMED_PTFX_ASSET("scr_rcbarry1")
					end
				end)
			elseif PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 29) then
				util.copy_to_clipboard(ENTITY.GET_ENTITY_MODEL(controls_entity_aimed_at))
				func.toast("Meteor","Copied Hash! - " .. ENTITY.GET_ENTITY_MODEL(controls_entity_aimed_at))
			elseif PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 311) then
				util.create_tick_handler(function()
					local time = util.current_time_millis() + 120000
					while time > util.current_time_millis() and not ENTITY.IS_ENTITY_DEAD(controls_entity_aimed_at) do
						PED.SET_PED_TO_RAGDOLL(controls_entity_aimed_at, 1000, 1000, 0, false, false, false)
						util.yield(0)
					end
				end)
			elseif PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 183) then
				ent_func.request_control(controls_entity_aimed_at)
				PED.SET_PED_TO_RAGDOLL(controls_entity_aimed_at, 1000, 1000, 0)
			elseif PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 324) then
				ent_func.request_control(controls_entity_aimed_at)
				TASK.CLEAR_PED_TASKS_IMMEDIATELY(controls_entity_aimed_at)
			end
		elseif ENTITY.IS_ENTITY_A_PED(controls_entity_aimed_at) and not PED.IS_PED_IN_ANY_VEHICLE(controls_entity_aimed_at) and PED.IS_PED_A_PLAYER(controls_entity_aimed_at) then
			local controls_entity_aimed_at = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(controls_entity_aimed_at)
			func.SF_PLAYER_ACTION()
			if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 29) then
					menu.trigger_commands(("kick"..players.get_name(controls_entity_aimed_at)))
			elseif PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 324) then
				TASK.CLEAR_PED_TASKS_IMMEDIATELY(controls_entity_aimed_at)
			end
		elseif ENTITY.IS_ENTITY_A_PED(controls_entity_aimed_at) and PED.IS_PED_IN_ANY_VEHICLE(controls_entity_aimed_at) then
			local controls_entity_aimed_at = PED.GET_VEHICLE_PED_IS_USING(controls_entity_aimed_at)
			func.SF_VEHICLE_PED_ACTION()
			if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 323) then
				ent_func.request_control(controls_entity_aimed_at)
				ent_func.hard_remove_entity(controls_entity_aimed_at)
			elseif PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 29) then
				util.copy_to_clipboard(ENTITY.GET_ENTITY_MODEL(controls_entity_aimed_at))
				func.toast("Meteor","Copied Hash! - " .. ENTITY.GET_ENTITY_MODEL(controls_entity_aimed_at))
			elseif PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 306) then
				ent_func.request_control(controls_entity_aimed_at)
				VEHICLE.SET_VEHICLE_ENGINE_HEALTH(controls_entity_aimed_at, -1)
			elseif PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 183) then
				ent_func.request_control(controls_entity_aimed_at)
				VEHICLE.SET_VEHICLE_ENGINE_HEALTH(controls_entity_aimed_at, -1)
				VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(controls_entity_aimed_at, -1)
			elseif PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 304) then
				if PED.IS_PED_A_PLAYER(VEHICLE.GET_PED_IN_VEHICLE_SEAT(controls_entity_aimed_at, -1)) then
					PED.SET_PED_INTO_VEHICLE(players.user_ped(), controls_entity_aimed_at, -2)
				else
					ent_func.request_control(VEHICLE.GET_PED_IN_VEHICLE_SEAT(controls_entity_aimed_at, -1))
					ent_func.request_control(controls_entity_aimed_at)
					PED.SET_PED_INTO_VEHICLE(VEHICLE.GET_PED_IN_VEHICLE_SEAT(controls_entity_aimed_at, -1), controls_entity_aimed_at, -2)
					PED.SET_PED_INTO_VEHICLE(players.user_ped(), controls_entity_aimed_at, -1)
				end
			end
			if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 324) then
				ENTITY.FREEZE_ENTITY_POSITION(controls_entity_aimed_at, true)
			else
				ENTITY.FREEZE_ENTITY_POSITION(controls_entity_aimed_at, false)
			end
		elseif ENTITY.IS_ENTITY_A_VEHICLE(controls_entity_aimed_at) then
			func.SF_VEHICLE_ACTION()
			if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 323) then
				ent_func.request_control(controls_entity_aimed_at)
				ent_func.hard_remove_entity(controls_entity_aimed_at)
			elseif PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 29) then
				util.copy_to_clipboard(ENTITY.GET_ENTITY_MODEL(controls_entity_aimed_at))
				func.toast("Meteor","Copied Hash! - " .. ENTITY.GET_ENTITY_MODEL(controls_entity_aimed_at))
			elseif PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 306) then
				ent_func.request_control(controls_entity_aimed_at)
				VEHICLE.SET_VEHICLE_ENGINE_HEALTH(controls_entity_aimed_at, -1)
			elseif PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 183) then
				ent_func.request_control(controls_entity_aimed_at)
				VEHICLE.SET_VEHICLE_ENGINE_HEALTH(controls_entity_aimed_at, -1)
				VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(controls_entity_aimed_at, -1)
			elseif PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 304) then
				if PED.IS_PED_A_PLAYER(VEHICLE.GET_PED_IN_VEHICLE_SEAT(controls_entity_aimed_at, -1)) then
					PED.SET_PED_INTO_VEHICLE(players.user_ped(), controls_entity_aimed_at, -2)
				else
					ent_func.request_control(VEHICLE.GET_PED_IN_VEHICLE_SEAT(controls_entity_aimed_at, -1))
					ent_func.request_control(controls_entity_aimed_at)
					PED.SET_PED_INTO_VEHICLE(VEHICLE.GET_PED_IN_VEHICLE_SEAT(controls_entity_aimed_at, -1), controls_entity_aimed_at, -2)
					PED.SET_PED_INTO_VEHICLE(players.user_ped(), controls_entity_aimed_at, -1)
				end
			end
			if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 324) then
				ENTITY.FREEZE_ENTITY_POSITION(controls_entity_aimed_at, true)
			else
				ENTITY.FREEZE_ENTITY_POSITION(controls_entity_aimed_at, false)
			end
		elseif ENTITY.IS_ENTITY_AN_OBJECT(controls_entity_aimed_at) then
			func.SF_OBJECT_ACTION()
			if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 323) then
				ent_func.request_control(controls_entity_aimed_at)
				ent_func.hard_remove_entity(controls_entity_aimed_at)
			elseif PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 29) then
				util.copy_to_clipboard(ENTITY.GET_ENTITY_MODEL(controls_entity_aimed_at))
				func.toast("Meteor","Copied Hash! - " .. ENTITY.GET_ENTITY_MODEL(controls_entity_aimed_at))
			end
		end
	end
end)

local entity_sort = 1
local entity_input = "u_m_y_zombie_01"
menu.text_input(main_spawner, "Spawn Entity", {"Enter Hash Model"}, "", function(input)
	entity_input = input
end, "u_m_y_zombie_01")

local entity_spawn_features = {"Ped", "Vehicle", "Object", "World Object"}
menu.textslider(main_spawner, "Select Entity Sort", {}, "", entity_spawn_features, function(index, name)
	entity_sort = index
end)

menu.action(main_spawner, "Spawn Entity", {}, "", function()
	local entity = util.joaat(entity_input)
	if STREAMING.IS_MODEL_VALID(entity) then
		ent_func.request_model(entity)
		if entity_sort == 1 then
			entities.create_ped(0, entity, ent_func.offset_coords(players.get_position(players.user()), ENTITY.GET_ENTITY_HEADING(players.user()), 5, 1), ENTITY.GET_ENTITY_HEADING(players.user()))
			func.toast("Meteor", "Successfully spawned ped (" .. entity .. ")")
		elseif entity_sort == 2 then
			entities.create_vehicle(entity, ent_func.offset_coords(players.get_position(players.user()), ENTITY.GET_ENTITY_HEADING(players.user()), 5, 1), ENTITY.GET_ENTITY_HEADING(players.user()))
			func.toast("Meteor", "Successfully spawned vehicle (" .. entity .. ")")
		elseif entity_sort == 3 then
			entities.create_object(entity, ent_func.offset_coords(players.get_position(players.user()), ENTITY.GET_ENTITY_HEADING(players.user()), 5, 1))
			func.toast("Meteor", "Successfully spawned object (" .. entity .. ")")
		end
	end
end)

menu.action(main_settings, "Check for Update", {}, "The script will automatically check for updates at most daily, but you can manually check using this option anytime.", function()
    auto_update_config.check_interval = 0
    if auto_updater.run_auto_update(auto_update_config) then
        util.toast("No updates found")
    end
end)
menu.action(main_settings, "Clean Reinstall", {}, "Force an update to the latest version, regardless of current version.", function()
    auto_update_config.clean_reinstall = true
    auto_updater.run_auto_update(auto_update_config)
end)

----------------------------------------------------------------------------------------------------------
--END SELF OPTIONS----------------------------------------------------------------------------------------
--BEGIN PLAYERS OPTIONS-----------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

player_menu_actions = function(pid)
menu.divider(menu.player_root(pid), "Meteor")
local player_options = menu.list(menu.player_root(pid), "Player Options")
local trolling_options = menu.list(menu.player_root(pid), "Trolling")

menu.action(player_options, "Force TP", {}, "", function()
	menu.trigger_commands("summon"..players.get_name(pid))
end)

menu.action(trolling_options, "Atomize", {}, "", function()
	for i = 1, 30 do
		local pos = players.get_position(pid)
		FIRE.ADD_EXPLOSION(pos.x + math.random(-2, 2), pos.y + math.random(-2, 2), pos.z + math.random(-2, 2), 70, 1, true, false, 0.2, false)
		util.yield(math.random(0, 1))
	end
end)

menu.toggle(trolling_options, "Mugger Loop", {}, "", function(on)
	if on then
		menu.trigger_commands("mugloop".. players.get_name(pid).. " on")
	end
	if not on then
		menu.trigger_commands("mugloop".. players.get_name(pid).. " off")
	end
end)

end
players.on_join(player_menu_actions)
players.dispatch_on_join()

