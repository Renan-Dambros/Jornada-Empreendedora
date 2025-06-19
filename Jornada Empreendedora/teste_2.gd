extends Control

const PORTA_PADRAO := 12345
const MAX_JOGADORES := 6

@onready var entrada_nome_servidor = $LineEdit          # Campo para nome de quem cria o servidor
@onready var entrada_nome_cliente = $LineEdit2          # Campo para nome de quem entra como cliente
@onready var botao_criar = $Button                      # Botão de criar servidor
@onready var botao_entrar = $Button2                    # Botão de entrar no servidor

var udp_server: UDPServer
var servidor_ip: String = ""
var nome_jogador: String = ""

func _ready():
	botao_criar.pressed.connect(_criar_servidor)
	botao_entrar.pressed.connect(_entrar_servidor)
	_iniciar_escuta_udp()

func _criar_servidor():
	nome_jogador = entrada_nome_servidor.text.strip_edges()
	if nome_jogador == "":
		push_warning("Digite seu nome antes de criar o servidor.")
		return

	var peer = ENetMultiplayerPeer.new()
	var erro = peer.create_server(PORTA_PADRAO, MAX_JOGADORES)
	if erro != OK:
		push_error("Erro ao criar servidor!")
		return

	multiplayer.multiplayer_peer = peer
	print("Servidor criado! Nome do jogador:", nome_jogador)

	# Obter IP local (ignora 127.0.0.1)
	var ip_local = ""
	for ip in IP.get_local_addresses():
		if not ip.begins_with("127"):
			ip_local = ip
			break

	# Enviar IP via broadcast UDP (corrigido)
	var udp = PacketPeerUDP.new()
	udp.set_broadcast_enabled(true)
	udp.connect_to_host("255.255.255.255", PORTA_PADRAO + 1)
	udp.put_packet(("SERVIDOR:" + ip_local).to_utf8_buffer())
	print("Broadcast enviado com IP:", ip_local)

func _entrar_servidor():
	nome_jogador = entrada_nome_cliente.text.strip_edges()
	if nome_jogador == "":
		push_warning("Digite seu nome antes de entrar no servidor.")
		return

	if servidor_ip == "":
		print("Aguardando descoberta do IP do servidor...")
		return

	var peer = ENetMultiplayerPeer.new()
	var erro = peer.create_client(servidor_ip, PORTA_PADRAO)
	if erro != OK:
		push_error("Erro ao conectar!")
		return

	multiplayer.multiplayer_peer = peer
	print("Conectado ao servidor! Nome do jogador:", nome_jogador)

func _iniciar_escuta_udp():
	udp_server = UDPServer.new()
	udp_server.listen(PORTA_PADRAO + 1)
	set_process(true)

func _process(_delta):
	if udp_server and udp_server.is_connection_available():
		var cliente = udp_server.take_connection()
		var dados = cliente.get_packet().get_string_from_utf8()
		if dados.begins_with("SERVIDOR:"):
			servidor_ip = dados.replace("SERVIDOR:", "")
			print("IP do servidor detectado automaticamente:", servidor_ip)
