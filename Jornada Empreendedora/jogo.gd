extends Node2D

@onready var popup        = $ParallaxBackground/Mensagem
@onready var sala         = get_node("/root/Sala")
@onready var botao_turno  = $ParallaxBackground/Button2
@onready var polygon      = $ParallaxBackground/Placar
@onready var botao_leg    = $ParallaxBackground/Button
# Labels para nomes dos jogadores (J1 a J6)
@onready var label_j1     = $ParallaxBackground/Placar/J1
@onready var label_j2     = $ParallaxBackground/Placar/J2
@onready var label_j3     = $ParallaxBackground/Placar/J3
@onready var label_j4     = $ParallaxBackground/Placar/J4
@onready var label_j5     = $ParallaxBackground/Placar/J5
@onready var label_j6     = $ParallaxBackground/Placar/J6
# Labels para casas dos jogadores (C1 a C6)
@onready var label_c1     = $ParallaxBackground/Placar/C1
@onready var label_c2     = $ParallaxBackground/Placar/C2
@onready var label_c3     = $ParallaxBackground/Placar/C3
@onready var label_c4     = $ParallaxBackground/Placar/C4
@onready var label_c5     = $ParallaxBackground/Placar/C5
@onready var label_c6     = $ParallaxBackground/Placar/C6

var jogadores_nodes = []
var posicoes        = []
var jogador_da_vez  = 0
var caminhos        = []
var meu_id          = -1
var meu_nome        = ""
var labels_jogadores = []  # Array para labels de nomes
var labels_casas    = []   # Array para labels de casas

func _ready():
	
	polygon.visible = false
	
	# Inicializa arrays de labels
	labels_jogadores = [label_j1, label_j2, label_j3, label_j4, label_j5, label_j6]
	labels_casas    = [label_c1, label_c2, label_c3, label_c4, label_c5, label_c6]
	
	randomize()
	print("Iniciando _ready para Jogo.tscn, Peer ID:", multiplayer.get_unique_id())
	
	# Espera pelo menos 2 jogadores na sala
	while sala.jogadores.size() < 2:
		print("Aguardando sincronização da lista de jogadores:", sala.jogadores)
		await get_tree().create_timer(0.1).timeout
	
	# Descobre o índice local na lista
	var peer_id = multiplayer.get_unique_id()
	for i in range(sala.jogadores.size()):
		if sala.jogadores[i].has("peer_id") and sala.jogadores[i]["peer_id"] == peer_id:
			meu_id   = i
			meu_nome = sala.jogadores[i]["nome"]
			break
	
	if meu_id == -1:
		print("Erro: Jogador local não encontrado na lista! Peer ID:", peer_id, "Jogadores:", sala.jogadores)
		botao_turno.disabled = true
		botao_turno.text     = "ERRO: Jogador não encontrado"
		return
	
	print("Jogador local inicializado: ID=", meu_id, "Nome=", meu_nome, "Peer ID=", peer_id)
	
	inicializar_jogo()
	configurar_controles()
	
	# Se for servidor, dispara o turno inicial e sincroniza estado
	if multiplayer.is_server():
		sala.atualizar_turno(sala.turno_atual)
		sala.sincronizar_estado_jogo(posicoes)

