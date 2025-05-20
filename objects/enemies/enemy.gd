extends CharacterBody2D

@onready var SpriteManager = $SpriteManager
@onready var InteractionManager = $InteractionManager
@onready var WanderPoint = $WanderPoint

@export var maxHealth : float = 100.0
@export var health : float = maxHealth

@export var moveSpeed : float = 50.0

@export var wanderDistance : int = 250

var player = null
var target = null

var statePool = ["idle", "idle", "idle", "wandering"]
var state : String = "idle"

func _ready():
	stateRandomiser()

func _physics_process(delta):
	if target == null:
		return
	
	var direction = target.global_position - global_position
	
	if direction.length() < 5 and state != "chasing":
		target = null
		stateRandomiser()
		return
	
	velocity = direction.normalized() * moveSpeed
	move_and_slide()

func stateRandomiser():
	if state == "hurt" or state == "chasing" or state == "attacking":
		return
	
	state = statePool[randi_range(0, statePool.size() - 1)]
	
	if state == "idle":
		idle()
		await get_tree().create_timer(randf_range(2.0, 10.0)).timeout
		stateRandomiser()
	elif state == "wandering":
		wander()

func _on_attack_range_area_entered(area):
	if area.is_in_group("Player") and area.is_in_group("Hurtbox"):
		target = null
		attack()

func attack():
	state = "attacking"
	SpriteManager.attack()

func damage(attackName):
	#take off health here and whatnot
	#then call on sprite manager to do animation
	state = "hurt"
	SpriteManager.damage()

func chasePlayer():
	state = "chasing"
	target = player
	SpriteManager.chase()

func idle():
	SpriteManager.idle()

func wander():
	SpriteManager.wander()
	WanderPoint.global_position = global_position + Vector2(randi_range(-wanderDistance, wanderDistance), randi_range(-wanderDistance, wanderDistance))
	target = WanderPoint

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
	if (anim_name.find("Attack") != -1 or anim_name.find("Hurt") != -1):
		if player == null:
			stateRandomiser()
		else:
			target = player
			state = "chasing"
