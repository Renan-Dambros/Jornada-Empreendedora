extends Path2D

@onready var linha = $Line2D

func _ready():
	linha.clear_points()
	var pontos = curve.get_baked_points()
	for p in pontos:
		linha.add_point(p)
