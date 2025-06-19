extends Node

signal jogadores_atualizados

var jogadores: Array = []  # Array de dicionários {"nome": String, "peer_id": int}
var status_pronto: Dictionary = {}  # Status de cada jogador (pronto ou não)
var turno_atual: int = 0  # Índice do jogador atual
var clientes_confirmados: Dictionary = {}  # Rastrear confirmações de sincronização

func _ready():
	print("Sala inicializada. Servidor: ", multiplayer.is_server(), " Peers conectados: ", multiplayer.get_peers())
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

@rpc("any_peer", "reliable")
func adicionar_jogador(nome: String):
	if not jogadores_contem_nome(nome):
		var peer_id = multiplayer.get_remote_sender_id()
		if peer_id == 0 and multiplayer.is_server():
			peer_id = multiplayer.get_unique_id()
		var jogador = {"nome": nome, "peer_id": peer_id}
		jogadores.append(jogador)
		status_pronto[nome] = false
		clientes_confirmados[peer_id] = false
		print("Adicionado jogador: Nome=", nome, " Peer ID=", peer_id, " Jogadores=", jogadores)
		emit_signal("jogadores_atualizados")
		rpc("sincronizar_lista", jogadores, status_pronto)

@rpc("any_peer", "reliable")
func alternar_status(nome: String):
	if nome in status_pronto:
		status_pronto[nome] = not status_pronto[nome]
		print("Status alterado: ", nome, " Pronto=", status_pronto[nome])
		emit_signal("jogadores_atualizados")
		rpc("sincronizar_status", status_pronto)

@rpc("authority", "reliable")
func sincronizar_lista(lista: Array, status: Dictionary):
	jogadores = lista
	status_pronto = status
	print("Lista sincronizada recebida: ", jogadores)
	emit_signal("jogadores_atualizados")

@rpc("authority", "reliable")
func sincronizar_status(status: Dictionary):
	status_pronto = status
	print("Status sincronizado: ", status_pronto)
	emit_signal("jogadores_atualizados")

@rpc("any_peer", "reliable")
func remover_jogador(nome: String):
	for i in range(jogadores.size()):
		if jogadores[i]["nome"] == nome:
			var peer_id = jogadores[i]["peer_id"]
			jogadores.remove_at(i)
			status_pronto.erase(nome)
			clientes_confirmados.erase(peer_id)
			print("Jogador removido: ", nome, " Jogadores=", jogadores)
			emit_signal("jogadores_atualizados")
			rpc("sincronizar_lista", jogadores, status_pronto)
			break

@rpc("authority", "reliable")
func iniciar_jogo():
	print("Iniciando jogo para todos os jogadores. Jogadores=", jogadores)
	if jogadores.size() < 2:
		print("Erro: Menos de 2 jogadores, não pode iniciar o jogo")
		return
	get_tree().change_scene_to_file("res://Jogo.tscn")

@rpc("any_peer", "reliable")
func solicitar_proximo_turno():
	if multiplayer.is_server():
		if jogadores.size() < 2:
			print("Erro: Menos de 2 jogadores, não pode avançar turno")
			return
		turno_atual = (turno_atual + 1) % jogadores.size()
		print("Servidor: Novo turno_atual=", turno_atual, " Jogador=", jogadores[turno_atual]["nome"])
		emit_signal("jogadores_atualizados")
		rpc("atualizar_turno", turno_atual)

@rpc("authority", "reliable")
func atualizar_turno(novo_turno: int):
	turno_atual = novo_turno
	print("Turno atualizado: turno_atual=", turno_atual, " Jogador=", jogadores[turno_atual]["nome"] if turno_atual < jogadores.size() else "Desconhecido")
	emit_signal("jogadores_atualizados")

@rpc("authority", "reliable")
func forcar_atualizacao_posicoes(novas_posicoes: Array):
	var jogo_node = get_node("/root/Jogo")
	if jogo_node and is_instance_valid(jogo_node):
		print("Forçando atualização de posições: ", novas_posicoes)
		jogo_node.atualizar_posicoes_jogadores(novas_posicoes)
	else:
		print("Erro: Nó /root/Jogo não encontrado")

@rpc("any_peer", "reliable")
func sincronizar_estado_jogo(novas_posicoes: Array):
	if multiplayer.is_server():
		if jogadores.size() < 2:
			print("Erro: Menos de 2 jogadores, não pode sincronizar estado")
			return
		print("Servidor: Sincronizando estado - Posições=", novas_posicoes)
		rpc("atualizar_estado_jogo", novas_posicoes)

@rpc("authority", "reliable")
func atualizar_estado_jogo(novas_posicoes: Array):
	var jogo_node = get_node("/root/Jogo")
	var tentativas = 0
	while not jogo_node and tentativas < 50:
		print("Aguardando carregamento de /root/Jogo, tentativa %d" % (tentativas + 1))
		await get_tree().create_timer(0.1).timeout
		jogo_node = get_node("/root/Jogo")
		tentativas += 1
	
	if jogo_node and is_instance_valid(jogo_node):
		print("Atualizando estado do jogo: Posições=", novas_posicoes, " Turno=", turno_atual)
		jogo_node.posicoes = novas_posicoes
		jogo_node.jogador_da_vez = turno_atual
		jogo_node.atualizar_posicoes_jogadores(novas_posicoes)
	else:
		print("Erro: Nó /root/Jogo não encontrado após %d tentativas" % tentativas)

func jogadores_contem_nome(nome: String) -> bool:
	for jogador in jogadores:
		if jogador["nome"] == nome:
			return true
	return false

func _on_peer_connected(id: int):
	print("Novo peer conectado: ", id)
	emit_signal("jogadores_atualizados")

func _on_peer_disconnected(id: int):
	print("Peer desconectado: ", id)
	for i in range(jogadores.size() - 1, -1, -1):
		if jogadores[i]["peer_id"] == id:
			var nome = jogadores[i]["nome"]
			jogadores.remove_at(i)
			status_pronto.erase(nome)
			clientes_confirmados.erase(id)
			print("Jogador removido por desconexão: ", nome)
			emit_signal("jogadores_atualizados")
			rpc("sincronizar_lista", jogadores, status_pronto)
