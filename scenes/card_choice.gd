extends Control

var card1 = "card1"
var card2 = "card2"
var card3 = "card3"

var cards:Dictionary = {
	"card1":{
		"name":"Zero Gravity",
		"description":"[color=green]-75% гравитации пуль[/color]\n[color=red]-50% скорости пуль[/color]"
	},
	"card2":{
		"name":"Fury",
		"description":"[color=green]+50% к урону[/color]\n[color=red]+100% отдачи[/color]"
	},
	"card3":{
		"name":"Fast hands",
		"description":"[color=green]+50% к скорострельности[/color]\n[color=red]-25% скорость перезарядки[/color]"
	},
	"card4":{
		"name":"glass canon",
		"description":"[color=green]+100% к урону\n[color=red]-65% HP"
	},
	"card5":{
		"name":"speedster",
		"description":"[color=green]+35% к максимальной скорости"
	},
	"card6":{
		"name":"big bullets",
		"description":"[color=green]+50% к размеру пуль"
	},
	"card7":{
		"name":"fast pewlets",
		"description":"[color=green]+50% к скорости пуль\n[color=red]-50% размер пуль"
	},
	"card8":{
		"name":"scatter gun",
		"description":"Стреляет сразу нескольким патронами\n[color=green]+3 патрона в очередь\n"
	},
	"card9":{
		"name":"tornado gun",
		"description":"Стреляет 'веером' из пуль\n[color=green]+4 патрона в очередь\n"
	},
	"card10":{
		"name":"MOAR!!",
		"description":"[color=green]+100% патронов в обойме\n[color=red]-35% скорость пули"
	},
	"card11":{
		"name":"precise shot",
		"description":"[color=green]-50% к разбросу пуль\n"
	},
	"card12":{
		"name":"chunky",
		"description":"[color=green]+100% HP\n[color=red]-50% к скорости пуль"
	},
	"card13":{
		"name":"soft gun",
		"description":"[color=green]-50% отдача"
	},
	"card14":{
		"name":"slow but strong",
		"description":"[color=green]+50% урон\n[color=red]-50% скорострельность\n-50% патроны"
	},
	"card15":{
		"name":"slow and big",
		"description":"[color=green]+50% HP\n[color=red]-25% максимальная скорость"
	},
	"card16":{
		"name":"too fast",
		"description":"[color=green]+50% к максимальной скорости\n+50% скорость зарядки прыжка[color=red]-60% HP"
	}
	
}

func card1():
	get_parent().current_weapon.bullet_gravity *= 0.25
	get_parent().current_weapon.bullet_spd *= 0.5

func card2():
	get_parent().current_weapon.damage *= 1.5
	get_parent().current_weapon.recoil_factor_x *= 2
	get_parent().current_weapon.recoil_factor_y *= 2

func card3():
	get_parent().current_weapon.cooldown_timer *= 0.75
	get_parent().current_weapon.reload_timer_modif *= 0.5

func card4():
	get_parent().current_weapon.damage *= 2
	get_parent().max_hp = round( get_parent().max_hp*0.35 )
	get_parent().hp = get_parent().max_hp
	get_node("../GUI/HP").max_value = get_parent().max_hp
	get_node("../GUI/HP2").max_value = get_parent().max_hp

func card5():
	get_parent().max_spd *= 1.35

func card6():
	get_parent().current_weapon.bullet_scale_modifier *= 1.5

func card7():
	get_parent().current_weapon.bullet_spd *= 1.5
	get_parent().current_weapon.bullet_scale_modifier *= 0.5

func card8():
	get_parent().current_weapon.multiple_bullet_spread_type = 1
	get_parent().current_weapon.multiple_bullet_count += 3

func card9():
	get_parent().current_weapon.multiple_bullet_spread_type = 0
	get_parent().current_weapon.multiple_bullet_count += 3
	
func card10():
	get_parent().current_weapon.max_ammo *= 2
	get_parent().current_weapon.bullet_spd *= 0.75

func card11():
	get_parent().current_weapon.spread *= 0.5
	get_parent().current_weapon.multiple_bullet_angle *= 0.5

func card12():
	get_parent().max_hp = round( get_parent().max_hp*2 )
	get_parent().hp = get_parent().max_hp
	get_node("../GUI/HP").max_value = get_parent().max_hp
	get_node("../GUI/HP2").max_value = get_parent().max_hp

func card13():
	get_parent().current_weapon.reload_timer_modif *= 0.5

func card14():
	get_parent().current_weapon.damage *= 1.5
	get_parent().current_weapon.cooldown_timer *= 2
	get_parent().current_weapon.max_ammo = round(get_parent().current_weapon.max_ammo * 0.5)

func card15():
	get_parent().max_hp = round( get_parent().max_hp * 1.5 )
	get_parent().max_spd *= 0.75
	get_parent().hp = get_parent().max_hp
	get_node("../GUI/HP").max_value = get_parent().max_hp
	get_node("../GUI/HP2").max_value = get_parent().max_hp

func card16():
	get_parent().max_hp = round( get_parent().max_hp * 0.6 )
	get_parent().max_spd *= 1.5
	get_parent().doublejump_spd * 2
	get_parent().hp = get_parent().max_hp
	get_node("../GUI/HP").max_value = get_parent().max_hp
	get_node("../GUI/HP2").max_value = get_parent().max_hp

func show():
	$card1/Button.disabled = true
	$card2/Button.disabled = true
	$card3/Button.disabled = true
	$Timer.start()
	$card1/RichTextLabel.percent_visible = 0
	$card2/RichTextLabel.percent_visible = 0
	$card3/RichTextLabel.percent_visible = 0
	
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

func _process(delta):
	$card1/RichTextLabel.percent_visible = lerp($card1/RichTextLabel.percent_visible, 1.1, 0.1)
	$card2/RichTextLabel.percent_visible = lerp($card2/RichTextLabel.percent_visible, 1.1, 0.1)
	$card3/RichTextLabel.percent_visible = lerp($card3/RichTextLabel.percent_visible, 1.1, 0.1)

func close():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false
	Multiplayer.respawn()

func _on_card1_pressed():
	close()
	call(card1)
	Multiplayer.notificate(Multiplayer.nickname + " взял " + str(cards[card1]["name"]), 2)

func _on_card2_pressed():
	close()
	call(card2)
	Multiplayer.notificate(Multiplayer.nickname + " взял " + str(cards[card2]["name"]), 2)

func _on_card3_pressed():
	close()
	call(card3)
	Multiplayer.notificate(Multiplayer.nickname + " взял " + str(cards[card3]["name"]), 2)

func _on_Timer_timeout():
	$card1/Button.disabled = false
	$card2/Button.disabled = false
	$card3/Button.disabled = false
