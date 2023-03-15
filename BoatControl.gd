extends RigidBody


# Declare member variables here. Examples:
# var a = 2

export(float) var moveSpeed;
export(float) var turnSpeed;
export(float) var turnLeanIntensity;
export(float) var jumpStrength;
export(NodePath) onready var sea = get_node("/root/Spatial/Sea");

var moving;
var turning;
var jump;

# Called when the node enters the scene tree for the first time.
func _ready():
	moving = 0;
	turning = 0;
	jump = false;

func _input(event):
	if Input.is_key_pressed(KEY_W):
		moving = 1;
	elif Input.is_key_pressed(KEY_S):
		moving = -1;
	else:
		moving = 0;

	if Input.is_key_pressed(KEY_D):
		turning = -1;
	elif Input.is_key_pressed(KEY_A):
		turning = 1;
	else:
		turning = 0;

	if Input.is_key_pressed(KEY_SPACE):
		jump = true;


func _physics_process(delta):
	add_central_force(transform.basis.x * moveSpeed * moving * delta);
	add_torque(transform.basis.y * turnSpeed * turning * delta);
	add_torque(transform.basis.x * turnLeanIntensity * -turning * delta);
	if(jump):
		var waveHeight = sea.GetWaveHeight(Vector2(global_transform.origin.x, global_transform.origin.z));
		if(global_transform.origin.y < waveHeight):
			apply_central_impulse(Vector3.UP *  jumpStrength);
		jump = false;
	sea.global_transform.origin.x = global_transform.origin.x-500;
	sea.global_transform.origin.z = global_transform.origin.z-500;
