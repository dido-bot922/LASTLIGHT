extends Node
class_name FirstPersonAnimationRouter

signal animation_requested(animation_name: String)

var animation_player: AnimationPlayer
var animation_tree: AnimationTree
var library: Dictionary = {}
var current := "idle"

func setup(root: Node) -> void:
    animation_player = root.get_node_or_null("AnimationPlayer") as AnimationPlayer
    animation_tree = root.get_node_or_null("AnimationTree") as AnimationTree
    _register_default_library()

func play(name: String, blend := 0.18) -> void:
    if name == current:
        return
    current = name
    if animation_player != null and animation_player.has_animation(name):
        animation_player.play(name, blend)
    elif animation_tree != null:
        animation_tree.set("parameters/state/transition_request", name)
    animation_requested.emit(name)

func register(name: String, description: String, duration := 0.0) -> void:
    library[name] = {"description": description, "duration": duration}

func has(name: String) -> bool:
    return library.has(name)

func _register_default_library() -> void:
    register("idle", "Respiração e microajustes de postura")
    register("walk", "Caminhada controlada em gravidade artificial")
    register("sprint", "Corrida curta com balanço de braços")
    register("interact", "Mãos operando um console")
    register("repair", "Reparo físico em painel de manutenção", 2.0)
    register("scan", "Leitura científica com instrumento de mão", 1.5)
    register("brace", "Postura de contenção durante emergência")
    register("damage", "Reação a impacto ou falha estrutural", 0.8)
