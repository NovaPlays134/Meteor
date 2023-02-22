
local functions = {}

function functions.convert_value(value)
	if value == 1 then
		return true
	else 
		return false
	end
end

function functions.is_phone_open()
	if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(util.joaat("cellphone_flashhand")) > 0 or memory.script_global(20266 + 1) > 3 then
		return true
	else
		return false
	end
end

local function splitter(input)
    local words = {}
    for word in input:gmatch("%w+") do
      table.insert(words, word)
    end
    return words
end

--credits to not thonk for making this function and letting me use it--
local function cut_string_to_length(input, length, fontSize)
    input = splitter(input)
    local output = {}
    local line = ""
    for i, word in ipairs(input) do
        if directx.get_text_size(line..word, fontSize) >= length then
            if directx.get_text_size(word, fontSize) > length then
                while directx.get_text_size(word , fontSize) > length do
                    local word_lenght = string.len(word)
                    for x = 1, word_lenght, 1 do
                        if directx.get_text_size(line..string.sub(word ,1, x), fontSize) > length then
                            output[#output+1] = line..string.sub(word, 1, x - 1)
                            line = ""
                            word = string.sub(word, x, word_lenght)
                            break
                        end
                    end
                end
            else
                output[#output+1] =  line
                line = ""
            end
        end
        if i == #input then
            output[#output+1] = line..word
        end
        line = line..word.." "
    end
    return table.concat(output, "\n")
end


function functions.toast(value1, value2)
    util.create_thread(function()
        local spawnX_pos = 0.9
        local text1 = cut_string_to_length(value1, 0.15, 0.55)
        local text2 = cut_string_to_length(value2, 0.15, 0.48)
        local get_text1_width, get_text1_height = directx.get_text_size(text1, 0.55)
        local get_text2_width, get_text2_height = directx.get_text_size(text2, 0.48)

        local rect_height = get_text1_height+get_text2_height + 0.02
        local text1_pos = spawnX_pos + (rect_height/4.95)
        local text2_pos = spawnX_pos + (rect_height/1.6)

        local l = 1010
        while l > 850 do
            for j = 1, 195, 5 do
                directx.draw_rect(l/1000, spawnX_pos, 0.16, rect_height, {r = 0, g = 0, b = 0, a = j/255})
                directx.draw_rect(l/1000, spawnX_pos, 0.002, rect_height, {r = 1, g = 1, b = 1, a = j/255})
                directx.draw_text((l+10)/1000, text1_pos, text1, ALIGN_CENTRE_LEFT, 0.55, {r = 1, g = 1, b = 1, a = j/255}, false)
                directx.draw_text((l+10)/1000, text2_pos, text2, ALIGN_CENTRE_LEFT, 0.48, {r = 1, g = 1, b = 1, a = j/255}, false)
                util.yield(0)
                l = l - 5
            end
        end

        for i = 1, 220 do
            directx.draw_rect(0.82, spawnX_pos, 0.16, rect_height, {r = 0, g = 0, b = 0, a = 195/255})
            directx.draw_rect(0.82, spawnX_pos, 0.002, rect_height, {r = 1, g = 1, b = 1, a = 195/255})
            directx.draw_text(0.825, text1_pos, text1, ALIGN_CENTRE_LEFT, 0.55, {r = 1, g = 1, b = 1, a = 1}, false)
            directx.draw_text(0.825, text2_pos, text2, ALIGN_CENTRE_LEFT, 0.48, {r = 1, g = 1, b = 1, a = 1}, false)
            util.yield(0)
        end

        local k = 850
        while k < 900 do
            for j = 195, 1, -5 do
                directx.draw_rect(k/1000, spawnX_pos, 0.16, rect_height, {r = 0, g = 0, b = 0, a = j/255})
                directx.draw_rect(k/1000, spawnX_pos, 0.002, rect_height, {r = 1, g = 1, b = 1, a = j/255})
                directx.draw_text((k+10)/1000, text1_pos, text1, ALIGN_CENTRE_LEFT, 0.55, {r = 1, g = 1, b = 1, a = j/255}, false)
                directx.draw_text((k+10)/1000, text2_pos, text2, ALIGN_CENTRE_LEFT, 0.48, {r = 1, g = 1, b = 1, a = j/255}, false)
                util.yield(0)
                k = k + 5
            end
        end
    end)
end

--got from acjoker script credit to aaron--
local scaleform = require('ScaleformLib')
local sf = scaleform('instructional_buttons')
local function Hudhide()
    HUD.HIDE_HUD_COMPONENT_THIS_FRAME(6)
    HUD.HIDE_HUD_COMPONENT_THIS_FRAME(7)
    HUD.HIDE_HUD_COMPONENT_THIS_FRAME(8)
    HUD.HIDE_HUD_COMPONENT_THIS_FRAME(9)
---@diagnostic disable-next-line: param-type-mismatch
    memory.write_int(memory.script_global(1645739+1121), 1)
    sf.CLEAR_ALL()
    sf.TOGGLE_MOUSE_BUTTONS(false)
end

function functions.SF_PED_ACTION()
    Hudhide()
    sf.SET_DATA_SLOT(5,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 323, true), "| Ped |     Delete |")
    sf.SET_DATA_SLOT(4,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 304, true), " Resurrect |")
	sf.SET_DATA_SLOT(3,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 29, true), " Copy Hash |")
	sf.SET_DATA_SLOT(2,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 311, true), " Stroke |")
	sf.SET_DATA_SLOT(1,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 183, true), " Ragdoll |")
	sf.SET_DATA_SLOT(0,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 324, true), " Clear Tasks")
    sf.DRAW_INSTRUCTIONAL_BUTTONS()
    sf:draw_fullscreen()
