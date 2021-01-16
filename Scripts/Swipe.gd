extends Node

#Script pompé sur Youtube (GDQuest)

#Mais tkt je l'ai compris car j'ai un gros cerveau

#Les signaux: swiped(swipe réussi) et canceled(temps écoulé)
signal swiped(direction,start_position)
signal swiped_canceled(start_position)

#Longueur maximale du swipe
export(float, 1.0, 1.5) var MAX_DIAGONAL_SLOPE = 1.3

#On prend le Timer et on crée la position de départ
onready var timer = $Timer
var swipe_start_position = Vector2()

func _input(event):
	#Si c'est pas un screentouch, on ne fait rien
	if not event is InputEventScreenTouch:
		return
	#Si l'écran est pressé, on commence la détection
	#Si y en a une en cours, on l'arrête
	if event.pressed:
		_start_detection(event.position)
	elif not timer.is_stopped():
		_end_detection(event.position)

func _start_detection(position):
	swipe_start_position = position
	timer.start()

func _end_detection(position):
	timer.stop()
	var direction = (position - swipe_start_position).normalized()
	#Verif de swipe de longueur maximale
	if abs(direction.x) + abs(direction.y) >= MAX_DIAGONAL_SLOPE:
		return
	
	if abs(direction.x) > abs(direction.y):
		emit_signal("swiped",Vector2(-sign(direction.x),0.0),swipe_start_position)
	else:
		emit_signal("swiped",Vector2(0.0,-sign(direction.y)),swipe_start_position)

func _on_Timer_timeout():
	emit_signal("swiped_canceled", swipe_start_position)
