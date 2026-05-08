@tool
class_name Attack
extends Plays

enum Target {STRAIGHT, SIDEWAYS, FRONT_ONLY, BACK_ONLY}
enum UseCondition {NORMAL, FRONT_ONLY, BACK_ONLY}

@export var name : String = "Free Ball"
@export var target : Target = Target.STRAIGHT
@export var use_condition : UseCondition = UseCondition.NORMAL
@export_range(0, 300) var base_pow : int = 1 :
	set(value):
		base_pow = value
		_update_base_pow_after_condition()
@export var show_in_indicator : bool = true
@export_multiline var descrition : String = "Can hit without volleying. Pass to an opponent and skip your turn. Can always be used."
@export var condition_name : String = ""
@export_range(0.75, 2.0) var condition_mult : float = 1.0 :
	set(value):
		condition_mult = value
		_update_base_pow_after_condition()
@export var need_to_be_manually_activated : bool = false

var is_mimicked : bool = false
var manually_activated : bool = false
var base_pow_after_condition : int = 1


func _init() -> void:
	self.type = Type.ATTACK_BODY


func _update_base_pow_after_condition() -> void:
	base_pow_after_condition = ceili(float(base_pow) * condition_mult)


func get_attack_pow(_attacker : Beastie, _defender : Beastie, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> int: # Overwrite this
	if manually_activated:
		return base_pow_after_condition
	return base_pow
