extends Control

@onready var label1 = $Label1
@onready var label2 = $Label2
@onready var label3 = $Label3
@onready var label4 = $Label4
@onready var label5 = $Label5
@onready var label6 = $Label6
@onready var label_ip_sala = $ip
@onready var sair_button = $Sair
@onready var pronto_button = $Pronto
@onready var iniciar_button = $Iniciar

func _ready():
	Sala.jogadores_atualizados.connect(atualizar_labels)
	atualizar_labels()

	if Rede.servidor_ip != "":
		atualizar_ip_servidor(Rede.servidor_ip)

	sair_button.pressed.connect(_on_sair_pressed)
	pronto_button.pressed.connect(_on_pronto_pressed)
	iniciar_button.pressed.connect(_on_iniciar_pressed)
	
	iniciar_button.visible = false
	atualizar_botao_pronto()

func atualizar_labels():
	var labels = [label1, label2, label3, label4, label5, label6]
	
	for i in range(labels.size()):
		if i < Sala.jogadores.size():
			var jogador = Sala.jogadores[i]
			var nome = jogador["nome"]
			
			# Label1 sempre mostra como Proprietário
			if i == 0:
				labels[i].text = nome + " (Proprietário)"
			# Demais labels mostram status normal
			else:
				var status = " (Pronto)" if Sala.status_pronto.get(nome, false) else " (Não Pronto)"
				labels[i].text = nome + status
		else:
			labels[i].text = "Esperando..."
	
	verificar_todos_prontos()

func atualizar_botao_pronto():
	var nome = Jogador.nome
	if Sala.jogadores.size() > 0 and Sala.jogadores[0]["nome"] == nome:
		# Se for o primeiro jogador (Proprietário)
		pronto_button.disabled = true
		pronto_button.text = "PROPRIETÁRIO"
		pronto_button.add_theme_color_override("font_color", Color.GOLDENROD)
	else:
		# Para outros jogadores
		pronto_button.disabled = false
		if Sala.status_pronto.has(nome):
			pronto_button.text = "PRONTO" if Sala.status_pronto[nome] else "NÃO PRONTO"
			pronto_button.add_theme_color_override("font_color", Color.GREEN if Sala.status_pronto[nome] else Color.RED)

func verificar_todos_prontos():
	if Sala.jogadores.size() < 2:  # Pelo menos 2 jogadores para começar
		iniciar_button.visible = false
		return
	
	var todos_prontos = true
	for jogador in Sala.jogadores:
		# O primeiro jogador (proprietário) não precisa estar "pronto"
		if jogador["nome"] == Sala.jogadores[0]["nome"]:
			continue
			
		if not Sala.status_pronto.get(jogador["nome"], false):
			todos_prontos = false
			break
	
	# Mostra o botão apenas para o proprietário se todos estiverem prontos
	iniciar_button.visible = todos_prontos and Sala.jogadores.size() > 0 and Sala.jogadores[0]["nome"] == Jogador.nome

func _on_pronto_pressed():
	var nome = Jogador.nome
	# Verifica novamente se não é o proprietário
	if Sala.jogadores.size() > 0 and Sala.jogadores[0]["nome"] != nome:
		Sala.rpc_id(1, "alternar_status", nome)
		# Atualiza localmente para resposta mais rápida
		if Sala.status_pronto.has(nome):
			Sala.status_pronto[nome] = not Sala.status_pronto[nome]
		atualizar_botao_pronto()
		atualizar_labels()

func _on_iniciar_pressed():
	if Sala.jogadores.size() > 0 and Sala.jogadores[0]["nome"] == Jogador.nome:
		verificar_todos_prontos()
		if iniciar_button.visible:
			# Envia comando para todos os clientes iniciarem o jogo
			Sala.rpc("iniciar_jogo")
			# Muda a cena localmente também
			get_tree().change_scene_to_file("res://Jogo.tscn")

func atualizar_ip_servidor(ip):
	label_ip_sala.text = "IP da sala: " + ip

func _on_sair_pressed():
	Sala.rpc_id(1, "remover_jogador", Jogador.nome)
	await get_tree().create_timer(0.2).timeout
	Rede.encerrar_conexao()
	get_tree().change_scene_to_file("res://Tela_Sala.tscn")