func inicializar_jogo():
	# Definir caminhos completos conforme original
	caminhos = [
		# Caminho do jogador 1 (exemplo)
		[Vector2(115,120), Vector2(290, 115), Vector2(420, 120), Vector2(259, 1112),
		 Vector2(183, 1070), Vector2(600, 100), Vector2(700, 100), Vector2(700, 200),
		 Vector2(600, 200), Vector2(500, 200), Vector2(400, 200), Vector2(300, 200),
		 Vector2(200, 200), Vector2(100, 200), Vector2(100, 300), Vector2(200, 300),
		 Vector2(300, 300), Vector2(400, 300), Vector2(500, 300), Vector2(600, 300),
		 Vector2(700, 300), Vector2(700, 400), Vector2(600, 400), Vector2(500, 400),
		 Vector2(400, 400), Vector2(300, 400), Vector2(200, 400), Vector2(100, 400)],

		# Caminho do jogador 2
		[Vector2(115, 165), Vector2(355, 115), Vector2(485, 120), Vector2(260, 1100),
		 Vector2(190, 1050), Vector2(590, 90), Vector2(690, 90), Vector2(690, 180),
		 Vector2(590, 180), Vector2(480, 180), Vector2(380, 180), Vector2(280, 180),
		 Vector2(180, 180), Vector2(80, 180), Vector2(80, 280), Vector2(180, 280),
		 Vector2(280, 280), Vector2(380, 280), Vector2(480, 280), Vector2(580, 280),
		 Vector2(680, 280), Vector2(680, 380), Vector2(580, 380), Vector2(480, 380),
		 Vector2(380, 380), Vector2(280, 380), Vector2(180, 380), Vector2(80, 380)],

		# Caminho do jogador 3
		[Vector2(115, 210), Vector2(290, 155), Vector2(420, 160), Vector2(260, 1100),
		 Vector2(190, 1050), Vector2(590, 90), Vector2(690, 90), Vector2(690, 180),
		 Vector2(590, 180), Vector2(480, 180), Vector2(380, 180), Vector2(280, 180),
		 Vector2(180, 180), Vector2(80, 180), Vector2(80, 280), Vector2(180, 280),
		 Vector2(280, 280), Vector2(380, 280), Vector2(480, 280), Vector2(580, 280),
		 Vector2(680, 280), Vector2(680, 380), Vector2(580, 380), Vector2(480, 380),
		 Vector2(380, 380), Vector2(280, 380), Vector2(180, 380), Vector2(80, 380)],

		# Jogador 4, 5 e 6 usam o mesmo caminho do 3 para exemplo
		[Vector2(200, 120), Vector2(355, 155), Vector2(485, 160), Vector2(260, 1100),
		 Vector2(190, 1050), Vector2(590, 90), Vector2(690, 90), Vector2(690, 180),
		 Vector2(590, 180), Vector2(480, 180), Vector2(380, 180), Vector2(280, 180),
		 Vector2(180, 180), Vector2(80, 180), Vector2(80, 280), Vector2(180, 280),
		 Vector2(280, 280), Vector2(380, 280), Vector2(480, 280), Vector2(580, 280),
		 Vector2(680, 280), Vector2(680, 380), Vector2(580, 380), Vector2(480, 380),
		 Vector2(380, 380), Vector2(280, 380), Vector2(180, 380), Vector2(80, 380)],

		[Vector2(200, 165), Vector2(290, 155), Vector2(420, 200), Vector2(260, 1100),
		 Vector2(190, 1050), Vector2(590, 90), Vector2(690, 90), Vector2(690, 180),
		 Vector2(590, 180), Vector2(480, 180), Vector2(380, 180), Vector2(280, 180),
		 Vector2(180, 180), Vector2(80, 180), Vector2(80, 280), Vector2(180, 280),
		 Vector2(280, 280), Vector2(380, 280), Vector2(480, 280), Vector2(580, 280),
		 Vector2(680, 280), Vector2(680, 380), Vector2(580, 380), Vector2(480, 380),
		 Vector2(380, 380), Vector2(280, 380), Vector2(180, 380), Vector2(80, 380)],

		[Vector2(200, 210), Vector2(355, 195), Vector2(485, 200), Vector2(260, 1100),
		 Vector2(190, 1050), Vector2(590, 90), Vector2(690, 90), Vector2(690, 180),
		 Vector2(590, 180), Vector2(480, 180), Vector2(380, 180), Vector2(280, 180),
		 Vector2(180, 180), Vector2(80, 180), Vector2(80, 280), Vector2(180, 280),
		 Vector2(280, 280), Vector2(380, 280), Vector2(480, 280), Vector2(580, 280),
		 Vector2(680, 280), Vector2(680, 380), Vector2(580, 380), Vector2(480, 380),
		 Vector2(380, 380), Vector2(280, 380), Vector2(180, 380), Vector2(80, 380)],
	]
	
	jogadores_nodes = [
		$ParallaxBackground/Parallax2D/Jogador1,
		$ParallaxBackground/Parallax2D/Jogador2,
		$ParallaxBackground/Parallax2D/Jogador3,
		$ParallaxBackground/Parallax2D/Jogador4,
		$ParallaxBackground/Parallax2D/Jogador5,
		$ParallaxBackground/Parallax2D/Jogador6
	]
	
	# Posiciona e oculta sprites conforme número de jogadores
	for i in range(jogadores_nodes.size()):
		var node = jogadores_nodes[i]
		if node:
			node.visible = i < sala.jogadores.size()
			if node.visible:
				node.position = caminhos[i][0]
				print("Jogador", i+1, "posicionado em", caminhos[i][0])
		posicoes.append(0 if i < sala.jogadores.size() else -1)
	
	# Inicializa os labels Jn (nome) e Cn (casa) para todos os jogadores
	for i in range(labels_jogadores.size()):
		if i < sala.jogadores.size() and sala.jogadores[i].has("nome"):
			labels_jogadores[i].text = sala.jogadores[i]["nome"]
			labels_casas[i].text = "%02d" % posicoes[i]
			labels_jogadores[i].visible = true
			labels_casas[i].visible = true
		else:
			labels_jogadores[i].text = ""
			labels_casas[i].text = ""
			labels_jogadores[i].visible = false
			labels_casas[i].visible = false
	
	# O servidor dispara a primeira sincronização de estado
	if multiplayer.is_server():
		sala.sincronizar_estado_jogo(posicoes)

