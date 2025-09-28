extends Control

@onready var card = preload("res://main/cardstuff/card.tscn")

var hands = {}

var turnorder = ["player"]

var topcard = -100

var selectedhand = ""
var selectedpos = Vector2(0,0)

var addingboxes = {
	"player" = [],
	"0" = [],
	"1" = [],
	"2" = []
}

const deckList = {
	-1 : 2,
	0 : 2,
	1 : 4,
	2 : 4,
	3 : 4,
	4 : 4,
	5 : 4,
	6 : 4,
	7 : 4,
	8 : 4,
	9 : 4,
	10 : 4,
	11 : 4,
	12 : 4,
	13 : 2
}

const topbot = {
	0 : "bot",
	1 : "top"
}

enum playerstate {
	OFFTURN = 0, 
	ADDING,
	CARDDRAWN,
	SWAPPING,
	PEEKOWN,
	PEEKOUT
}



var deck = []
var disc = []
	

signal discarded(ca)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	deck = []
	for k in deckList:
		var v = deckList[k]
		for i in range(v):
			deck.append(k)
	shuffle() 
	
	hands["player"] = deal(Connection.gametype)
	for i in range(Connection.numbots):
		hands[str(i)] = deal(Connection.gametype)
		
	
	
	refreshall()
	
	for x in $player/bot.get_children():
		x.up = true
	
	self.discarded.connect(self.updatetop)

func shuffle():
	randomize()
	deck.shuffle()

func deal(x : int):
	var hand = {
		top = [],
		bot = []
	}
	
	if deck.size() >= x:
		for i in range(x):
			if i%2 == 0:
				hand.top.append(deck.pop_back())
			else:
				hand.bot.append(deck.pop_back())
	else:
		deck = disc
		disc = [disc[-1]]
		randomize()
		deck.shuffle()
		for i in range(x):
			if i%2 == 0:
				hand.top.append(deck.pop_back())
			else:
				hand.bot.append(deck.pop_back())
	
	return hand #top and bottom arrays of integers

func draw() -> int:
	var c
	if deck.size() >= 1:
		c = deck.pop_back()
	else:
		deck = disc
		disc = [disc[-1]]
		randomize()
		deck.shuffle()
		c = deck.pop_back()
	return c #int value

func penalty(h) -> void:
	var c = draw()
	hands.h[toporbot(h)].append(c) #adds penalty to hand
	refreshall()

func discard(c):
	disc.append(c)
	emit_signal("discarded", c)
	

func toporbot(h) -> String: #return whether a card should be added to the top or bottom row (string)
	var hand = hands.h
	var result = "top"
	if hand.bot.size() > hand.top.size(): 
		result = "bot"
	return result

func refreshall():
	for h in hands:  #remove children
		for c in get_node(h+"/top").get_children():
			c.queue_free()
		for c in get_node(h+"/bot").get_children():
			c.queue_free()
	
	
	for x in hands:
		for i in range(hands[x].top.size()):
			var curcard = card.instantiate()
			curcard.val = hands[x].top[i]
			curcard.ownerhand = x
			get_node(str(x)+"/top").add_child(curcard)
		
		for i in range(hands[x].bot.size()):
			var curcard = card.instantiate()
			curcard.val = hands[x].bot[i]
			curcard.ownerhand = x
			curcard.row = "bot"
			curcard.entered.connect(self.cardenter)
			curcard.exited.connect(self.cardexit)
			get_node(str(x)+"/bot").add_child(curcard)

func refreshhand(h):
	for c in get_node(h+"/top").get_children():
		c.queue_free()
	for c in get_node(h+"/bot").get_children():
		c.queue_free()
	
	for i in range(hands[h].top.size()):
		var curcard = card.instantiate()
		curcard.val = hands[h].top[i]
		curcard.ownerhand = h
		curcard.entered.connect(self.cardenter)
		curcard.exited.connect(self.cardexit)
		get_node(str(h)+"/top").add_child(curcard)
	
	for i in range(hands[h].bot.size()):
		var curcard = card.instantiate()
		curcard.val = hands[h].bot[i]
		curcard.ownerhand = h
		curcard.row = "bot"
		curcard.entered.connect(self.cardenter)
		curcard.exited.connect(self.cardexit)
		get_node(str(h)+"/bot").add_child(curcard)

func cardenter(h, r, p):
	selectedhand = h
	selectedpos = Vector2(r,p)
	match playerstate:
		_: pass
	
	
	
	

func cardexit():
	selectedhand = ""


func add(pl, h, r, p):
	var c = get_node(h + "/" + topbot[r] + "/" + str(p))
	c.up = true
	addingboxes[pl].append(c)
	
	if addingboxes[pl].length > 1:
		if (addingboxes[pl][0] == addingboxes[pl][1]) && addingboxes[pl][0].val == topcard: #if double clicking on same card and it can be flipped
			discard(addingboxes[pl][0].val)
			hands.h.topbot[r].remove(p)
			refreshhand(pl)
			return
		
		



func checkadd(pl):
	if addingboxes[pl][0].val + addingboxes[pl][1].val == topcard:
		pass
	


func updatetop(v):
	topcard = v
	
func reset():
	_ready()


func _on_ready_button_up() -> void:
	#start game
	pass
