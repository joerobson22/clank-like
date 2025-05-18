extends Node2D

@onready var player = get_parent()

var canAttack : bool = true

func _process(delta):
	if Input.is_action_just_released("attack") and canAttack:
		player.attack()
