extends Node
class_name GameState

signal resources_changed(resources: Dictionary)
signal log_added(message: String, severity: String)
signal anomaly_changed(value: float)
signal objective_changed(title: String, description: String)
signal mission_phase_changed(phase: String)
signal journal_updated(entry: String)
signal diagnostic_report(text: String)
signal cipher_progress(value: float)

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
    "navigation": false
}

var phase := "EARTH_PREP"
var anomaly_progress := 0.0
var ticks := 0.0
var max_scan_count := 5
var scans_performed := 0
var objective_title := "Preparar a missão"
var objective_description := "Ative o reator, suporte de vida, comunicação e laboratório para preparar a nave."

func _ready() -> void:
    set_process(true)
    emit_signal("objective_changed", objective_title, objective_description)
    emit_signal("mission_phase_changed", phase)

func _process(delta: float) -> void:
    ticks += delta
    _simulate_resources(delta)

func _simulate_resources(delta: float) -> void:
    if systems.reactor:
        resources.energy = max(0.0, resources.energy - delta * 0.014)
        resources.fuel = max(0.0, resources.fuel - delta * 0.006)
    if systems.life_support:
        resources.oxygen = min(100.0, resources.oxygen + delta * 0.02)
        resources.temperature = move_toward(resources.temperature, 21.0, delta * 0.02)
    else:
        resources.oxygen = max(0.0, resources.oxygen - delta * 0.009)
        resources.temperature = move_toward(resources.temperature, 14.0, delta * 0.014)

    if systems.comms:
        resources.signal = min(100.0, resources.signal + delta * 0.03)
    else:
        resources.signal = max(0.0, resources.signal - delta * 0.02)

    resources.radiation = clamp(resources.radiation + sin(ticks * 0.12) * delta * 0.05, 0.0, 100.0)
    resources_changed.emit(resources)

func toggle_system(id: String) -> String:
    if not systems.has(id):
        return "UNKNOWN"
    systems[id] = not systems[id]
    var state := "ONLINE" if systems[id] else "STANDBY"
    log_added.emit("%s: %s" % [id.to_upper(), state], "good")
    resources_changed.emit(resources)
    return state

func set_objective(title: String, description: String) -> void:
    objective_title = title
    objective_description = description
    objective_changed.emit(title, description)

func advance_phase(next_phase: String) -> void:
    phase = next_phase
    mission_phase_changed.emit(next_phase)

func add_journal_entry(text: String) -> void:
    journal_updated.emit(text)
    log_added.emit(text, "good")

func analyze_signal() -> void:
    if not systems.science or not systems.comms:
        log_added.emit("Ative LABORATÓRIO e COMUNICAÇÕES para analisar o sinal.", "warning")
        return

    scans_performed += 1
    anomaly_progress = min(100.0, anomaly_progress + 20.0)
    resources.signal = min(100.0, resources.signal + 18.0)
    anomaly_changed.emit(anomaly_progress)
    cipher_progress.emit(anomaly_progress)

    if scans_performed >= max_scan_count:
        var msg := "PADRÃO PRINCIPAL DECODIFICADO: o sinal é estruturado, intencional e não natural."
        log_added.emit(msg, "critical")
        diagnostic_report.emit(msg)
    else:
        var msg := "Leitura %d/%d concluída. Padrão ressonante detectado." % [scans_performed, max_scan_count]
        log_added.emit(msg, "good")
        diagnostic_report.emit(msg)

func reset_progress() -> void:
    anomaly_progress = 0.0
    scans_performed = 0
    resources.signal = 0.0
    anomaly_changed.emit(anomaly_progress)
    cipher_progress.emit(anomaly_progress)
