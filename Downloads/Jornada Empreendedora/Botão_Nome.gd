extends Button

func _on_pressed():
	var campo_nome = get_node("../LineEdit")  # Ajuste o caminho conforme sua estrutura
	if campo_nome.text.strip_edges() == "":
		print("Nome não pode ser vazio!")
		return
	
	Jogador.nome = campo_nome.text
	print("Nome salvo:", Jogador.nome)
	get_tree().change_scene_to_file("res://Tela_Sala.tscn")
