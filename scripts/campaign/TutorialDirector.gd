extends Node
class_name LL_TutorialDirector

signal tutorial_step_changed(index: int, title: String, instruction: String)
signal tutorial_finished

var steps := [
    {"id": "look", "title": "Orientação", "instruction": "Mova o mouse para observar o módulo de preparação."},
    {"id": "move", "title": "Deslocamento", "instruction": "Use W, A, S e D para caminhar pelo corredor."},
    {"id": "reactor", "title": "Reator", "instruction": "Encontre o console do reator e pressione E."},
    {"id": "life", "title": "Atmosfera", "instruction": "Ative o suporte de vida para estabilizar o oxigênio."},
    {"id": "science", "title": "Ciência", "instruction": "Ligue o laboratório e prepare uma análise."},
    {"id": "signal", "title": "Sinal", "instruction": "Ative comunicações e observe o padrão recebido."},
    {"id": "finish", "title": "Primeira decisão", "instruction": "Escolha entre analisar o sinal ou preparar a nave."}
]
var index := 0
var enabled := true

func _ready() -> void:
    if enabled:
        _emit_current()

func _process(_delta: float) -> void:
    if not enabled:
        return
    match str(steps[index].id):
        "reactor":
            if GameState.systems.reactor: advance()
        "life":
            if GameState.systems.life_support: advance()
        "science":
            if GameState.systems.science: advance()
        "signal":
            if GameState.systems.comms: advance()

func advance() -> void:
    index += 1
    if index >= steps.size():
        enabled = false
        tutorial_finished.emit()
        EventBus.post("Tutorial concluído. A missão agora é sua.", "good")
        return
    _emit_current()

func skip() -> void:
    enabled = false
    EventBus.post("Tutorial ignorado. Todos os sistemas continuam disponíveis.", "info")

func _emit_current() -> void:
    var step: Dictionary = steps[index]
    tutorial_step_changed.emit(index, step.title, step.instruction)
    EventBus.post("TUTORIAL: " + step.title + " — " + step.instruction, "info")
