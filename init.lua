-- This mod provides the visible text on signs library used by Home Decor
-- and perhaps other mods at some point in the future.  Forked from thexyz's/
-- PilzAdam's original text-on-signs mod and rewritten by Vanessa Ezekowitz
-- and Diego Martinez

-- modif 202007 by cpc6128
-- caractere speciaux (1abcABC) remplace les caracteres entre les parentheses par des caracteres speciaux
-- (1 = choix de police 1 2 3 4 puis sortie avec )
-- couleur #a --> #w
local color_translate=function(color_in)
  local color_out = string.byte(string.upper(color_in))-65
  if color_out<0 or color_out>26 then color_out=15 end
  return color_out
end

local decal=0
local old_color="P"
-- textpos = {
--		{ delta = {entity position for 0° yaw}, exact yaw expression }
--		{ delta = {entity position for 180° yaw}, exact yaw expression }
--		{ delta = {entity position for 270° yaw}, exact yaw expression }
--		{ delta = {entity position for 90° yaw}, exact yaw expression }
-- }
-- Made colored metal signs optionals
local enable_colored_metal_signs = true

-- CWz's keyword interact mod uses this setting.
local current_keyword = minetest.settings:get("interact_keyword") or "iaccept"

monitor = {}
monitor.path = minetest.get_modpath(minetest.get_current_modname())
screwdriver = screwdriver or {}

local creative_enable = 1
-- Load support for intllib.
local S, NS = dofile(monitor.path .. "/intllib.lua")
monitor.gettext = S

-- text encoding
--dofile(signs_lib.path .. "/encoding.lua");

-- Initialize character texture cache
local ctexcache = {}

--[[
local wall_dir_change = {
	[0] = 4,
	0,
	5,
	1,
	2,
	3,
	0
}

signs_lib.wallmounted_rotate = function(pos, node, user, mode)
	if mode ~= screwdriver.ROTATE_FACE then return false end 
	minetest.swap_node(pos, { name = node.name, param2 = wall_dir_change[node.param2 % 6] })
	signs_lib.update_sign(pos,nil,nil,node)
	return true
end

signs_lib.facedir_rotate = function(pos, node, user, mode)
	if mode ~= screwdriver.ROTATE_FACE then return false end
if string.find(node.name,"spacengine") then return false end
	local newparam2 = (node.param2 %8) + 1
	if newparam2 == 5 then
		newparam2 = 6
	elseif newparam2 > 6 then
		newparam2 = 0
	end
	minetest.swap_node(pos, { name = node.name, param2 = newparam2 })
	signs_lib.update_sign(pos,nil,nil,node)
	return true
end

signs_lib.facedir_rotate_simple = function(pos, node, user, mode)
	if mode ~= screwdriver.ROTATE_FACE then return false end
	local newparam2 = (node.param2 %8) + 1
	if newparam2 > 3 then newparam2 = 0 end
	minetest.swap_node(pos, { name = node.name, param2 = newparam2 })
	signs_lib.update_sign(pos,nil,nil,node)
	return true
end
--]]

monitor.modpath = minetest.get_modpath("monitor")

local DEFAULT_TEXT_SCALE = {x=0.8, y=0.5}

monitor.regular_wall_sign_model = {
	nodebox = {
		type = "wallmounted",
		wall_side =   { -0.5,    -0.25,   -0.4375, -0.4375,  0.375,  0.4375 },
		wall_bottom = { -0.4375, -0.5,    -0.25,    0.4375, -0.4375, 0.375 },
		wall_top =    { -0.4375,  0.4375, -0.375,   0.4375,  0.5,    0.25 }
	},
	textpos = {
		nil,
		nil,
		{delta = { x =  0.41, y = 0.07, z =  0    }, yaw = math.pi / -2},
		{delta = { x = -0.41, y = 0.07, z =  0    }, yaw = math.pi / 2},
		{delta = { x =  0,    y = 0.07, z =  0.41 }, yaw = 0},
		{delta = { x =  0,    y = 0.07, z = -0.41 }, yaw = math.pi},
	}
}

monitor.metal_wall_sign_model = {
	nodebox = {
		type = "fixed",
		fixed = {-0.4375, -0.25, 0.4375, 0.4375, 0.375, 0.5}
	},
	textpos = {
		{delta = { x =  0,     y = 0.07, z =  0.41 }, yaw = 0},
		{delta = { x =  0.41,  y = 0.07, z =  0    }, yaw = math.pi / -2},
		{delta = { x =  0,     y = 0.07, z = -0.41 }, yaw = math.pi},
		{delta = { x = -0.41,  y = 0.07, z =  0    }, yaw = math.pi / 2},
	}
}

