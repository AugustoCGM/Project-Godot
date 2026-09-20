extends Camera2D

var target: Node2D
var shake_intensity: float = 0.0
var shake_fade: float = 5.0

func _ready() -> void:
	get_target()

func _process(delta: float) -> void:
	# 1. Acompanhamento do Jogador
	if target:
		position = target.position
	
	# 2. Lógica de Tremor (Screen Shake)
	if shake_intensity > 0:
		shake_intensity = lerpf(shake_intensity, 0.0, shake_fade * delta)
		var random_x = randf_range(-1.0, 1.0)
		var random_y = randf_range(-1.0, 1.0)
		offset = Vector2(random_x, random_y) * shake_intensity
	else:
		offset = Vector2.ZERO

func get_target():
	var nodes = get_tree().get_nodes_in_group("Player")
	if nodes.size() == 0:
		push_error("Player não encontrado")
		return
	target = nodes[0]

# Função pública para receber o impacto do player.gd
func apply_shake(strength: float, fade_speed: float = 5.0):
	shake_intensity = strength
	shake_fade = fade_speed
