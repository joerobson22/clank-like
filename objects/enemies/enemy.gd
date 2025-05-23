extends CharacterBody2D

#CHILDREN
@onready var SpriteManager = $SpriteManager
@onready var InteractionManager = $InteractionManager
@onready var SetupManager = $SetupManager
@onready var Healthbar = $Healthbar

#ENEMY TYPE
var ENEMYTYPE : String = ""

#ENEMY ATTRIBUTES
#health
@export var maxHealth : float = 100.0
#movement
@export var wanderSpeed : float
@export var chaseSpeed : float
@export var fleeSpeed : float
@export var maxWanderDistance : int
#attack information
@export var attackSpeed : float
@export var attackRange : float
@export var attackCooldown : float
@export var attackOvershoot : float
@export var minLungeDistance : float
@export var attackSpeedDampen : float
#behaviour
@export var minWait : float
@export var maxWait : float
@export var willFlee : bool
@export var minFleeDistance : float

#TARGET POINTS
var targetPointScene = preload("res://objects/enemies/target_point.tscn")
var wanderPoint = null
var attackPoint = null
var fleePoint = null
var levelBounds = [Vector2(-2000, -1300), Vector2(2000, 1300)] 

#PHYSICS ATTRIBUTES
var speed : float = 0.0

#NODE REFERENCES
var player = null
var target = null
var rangedTarget = null

#STATE MACHINE VARIABLES
var dead : bool = false
var statePool = ["idle", "wandering"]
var state : String = "idle"
var attackState : String = ""
var canAttack : bool = true

var projectileScene = preload("res://objects/misc/projectile.tscn")

var attackMethod : String = ""
var attackMethods = ["Lunge", "Ranged"]

#INSTANTIATION --------------------------------------------------------------------------------------

func _ready():
	attackMethod = attackMethods[randi_range(0, attackMethods.size() - 1)]
	SetupManager.setup(attackMethod)
	
	setupTargetPoints()
	
	Healthbar.setup(maxHealth, maxHealth, "Enemy")
	
	stateRandomiser()


func setupTargetPoints():
	wanderPoint = targetPointScene.instantiate()
	attackPoint = targetPointScene.instantiate()
	fleePoint = targetPointScene.instantiate()
	get_tree().root.call_deferred("add_child", wanderPoint)
	get_tree().root.call_deferred("add_child", attackPoint)
	get_tree().root.call_deferred("add_child", fleePoint)


#PHYSICS PROCESS -----------------------------------------------------------------------------------

func _process(delta):
	$state.text = state
	$attack.text = attackState

func _physics_process(delta):
	if dead:
		return
	
	#if player is not null, that means the player is in detection range
	if player != null and shouldChase():
		#therefore, if we should chase the player
		chasePlayer()
	
	#if we don't have a target, don't move
	if target == null:
		return
	
	var direction = target.global_position - global_position
	
	#if we are close to our wander point, find another one
	if direction.length() < 10 and state == "wandering":
		stateRandomiser()
	
	#if we are in adequate range to attack and we can attack, attack!
	if direction.length() < attackRange and shouldAttack():
		attack()
	
	#if we are attacking with a LUNGE and we are close to our target point, end the lunge
	if direction.length() < attackSpeed / 5 and attackState == "lunge":
		SpriteManager.finishAttack(ENEMYTYPE)
	
	#if we are fleeing, we want to flee until the min flee distance is met, then reset our focus
	if state == "flee" and direction.length() > minFleeDistance and minFleeDistance > 0:
		resetFocus()
	
	#if we are lunging, set the speed to dampen when you get closer
	if attackState == "lunge":
		speed = max(speed * attackSpeedDampen, attackSpeed / 2)
	
	velocity = direction.normalized() * speed
	move_and_slide()

#ATTACK FUNCTIONS ----------------------------------------------------------------------------------

func shouldAttack() -> bool:
	return (canAttack and attackState == "" and state == "chasing")

func attack():
	#once we have determined it's okay to attack
	canAttack = false
	
	if attackMethod == "Lunge":
		#charge up the lunge
		chargeLunge()
	
	elif attackMethod == "Stationary":
		#perform a stationary attack
		attackState = "stationary"
		stationaryAttack()
	
	elif attackMethod == "Ranged":
		#shoot at the player
		attackState = "ranged"
		rangedTarget = target
		chargeRanged()

