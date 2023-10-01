extends CharacterBody2D

var currentPos = [1,1]

func _input(event):
	if event.is_action_pressed("ui_right"):
		currentPos[0] += 48
		
	self.position = Vector2(currentPos[0], currentPos[1])
