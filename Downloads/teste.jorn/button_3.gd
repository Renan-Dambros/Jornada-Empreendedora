extends Button

func _ready():
	get_parent().get_node("Legenda").visible = false
	get_parent().get_node("Legenda2").visible = false
	get_parent().get_node("Button4").visible = false

func _pressed():
	get_parent().get_node("Legenda").visible = true
	get_parent().get_node("Legenda2").visible = true
	get_parent().get_node("Button4").visible = true
