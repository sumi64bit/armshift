extends Control

var empty_van_messages: PackedStringArray = [
	"What are you doing? The driver is lonely and confused.",
	"Ah, yes. A fresh shipment of... absolutely nothing.",
	"Efficiency level: 0%. Confusion level: 100%.",
	"We don't get paid for transporting ghosts.",
	"Is this some kind of tax write-off?",
	"Wait, let me look closer... nope, still empty.",
	"The customer ordered 'Nothing' and you delivered it perfectly!",
	"Fuel costs: $50. Cargo value: $0. Math is hard.",
	"That is a very expensive way to move air across town.",
	"Mission Failed: Cargo not found. Did it evaporate?",
	"Inventory says we're full of 'potential,' but the van is empty.",
	"The 'Invisible Box' trend is really getting out of hand.",
	"Did the boxes fall out, or did you just forget the 'factory' part of this sim?",
	"Congrats! You just delivered a whole lot of vacuum.",
	"Our customer service department is going to have a long day.",
	"The van feels light today. A bit too light. Suspiciously light.",
	"Are we playing Hide and Seek with the cargo? Because I can't find it.",
	"Sending an empty van is a bold strategy. Let's see if it pays off.",
	"Zero boxes? That’s some high-level minimalist logistics right there.",
	"The driver enjoyed the scenic route, but the customer is still waiting."
]

@onready var package_count: Label = $TextureRect/HBoxContainer/package_count
@onready var points_label: Label = $TextureRect/points_earned/points

func popup(deliveries: int, points: int) -> void:
	package_count.text = str(deliveries)
	points_label.text = str(points)
	$TextureRect/delivery_anim.play("show")
	$TextureRect/boxes/good_box.hide()
	$TextureRect/boxes/great_box.hide()
	$TextureRect/boxes/perfect_box.hide()
	$TextureRect/boxes/null_box.hide()
	
	$TextureRect/good_panel.hide()
	$TextureRect/great_panel.hide()
	$TextureRect/perfect_panel.hide()
	$TextureRect/null_panel.hide()
	
	$TextureRect/empty_delivery.hide()
	$TextureRect/good_delivery.hide()
	$TextureRect/great_delivery.hide()
	$TextureRect/perfect_delivery.hide()
	
	if points >= 2000:
		$TextureRect/perfect_panel.show()
		$TextureRect/boxes/perfect_box.show()
		$TextureRect/perfect_delivery.show()
		$TextureRect/HBoxContainer.show()
		$TextureRect/points_earned.show()
		$TextureRect/message.hide()
		$TextureRect/perfect_anim.play("show")
	elif points >= 1000:
		$TextureRect/great_delivery.show()
		$TextureRect/boxes/great_box.show()
		$TextureRect/great_panel.show()
		$TextureRect/HBoxContainer.show()
		$TextureRect/points_earned.show()
		$TextureRect/message.hide()
	elif points > 0:
		$TextureRect/good_panel.show()
		$TextureRect/boxes/good_box.show()
		$TextureRect/good_delivery.show()
		$TextureRect/HBoxContainer.show()
		$TextureRect/points_earned.show()
		$TextureRect/message.hide()
	else:
		$TextureRect/empty_delivery.show()
		$TextureRect/boxes/null_box.show()
		$TextureRect/null_panel.show()
		$TextureRect/HBoxContainer.hide()
		$TextureRect/points_earned.hide()
		$TextureRect/message.show()
		var random_index = randi() % empty_van_messages.size()
		var text_comment = empty_van_messages[random_index]
		$TextureRect/message.text = text_comment
