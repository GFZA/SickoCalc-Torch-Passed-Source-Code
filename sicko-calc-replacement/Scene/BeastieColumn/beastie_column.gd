@tool
class_name BeastieColumn
extends MarginContainer

const SPRECKO = preload("uid://p68xjhmdw3hk")
const FREE_BALL : Plays = preload("uid://1gwxenj63w75")

signal beastie_updated
signal plays_select_ui_requested

@export var beastie : Beastie = SPRECKO:
	set(value):
		beastie = value
		_update_beastie()


@export var side : Global.MySide = Global.MySide.LEFT :
	set(value):
		side = value
		_update_side()

var current_attack : Attack = FREE_BALL:
	set(value):
		current_attack = value
		_update_attack()

@onready var beastie_row: BeastieRow = %BeastieRow

@onready var attack_row: HBoxContainer = %AttackRow
@onready var select_attack_button: Button = %SelectAttackButton
@onready var attack_plays_ui: PlaysUI = %AttackPlaysUI
@onready var mimic_attack_select_button: Button = %MimicAttackSelectButton
@onready var mimic_attack_plays_ui: PlaysUI = %MimicAttackPlaysUI


func _ready() -> void:
	var is_left : bool = side == Global.MySide.LEFT
	attack_row.visible = is_left

	if is_left:
		select_attack_button.pressed.connect(plays_select_ui_requested.emit)

	_update_attack()


func _update_beastie() -> void:
	if not is_node_ready():
		await ready
	beastie_row.beastie = beastie
	beastie_updated.emit()


func _update_side() -> void:
	if not is_node_ready():
		await ready
	beastie_row.side = side


func _update_attack() -> void:
	if not is_node_ready():
		await ready
	if not side == Global.MySide.LEFT:
		return

	if not current_attack:
		select_attack_button.flat = false
		attack_plays_ui.hide()
	else:
		select_attack_button.flat = true
		attack_plays_ui.my_play = current_attack
		attack_plays_ui.show()
