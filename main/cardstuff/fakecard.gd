extends PanelContainer

var val : int : 
	set(n): 
		val = n
		set_val()
		

func set_val():
	$MarginContainer/contents/valuetxt.text = str(val)
	
