extends Button

func _ready():
	get_parent().get_node("Polygon2D").visible = false

func _pressed():
	get_parent().get_node("Polygon2D").visible = true
