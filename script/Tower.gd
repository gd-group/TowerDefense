extends Area2D
class_name Tower

signal tower_select(tower)
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

export var shoot_time = 0.5
export var bullet_speed = 400
export var damage = 1
var total_cost = 100
var radius = 100
var bullet_pack = preload("res://Bullet.tscn")
var within_mobs = []
var target: Mob = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var shape: CircleShape2D = $Range/RangeShape.shape
	radius = shape.radius	
	set_selected(false)
	$ShootTimer.connect("timeout", self, "shoot")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _physics_process(delta: float) -> void:
	if target != null:
		var angle = position.angle_to_point(target.position)
		$TowerDir.rotation = angle - PI * 0.5

func setup(tower_id: int, pos: Vector2, cost: int):
	$TowerDir/TowerSprite.animation = "tower" + str(tower_id)
	position = pos

func set_selected(selected: bool):
	$Range/RangeSprite.visible = selected
	
func sort_mob(mob1: Mob, mob2: Mob):
	return mob1.distance < mob2.distance
	
func find_target():
	if len(within_mobs) > 0:
		within_mobs.sort_custom(self, "sort_mob")
	target = within_mobs[-1] if len(within_mobs) > 0 else null
	if target:
		if $ShootTimer.is_stopped():
			shoot()

func upgrade(cost: int):
	var shape: CircleShape2D = $Range/RangeShape.shape
	radius = radius * 1.2
	shape.radius = radius
	var sp_scale = radius / 160.0
	$Range/RangeSprite.scale = Vector2(sp_scale, sp_scale)
	
func shoot():
	if not target:
		$ShootTimer.stop()
		return
	var bullet = bullet_pack.instance()
	var from_pos = position + $TowerDir.transform * $TowerDir/ShootPoint.position
	var to_pos = target.advanced_position(from_pos, bullet_speed)
	bullet.setup(from_pos, to_pos, bullet_speed, damage)
	get_parent().add_child(bullet)
	# next shoot time
	$ShootTimer.start(shoot_time)

func _on_Tower_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		emit_signal("tower_select", self)


func _on_Range_body_entered(body: Node) -> void:
	if body is Mob:
		within_mobs.append(body)
		find_target()

func _on_Range_body_exited(body: Node) -> void:
	if body is Mob:
		within_mobs.erase(body)	
		find_target()
