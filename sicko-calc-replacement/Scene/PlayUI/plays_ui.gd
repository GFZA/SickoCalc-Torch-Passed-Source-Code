@tool
class_name PlaysUI
extends MarginContainer

const UIBG : Dictionary[Plays.Type, Texture2D] = {
	Plays.Type.ATTACK_BODY : preload("uid://uj4m1ntklqnf"),
	Plays.Type.ATTACK_SPIRIT : preload("uid://ctq1b1lo45elm"),
	Plays.Type.ATTACK_MIND : preload("uid://cyu38q3r5dpnk"),
	Plays.Type.SUPPORT : preload("uid://bebdev5axcnwe"),
	Plays.Type.VOLLEY : preload("uid://doj5nryoqgr7s"),
	Plays.Type.DEFENSE : preload("uid://dgum3wc24lo16")
}

const MAX_LABEL_LENGTH : int = 475
const DEFAULT_FONT_SIZE : int = 108

@export var my_play : Plays = null :
	set(value):
		if value == null:
			play_name = "End Turn"
			current_bg = Plays.Type.DEFENSE
			my_play = value
			return

		my_play = value
		play_name = my_play.name
		current_bg = my_play.type

@export var disabled : bool = false :
	set(value):
		if not is_node_ready():
			await ready
		disabled = value
		disabled_mask.visible = disabled

var play_name : String = "Block" :
	set(value):
		play_name = value
		update_play_name_label(play_name)

var current_bg : Plays.Type = Plays.Type.DEFENSE :
	set(value):
		current_bg = value
		update_background(current_bg)

var my_name_setting : LabelSettings = null

@onready var play_name_label: Label = %PlayNameLabel
@onready var ui_texture_rec: TextureRect = %UITextureRec
@onready var disabled_mask: TextureRect = %DisabledMask


func _ready() -> void:
	if not is_node_ready():
		await ready

	my_name_setting = play_name_label.label_settings.duplicate()
	play_name_label.label_settings = my_name_setting


func update_play_name_label(assigned_name : String) -> void:
	if not is_node_ready():
		await ready

	my_name_setting.font_size = DEFAULT_FONT_SIZE # Reset
	play_name_label.text = assigned_name

	var font : Font = my_name_setting.font
	var text_width := font.get_string_size(
		play_name_label.text,
		HORIZONTAL_ALIGNMENT_RIGHT,
		-1,
		DEFAULT_FONT_SIZE
	).x

	if text_width > MAX_LABEL_LENGTH:
		var font_scale : float = float(MAX_LABEL_LENGTH / text_width)
		my_name_setting.font_size = int(DEFAULT_FONT_SIZE * font_scale)
	else:
		my_name_setting.font_size = DEFAULT_FONT_SIZE


func update_background(new_bg : Plays.Type) -> void:
	if not is_node_ready():
		await ready
	ui_texture_rec.texture = UIBG.get(new_bg)
