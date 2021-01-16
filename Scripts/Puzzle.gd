extends Node2D

var Grids = null
var grid

func _ready():
	self.Grids = preload("res://Scenes/Grid.tscn")
	self.grid = Grids.instance()
	yield(self.grid,"ready")
	grid.init(10,14,["lines","O","tee"])
	self.add_child(grid)
