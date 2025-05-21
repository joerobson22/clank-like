extends Node2D

@onready var enemy = get_parent()

@onready var FullAP = $FullAP
@onready var BodyAP = $Body/BodyAP
@onready var ExtraAP = $Extras/ExtraAP

func damage(ENEMYTYPE):
	FullAP.play(ENEMYTYPE + "Hurt")

func chargeLunge(ENEMYTYPE):
	FullAP.play(ENEMYTYPE + "LungeChargeup")

func attack(attackMethod, ENEMYTYPE):
	FullAP.play(ENEMYTYPE + attackMethod)

func finishAttack(ENEMYTYPE):
	FullAP.play(ENEMYTYPE + "FinishAttack")

func chase(ENEMYTYPE):
	pass

func idle(ENEMYTYPE):
	pass

func wander(ENEMYTYPE):
	pass
