extends CharacterBody3D

var target_velocity = Vector3.ZERO
@export var speed = 5.0
@export var jump_speed = 10.0
@export var friccion = 1.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var GETEXP: AudioStreamPlayer3D = $componentes/AudioStreamPlayer3D
const EXP = preload("res://Componentes/particulas/exp.tscn")

func _physics_process(delta: float):
	var direccion = Vector3.ZERO

	# Movimiento horizontal
	if Input.is_physical_key_pressed(KEY_D):
		direccion.x -= 1
	if Input.is_physical_key_pressed(KEY_A):
		direccion.x += 1
	if Input.is_physical_key_pressed(KEY_W):
		direccion.z += 1
	if Input.is_physical_key_pressed(KEY_S):
		direccion.z -= 1

	if direccion != Vector3.ZERO:
		direccion = direccion.normalized()
		
	target_velocity.x = direccion.x * (speed/friccion)
	target_velocity.z = direccion.z * (speed/friccion)
	
	if is_on_floor():
		# Si está en el suelo, reinicia la velocidad en Y y permite el salto
		if Input.is_physical_key_pressed(KEY_SPACE):
			velocity.y = jump_speed
		else:
			velocity.y = 0  # Reiniciar velocidad Y cuando toca el suelo
	else : 
		velocity.y-= gravity * delta
	

	# Aplicar la velocidad horizontal (X y Z)
	velocity.x = target_velocity.x
	velocity.z = target_velocity.z
	# Mover el personaje con la gravedad y la velocidad horizontal aplicada
	move_and_slide()


func _on_destructor_body_entered(body: Node3D) -> void:
	if "ExpBody" in body.name:
		GETEXP.play()
		body.queue_free()
