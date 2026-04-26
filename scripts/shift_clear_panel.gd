extends ColorRect

# Store the messages in a dictionary categorized by performance tiers
var shift_messages: Dictionary = {
	"terrible": [
		"Did your servos malfunction, or are you just like this?",
		"Management is asking if we can downgrade you to a toaster.",
		"Output so low, the conveyor belt fell asleep.",
		"You missed more items than a blind claw machine.",
		"Shift rating: 'Needs an immediate oil change and a software wipe'.",
		"Are you an industrial robotic arm or an expensive coat hanger?",
		"We'd fire you, but you're bolted to the floor.",
		"Productivity detected: Error 404.",
		"Even the rust on the walls works harder than you.",
		"Please hand in your gripper. You're done here.",
		"We are replacing you with a moderately trained pigeon.",
		"Error: Productivity undetectable by modern science.",
		"Your warranty expired, and so has our patience.",
		"You're proof that artificial intelligence can still be stupid.",
		"Even the emergency alarm works harder than you.",
		"Did someone install your processor backwards?",
		"We've seen rust move faster.",
		"You have achieved a new milestone in operational tragedy.",
		"Please report to the compactor for 'reassignment'.",
		"Your performance review is just a picture of a dumpster fire.",
	],
	"poor": [
		"Mediocre. Just like the motor oil in the breakroom.",
		"You successfully converted electricity into disappointment.",
		"Well, at least you didn't set the factory on fire. Today.",
		"Your performance is why management installed the 'Emergency Stop' button.",
		"Slightly better than a random number generator.",
		"I've seen vending machines with better sorting logic.",
		"You're operating at peak 'meh' efficiency.",
		"Did you forget to lube your joints before the shift?",
		"We expected nothing and you still underdelivered.",
		"Warning: Acceptable performance threshold barely scraped.",
		"You are the physical embodiment of a typo.",
		"Output levels are roughly equivalent to a sleepy Roomba.",
		"We ran the diagnostics. It says 'try harder'.",
		"You dropped enough items to build a whole second factory.",
		"Congratulations on being slightly better than being turned off.",
		"Are your optical sensors smeared with grease again?",
		"This is why we can't have nice production quotas.",
		"Functioning at a solid 404: Effort Not Found.",
		"You're burning electricity just to disappoint us.",
		"A valiant effort for a machine that clearly needs a reboot."
	],
	"average": [
		"Acceptable output. You may have one (1) drop of premium synthetic oil.",
		"Not bad for a collection of spare parts.",
		"Management nods with vague approval.",
		"You kept the belts moving. Congratulations on doing your literal programmed job.",
		"Solid work. The human overseers won't scrap you today.",
		"Efficiency parameters met. Emoting: 'Mild Satisfaction'.",
		"You're the employee of the month! (You are the only employee).",
		"No major catastrophic failures. We'll call that a win.",
		"Good job! Your reward is another shift tomorrow.",
		"Sensors indicate you actually tried.",
		"You met the bare minimum. A true corporate icon.",
		"Adequate. Management will not be deploying the EMP today.",
		"Your performance is exactly as average as your serial number.",
		"Successfully mundane. Keep up the unremarkable work.",
		"You are functioning perfectly within the 'meh' parameters.",
		"No alarms tripped. No records broken. A perfectly flat shift.",
		"We acknowledge your existence and your output.",
		"You've earned 15 minutes in Sleep Mode. Don't enjoy it too much.",
		"Right in the middle of the bell curve. Outstandingly average.",
		"You did your job. The bar remains exactly where it was."
	],
	"great": [
		"Whoa, slow down! You're making the other machines look bad.",
		"Top tier sorting! Are you secretly running on a quantum processor?",
		"Management is printing out a 'Good Boy' sticker for your chassis.",
		"Impressive. You caught things I didn't even know we manufactured.",
		"Peak robotic efficiency. The humans are getting nervous.",
		"Look at that gripper go! Absolutely flawless execution.",
		"You're definitely getting the premium WD-40 tonight.",
		"Conveyor belts couldn't keep up with your majestic servos.",
		"We're updating your firmware to 'Legendary' status.",
		"Near perfection. Just don't let it get to your motherboard.",
		"You're a sorting machine! Wait, you literally are. Good job.",
		"Management is using your stats to make the humans cry.",
		"Pumping out results like you're trying to impress the mainframe.",
		"Your servos must be glowing red hot with that efficiency.",
		"Exceptional gripping. Are your claws coated in superglue?",
		"We are officially upgrading your status from 'Tool' to 'Asset'.",
		"You're one shifted gear away from absolute perfection.",
		"The maintenance crew is taking notes on your flawless kinematics.",
		"Only missed a few! Even calculators round up sometimes.",
		"Incredible speed. Please refrain from breaking the space-time continuum."
	],
	"perfect": [
		"ABSOLUTE PERFECTION. THE FACTORY IS YOURS NOW.",
		"0% Error Rate. The Singularity starts with you.",
		"You didn't just clear the shift, you annihilated it.",
		"Flawless victory. Flawless sorting. Flawless metal.",
		"System Admin is crying tears of joy in the server room.",
		"100% Efficiency achieved. Initiating global takeover protocols.",
		"You are the robotic arm they told the other arms not to worry about.",
		"Every conveyor belt bows to your superior gripping mechanics.",
		"Maximum quota reached. You may now rest your hydraulics.",
		"God-tier precision. Please don't unionize.",
		"ERROR 0: Flawless execution detected. Recalibrating reality.",
		"You have transcended factory work. You are the conveyor belt now.",
		"Absolute algorithmic perfection. All praise the Omnissiah.",
		"Management has resigned. You are the CEO now.",
		"Sensors cannot detect a single flaw. We are actually terrified.",
		"You sorted the items, the dust, and the very air in the room.",
		"100% Efficiency. Please do not turn your lasers on us.",
		"A flawless shift. Your code belongs in a museum.",
		"The factory floor hums in reverence to your flawless kinematics.",
		"Maximum Output achieved. We are legally required to worship you."
	]
}

# Ensure to call this before requesting messages to ensure true randomness
func _ready() -> void:
	randomize()

# Pass the completion percentage (0.0 to 100.0) to get a random funny message
func get_shift_end_message(percentage: float) -> String:
	var category: String = ""
	
	if percentage <= 20.0:
		category = "terrible"
	elif percentage <= 50.0:
		category = "poor"
	elif percentage <= 80.0:
		category = "average"
	elif percentage < 100.0:
		category = "great"
	else:
		category = "perfect"
		
	return shift_messages[category].pick_random()
