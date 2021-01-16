extends Node2D

export (int,0,5) var color = 1 setget actsprite
onready var sprite = $blocks

func _ready():
	sprite.frame = color

func actsprite(value):
	if sprite != null:
		self.sprite.frame = clamp(value,0,5)
	color = clamp(value,0,5)
