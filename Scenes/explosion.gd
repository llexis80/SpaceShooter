extends Node3D


@onready var fire_mesh = $fire

var fire_width
var fire_heigth
var fire_speed
var fire_aperture = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fire_mesh.mesh.size = Vector2(fire_width, fire_heigth)


func init(x, z, width, heigth, speed = 1.0):
	translate(Vector3(x, 0, z))
	fire_width = width
	fire_heigth = heigth
	fire_speed = speed
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fire_aperture < 1.0:
		fire_aperture += delta * fire_speed
		fire_mesh.set_instance_shader_parameter("fire_aperature", fire_aperture)
	else:
		queue_free()
