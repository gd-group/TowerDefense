extends KinematicBody2D
class_name Mob

signal reach_end(damage)

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
export var sid = 0			# enemy id
export var distance = 0.0	# enemy travel distance
export var speed = 100
export var hp = 3

var path_follow: PathFollow2D
var offset = 0.0
var bar_pos = Vector2()
var total_hp = 0

# get position in path with distance and y-offset
func get_path_position(dis: float) -> Vector2:
	# update path follow offset as distance
	path_follow.offset = dis
	# offset matrix by y-axis
	var mtx_offset = Transform2D().translated(Vector2(0, offset))
	# final matrix = path_follow matrix * offset matrix
	# tv = (MA * (MB * v))
	var mtx = path_follow.transform * mtx_offset
	# get_origin() is equal to final translated position
	return mtx.get_origin()

func setup(follow: PathFollow2D, offset: float) -> void:
	self.offset = offset
	distance = 0
	path_follow = follow
	# update path follow offset as distance
	position = get_path_position(distance)
	rotation = path_follow.rotation
	total_hp = hp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bar_pos = $Position2D.position
	$Position2D/Progress.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _process(delta: float) -> void:
	if $Position2D/Progress.visible:
		# reverse rotation of progress bar using inverse transform matrix
		var mtx = transform.affine_inverse()
		$Position2D.position = mtx.basis_xform(bar_pos)
		$Position2D.rotation = mtx.get_rotation()
	
func _physics_process(delta: float) -> void:
	distance += delta * speed
	path_follow.offset = distance
	# update position
	position = get_path_position(distance)
	rotation = path_follow.rotation
	# check if reached end
	if path_follow.unit_offset >= 0.998:
		emit_signal("reach_end", 1)
		queue_free()

# get advanced position in path where shooting from position and speed
func advanced_position(from_pos: Vector2, from_speed: float):
	# distance from from_pos to mob position
	var dis = from_pos.distance_to(position)
	# approximate time to hit mob
	var t = dis / from_speed
	# approximate advanced distance when bullet hit
	var advanced_dis = distance + speed * t
	return get_path_position(advanced_dis)
	
func on_hit(damage: int):
	hp -= damage
	if hp <= 0:
		queue_free()
	else:
		$Position2D/Progress.visible = true
		$Position2D/Progress.value = (hp * 100.0) / total_hp
