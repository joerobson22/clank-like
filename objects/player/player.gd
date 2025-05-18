extends CharacterBody2D

@onready var SpriteManager = $SpriteManager
@onready var InteractionManager = $InteractionManager

@export var moveSpeed : float = 250.0

func _physics_process(delta):
	motion(delta)

func motion(delta):
	var inputVector = Vector2.ZERO
	
	inputVector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	inputVector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	
	
	if (Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down")):
		flip(inputVector)
		inputVector = inputVector.normalized()
		velocity = inputVector * moveSpeed
		move_and_slide()

func flip(inputVector):
	if inputVector.x == 0:
		return
	
	var sc : int
	if inputVector.x > 0:
		sc = 1
	elif inputVector.x < 0:
		sc = -1
	
	SpriteManager.scale.x = sc
	InteractionManager.scale.x = sc
