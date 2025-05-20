extends CharacterBody2D

@onready var SpriteManager = $SpriteManager
@onready var InteractionManager = $InteractionManager

@export var moveSpeed : float = 250.0
@export var lungeDistance : float = 10.0
@export var dodgeSpeed : float = 500.0
@export var dodgeDuration : float = 0.25
@export var dodgeCooldown : float = 0.25

var attackNum = 1
var numAttacks = 1
var attacking : bool = false

var dodging : bool = false
var canDodge : bool = true

var lastInputVector : Vector2 = Vector2.RIGHT
var direction = "STRAIGHT"

var weaponName = "Sword"

func _physics_process(delta):
	motion(delta)

func motion(delta):
	if attacking:
		return
	
	if dodging:
		dodge()
		return
	
	var inputVector = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
		)
	
	if inputVector != Vector2.ZERO:
		flip(inputVector)
		lastInputVector = inputVector
		inputVector = inputVector.normalized()
		velocity = inputVector * moveSpeed
		move_and_slide()
	
	if Input.is_action_just_pressed("space") and canDodge:
		startDodge()
		dodging = true
		canDodge = false

func attack():
	attacking = true
	lunge()
	#play attack animation
	SpriteManager.attack(type_convert(attackNum, TYPE_STRING))
	attackNum += 1

func lunge():
	move_and_collide(lastInputVector.normalized() * lungeDistance)

func dodge():
	velocity = lastInputVector.normalized() * dodgeSpeed
	move_and_slide()

func startDodge():
	dodge()
	await get_tree().create_timer(dodgeDuration).timeout
	dodging = false
	await get_tree().create_timer(dodgeCooldown).timeout
	canDodge = true

func damageEnemies(attackName): #in the future, may also pass weapon, crit chance, other buffs
	for e in InteractionManager.enemyList:
		e.damage(attackName)
	InteractionManager.cooldown()

func interact():
	pass

func flip(inputVector):
	direction = SpriteManager.getDirection(inputVector)
	InteractionManager.setDirection(direction)
	
	if inputVector.x == 0:
		return
	
	var sc : int
	if inputVector.x > 0:
		sc = 1
	elif inputVector.x < 0:
		sc = -1
	
	SpriteManager.scale.x = sc
	InteractionManager.scale.x = sc
