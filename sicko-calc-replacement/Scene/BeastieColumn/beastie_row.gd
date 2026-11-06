@tool
class_name BeastieRow
extends MarginContainer

signal level_updated(level : int)
signal beastie_select_ui_requested

const EVIL_AXOLATI = preload("uid://l3eh6masrurv")
const SECRET_1 = preload("uid://cukw0bkohbuhw")
const SECRET_2 = preload("uid://cxjjnkkwhac1y")
const SECRET_3 = preload("uid://bh3ewxrd80od8")
const SECRET_4 = preload("uid://bvfwcjo648fyi")
const SECRET_5 = preload("uid://d1e421ymawf16")

@export var beastie : Beastie :
	set(value):
		beastie = value
		update_beastie()

@export_range(1, 100) var level : int = 50 :
	set(value):
		level = value
		if not is_node_ready():
			await ready
		level_line_edit.text = str(level)
		level_updated.emit(level)

@export var side : Global.MySide = Global.MySide.LEFT :
	set(value):
		side = value
		_update_side()

@onready var main_container: HBoxContainer = %MainContainer

@onready var upper_stats_container: HBoxContainer = %UpperStatsContainer

@onready var level_container: HBoxContainer = %LevelContainer
@onready var level_line_edit: LineEdit = %LevelLineEdit
@onready var level_button_container: VBoxContainer = %LevelButtonContainer
@onready var level_up_button: Button = %LevelUpButton
@onready var level_down_button: Button = %LevelDownButton

@onready var stats_label: Label = %StatsLabel
@onready var body_stats_label: Label = %BodyStatsLabel
@onready var spirit_stats_label: Label = %SpiritStatsLabel
@onready var mind_stats_label: Label = %MindStatsLabel

@onready var select_beastie_button: Button = %SelectBeastieButton

@onready var beastie_display_container: VBoxContainer = %BeastieDisplayContainer
@onready var name_label: Label = %NameLabel
@onready var icon_rect: TextureRect = %IconRect


func _ready() -> void:
	level_line_edit.text_submitted.connect(_on_level_line_edit_text_summited)
	level_up_button.pressed.connect(_on_level_up_button_pressed)
	level_down_button.pressed.connect(_on_level_down_button_pressed)
	select_beastie_button.pressed.connect(beastie_select_ui_requested.emit)
	Global.damage_updated.connect(_more_special)


func update_beastie() -> void:
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
		body_stats_label.text = str(beastie.get_stats_to_display(Beastie.Stats.B_POW)) if is_left else str(beastie.get_stats_to_display(Beastie.Stats.B_DEF))
		spirit_stats_label.text = str(beastie.get_stats_to_display(Beastie.Stats.S_POW)) if is_left else str(beastie.get_stats_to_display(Beastie.Stats.S_DEF))
		mind_stats_label.text = str(beastie.get_stats_to_display(Beastie.Stats.M_POW)) if is_left else str(beastie.get_stats_to_display(Beastie.Stats.M_DEF))
		_special()


func _update_side() -> void:
	if not is_node_ready():
		await ready

	var is_left : bool = (side == Global.MySide.LEFT)
	var new_index : int = 0 if not is_left else 1
	main_container.move_child(beastie_display_container, new_index)

	icon_rect.flip_h = is_left
	var index : int = 0 if is_left else 1
	upper_stats_container.move_child(level_container, index)
	stats_label.text = "POW" if is_left else "DEF"
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if is_left else HORIZONTAL_ALIGNMENT_LEFT
	body_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if is_left else HORIZONTAL_ALIGNMENT_LEFT
	spirit_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if is_left else HORIZONTAL_ALIGNMENT_LEFT
	mind_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if is_left else HORIZONTAL_ALIGNMENT_LEFT
	body_stats_label.text = str(beastie.get_stats_to_display(Beastie.Stats.B_POW)) if is_left else str(beastie.get_stats_to_display(Beastie.Stats.B_DEF))
	spirit_stats_label.text = str(beastie.get_stats_to_display(Beastie.Stats.S_POW)) if is_left else str(beastie.get_stats_to_display(Beastie.Stats.S_DEF))
	mind_stats_label.text = str(beastie.get_stats_to_display(Beastie.Stats.M_POW)) if is_left else str(beastie.get_stats_to_display(Beastie.Stats.M_DEF))


func _on_level_line_edit_text_summited(new_text : String) -> void:
	var new_level : int = new_text.to_int() if new_text.length() != 0 else 100
	new_level = clampi(new_level, 1, 100)
	level = new_level
	level_line_edit.release_focus()


func _on_level_up_button_pressed() -> void:
	var new_level : int = min(100, level + 1)
	level = new_level


func _on_level_down_button_pressed() -> void:
	var new_level : int = max(1, level - 1)
	level = new_level


func reset_level() -> void:
	level = 50


func _special() -> void:
	if not beastie:
		return
	if not beastie.my_trait:
		return
	if beastie.my_plays.front() == null:
		return
	var beastie_name : String = beastie.specie_name.to_lower()
	var trait_name : String = beastie.my_trait.name.to_lower()
	var attack_name : String = beastie.my_plays.front().name.to_lower()

	# To anyone reading this code, please keep these secrets. Thanks!
	match [beastie_name, trait_name, attack_name]:
		["riplash", "shy", "launch"]:
			name_label.text = "Pipe Bomb"
			icon_rect.texture = SECRET_1
		["kasaleet", _, "spike"]:
			name_label.text = "Footdive"
			icon_rect.texture = SECRET_2
		["squimage", "moist", "grit"]:
			name_label.text = "ena"
			icon_rect.texture = SECRET_3
		["sprecko", "cleanup", "sweep"]:
			name_label.text = "Dirt Sponge"
			icon_rect.texture = SECRET_4


func _more_special(damage : int) -> void:
	if not beastie:
		return
	if beastie.specie_name == "Rookee" and damage > 100000:
		name_label.text = "Scapegoat"
		icon_rect.texture = SECRET_5
