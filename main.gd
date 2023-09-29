extends Node2D

@onready var start_button = $CanvasLayer/CenterContainer/Start
@onready var game_over = $CanvasLayer/CenterContainer/GameOver

var powerItem = preload("res://power_up.tscn")
var enemy = preload("res://enemy.tscn")
var score = 0
var audioPlayback = 0
var gameStarted = 0
var gameOver = 0
var gameLevel = 1

func new_game():
	gameOver = 0
	score = 0
	$CanvasLayer/UI.update_score(score)
	$Player.start()
	spawn_enemies(gameLevel)

func spawn_enemies(level):
	gameStarted = 1
	for x in range(9):
		for y in range(9):
			var e = enemy.instantiate()
			e.speedMultiplier = (level * .5) + 1
			var pos = Vector2(x * (16+8) + 24, 16 * 4 + y * 16)
			add_child(e)
			e.start(pos)
			e.died.connect(_on_enemy_died)
			e.dropPowerUp.connect(_drop_powerup)

# Called when the node enters the scene tree for the first time.
func _ready():
	game_over.hide()
	start_button.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gameStarted == 1 and gameOver == 0:
		if not get_tree().get_nodes_in_group("enemies"):
			gameStarted = 0
			gameLevel += 1
			spawn_enemies(gameLevel)


func _on_enemy_died(value):
	score += value
	$CanvasLayer/UI.update_score(score)

func _drop_powerup(pos):
	var dropItem = powerItem.instantiate()
	add_child(dropItem)
	dropItem.start(pos)

func _on_start_pressed():
	start_button.hide()
	new_game()


func _on_player_died():
	gameOver = 1
	gameLevel = 1
	get_tree().call_group("enemies","queue_free")
	game_over.show()
	await get_tree().create_timer(2).timeout
	game_over.hide()
	start_button.show()

func _on_audio_stream_player_2d_finished():
	$AudioStreamPlayer2D.play()

func _unhandled_input(event):
	if event.is_action_pressed("startgame") and start_button.is_visible_in_tree():
		start_button.hide()
		new_game()
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("quit"):
		get_tree().quit()
	if event.is_action_pressed("mute"):
		if $AudioStreamPlayer2D.playing:
			audioPlayback = $AudioStreamPlayer2D.get_playback_position()
			$AudioStreamPlayer2D.stop()
		else:
			$AudioStreamPlayer2D.play(audioPlayback)
	if event.is_action_pressed("debug"):
		print(get_tree().get_nodes_in_group("enemies"))



