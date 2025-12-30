extends StaticBody2D

var color: Color = Color.WHITE
var hits: int = 1
var max_hits: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hit_label: Label = $HitLabel

func _ready() -> void:
	add_to_group("brick")
	update_visual()

func update_visual() -> void:
	# Set brick color with alpha based on remaining hits
	var alpha = 0.5 + (float(hits) / float(max_hits)) * 0.5
	sprite.modulate = Color(color.r, color.g, color.b, alpha)
	
	# Show hit count for multi-hit bricks
	if max_hits > 1:
		hit_label.text = str(hits)
		hit_label.visible = true
	else:
		hit_label.visible = false

func take_damage() -> void:
	hits -= 1
	if hits > 0:
		update_visual()
		# Flash effect
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 1.0, 0.05)
		tween.tween_property(sprite, "modulate:a", sprite.modulate.a, 0.05)