@tool
class_name Defense
extends Plays

@export var name : String = "Tag Out"
@export_multiline var descrition : String = "TAG OUT."


func _init() -> void:
	self.type = Type.DEFENSE
