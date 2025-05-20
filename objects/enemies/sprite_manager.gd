extends Node2D

@onready var enemy = get_parent()

@onready var FullAP = $FullAP
@onready var BodyAP = $Body/BodyAP
@onready var ExtraAP = $Extras/ExtraAP

func damage():
	FullAP.play("damage")
