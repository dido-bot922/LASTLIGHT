extends Node
class_name FirstPersonFeedback

signal pulse(color: Color, strength: float, duration: float)
signal subtitle(text: String, duration: float)

var damage_flash := 0.0
var interact_flash := 0.0
var current_message := ""
var message_time := 0.0

func _process(delta: float) -> void:
    damage_flash = maxf(0.0, damage_flash - delta)
    interact_flash = maxf(0.0, interact_flash - delta)
    message_time = maxf(0.0, message_time - delta)

func damage(amount: float) -> void:
    damage_flash = clampf(amount, 0.0, 1.0)
    pulse.emit(Color("ff536b"), damage_flash, 0.3)

func confirm() -> void:
    interact_flash = 1.0
    pulse.emit(Color("66e6ff"), 0.35, 0.12)

func warn(text: String) -> void:
    current_message = text
    message_time = 2.5
    subtitle.emit(text, 2.5)
    pulse.emit(Color("ffc766"), 0.45, 0.2)

func narrate(text: String, duration := 4.0) -> void:
    current_message = text
    message_time = duration
    subtitle.emit(text, duration)
