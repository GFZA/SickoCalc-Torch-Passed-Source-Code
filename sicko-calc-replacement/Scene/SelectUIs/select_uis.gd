class_name SelectUIs
extends MarginContainer

signal beastie_selected(beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition)
signal plays_selected(plays : Plays, slot_index : int, side : Global.MySide, team_pos : TeamController.TeamPosition)
signal trait_selected(new_trait : Trait, side : Global.MySide, team_pos : TeamController.TeamPosition)

#var board : Board = null # Set by Main on ready

@onready var bg_hidden_button: Button = %BGHiddenButton
@onready var beastie_select_ui: BeastieSelectUI = %BeastieSelectUI
@onready var plays_select_ui: PlaysSelectUI = %PlaysSelectUI
@onready var trait_select_ui: TraitSelectUI = %TraitSelectUI


func _ready() -> void:
	bg_hidden_button.pressed.connect(reset_and_hide)
	beastie_select_ui.beastie_selected.connect(_on_beastie_selected)
	plays_select_ui.plays_selected.connect(_on_plays_selected)
	trait_select_ui.trait_selected.connect(_on_trait_selected)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		reset_and_hide()


func _on_beastie_selected(beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition) -> void:
	#board.board_manager.add_beastie_to_scene(beastie, side, team_pos)
	beastie_selected.emit(beastie, side, team_pos)
	reset_and_hide()


func _on_plays_selected(plays : Plays, slot_index : int, side : Global.MySide, team_pos : TeamController.TeamPosition) -> void:
	plays_selected.emit(plays, slot_index, side, team_pos)
	reset_and_hide()


func _on_trait_selected(new_trait : Trait, side : Global.MySide, team_pos : TeamController.TeamPosition) -> void:
	trait_selected.emit(new_trait, side, team_pos)
	reset_and_hide()


func reset_and_hide() -> void:
	beastie_select_ui.hide()
	plays_select_ui.hide()
	trait_select_ui.hide()
	beastie_select_ui.reset()
	plays_select_ui.reset()
	trait_select_ui.reset()
	hide()


func hide_all_ui() -> void:
	beastie_select_ui.hide()
	plays_select_ui.hide()
	trait_select_ui.hide()


func show_beastie_select_ui(side : Global.MySide, team_pos : TeamController.TeamPosition) -> void:
	show()
	hide_all_ui()
	beastie_select_ui.show()
	beastie_select_ui.side = side
	beastie_select_ui.team_pos = team_pos
	beastie_select_ui.update_grid()


func show_plays_select_ui(beastie : Beastie, slot_index : int, side : Global.MySide, team_pos : TeamController.TeamPosition) -> void:
	show()
	hide_all_ui()
	plays_select_ui.show()
	plays_select_ui.beastie = beastie
	plays_select_ui.side = side
	plays_select_ui.team_pos = team_pos
	plays_select_ui.slot_index = slot_index


func show_trait_select_ui(beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition) -> void:
	show()
	hide_all_ui()
	trait_select_ui.show()
	trait_select_ui.beastie = beastie
	trait_select_ui.side = side
	trait_select_ui.team_pos = team_pos
