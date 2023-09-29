extends Area2D

@export var speed = 150

func start(pos):
	position = pos

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y += speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_area_entered(area):
	if area.name == "Player":
		$Sprite2D.hide()
		$BulletHit.play()
		if area.invincible != 1:
			area.shield -= 1
		#queue_free()


func _on_bullet_hit_finished():
	queue_free()
