@tool
extends Trait


func get_defense_mult(attacker : Beastie, defender : Beastie, _attack : Attack, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> float: # Overwrite
	var defender_trait : Trait = defender.my_trait
	var is_anticipation : bool = (defender_trait.name.to_lower() == "anticipation")
	if not is_anticipation:
		return 1.0

	if attacker.get_feeling_stack(Beastie.Feelings.BLOCKED) > 0:
		return def_mult

	return 1.0
