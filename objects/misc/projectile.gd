extends RigidBody2D

@onready var Hitbox = $Hitbox

var PROJECTILETYPE : String = ""

var targetGroup : String
var friendlyGroup : String

var explosive : bool = false
var damage : float

func _ready():
	#init dependent on the projectiletype
	Hitbox.add_to_group(friendlyGroup)

func damageTarget(target):
	target.damage(damage)

func deleteProjectile():
	queue_free()

func _on_hitbox_area_entered(area):
	if area.is_in_group("Hurtbox") and area.is_in_group(targetGroup):
		var node = area.get_parent().get_parent()
		damageTarget(node)
		if !node.isInvincible():
			deleteProjectile()

func _on_body_entered(body):
	if body.is_in_group(targetGroup):
		damageTarget(body)
	if body.get_script() != null:
		if !body.isInvincible():
			deleteProjectile()
	else:
		deleteProjectile()