monitor.yard_sign_model = {
	nodebox = {
		type = "fixed",
		fixed = {
				{-0.4375, -0.25, -0.0625, 0.4375, 0.375, 0},
				{-0.0625, -0.5, -0.0625, 0.0625, -0.1875, 0},
		}
	},
	textpos = {
		{delta = { x =  0,    y = 0.07, z = -0.08 }, yaw = 0},
		{delta = { x = -0.08, y = 0.07, z =  0    }, yaw = math.pi / -2},
		{delta = { x =  0,    y = 0.07, z =  0.08 }, yaw = math.pi},
		{delta = { x =  0.08, y = 0.07, z =  0    }, yaw = math.pi / 2},
	}
}

monitor.hanging_sign_model = {
	nodebox = {
		type = "fixed",
		fixed = {
				{-0.4375, -0.3125, -0.0625, 0.4375, 0.3125, 0},
				{-0.4375, 0.25, -0.03125, 0.4375, 0.5, -0.03125},
		}
	},
	textpos = {
		{delta = { x =  0,    y = -0.02, z = -0.08 }, yaw = 0},
		{delta = { x = -0.08, y = -0.02, z =  0    }, yaw = math.pi / -2},
		{delta = { x =  0,    y = -0.02, z =  0.08 }, yaw = math.pi},
		{delta = { x =  0.08, y = -0.02, z =  0    }, yaw = math.pi / 2},
	}
}

monitor.sign_post_model = {
	nodebox = {
		type = "fixed",
		fixed = {
				{-0.4375, -0.25, -0.1875, 0.4375, 0.375, -0.125},
				{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125},
		}
	},
	textpos = {
		{delta = { x = 0,    y = 0.07, z = -0.2 }, yaw = 0},
		{delta = { x = -0.2, y = 0.07, z = 0    }, yaw = math.pi / -2},
		{delta = { x = 0,    y = 0.07, z = 0.2  }, yaw = math.pi},
		{delta = { x = 0.2,  y = 0.07, z = 0    }, yaw = math.pi / 2},
	}
}

-- the list of standard sign nodes

monitor.sign_node_list = {
	"monitor:screen_down",
	"monitor:screen_console",
	"monitor:screen_wall",
	"monitor:screen_up",
  "monitor:screen_led"
}

local default_sign, default_sign_image

-- infinite stacks

if not minetest.settings:get_bool("creative_mode") then
	monitor.expect_infinite_stacks = false
else
	monitor.expect_infinite_stacks = true
end

-- CONSTANTS

-- Path to the textures.
local TP = monitor.path .. "/textures"
-- Font file formatter
local CHAR_FILE = "%s_%02x.png"
-- Fonts path
local CHAR_PATH = TP .. "/" .. CHAR_FILE

-- Font name.
local font_name = "mnt"

-- Lots of overkill here. KISS advocates, go away, shoo! ;) -- kaeza

local PNG_HDR = string.char(0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)

-- check if a file does exist
-- to avoid reopening file after checking again
-- pass TRUE as second argument
local function file_exists(name, return_handle, mode)
	mode = mode or "r";
	local f = io.open(name, mode)
	if f ~= nil then
		if (return_handle) then
			return f
		end
		io.close(f) 
		return true 
	else 
		return false 
	end
end

