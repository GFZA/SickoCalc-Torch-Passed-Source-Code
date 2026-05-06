@tool
class_name Support
extends Plays

@export var name : String = "Provoke"
@export_multiline var descrition : String = "Target feels 2 ANGRY (only attacks)."


func _init() -> void:
	self.type = Type.SUPPORT
