@tool
extends Node

signal is_musclebrained_updated(value : bool)

enum MySide {LEFT, RIGHT}
enum SortBeastie {NAME, NUMBER}

var SPRECKO : Beastie = load("res://Autoloads/Resources/Beastie/Sprecko/sprecko.tres")

var pause_updating_field : bool = false
var resetting : bool = false

var is_musclebrained : bool = false : # Absolutely cheese var
	set(value):
		is_musclebrained = value
		is_musclebrained_updated.emit(is_musclebrained)

@onready var is_on_web : bool = OS.get_name() == "Web"
@onready var is_on_web_mobile : bool = is_on_web and (OS.has_feature("web_android") or OS.has_feature("web_ios"))

#region Main Color Datas
enum ColorType {BODY, SPIRIT, MIND}

const COLOR_DICT : Dictionary[ColorType, Color] = {
	ColorType.BODY : Color(0.984, 0.878, 0.353, 1.0),
	ColorType.SPIRIT : Color(0.98, 0.525, 0.69, 1.0),
	ColorType.MIND : Color(0.592, 0.851, 0.984, 1.0),
}

func get_main_color(color_type : ColorType) -> Color:
	return COLOR_DICT.get(color_type) if COLOR_DICT.has(color_type) else Color.GREEN
#endregion

#region Icon Datas
enum Icon {
	ERROR,
	BODY, SPIRIT, MIND, ALL_TYPE,
	VOLLEY, SUPPORT, DEFENSE,
	UP_1, UP_2, UP_3, DOWN_1, DOWN_2, DOWN_3,
	WIPED, TRIED, SHOOK, JAZZED, BLOCKED, WEEPY,
	TOUGH, TENDER, SWEATY, NOISY, ANGRY, NERVOUS, STRESSED,
}
const ICON_PATHS : Dictionary[Icon, String] = {
	Icon.BODY : "res://Autoloads/Icons/icon_body.png",
	Icon.SPIRIT : "res://Autoloads/Icons/icon_spirit.png",
	Icon.MIND : "res://Autoloads/Icons/icon_mind.png",
	#Icon.ALL_TYPE : Will manually add all three icons later
	Icon.VOLLEY : "res://Autoloads/Icons/icon_volley.png",
	Icon.SUPPORT : "res://Autoloads/Icons/icon_support.png",
	Icon.DEFENSE : "res://Autoloads/Icons/icon_defense.png",
	Icon.UP_1 : "res://Autoloads/Icons/icon_up.png",
	Icon.UP_2 : "res://Autoloads/Icons/icon_up_2.png",
	Icon.UP_3 : "res://Autoloads/Icons/icon_up_3.png",
	Icon.DOWN_1 : "res://Autoloads/Icons/icon_down.png",
	Icon.DOWN_2 : "res://Autoloads/Icons/icon_down_2.png",
	Icon.DOWN_3 : "res://Autoloads/Icons/icon_down_3.png",
	Icon.WIPED : "res://Autoloads/Icons/icon_wiped.png",
	Icon.TRIED : "res://Autoloads/Icons/icon_tired.png",
	Icon.SHOOK : "res://Autoloads/Icons/icon_shook.png",
	Icon.JAZZED : "res://Autoloads/Icons/icon_jazzed.png",
	Icon.BLOCKED : "res://Autoloads/Icons/icon_blocked.png",
	Icon.WEEPY : "res://Autoloads/Icons/icon_weepy.png",
	Icon.TOUGH : "res://Autoloads/Icons/icon_tough.png",
	Icon.TENDER : "res://Autoloads/Icons/icon_tender.png",
	Icon.SWEATY : "res://Autoloads/Icons/icon_sweaty.png",
	Icon.NOISY : "res://Autoloads/Icons/icon_noisy.png",
	Icon.ANGRY : "res://Autoloads/Icons/icon_angry.png",
	Icon.NERVOUS : "res://Autoloads/Icons/icon_nervous.png",
	Icon.STRESSED : "res://Autoloads/Icons/icon_stressed.png"
}

const ICON_KEYWORDS : Dictionary[String, Icon] = {
	"BODY" : Icon.BODY,
	"SPIRIT" : Icon.SPIRIT,
	"MIND" : Icon.MIND,
	"ALL_TYPE" : Icon.ALL_TYPE,
	"VOLLEY" : Icon.VOLLEY,
	"SUPPORT" : Icon.SUPPORT,
	"DEFENSE" : Icon.DEFENSE,
	"UP1" : Icon.UP_1,
	"UP2" : Icon.UP_2,
	"UP3" : Icon.UP_3,
	"DOWN1" : Icon.DOWN_1,
	"DOWN2" : Icon.DOWN_2,
	"DOWN3" : Icon.DOWN_3,
	"WIPED" : Icon.WIPED,
	"TIRED" : Icon.TRIED, # typo, i know...
	"SHOOK" : Icon.SHOOK,
	"JAZZED" : Icon.JAZZED,
	"BLOCKED" : Icon.BLOCKED,
	"WEEPY" : Icon.WEEPY,
	"TOUGH" : Icon.TOUGH,
	"TENDER" : Icon.TENDER,
	"SWEATY" : Icon.SWEATY,
	"NOISY" : Icon.NOISY,
	"ANGRY" : Icon.ANGRY,
	"NERVOUS" : Icon.NERVOUS,
	"STRESSED" : Icon.STRESSED
}