-- Read the image size from a PNG file.
-- Returns image_w, image_h.
-- Only the LSB is read from each field!
local function read_image_size(filename)
	local f = file_exists(filename, true, "rb")
	-- file might not exist (don't crash the game)
	if (not f) then
		return 0, 0
	end
	f:seek("set", 0x0)
	local hdr = f:read(string.len(PNG_HDR))
	if hdr ~= PNG_HDR then
		f:close()
		return
	end
	f:seek("set", 0x13)
	local ws = f:read(1)
	f:seek("set", 0x17)
	local hs = f:read(1)
	f:close()
	return ws:byte(), hs:byte()
end

-- Set by build_char_db()
local LINE_HEIGHT
local SIGN_WIDTH
local COLORBGW, COLORBGH

-- Size of the canvas, in characters.
-- Please note that CHARS_PER_LINE is multiplied by the average character
-- width to get the total width of the canvas, so for proportional fonts,
-- either more or fewer characters may fit on a line.
local CHARS_PER_LINE = 30
local NUMBER_OF_LINES = 7

-- 6 rows, max 80 chars per, plus a bit of fudge to
-- avoid excess trimming (e.g. due to color codes)

local MAX_INPUT_CHARS = 244

-- This holds the individual character widths.
-- Indexed by the actual character (e.g. charwidth["A"])
local charwidth

-- helper functions to trim sign text input/output

local function trim_input(text)
	return text:sub(1, math.min(MAX_INPUT_CHARS, text:len()))
end

local function build_char_db()

	charwidth = { }

	-- To calculate average char width.
	local total_width = 0
	local char_count = 0

	for c = 32, 255 do  -- +nb nouveau charact
		local w, h = read_image_size(CHAR_PATH:format(font_name, c))
		if w and h then
			--local ch = string.char(c)
			charwidth[c] = w
			total_width = total_width + w
			char_count = char_count + 1
		end
	end
  
  for c = 288, 382 do  -- +nb nouveau charact
		local w, h = read_image_size(CHAR_PATH:format(font_name, c))
		if w and h then
			--local ch = string.char(c)
			charwidth[c] = w
			total_width = total_width + w
			char_count = char_count + 1
		end
	end
  
  for c = 829, 858 do  -- +nb nouveau charact
		local w, h = read_image_size(CHAR_PATH:format(font_name, c))
		if w and h then
			--local ch = string.char(c)
			charwidth[c] = w
			total_width = total_width + w
			char_count = char_count + 1
		end
	end

  for c = 554, 630 do  -- +nb nouveau charact
		local w, h = read_image_size(CHAR_PATH:format(font_name, c))
		if w and h then
			--local ch = string.char(c)
			charwidth[c] = w
			total_width = total_width + w
			char_count = char_count + 1
		end
	end

	COLORBGW, COLORBGH = read_image_size(TP.."/mnt_bg_n.png")
	assert(COLORBGW and COLORBGH, "error reading bg dimensions")
	LINE_HEIGHT = COLORBGH

	-- XXX: Is there a better way to calc this?
	SIGN_WIDTH = math.floor((total_width / char_count) * CHARS_PER_LINE)

end

local sign_groups = {choppy=2, dig_immediate=2}

local fences_with_sign = { }

-- some local helper functions

local function split_lines_and_words_old(text)
	local lines = { }
	local line = { }
	if not text then return end
	for word in text:gmatch("%S+") do
		if word == "|" then
			table.insert(lines, line)
			if #lines >= NUMBER_OF_LINES then break end
			line = { }
		elseif word == "\\|" then
			table.insert(line, "|")
		else
			table.insert(line, word)
		end
	end
	table.insert(lines, line)
	return lines
end

local function split_lines_and_words(text)
	if not text then return end
	text = string.gsub(text, "@KEYWORD", current_keyword)
	local lines = { }
	for _, line in ipairs(text:split("\n")) do
		table.insert(lines, line:split(" "))
	end
	return lines
end

local math_max = math.max

local function fill_line(x, y, w, c)
	c = c or "C"

	local tex = { }
	for xx = 0, math.max(0, w), COLORBGW do
		table.insert(tex, (":%d,%d=mnt_bg_%s.png"):format(x + xx, y, c))
	end
	return table.concat(tex)
end

-- make char texture file name
-- if texture file does not exist use fallback texture instead
local function char_tex(font_name, ch)
  local c = ch:byte()+decal
	if ctexcache[font_name.. tonumber(c)] then
		return ctexcache[font_name.. tonumber(c)], true
	else
    
		local exists, tex = file_exists(CHAR_PATH:format(font_name, c))
		if exists and c ~= 14 then
			tex = CHAR_FILE:format(font_name, c)
		else
			tex = CHAR_FILE:format(font_name, 0x0)
		end
    
		ctexcache[font_name.. tonumber(c)] = tex
		return tex, exists
	end
end

local function make_line_texture(line, lineno, pos)

	local width = 0
	local maxw = 0

	local words = { }
	local default_color = old_color

	local cur_color = color_translate(default_color)
  
	-- We check which chars are available here.
	for word_i, word in ipairs(line) do
		local chars = { }
		local ch_offs = 0
		local word_l = #word
		local i = 1
    local out=0
--minetest.log(word)
		while i <= word_l  do
			local c = word:sub(i, i)
      out=0
      --
      if c == "(" then
        local charact=word:byte(i+1)
if charact==nil then charact=65 end
        if charact>64 then --lettre = color
          local cc = color_translate(word:sub(i+1, i+1))
          if cc then
            i = i + 1
            cur_color = cc
          end
          out=1

        else --chiffre = font
          local cc = tonumber(word:sub(i+1, i+1))
          if cc then
            i = i + 1
            if cc>4 then cc=4 end
              decal = 256*cc
            end
          out=1
        end
      end
      
      if c == ")" then
        decal=0
        out=1
      end
      
      if out==0 then
        local hexa=string.byte(c)
				local w = charwidth[hexa+decal]
				if w then
					width = width + w + 1
					if width >= (SIGN_WIDTH - charwidth[32]) then
						width = 0
					else
						maxw = math_max(width, maxw)
					end
					if #chars < MAX_INPUT_CHARS then
						table.insert(chars, {
							off = ch_offs,
							tex = char_tex(font_name, c),
							col = string.char(cur_color+65),--("%X"):format(cur_color),
              dcl= decal,
						})
            
					end
					ch_offs = ch_offs + w
				end
			end
			i = i + 1
		end
		width = width + charwidth[32] + 1
		maxw = math_max(width, maxw)
		table.insert(words, { chars=chars, w=ch_offs })
	end

	-- Okay, we actually build the "line texture" here.

	local texture = { }

	local start_xpos = math.floor((SIGN_WIDTH - maxw) / 2)

	local xpos = start_xpos
	local ypos = (LINE_HEIGHT * lineno)

	cur_color = nil
  
	for word_i, word in ipairs(words) do
		local xoffs = (xpos - start_xpos)
		if (xoffs > 0) and ((xoffs + word.w) > maxw) then
			table.insert(texture, fill_line(xpos, ypos, maxw, old_color))--"n"))
			xpos = start_xpos
			ypos = ypos + LINE_HEIGHT
			lineno = lineno + 1
			if lineno >= NUMBER_OF_LINES then break end
			table.insert(texture, fill_line(xpos, ypos, maxw, cur_color))
		end
		for ch_i, ch in ipairs(word.chars) do
      decal=ch.dcl
			if ch.col ~= cur_color then
				cur_color = ch.col
        old_color = cur_color
				table.insert(texture, fill_line(xpos + ch.off, ypos, maxw, cur_color))
			end
			table.insert(texture, (":%d,%d=%s"):format(xpos + ch.off, ypos, ch.tex))
		end
    decal=0
		table.insert(
			texture, 
			(":%d,%d="):format(xpos + word.w, ypos) .. char_tex(font_name, " ")
		)
    
		xpos = xpos + word.w + charwidth[32]
		if xpos >= (SIGN_WIDTH + charwidth[32]) then break end
	end

	table.insert(texture, fill_line(xpos, ypos, maxw, "n"))
	table.insert(texture, fill_line(start_xpos, ypos + LINE_HEIGHT, maxw, "n"))

	return table.concat(texture), lineno
