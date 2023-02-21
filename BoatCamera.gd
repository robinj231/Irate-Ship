extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var camRotH = 0;
var camRotV = 0;

export(NodePath) onready var boat = get_node("/root/Spatial/Boat");
export(float) var speedH;
export(float) var speedV;
export(float) var vMin = -55.0;
export(float) var vMax = 75.0;

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);


func _input(event):
	if event is InputEventMouseMotion:
		camRotH += -event.relative.x * speedH;
		camRotV += -event.relative.y * speedV;
	
func _physics_process(delta):
	global_transform.origin.x = boat.global_transform.origin.x;
	global_transform.origin.z = boat.global_transform.origin.z;
	camRotV = clamp(camRotV, vMin, vMax);
	rotation_degrees.y = camRotH;
	rotation_degrees.x = camRotV;
