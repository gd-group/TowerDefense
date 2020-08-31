extends RigidBody2D
class_name Bullet

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
var damage = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func setup(pos: Vector2, target_pos: Vector2, speed: float, damage: int) -> void:
	var dir = pos.angle_to_point(target_pos)
	var mtx = Transform2D(dir + PI, Vector2())
	var vec = mtx * Vector2(speed, 0)
	position = pos
	rotation = dir
	linear_velocity = vec
	self.damage = damage


func _on_Bullet_body_entered(body: Node) -> void:
	if body is Mob:
		var mob: Mob = body
		mob.on_hit(damage)
	queue_free()


func _on_VisibilityNotifier2D_viewport_exited(viewport: Viewport) -> void:
	queue_free()
