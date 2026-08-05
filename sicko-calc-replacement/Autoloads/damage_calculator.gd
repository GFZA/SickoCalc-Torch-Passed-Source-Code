@tool
extends Node

const MIRACLE_PLAY_POW : int = 75
const PRESICION_STRIKE_DAMAGE : int = 30

const MIMIC_MULT : float = 1.2
const MUSCLEBRAIN_MULT : float = 1.2

const FRIENDSHIP_MULT : float = 0.75
const RALLY_MIND_MULT : float = 0.75
const TENDER_MULT : float = 2.0
const TOUGH_MULT : float = 0.25

const RALLY_FLAT : int = 20
const CHEERLEADER_FLAT : int = 10
const STARTER_FLAT : int = 15

const NORMAL_CALC_BYPASSING_ATTACKS : Array[String] = ["grinder", "precision strike", "exp precision strike"]

const LOWEST_DEF_TARGETING_ATTACKS : Array[String] = ["snipe"]
const HIGHEST_DEF_TARGETING_ATTACKS : Array[String] = ["contest"]

const ALWAYS_CALC_FROM_BENCH_ATTACKS : Array[String] = ["flight"]
const ALWAYS_CALC_FROM_BACK_ATTACKS : Array[String] = ["flight"]
const ALWAYS_CALC_FROM_FRONT_ATTACKS : Array[String] = ["swarm", "launch"]

const SWAP_ROW_BONUS_ATTACKS : Array[String] = ["rocket"]
const SWAP_ROW_BONUS_TRAITS : Array[String] = ["shy"]

const BOOSTS_IGNORING_ATTACKS : Array[String] = ["raw fury", "exp precision strike"]
const BOOSTS_IGNORING_TRAITS : Array[String] = ["foggy"]

const TRAITS_IGNORING_ATTACKS : Array[String] = ["true strike"]
const TRAITS_IGNORING_TRAITS : Array[String] = ["maverick"]

const FIELD_IGNORING_ATTACKS : Array[String] = ["sweep"]
const FIELD_IGNORING_TRAITS : Array[String] = ["in the clouds"]

const RALLY_BOOST_EXCEPTION_ATTACKS : Array[String] = ["ego blast"]
const RALLY_BOOST_EXCEPTION_TRAITS : Array[String] = ["extrovert"]

const BLOCKED_IGNORING_ATTACKS : Array[String] = ["roll shot", "exp tracker"]
const BLOCKED_IGNORING_TRAITS : Array[String] = ["rogue"]

const TOUGH_IGNORING_ATTACKS : Array[String] = ["raw fury", "exp precision strike"]
const TOUGH_IGNORING_TRAITS : Array[String] = [] # Unused


