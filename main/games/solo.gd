extends Control

@onready var card = preload("res://main/cardstuff/card.tscn")

var hands = {}



var deckList = {
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
	#print(deck)
	shuffle()
	
	hands["player"] = deal(Connection.gametype)
	for i in range(Connection.numbots):
		hands[str(i)] = deal(Connection.gametype)
	
	
	
	for x in hands:
		for i in range(hands[x].top.size()):
			var curcard = card.instantiate()
			curcard.val = hands[x].top[i]
			get_node(str(x)+"/top").add_child(curcard)
		
		for i in range(hands[x].bot.size()):
			var curcard = card.instantiate()
			curcard.val = hands[x].bot[i]
			get_node(str(x)+"/bot").add_child(curcard)
	
	for x in $player/bot.get_children():
		x.up = true
		

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
	
	return hand

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
	return c

func discard(c):
	disc.append(c)
	emit_signal("discarded", c)
	

func reset():
	_ready()
