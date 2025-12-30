extends CharacterBody2D

const SPEED: float = 500.0
const SMOOTH_FACTOR: float = 0.15

var target_x: float = 0.0
var use_mouse: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Position paddle at bottom of screen
	var viewport_size = get_viewport_rect().size
	position = Vector2(viewport_size.x / 2, viewport_size.y - 50)
	target_x = position.x
	
	# Adjust paddle width based on level
	var width = max(100 - (Global.level - 1) * 5, 60)
	var shape = collision.shape as RectangleShape2D
	shape.size.x = width

func _physics_process(delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	var half_width = collision.shape.size.x / 2
	
	# Keyboard input
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		use_mouse = false
		target_x = position.x + direction * SPEED * delta
	
	# Smooth movement
	position.x = lerp(position.x, target_x, SMOOTH_FACTOR)
	
	# Clamp position
	position.x = clamp(position.x, half_width, viewport_size.x - half_width)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		use_mouse = true
		target_x = event.position.x
	elif event is InputEventScreenTouch or event is InputEventScreenDrag:
		use_mouse = true
		target_x = event.position.x