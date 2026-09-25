extends Node
class_name AlienCipher

var pattern_index := 0
var symbols := ["::", "..", "-:", "-.", ":::"]

func _ready() -> void:
    GameState.cipher_progress.connect(_on_progress)

func decode_step() -> String:
    if pattern_index >= symbols.size():
        pattern_index = 0
    var symbol := symbols[pattern_index]
    pattern_index += 1
    return symbol

func _on_progress(value: float) -> void:
    var ratio := clamp(value / 100.0, 0.0, 1.0)
    if ratio > 0.5:
        GameState.log_added.emit("CÓDIGO ALIENÍGENA: presença de estrutura não aleatória detectada.", "critical")