func configurar_controles():
	if not botao_turno.pressed.is_connected(executar_turno):
		botao_turno.pressed.connect(executar_turno)
	
	if sala.is_connected("jogadores_atualizados", atualizar_botao_turno):
		sala.disconnect("jogadores_atualizados", atualizar_botao_turno)
	sala.connect("jogadores_atualizados", atualizar_botao_turno)
	
	atualizar_botao_turno()

func atualizar_botao_turno():
	jogador_da_vez = sala.turno_atual
	var eh_minha_vez = jogador_da_vez == meu_id
	botao_turno.disabled = not eh_minha_vez
	if eh_minha_vez:
		botao_turno.text = "ROLAR DADO"
	else:
		var nome = "Desconhecido"
		if jogador_da_vez < sala.jogadores.size() and sala.jogadores[jogador_da_vez].has("nome"):
			nome = sala.jogadores[jogador_da_vez]["nome"]
		botao_turno.text = "Vez de %s" % nome
	print("Botão atualizado: vez=", jogador_da_vez, "meu_id=", meu_id, "habilitado=", eh_minha_vez)

	# Atualiza visibilidade para desconexões e labels
	for i in range(jogadores_nodes.size()):
		var node = jogadores_nodes[i]
		if node:
			node.visible = i < sala.jogadores.size()
			# opcional: resetar posição e posicoes quando desconectado
			if not node.visible:
				posicoes[i] = -1
				labels_jogadores[i].text = ""
				labels_casas[i].text = ""
				labels_jogadores[i].visible = false
				labels_casas[i].visible = false
			else:
				labels_jogadores[i].text = sala.jogadores[i]["nome"] if i < sala.jogadores.size() and sala.jogadores[i].has("nome") else ""
				labels_casas[i].text = "Casa: %02d" % posicoes[i] if posicoes[i] >= 0 else ""
				labels_jogadores[i].visible = true
				labels_casas[i].visible = true

func executar_turno():
	if jogador_da_vez != meu_id:
		botao_turno.disabled = true
		return
	
	# Rola, calcula posição e anima local
	var dado      = randi_range(1, 6)
	var caminho   = caminhos[jogador_da_vez]
	var pos_atual = posicoes[jogador_da_vez] + dado
	pos_atual = min(pos_atual, caminho.size() - 1)
	posicoes[jogador_da_vez] = pos_atual
	
	var node = jogadores_nodes[jogador_da_vez]
	var tween = create_tween()
	tween.tween_property(node, "position", caminho[pos_atual], 0.5).set_ease(Tween.EASE_IN_OUT)
	
	var desc = verificar_efeito_casa(pos_atual, jogador_da_vez)
	popup.title = "Casa %02d: " % [pos_atual]
	popup.dialog_text = "Dado valor: %d \n \n %s " % [dado, desc]
	popup.popup_centered()
	
	# Atualiza o label Cn do jogador local
	if jogador_da_vez < labels_casas.size():
		labels_casas[jogador_da_vez].text = "Casa: %02d" % pos_atual
	
	# RPC para TODOS os peers usando rpc()
	rpc("atualizar_posicoes_jogadores", posicoes)
	
	# Passa o turno
	passar_turno()

