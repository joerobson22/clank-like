extends Node2D

@onready var enemy = get_parent()

@onready var FullAP = $FullAP
@onready var BodyAP = $Body/BodyAP
@onready var ExtraAP = $Extras/ExtraAP

func RESET():
	FullAP.play("RESET")

func damage(ENEMYTYPE):
	BodyAP.play(ENEMYTYPE + "Hurt")

func die(ENEMYTYPE):
	FullAP.stop()
	ExtraAP.stop()
	BodyAP.play(ENEMYTYPE + "Die")

func chargeLunge(ENEMYTYPE):
	FullAP.play(ENEMYTYPE + "LungeChargeup")

func chargeRanged(ENEMYTYPE):
	FullAP.play(ENEMYTYPE + "RangedChargeup")

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
