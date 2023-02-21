extends MeshInstance
tool

# Declare member variables here. Examples:
export (NodePath) onready var light = get_node("/root/Spatial/DirectionalLight");
var lightDir;

# Called when the node enters the scene tree for the first time.
func _ready():
	factorLighting();


func factorLighting():
	lightDir = light.transform.basis.z;
	for index in self.get_surface_material_count():
		if(!self.get_surface_material(index) is SpatialMaterial):
			self.get_surface_material(index).set_shader_param("lightDir", lightDir);

#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(light != null and lightDir != light.transform.basis.z):
		factorLighting();
