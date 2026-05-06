@tool
extends Trait


func get_defense_mult(_attacker : Beastie, defender : Beastie, _attack : Attack, \
					 _attacker_team_controller : TeamController = null,\
					 defender_team_controller : TeamController = null) -> float: # Overwrite
	var defender_trait : Trait = defender.my_trait
	var is_performer : bool = (defender_trait.name.to_lower() == "performer")
	if not is_performer:
		return 1.0

	if not defender_team_controller:
		return 1.0

	if defender_team_controller.get_field_effect_stack(FieldEffect.Type.RALLY) > 0:
		return def_mult

	return 1.0
