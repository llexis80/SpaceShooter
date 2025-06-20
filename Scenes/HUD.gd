extends CanvasLayer

@onready var boss = $Boss
@onready var player_hull_integrity_bar = $Player/GridContainer/HullIntegrityBar
@onready var player_shield_power_bar = $Player/GridContainer/ShieldPowerBar
@onready var boss_hull_integrity_bar = $Boss/GridContainer/HullIntegrityBar
@onready var boss_shield_power_bar = $Boss/GridContainer/ShieldPowerBar
@onready var missile_counter = $Player/GridContainer/MissileCounter

func set_player_values(player):
	tween_property(player_hull_integrity_bar, "value", player.hull_integrity)
	tween_property(player_shield_power_bar, "value", player.shield_power)
	missile_counter.text = str(player.missiles)

func set_boss_values(boss):
	tween_property(boss_hull_integrity_bar, "value", boss.get_hull_integrity())
	tween_property(boss_shield_power_bar, "value", boss.get_shield_power())
	
func tween_property(element, property, value):
	if value != element.get(property):
		var tween = get_tree().create_tween()
		tween.tween_property(element, "value", value, 1)

func show_boss_section():
	boss.visible = true

func hide_boss_section():
	boss.visible = false
