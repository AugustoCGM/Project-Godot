extends CharacterBody2D

enum MrChopsState {
	idle,
	walk,
	bite,
	dead,
	respawning,
	bounced # NOVO ESTADO: Reação ao ser pisado
}

@onready var ani: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var raycasts: Node2D = $RayCasts
@onready var wall_detector: RayCast2D = $RayCasts/WallDetector
@onready var ground_detector: RayCast2D = $RayCasts/GroundDetector
@onready var player_detector: RayCast2D = $RayCasts/PlayerDetector

# --- VARIÁVEIS DE CONFIGURAÇÃO (Inspetor) ---
@export var can_move: bool = true
@export var patrol_distance: float = 0.0 
@export var edge_wait_time: float = 0.0 
@export var can_respawn: bool = false
@export var respawn_time: float = 3.0

const SPEED = 20.0 
const JUMP_VELOCITY = -400.0

var status: MrChopsState
var direction := -1.0 
var state_timer: float = 0.0
var default_hitbox_pos_x: float

var death_rot_speed: float = 0.0
var death_scale_speed: float = 0.0

var spawn_position: Vector2
var is_waiting_respawn: bool = false
var current_respawn_timer: float = 0.0
var will_turn_after_idle: bool = false 

func _ready() -> void:
	default_hitbox_pos_x = hitbox.position.x
	spawn_position = position 
	
	if can_move:
		go_to_walk_state()
	else:
		go_to_idle_state()

func _physics_process(delta: float) -> void:
	if is_waiting_respawn:
		process_respawn(delta)
		return

	if status == MrChopsState.dead:
		dead_state(delta)
		return

	if status != MrChopsState.respawning and not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		MrChopsState.idle:
			idle_state(delta)
		MrChopsState.walk:
			walk_state(delta)
		MrChopsState.bite:
			bite_state(delta)
		MrChopsState.respawning:
			respawning_state(delta)
		MrChopsState.bounced:
			bounced_state(delta) # Executa a pausa do impacto

	move_and_slide()

# ==========================================
# MÓDULO: SISTEMA DE RESPAWN
# ==========================================

func process_respawn(delta: float):
	current_respawn_timer -= delta
	if current_respawn_timer <= 0:
		begin_respawn()

func begin_respawn():
	is_waiting_respawn = false
	status = MrChopsState.respawning
	
	position = spawn_position
	visible = true
	
	scale = Vector2(1, 1)
	modulate.a = 0.0 
	rotation = 0.0
	direction = -1.0
	z_index = 0
	velocity = Vector2.ZERO
	will_turn_after_idle = false 
	
	ani.play("idle")

func respawning_state(delta: float):
	modulate.a = move_toward(modulate.a, 1.0, 1.5 * delta)
	
	if modulate.a >= 1.0:
		hitbox.set_deferred("monitoring", true)
		hitbox.set_deferred("monitorable", true)
		if has_node("CollisionShape2D"):
			$CollisionShape2D.set_deferred("disabled", false)
			
		wall_detector.set_deferred("enabled", true)
		ground_detector.set_deferred("enabled", true)
		player_detector.set_deferred("enabled", true)
		
		if can_move:
			go_to_walk_state()
		else:
			go_to_idle_state()

# ==========================================
# MÓDULO: FUNÇÕES DE TRANSIÇÃO E DANO
# ==========================================

func go_to_idle_state(time_to_wait: float = 1.0):
	status = MrChopsState.idle
	ani.play("idle")
	velocity.x = 0
	hitbox.position.x = default_hitbox_pos_x
	state_timer = time_to_wait 

func go_to_walk_state():
	status = MrChopsState.walk
	ani.play("walk")
	hitbox.position.x = default_hitbox_pos_x

func go_to_bite_state():
	status = MrChopsState.bite
	ani.play("bite")
	velocity.x = 0
	hitbox.position.x = default_hitbox_pos_x + (15.0 * direction)
	state_timer = 0.5 

func go_to_bounced_state():
	status = MrChopsState.bounced
	ani.play("bounced") # A animação de achatamento/dano
	velocity.x = 0
	state_timer = 0.3 # Tempo que o jacaré fica esmagado antes de voltar a agir

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
	
	z_index = 100 

func take_damage(hit_direction: float = 1.0):
	go_to_dead_state()
	var random_up = randf_range(300.0, 600.0)
	var random_x = randf_range(100.0, 300.0)
	velocity = Vector2(hit_direction * random_x, -random_up)
	death_rot_speed = hit_direction * randf_range(5.0, 15.0)
	death_scale_speed = randf_range(2.0, 4.0)

func take_bounce():
	# Só recebe o pisão se estiver vivo e materializado
	if status != MrChopsState.dead and status != MrChopsState.respawning:
		go_to_bounced_state()

# ==========================================
# MÓDULO: COMPORTAMENTOS POR ESTADO
# ==========================================

func idle_state(delta):
	state_timer -= delta
	
	if state_timer <= 0:
		if player_detector.is_colliding():
			go_to_bite_state()
		elif can_move:
			if will_turn_after_idle:
				direction *= -1.0
				update_facing()
				will_turn_after_idle = false
			go_to_walk_state()
		else:
			state_timer = 1.0

func walk_state(_delta):
	velocity.x = direction * SPEED
	update_facing()
	
	if player_detector.is_colliding():
		go_to_bite_state()
		return
	
	var needs_to_turn = false
	
	if patrol_distance > 0:
		if position.x > spawn_position.x + patrol_distance and direction > 0:
			needs_to_turn = true
		elif position.x < spawn_position.x - patrol_distance and direction < 0:
			needs_to_turn = true
	
	if is_on_floor() and not needs_to_turn:
		var hit_wall = wall_detector.is_colliding()
		var no_ground = not ground_detector.is_colliding()
		
		if hit_wall or no_ground:
			needs_to_turn = true
			position.x += (direction * -1.0) * 2.0
			
	if needs_to_turn:
		if edge_wait_time > 0.0:
			will_turn_after_idle = true
			go_to_idle_state(edge_wait_time)
		else:
			direction *= -1.0
			update_facing() 
			velocity.x = direction * SPEED

func bite_state(delta):
	state_timer -= delta
	if state_timer <= 0:
		go_to_idle_state()

func bounced_state(delta):
	state_timer -= delta
	if state_timer <= 0:
		# Após o pisão, o jacaré se recupera. O idle garante que ele olhe se o jogador ainda está perto antes de andar.
		go_to_idle_state()

func dead_state(delta):
	velocity += get_gravity() * delta
	position += velocity * delta
	
	rotation += death_rot_speed * delta
	scale += Vector2(death_scale_speed, death_scale_speed) * delta
	
	if scale.x > 2.5:
		modulate.a -= delta * 2.5 
		
	if modulate.a <= 0.0 or scale.x > 10.0:
		if can_respawn:
			is_waiting_respawn = true
			current_respawn_timer = respawn_time
			visible = false
			velocity = Vector2.ZERO
		else:
			queue_free()

# ==========================================
# MÓDULO: FUNÇÕES AUXILIARES
# ==========================================

func update_facing():
	ani.flip_h = direction > 0
	raycasts.scale.x = -direction 
	
	wall_detector.force_raycast_update()
	ground_detector.force_raycast_update()
	player_detector.force_raycast_update()
