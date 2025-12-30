extends Node

# Game state
var score: int = 0
var high_score: int = 0
var lives: int = 3
var level: int = 1
var player_name: String = "Player"

# Constants
const INITIAL_LIVES: int = 3
const POINTS_PER_BRICK: int = 10

func _ready():
	load_game_data()

func add_score(points: int) -> void:
	score += points
	if score > high_score:
		high_score = score

func reset_game() -> void:
	score = 0
	lives = INITIAL_LIVES
	level = 1

func lose_life() -> bool:
	lives -= 1
	return lives <= 0

func next_level() -> void:
	level += 1
	lives = min(lives + 1, 5)  # Bonus life, max 5

func save_game_data() -> void:
	var save_data = {
		"high_score": high_score,
		"player_name": player_name
	}
	var file = FileAccess.open("user://brick_breaker_save.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func load_game_data() -> void:
	if FileAccess.file_exists("user://brick_breaker_save.json"):
		var file = FileAccess.open("user://brick_breaker_save.json", FileAccess.READ)
		if file:
			var json = JSON.new()
			var parse_result = json.parse(file.get_as_text())
			file.close()
			if parse_result == OK:
				var data = json.get_data()
				high_score = data.get("high_score", 0)
				player_name = data.get("player_name", "Player")