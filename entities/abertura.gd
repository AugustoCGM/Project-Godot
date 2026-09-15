extends Node2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Tenta encontrar o jogador na cena pelo grupo "Player"
	var players = get_tree().get_nodes_in_group("Player")
	
	if players.size() > 0:
		var player = players[0]
		
		# 1. Posiciona o player exatamente no centro da abertura
		player.global_position = global_position
		
		# 2. Esconde o player e desativa o movimento e a gravidade
		player.visible = false
		player.set_physics_process(false)
		
		# 3. Toca a animação da abertura
		anim_sprite.play("Abertura")
		
		# 4. Espera a animação terminar
		await anim_sprite.animation_finished
		
		# 5. Revela o player e reativa a física
		player.visible = true
		player.set_physics_process(true)
	else:
		push_error("Abertura: Nenhum nó do grupo 'Player' foi encontrado na cena.")
