class_name Main
extends Control

@onready var left_beastie_column: BeastieColumn = %LeftBeastieColumn
@onready var right_beastie_column: BeastieColumn = %RightBeastieColumn
@onready var select_uis: SelectUIs = %SelectUIs


func _ready() -> void:
	left_beastie_column.beastie_row.beastie_select_ui_requested.connect(select_uis.show_beastie_select_ui.bind(Global.MySide.LEFT))
	right_beastie_column.beastie_row.beastie_select_ui_requested.connect(select_uis.show_beastie_select_ui.bind(Global.MySide.RIGHT))
	select_uis.beastie_selected.connect(_on_beastie_selected)


func _on_beastie_selected(beastie : Beastie, side : Global.MySide) -> void:
	var column : BeastieColumn = left_beastie_column if side == Global.MySide.LEFT else right_beastie_column
	column.beastie = beastie
