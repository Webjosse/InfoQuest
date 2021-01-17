extends Node2D

var Grids = null
var grid;
onready var swipe = $Swipe
onready var Actlabel = $Pinterface/ActionLabel
var action = 3
var lastSwap = []

func _ready():
	self.Grids = preload("res://Scenes/Grid.tscn")
	self.grid = Grids.instance()
	grid.init(10,14,["ZS","JL","O"])
	self.add_child(grid)


func _on_Swipe_swiped(direction, start_position):
	if grid == null:
		return
	if action <= 0:
		return
	var pos = grid.pieces[0][0].get_position()
	print(pos)
	var x = start_position[0]-pos[0]
	var y = start_position[1]-pos[1]
	if x<0 or y<0 or x>grid.width*36 or y>grid.height*36:
		return
	x = x/36
	y = y/36
	setaction(action-1)
	grid.swap(x,y,x-direction[0],y-direction[1])

func undo():
	"""
	setaction(action+1)
	grid.undoSwap()
	"""
	print(len(grid.detectFigure("JL")))

func setaction(value):
	action = value
	Actlabel.text = "Actions\n"+str(value)
