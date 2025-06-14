extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")


func _on_restore_default_button_pressed():
	KeyManager.reset_keymap()
	for item in Utils.get_all_children($CanvasLayer/ControlsContainer):
		if item is KeyBindingButton:
			item.display_current_key()


func _on_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.
