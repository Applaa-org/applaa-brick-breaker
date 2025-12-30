extends Control

@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var new_high_score_label: Label = $VBoxContainer/NewHighScoreLabel
@onready var next_level_button: Button = $VBoxContainer/ButtonContainer/NextLevelButton
@onready var restart_button: Button = $VBoxContainer/ButtonContainer/RestartButton
@onready var menu_button: Button = $VBoxContainer/ButtonContainer/MenuButton
@onready var close_button: Button = $VBoxContainer/ButtonContainer/CloseButton

func _ready() -> void:
	# Display scores
	score_label.text = "Final Score: %d" % Global.score
	level_label.text = "Level Completed: %d" % Global.level
	high_score_label.text = "High Score: %d" % Global.high_score
	
	# Check for new high score
	if Global.score >= Global.high_score:
		new_high_score_label.visible = true
	else:
		new_high_score_label.visible = false
	
	# Connect buttons
	next_level_button.pressed.connect(_on_next_level_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	close_button.pressed.connect(_on_close_pressed)

func _on_next_level_pressed() -> void:
	Global.next_level()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_restart_pressed() -> void:
	Global.reset_game()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_close_pressed() -> void:
	get_tree().quit()