extends Node2D

@onready var player = get_parent()
@onready var DirectionAP = $Hitbox/DirectionAP

var enemyList = []

var cooldownTime : float = 0.1
var fullCooldownTime : float = 0.25
var canAttack : bool = true

func _process(delta):
	if Input.is_action_just_released("attack") and canAttack:
		player.attack()
		canAttack = false
	
	if Input.is_action_just_released("interact"):
		player.interact()

func setDirection(directionString):
	DirectionAP.play(directionString)

func cooldown():
	var time = cooldownTime
	player.attackNum += 1
	if player.attackNum > player.numAttacks:
		player.attackNum = 1
		time = fullCooldownTime
	await get_tree().create_timer(time).timeout
	canAttack = true

func _on_hitbox_area_entered(area):
	if area.is_in_group("Enemy") and area.is_in_group("Hurtbox"):
		if enemyList.find(area.get_parent()) == -1:
			#print("added")
			enemyList.append(area.get_parent().parent)
	elif area.is_in_group("Player") and area.is_in_group("DamageActivator"):
		player.damageEnemies()

func _on_hitbox_area_exited(area):
	if area.is_in_group("Enemy") and area.is_in_group("Hurtbox"):
		#print("removed")
		enemyList.erase(area.get_parent().parent)

func _on_hurtbox_area_entered(area):
	pass


func _on_detectable_area_entered(area):
	pass # Replace with function body.