end

local function make_sign_texture(lines, pos)
	local texture = { ("[combine:%dx%d"):format(SIGN_WIDTH, LINE_HEIGHT * NUMBER_OF_LINES) }
	local lineno = 0
	for i = 1, #lines do
		if lineno >= NUMBER_OF_LINES then break end
		local linetex, ln = make_line_texture(lines[i], lineno, pos)
		table.insert(texture, linetex)
		lineno = ln + 1
	end
	table.insert(texture, "^[makealpha:0,0,0")
	return table.concat(texture, "")
end

local function set_obj_text(obj, text, new, pos)
	local split = new and split_lines_and_words or split_lines_and_words_old
	--local text_ansi = Utf8ToAnsi(text)
	local n = minetest.registered_nodes[minetest.get_node(pos).name]
	local text_scale = (n and n.text_scale) or DEFAULT_TEXT_SCALE
	obj:set_properties({
		textures={make_sign_texture(split(text), pos)},--text_ansi), pos)},
		visual_size = text_scale,
	})
end

monitor.construct_sign = function(pos, locked, screen)
	local meta = minetest.get_meta(pos)
	meta:set_string("infotext", "")
end

monitor.destruct_sign = function(pos,led)
  radius=0.5
  if led then radius=1 end
	local objects = minetest.get_objects_inside_radius(pos, radius)
	for _, v in ipairs(objects) do
		local e = v:get_luaentity()
		if e and e.name == "monitor:text" then
			v:remove()
		end
	end
end

