extends Node3D

@onready var player_scene = preload("res://Scenes/player.gd")
@onready var missile_scene = preload("res://Scenes/rocket.tscn")
@onready var loading_label: Label = $LoadingLabel
@onready var pause_box: VBoxContainer = $PauseBox

@onready var debug = $Debug
@onready var player = $player
@onready var hud = $Hud
@onready var camera = $Camera3D
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var pixelation: ColorRect = $CanvasLayer2/Pixelation

var fire_cadence = 0.2
var fire_cooldown = 0.0
var missile_cadence = 1.0
var missile_cooldown = 0.0
var current_level
var level_loaded = false
var level_loading = false
var thread
var global_time = 0.0
var pixel_size = 16.0


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.capture_mouse()
	pause_box.visible = false
	GameManager.set_boundary(
		$"Boundary/LeftWall".position.x,
		$"Boundary/RightWall".position.x,
		$Boundary/TopWall.position.z,
		$Boundary/BottomWall.position.z
	)
	GameManager.set_camera(camera)
	GameManager.set_world_environment(world_environment)
	GameManager.spawn_stars(self)
	player.connect("player_destroyed", Callable(self, "_on_player_destroyed"))
	player.connect("update_hud", Callable(self, "_on_update_hud"))
	player.init()
	GameManager.set_player(player)
	hud.hide_boss_section()
	debug.init(player)
	color_rect.visible = false


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		GameManager.release_mouse()
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")
	if Input.is_action_just_pressed("pause_game"):
		pause_game()

func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		pause_game()

func pause_game():
	pause_box.visible = true
	GameManager.set_pause_environment()
	get_tree().paused = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if level_loaded:
		if pixel_size > 1.0:
			pixelate(delta)
		pause_box.visible = get_tree().paused
		global_time += delta
		RenderingServer.global_shader_parameter_set("global_time", global_time)
		GameManager.process_background(self, delta)
		GameManager.process_debris(delta)
		current_level.process(self, delta)
		if Input.is_action_pressed("shoot_primary") and fire_cooldown <= 0:
			fire_bullet()
		if Input.is_action_pressed("fire_secondary") and missile_cooldown <= 0:
			fire_missile()
		fire_cooldown -= delta
		missile_cooldown -= delta
	elif not level_loading:
		thread = Thread.new()
		thread.start(Callable(self, "load_level").bind("tutorial"))


func pixelate(delta):
	pixelation.get_material().set_shader_parameter("pixel_size", pixel_size)
	pixel_size -= delta * 10
	if pixel_size <= 1.0:
		pixel_size = 1.0

func load_level(level_name):
	Thread.set_thread_safety_checks_enabled(false)
	level_loading = true
	current_level = LevelManager.load_level(level_name)
	current_level.init(self, [player_scene])
	level_loaded = true
	level_loading = false
	thread.call_deferred("wait_for_finish")
	loading_label.visible = false


func fire_bullet():
	if Utils.is_valid_node(player):
		fire_cooldown = fire_cadence
		GameManager.fire_player_weapon(self)


func fire_missile():
	if Utils.is_valid_node(player) and player.missiles >0:
		var missile_weapon = player.get_main_weapon()
		if missile_weapon:
			missile_cooldown = missile_cadence
			var missile = missile_scene.instantiate()
			missile.init(missile_weapon)
			add_child(missile)
			player.missiles -= 1
			_on_update_hud()
			SoundManager.fire_missile()

func _on_player_destroyed():
	GameManager.create_explosion(self, player, 30, 30)

func _on_enemy_destroyed(enemy):
	GameManager.create_explosion(self, enemy, 15, 15)
	if enemy.is_in_group("boss"):
		hud.hide_boss_section()
		shockwave(enemy)


func shockwave(enemy):
	var projection = GameManager.to_2D(enemy.position) / (get_window().size as Vector2);
	var material = color_rect.get_material()
	material.set_shader_parameter("center", projection)
	color_rect.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(material, "shader_parameter/size", 2.0, 2.0)
	tween.tween_callback(hide_shader_rect)


func hide_shader_rect():
	color_rect.visible = false


func _on_show_hit_effect(enemy, bullet):
	GameManager.create_hit_effect(self, enemy, bullet)
	if enemy.is_in_group("boss"):
		hud.set_boss_values(enemy)

func _on_update_hud():
	hud.set_player_values(player)

func _on_weapon_fired(enemy, event):
	GameManager.fire_enemy_weapon(self, enemy, event)

func _on_enemy_spawned(enemy):
	if enemy.is_in_group("boss"):
		hud.show_boss_section()

func _exit_tree() -> void:
	if thread.is_alive():
		thread.wait_for_finish()