func get_damage(attacker : Beastie, defender : Beastie, attack : Attack, \
				attacker_team_controller : TeamController = null, \
				defender_team_controller : TeamController = null) -> int:

	if not attacker.my_trait:
		push_error("Attacker %s doesn't have trait assigned!" % attacker.specie_name)
		return 0
	if not defender.my_trait:
		push_error("Defender %s doesn't have trait assigned!" % defender.specie_name)
		return 0

	var final_damage : int = 0
	var attack_name : String = attack.name.to_lower()
	var attacker_trait : String = attacker.my_trait.name.to_lower()
	var defender_trait : String = defender.my_trait.name.to_lower()
	var get_musclebrained : bool = (attacker_trait == "musclebrain") and (attack.type != Plays.Type.ATTACK_BODY)

	#region Special attacks
	if attack_name == "grinder":
		final_damage = max(1, ceili(float(defender.health) / 2.0))
		if attack.is_mimicked:
			final_damage = ceili(final_damage * MIMIC_MULT) # do it here as it skip the part where do this normally

	if attack_name in ["precision strike", "exp precision strike"]:
		final_damage = PRESICION_STRIKE_DAMAGE # It's now affected by Blocked
		if attacker_trait == "musclebrain":
			final_damage = ceili(final_damage * MUSCLEBRAIN_MULT) # since it overwrite the musclebrain check above, just check again here
		if attack.is_mimicked:
			final_damage = ceili(final_damage * MIMIC_MULT) # do it here as it skip the part where do this normally

	if attack_name == "free ball":
		if attacker_trait == "miracle play":
			attack = attack.duplicate(true)
			attack.base_pow = MIRACLE_PLAY_POW

	# Dealing with Barrier
	if defender_team_controller and not defender.is_really_at_bench:
		var barrier_upper : bool = (defender_team_controller.get_field_effect_stack(FieldEffect.Type.BARRIER_UPPER) > 0)
		var barrier_lower : bool = (defender_team_controller.get_field_effect_stack(FieldEffect.Type.BARRIER_LOWER) > 0)

		match [barrier_upper, barrier_lower]:
			[true, true]: # Both lanes
				if defender.my_field_position in [Beastie.Position.UPPER_FRONT, Beastie.Position.LOWER_FRONT]:
					return Global.BREAK_TEXT_DAMAGE # BREAK
				if attack.target == Attack.Target.STRAIGHT:
					if defender.my_field_position in [Beastie.Position.UPPER_BACK, Beastie.Position.LOWER_BACK]:
						return 0
				# (No need for special condition of sideway at net)
			[true, false]: # Upper only
				if defender.my_field_position == Beastie.Position.UPPER_FRONT:
					return Global.BREAK_TEXT_DAMAGE # BREAK
				if attack.target == Attack.Target.STRAIGHT:
					if defender.my_field_position == Beastie.Position.UPPER_BACK:
						return 0
				else:
					if defender.my_field_position == Beastie.Position.LOWER_FRONT:
						if attacker.my_field_position in [Beastie.Position.UPPER_FRONT, Beastie.Position.UPPER_BACK]:
							return 0
			[false, true]: # Lower only
				if defender.my_field_position == Beastie.Position.LOWER_FRONT:
					return Global.BREAK_TEXT_DAMAGE # BREAK
				if attack.target == Attack.Target.STRAIGHT:
					if defender.my_field_position == Beastie.Position.LOWER_BACK:
						return 0
				else:
					if defender.my_field_position == Beastie.Position.UPPER_FRONT:
						if attacker.my_field_position in [Beastie.Position.LOWER_FRONT, Beastie.Position.LOWER_BACK]:
							return 0
	#endregion

	#region Set up vars for calculation

	var attacker_at_net : bool = attacker.check_if_net() or attack_name in ALWAYS_CALC_FROM_FRONT_ATTACKS
	if attack_name in ALWAYS_CALC_FROM_BACK_ATTACKS:
		attacker_at_net = false

	var dread : bool = false
	if attacker_team_controller:
		dread = attacker_team_controller.get_field_effect_stack(FieldEffect.Type.DREAD) > 0
	var jazzed : bool = ((attacker.get_feeling_stack(Beastie.Feelings.JAZZED) > 0) or \
				((attack_name == "thriller")) and not dread \
				and not attacker.get_feeling_stack(Beastie.Feelings.WEEPY) > 0)
	var attacker_weepy : bool = (attacker.get_feeling_stack(Beastie.Feelings.WEEPY) > 0)

	var defender_at_net : bool = defender.check_if_net()
	var defender_is_stacked : bool = defender.check_if_stack()
	var tough : bool = (defender.get_feeling_stack(Beastie.Feelings.TOUGH) > 0)
	var tender : bool = (defender.get_feeling_stack(Beastie.Feelings.TENDER) > 0)
	var defender_weepy : bool = (defender.get_feeling_stack(Beastie.Feelings.WEEPY) > 0)

	var base_pow : int = attack.get_attack_pow(attacker, defender, attacker_team_controller, defender_team_controller)
	if get_musclebrained:
		base_pow = ceili(float(base_pow) * MUSCLEBRAIN_MULT)

	var type : Plays.Type = attack.type if not get_musclebrained else Plays.Type.ATTACK_BODY
	assert(type == Plays.Type.ATTACK_BODY or type == Plays.Type.ATTACK_SPIRIT or type == Plays.Type.ATTACK_MIND,
			"Attack's type not found! Check if the attack is assigned its type correctly!")

	var stats_type_attack : int = int(type)
	var stats_type_defense : int = int(type) + 3
	# Very dirty cheese to convert one enum to another as they're in the same index
	# 0 == Plays.Type.ATTACK_BODY == Beastie.Stats.B_POW
	# 1 == Plays.Type.ATTACK_SPIRIT == Beastie.Stats.S_POW
	# 2 == Plays.Type.ATTACK_MIND == Beastie.Stats.M_POW
	# 3 == Beastie.Stats.B_DEF
	# 4 == Beastie.Stats.S_DEF
	# 5 == Beastie.Stats.M_DEF
	if attack_name in HIGHEST_DEF_TARGETING_ATTACKS:
		stats_type_defense = _get_highest_or_lowest_def_stat(true, attacker, defender, attack, jazzed, defender_weepy)
	if attack_name in LOWEST_DEF_TARGETING_ATTACKS:
		stats_type_defense = _get_highest_or_lowest_def_stat(false, attacker, defender, attack, jazzed, defender_weepy)

	var total_attack_stat : int = attacker.get_total_stats_value(stats_type_attack) # Will get +5 from being lv.50 in calculation
	var total_defense_stat : int = defender.get_total_stats_value(stats_type_defense)
	var attack_boosts : int = attacker.get_boosts(stats_type_attack)
	var defense_boosts : int = defender.get_boosts(stats_type_defense)
	var ignore_trait : bool = (attack_name in TRAITS_IGNORING_ATTACKS or attacker_trait in TRAITS_IGNORING_TRAITS)
	#endregion

	#region Get boost counts and damage mults
	# --- POW boosts ---
	var total_attack_boost : int = 0
	var attack_boosts_to_add : int = attack_boosts
	var ignore_pow_boosts : bool = attacker_weepy or (defender_trait in BOOSTS_IGNORING_TRAITS and \
							not (attack_name in TRAITS_IGNORING_ATTACKS or attacker_trait in TRAITS_IGNORING_TRAITS))
	if ignore_pow_boosts:
		attack_boosts_to_add = min(0, attack_boosts) # so it counts deboosts
	elif attack_name in ALWAYS_CALC_FROM_BENCH_ATTACKS:
		attack_boosts_to_add = 0  # clear all boosts
	total_attack_boost += attack_boosts_to_add

	if jazzed:
		if signi(total_attack_boost) == -1:
			total_attack_boost = 0
		total_attack_boost += 1

	if not attack_name in ALWAYS_CALC_FROM_BENCH_ATTACKS: # Flight remove all row bonus for some reason
		if attacker_trait in SWAP_ROW_BONUS_TRAITS:
			total_attack_boost += int(not attacker_at_net)
		else:
			total_attack_boost += int(attacker_at_net)

	# --- DEF boosts ---
	var total_defense_boost : int = 0
	var def_boosts_to_add : int = defense_boosts
	var ignore_target_boost : bool = (attacker_trait in BOOSTS_IGNORING_TRAITS) or (attack_name in BOOSTS_IGNORING_ATTACKS)
	if defender_weepy or jazzed or ignore_target_boost:
		def_boosts_to_add = mini(0, defense_boosts) # so it counts deboosts
	total_defense_boost += def_boosts_to_add

	var swap_row_bonus : bool = false
	var is_traits_ignoring_attack : bool = attack_name in TRAITS_IGNORING_ATTACKS
	var attacker_is_traits_ignoring_trait : bool = attacker_trait in TRAITS_IGNORING_TRAITS
	var is_swap_row_bonus_attack : bool = attack_name in SWAP_ROW_BONUS_ATTACKS
	var defender_is_swap_row_bonus_trait : bool = defender_trait in SWAP_ROW_BONUS_TRAITS

	if not defender_is_swap_row_bonus_trait:
		if is_swap_row_bonus_attack:
			swap_row_bonus = true
		else:
			swap_row_bonus = false
	else:
		if is_swap_row_bonus_attack != (attacker_is_traits_ignoring_trait != is_traits_ignoring_attack): # make it double ignore if both
			swap_row_bonus = false
		else:
			swap_row_bonus = true

	if swap_row_bonus:
		total_defense_boost += int(defender_at_net)
	else:
		total_defense_boost += int(not defender_at_net) + int(defender_is_stacked)

	var attacker_trait_mult : float = attacker.my_trait.get_attack_mult(attacker, defender, attack, attacker_team_controller, defender_team_controller)
	var defender_trait_mult : float = 1.0
	if not ignore_trait:
		defender_trait_mult = defender.my_trait.get_defense_mult(attacker, defender, attack, attacker_team_controller, defender_team_controller)

	var mimic_mult : float = MIMIC_MULT if attack.is_mimicked else 1.0

	var tender_mult : float = TENDER_MULT if tender else 1.0

	var rally_mind_mult : float = RALLY_MIND_MULT if stats_type_attack == int(Plays.Type.ATTACK_MIND) and attacker_team_controller and \
							(attacker_team_controller.get_field_effect_stack(FieldEffect.Type.RALLY) > 0) and not attack_name in RALLY_BOOST_EXCEPTION_ATTACKS \
							and not attacker_trait in RALLY_BOOST_EXCEPTION_TRAITS and not attack_name in FIELD_IGNORING_ATTACKS \
							and not (attacker_trait in FIELD_IGNORING_TRAITS) else 1.0

	var friendship_mult : float = FRIENDSHIP_MULT if defender_team_controller and \
							defender_team_controller.check_for_friendship_buff(defender) and \
							not ignore_trait \
							else 1.0

	var all_damage_mults : float = (attacker_trait_mult / defender_trait_mult) * mimic_mult \
									* tender_mult * rally_mind_mult * friendship_mult
	#endregion

	#region Get final stats for calculation
	var final_atk : float = float(total_attack_stat) + 5.0
	match signi(total_attack_boost):
		1:
			final_atk += floori(final_atk * float(total_attack_boost) / 2.0)
		-1:
			final_atk = floori(final_atk * 2.0 / (absf(float(total_attack_boost)) + 2.0))

	var final_def : float = float(total_defense_stat) + 5.0
	match signi(total_defense_boost):
		1:
			final_def += floori(final_def * float(total_defense_boost) / 2.0)
		-1:
			final_def = floori(final_def * 2.0 / (absf(float(total_defense_boost)) + 2.0))
	#endregion

	#region Calculate the damage + board states
	if not attack_name in NORMAL_CALC_BYPASSING_ATTACKS:
		final_damage = max(1, ceili(((floori(final_atk) * base_pow / final_def) * 0.4) * all_damage_mults))

	if attacker_team_controller:
		if attacker_team_controller.check_for_cheerleader_buff(attacker):
			final_damage += CHEERLEADER_FLAT
		var boostable_by_rally : bool = ((stats_type_attack == int(Plays.Type.ATTACK_SPIRIT)) or (attack_name in RALLY_BOOST_EXCEPTION_ATTACKS) or (attacker_trait in RALLY_BOOST_EXCEPTION_TRAITS)) \
										and not (attacker_trait in FIELD_IGNORING_TRAITS)
		var has_rally : bool = (attacker_team_controller.get_field_effect_stack(FieldEffect.Type.RALLY) > 0)
		var defender_ignore_rally : bool = (defender_trait in FIELD_IGNORING_TRAITS) and not attacker_trait in TRAITS_IGNORING_TRAITS
		if boostable_by_rally and has_rally and not defender_ignore_rally:
			final_damage += RALLY_FLAT

	var starter_trait_proc : bool = bool(attacker.my_trait.get_starter_trait_boost_stack(attacker, stats_type_attack))
	if starter_trait_proc:
		final_damage += STARTER_FLAT

	# Apply Blocked after adding flat damage now (New in Milestone 4)
	var blocked_stack : float = 0.0
	var ignore_blocked : bool = (attack_name in BLOCKED_IGNORING_ATTACKS) or (attacker_trait in BLOCKED_IGNORING_TRAITS and attacker.my_trait.manually_activated)
	if not ignore_blocked:
		blocked_stack = attacker.get_feeling_stack(Beastie.Feelings.BLOCKED)
	var blocked_mult : float = 2.0 / (2.0 + blocked_stack)
	final_damage = max(1, ceili(final_damage * blocked_mult))

	final_damage = attacker.my_trait.special_cal_formula(final_damage, attacker, defender, attack, attacker_team_controller, defender_team_controller)

	# Apply Tough mult after everything
	var ignore_tough : bool = attack_name in TOUGH_IGNORING_ATTACKS
	var tough_mult : float = TOUGH_MULT if tough and not ignore_tough else 1.0
	final_damage = max(1, ceili(float(final_damage) * tough_mult))

	if not ignore_trait:
		final_damage = defender.my_trait.special_cal_formula(final_damage, attacker, defender, attack, attacker_team_controller, defender_team_controller)

	#endregion

	if attacker_team_controller:
		final_damage += (max(0, (attacker_team_controller.weariness - 7)) * 10)

	return final_damage