const FEELINGS_TO_ICON_DICT : Dictionary[Beastie.Feelings, Icon] = {
	Beastie.Feelings.WIPED : Icon.WIPED,
	Beastie.Feelings.TRIED : Icon.TRIED,
	Beastie.Feelings.SHOOK : Icon.SHOOK,
	Beastie.Feelings.JAZZED : Icon.JAZZED,
	Beastie.Feelings.BLOCKED : Icon.BLOCKED,
	Beastie.Feelings.WEEPY : Icon.WEEPY,
	Beastie.Feelings.TOUGH : Icon.TOUGH,
	Beastie.Feelings.TENDER : Icon.TENDER,
	Beastie.Feelings.SWEATY : Icon.SWEATY,
	Beastie.Feelings.NOISY : Icon.NOISY,
	Beastie.Feelings.ANGRY : Icon.ANGRY,
	Beastie.Feelings.NERVOUS : Icon.NERVOUS,
	Beastie.Feelings.STRESSED : Icon.STRESSED
}


func get_icon_path_from_feelings(feelings : Beastie.Feelings) -> String:
	var icon_enum : Icon = FEELINGS_TO_ICON_DICT.get(feelings)
	return _get_icon_path(icon_enum)


func get_iconified_text(text : String, have_full_stop : bool = true) -> String:
	var new_text : String = ""
	var words_array := text.split(" ")

	var count : int = 0
	for word : String in words_array:
		var full_stop : String = "." if have_full_stop else ""
		var ending : String = full_stop if count == words_array.size() - 1 else " "
		var icon : Icon = _convert_word_to_icon_enum(word)
		match icon:
			Icon.ERROR:
				new_text += word
			Icon.UP_1, Icon.UP_2, Icon.UP_3, Icon.DOWN_1, Icon.DOWN_2, Icon.DOWN_3, \
			Icon.BODY, Icon.SPIRIT, Icon.MIND:
				new_text += _add_img_bbcode(icon) # Replace keyword entirely
			Icon.ALL_TYPE:
				new_text += _add_img_bbcode(Icon.BODY) + _add_img_bbcode(Icon.SPIRIT) + _add_img_bbcode(Icon.MIND)
							# Replace keyword entirely but special
			_:
				new_text += _add_img_bbcode(icon) + word # Add icon before keyword
		new_text += ending
		count += 1

	return new_text


func _convert_word_to_icon_enum(word : String) -> Icon:
	word = word.to_upper()
	if word.ends_with(","):
		word = word.trim_suffix(",")
	if word.ends_with("."):
		word = word.trim_suffix(".")

	return ICON_KEYWORDS.get(word, Icon.ERROR)


func _get_icon_path(icon : Icon) -> String:
	assert(icon != Icon.ERROR, "Tried to get path of non-existing icon!")
	return ICON_PATHS.get(icon)


func _add_img_bbcode(icon : Icon) -> String:
	return "[img]" + _get_icon_path(icon) + "[/img]"
#endregion

var all_beasties_data : Array[Beastie] = []
var all_body_attacks : Array[Plays] = []
var all_spirit_attacks : Array[Plays] = []
var all_mind_attacks : Array[Plays] = []
var all_volley_plays : Array[Plays] = []
var all_support_plays : Array[Plays] = []
var all_defense_plays : Array[Plays] = []
var all_plays : Array[Plays] = []
var all_trait_data : Array[Trait] = []


func _ready() -> void:
	_assign_all_plays_data()
	_assign_all_trait_data()
	_assign_all_beasties_data()


func _assign_all_plays_data() -> void:
	for i in 6: # 6 loops
		var path : String = "res://Autoloads/Resources/Plays/"
		var array_to_add : Array[Plays] = []
		match i:
			0:
				path += "Attack/Body"
				array_to_add = all_body_attacks
			1:
				path += "Attack/Spirit"
				array_to_add = all_spirit_attacks
			2:
				path += "Attack/Mind"
				array_to_add = all_mind_attacks
			3:
				path += "Volley"
				array_to_add = all_volley_plays
			4:
				path += "Support"
				array_to_add = all_support_plays
			5:
				path += "Defense"
				array_to_add = all_defense_plays

		var dir := DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if file_name.ends_with(".tres") or file_name.ends_with(".tres.remap"): # Is Beastie Resource
					var suffix : String = ".tres" if not Global.is_on_web else "" # Not sure why we need this but it works!
					var final_path = path + "/" + file_name.get_basename() + suffix
					#_adjust_plays(final_path)
					array_to_add.append(load(final_path))
				file_name = dir.get_next()
		else:
			push_error("An error occurred when trying to access the path %s." % path)

	var free_ball : Plays = null
	for play : Plays in all_body_attacks:
		if play.name.to_lower() == "free ball":
			free_ball = play
			all_body_attacks.erase(play)
	all_body_attacks.push_front(free_ball) # Make Free Ball always the first option

	all_plays.append_array(all_body_attacks)
	all_plays.append_array(all_spirit_attacks)
	all_plays.append_array(all_mind_attacks)
	all_plays.append_array(all_volley_plays)
	all_plays.append_array(all_support_plays)
	all_plays.append_array(all_defense_plays)


