class_name Main
extends Control

const FREE_BALL = preload("res://Autoloads/Resources/Plays/Attack/Body/free_ball.tres")

var current_attack : Attack = FREE_BALL :
	set(value):
		current_attack = value
		_update()

@onready var arrow_anchor: Control = %ArrowAnchor
@onready var github_button: Button = %GithubButton

@onready var left_beastie_column: BeastieColumn = %LeftBeastieColumn
@onready var damage_splash: DamageSplash = %DamageSplash
@onready var right_beastie_column: BeastieColumn = %RightBeastieColumn
@onready var select_uis: SelectUIs = %SelectUIs

@onready var cheerleader_button: Button = %CheerleaderButton
@onready var friendship_button: Button = %FriendshipButton
@onready var weariness_number_ui: NumberUIAlt = %WearinessNumberUI
@onready var reset_all_button: Button = %ResetButton
@onready var screenshot_button: Button = %ScreenshotButton

# Fake TeamController to avoid refactor damage calc code lol
@onready var team_controller: TeamController = %TeamController


func _ready() -> void:
	github_button.pressed.connect(_on_github_button_pressed)

	left_beastie_column.beastie_updated.connect(_update)
	right_beastie_column.beastie_updated.connect(_update)

	left_beastie_column.beastie_row.beastie_select_ui_requested.connect(select_uis.show_beastie_select_ui.bind(Global.MySide.LEFT))
	right_beastie_column.beastie_row.beastie_select_ui_requested.connect(select_uis.show_beastie_select_ui.bind(Global.MySide.RIGHT))
	select_uis.beastie_selected.connect(_on_beastie_selected)

	left_beastie_column.plays_select_ui_requested.connect(_on_left_column_play_select_ui_requested)
	# specify if this is selecting for mimicked attack later
	select_uis.plays_selected.connect(_on_play_selected)

	left_beastie_column.trait_select_ui_requested.connect(select_uis.show_trait_select_ui.bind(Global.MySide.LEFT))
	right_beastie_column.trait_select_ui_requested.connect(select_uis.show_trait_select_ui.bind(Global.MySide.RIGHT))
	select_uis.trait_selected.connect(_on_trait_selected)

	left_beastie_column.rally_requested.connect(_on_rally_requested)
	left_beastie_column.stamina_change_requested.connect(func(value : int):
		if right_beastie_column.beastie:
			right_beastie_column.beastie.health = value
	)

	# Absolute desperation of a solution...
	left_beastie_column.left_column_musclebrain_reset_requested.connect(right_beastie_column.on_left_column_musclebrain_reset_requested)

	cheerleader_button.toggled.connect(func(toggle_on : bool):
		team_controller.have_cheerleader = toggle_on
		_update()
	)
	friendship_button.toggled.connect(func(toggle_on : bool):
		team_controller.have_friendship = toggle_on
		_update()
	)

	weariness_number_ui.value_updated.connect(func(value : int):
		team_controller.weariness = value
		_update()
	)

	reset_all_button.pressed.connect(func():
		left_beastie_column.beastie = Global.SPRECKO.duplicate(true)
		left_beastie_column.boost_row.reset_all_ui() # will signal up to column and reset it too
		right_beastie_column.beastie = Global.SPRECKO.duplicate(true)
		right_beastie_column.boost_row.reset_all_ui() # will signal up to column and reset it too
		cheerleader_button.button_pressed = false
		friendship_button.button_pressed = false
		weariness_number_ui.reset()
		team_controller.reset()
		current_attack = FREE_BALL.duplicate(true)
	)

	screenshot_button.pressed.connect(save_image)

	_update()

	_fix_button_for_mobile.call_deferred()


func _on_beastie_selected(beastie : Beastie, side : Global.MySide) -> void:
	var column : BeastieColumn = left_beastie_column if side == Global.MySide.LEFT else right_beastie_column
	column.beastie = beastie

	if side != Global.MySide.LEFT:
		return

	for attack : Plays in beastie.possible_plays:
		if current_attack.name.to_lower() == attack.name.to_lower():
			return
	current_attack = FREE_BALL


func _on_left_column_play_select_ui_requested() -> void:
	select_uis.show_plays_select_ui(left_beastie_column.beastie)


func _on_play_selected(attack : Plays) -> void:
	current_attack = attack
	if not current_attack:
		current_attack = FREE_BALL


func _on_trait_selected(new_trait : Trait, side : Global.MySide) -> void:
	var column : BeastieColumn = left_beastie_column if side == Global.MySide.LEFT else right_beastie_column
	column.beastie.my_trait = new_trait
	column.update_custom_trait_button()


func _update() -> void:
	if not is_node_ready():
		await ready

	if Global.resetting:
		return

	var attacker : Beastie = left_beastie_column.beastie
	var defender : Beastie = right_beastie_column.beastie

	if not attacker or not defender:
		damage_splash.amount = 0
		damage_splash.attack = null

	if attacker and defender:
		Global.is_musclebrained = attacker.my_trait.name.to_lower() == "musclebrain"
		current_attack.is_mimicked = left_beastie_column.mimic_button.button_pressed
		attacker.my_plays[0] = current_attack
		damage_splash.amount = DamageCalculator.get_damage(attacker, defender, current_attack, team_controller, team_controller)
		damage_splash.attack = current_attack

		var index : int = int(current_attack.type)
		var color_type := index as Global.ColorType
		var new_color = Global.get_main_color(color_type)
		if Global.is_musclebrained:
			new_color = Global.get_main_color(Global.ColorType.BODY)
		for arrow : Polygon2D in arrow_anchor.get_children():
			arrow.color = new_color

		if left_beastie_column.current_attack == current_attack:
			return # this prevents the most stupid accidental infinite recursive loop I ever made, like wtf lmao
		left_beastie_column.current_attack = current_attack
		right_beastie_column.current_attack = current_attack


func _on_rally_requested(toggled_on : bool) -> void:
	if toggled_on:
		team_controller.my_field_effects.get_or_add(FieldEffect.Type.RALLY, 1)
	elif team_controller.my_field_effects.has(FieldEffect.Type.RALLY):
		team_controller.my_field_effects.erase(FieldEffect.Type.RALLY)
	_update()


func save_image() -> void:
	if not Global.is_on_web:
		return
	var image : Image = get_viewport().get_texture().get_image()
	var raw : PackedByteArray = image.save_png_to_buffer()
	JavaScriptBridge.download_buffer(raw, "damage.png")


func _on_github_button_pressed() -> void:
	OS.shell_open("https://github.com/GFZA/SickoCalc-Torch-Passed-Source-Code")


# It doesn't work??????
# I have no idea why lol
# TODO: look into this more

var all_buttons : Array[Button] = []

func _fix_button_for_mobile() -> void:
	_find_button_recursive(self)
	for button : Button in all_buttons:
		if not button.name.to_lower() == "screenshotbutton":
			button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS # really bad cheese to set all button lol
		if Global.is_on_web_mobile:
			var normal_style = button.get_theme_stylebox("normal")
			var pressed_style = button.get_theme_stylebox("pressed")
			button.add_theme_stylebox_override("hover", normal_style)
			button.add_theme_stylebox_override("hover_pressed", pressed_style)


func _find_button_recursive(parent : Node) -> void:
	for child in parent.get_children():
		if child.get_class().to_lower() == "button":
			all_buttons.append(child)
		if child.get_child_count() > 0:
			_find_button_recursive(child)
