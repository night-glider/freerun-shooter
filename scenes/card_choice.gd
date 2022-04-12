extends Control

var card1 = "card1"
var card2 = "card2"
var card3 = "card3"

var cards:Dictionary = {
	"card1":{
		"name":"Zero Gravity",
		"description":"[color=green]Убирает гравитацию[/color]\n[color=red]-50% скорости пуль[/color]"
	},
	"card2":{
		"name":"Fury",
		"description":"[color=green]+100% к урону[/color]\n[color=red]+300% отдачи[/color]"
	},
	"card3":{
		"name":"Fast hands",
		"description":"[color=green]+50% к скорострельности[/color]\n[color=red]-50% скорости пуль[/color]"
	}
}

func card1():
	get_parent().current_weapon.bullet_gravity = 0
	get_parent().current_weapon.bullet_spd *= 0.5

func card2():
	get_parent().current_weapon.damage *= 2
	get_parent().current_weapon.recoil_factor_x *= 4
	get_parent().current_weapon.recoil_factor_y *= 4

func card3():
	get_parent().current_weapon.cooldown_timer *= 0.75
	get_parent().current_weapon.bullet_spd *= 0.5

func _ready():
	pass
	#show()

func show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = true
	var cards_array = []
	for element in cards:
		cards_array.append(element)
	cards_array.shuffle()
	card1 = cards_array[0]
	card2 = cards_array[1]
	card3 = cards_array[2]
	
	$card1/RichTextLabel.bbcode_text = cards[card1]["name"] + "\n" + cards[card1]["description"]
	$card2/RichTextLabel.bbcode_text = cards[card2]["name"] + "\n" + cards[card2]["description"]
	$card3/RichTextLabel.bbcode_text = cards[card3]["name"] + "\n" + cards[card3]["description"]
	

func close():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false
	get_parent().get_parent().respawn()


func _on_card1_pressed():
	close()
	call(card1)
	get_parent().get_parent().notificate(get_parent().nickname + " picked " + str(cards[card1]["name"]), 2)


func _on_card2_pressed():
	close()
	call(card2)
	get_parent().get_parent().notificate(get_parent().nickname + " picked" + str(cards[card2]["name"]), 2)


func _on_card3_pressed():
	close()
	call(card3)
	get_parent().get_parent().notificate(get_parent().nickname + " picked" + str(cards[card3]["name"]), 2)
