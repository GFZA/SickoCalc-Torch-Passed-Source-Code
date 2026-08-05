@tool
class_name Beastie
extends Resource

enum Sprite {IDLE, READY, SPIKE, VOLLEY, GOOD, BAD, ICON}
enum Feelings {WIPED, TRIED, SHOOK, JAZZED, BLOCKED, WEEPY, TOUGH, TENDER, SWEATY, NOISY, ANGRY, NERVOUS, STRESSED}
enum Stats {B_POW, S_POW, M_POW, B_DEF, S_DEF, M_DEF}
enum Position {UPPER_BACK, UPPER_FRONT, LOWER_BACK, LOWER_FRONT, BENCH_1, BENCH_2, NOT_ASSIGNED}

const MAX_NAME_LENGTH : int = 12
const MAX_NUNBER_LENGTH : int = 3

signal my_name_updated(my_name : String)
signal sport_number_updated(sport_number : int)
signal invests_updated(invests_dict : Dictionary[Stats, int])
signal current_boosts_updated(boost_dict : Dictionary[Stats, int])
signal current_feelings_updated(feelings_dict : Dictionary[Feelings, int])
signal my_plays_updated(updated_plays : Array[Plays])
signal my_trait_updated(updated_trait : Trait)
signal health_updated(health : int)


@export_range(0, 100, 1) var health : int = 100 :
	set(value):
		clamp(value, 0, 100)
		health = value
		health_updated.emit(health)

@export var my_plays : Array[Plays] = get_empty_slot_plays_array() :
	set(value):
		if value.size() != 3:
			value.resize(3) # Just to be safe
		my_plays = value
		my_plays_updated.emit(my_plays)

@export var my_trait : Trait = null :
	set(value):
		my_trait = value
		if my_trait and my_trait.name.to_lower() == "haunted":
			current_feelings.clear()
			current_feelings.get_or_add(Feelings.TRIED, 4)
		my_trait_updated.emit(my_trait)

@export var current_boosts : Dictionary[Stats, int] = {} :
	set(value):
		value.sort()
		current_boosts = value
		current_boosts_updated.emit(current_boosts)

@export var current_feelings : Dictionary[Feelings, int] = {} :
	set(value):
		value.sort()
		current_feelings = value
		current_feelings_updated.emit(current_feelings)

@export_group("Less important")
@export var my_name : String = "" :
	set(value):
		value = value.substr(0, MAX_NAME_LENGTH)
		my_name = value
		my_name_updated.emit(my_name)
@export_range(0, 999) var sport_number : int = 0:
	set(value):
		clamp(value, 0, 999)
		sport_number = value
		sport_number_updated.emit(sport_number)
@export var invests : Dictionary[Stats, int] = {
	Beastie.Stats.B_POW : 0,
	Beastie.Stats.S_POW : 0,
	Beastie.Stats.M_POW : 0,
	Beastie.Stats.B_DEF : 0,
	Beastie.Stats.S_DEF : 0,
	Beastie.Stats.M_DEF : 0,
} :
	set(value):
		value.sort()
		invests = value
		invests_updated.emit(invests)

@export_group("Internal Infos")
@export var specie_name : String = "Sprecko"
@export_range(1, 106) var beastiepedia_id : int = 1
@export var is_nfe : bool = false
@export_color_no_alpha var bar_color : Color = Color.GREEN
@export_range(1, 150) var body_base_pow : int = 45
@export_range(1, 150) var spirit_base_pow : int = 43
@export_range(1, 150) var mind_base_pow : int = 42
@export_range(1, 150) var body_base_def : int = 50
@export_range(1, 150) var spirit_base_def : int = 67
@export_range(1, 150) var mind_base_def : int = 55
@export_multiline var plays_string : String = "From Levels:\n1\nCareful Shot\n1\nCall Out\n6\nRefresh\n9\nLure Shot\n12\nBreaker\n15\nShield\n19\nClear Field\n24\nToppler\n30\nMark\n35\nSnipe\n39\nForward Pass\n43\nDemolish\nFrom Friends:\nPower Sap\nBoom\nRelaxed Hit\nDig\nPipe\nChill Out\nExhaust\nHunker\nTough Front\nHeat Up\nTorch Pass"
@export var possible_plays : Array[Plays] = []
@export var possible_traits : Array[Trait] = []
@export var sprites : Dictionary[Sprite, Texture2D] = {
	Sprite.IDLE : null,
	Sprite.READY : null,
	Sprite.SPIKE : null,
	Sprite.VOLLEY : null,
	Sprite.GOOD : null,
	Sprite.BAD : null,
	Sprite.ICON : null,
}
@export var x_offset : int = 0
@export var y_offset : int = 0
@export var ball_anchor_position_receive : Vector2 = Vector2.ZERO # When the beastie s facing LEFT
@export var ball_anchor_position_ready : Vector2 = Vector2.ZERO # When the beastie s facing LEFT

