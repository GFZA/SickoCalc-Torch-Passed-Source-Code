@tool
extends Trait


func special_cal_formula(damage : int, attacker : Beastie, defender : Beastie, _attack : Attack, \
					 _attacker_team_controller : TeamController = null, \
					 _defender_team_controller : TeamController = null) -> int: # Overwrite
	# Can't use attack var as it could be from trait danced intangible beastie who have body attack
	var defender_trait : Trait = defender.my_trait
	var is_intangible : bool = (defender_trait.name.to_lower() == "intangible")
	if not is_intangible:
		return damage

	var attacker_attack : Plays = attacker.my_plays[0]
	if attacker_attack and attacker_attack.type == Plays.Type.ATTACK_BODY:
		return 0

	return damage