local function make_infotext(text)
	text = trim_input(text)
	local lines = split_lines_and_words(text) or {}
	local lines2 = { }
	for _, line in ipairs(lines) do
		table.insert(lines2, (table.concat(line, " "):gsub("#[0-9a-fA-F]", ""):gsub("##", "#")))
	end
	return table.concat(lines2, "\n")
end

monitor.update_sign = function(pos, fields, owner, node)

	-- First, check if the interact keyword from CWz's mod is being set,
	-- or has been changed since the last restart...

	local meta = minetest.get_meta(pos)
	local stored_text = meta:get_string("text") or ""
	current_keyword = rawget(_G, "mki_interact_keyword") or current_keyword

	local new

	if fields then

		fields.text = trim_input(fields.text)

		local ownstr = ""
		if owner then ownstr = S("Locked sign, owned by @1\n", owner) end

		meta:set_string("infotext", ownstr..string.gsub(make_infotext(fields.text), "@KEYWORD", current_keyword).." ")
		meta:set_string("text", fields.text)
		
		meta:set_int("__signslib_new_format", 1)
		new = true
	else
		new = (meta:get_int("__signslib_new_format") ~= 0)
	end
  local signnode = node or minetest.get_node(pos)
  if signnode.name=="monitor:screen_led" then
    monitor.destruct_sign(pos,true)
  else
    monitor.destruct_sign(pos)
  end
	local text = meta:get_string("text")
	if text == nil or text == "" then return end
	local sign_info
	local signnode = node or minetest.get_node(pos)
	local signname = signnode.name
	local textpos = minetest.registered_nodes[signname].textpos
  local node_param2=minetest.get_node(pos).param2 + 1
	if textpos then
		sign_info = textpos[minetest.get_node(pos).param2 + 1]
--[[
	elseif signnode.name == "signs:sign_yard" then
		sign_info = monitor.yard_sign_model.textpos[minetest.get_node(pos).param2 + 1]
	elseif signnode.name == "signs:sign_hanging" then
		sign_info = monitor.hanging_sign_model.textpos[minetest.get_node(pos).param2 + 1]
	elseif string.find(signnode.name, "sign_wall") then
		if signnode.name == default_sign
		  or signnode.name == default_sign_metal
		  or signnode.name == "locked_sign:sign_wall_locked" then
			sign_info = monitor.regular_wall_sign_model.textpos[minetest.get_node(pos).param2 + 1]
		else
			sign_info = monitor.metal_wall_sign_model.textpos[minetest.get_node(pos).param2 + 1]
		end
	else -- ...it must be a sign on a fence post.
		sign_info = monitor.sign_post_model.textpos[minetest.get_node(pos).param2 + 1]
--]]
	end
	if sign_info == nil then
		return
	end
	local text = minetest.add_entity({x = pos.x + sign_info.delta.x,
										y = pos.y + sign_info.delta.y,
										z = pos.z + sign_info.delta.z}, "monitor:text")
	text:setyaw(sign_info.yaw)

--modification console
if string.find(signname,"monitor:screen")  then
local rot = text:get_rotation()
rot.x=sign_info.rot
text:set_rotation(rot)
end


end


local signs_text_on_activate

signs_text_on_activate = function(self)
	local pos = self.object:getpos()
	local meta = minetest.get_meta(pos)
	local text = meta:get_string("text")
	local new = (meta:get_int("__signslib_new_format") ~= 0)
	if text and minetest.registered_nodes[minetest.get_node(pos).name] then
		text = trim_input(text)
		set_obj_text(self.object, text, new, pos)
	end
end

minetest.register_entity(":monitor:text", {
	collisionbox = { 0, 0, 0, 0, 0, 0 },
	visual = "upright_sprite",
	textures = {},

	on_activate = signs_text_on_activate,
})

build_char_db()

minetest.register_lbm({
	nodenames = monitor.sign_node_list,
	name = "monitor:restore_sign_text",
	label = "Restore monitor text",
	run_at_every_load = true,
	action = function(pos, node)
		monitor.update_sign(pos,nil,nil,node)
	end
})

--
--screen

