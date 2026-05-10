@tool
class_name StaminaContainer
extends HBoxContainer

signal value_updated(value : int)

@export var text : String = "Target STAMINA":
	set(new_value):
		text = new_value
		if not is_node_ready():
			await ready
		text_label.text = text

@export_range(1, 100) var value : int = 100 :
	set(new_value):
		value = new_value
		if not is_node_ready():
			await ready
		stamina_line_edit.text = str(value)
		stamina_progress_bar.value = value
		value_updated.emit(value)

@onready var text_label: Label = %TextLabel
@onready var stamina_line_edit: LineEdit = %StaminaLineEdit
@onready var up_down_button_container: VBoxContainer = %UpDownButtonContainer
@onready var stamina_up_button: Button = %StaminaUpButton
@onready var stamina_down_button: Button = %StaminaDownButton
@onready var stamina_slider: HSlider = %StaminaSlider
@onready var stamina_progress_bar: ProgressBar = %StaminaProgressBar


func _ready() -> void:
	stamina_line_edit.text_submitted.connect(_on_stamina_line_edit_text_summited)
	stamina_up_button.pressed.connect(_on_stamina_up_button_pressed)
	stamina_down_button.pressed.connect(_on_stamina_down_button_pressed)
	stamina_slider.value_changed.connect(_on_stamina_slider_value_changed)


func _on_stamina_line_edit_text_summited(new_text : String) -> void:
	var new_stamina : int = new_text.to_int() if new_text.length() != 0 else 100
	value = new_stamina
	stamina_line_edit.release_focus()


func _on_stamina_up_button_pressed() -> void:
	var new_stamina : int = min(100, value + 1)
	value = new_stamina


func _on_stamina_down_button_pressed() -> void:
	var new_stamina : int = max(1, value - 1)
	value = new_stamina


func _on_stamina_slider_value_changed(new_value : int) -> void:
	value = new_value


func reset() -> void:
	text = "Text Here"
	value = 100
