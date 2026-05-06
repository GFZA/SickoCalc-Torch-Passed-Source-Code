@tool
class_name PlaysButton
extends Button

signal plays_selected(plays : Plays)

@export var plays : Plays = null :
	set(value):
		plays = value
		_update_plays()

@onready var plays_ui: PlaysUI = %PlaysUI
@onready var desc_label: RichTextLabel = %DescLabel


func _ready() -> void:
	pressed.connect(_on_pressed)


func _update_plays() -> void:
	if not is_node_ready():
		await ready
	if not plays:
		plays_ui.my_play = null
		desc_label.text = "Do nothing."
		return
	plays_ui.my_play = plays
	var desc : String = ""
	if plays is Attack:
		desc += "%s POW. " % str(plays.base_pow)
	desc += Global.get_iconified_text(plays.descrition, false)
	desc_label.text = desc # Yes, typo, awesome.


func _on_pressed() -> void:
	if not plays:
		plays_selected.emit(null)
		return
	plays_selected.emit(plays)
