extends CharacterBody2D

#CHILDREN
@onready var SpriteManager = $SpriteManager
@onready var InteractionManager = $InteractionManager

#ENEMY TYPE
var ENEMYTYPE : String = ""

#ENEMY ATTRIBUTES
#health
var maxHealth : float = 100.0
var health : float = maxHealth
#movement
var moveSpeed : float = 50.0
var chaseSpeed : float = 100.0
var maxWanderDistance : int = 250
#attack information
var attackSpeed : float
var attackRange : float
var attackCooldown : float

#TARGET POINTS
var targetPointScene = preload("res://objects/enemies/target_point.tscn")
var wanderPoint = null
var attackPoint = null

#PHYSICS ATTRIBUTES
var speed : float = 0.0

#NODE REFERENCES
var player = null
var target = null

#STATE MACHINE VARIABLES
var statePool = ["idle", "wandering"]
var state : String = "idle"
var canAttack : bool = true

#RECORDS FOR ATTRIBUTES DEPENDENT ON ATTACK TYPE
var attackDict = {
	"Lunge" : [500.0, 3.0],
	"Stationary" : [100.0, 0.25]
}

var attackMethod : String = ""
var attackMethods = ["Stationary", "Lunge"]

#INSTANTIATION --------------------------------------------------------------------------------------

func _ready():
	wanderPoint = targetPointScene.instantiate()
	attackPoint = targetPointScene.instantiate()
	get_tree().root.call_deferred("add_child", wanderPoint)
	get_tree().root.call_deferred("add_child", attackPoint)
	
	attackMethod = attackMethods[randi_range(0, attackMethods.size() - 1)]
	attackRange = attackDict[attackMethod][0]
	attackCooldown = attackDict[attackMethod][1]
	
	stateRandomiser()

#PHYSICS PROCESS -----------------------------------------------------------------------------------

func _physics_process(delta):
	if target == null:
		return
	
	var direction = target.global_position - global_position
	
	if direction.length() < attackRange and state == "chasing" and canAttack:
		attack()
	
	if direction.length() < 10 and state == "attacking":
		target = null
		SpriteManager.finishAttack(ENEMYTYPE)
	
	if direction.length() < 5 and state != "chasing" and state != "attacking":
		target = null
		stateRandomiser()
		return
	
	velocity = direction.normalized() * speed
	move_and_slide()

#ATTACK FUNCTIONS ----------------------------------------------------------------------------------

func attack():
	canAttack = false
	state = "attacking"
	if attackMethod == "Lunge":
		SpriteManager.chargeLunge(ENEMYTYPE)
	
	elif attackMethod == "Stationary":
		stationaryAttack()
		SpriteManager.attack("StationaryAttack", ENEMYTYPE)

func lungeAttack():
	SpriteManager.attack("LungeAttack", ENEMYTYPE)
	speed = attackSpeed
	attackPoint.global_position = player.global_position
	target = attackPoint

func stationaryAttack():
	target = null

#DAMAGE AND DEATH FUNCTIONS ------------------------------------------------------------------------

func damage(attackName):
	#take off health here and whatnot
	#then call on sprite manager to do animation
	state = "hurt"
	SpriteManager.damage(ENEMYTYPE)

#BEHAVIOUR FUNCTIONS -----------------------------------------------------------------------------

func stateRandomiser():
	if state == "hurt" or state == "chasing" or state == "attacking":
		return
	
	state = statePool[randi_range(0, statePool.size() - 1)]
	
	if state == "idle":
		idle()
		await get_tree().create_timer(randf_range(1.0, 5.0)).timeout
		stateRandomiser()
	elif state == "wandering":
		wander()

func chasePlayer():
	speed = chaseSpeed
	state = "chasing"
	target = player
	SpriteManager.chase(ENEMYTYPE)

func idle():
	SpriteManager.idle(ENEMYTYPE)

func wander():
	speed = moveSpeed
	SpriteManager.wander(ENEMYTYPE)
	wanderPoint.global_position = global_position + Vector2(randi_range(-maxWanderDistance, maxWanderDistance), randi_range(-maxWanderDistance, maxWanderDistance))
	target = wanderPoint

func resetFocus():
	if player == null:
		stateRandomiser()
	else:
		chasePlayer()

func cooldownAttack():
	await get_tree().create_timer(attackCooldown).timeout
	canAttack = true

#ANIMATION STATE MACHINE probably could've used an animation tree but oh well ------------------------------------------------

func _on_full_ap_animation_finished(anim_name):
	if anim_name.find("Hurt") != -1:
		resetFocus()
	
	elif anim_name.find("FinishAttack") != -1:
		resetFocus()
		cooldownAttack()
	
	elif anim_name.find("StationaryAttack") != -1:
		SpriteManager.finishAttack()
	
	elif anim_name.find("LungeChargeup") != -1:
		lungeAttack()
