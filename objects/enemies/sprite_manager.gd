extends Node2D

@onready var enemy = get_parent()

@onready var FullAP = $FullAP
@onready var BodyAP = $Body/BodyAP
@onready var ExtraAP = $Extras/ExtraAP

func damage():
	FullAP.play("Hurt")

func attack(attackMethod):
	FullAP.play("Attack")

func finishAttack():
	FullAP.play("FinishAttack")

func chase():
	pass

func idle():
	pass

func wander():
	pass
