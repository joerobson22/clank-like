extends Node2D

@onready var parent = get_parent()

#AREA DETECTION
func _on_object_detection_area_entered(area):
	if area.is_in_group("Player") and area.is_in_group("Detectable"):
		parent.player = area.get_parent().player

func _on_object_detection_area_exited(area):
	pass


func _on_forget_radius_area_exited(area):
	if area.is_in_group("Player") and area.is_in_group("Detectable"):
		parent.player = null
		parent.stateRandomiser()
