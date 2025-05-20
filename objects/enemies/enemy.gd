extends CharacterBody2D

@onready var SpriteManager = $SpriteManager
@onready var InteractionManager = $InteractionManager

func damage(attackName):
	#take off health here and whatnot
	#then call on sprite manager to do animation
	SpriteManager.damage()
