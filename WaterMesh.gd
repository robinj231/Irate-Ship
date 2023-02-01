extends MeshInstance

#var vertices = PoolVector3Array();
export (int) var width = 10;
export (int) var length = 10;

# Called when the node enters the scene tree for the first time.
func _ready():
	# for x in width:
	# 	for z in length:
	# 		vertices.push_back(Vector3(x,0,0));
	# 		vertices.push_back(Vector3(x+1,0,0));
	# 		vertices.push_back(Vector3(0,0,z+1));

	# 		vertices.push_back(Vector3(x+1,0,0));
	# 		vertices.push_back(Vector3(0,0,z+1));
	# 		vertices.push_back(Vector3(0,0,z));

	var vertices = PoolVector3Array()
	vertices.push_back(Vector3(0, 1, 0))
	vertices.push_back(Vector3(1, 0, 0))
	vertices.push_back(Vector3(0, 0, 1))
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var m = MeshInstance.new()
	m.mesh = arr_mesh


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