end

function functions.SF_PLAYER_ACTION()
    Hudhide()
    sf.SET_DATA_SLOT(1,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 29, true), "| Player |     Kick |")
	sf.SET_DATA_SLOT(0,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 324, true), " Freeze |")
    sf.DRAW_INSTRUCTIONAL_BUTTONS()
    sf:draw_fullscreen()
end

function functions.SF_VEHICLE_PED_ACTION()
    Hudhide()
    sf.SET_DATA_SLOT(5,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 323, true), "| Vehicle With Ped |     Delete |")
    sf.SET_DATA_SLOT(4,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 29, true), " Copy Hash |")
	sf.SET_DATA_SLOT(3,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 306, true), " Engine |")
	sf.SET_DATA_SLOT(2,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 183, true), " Burn |")
	sf.SET_DATA_SLOT(1,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 304, true), " Enter |")
	sf.SET_DATA_SLOT(0,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 324, true), " Freeze |")
    sf.DRAW_INSTRUCTIONAL_BUTTONS()
    sf:draw_fullscreen()
end

function functions.SF_VEHICLE_ACTION()
    Hudhide()
    sf.SET_DATA_SLOT(5,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 323, true), "| Vehicle |     Delete |")
    sf.SET_DATA_SLOT(4,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 29, true), " Copy Hash |")
	sf.SET_DATA_SLOT(3,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 306, true), " Engine |")
	sf.SET_DATA_SLOT(2,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 183, true), " Burn |")
	sf.SET_DATA_SLOT(1,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 304, true), " Enter |")
	sf.SET_DATA_SLOT(0,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 324, true), " Freeze |")
    sf.DRAW_INSTRUCTIONAL_BUTTONS()
    sf:draw_fullscreen()
end

function functions.SF_OBJECT_ACTION()
    Hudhide()
    sf.SET_DATA_SLOT(1,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 323, true), "| Object |     Delete |")
	sf.SET_DATA_SLOT(0,PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(0, 29, true), " Copy Hash |")
    sf.DRAW_INSTRUCTIONAL_BUTTONS()
    sf:draw_fullscreen()
end

return functions