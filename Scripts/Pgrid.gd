extends Node2D

export (int) var width = 10
export (int) var height = 14

var pieces = []
var blocks;
var figs = []
onready var Pset = $Set

func init(w,h,L):
	self.width = w
	self.height = h
	self.figs = L
	deleteFig(figs)


func _ready():
	
	print("hello")
	
	randomize()
	
	#On remplit le tablea pieces avec des cases null
	
	for i in range(width):
		pieces.append([])
		for _j in range(height):
			pieces[i].append(null)
	
	# On charge la scène "Blocks"
	
	self.blocks = preload("res://Scenes/Block.tscn")
	
	# Remlis avec des pieces aléatoires
	fill_pieces()
	# Met en position les blocs
	set_pos()
	# Rechange les couleurs des blocs pour supprimer les figures


func fill_pieces():

	for i in range(width):

		for j in range(height):
			
			#Invoque une "instance" de la scène "Block" (importée dans _ready() )
			pieces[i][j] = self.blocks.instance()
			self.Pset.add_child(pieces[i][j])
	
	# Augmente la fréquence de même couleurs aux mêmes endroits
	changelines()

func set_pos():
	var s = Pset.rect_size
	var r;
	for i in range(width):
		for j in range(height):
			r = Vector2(i*s[0]/width,j*s[1]/height)
			pieces[i][j].set_position(r)

func changelines():
	var r;
	
	#Remplis par colonnes de couleur
	for i in range(width):
		r = randi()%6
		for j in range(height):
			pieces[i][j].color = r
	var c;
	
	#Lignes de couleur + aléas
	for j in range(height):
		r = randi()%6
		for i in range(width):
			c = pieces[i][j].color
			
			#Aléas: si croisement ou sinon 2 chances sur 3: changer la couleur
			if r == c or randi()%3 != 0:
				pieces[i][j].color = randi()%6

func deleteFig(list):
	var r;
	var b = true
	
	#b désigne le fait qu'e toutes les figuresune figure reste ou non'
	while b:
		randomize()
		
		#Pour les figures type lignes
		if "lines" in list:
			#On les detecte
			var Detected = detectFigure("lines")
			for i in Detected:
				
				"""
				On change 2 blocks aléatoires consécutifs de la figure
				 %3 car la figure est suite de 4, et 4-1 = 3
				(le -1 c'est pour en avoir 2)
				
				 EN GROS: ça marche donc c cool
				
				"""
				r = randi()%3
				
				if i[2]:
					
					pieces[i[0]+r][i[1]].color = randi()%6
					pieces[i[0]+r+1][i[1]].color = randi()%6
				else:
					
					pieces[i[0]][i[1]+r].color = randi()%6
					pieces[i[0]][i[1]+r+1].color = randi()%6
		
		#Pour les figures en T
		if "tee" in list:
			#Détection
			var Detected = detectFigure("tee")
			for i in Detected:
				
				# On vérifie que la position soit pas en bords, et on change
				# soit les blocs haut-droite soit bas-gauche
				r= randi()%2
				if (r==1 or i[0]*i[1]==0) and i[0]<width-1 and i[1]<height-1:
					pieces[i[0]+1][i[1]].color = randi()%6
					pieces[i[0]][i[1]+1].color = randi()%6
				else:
					pieces[i[0]][i[1]-1].color = randi()%6
					pieces[i[0]-1][i[1]].color = randi()%6
		
		#Pour les figures type J ou L
		if "JL" in list:
			#Détection
			var Detected = detectFigure("JL")
			for i in Detected:
				
				"""
				Pour celui-ci, on s'assure que ce n'est pas la même couleur
				car on en change qu'un (sinon les probas rendent le code moins
				optimisé
				"""
				var c = pieces[i[0]][i[1]].color
				r = randi()%5
				if r>c:
					r += 1
				if i[2]:
					pieces[i[0]+2][i[1]].color = r
				else:
					pieces[i[0]][i[1]+2].color = r
		
		#Pour les figures type Z ou S
		if "ZS" in list:
			#Détection
			var Detected = detectFigure("ZS")
			for i in Detected:
				
				#Pareil que J
				var c = pieces[i[0]][i[1]].color
				r = randi()%5
				if r>c:
					r += 1
				if randi()%2 == 0:
					pieces[i[0]][i[1]].color = r
				elif i[2]%2 == 0:#fig 2 et 4: les 2 du milieu
					pieces[i[0]][i[1]+1].color = r # sont rouge et dessous
				else:#Autres figs: adjacents
					pieces[i[0]+2-i[2]][i[1]].color = r
			
		if "O" in list:
			#Détection
			var Detected = detectFigure("ZS")
			for i in Detected:
				r = randi()%5
				if r>pieces[i[0]][i[1]].color:
					r += 1
				#C'est la plus simple
				pieces[i[0]+randi()%2][i[1]+randi()%2].color =r
		# On vérifie s'il reste une figure
		b = false
		for i in list:
			if detectFigure(i) != []:
				b = true
		print(b)