var my_side : Global.MySide = Global.MySide.LEFT
var my_field_position : Position = Position.NOT_ASSIGNED
var ally_field_position : Position = Position.NOT_ASSIGNED

# For Hunter/Pressure to work, we need to check if defender is at bench
# But because of how BoardManager change benched beastie's my_field_position to back row
# so it's easiter to show in DamageIndicator, using my_field_position for that doesn't work
# So this var is the ugly workaround...
var is_really_at_bench : bool = false


func get_total_stats_value(stats_type : Stats) -> int:
	var base_stats : int = 0
	match stats_type: # Should have use Dictionary like invests instead, too lazy to refactor now...
		Beastie.Stats.B_POW:
			base_stats = body_base_pow
		Beastie.Stats.S_POW:
			base_stats = spirit_base_pow
		Beastie.Stats.M_POW:
			base_stats = mind_base_pow
		Beastie.Stats.B_DEF:
			base_stats = body_base_def
		Beastie.Stats.S_DEF:
			base_stats = spirit_base_def
		Beastie.Stats.M_DEF:
			base_stats = mind_base_def
	var invest_point : int = invests.get(stats_type)
	return base_stats + invest_point


func get_sprite(sprite_type : Sprite) -> Texture2D:
	return sprites.get(sprite_type)


func check_if_net() -> bool:
	if my_field_position == Beastie.Position.UPPER_FRONT or my_field_position == Beastie.Position.LOWER_FRONT:
		return true
	return false


func check_if_stack() -> bool:
	if (my_field_position == Beastie.Position.UPPER_FRONT and ally_field_position == Beastie.Position.UPPER_BACK) or \
	   (my_field_position == Beastie.Position.LOWER_FRONT and ally_field_position == Beastie.Position.LOWER_BACK):
		return true
	return false


func get_boosts(boost_type : Beastie.Stats) -> int:
	if not current_boosts.has(boost_type):
		return 0
	return current_boosts.get(boost_type)


func get_feeling_stack(feeling : Beastie.Feelings) -> int:
	if not current_feelings.has(feeling):
		return 0
	return current_feelings.get(feeling)


func get_total_invests_points() -> int:
	var result : int = 0
	for point in invests.values():
		result += point
	return result


static func get_empty_stats_dict() -> Dictionary[String, Array]:
	# Due to typing, we need this convoluted function, bruh
	return {}


static func get_empty_plays_array() -> Array[Plays]:
	# Due to typing, we need this convoluted function, bruh
	return []


static func get_empty_slot_plays_array() -> Array[Plays]:
	var array : Array[Plays] = []
	array.resize(3)
	return array


static func get_empty_trait_array() -> Array[Trait]:
	# Due to typing, we need this convoluted function, bruh
	return []


func get_stats_to_display(stat : Stats) -> int:
	var base_stat : int = get_total_stats_value(stat)
	var total_boost : int = 0
	var boosts_to_add : int = get_boosts(stat)
	if get_feeling_stack(Feelings.WEEPY) > 0:
		boosts_to_add = min(0, boosts_to_add) # so it counts deboosts
	total_boost += boosts_to_add

	match stat:
		Stats.B_POW, Stats.S_POW, Stats.M_POW:
			if my_trait.name.to_lower() == "shy":
				total_boost += int(not check_if_net())
			else:
				total_boost += int(check_if_net())
		Stats.B_DEF, Stats.S_DEF, Stats.M_DEF:
			if my_trait.name.to_lower() == "shy":
				total_boost += int(check_if_net())
			else:
				total_boost += int(not check_if_net()) + int(check_if_stack())

	var final_stat : float = float(base_stat) + 5.0
	match signi(total_boost):
		1:
			final_stat += floori(final_stat * float(total_boost) / 2.0)
		-1:
			final_stat = floori(final_stat * 2.0 / (absf(float(total_boost)) + 2.0))

	return floori(final_stat)
