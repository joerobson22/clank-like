extends CharacterBody2D

#CHILDREN
@onready var SpriteManager = $SpriteManager
@onready var InteractionManager = $InteractionManager

#ATTRIBUTES
#moving
@export var moveSpeed : float = 250.0
#lunging
@export var lungeSpeed : float = 50.0
@export var lungeDuration : float = 0.1
#dodging
@export var dodgeSpeed : float = 750.0
@export var dodgeDuration : float = 0.25
@export var dodgeCooldown : float = 0.25

#ATTACK INFORMATION
var attackNum = 1
var numAttacks
var weaponName = "Sword"

var projectileScene = preload("res://objects/misc/projectile.tscn")

#STATE MACHINE VARIABLES
var states = {
	"attacking" : false,
	"canAttack" : true,
	"dodging" : false,
	"canDodge" : true,
	"invincible" : false
}

#PHYSICS INFORMATION
var lastInputVector : Vector2 = Vector2.RIGHT
var direction = "STRAIGHT"

#INSTANTIATION ------------------------------------------------------------------------------------
func _ready():
	if weaponName == "Sword":
		numAttacks = 1
		#set sprite etc

#PHYSICS PROCESS ------------------------------------------------------------------------------------
func _physics_process(delta):
	states["invincible"] = states["dodging"]
	
	if states["attacking"]:
		dash(lungeSpeed)
		return
	
	if states["dodging"]:
		dash(dodgeSpeed)
		return
	
	motion(delta)

#MOVEMENT ------------------------------------------------------------------------------------

func motion(delta):
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
	
	if Input.is_action_just_pressed("space") and states["canDodge"]:
		startDash(dodgeSpeed, dodgeDuration, dodgeCooldown, "dodging", "canDodge")

func dash(speed):
	velocity = lastInputVector.normalized() * speed
	move_and_slide()

func startDash(speed, duration, cooldown, actionName, actionStatus):
	states[actionName] = true
	states[actionStatus] = false
	
	dash(speed)
	
	await get_tree().create_timer(duration).timeout
	states[actionName] = false
	
	await get_tree().create_timer(cooldown).timeout
	states[actionStatus] = true

#ATTACKING ------------------------------------------------------------------------------------

func attack():
	startDash(lungeSpeed, lungeDuration, 0.0, "attacking", "canAttack")
	#play attack animation
	SpriteManager.attack(type_convert(attackNum, TYPE_STRING))
	attackNum += 1

func damageEnemies(attackName): #in the future, may also pass weapon, crit chance, other buffs
	for e in InteractionManager.enemyList:
		e.damage(attackName)
	InteractionManager.cooldown()

#HURTING -------------------------------------------------------------------------------------------

func damage(dam):
	if isInvincible():
		return

#INTERACTIONS ------------------------------------------------------------------------------------
func interact():
	pass

#DIRECTION CONTROL ----------------------------------------------------------------------------------

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

#GETTERS --------------------------------------------------------------------------------------------

func isInvincible() -> bool:
	return states["invincible"]