func chargeLunge():
	attackState = "charging"
	speed = 0.1 * chaseSpeed
	SpriteManager.chargeLunge(ENEMYTYPE)

func lungeAttack():
	attackState = "lunge"
	SpriteManager.attack("LungeAttack", ENEMYTYPE)
	speed = attackSpeed
	calculateAttackPointPosition()

func calculateAttackPointPosition():
	var directionVector = target.global_position - global_position
	directionVector = maxVector((directionVector * attackOvershoot), (directionVector * attackOvershoot).normalized() * minLungeDistance)
	attackPoint.global_position = target.global_position + directionVector
	target = attackPoint

func maxVector(v1, v2) -> Vector2:
	if v1.length() > v2.length():
		return v1
	else:
		return v2

func stationaryAttack():
	SpriteManager.attack("StationaryAttack", ENEMYTYPE)
	target = null

func chargeRanged():
	target = null
	SpriteManager.chargeRanged(ENEMYTYPE)

func rangedAttack():
	SpriteManager.attack("RangedAttack", ENEMYTYPE)
	var direction : Vector2 = (rangedTarget.global_position - global_position).normalized()
	spawnProjectile(direction)

func spawnProjectile(direction):
	var newProjectile = projectileScene.instantiate()
	newProjectile.targetGroup = "Player"
	newProjectile.friendlyGroup = "Enemy"
	newProjectile.global_position = global_position
	newProjectile.damage = Global.enemyBaseDamageLookup[attackMethod]
	
	get_tree().root.call_deferred("add_child", newProjectile)
	
	await get_tree().process_frame
	newProjectile.linear_velocity = direction * attackSpeed

func damagePlayer(p):
	p.damage(calculateDamage())

func calculateDamage() -> float:
	return Global.enemyBaseDamageLookup[attackMethod]

#DAMAGE AND DEATH FUNCTIONS ------------------------------------------------------------------------

func damage(damage):
	SpriteManager.damage(ENEMYTYPE)
	if Healthbar.damage(damage):
		die()

func die():
	dead = true
	SpriteManager.die(ENEMYTYPE)

#BEHAVIOUR FUNCTIONS -----------------------------------------------------------------------------

func stateRandomiser():
	if attackState != "":
		return
	
	SpriteManager.RESET()
	state = statePool[randi_range(0, statePool.size() - 1)]
	
	if state == "idle":
		idle()
	elif state == "wandering":
		wander()

func shouldChase() -> bool:
	if attackState != "" or state == "flee":
		return false
	
	return canAttack

func chasePlayer():
	speed = chaseSpeed
	state = "chasing"
	target = player
	SpriteManager.chase(ENEMYTYPE)

func idle():
	target = null
	SpriteManager.idle(ENEMYTYPE)
	await get_tree().create_timer(randf_range(minWait, maxWait)).timeout
	stateRandomiser()

func wander():
	speed = wanderSpeed
	SpriteManager.wander(ENEMYTYPE)
	var valid : bool = false
	while !valid:
		wanderPoint.global_position = global_position + Vector2(randi_range(-maxWanderDistance, maxWanderDistance), randi_range(-maxWanderDistance, maxWanderDistance))
		valid = inBounds(wanderPoint.global_position.x, wanderPoint.global_position.y)
	target = wanderPoint

func resetFocus():
	if player != null and canAttack:
		chasePlayer()
	else:
		stateRandomiser()

func cooldownAttack():
	attackState = ""
	if willFlee:
		flee()
	else:
		resetFocus()
	await get_tree().create_timer(attackCooldown).timeout
	canAttack = true
	resetFocus()

func flee():
	state = "flee"
	if attackMethod == "Stationary":
		target = player
	else:
		if player == null:
			fleePoint.global_position = global_position
		else:
			fleePoint.global_position = player.global_position
		target = fleePoint
	speed = -fleeSpeed

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
		#once the lunge has been charged, lunge!
		lungeAttack()
	
	elif anim_name.find("RangedChargeup") != -1:
		rangedAttack()
	
	elif anim_name.find("Die") != -1:
		queue_free()

func isInvincible() -> bool:
	return false
