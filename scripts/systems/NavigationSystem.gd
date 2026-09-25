extends Node
class_name LL_NavigationSystem

signal course_changed(destination: String)
signal jump_started(destination: String)
signal jump_aborted(reason: String)
signal navigation_updated(progress: float)

var destinations := {
    "LUNA-ORBITA": {"distance": 1.0, "fuel": 4.0, "radiation": 5.0},
    "CERES-RELAY": {"distance": 5.0, "fuel": 18.0, "radiation": 18.0},
    "KEPLER-GATE": {"distance": 16.0, "fuel": 42.0, "radiation": 35.0},
    "VEIL-9": {"distance": 30.0, "fuel": 68.0, "radiation": 55.0}
}
var destination := ""
var travel_progress := 0.0
var travelling := false

func select_destination(id: String) -> bool:
    if not destinations.has(id):
        return false
    destination = id
    course_changed.emit(id)
    EventBus.post("Rota selecionada: " + id, "info")
    return true

func begin_transfer() -> bool:
    if travelling or destination.is_empty():
        return false
    if not GameState.systems.navigation or not GameState.systems.thrusters:
        EventBus.post("Navegação e propulsão precisam estar online.", "warning")
        return false
    var route: Dictionary = destinations[destination]
    if GameState.resources.fuel < route.fuel:
        EventBus.post("Combustível insuficiente para a transferência.", "warning")
        return false
    GameState.resources.fuel -= route.fuel
    travelling = true
    travel_progress = 0.0
    jump_started.emit(destination)
    EventBus.post("Transferência iniciada: " + destination, "critical")
    return true

func _process(delta: float) -> void:
    if not travelling:
        return
    var speed := 0.7 if GameState.resources.energy > 30.0 else 0.35
    if FailureSystem.has("guidance_fault"):
        speed *= 0.45
    travel_progress = min(100.0, travel_progress + delta * speed)
    navigation_updated.emit(travel_progress)
    if travel_progress >= 100.0:
        travelling = false
        GameState.resources.radiation += destinations[destination].radiation * 0.1
        EventBus.post("Transferência concluída: " + destination, "good")
