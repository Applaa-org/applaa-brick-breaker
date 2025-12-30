extends Control

@onready var high_score_label: Label = $VBoxContainer/HighScorePanel/HighScoreLabel
@onready var player_name_input: LineEdit = $VBoxContainer/PlayerNameInput
@onready var start_button: Button = $VBoxContainer/ButtonContainer/StartButton
@onready var close_button: Button = $VBoxContainer/ButtonContainer/CloseButton

func _ready() -> void:
	# Initialize display
	high_score_label.text = "High Score: 0"
	
	# Load saved data
	if Global.player_name != "Player":
		player_name_input.text = Global.player_name
	
	high_score_label.text = "High Score: %d" % Global.high_score
	
	# Connect signals
	start_button.pressed.connect(_on_start_pressed)
	close_button.pressed.connect(_on_close_pressed)
	player_name_input.text_changed.connect(_on_name_changed)

func _on_start_pressed() -> void:
	Global.player_name = player_name_input.text if player_name_input.text != "" else "Player"
	Global.reset_game()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_close_pressed() -> void:
	get_tree().quit()

func _on_name_changed(new_text: String) -> void:
	Global.player_name = new_text if new_text != "" else "Player"