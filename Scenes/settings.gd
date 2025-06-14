extends Node3D


@onready var window_size_option_button: OptionButton = $CanvasLayer/OptionsContainer/WindowSizeOptionButton
@onready var fullscreen_button: CheckButton = $CanvasLayer/OptionsContainer/FullscreenButton
@onready var asteroid: Enemy = $asteroid
@onready var ufo_ship: Enemy = $ufo_ship
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var gamma_slider: HSlider = $CanvasLayer/OptionsContainer/GammaSlider
@onready var master_volume_slider: HSlider = $CanvasLayer/OptionsContainer/MasterVolumeSlider
@onready var music_volume_slider: HSlider = $CanvasLayer/OptionsContainer/MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = $CanvasLayer/OptionsContainer/SfxVolumeSlider
@onready var language_option_button: OptionButton = $CanvasLayer/OptionsContainer/LanguageOptionButton


var options


func _ready() -> void:
	options = OptionsManager.read_options()
	if options.has("full_screen"):
		fullscreen_button.set_pressed_no_signal(options.full_screen)
	window_size_option_button.clear()
	var screen_size = DisplayServer.screen_get_size()
	var index = 0
	for size in OptionsManager.window_size_list:
		if size.width <= screen_size.x and size.height <= screen_size.y:
			window_size_option_button.add_item(str(size.width) + " x " + str(size.height))
			if options.has("window_width") and size.width == options.window_width and options.has("window_height") and size.height == options.window_height:
				window_size_option_button.select(index)
			index += 1
	gamma_slider.value = options.tonemap_exposure if options.has("tonemap_exposure") else 1.0
	master_volume_slider.value = options.master_volume if options.has("master_volume") else 1.0
	music_volume_slider.value = options.music_volume if options.has("music_volume") else 1.0
	sfx_volume_slider.value = options.sfx_volume if options.has("sfx_volume") else 1.0
	reload_language_options()
	spawn_asteroid()
	spawn_ufo()


func reload_language_options():
	language_option_button.clear()
	var index = 0
	for language in OptionsManager.locale_list:
		language_option_button.add_icon_item(language.flag, tr(language.label))
		if language.locale == options.locale:
		#if language["locale"] == options.locale:
			language_option_button.select(index)
		index += 1
		

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		back_to_main_menu()


func _on_back_button_pressed() -> void:
	back_to_main_menu()

func back_to_main_menu():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func _on_window_size_option_button_item_selected(index: int) -> void:
	var size = OptionsManager.window_size_list[index]
	options.window_width = size.width
	options.window_height = size.height
	OptionsManager.write_options(options)
	OptionsManager.resize_window()


func _on_fullscreen_button_toggled(button_pressed):
	options.full_screen = button_pressed
	OptionsManager.write_options(options)
	OptionsManager.set_window_mode()
	OptionsManager.resize_window()


func spawn_asteroid():
	var spawn = {
		"hit_points": 20.0,
		"coords": Vector3.ZERO,
		"scale": Vector3(1, 1, 1),
		"direction": Vector3.ZERO,
		"rotation": Utils.get_random_vector3_in_range(0.1, 1)
	}
	asteroid.init(self, spawn, [])


func spawn_ufo():
	var spawn = {
		"hit_points": 20.0,
		"coords": Vector3.ZERO,
		"scale": Vector3(1, 1, 1),
		"direction": Vector3.ZERO,
		"rotation": Vector3(0, 0, 0.2)
	}
	ufo_ship.init(self, spawn, [])


func _on_gamma_slider_value_changed(value: float) -> void:
	options.tonemap_exposure = gamma_slider.value
	OptionsManager.write_options(options)
	world_environment.environment.tonemap_exposure = options.tonemap_exposure


func _on_enemy_spawned(_enemy):
	pass


func _on_master_volume_slider_value_changed(value: float) -> void:
	options.master_volume = value
	OptionsManager.write_options(options)
	SoundManager.set_master_volume(value)


func _on_music_volume_slider_value_changed(value: float) -> void:
	options.music_volume = value
	OptionsManager.write_options(options)
	SoundManager.set_music_volume(value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	options.sfx_volume = value
	OptionsManager.write_options(options)
	SoundManager.set_sfx_volume(value)


func _on_key_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/key_binding.tscn")


func _on_language_option_button_item_selected(index: int) -> void:
	var language = OptionsManager.locale_list[index]
	options.locale = language.locale
	#options.locale = language["locale"]
	OptionsManager.write_options(options)
	OptionsManager.set_locale()
	reload_language_options()
