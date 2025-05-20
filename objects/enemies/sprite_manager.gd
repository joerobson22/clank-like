extends Node2D

@onready var enemy = get_parent()

@onready var FullAP = $FullAP
@onready var BodyAP = $Body/BodyAP
@onready var ExtraAP = $Extras/ExtraAP

func damage():
	FullAP.play("Hurt")

func attack():
	FullAP.play("Attack")

func chase():
	pass

func idle():
	pass

func wander():
	pass
