@tool
class_name BeastieRow
extends MarginContainer

signal beastie_select_ui_requested

const EVIL_AXOLATI = preload("uid://l3eh6masrurv")

@export var beastie : Beastie :
	set(value):
		beastie = value
		_update_beastie()

@export var side : Global.MySide = Global.MySide.LEFT :
	set(value):
		side = value
		_update_side()

@onready var main_container: HBoxContainer = %MainContainer
@onready var beastie_display_container: VBoxContainer = %BeastieDisplayContainer

@onready var name_label: Label = %NameLabel
@onready var icon_rect: TextureRect = %IconRect

@onready var stats_label: Label = %StatsLabel
@onready var body_stats_label: Label = %BodyStatsLabel
@onready var spirit_stats_label: Label = %SpiritStatsLabel
@onready var mind_stats_label: Label = %MindStatsLabel

@onready var select_beastie_button: Button = %SelectBeastieButton


func _ready() -> void:
	select_beastie_button.pressed.connect(beastie_select_ui_requested.emit)


func _update_beastie() -> void:
	if not is_node_ready():
		await ready

	var is_left : bool = (side == Global.MySide.LEFT)
	if not beastie:
		name_label.text = "Unselected"
		icon_rect.texture = EVIL_AXOLATI
		body_stats_label.text = "0"
		spirit_stats_label.text = "0"
		mind_stats_label.text = "0"
	else:
		name_label.text = beastie.specie_name
		icon_rect.texture = beastie.get_sprite(Beastie.Sprite.ICON)
		body_stats_label.text = str(beastie.get_total_stats_value(Beastie.Stats.B_POW)) if is_left else str(beastie.get_total_stats_value(Beastie.Stats.B_DEF))
		spirit_stats_label.text = str(beastie.get_total_stats_value(Beastie.Stats.S_POW)) if is_left else str(beastie.get_total_stats_value(Beastie.Stats.S_DEF))
		mind_stats_label.text = str(beastie.get_total_stats_value(Beastie.Stats.M_POW)) if is_left else str(beastie.get_total_stats_value(Beastie.Stats.M_DEF))


func _update_side() -> void:
	if not is_node_ready():
		await ready

	var is_left : bool = (side == Global.MySide.LEFT)
	var new_index : int = 0 if not is_left else 1
	main_container.move_child(beastie_display_container, new_index)

	icon_rect.flip_h = is_left
	stats_label.text = "POW" if is_left else "DEF"
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if is_left else HORIZONTAL_ALIGNMENT_LEFT
	body_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if is_left else HORIZONTAL_ALIGNMENT_LEFT
	spirit_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if is_left else HORIZONTAL_ALIGNMENT_LEFT
	mind_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if is_left else HORIZONTAL_ALIGNMENT_LEFT
