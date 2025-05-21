extends Node2D

@onready var parent = get_parent()

#AREA DETECTION
func _on_object_detection_area_entered(area):
	if area.is_in_group("Player") and area.is_in_group("Detectable"):
		parent.player = area.get_parent().player
		parent.chasePlayer()

func _on_object_detection_area_exited(area):
	if area.is_in_group("Player") and area.is_in_group("Detectable"):
		parent.player = null
		parent.state = "idle"
		parent.stateRandomiser()
