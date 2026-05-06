@tool
class_name FieldEffect
extends Resource

enum Type {RALLY, DREAD, RHYTHM, TRAP, QUAKE, BARRIER_UPPER, BARRIER_LOWER}

@export var type : Type = Type.RALLY
@export var name : String = "RALLY"
@export_range(0, 6) var stack : int = 0
@export var max_stack : int = -1
@export_multiline var desc : String = "SPIRIT damage +15, MIND damage x¾"
