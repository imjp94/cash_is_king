tool
extends Spatial

enum GRADE {
	COPPER, SILVER, GOLD
}
const GRADE_COLOR = [Color("e8a06e"), Color.silver, Color.gold]
const GRADE_DAMAGE = [1, 2, 5]

export(GRADE) var grade = GRADE.COPPER setget set_grade

onready var mesh_instance = $MeshInstance
onready var anim_player = $AnimationPlayer
onready var timer = $Timer

var target setget set_target

var _origin = Vector3.ZERO


func _ready():
	set_target(target)
	set_grade(grade)
	_origin = global_transform.origin

func _process(delta):
	if not is_instance_valid(target): # TODO: Identify this coin is for animation or projectile, free it if solely for animation
		set_process(!!target)
		return

	var p0 = _origin
	var p1 = _origin + ((target.global_transform.origin - _origin) / 2.0) + (Vector3.UP * 30.0)
	var p2 = target.global_transform.origin
	var t = (1.0 - timer.time_left / timer.wait_time)
	global_transform.origin = quadratic_bezier(p0, p1, p2, t)
	if t >= 0.98:
		queue_free()

func set_target(v):
	target = v
	set_process(!!target)

func quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var r = q0.linear_interpolate(q1, t)
	return r

func set_grade(v):
	var old = grade
	grade = v
	if is_inside_tree():
		var material = mesh_instance.get("material/0")
		material.set("albedo_color", GRADE_COLOR[grade])
		material.set("emission", GRADE_COLOR[grade])