# Early calculating def stat just to pick stats for Contest or Snipe to calc actual damage again later
func _get_highest_or_lowest_def_stat(get_highest : bool, attacker : Beastie, defender : Beastie, attack : Attack, jazzed : bool, defender_weepy : bool) -> Beastie.Stats:
	var def_dict : Dictionary[Beastie.Stats, int] = {}

	var attack_name : String = attack.name.to_lower()
	for stat : Beastie.Stats in [Beastie.Stats.B_DEF, Beastie.Stats.S_DEF, Beastie.Stats.M_DEF]:
		var result : int = _pre_calc_def_stat(stat, attacker, defender, attack_name, jazzed, defender_weepy)
		def_dict.get_or_add(stat, result)

	var values_array : Array[int] = def_dict.values()
	values_array.sort()
	var highest_or_lowest_def : int = values_array.back() if get_highest else values_array.front()
	return def_dict.find_key(highest_or_lowest_def)


func _pre_calc_def_stat(stat : Beastie.Stats, attacker : Beastie, defender : Beastie, attack_name : String, jazzed : bool, defender_weepy : bool) -> int:
	var def_stat : int = defender.get_total_stats_value(stat)
	var total_defense_boost : int = 0
	var def_boosts_to_add : int = defender.get_boosts(stat)
	if defender_weepy or attacker.my_trait.name.to_lower() in BOOSTS_IGNORING_TRAITS or attack_name in BOOSTS_IGNORING_ATTACKS:
		def_boosts_to_add = min(0, defender.get_boosts(stat)) # so it counts deboosts
	total_defense_boost += def_boosts_to_add

	if jazzed:
		total_defense_boost = mini(0, total_defense_boost)

	# didn't account for back row bonus cuz we just need to see what's highest
	# then calc the acutal stat later

	var final_def : float = float(def_stat) + 5.0
	match signi(total_defense_boost):
		1:
			final_def += floori(final_def * float(total_defense_boost) / 2.0)
		-1:
			final_def = floori(final_def * 2.0 / (absf(float(total_defense_boost)) + 2.0))

	return floori(final_def)
