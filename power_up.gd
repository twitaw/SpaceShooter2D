extends Area2D

@export var speed = 150

var itemList = ["LaserSpeed","Shield","Speed"]
var item = floor(randf_range(0,1.99))

func start(pos):
	position = pos

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.frame = item

func powerUpPlayer(player):
	if itemList[item] == "LaserSpeed":
		player.decrease_gun_cooldown()
	elif itemList[item] == "Speed":
		player.increase_speed()
	elif itemList[item] == "Shield":
		player.reset_shield()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y += speed * delta


func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()


func _on_area_entered(area):
	if area.name == "Player":
		powerUpPlayer(area)
		queue_free()
