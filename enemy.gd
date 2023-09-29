extends Area2D

var start_pos = Vector2.ZERO
var speed = 0
var speedMultiplier = 1

var bullet_scene = preload("res://enemy_bullet.tscn")

var enemies_img = [
	["res://Assets/Mini Pixel Pack 3/Enemies/Alan (16 x 16).png",6],
	["res://Assets/Mini Pixel Pack 3/Enemies/Bon_Bon (16 x 16).png",4],
	["res://Assets/Mini Pixel Pack 3/Enemies/Lips (16 x 16).png",5]
]

@onready var screensize = get_viewport_rect().size

signal died
signal dropPowerUp(pos)

func start(pos):
	speed = 0
	position = Vector2(pos.x,-pos.y)
	start_pos = pos
	await get_tree().create_timer(randf_range(0.25,0.55)).timeout
	var tween = create_tween().set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position:y", start_pos.y, 1.4)
	await tween.finished
	var max_wait = 20 - (speedMultiplier * 2)
	$MoveTimer.wait_time = randf_range(3,max_wait)
	$MoveTimer.start()
	$ShootTimer.wait_time = randf_range(4,max_wait)
	$ShootTimer.start()

func explode():
	if randf_range(0,1) >= .75:
		dropPowerUp.emit(position)
	$Explosion.play()
	speed = 0
	set_deferred("monitoring",false)
	$AnimationPlayer.play("explode")
	collision_layer = 0
	died.emit(5)
	await $AnimationPlayer.animation_finished
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load Random Images
	var e = enemies_img[floor(randf_range(0,3))]
	$Sprite2D.texture = load(e[0])
	$Sprite2D.hframes = e[1]

	# Randomize Animation Start
	$DelayAnimationTimer.wait_time = randf_range(.1,1)
	$DelayAnimationTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y += speed * speedMultiplier * delta
	if position.y > screensize.y + 32:
		start(start_pos)


func _on_move_timer_timeout():
	speed = randf_range(75, 100)


func _on_shoot_timer_timeout():
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(position)
	$ShootTimer.wait_time = randf_range(4,20)
	$ShootTimer.start()


func _on_delay_animation_timer_timeout():
	$AnimationPlayer2.play("bounce")
