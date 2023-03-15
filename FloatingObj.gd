extends Spatial

export (float) var depthBeforeSubmerged = 1.0;
export(float) var depthOffset = 0.5;
export (float) var displacementAmount = 6.0;
export(int) var floaterCount = 4;
export (float) var waterDrag = 0.99;
export (float) var waterAngularDrag = 0.5;
export(NodePath) onready var sea = get_node("/root/Spatial/Sea");
export(NodePath) onready var rigidBody = get_parent();

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	var waveHeight = sea.GetWaveHeight(Vector2(global_transform.origin.x, global_transform.origin.z));
	#rigidBody.add_force(Vector3(0.0, -rigidBody.gravity_scale/floaterCount, 0.0), transform.origin);
	
	var yPosOffset = global_transform.origin.y - depthOffset;
	if(yPosOffset < waveHeight):
		var displacementMult = clamp((waveHeight-yPosOffset)/depthBeforeSubmerged, 0, 1) * displacementAmount;
		rigidBody.add_force(Vector3(0.0, displacementMult, 0.0), global_transform.origin - rigidBody.global_transform.origin);
		rigidBody.add_central_force(displacementMult * -rigidBody.linear_velocity * waterDrag * delta);
		rigidBody.add_torque(displacementMult * -rigidBody.angular_velocity * waterAngularDrag * delta);
