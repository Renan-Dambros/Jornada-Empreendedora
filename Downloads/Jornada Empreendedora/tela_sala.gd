extends Control

@onready var popup_criar_sala = $Criar
@onready var popup_entrar_sala = $Entrar
@onready var line_edit_senha_sala_criar = $Criar/Senha_Criar_S
@onready var line_edit_ip_servidor = $Entrar/Nome_Entrar_S
@onready var line_edit_senha_sala_entrar = $Entrar/Senha_Entrar_S

var rede: Rede

func _ready():
	rede = get_node("/root/Rede")
	rede.conexao_sucesso.connect(_on_conexao_sucesso)
	rede.conexao_falhou.connect(_on_conexao_falhou)

func _on_criar_sala_pressed():
	popup_criar_sala.popup_centered()
	line_edit_senha_sala_criar.grab_focus()

func _on_entra_sala_pressed():
	popup_entrar_sala.popup_centered()
	line_edit_ip_servidor.grab_focus()

func _on_criar_pressed():
	var senha_sala = line_edit_senha_sala_criar.text.strip_edges()
	if senha_sala.is_empty():
		OS.alert("Digite uma senha para a sala!", "Erro")
		return
	
	rede.senha_sala = senha_sala

	if rede.criar_servidor():
		Sala.adicionar_jogador(Jogador.nome)  # Apenas local no servidor
		popup_criar_sala.hide()
		get_tree().change_scene_to_file("res://Sala_Espera.tscn")

func _on_entrar_pressed():
	var ip_servidor = line_edit_ip_servidor.text.strip_edges()
	var senha_sala = line_edit_senha_sala_entrar.text.strip_edges()
	
	if ip_servidor.is_empty() or senha_sala.is_empty():
		OS.alert("Preencha todos os campos!", "Erro")
		return

	rede.servidor_ip = ip_servidor
	rede.senha_sala = senha_sala
	rede.conectar_ao_servidor()

func _on_conexao_sucesso():
	Sala.adicionar_jogador.rpc_id(1, Jogador.nome)  # Cliente envia nome ao servidor
	popup_entrar_sala.hide()
	get_tree().change_scene_to_file("res://Sala_Espera.tscn")

func _on_conexao_falhou(mensagem: String):
	OS.alert("Falha na conexão:\n" + mensagem, "Erro")
	popup_entrar_sala.hide()
