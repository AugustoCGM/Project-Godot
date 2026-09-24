extends CharacterBody2D

enum MrChopsState {
	idle,
	walk,
	bite,
	dead
}

@onready var ani: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var raycasts: Node2D = $RayCasts
@onready var wall_detector: RayCast2D = $RayCasts/WallDetector
@onready var ground_detector: RayCast2D = $RayCasts/GroundDetector
@onready var player_detector: RayCast2D = $RayCasts/PlayerDetector

const SPEED = 20.0 
const JUMP_VELOCITY = -400.0

var status: MrChopsState
var direction := -1.0 
var state_timer: float = 0.0
var default_hitbox_pos_x: float
var death_rot_speed: float = 0.0
var death_scale_speed: float = 0.0


func _ready() -> void:
	# Guarda a posição original da hitbox centralizada
	default_hitbox_pos_x = hitbox.position.x
	go_to_walk_state()

func _physics_process(delta: float) -> void:
	# Se estiver morto, roda apenas a física visual de arremesso 3D e ignora o resto
	if status == MrChopsState.dead:
		dead_state(delta)
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		MrChopsState.idle:
			idle_state(delta)
		MrChopsState.walk:
			walk_state(delta)
		MrChopsState.bite:
			bite_state(delta)

	move_and_slide()

# ==========================================
# MÓDULO: FUNÇÕES DE TRANSIÇÃO
# ==========================================

func go_to_idle_state():
	status = MrChopsState.idle
	ani.play("idle")
	velocity.x = 0
	
	# Restaura a hitbox para o centro do corpo
	hitbox.position.x = default_hitbox_pos_x
	
	# Define o tempo que o jacaré fica parado "pensando" antes de agir (1 segundo)
	state_timer = 1.0 

func go_to_walk_state():
	status = MrChopsState.walk
	ani.play("walk")
	hitbox.position.x = default_hitbox_pos_x

func go_to_bite_state():
	status = MrChopsState.bite
	ani.play("bite")
	velocity.x = 0
	
	# Desloca a hitbox 15 pixels para frente para "alcançar" o jogador.
	# (Você pode aumentar ou diminuir o valor 15.0 dependendo do tamanho da sua arte)
	hitbox.position.x = default_hitbox_pos_x + (15.0 * direction)
	
	# Define a duração do ataque (0.5 segundos). 
	# Ajuste para sincronizar perfeitamente com a duração da sua animação "bite".
	state_timer = 0.5 

func go_to_dead_state():
	if status == MrChopsState.dead:
		return
		
	status = MrChopsState.dead
	ani.play("dead")
	
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
		
	wall_detector.set_deferred("enabled", false)
	ground_detector.set_deferred("enabled", false)
	player_detector.set_deferred("enabled", false)
	
	# --- INÍCIO DO EFEITO 3D ---
	z_index = 100 # Renderiza na frente de tudo no jogo

func take_damage(hit_direction: float = 1.0):
	go_to_dead_state()
	
	# Gera valores caóticos para que cada morte seja única
	var random_up = randf_range(300.0, 600.0)
	var random_x = randf_range(100.0, 300.0)
	
	# Aplica o solavanco inicial baseado no lado que o player atacou
	velocity = Vector2(hit_direction * random_x, -random_up)
	
	# Velocidade de giro (gira rolando para trás)
	death_rot_speed = hit_direction * randf_range(5.0, 15.0)
	
	# Velocidade de crescimento em direção à tela
	death_scale_speed = randf_range(2.0, 4.0)

func dead_state(delta):
	# Como cancelamos o move_and_slide, controlamos a inércia manualmente
	velocity += get_gravity() * delta
	position += velocity * delta
	
	# Cresce e gira
	rotation += death_rot_speed * delta
	scale += Vector2(death_scale_speed, death_scale_speed) * delta
	
	# Ilusão óptica de desfoque: começa a ficar transparente ao se aproximar muito da "lente"
	if scale.x > 2.5:
		modulate.a -= delta * 2.5 
		
	# Deleta o inimigo da memória do celular quando ficar invisível ou gigante demais
	if modulate.a <= 0.0 or scale.x > 10.0:
		queue_free()

# ==========================================
# MÓDULO: COMPORTAMENTOS POR ESTADO
# ==========================================

func idle_state(delta):
	state_timer -= delta
	
	# Só toma uma decisão quando o tempo de "descanso" acabar
	if state_timer <= 0:
		if player_detector.is_colliding():
			go_to_bite_state() # Player continuou na frente, ataca novamente
		else:
			go_to_walk_state() # Player fugiu, volta a patrulhar

func walk_state(_delta):
	velocity.x = direction * SPEED
	update_facing()
	
	# Se vir o jogador, prioriza o ataque
	if player_detector.is_colliding():
		go_to_bite_state()
		return
	
	if is_on_floor():
		var hit_wall = wall_detector.is_colliding()
		var no_ground = not ground_detector.is_colliding()
		
		if hit_wall or no_ground:
			direction *= -1.0
			position.x += direction * 2.0

func bite_state(delta):
	state_timer -= delta
	
	# Aguarda a animação da mordida terminar para entrar no estado de descanso (idle)
	if state_timer <= 0:
		go_to_idle_state()


# ==========================================
# MÓDULO: FUNÇÕES AUXILIARES
# ==========================================

func update_facing():
	ani.flip_h = direction > 0
	raycasts.scale.x = -direction 
	
	wall_detector.force_raycast_update()
	ground_detector.force_raycast_update()
	player_detector.force_raycast_update()
