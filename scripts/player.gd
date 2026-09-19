extends CharacterBody2D


enum PlayerState {
	idle,
	walk,
	jump,
	crouch,
	roll
}

@onready var ani: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 160.0
const CROUCH_SPEED = 80.0 
const ROLL_SPEED = 220.0  
const JUMP_VELOCITY = -300.0

var status: PlayerState
var has_double_jumped: bool = false # Variável de controle do pulo duplo

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	# Aplica a gravidade se não estiver no chão
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		has_double_jumped = false # Recarrega o pulo duplo ao tocar no chão

	# Executa a lógica correspondente ao estado atual do personagem
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

	move_and_slide()


# ==========================================
# MÓDULO: FUNÇÕES DE TRANSIÇÃO DE ESTADO
# ==========================================

func go_to_idle_state():
	status = PlayerState.idle
	ani.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	ani.play("walk")

func go_to_jump_state():
	status = PlayerState.jump
	# A força do pulo foi removida daqui para evitar pulos automáticos nas beiradas.
	# A animação agora é resolvida no bloco do jump_state.

func go_to_crouch_state():
	status = PlayerState.crouch
	ani.play("crouch") 

func go_to_roll_state():
	status = PlayerState.roll
	ani.play("roll")


# ==========================================
# MÓDULO: COMPORTAMENTOS POR ESTADO
# ==========================================

func idle_state():
	var direction := Input.get_axis("left", "right")
	update_facing(direction)

	if not is_on_floor():
		go_to_jump_state() # Caiu da beirada
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY # Pulo intencional
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
		go_to_jump_state() # Caiu da beirada
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY # Pulo intencional
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

	# Lógica do Pulo Duplo
	if Input.is_action_just_pressed("jump") and not has_double_jumped:
		velocity.y = JUMP_VELOCITY
		has_double_jumped = true

	# Controle Dinâmico da Animação Aérea
	if has_double_jumped:
		ani.play("roll") # Substitui a animação padrão pelo giro durante o pulo duplo
	else:
		if velocity.y > 0:
			ani.play("falling")
		else:
			ani.play("jump")

	# Aterrissagem
	if is_on_floor():
		if direction != 0:
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
		go_to_jump_state() # Caiu da beirada rolando
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY # Pulou enquanto rolava
		go_to_jump_state()
	elif not Input.is_action_pressed("crouch"):
		if direction != 0:
			go_to_walk_state()
		else:
			go_to_idle_state()
	elif direction == 0:
		go_to_crouch_state()


# ==========================================
# MÓDULO: FUNÇÕES AUXILIARES
# ==========================================

func update_facing(direction: float):
	if direction > 0:
		ani.flip_h = false
	elif direction < 0:
		ani.flip_h = true
