@tool
extends Node

# Use to tell DamageSplash display BREAK text
const BREAK_TEXT_DAMAGE := -99999

enum MySide {LEFT, RIGHT}
enum SortBeastie {NAME, NUMBER}

var pause_updating_field : bool = false
var resetting : bool = false
@onready var is_on_web : bool = OS.get_name() == "Web"

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
	_assign_all_beasties_data()
	_assign_all_plays_data()
	_assign_all_trait_data()


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
							all_beasties_data.append(load(path + file_name + "/" + inner_file_name.get_basename() + suffix))
						inner_file_name = inner_dir.get_next()
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access the path %s." % path)


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
					array_to_add.append(load(path + "/" + file_name.get_basename() + suffix))
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
				all_trait_data.append(load(path + "/" + file_name.get_basename() + suffix))
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access the path %s." % path)
