@tool
class_name DamageSplash
extends MarginContainer

@export_exp_easing() var amount : int = 0 :
	set(value):
		value = clamp(value, 0, INF)
		amount = value
		_update_number_label()

@export var attack : Attack = null :
	set(value):
		attack = value
		_update_color()

var my_label_setting : LabelSettings = null

@onready var number_label: Label = %NumberLabel
@onready var bg_splash: Polygon2D = %BGSplash


func _ready() -> void:
	my_label_setting = number_label.label_settings.duplicate()
	number_label.label_settings = my_label_setting


func _update_number_label() -> void:
	if not is_node_ready():
		await ready

	number_label.text = str(amount)


func _update_color() -> void:
	if not is_node_ready():
		await ready
	var new_color : Color = Global.get_main_color(Global.ColorType.BODY)
	if attack and not Global.is_musclebrained:
		var index : int = int(attack.type)
		var color_type := index as Global.ColorType
		new_color = Global.get_main_color(color_type)
	bg_splash.color = new_color
	my_label_setting.font_color = new_color
