extends Button

func _pressed():
	get_parent().get_node("Legenda").visible = false
	get_parent().get_node("Legenda2").visible = false
	get_parent().get_node("Button4").visible = false
