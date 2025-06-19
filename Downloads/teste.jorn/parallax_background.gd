extends ParallaxBackground

# Defina aqui a posição máxima que o fundo pode alcançar (negativo para movimento para a direita)
var max_scroll_offset = 1935 

func _unhandled_input(event):
	if event is InputEventScreenDrag:
		var delta = event.relative
		scroll_offset.x += delta.x  # Atualiza a posição com base no movimento
		
		# Limita o scroll_offset entre -max_scroll_offset (máximo para a direita) e 0 (posição inicial)
		scroll_offset.x = clamp(scroll_offset.x, -max_scroll_offset, 0)
		
		# Opcional: Debug para ver os valores
		print("Posição atual: ", scroll_offset.x, " | Delta: ", delta.x)