minetest.register_node("monitor:screen_up", {
  description = "up Screen",
  node_placement_prediction = "",
  paramtype = "light",
  sunlight_propagates = true,
  paramtype2 = "facedir",
  light_source = 6,
  drawtype = "mesh",
  mesh = "screen_up.obj",
  tiles = {
		"mnt_screen_up_bottom.png",
		"mnt_screen_up_side.png",
		"mnt_screen_up_side.png",
		"mnt_screen_up_side.png",
		"mnt_screen_up_side.png",
    "mnt_screen_up_dark.png"
	},
  selection_box = { type = "fixed", fixed = { -0.5,-0.5,0.3,0.5,0.5,0.5} },
  collision_box = { type = "fixed", fixed = { -0.5,-0.5,0.3,0.5,0.5,0.5} },

  textpos = {
		{delta = { x =  0.04,     y = -0.2, z =  0.1 }, yaw = 0 ,rot=0.73},
		{delta = { x =  0.1,  y = -0.2, z =  -0.04    }, yaw = math.pi / -2 ,rot=0.73},
		{delta = { x =  -0.04,     y = -0.2, z = -0.1 }, yaw = math.pi ,rot=0.73},
		{delta = { x = -0.1,  y = -0.2, z =  0.04    }, yaw = math.pi / 2 ,rot=0.73},
	},
  default_color = "c",
  groups = {cracky=333, spacengine=12,not_in_creative_inventory = creative_enable},
  on_construct=function(pos)
    spacengine.construct_node(pos,"Screen up","^C¨64¨0¨^bC0bJ0bM0aa0bi0¨1",12)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_destruct = function(pos)
    monitor.destruct_sign(pos)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player,"screen")
	end,
  can_dig=spacengine.can_dig,
  on_rotate = screwdriver.disallow,
  on_punch = function(pos, node, puncher)
    local check=spacengine.owner_check(puncher,pos)
    if check<2 then return false end
    spacengine.formspec_update(pos,puncher,"sw#1#>",check) -- value
  end
})

minetest.register_node("monitor:screen_wall", {
	description = "wall screen",
  sunlight_propagates = true,
	paramtype = "light",
light_source = 6,
node_placement_prediction = "",
	groups = {cracky=333,spacengine=12,not_in_creative_inventory = creative_enable},
	sounds = default.node_sound_stone_defaults(),
paramtype2 = "facedir",
drawtype = "nodebox",
tiles = {"mnt_screen_wall.png"},
default_color = "c",
node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.4375, 0.5, 0.5, 0.5}, -- NodeBox1
		}
	},
	textpos = {
		{delta = { x =  0.04,     y = 0.07, z =  0.41 }, yaw = 0 ,rot=0},
		{delta = { x =  0.41,  y = 0.07, z =  -0.04    }, yaw = math.pi / -2 ,rot=0},
		{delta = { x =  -0.04,     y = 0.07, z = -0.41 }, yaw = math.pi ,rot=0},
		{delta = { x = -0.41,  y = 0.07, z =  0.04    }, yaw = math.pi / 2 ,rot=0},
	},
  on_construct=function(pos)
    spacengine.construct_node(pos,"Screen wall","^C¨64¨0¨^bC0bJ0bM0aa0bi0¨1",12)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_destruct = function(pos)
    monitor.destruct_sign(pos)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player,"screen")
	end,
  can_dig=spacengine.can_dig,
  on_rotate = screwdriver.disallow,
  on_punch = function(pos, node, puncher)
    local check=spacengine.owner_check(puncher,pos)
    if check<2 then return false end
    spacengine.formspec_update(pos,puncher,"sw#1#>",check) -- value
  end
})

minetest.register_node("monitor:screen_console", {
  description = "Console screen",
  drawtype = "mesh",
  mesh = "console_screen.obj",
  tiles = {"mnt_fond_console.png"},
  sunlight_propagates = true,
  node_placement_prediction = "",
  selection_box = { type = "fixed", fixed = { -0.5,-0.5,0.1,0.5,0,0.5} },
  collision_box = { type = "fixed", fixed = { -0.5,-0.5,0.1,0.5,0,0.5} },
  paramtype = "light",
  paramtype2 = "facedir",
  light_source = 6,
  groups = {cracky=333,spacengine=12,not_in_creative_inventory = creative_enable},
  textpos = {
		{delta = { x =  0,     y = -0.28, z =  0.15 }, yaw = math.pi ,rot=0.5},
		{delta = { x =  0.15,  y = -0.28, z =  0  }, yaw = math.pi / 2 ,rot=0.5},
		{delta = { x =  0,     y = -0.28, z = -0.15 }, yaw = math.pi ,rot=-0.5},
		{delta = { x = -0.15,  y = -0.28, z =  0  }, yaw = math.pi / 2 ,rot=-0.5},
	},
  default_color = "c",
  on_construct=function(pos)
    spacengine.construct_node(pos,"Screen console","^C¨64¨0¨^bC0bJ0bM0aa0bi0¨1",12)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_destruct = function(pos)
    monitor.destruct_sign(pos)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player,"screen")
	end,
  can_dig=spacengine.can_dig,
  on_rotate = screwdriver.disallow,
  on_punch = function(pos, node, puncher)
    local check=spacengine.owner_check(puncher,pos)
    if check<2 then return false end
    spacengine.formspec_update(pos,puncher,"sw#1#>",check) -- value
  end
})

