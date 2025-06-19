extends Button

func _ready():
	# Conecta o sinal "pressed" do botão à função que muda de cena
	self.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	# Carrega e muda para a nova cena
	get_tree().change_scene_to_file("res://Tela_Nome.tscn")
