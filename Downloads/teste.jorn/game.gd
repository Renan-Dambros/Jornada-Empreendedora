extends Node

var jogadores_na_partida: Array = []

func configurar_jogadores(lista_jogadores: Array):
	jogadores_na_partida = lista_jogadores
	print("Jogadores configurados para a partida: ", jogadores_na_partida)
