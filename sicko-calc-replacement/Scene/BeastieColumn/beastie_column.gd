@tool
class_name BeastieColumn
extends MarginContainer


@export var beastie : Beastie :
	set(value):
		beastie = value
		_update_beastie()


@export var side : Global.MySide = Global.MySide.LEFT :
	set(value):
		side = value
		_update_side()


@onready var beastie_row: BeastieRow = %BeastieRow


func _update_beastie() -> void:
	if not is_node_ready():
		await ready
	beastie_row.beastie = beastie


func _update_side() -> void:
	if not is_node_ready():
		await ready
	beastie_row.side = side
