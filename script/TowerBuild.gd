extends Control

signal build_tower(tower_id)
signal tower_action(action, cost)

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
var left_clicked = false
var upgrade_cost = 100
var sell_cost = 100
var selected_tower: Tower = null
var radius = 100

func _ready() -> void:
	var shape: CircleShape2D = $Circle/CollisionShape.shape
	radius = shape.radius
	
func _input(event: InputEvent) -> void:
	if event.is_action_released("right_click"):
		close()
	elif event.is_action_released("left_click"):
		var mpos = get_local_mouse_position()
		var dis = mpos.distance_to(Vector2())
		if dis >= radius:
			close()

func open(pos: Vector2, tower: Tower=null, upgrade_cost=0, sell_cost=0):
	if visible:
		return
	rect_position = pos
	visible = true
	if selected_tower:
		selected_tower.set_selected(false)
	selected_tower = tower
	if tower:
		tower.set_selected(true)
	if upgrade_cost > 0:
		self.upgrade_cost = upgrade_cost
		$Upgrade/UpgradeCost.text = "$" + str(upgrade_cost)
	if sell_cost > 0:
		self.sell_cost = sell_cost
		$Sell/SellCost.text = "$" + str(sell_cost)

func close() -> void:
	visible = false
	left_clicked = false
	if selected_tower:
		selected_tower.set_selected(false)
	
func _on_TowerButton1_button_up() -> void:
	emit_signal("build_tower", 0)
	close()

func _on_TowerButton2_button_up() -> void:
	emit_signal("build_tower", 1)
	close()

func _on_TowerButton3_button_up() -> void:
	emit_signal("build_tower", 2)
	close()

func _on_Circle_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		left_clicked = true
	elif event.is_action_pressed("right_click"):
		left_clicked = false

func _on_TowerUpgrade_button_up() -> void:
	emit_signal("tower_action", "upgrade", upgrade_cost)
	selected_tower.upgrade(upgrade_cost)
	close()

func _on_TowerSell_button_up() -> void:
	emit_signal("tower_action", "sell", sell_cost)
	close()
