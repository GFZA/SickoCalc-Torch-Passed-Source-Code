extends Button

func _ready():
	if Global.is_on_mobile:
		var normal_style = get_theme_stylebox("normal")
		add_theme_stylebox_override("hover", normal_style)
