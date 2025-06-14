class_name PowerUp
extends Area3D


var lifecycle = PowerUpLifecycle.new()

@export var shield_boost = 0.0
@export var activate_side_weapons = false
@export var add_missle = false

func init(enemy):
	position = enemy.global_position
	lifecycle.init(self)
	enemy.power_up = null

func _process(delta):
	lifecycle.process(self, delta)


func _on_area_entered(area):
	pass # Replace with function body.
