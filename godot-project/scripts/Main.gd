extends Node2D

# Game constants
const BRICK_ROWS: int = 5
const BRICK_COLS: int = 10
const BRICK_WIDTH: float = 70.0
const BRICK_HEIGHT: float = 25.0
const BRICK_PADDING: float = 5.0
const BRICK_OFFSET_TOP: float = 80.0
const BRICK_OFFSET_LEFT: float = 45.0

# Brick colors
const BRICK_COLORS: Array = [
	Color("#ff006e"),
	Color("#ff6b35"),
	Color("#ffd700"),
	Color("#00d4ff"),
	Color("#7b2cbf")
]

# References
@onready var paddle: CharacterBody2D = $Paddle
@onready var ball: CharacterBody2D = $Ball
@onready var brick_container: Node2D = $BrickContainer
@onready var hud: CanvasLayer = $HUD
@onready var score_label: Label = $HUD/TopPanel/ScoreLabel
@onready var high_score_label: Label = $HUD/TopPanel/HighScoreLabel
@onready var lives_label: Label = $HUD/TopPanel/LivesLabel

var brick_scene: PackedScene

func _ready() -> void:
	# Load brick scene
	brick_scene = preload("res://scenes/Brick.tscn")
	
	# Initialize level
	create_bricks()
	reset_ball_position()
	update_hud()
	
	# Connect ball signals
	ball.ball_lost.connect(_on_ball_lost)
	ball.brick_hit.connect(_on_brick_hit)

func create_bricks() -> void:
	# Clear existing bricks
	for child in brick_container.get_children():
		child.queue_free()
	
	# Calculate rows based on level
	var rows = BRICK_ROWS + int((Global.level - 1) / 2.0)
	
	for row in range(rows):
		for col in range(BRICK_COLS):
			var brick = brick_scene.instantiate()
			var x = BRICK_OFFSET_LEFT + col * (BRICK_WIDTH + BRICK_PADDING)
			var y = BRICK_OFFSET_TOP + row * (BRICK_HEIGHT + BRICK_PADDING)
			
			brick.position = Vector2(x, y)
			brick.color = BRICK_COLORS[row % BRICK_COLORS.len()]
			
			# Multi-hit bricks in higher levels
			var hits = 1
			if Global.level >= 3 and row < 2:
				hits = 2
			if Global.level >= 5 and row == 0:
				hits = 3
			brick.max_hits = hits
			brick.hits = hits
			
			brick_container.add_child(brick)

func reset_ball_position() -> void:
	ball.reset_position(paddle.position - Vector2(0, 30))

func update_hud() -> void:
	score_label.text = "Score: %d" % Global.score
	high_score_label.text = "Best: %d" % Global.high_score
	lives_label.text = "Lives: %d" % Global.lives

func _on_ball_lost() -> void:
	if Global.lose_life():
		# Game over
		Global.save_game_data()
		get_tree().change_scene_to_file("res://scenes/DefeatScreen.tscn")
	else:
		# Reset ball and continue
		update_hud()
		reset_ball_position()

func _on_brick_hit(brick: Node2D) -> void:
	brick.take_damage()
	
	if brick.hits <= 0:
		Global.add_score(Global.POINTS_PER_BRICK * Global.level)
		update_hud()
		brick.queue_free()
		
		# Check for victory
		await get_tree().process_frame
		if brick_container.get_child_count() == 0:
			Global.save_game_data()
			get_tree().change_scene_to_file("res://scenes/VictoryScreen.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")