extends Node
class_name LL_InputPromptService

signal prompt_changed(text: String)
signal device_changed(device: String)

var device := "keyboard_mouse"
var prompts := {
    "interact": {"keyboard_mouse": "E", "controller": "A"},
    "sprint": {"keyboard_mouse": "SHIFT", "controller": "L3"},
    "cancel": {"keyboard_mouse": "ESC", "controller": "B"},
    "scan": {"keyboard_mouse": "Q", "controller": "LB"}
}

func _ready() -> void:
    prompt_changed.emit("E")

func set_device(next_device: String) -> void:
    if next_device not in ["keyboard_mouse", "controller"]:
        return
    if device == next_device:
        return
    device = next_device
    device_changed.emit(device)

func prompt(action: String) -> String:
    if not prompts.has(action):
        return "?"
    return str(prompts[action].get(device, "?"))

func format_action(action: String, label: String) -> String:
    return "[%s] %s" % [prompt(action), label]

func _input(event: InputEvent) -> void:
    if event is InputEventJoypadButton or event is InputEventJoypadMotion:
        set_device("controller")
    elif event is InputEventKey or event is InputEventMouseMotion or event is InputEventMouseButton:
        set_device("keyboard_mouse")
