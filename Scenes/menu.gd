extends Node3D

@onready var logo_light: DirectionalLight3D = $LogoLight

var current_rotation = 0.0
var max_rotation = 3.0
var rotating = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#OptionsManager.release_mouse()
	#GameManager.capture_mouse()
	GameManager.release_mouse()
	GameManager.set_boundary(
		$"Boundary/LeftWall".position.x,
		$"Boundary/RightWall".position.x,
		$Boundary/TopWall.position.z,
		$Boundary/BottomWall.position.z
	)
	GameManager.spawn_stars(self)
	SoundManager.fade_in_intro_song(64.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	GameManager.process_background(self, delta)
	if rotating:
		logo_light.rotate_x(delta)
		current_rotation += delta
		if rotating and current_rotation >= max_rotation:
			rotating = false


func _on_start_button_pressed() -> void:
	SoundManager.fade_out_intro_song()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")