minetest.register_node("monitor:screen_down", {
  description = "down screen",
  drawtype = "mesh",
  mesh = "console_down.obj",
  tiles = {"mnt_fond_console.png"},
  sunlight_propagates = true,
  node_placement_prediction = "",
  selection_box = { type = "fixed", fixed = { -0.5,-0.5,-0.15,0.5,0.4,0.5} },
  collision_box = { type = "fixed", fixed = { -0.5,-0.5,-0.15,0.5,0.4,0.5} },
  paramtype = "light",
  paramtype2 = "facedir",
  light_source = 6,
  groups = {cracky=333,spacengine=12,not_in_creative_inventory = creative_enable},
  textpos = {
		{delta = { x =  0,     y = 0.36, z =  0.15 }, yaw = math.pi ,rot=1.17},
		{delta = { x =  0.15,  y = 0.36, z =  0  }, yaw = math.pi / 2 ,rot=1.17},
		{delta = { x =  0,     y = 0.36, z = -0.15 }, yaw = math.pi ,rot=-1.17},
		{delta = { x = -0.15,  y = 0.36, z =  0  }, yaw = math.pi / 2 ,rot=-1.17},
	},
  default_color = "c",
  on_construct=function(pos)
    spacengine.construct_node(pos,"Screen down","^C¨64¨0¨^bC0bJ0bM0aa0bi0¨1",12)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_destruct = function(pos)
    monitor.destruct_sign(pos)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player,"screen")
	end,
  can_dig=spacengine.can_dig,
  on_rotate = screwdriver.disallow,
  on_punch = function(pos, node, puncher)
    local check=spacengine.owner_check(puncher,pos)
    if check<2 then return false end
    spacengine.formspec_update(pos,puncher,"sw#1#>",check) -- value
  end
})

