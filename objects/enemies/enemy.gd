extends CharacterBody2D

#CHILDREN
@onready var SpriteManager = $SpriteManager
@onready var InteractionManager = $InteractionManager
@onready var SetupManager = $SetupManager

#ENEMY TYPE
var ENEMYTYPE : String = ""

#ENEMY ATTRIBUTES
#health
@export var maxHealth : float = 100.0
var health : float = maxHealth
#movement
@export var wanderSpeed : float
@export var chaseSpeed : float
@export var fleeSpeed : float
@export var maxWanderDistance : int
#attack information
@export var attackSpeed : float
@export var attackRange : float
@export var attackCooldown : float
#behaviour
@export var minWait : float
@export var maxWait : float
@export var willBackOff : bool
@export var minFleeDistance : float

#TARGET POINTS
var targetPointScene = preload("res://objects/enemies/target_point.tscn")
var wanderPoint = null
var attackPoint = null
var levelBounds = [Vector2(-1000, -1000), Vector2(1000, 1000)] 

#PHYSICS ATTRIBUTES
var speed : float = 0.0

#NODE REFERENCES
var player = null
var target = null

#STATE MACHINE VARIABLES
var statePool = ["idle", "wandering"]
var state : String = "idle"
var canAttack : bool = true

var projectileScene = preload("res://objects/misc/projectile.tscn")

var attackMethod : String = ""
var attackMethods = ["Ranged", "Lunge", "Stationary"]

#INSTANTIATION --------------------------------------------------------------------------------------

func _ready():
	attackMethod = attackMethods[randi_range(0, attackMethods.size() - 1)]
	SetupManager.setup(attackMethod)
	
	wanderPoint = targetPointScene.instantiate()
	attackPoint = targetPointScene.instantiate()
	get_tree().root.call_deferred("add_child", wanderPoint)
	get_tree().root.call_deferred("add_child", attackPoint)
	
	stateRandomiser()

#PHYSICS PROCESS -----------------------------------------------------------------------------------

func _physics_process(delta):
	if target == null:
		return
	
	var direction = target.global_position - global_position
	
	if direction.length() < attackRange and state == "chasing" and canAttack:
		attack()
	
	if attackMethod == "Ranged" and direction.length() < attackRange:
		return
	
	if direction.length() < 10 and state == "attacking":
		target = null
		SpriteManager.finishAttack(ENEMYTYPE)
	
	if direction.length() < 5 and state != "chasing" and state != "attacking" and state != "backing off":
		target = null
		stateRandomiser()
		return
	
	if direction.length() > minFleeDistance and state == "backing off":
		resetFocus()
	
	velocity = direction.normalized() * speed
	move_and_slide()

#ATTACK FUNCTIONS ----------------------------------------------------------------------------------

func attack():
	canAttack = false
	state = "attacking"
	if attackMethod == "Lunge":
		chargeLunge()
	
	elif attackMethod == "Stationary":
		stationaryAttack()
	
	elif attackMethod == "Ranged":
		chargeRanged()

func chargeLunge():
	SpriteManager.chargeLunge(ENEMYTYPE)

func lungeAttack():
	SpriteManager.attack("LungeAttack", ENEMYTYPE)
	speed = attackSpeed
	attackPoint.global_position = player.global_position
	target = attackPoint

func stationaryAttack():
	SpriteManager.attack("StationaryAttack", ENEMYTYPE)
	target = null

func chargeRanged():
	target = null
	SpriteManager.chargeRanged(ENEMYTYPE)

func rangedAttack():
	if player == null:
		resetFocus()
		return
	SpriteManager.attack("RangedAttack", ENEMYTYPE)
	var direction : Vector2 = (player.global_position - global_position).normalized()
	spawnProjectile(direction)

func spawnProjectile(direction):
	var newProjectile = projectileScene.instantiate()
	newProjectile.targetGroup = "Player"
	newProjectile.friendlyGroup = "Enemy"
	newProjectile.global_position = global_position
	
	get_tree().root.call_deferred("add_child", newProjectile)
	
	await get_tree().process_frame
	newProjectile.linear_velocity = direction * attackSpeed

#DAMAGE AND DEATH FUNCTIONS ------------------------------------------------------------------------

func damage(attackName):
	#take off health here and whatnot
	#then call on sprite manager to do animation
	SpriteManager.damage(ENEMYTYPE)

#BEHAVIOUR FUNCTIONS -----------------------------------------------------------------------------

func stateRandomiser():
	if state == "chasing" or state == "attacking":
		return
	
	await get_tree().create_timer(randf_range(minWait, maxWait)).timeout
	state = statePool[randi_range(0, statePool.size() - 1)]
	
	if state == "idle":
		idle()
		stateRandomiser()
	elif state == "wandering":
		wander()

func chasePlayer():
	if state == "attacking":
		return
	
	speed = chaseSpeed
	state = "chasing"
	target = player
	SpriteManager.chase(ENEMYTYPE)

func idle():
	SpriteManager.idle(ENEMYTYPE)

func wander():
	speed = wanderSpeed
	SpriteManager.wander(ENEMYTYPE)
	var valid : bool = false
	while !valid:
		wanderPoint.global_position = global_position + Vector2(randi_range(-maxWanderDistance, maxWanderDistance), randi_range(-maxWanderDistance, maxWanderDistance))
		valid = inBounds(wanderPoint.global_position.x, wanderPoint.global_position.y)
	target = wanderPoint

func resetFocus():
	if player == null:
		stateRandomiser()
	else:
		chasePlayer()

func cooldownAttack():
	if willBackOff:
		state = "backing off"
		target = player
		speed = fleeSpeed
	else:
		resetFocus()
	await get_tree().create_timer(attackCooldown).timeout
	canAttack = true
	resetFocus()

#USEFUL FUNCTIONS
func inBounds(x, y) -> bool:
	return (x >= levelBounds[0].x and y >= levelBounds[0].y and x <= levelBounds[1].x and y <= levelBounds[1].y)

#ANIMATION STATE MACHINE probably could've used an animation tree but oh well ------------------------------------------------

func _on_full_ap_animation_finished(anim_name):	
	if anim_name.find("FinishAttack") != -1:
		SpriteManager.RESET()
		cooldownAttack()
	
	elif anim_name.find("StationaryAttack") != -1 or anim_name.find("RangedAttack") != -1:
		SpriteManager.finishAttack(ENEMYTYPE)
	
	elif anim_name.find("LungeChargeup") != -1:
		lungeAttack()
	
	elif anim_name.find("RangedChargeup") != -1:
		rangedAttack()

func isInvincible() -> bool:
	return false