func _assign_all_trait_data() -> void:
	var path : String = "res://Autoloads/Resources/Trait/"
	var dir := DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".tres.remap"): # Is Beastie Resource
				var suffix : String = ".tres" if not Global.is_on_web else "" # Not sure why we need this but it works!
				var final_path : String = path + "/" + file_name.get_basename() + suffix
				#_adjust_traits(final_path)
				all_trait_data.append(load(final_path))
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access the path %s." % path)


func _assign_all_beasties_data() -> void:
	var path : String = "res://Autoloads/Resources/Beastie/"
	var dir := DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir(): # Is Folder
				var inner_dir := DirAccess.open(path + file_name + "/")
				if inner_dir:
					inner_dir.list_dir_begin()
					var inner_file_name : String = inner_dir.get_next()
					while inner_file_name != "":
						if inner_file_name.ends_with(".tres") or inner_file_name.ends_with(".tres.remap"): # Is Beastie Resource
							var suffix : String = ".tres" if not Global.is_on_web else "" # Not sure why we need this but it works!
							var final_path : String = path + file_name + "/" + inner_file_name.get_basename() + suffix
							var beastie : Beastie = load(final_path)
							#var path_to_folder : String = path + beastie.specie_name.capitalize() + "/"
							#_assign_beastie_their_sprite(beastie, path_to_folder, final_path)
							#_assign_beastie_their_playdex(beastie, final_path)
							all_beasties_data.append(beastie)
						inner_file_name = inner_dir.get_next()
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access the path %s." % path)


#region Dev tool functions (uncomment codes above then run the game)

func _adjust_plays(resource_file_path : String) -> void:
	var attack : Attack = load(resource_file_path)
	if attack.condition_mult != 1.0:
		attack.need_to_be_manually_activated = true
	ResourceSaver.save(attack, resource_file_path)


func _adjust_traits(resource_file_path : String) -> void:
	var the_trait : Trait = load(resource_file_path)
	if ((the_trait.def_mult != 1.0 or the_trait.damage_dealt_mult != 1.0 or the_trait.is_starter_trait) and \
		the_trait.name.to_lower() not in ["spiker", "absorption", "helmet", "musclebrain"] and not the_trait.always_activate) or \
		the_trait.name.to_lower() in ["stagecraft"]:
		the_trait.need_to_be_manually_activated = true
	ResourceSaver.save(the_trait, resource_file_path)


func _assign_beastie_their_sprite(beastie : Beastie, path_to_folder : String, path_to_beastie : String) -> void:
	beastie.sprites.clear()
	var s_icon : Texture2D = null

	var dir := DirAccess.open(path_to_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png"):
				var new_sprite : Texture2D = load(path_to_folder + file_name)
				if new_sprite:
					file_name = file_name.trim_suffix(".png")
					if file_name.begins_with("icon"):
						s_icon = new_sprite
					if file_name.ends_with("_ready") or file_name.ends_with("_spike") or \
						file_name.ends_with("_volley") or file_name.ends_with("_good") or \
						file_name.ends_with("_bad") or file_name.ends_with("_idle"):
						if dir.remove(path_to_folder + file_name + ".png") != Error.OK:
							push_error("Can't remove file from" + path_to_folder + file_name + ".png")
			file_name = dir.get_next()

		if s_icon == null:
			push_error("%s have no icon spirte!" % beastie.specie_name)

		beastie.sprites = {
			Beastie.Sprite.ICON : s_icon,
		}

	ResourceSaver.save(beastie, path_to_beastie)


func _assign_beastie_their_playdex(beastie : Beastie, path_to_beastie : String) -> void:
	beastie.possible_plays.clear()
	var all_play_names : Array[String] = []

	var splitted_string : PackedStringArray = beastie.plays_string.split("\n")
	for play_name : String in splitted_string:
		if play_name.to_int() == 0 and not play_name in ["From Levels:", "From Friends:"]:
			all_play_names.append(play_name)

	for play_name : String in all_play_names:
		play_name = play_name.to_lower()
		var i : int = 0
		for play : Plays in all_plays:
			if play.name.to_lower() == play_name:
				if play.type in [Plays.Type.VOLLEY, Plays.Type.DEFENSE, Plays.Type.SUPPORT]:
					break
				else:
					if play_name == "mimic":
						break
					else:
						beastie.possible_plays.append(play)
						break
			i += 1
			if i == all_plays.size():
				push_error("Can't find '%s' from %s in global all_plays data!" % [play_name, beastie.specie_name])

	ResourceSaver.save(beastie, path_to_beastie)

#endregion
