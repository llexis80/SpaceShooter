class_name Enemy
extends Area3D


var lifecycle = Lifecycle.new()
var weapons = []
var power_up


func init(root_node, spawn, timeline):
	for node in get_children():
		if node.name == "Weapons":
			weapons = node.get_children()
	lifecycle.init(root_node, self, spawn, timeline)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	lifecycle.process(self, delta)


func explode():
	lifecycle.explode(self)


func get_hull_integrity():
	return lifecycle.get_hull_integrity()

func get_shield_power():
	return lifecycle.get_shield_power()

func _on_area_entered(area):
	if area.is_in_group("bullet") or area.is_in_group("missile"):
		lifecycle.process_hit(self, area)
		area.queue_free()
