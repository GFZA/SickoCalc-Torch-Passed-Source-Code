@tool
class_name NumberUIAlt
extends HBoxContainer

signal value_updated(value : int)

@export_range(-99, 99) var num : int = 0 :
	set(value):
		num = clamp(value, value_min, 99)
		_update_ui()

@export_range(-99, 99) var default : int = 0
@export_range(-99, 99) var value_min : int = -99
@export_range(-99, 99) var value_max : int = 99
@export var color : Color = Color(1.0, 1.0, 1.0, 0.0) :
	set(value):
		color = value
		if not is_node_ready():
			await ready
		color_rect.color = color

@onready var color_rect: ColorRect = %ColorRect
@onready var number_label: Label = %NumberLabel
@onready var min_button: Button = %MinButton
@onready var minus_button: Button = %MinusButton
@onready var max_button: Button = %MaxButton
@onready var plus_button: Button = %PlusButton



func _ready() -> void:
	plus_button.pressed.connect(func(): num = clamp(num + 1, value_min, value_max))
	minus_button.pressed.connect(func(): num = clamp(num - 1, value_min, value_max))
	max_button.pressed.connect(_on_max_button_pressed)
	min_button.pressed.connect(func(): num = value_min)

	reset()


func reset() -> void:
	num = default


func _update_ui() -> void:
	if not is_node_ready():
		await ready
	number_label.text = str(num)
	value_updated.emit(num)


func _on_max_button_pressed() -> void:
		num = value_max
