extends Node

signal conexao_sucesso
signal conexao_falhou(mensagem: String)

var senha_sala = ""
var servidor_ip = ""
var is_server = false
var peer: ENetMultiplayerPeer

func _ready():
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_connected_to_server():
	print("Conectado com sucesso ao servidor!")
	conexao_sucesso.emit()

func _on_connection_failed():
	var mensagem = "Falha na conexão com o servidor."
	print(mensagem)
	conexao_falhou.emit(mensagem)

func _on_server_disconnected():
	var mensagem = "Desconectado do servidor."
	print(mensagem)
	conexao_falhou.emit(mensagem)

func criar_servidor():
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(13579, 10)
	
	if result == OK:
		multiplayer.multiplayer_peer = peer
		is_server = true
		servidor_ip = get_ip_local()
		print("Servidor criado com sucesso no IP: ", servidor_ip)
		return true
	else:
		var mensagem = "Erro ao criar servidor (Código: %d)" % result
		print(mensagem)
		conexao_falhou.emit(mensagem)
		return false

func conectar_ao_servidor():
	if servidor_ip.is_empty():
		var mensagem = "IP do servidor não foi definido."
		print(mensagem)
		conexao_falhou.emit(mensagem)
		return false

	peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(servidor_ip, 13579)
	
	if result == OK:
		multiplayer.multiplayer_peer = peer
		is_server = false
		print("Conectando ao servidor em: ", servidor_ip)
		return true
	else:
		var mensagem = "Erro ao conectar ao servidor (Código: %d)" % result
		print(mensagem)
		conexao_falhou.emit(mensagem)
		return false

func get_ip_local():
	var ip_list = IP.get_local_addresses()
	for ip in ip_list:
		if ip.begins_with("192.168.") or ip.begins_with("10.") or ip.begins_with("172."):
			return ip
	return "127.0.0.1"

func encerrar_conexao():
	if peer:
		peer.close()
	multiplayer.multiplayer_peer = null
	is_server = false
