extends Control

@onready var line_edit_nome = $LineEdit  # Referência ao LineEdit para o nome
@onready var button_confirmar = $Button  # Referência ao botão de confirmação

# Quando o jogador clicar no botão "Confirmar"
func _on_button_pressed():
	var nome = $LineEdit.text
	if nome != "":
		Jogador.nome = nome
		get_tree().change_scene_to_file("res://Tela_Sala.tscn")
	else:
		print("Por favor, insira um nome.")
