@tool
extends Trait


func special_cal_formula(damage : int, _attacker : Beastie, _defender : Beastie, _attack : Attack, \
					 _attacker_team_controller : TeamController = null, \
					 defender_team_controller : TeamController = null) -> int: # Overwrite
	if not defender_team_controller:
		return damage

	var have_rally : bool = (defender_team_controller.get_field_effect_stack(FieldEffect.Type.RALLY) > 0)
	var have_dread : bool = (defender_team_controller.get_field_effect_stack(FieldEffect.Type.DREAD) > 0)
	if (have_rally or have_dread) and damage > 66:
		return 66

	return damage
