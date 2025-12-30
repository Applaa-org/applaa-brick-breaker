extends CharacterBody2D

signal ball_lost
signal brick_hit(brick: Node2D)

const BASE_SPEED: float = 400.0
const SPEED_INCREMENT: float = 20.0
const MAX_BOUNCE_ANGLE: float = 75.0

var speed: float = BASE_SPEED
var direction: Vector2 = Vector2.ZERO
var is_active: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	speed = BASE_SPEED + (Global.level - 1) * SPEED_INCREMENT

func reset_position(pos: Vector2) -> void:
	position = pos
	is_active = false
	
	# Wait for input to launch
	await get_tree().create_timer(0.5).timeout
	launch_ball()

func launch_ball() -> void:
	# Random angle between 45 and 135 degrees (upward)
	var angle = randf_range(deg_to_rad(45), deg_to_rad(135))
	direction = Vector2(cos(angle), -abs(sin(angle))).normalized()
	if randf() > 0.5:
		direction.x = -direction.x
	is_active = true

func _physics_process(delta: float) -> void:
	if not is_active:
		return
	
	velocity = direction * speed
	var collision_info = move_and_collide(velocity * delta)
	
	if collision_info:
		var collider = collision_info.get_collider()
		
		if collider.is_in_group("paddle"):
			handle_paddle_collision(collider)
		elif collider.is_in_group("brick"):
			handle_brick_collision(collider, collision_info)
		else:
			# Wall collision
			direction = direction.bounce(collision_info.get_normal())
	
	# Check bounds
	var viewport_size = get_viewport_rect().size
	
	# Side walls
	if position.x <= 10 or position.x >= viewport_size.x - 10:
		direction.x = -direction.x
		position.x = clamp(position.x, 10, viewport_size.x - 10)
	
	# Top wall
	if position.y <= 10:
		direction.y = abs(direction.y)
		position.y = 10
	
	# Bottom - ball lost
	if position.y > viewport_size.y + 50:
		is_active = false
		ball_lost.emit()

func handle_paddle_collision(paddle: Node2D) -> void:
	# Calculate hit position (0 = left edge, 1 = right edge)
	var paddle_shape = paddle.get_node("CollisionShape2D").shape as RectangleShape2D
	var paddle_width = paddle_shape.size.x
	var hit_pos = (position.x - paddle.position.x + paddle_width / 2) / paddle_width
	hit_pos = clamp(hit_pos, 0.0, 1.0)
	
	# Calculate bounce angle (-MAX_BOUNCE_ANGLE to +MAX_BOUNCE_ANGLE)
	var angle = (hit_pos - 0.5) * 2 * deg_to_rad(MAX_BOUNCE_ANGLE)
	
	direction = Vector2(sin(angle), -cos(angle)).normalized()
	
	# Ensure ball moves upward
	direction.y = -abs(direction.y)
	
	# Small speed increase
	speed = min(speed + 5, BASE_SPEED + 200)

func handle_brick_collision(brick: Node2D, collision_info: KinematicCollision2D) -> void:
	direction = direction.bounce(collision_info.get_normal())
	brick_hit.emit(brick)