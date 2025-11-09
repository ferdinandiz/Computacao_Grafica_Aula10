extends CharacterBody3D

@export var move_speed: float = 6.0
@export var accel: float = 18.0
@export var deaccel: float = 22.0
@export var jump_velocity: float = 4.5

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") as float
var _vel: Vector3 = Vector3.ZERO

# Referência à lanterna (SpotLight3D) como filho do Player
@onready var flashlight: SpotLight3D = $Flashlight
@onready var cam: Camera3D = get_node_or_null("/root/Level/Camera3D") # ajuste o caminho conforme sua cena

func _ready() -> void:
	# Configurações iniciais da lanterna
	flashlight.light_energy = 2.0            # intensidade
	flashlight.spot_range = 20.0             # alcance
	flashlight.spot_angle = 35.0             # ângulo do feixe (graus)
	flashlight.shadow_enabled = true         # sombras ON para efeitos perceptíveis
	flashlight.shadow_bias = 0.02
	flashlight.shadow_normal_bias = 0.5

func _physics_process(delta: float) -> void:
	# gravidade
	if not is_on_floor():
		_vel.y -= gravity * delta
	else:
		# leve amortecimento quando no chão
		if _vel.y < 0.0:
			_vel.y = 0.0

	# direção de movimento no plano XZ (WASD / setas)
	var dir := Vector3.ZERO
	if Input.is_action_pressed("ui_right"):
		dir.x += 1.0
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1.0
	if Input.is_action_pressed("ui_down"):
		dir.z += 1.0
	if Input.is_action_pressed("ui_up"):
		dir.z -= 1.0

	# movimento relativo à orientação da câmera (se houver)
	if cam:
		dir = (cam.global_transform.basis * dir).normalized()
		dir.y = 0.0

	var target := dir * move_speed

	# acelera / desacelera suavemente no plano
	var v_planar := _vel
	v_planar.y = 0.0

	var diff := target - v_planar
	var k := accel if diff.length() > 0.001 else deaccel
	var max_step := k * delta

	if diff.length() > max_step:
		v_planar += diff.normalized() * max_step
	else:
		v_planar = target


	_vel.x = v_planar.x
	_vel.z = v_planar.z

	# pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		_vel.y = jump_velocity

	velocity = _vel
	move_and_slide()

	# gira o Player para a direção de movimento (estético)
	if v_planar.length() > 0.05:
		look_at(global_transform.origin + v_planar.normalized(), Vector3.UP)

	# alinhar lanterna para frente do Player
	_update_flashlight_pose()

func _input(event: InputEvent) -> void:
	# alternar lanterna (tecla "F" mapeada em Input Map como "flash_toggle")
	if event.is_action_pressed("flash_toggle"):
		flashlight.visible = not flashlight.visible
	# ajustar ângulo da lanterna (teclas 1 e 2, por exemplo)
	if event.is_action_pressed("flash_narrow"):
		flashlight.spot_angle = clamp(flashlight.spot_angle - 3.0, 5.0, 70.0)
	if event.is_action_pressed("flash_widen"):
		flashlight.spot_angle = clamp(flashlight.spot_angle + 3.0, 5.0, 70.0)
	# ajustar intensidade (teclas 8/9)
	if event.is_action_pressed("flash_dim"):
		flashlight.light_energy = max(0.2, flashlight.light_energy - 0.2)
	if event.is_action_pressed("flash_bright"):
		flashlight.light_energy = min(6.0, flashlight.light_energy + 0.2)

func _update_flashlight_pose() -> void:
	# posiciona a lanterna levemente à frente e acima do "rosto"
	var forward := -global_transform.basis.z.normalized()
	var offset := Vector3(0.0, 0.6, 0.0) + forward * 0.6
	flashlight.global_transform = Transform3D(
		Basis().looking_at(forward, Vector3.UP),
		global_transform.origin + offset
	)
