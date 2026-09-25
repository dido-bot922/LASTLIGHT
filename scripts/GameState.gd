extends Node

signal resources_changed(resources: Dictionary)
signal log_added(message: String, severity: String)
signal anomaly_changed(value: float)
signal objective_changed(title: String, description: String)
signal mission_phase_changed(phase: String)

var phase := "EARTH_PREP"
var objective_title := "Preparar a missão"
var objective_description := "Ative reinicialização do reator, suporte de vida, comunicações e laboratório."

var resources := {
    "energy": 82.0,
    "oxygen": 96.0,
    "fuel": 74.0,
    "temperature": 21.0,
    "radiation": 3.0,
    "signal": 0.0
}

var systems := {
    "reactor": false,
    "life_support": false,
    "comms": false,
    "science": false,
    "thrusters": false,
    "navigation": false,
    "airlock": false
}

var anomaly_progress := 0.0
var scans_completed := 0
var scan_goal := 5

func _ready() -> void:
    set_process(true)
    objective_changed.emit(objective_title, objective_description)
    mission_phase_changed.emit(phase)

func _process(delta: float) -> void:
    _simulate_systems(delta)

func _simulate_systems(delta: float) -> void:
    if systems.reactor:
        resources.energy = max(0.0, resources.energy - delta * 0.012)
        resources.fuel = max(0.0, resources.fuel - delta * 0.006)
    else:
        resources.energy = min(100.0, resources.energy + delta * 0.006)

    if systems.life_support:
        resources.oxygen = min(100.0, resources.oxygen + delta * 0.025)
        resources.temperature = move_toward(resources.temperature, 21.0, delta * 0.015)
    else:
        resources.oxygen = max(0.0, resources.oxygen - delta * 0.01)
        resources.temperature = move_toward(resources.temperature, 14.0, delta * 0.015)

    if systems.comms:
        resources.signal = min(100.0, resources.signal + delta * 0.025)
    else:
        resources.signal = max(0.0, resources.signal - delta * 0.02)

    resources.radiation = clamp(resources.radiation + sin(TAU * 0.2 * (OS.get_ticks_msec() / 1000.0)) * delta * 0.05, 0.0, 100.0)
    resources_changed.emit(resources)

func advance_phase(next_phase: String) -> void:
    phase = next_phase
    mission_phase_changed.emit(next_phase)

func set_objective(title: String, description: String) -> void:
    objective_title = title
    objective_description = description
    objective_changed.emit(title, description)

func toggle_system(system_name: String) -> String:
    if not systems.has(system_name):
        return "UNKNOWN"
    systems[system_name] = not systems[system_name]
    var state := "ONLINE" if systems[system_name] else "STANDBY"
    log_added.emit("%s: %s" % [system_name.to_upper(), state], "good")
    resources_changed.emit(resources)
    return state

func analyze_signal() -> void:
    if not systems.science or not systems.comms:
        log_added.emit("Ative laboratório e comunicações antes da análise.", "warning")
        return

    scans_completed += 1
    anomaly_progress = min(100.0, anomaly_progress + 20.0)
    resources.signal = min(100.0, resources.signal + 12.0)
    anomaly_changed.emit(anomaly_progress)

    if scans_completed >= scan_goal:
        log_added.emit("SINAL DECODIFICADO: a emissão tem padrão inteligível e não natural.", "critical")
    else:
        log_added.emit("Leitura %d/%d concluída. Padrão ressonante detectado." % [scans_completed, scan_goal], "good")

func reset_signal() -> void:
    scans_completed = 0
    anomaly_progress = 0.0
    resources.signal = 0.0
    anomaly_changed.emit(anomaly_progress)
