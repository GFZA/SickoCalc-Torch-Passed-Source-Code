@tool
class_name NumberUI
extends HBoxContainer

signal value_updated(value : int)

@export_range(-99, 99) var num : int = 0 :
	set(value):
		num = clamp(value, value_min, 99)
		_update_ui()

@export_range(-99, 99) var default : int = 0
@export_range(-99, 99) var value_min : int = -99
@export_range(-99, 99) var value_max : int = 99

@export var allow_double_click_max : bool = false

@export var side : Global.MySide = Global.MySide.RIGHT:
	set(value):
		side = value
		_update_side()

@export var show_reset_button : bool = true :
	set(value):
		show_reset_button = value
		if not is_node_ready():
			await ready
		if reset_button.visible:
			reset_button.visible = false
		max_button.visible = value

@export var show_max_button : bool = true :
	set(value):
		show_max_button = value
		if not is_node_ready():
			await ready
		max_button_spacer.visible = value
		max_button.visible = value

@export var show_min_button : bool = false :
	set(value):
		show_min_button = value
		if not is_node_ready():
			await ready
		min_button_spacer.visible = value
		min_button.visible = value

@onready var reset_button: Button = %ResetButton
@onready var number_label: Label = %NumberLabel
@onready var infinity_number_label: Label = %InfinityNumberLabel
@onready var up_down_button_container: VBoxContainer = %UpDownButtonContainer
@onready var up_button: Button = %UpButton
@onready var down_button: Button = %DownButton
@onready var max_button_spacer: Control = %MaxButtonSpacer
@onready var max_button: Button = %MaxButton
@onready var min_button_spacer: Control = %MinButtonSpacer
@onready var min_button: Button = %MinButton


func _ready() -> void:
	reset_button.pressed.connect(func(): num = default)
	up_button.pressed.connect(func(): num = clamp(num + 1, value_min, value_max))
	down_button.pressed.connect(func(): num = clamp(num - 1, value_min, value_max))
	max_button.pressed.connect(_on_max_button_pressed)
	min_button.pressed.connect(func(): num = value_min)

	reset()


func reset() -> void:
	num = default
	reset_button.hide()


func _update_ui() -> void:
	if not is_node_ready():
		await ready
	number_label.visible = (num != 99)
	number_label.text = str(num)
	infinity_number_label.visible = (num == 99)
	if show_reset_button:
		reset_button.visible = not (num == default)
	value_updated.emit(num)


func _update_side() -> void:
	if not is_node_ready():
		await ready

	# Ugly code. Pretty outcome. Worth it(?)
	match side:
		Global.MySide.LEFT:
			move_child(max_button, 0)
			move_child(max_button_spacer, 1)
			move_child(min_button, 2)
			move_child(min_button_spacer, 3)
			move_child(up_down_button_container, 4)
			move_child(number_label, 5)
			move_child(reset_button, 6)
		Global.MySide.RIGHT:
			move_child(reset_button, 0)
			move_child(number_label, 1)
			move_child(up_down_button_container, 2)
			move_child(max_button_spacer, 3)
			move_child(max_button, 4)
			move_child(min_button_spacer, 5)
			move_child(min_button, 6)


func _on_max_button_pressed() -> void:
	if allow_double_click_max and num < 99 and num == value_max:
		num = 99
	else:
		num = value_max
