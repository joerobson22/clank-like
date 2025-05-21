extends CharacterBody2D

@onready var SpriteManager = $SpriteManager
@onready var InteractionManager = $InteractionManager

@export var maxHealth : float = 100.0
@export var health : float = maxHealth
@export var moveSpeed : float = 50.0
@export var chaseSpeed : float = 100.0
@export var attackSpeed : float = 1000.0
@export var attackRadius : float = 500.0
@export var attackCooldown : float = 3.0

@export var maxWanderDistance : int = 250

var targetPointScene = preload("res://objects/enemies/target_point.tscn")
var wanderPoint = null
var attackPoint = null

var speed : float = 0.0

var player = null
var target = null

var statePool = ["idle", "wandering"]
var state : String = "idle"
var canAttack : bool = true

var attackDict = {
	"lunge" : [500.0, 3.0],
	"stationary" : [100.0, 0.25]
}

var attackMethod : String = ""
var attackMethods = ["stationary", "lunge"]

func _ready():
	wanderPoint = targetPointScene.instantiate()
	attackPoint = targetPointScene.instantiate()
	get_tree().root.call_deferred("add_child", wanderPoint)
	get_tree().root.call_deferred("add_child", attackPoint)
	attackMethod = attackMethods[randi_range(0, attackMethods.size() - 1)]
	attackRadius = attackDict[attackMethod][0]
	attackCooldown = attackDict[attackMethod][1]
	
	print(attackMethod)
	
	stateRandomiser()

func _physics_process(delta):	
	if target == null:
		return
	
	var direction = target.global_position - global_position
	
	if direction.length() < attackRadius and state == "chasing" and canAttack:
		attack()
	
	if direction.length() < 10 and state == "attacking":
		target = null
		SpriteManager.finishAttack()
	
	if direction.length() < 5 and state != "chasing" and state != "attacking":
		target = null
		stateRandomiser()
		return
	
	velocity = direction.normalized() * speed
	move_and_slide()

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

func attack():
	canAttack = false
	state = "attacking"
	if attackMethod == "lunge":
		lungeAttack()
	elif attackMethod == "stationary":
		stationaryAttack()
	SpriteManager.attack(attackMethod + "Attack")

func lungeAttack():
	speed = attackSpeed
	attackPoint.global_position = player.global_position
	target = attackPoint

func stationaryAttack():
	target = null

func damage(attackName):
	#take off health here and whatnot
	#then call on sprite manager to do animation
	state = "hurt"
	SpriteManager.damage()

func chasePlayer():
	speed = chaseSpeed
	state = "chasing"
	target = player
	SpriteManager.chase()

func idle():
	SpriteManager.idle()

func wander():
	speed = moveSpeed
	SpriteManager.wander()
	wanderPoint.global_position = global_position + Vector2(randi_range(-maxWanderDistance, maxWanderDistance), randi_range(-maxWanderDistance, maxWanderDistance))
	target = wanderPoint

func _on_object_detection_area_entered(area):
	if area.is_in_group("Player") and area.is_in_group("Detectable"):
		player = area.get_parent().player
		chasePlayer()


func _on_object_detection_area_exited(area):
	if area.is_in_group("Player") and area.is_in_group("Detectable"):
		player = null
		state = "idle"
		stateRandomiser()


func _on_full_ap_animation_finished(anim_name):
	if anim_name.find("FinishAttack") != -1 or anim_name.find("Hurt") != -1:
		if player == null:
			stateRandomiser()
		else:
			chasePlayer()
	elif anim_name.find("Attack") != -1 and attackMethod != "lunge":
		SpriteManager.finishAttack()
	
	if anim_name.find("FinishAttack") != -1:
		await get_tree().create_timer(attackCooldown).timeout
		canAttack = true
