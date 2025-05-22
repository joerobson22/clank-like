extends Node2D

@onready var player = get_parent()

@onready var BodyAP = $Body/BodyAP
@onready var WeaponAP = $Weapon/WeaponAP
@onready var FullAP = $FullAP

func attack(attackNum):
	var baseAttackString = player.weaponName + "BasicAttack" + attackNum
	var fullAttackString = baseAttackString + "_" + player.direction
	
	player.get_node("InteractionManager/Hitbox/DamageActivator/AnimationPlayer").play(baseAttackString)
	WeaponAP.play(fullAttackString)
	BodyAP.play(fullAttackString)

func getDirection(inputVector : Vector2) -> String:
	var newDirection = ""
	if inputVector.x != 0 and inputVector.y != 0:
		newDirection += "DIAGONAL"
	elif inputVector.x != 0 or inputVector.y != 0:
		newDirection += "STRAIGHT"
	
	if inputVector.y > 0:
		newDirection += "DOWN"
	elif inputVector.y < 0:
		newDirection += "UP"
	
	return newDirection

func _on_full_ap_animation_finished(anim_name):
	pass

func _on_weapon_ap_animation_finished(anim_name):
	pass
	#print(anim_name)
	#if anim_name.find("Attack") != -1:
	#	player.states["attacking"] = false
	#	player.damageEnemies(anim_name)

func _on_body_ap_animation_finished(anim_name):
	pass # Replace with function body.