func verificar_efeito_casa(pos, idx):
	var efeitos = [
		"Início - Boa sorte na sua jornada!",              # 0
		"Passo firme - Você está no caminho certo!",      # 1
		"Vento a favor - Movimentação suave!",            # 2
		"Pedra no caminho - Cuidado ao avançar!",         # 3
		"Floresta densa - Observe bem o terreno!",        # 4
		"Atalho - Avance 2 casas!",                       # 5
		"Rio calmo - Um momento de tranquilidade.",       # 6
		"Ponte estreita - Equilíbrio é a chave!",         # 7
		"Acampamento - Recupere suas energias.",          # 8
		"Trilha sinuosa - Um desafio à frente!",          # 9
		"Armadilha - Volte 2 casas!",                     # 10
		"Cachoeira - Um espetáculo da natureza!",         # 11
		"Vila amigável - Os locais te saúdam.",           # 12
		"Caverna escura - Um mistério à espreita.",       # 13
		"Clareira - Um lugar perfeito para descansar.",   # 14
		"Moeda dourada - Nada acontece.",                 # 15
		"Montanha alta - A vista é incrível!",            # 16
		"Chuva forte - O caminho está escorregadio!",     # 17
		"Fogueira - Aqueça-se antes de continuar.",       # 18
		"Cruzamento - Escolha seu destino com sabedoria.", # 19
		"Cansaço - Perde uma rodada!",                    # 20
		"Luz da lua - A noite guia seus passos.",         # 21
		"Ruínas antigas - Segredos do passado.",          # 22
		"Lago sereno - Reflita sobre sua jornada.",       # 23
		"Tempestade - Proteja-se e aguarde!",             # 24
		"Planície aberta - Liberdade para avançar!",      # 25
		"Floresta encantada - Magia no ar!",              # 26
		"Chegada - Você está perto do fim!",              # 27
	]
	
	# Aplica efeitos especiais
	match pos:
		5:
			posicoes[idx] = min(pos + 2, caminhos[idx].size() - 1)
			create_tween().tween_property(jogadores_nodes[idx], "position", caminhos[idx][posicoes[idx]], 0.5).set_ease(Tween.EASE_IN_OUT)
			# Atualiza o label Cn após efeito especial
			if idx < labels_casas.size():
				labels_casas[idx].text = "Casa: %02d" % posicoes[idx]
		10:
			posicoes[idx] = max(pos - 2, 0)
			create_tween().tween_property(jogadores_nodes[idx], "position", caminhos[idx][posicoes[idx]], 0.5).set_ease(Tween.EASE_IN_OUT)
			# Atualiza o label Cn após efeito especial
			if idx < labels_casas.size():
				labels_casas[idx].text = "Casa: %02d" % posicoes[idx]
	
	return efeitos[pos]

func passar_turno():
	if multiplayer.is_server():
		sala.solicitar_proximo_turno()
	else:
		sala.rpc_id(1, "solicitar_proximo_turno")

@rpc("any_peer", "reliable")
func atualizar_posicoes_jogadores(novas: Array):
	posicoes = novas
	for i in range(min(posicoes.size(), jogadores_nodes.size())):
		if posicoes[i] >= 0 and jogadores_nodes[i] and is_instance_valid(jogadores_nodes[i]):
			var alvo = caminhos[i][ clamp(posicoes[i], 0, caminhos[i].size() - 1) ]
			create_tween().tween_property(jogadores_nodes[i], "position", alvo, 0.5).set_ease(Tween.EASE_IN_OUT)
			print("Jogador", i+1, "posicionado em", alvo)
			# Atualiza o label Cn para o jogador
			if i < labels_casas.size():
				labels_casas[i].text = "Casa: %02d" % posicoes[i]
	
	atualizar_botao_turno()

func _on_button_3_pressed() -> void:
	pass

func _on_button_pressed() -> void:
	polygon.visible = true
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if polygon.visible:
			# Get the rectangle of the Label in global coordinates
			var label_rect = polygon.get_global_rect()
			# Check if the click position is outside the Label's rectangle
			if not label_rect.has_point(event.position):
				polygon.visible = false
