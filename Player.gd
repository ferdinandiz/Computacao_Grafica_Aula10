extends CharacterBody3D

@export var move_speed: float = 6.0
@export var jump_speed: float = 6.5
@export var accel: float = 12.0
@export var air_control: float = 3.5

var gravity: float

func _ready() -> void:
	# física padrão do projeto
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	# 1) Gravidade
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2) Direção de movimento no plano XZ (mundo)
	var input_dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
	)

	var wish_dir = Vector3.ZERO
	if input_dir.length() > 0.0:
		input_dir = input_dir.normalized()
		# movimenta no plano XZ (Z para frente, X para os lados)
		wish_dir = Vector3(input_dir.x, 0.0, input_dir.y)
		wish_dir = wish_dir.normalized()

	# 3) Aceleração / desaceleração no chão vs. no ar
	var target_vel = wish_dir * move_speed
	var lerp_factor = accel * delta if is_on_floor() else air_control * delta

	velocity.x = lerp(velocity.x, target_vel.x, clamp(lerp_factor, 0.0, 1.0))
	velocity.z = lerp(velocity.z, target_vel.z, clamp(lerp_factor, 0.0, 1.0))

	# 4) Pulo (Space/Enter = "ui_accept")
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_speed

	# 5) Move com colisões e “gruda” no piso inclinado (floor_max_angle padrão já ajuda)
	move_and_slide()

	# 6) Gire o cubo na direção do movimento (opcional, só se estiver andando)
	if Vector2(velocity.x, velocity.z).length() > 0.05:
		var look = Vector3(velocity.x, 0, velocity.z).normalized()
		# suaviza rotação: “slerp” simples via lerp_angle
		var target_yaw = atan2(-look.x, -look.z) # z pra frente
		var current_yaw = rotation.y
		rotation.y = lerp_angle(current_yaw, target_yaw, 8.0 * delta)
