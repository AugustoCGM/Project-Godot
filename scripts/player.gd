extends CharacterBody2D

enum PlayerState{
	idle,
	walk,
	jump
}

@onready var ani: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 160.0
const JUMP_VELOCITY = -300.0

var status: PlayerState

func _ready() -> void:
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

	move_and_slide()


func go_to_idle_state():
	status = PlayerState.idle
	ani.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	ani.play("walk")
func go_to_jump_state():
	status = PlayerState.jump
	ani.play("jump")

func idle_state():
	move()

func walk_state():
	move()

func jump_state():
	move()



func move():
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)






































func temp(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if is_on_floor():
		if direction > 0:
			ani.flip_h = false
			ani.play('walk')
		elif direction < 0:
			ani.flip_h = true
			ani.play('walk')
		else:
			ani.play("idle")

	else:
		# Verifica se a velocidade no eixo Y é maior que 0 (caindo)
		if velocity.y > 0:
			ani.play("falling")
		else:
			ani.play("jump")
		
		#virar o sprite enquanto o personagem está no ar
		if direction > 0:
			ani.flip_h = false
		elif direction < 0:
			ani.flip_h = true

	move_and_slide()
