@tool
extends Trait


func special_cal_formula(damage : int, attacker : Beastie, _defender : Beastie, _attack : Attack, \
					 _attacker_team_controller : TeamController = null, \
					 _defender_team_controller : TeamController = null) -> int: # Overwrite
	if attacker.my_trait.name.to_lower() == "vicious":
		return max(damage, 30)
	return damage
