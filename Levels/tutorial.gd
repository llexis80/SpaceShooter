extends Node

var asteroid_scene = preload("res://Scenes/asteroid.tscn")
var ufo_ship_scene = preload("res://Scenes/ufo_ship.tscn")
var ufo_bullet_scene = preload("res://Scenes/ufo_bullet.tscn")
var powerup_w_scene = preload("res://Scenes/powerup_w.tscn")
var powerup_s_scene = preload("res://Scenes/powerup_s.tscn")
var missile_scene = preload("res://Scenes/missile.tscn")
var boss_scene = preload("res://Scenes/boss.tscn")
var torpedo_scene = preload("res://Scenes/torpedo.tscn")
var powerup_m_scene = preload("res://Scenes/powerup_m.tscn")
var power_s_scene = preload("res://Scenes/powerup_s.tscn")
var explosion_scene = preload("res://Scenes/explosion.tscn")
var hit_effect_scene = preload("res://Scenes/hit_effect.tscn")
var bullet_scene = preload("res://Scenes/bullet.tscn")

var timeline = []
var elapsed_time = 0.0
var previous_second = 0

func init(node, more_scenes: Array):
	var scenes = [asteroid_scene, ufo_ship_scene, ufo_bullet_scene, powerup_w_scene, powerup_s_scene, missile_scene,
	boss_scene, torpedo_scene, powerup_m_scene, power_s_scene, explosion_scene, hit_effect_scene, bullet_scene]
	scenes.append_array(more_scenes)
	LevelManager.compile_shaders(node, scenes)
	timeline.append({"timestamp": 1, "wave": get_asteroid_wave()})
	timeline.append({"timestamp": 2, "wave": get_ufo_ship_wave()})
	timeline.append({"timestamp": 3, "wave": get_missile_wave()})
	timeline.append({"timestamp": 4, "wave": get_missile_wave(true)})
	timeline.append({"timestamp": 6, "wave": get_boss_wave()})

func process(node, delta):
	elapsed_time += delta
	if elapsed_time - previous_second > 1.0:
		previous_second += 1.0
		for event in timeline:
			if event.timestamp <= elapsed_time and not event.has("processed"):
				process_wave(node, event.wave)
				event.processed = true

func process_wave(node, wave):
	for item in wave:
		var enemy = item.enemy.instantiate()
		enemy.init(node, item.spawn, item.timeline)
		node.add_child(enemy)

func get_asteroid_wave():
	var wave = []
	for i in 11:
		wave.append({
			"enemy": asteroid_scene,
			"spawn": {
				"hit_points": 20.0,
				"coords": Vector3(Utils.get_random_x_in_viewport(10), 0, GameManager.boundary.top - i * 2),
				"scale": Utils.get_random_vector3_in_range(1, 4),
				"direction": Vector3(0, 0, randf_range(5.0 , 15.0)),
				"rotation": Utils.get_random_vector3_in_range(0.1, 0.1), # "," does it need at the end?
			},
			"timeline": []
		})
	return wave

func get_ufo_ship_wave():
	var wave = []
	var powerup_index = randi_range(0, 10)
	for i in 11:
		wave.append({
			"enemy": ufo_ship_scene,
			"spawn": {
				"hit_points": 20.0,
				"coords": Vector3(-50 + i * 10, 0, GameManager.boundary.top + i),
				"scale": Vector3(0.5, 0.5, 0.5),
				"direction": Vector3(0, 0, 2.0),
				"rotation": Vector3(0, 0, 0.5),
				"power_up": powerup_w_scene if i == powerup_index else null,
			},
			"timeline": get_ufo_ship_timeline()
		})
	return wave

func get_ufo_ship_timeline():
	return [{
		"timestamp": 5,
		"fire": {
			"shot": ufo_bullet_scene,
			"weapon": "Main",
		}
	}]

func get_missile_wave(power_up = false):
	var wave = []
	wave.append({
		"enemy": missile_scene,
		"spawn": {
			"hit_points": 20.0,
			"coords": Vector3(randf_range(-20, 20), 0, GameManager.boundary.top),
			"scale": Vector3(1, 1, 1),
			"direction": Vector3(0, 0, 20.0),
			"rotation": Vector3.ZERO,
			"target": GameManager.player,
			"power_up": powerup_m_scene if power_up else null,
		},
		"timeline": []
		})
	return wave

func get_boss_wave():
	var wave = []
	wave.append({
		"enemy": boss_scene,
		"spawn": {
			"hit_points": 500.0,
			"shield_power": 500.0,
			"coords": Vector3(0, 0, GameManager.boundary.top -20),
			"scale": Vector3(4, 4, 4),
			"direction": Vector3(0, 0, 3.0),
			"rotation": Vector3(0, 0.5, 0),
		},
		"timeline": get_boss_timeline()
		})
	return wave

func get_boss_timeline():
	var events = []
	for i in 5:
		for j in 4:
			events.append({
				"timestamp": 10 + (i + 1) * 2,
				"fire": {
					"shot": torpedo_scene,
					"weapon": "Gun " + str(j + 1),
					}
				})
	return events