--console
minetest.register_node("monitor:console_base", {
  description = "Console",
  drawtype = "mesh",
  mesh = "console_base.obj",
  tiles = {"mnt_fond_console1.png"},
  selection_box = { type = "fixed", fixed = { -0.5,-0.5,0,0.5,0.5,0.5} },
  collision_box = { type = "fixed", fixed = { -0.5,-0.5,0,0.5,0.5,0.5} },
  paramtype = "light",
  paramtype2 = "facedir",
  sunlight_propagates = true,
  groups = {cracky=1,not_in_creative_inventory = creative_enable},
  sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("monitor:screen_led", {
	description = "Big screen",
  sunlight_propagates = true,
	paramtype = "light",
light_source = 8,
node_placement_prediction = "",
	groups = {cracky=333,spacengine=12,not_in_creative_inventory = creative_enable},
	sounds = default.node_sound_stone_defaults(),
paramtype2 = "facedir",
drawtype = "nodebox",
tiles = {"mnt_led.png"},
default_color = "c",
node_box = {
		type = "fixed",
		fixed = {
			{-0.85, -0.15, 0.4375, 0.85, 0.15, 0.5}, -- NodeBox1
		}
	},
  text_scale={x=1.9, y=1.8},
	textpos = {
		{delta = { x =  0.1,     y = -0.27, z =  0.42 }, yaw = 0 ,rot=0},--{delta = { x =  0.1,     y = -0.4, z =  0.42 }, yaw = 0 ,rot=0},
		{delta = { x =  0.42,  y = -0.27, z =  -0.1    }, yaw = math.pi / -2 ,rot=0},--{delta = { x =  0.42,  y = -0.4, z =  -0.1    }, yaw = math.pi / -2 ,rot=0},
		{delta = { x =  -0.1,     y = -0.27, z = -0.42 }, yaw = math.pi ,rot=0},--{delta = { x =  -0.1,     y = -0.4, z = -0.42 }, yaw = math.pi ,rot=0},
		{delta = { x = -0.42,  y = -0.27, z =  0.1    }, yaw = math.pi / 2 ,rot=0},--{delta = { x = -0.42,  y = -0.4, z =  0.1    }, yaw = math.pi / 2 ,rot=0},
	},
  on_construct=function(pos)
    spacengine.construct_node(pos,"Screen led","^m¨64¨0¨^aa0¨1¨^m",12)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_destruct = function(pos)
    monitor.destruct_sign(pos,true)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player,"led",true)
	end,
  can_dig=spacengine.can_dig,
  on_rotate = screwdriver.disallow,
  on_punch = function(pos, node, puncher)
    local check=spacengine.owner_check(puncher,pos)
    if check<2 then return false end
    --spacengine.formspec_update(pos,puncher,"sw#1#>",check) -- value
  end
})

--AIM
minetest.register_node("monitor:screen_aim", {
	description = "AIM screen",
  sunlight_propagates = true,
	paramtype = "light",
  light_source = 6,
  node_placement_prediction = "",
	groups = {cracky=333,spacengine=12,not_in_creative_inventory = creative_enable},
	sounds = default.node_sound_stone_defaults(),
  paramtype2 = "facedir",
  drawtype = "nodebox",
  tiles = {"mnt_screen_aim.png"},
  default_color = "c",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.4375, 0.5, 0.5, 0.5}, -- NodeBox1
		}
	},
	textpos = {
		{delta = { x =  0.04,     y = 0.07, z =  0.43 }, yaw = 0 ,rot=0},
		{delta = { x =  0.43,  y = 0.07, z =  -0.04    }, yaw = math.pi / -2 ,rot=0},
		{delta = { x =  -0.04,     y = 0.07, z = -0.43 }, yaw = math.pi ,rot=0},
		{delta = { x = -0.43,  y = 0.07, z =  0.04    }, yaw = math.pi / 2 ,rot=0},
	},
  on_construct=function(pos)
    spacengine.construct_node(pos,"Screen aim","^c¨64¨0¨^ax0az0ay0aI0bG0bo0bo0bo0¨1",12)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_destruct = function(pos)
    monitor.destruct_sign(pos)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player,"info",true)
	end,
  can_dig=spacengine.can_dig,
  on_rotate = screwdriver.disallow,
  on_punch = function(pos, node, puncher)
    local check=spacengine.owner_check(puncher,pos)
    if check<2 then return false end
    spacengine.formspec_update(pos,puncher,"sw#1#>",check) -- value
  end
})

--screen transparent
minetest.register_node("monitor:screen_transparent", {
	description = "transparent screen",
  inventory_image = "mnt_transparent_screen_inv.png",
  sunlight_propagates = true,
	paramtype = "light",
  light_source = 8,
  node_placement_prediction = "",
	groups = {cracky=333,spacengine=12,not_in_creative_inventory = creative_enable},
	sounds = default.node_sound_stone_defaults(),
  paramtype2 = "facedir",
  drawtype = "nodebox",
  tiles = {"mnt_transparent_screen.png"},
  --tiles = {"mnt_transparent_screen.png", "mnt_transparent_screen.png", "mnt_transparent_screen.png", "mnt_transparent_screen.png", "mnt_transparent_screen_side.png", "mnt_transparent_screen.png"},
  default_color = "c",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.05, 0.5, 0.5, 0.05}, -- NodeBox1
		}
	},
  use_texture_alpha=true,
  text_scale={x=1, y=0.6},
	textpos = {
		{delta = { x =  0.04, y = 0, z =  -0.06 }, yaw = 0 ,rot=0},
		{delta = { x =  -0.06,  y = 0, z =  -0.04    }, yaw = math.pi / -2 ,rot=0},
		{delta = { x =  -0.04, y = 0, z = 0.06 }, yaw = math.pi ,rot=0},
		{delta = { x = 0.06,  y = 0, z =  0.04    }, yaw = math.pi / 2 ,rot=0},
	},
  on_construct=function(pos)
    spacengine.construct_node(pos,"Screen transparent","^C¨64¨0¨^bC0bJ0bM0aa0bi0¨1",12)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_destruct = function(pos)
    monitor.destruct_sign(pos)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player,"screen")
	end,
  can_dig=spacengine.can_dig,
  on_rotate = screwdriver.disallow,
  on_punch = function(pos, node, puncher)
    local check=spacengine.owner_check(puncher,pos)
    if check<2 then return false end
    spacengine.formspec_update(pos,puncher,"sw#1#>",check) -- value
  end
})
