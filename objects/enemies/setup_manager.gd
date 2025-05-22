extends Node2D

@onready var parent = get_parent()
@onready var AP = $AnimationPlayer

func setup(ENEMYTYPE):
	AP.play(ENEMYTYPE)
