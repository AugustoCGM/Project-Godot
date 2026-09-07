extends CharacterBody2D
@onready var ani: AnimatedSprite2D = $AnimatedSprite2D


const SPEED = 100.0
const JUMP_VELOCITY = -300.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
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
		ani.play("jump")
		if direction > 0:
			ani.flip_h = false
		elif direction < 0:
			ani.flip_h = true
		
		

	move_and_slide()
