@tool
class_name TraitButton
extends Button

signal trait_selected(new_trait : Trait)

@export var my_trait : Trait = null :
	set(value):
		my_trait = value
		_update_trait()

@onready var trait_name_label: Label = %TraitNameLabel
@onready var trait_desc_label: RichTextLabel = %TraitDescLabel


func _ready() -> void:
	pressed.connect(_on_pressed)


func _update_trait() -> void:
	if not is_node_ready():
		await ready
	if not my_trait:
		trait_name_label.text = "Trait"
		trait_desc_label.text = "Likes to ball"
		return
	trait_name_label.text = my_trait.name
	trait_desc_label.text = Global.get_iconified_text(my_trait.description, false)


func _on_pressed() -> void:
	if not my_trait:
		my_trait.emit(null)
		return
	trait_selected.emit(my_trait)
