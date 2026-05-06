@tool
extends Trait


func get_attack_mult(attacker : Beastie, _defender : Beastie, _attack : Attack, \
					 attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> float: # Overwrite
	var attacker_trait : Trait = attacker.my_trait
	var is_groove : bool = (attacker_trait.name.to_lower() == "groove")
	if not is_groove:
		return 1.0

	if not attacker_team_controller:
		return 1.0

	if attacker_team_controller.get_field_effect_stack(FieldEffect.Type.RHYTHM) > 0:
		return damage_dealt_mult

	return 1.0
