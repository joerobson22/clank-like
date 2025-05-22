extends Node2D

@onready var Under = $UnderBar
@onready var Over = $OverBar

var maxHealth : float
var health : float

func setup(h, m, c):
	maxHealth = m
	health = h
	$AnimationPlayer.play(c)
	
	Over.max_value = maxHealth
	Under.max_value = maxHealth
	Over.value = health
	Under.value = health

func damage(damage) -> bool:
	health -= damage
	Over.value = health
	
	get_tree().create_tween().tween_property(Under, "value", health, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	return health <= 0
