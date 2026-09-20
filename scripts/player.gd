extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	crouch,
	roll,
	dive,   
	boost   
}

@onready var ani: AnimatedSprite2D = $AnimatedSprite2D
@onready var colision_shape: CollisionShape2D = $CollisionShape2D

const SPEED = 160.0
const CROUCH_SPEED = 80.0 
const ROLL_SPEED = 300.0  
const JUMP_VELOCITY = -300.0
const DIVE_VELOCITY = 600.0   
const BOOST_SPEED = 600.0     
const BOOST_DURATION = 0.4    

var status: PlayerState
var has_double_jumped: bool = false
var boost_timer: float = 0.0  

var default_col_size: Vector2
var default_col_pos: Vector2

func _ready() -> void:
	default_col_size = colision_shape.shape.size
	default_col_pos = colision_shape.position
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.walk:
			walk_state()
		PlayerState.jump:
			jump_state()
		PlayerState.crouch:
			crouch_state()
		PlayerState.roll:
			roll_state()
		PlayerState.dive:
			dive_state()
		PlayerState.boost:
			boost_state(delta) 

	move_and_slide()

# ==========================================
# MÓDULO: GERENCIAMENTO DE COLISÃO E EFEITOS
# ==========================================

func apply_crouch_collision():
	colision_shape.shape.size = Vector2(12, 13)
	colision_shape.position = Vector2(-1.0, 3.5)

func restore_collision():
	colision_shape.shape.size = default_col_size
	colision_shape.position = default_col_pos

func trigger_camera_shake(intensity: float, fade: float = 5.0):
	var cam = get_viewport().get_camera_2d()
	if cam and cam.has_method("apply_shake"):
		cam.apply_shake(intensity, fade)

# ==========================================
# MÓDULO: FUNÇÕES DE TRANSIÇÃO DE ESTADO
# ==========================================

func go_to_idle_state():
	status = PlayerState.idle
	restore_collision() 
	ani.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	restore_collision() 
	ani.play("walk")

func go_to_jump_state():
	status = PlayerState.jump
	restore_collision()

func go_to_crouch_state():
	status = PlayerState.crouch
	apply_crouch_collision()
	ani.play("crouch") 

func go_to_roll_state():
	status = PlayerState.roll
	apply_crouch_collision()
	ani.play("roll")

func go_to_dive_state():
	status = PlayerState.dive
	apply_crouch_collision() 
	ani.play("roll")         
	velocity.x = 0           
	velocity.y = DIVE_VELOCITY

func go_to_boost_state():
	status = PlayerState.boost
	apply_crouch_collision() 
	ani.play("roll")
	boost_timer = BOOST_DURATION 
	
	# Aplica a explosão máxima de velocidade no frame 0 do impulso
	var dir = -1 if ani.flip_h else 1
	velocity.x = dir * BOOST_SPEED
	
	# Tremor suavizado
	trigger_camera_shake(3.5, 6.0)

# ==========================================
# MÓDULO: COMPORTAMENTOS POR ESTADO
# ==========================================

func idle_state():
	var direction := Input.get_axis("left", "right")
	update_facing(direction)

	if not is_on_floor():
		go_to_jump_state() 
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY 
		go_to_jump_state()
	elif Input.is_action_pressed("crouch"): 
		go_to_crouch_state()
	elif direction != 0:
		go_to_walk_state()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func walk_state():
	var direction := Input.get_axis("left", "right")
	update_facing(direction)
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if not is_on_floor():
		go_to_jump_state() 
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY 
		go_to_jump_state()
	elif Input.is_action_pressed("crouch"):
		go_to_crouch_state()
	elif direction == 0:
		go_to_idle_state()

func jump_state():
	var direction := Input.get_axis("left", "right")
	update_facing(direction)
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("jump") and not has_double_jumped:
		velocity.y = JUMP_VELOCITY
		has_double_jumped = true

	if has_double_jumped and Input.is_action_just_pressed("crouch"):
		go_to_dive_state()
		return

	if has_double_jumped:
		if Input.is_action_pressed("jump"):
			ani.play("roll")
		else:
			ani.play("falling" if velocity.y > 0 else "jump")
	else:
		ani.play("falling" if velocity.y > 0 else "jump")

	if is_on_floor():
		var can_boost = has_double_jumped and Input.is_action_pressed("jump")
		has_double_jumped = false 
		
		if can_boost:
			go_to_boost_state()
		elif direction != 0:
			go_to_walk_state()
		else:
			go_to_idle_state()

func crouch_state():
	var direction := Input.get_axis("left", "right")
	velocity.x = move_toward(velocity.x, 0, SPEED)

	if direction != 0 and is_on_floor():
		go_to_roll_state()
		return

	if not Input.is_action_pressed("crouch"):
		go_to_idle_state()

func roll_state():
	var direction := Input.get_axis("left", "right")
	update_facing(direction)

	if direction:
		velocity.x = direction * ROLL_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, ROLL_SPEED)

	if not is_on_floor():
		go_to_jump_state() 
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY 
		go_to_jump_state()
	elif not Input.is_action_pressed("crouch"):
		if direction != 0:
			go_to_walk_state()
		else:
			go_to_idle_state()
	elif direction == 0:
		go_to_crouch_state()

func dive_state():
	velocity.y = DIVE_VELOCITY
	
	if is_on_floor():
		# Impacto severo reduzido à metade para maior conforto visual
		trigger_camera_shake(3.5, 5.0)
		has_double_jumped = false 
		go_to_idle_state()

func boost_state(delta: float):
	boost_timer -= delta
	
	# Determina o vetor alvo (velocidade normal de movimento)
	var dir = -1 if ani.flip_h else 1
	var target_speed = dir * SPEED
	
	# Desacelera do BOOST_SPEED até o SPEED normal a uma taxa de 500 pixels por segundo
	velocity.x = move_toward(velocity.x, target_speed, 500.0 * delta)

	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		go_to_jump_state() 
		return

	if boost_timer <= 0:
		if not is_on_floor():
			go_to_jump_state() 
		elif Input.get_axis("left", "right") != 0:
			go_to_walk_state() 
		else:
			go_to_idle_state()

	if boost_timer <= 0:
		if not is_on_floor():
			go_to_jump_state() 
		elif Input.get_axis("left", "right") != 0:
			go_to_walk_state() 
		else:
			go_to_idle_state() 

# ==========================================
# MÓDULO: FUNÇÕES AUXILIARES
# ==========================================

func update_facing(direction: float):
	if direction > 0:
		ani.flip_h = false
	elif direction < 0:
		ani.flip_h = true
