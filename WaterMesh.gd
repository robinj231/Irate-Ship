extends "res://ToonEntity.gd"
tool

var vertices = PoolVector3Array();
var indexes = PoolIntArray();
var uv = PoolVector2Array();
var normals = PoolVector3Array();

export(NodePath) onready var playerBoat = get_node("/root/Spatial/Boat");
export(Vector2) var waveADir;
export(float) var waveASteepness;
export(float) var waveALength;
export(Vector2) var waveBDir;
export(float) var waveBSteepness;
export(float) var waveBLength;
export(Vector2) var waveCDir;
export(float) var waveCSteepness;
export(float) var waveCLength;

export (int) var generate = 0;

export(int) var width = 10;

export(float) onready var time = 0.0;

export(ShaderMaterial) var waterShaderInstance;
export(Color) var waterColor;

var waterShader;

func _ready():
	if Engine.editor_hint and generate:
		GenerateMesh();
		set_surface_material(0, waterShaderInstance);
	time = 0.0;
	waterShader = self.get_surface_material(0);
	waterShader.set_shader_param("waveADir", waveADir);
	waterShader.set_shader_param("waveASteepness", waveASteepness);
	waterShader.set_shader_param("waveALength", waveALength);
	waterShader.set_shader_param("waveBDir", waveBDir);
	waterShader.set_shader_param("waveBSteepness", waveBSteepness);
	waterShader.set_shader_param("waveBLength", waveBLength);
	waterShader.set_shader_param("waveCDir", waveCDir);
	waterShader.set_shader_param("waveCSteepness", waveCSteepness);
	waterShader.set_shader_param("waveCLength", waveCLength);
	waterShader.set_shader_param("albedo", waterColor);
	

func _physics_process(delta):
	time += delta;
	waterShader.set_shader_param("objTime", time);
	waterShader.set_shader_param("waveADir", waveADir);
	waterShader.set_shader_param("waveASteepness", waveASteepness);
	waterShader.set_shader_param("waveALength", waveALength);
	waterShader.set_shader_param("waveBDir", waveBDir);
	waterShader.set_shader_param("waveBSteepness", waveBSteepness);
	waterShader.set_shader_param("waveBLength", waveBLength);
	waterShader.set_shader_param("waveCDir", waveCDir);
	waterShader.set_shader_param("waveCSteepness", waveCSteepness);
	waterShader.set_shader_param("waveCLength", waveCLength);

	
func gerstnerWave(waveDir, waveSteepness, waveLength, pos):
	var k = 2.0 * 3.14159265358979323846 / waveLength;
	var  c = sqrt(9.8 / k);
	var  d = waveDir.normalized();
	var  f = k * (d.dot(pos) - c * time);
	var  a = waveSteepness / k;

	return a * sin(f);

func GetWaveHeight(pos):
	return gerstnerWave(waveADir, waveASteepness, waveALength, pos) + gerstnerWave(waveBDir, waveBSteepness, waveBLength, pos) + gerstnerWave(waveCDir, waveCSteepness, waveCLength, pos);




func GenerateMesh():
	var meshData = [];
	meshData.resize(ArrayMesh.ARRAY_MAX);

	for z in width:
		for x in width:
			vertices.push_back(Vector3(x,0,z));
			uv.push_back(Vector2(x/20.0,z/20.0));



	var lastVertex = 0;
	var curVertex = 0;
	while lastVertex < vertices.size():
		indexes.push_back(curVertex);
		indexes.push_back(curVertex + 1);
		indexes.push_back(curVertex + width + 1);

		indexes.push_back(curVertex);
		indexes.push_back(curVertex + width + 1);
		indexes.push_back(curVertex + width);
		curVertex += 1;
		if(curVertex % width == width-1):
			curVertex += 1;
		lastVertex = curVertex + width + 1;

	for v in vertices:
		normals.push_back(Vector3(0,1,0));

	meshData[ArrayMesh.ARRAY_VERTEX] = vertices;

	meshData[ArrayMesh.ARRAY_INDEX] = indexes;

	meshData[ArrayMesh.ARRAY_TEX_UV] = uv;

	meshData[ArrayMesh.ARRAY_NORMAL] = normals;

	mesh = ArrayMesh.new();
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, meshData);
