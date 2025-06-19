extends Camera2D

var touch_positions := {}
var initial_zoom := Vector2(1, 1)
var max_zoom := 2.0
var zoom_speed := 0.01
var last_drag_position: Vector2 = Vector2.INF

# Limites do mundo (ajuste conforme o tamanho do seu mapa/jogo)
var world_min := Vector2(0, 0)
var world_max := Vector2(1152, 648)

# Suavização do movimento e zoom
var smooth_factor := 0.3
var target_zoom := Vector2(1, 1)  # Variável para controlar o zoom suavizado

func _ready():
	initial_zoom = zoom

	# Definindo os limites da câmera (opcional, mas ajuda)
	limit_left = world_min.x
	limit_top = world_min.y
	limit_right = world_max.x
	limit_bottom = world_max.y
	set_limit_drawing_enabled(true)  # Apenas para ver os limites na cena

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_positions[event.index] = event.position
			if touch_positions.size() == 1:
				last_drag_position = event.position
		else:
			touch_positions.erase(event.index)
			if touch_positions.size() < 2:
				remove_meta("last_distance")

	elif event is InputEventScreenDrag:
		touch_positions[event.index] = event.position

		if touch_positions.size() == 1:
			# Movimento com um dedo (drag)
			if last_drag_position != Vector2.INF:
				var delta = last_drag_position - event.position
				var target_position = position + delta * zoom

				# Interpolação para suavizar o movimento usando lerp
				position = position.lerp(target_position, smooth_factor)

				# Limita a posição da câmera dentro dos limites do mundo
				position.x = clamp(position.x, world_min.x, world_max.x)
				position.y = clamp(position.y, world_min.y, world_max.y)

			last_drag_position = event.position

		elif touch_positions.size() == 2:
			var keys = touch_positions.keys()
			var pos1 = touch_positions[keys[0]]
			var pos2 = touch_positions[keys[1]]
			var current_distance = pos1.distance_to(pos2)

			if not has_meta("last_distance"):
				set_meta("last_distance", current_distance)
				return

			var last_distance = get_meta("last_distance")
			var diff = current_distance - last_distance

			if abs(diff) > 2:
				var zoom_change = 1.0 - diff * zoom_speed
				var new_zoom = zoom * zoom_change

				# Clampa o novo zoom para garantir que ele não ultrapasse os limites
				new_zoom.x = clamp(new_zoom.x, initial_zoom.x, max_zoom)
				new_zoom.y = clamp(new_zoom.y, initial_zoom.y, max_zoom)

				# Suaviza a transição de zoom
				target_zoom = target_zoom.lerp(new_zoom, smooth_factor)

			set_meta("last_distance", current_distance)

func _process(delta):
	# Aplica o zoom suavizado
	zoom = target_zoom

func _unhandled_input(event):
	if event is InputEventScreenTouch and not event.pressed:
		last_drag_position = Vector2.INF
