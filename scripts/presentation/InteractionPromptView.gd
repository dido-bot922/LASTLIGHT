extends Node
class_name LL_InteractionPromptView

@export var fade_speed := 12.0
var label: Label
var target_alpha := 0.0
var current_alpha := 0.0
var current_prompt := ""

func _ready() -> void:
    label = Label.new()
    label.name = "InteractionPrompt"
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 22)
    label.add_theme_color_override("font_color", Color("b8efff"))
    label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    label.position = Vector2(-260.0, -105.0)
    label.size = Vector2(520.0, 48.0)
    label.modulate.a = 0.0
    add_child(label)

func _process(delta: float) -> void:
    current_alpha = lerpf(current_alpha, target_alpha, delta * fade_speed)
    if label != null:
        label.modulate.a = current_alpha

func show_prompt(text: String) -> void:
    current_prompt = text
    target_alpha = 1.0
    if label != null:
        label.text = text

func hide_prompt() -> void:
    target_alpha = 0.0

func pulse() -> void:
    if label == null:
        return
    var tween := create_tween()
    tween.tween_property(label, "scale", Vector2(1.08, 1.08), 0.08)
    tween.tween_property(label, "scale", Vector2.ONE, 0.14)