# Détection de figures
func detectFigure(fig):
	var L = [] #Liste à renvoyer
	var c; #Pour stocker la couleur (plus tard)
	var dir; #La direction (pour le T)
	
	#On vérifie si 3 blocs sont alignés pour le J, L et lignes
	if fig == "lines" or fig == "JL":
		for i in range(width):
			for j in range(height):
				c = pieces[i][j].color
				#Horizontal
				if j<height-2 and [ pieces[i][j+1].color, pieces[i][j+2].color ] == [c,c]:
					#Lignes: on vérifie le 4e
					if fig == "lines" and j<height-3 and pieces[i][j+3].color == c:
						L.append([i,j,false])
					if fig == "JL": #J/L: on regarde les adjacents
						
						if i<width-1:
							
							if pieces[i+1][j].color == c:
								L.append([i,j,false,1])
						
							if pieces[i+1][j+2].color == c:
								L.append([i,j,false,3])
						if i>0:
							
							if pieces[i-1][j].color == c:
								L.append([i,j,false,2])
						
							if pieces[i-1][j+2].color == c:
								L.append([i,j,false,4])
				#Vertical
				if i<width-2 and [ pieces[i+1][j].color, pieces[i+2][j].color ] == [c,c]:
					#Lignes: on vérifie le 4e
					if fig == "lines" and i<width-3 and pieces[i+3][j].color == c:
						L.append([i,j,true])
					if fig == "JL": #J/L: on regarde les adjacents
						
						if j<height-1:
							if pieces[i][j+1].color == c:
								L.append([i,j,true,1])
							
							if pieces[i+2][j+1].color == c:
								L.append([i,j,true,3])
						if j>0:
							if pieces[i][j-1].color == c:
								L.append([i,j,true,2])
							
							if pieces[i+2][j-1].color == c:
								L.append([i,j,true,4])
	if fig == "tee": #Pour les T
		var sum;
		
		for i in range(width):
			
			for j in range(height):
				
				c = pieces[i][j].color
				sum = 0
				dir = 0
				#Droite
				if i<width-1 and pieces[i+1][j].color == c:
					sum += 1
				else:
					dir = 1
				#Bas
				if j<height-1 and pieces[i][j+1].color == c:
					sum += 1
				else:
					dir = 2
				#Gauche
				if i>0 and pieces[i-1][j].color == c:
					sum += 1
				else:
					dir = 3
				#Haut
				if j>0 and pieces[i][j-1].color == c:
					sum += 1
				else:
					dir = 4
				#On vérifie si y en a 3
				if sum >= 3:
					L.append([i,j,dir])
	if fig == "ZS": #Pour les ZS
		for i in range(width):
			for j in range(height-1):
				#Référez vous à l'annexe P1
				c = pieces[i][j].color
				if j<height-1 and pieces[i][j+1].color == c:
					#Pour fig. 1 et 2
					if i<width-1 and pieces[i+1][j].color == c:
						if j>0 and pieces[i+1][j-1].color == c:# fig 1
							L.append([i,j, 1])
						if i>0 and pieces[i-1][j+1].color == c:
							L.append([i,j, 2])
					#Pour fig 3 et 4
					if i>0 and pieces[i-1][j].color == c:
						if j>0 and pieces[i-1][j-1].color == c:
							L.append([i,j, 3])
						if width-1>i and pieces[i+1][j+1].color == c:
							L.append([i,j, 4])
	if fig == "O":#Carré de 4
		for i in range(width-1):
			for j in range(height-1):
				c = pieces[i][j].color
				if [pieces[i][j+1].color,pieces[i+1][j].color,pieces[i+1][j+1].color] == [c,c,c]:
					L.append([i,j])
	return L

func _on_SwipeDetector_swiped(direction,start):
	print(direction)
	print(start)
