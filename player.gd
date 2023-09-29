extends Area2D

signal died
signal shield_changed

@export var speed = 150
@export var cooldown = 0.5
@export var bullet_scene : PackedScene
@export var max_shield = 10
@onready var screensize = get_viewport_rect().size

var invincible = 1
var can_shoot = true
var max_cooldown = 0.2
var shield = max_shield:
	set = set_shield

func start():
	position = Vector2(screensize.x / 2, screensize.y - 20)
	invincible = 1
	$DelayDamage.start()
	show()
	reset_shield()
	$GunCoolDown.wait_time = cooldown

func shoot():
	if not can_shoot:
		return
	$BlasterFire.play()
	can_shoot = false
	$GunCoolDown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(position + Vector2(0,-8))

func set_shield(value):
	shield = min(max_shield, value)
	shield_changed.emit(max_shield, shield)
	if shield <= 0:
		hide()
		died.emit()

func decrease_gun_cooldown():
	if $GunCoolDown.wait_time > max_cooldown:
		$GunCoolDown.wait_time -= .1

func reset_shield():
	if shield < max_shield:
		shield = max_shield

func increase_speed():
	speed += 25
	$Ship/Booster.position.y += 8 * $Ship/Booster.scale.y
	$Ship/Booster.scale.y *= 2
	$Ship/Booster.scale.x *= 1.2


# Called when the node enters the scene tree for the first time.
func _ready():
	start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input =  Input.get_vector("left","right","up","down")

	if input.x > 0:
		$Ship.frame = 2
		$Ship/Booster.animation = "right"
	elif input.x < 0:
		$Ship.frame = 0
		$Ship/Booster.animation = "left"
	else:
		$Ship.frame = 1
		$Ship/Booster.animation = "forward"

	position += input * speed * delta
	position = position.clamp(Vector2(8,8), screensize - Vector2(8,8))

	if Input.is_action_pressed("shoot"):
		shoot()


func _on_gun_cool_down_timeout():
	can_shoot = true


func _on_area_entered(area):
	if invincible == 1:
		return
	if area.is_in_group("enemies"):
		area.explode()
		shield -= max_shield / 2


func _on_delay_damage_timeout():
	invincible = 0
