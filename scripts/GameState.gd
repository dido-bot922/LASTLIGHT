extends Node
class_name GameStateController

signal resources_changed(resources: Dictionary)
signal log_added(message: String, severity: String)
signal anomaly_changed(value: float)
signal objective_changed(title: String, description: String)
signal mission_phase_changed(phase: String)
signal system_changed(system_id: String, online: bool)
signal interaction_denied(reason: String)

const PHASE_PREP := "EARTH_PREP"
const PHASE_SIGNAL := "SIGNAL_ANALYSIS"
const PHASE_LAUNCH := "LAUNCH_READY"
const PHASE_TRAVEL := "SPACE_TRAVEL"
const PHASE_CONTACT := "FIRST_CONTACT"
const SYSTEM_IDS := ["reactor", "life_support", "comms", "science", "navigation", "thrusters", "airlock"]

var phase := PHASE_PREP
var objective_title := "Preparar a missão"
var objective_description := "Ative o reator, o suporte de vida, as comunicações e o laboratório."
var resources := {"energy": 82.0, "oxygen": 96.0, "fuel": 74.0, "temperature": 21.0, "radiation": 3.0, "signal": 0.0, "pressure": 1.0}
var systems := {"reactor": false, "life_support": false, "comms": false, "science": false, "thrusters": false, "navigation": false, "airlock": false}
var anomaly_progress := 0.0
var scans_completed := 0
var scan_goal := 5
var mission_flags: Dictionary = {}
var _emit_timer := 0.0

func _ready() -> void:
    call_deferred("_announce_state")

func _process(delta: float) -> void:
    _simulate_systems(delta)
    _emit_timer += delta
    if _emit_timer >= 0.25:
        _emit_timer = 0.0
        resources_changed.emit(resources)

func _simulate_systems(delta: float) -> void:
    if systems.reactor:
        resources.energy = maxf(0.0, resources.energy - delta * 0.012)
        resources.fuel = maxf(0.0, resources.fuel - delta * 0.006)
    else:
        resources.energy = minf(100.0, resources.energy + delta * 0.006)
    if systems.life_support:
        resources.oxygen = minf(100.0, resources.oxygen + delta * 0.025)
        resources.temperature = move_toward(resources.temperature, 21.0, delta * 0.015)
    else:
        resources.oxygen = maxf(0.0, resources.oxygen - delta * 0.01)
        resources.temperature = move_toward(resources.temperature, 14.0, delta * 0.015)
    resources.signal = clampf(resources.signal + (delta * 0.025 if systems.comms else -delta * 0.02), 0.0, 100.0)
    resources.radiation = clampf(resources.radiation + sin(Time.get_ticks_msec() * 0.0012) * delta * 0.05, 0.0, 100.0)
    resources.pressure = move_toward(resources.pressure, 1.0 if systems.life_support else 0.72, delta * 0.01)

func _announce_state() -> void:
    objective_changed.emit(objective_title, objective_description)
    mission_phase_changed.emit(phase)
    resources_changed.emit(resources)
    anomaly_changed.emit(anomaly_progress)

func has_system(id: String) -> bool:
    return bool(systems.get(id, false))

func all_preflight_systems_online() -> bool:
    for id in ["reactor", "life_support", "comms", "science"]:
        if not has_system(id):
            return false
    return true

func set_system(id: String, online: bool, reason := "") -> bool:
    if not systems.has(id):
        interaction_denied.emit("Sistema desconhecido: " + id)
        return false
    if bool(systems[id]) == online:
        return true
    systems[id] = online
    system_changed.emit(id, online)
    var suffix := " — " + reason if not reason.is_empty() else ""
    log_added.emit("%s: %s%s" % [id.to_upper(), "ONLINE" if online else "STANDBY", suffix], "good" if online else "warning")
    resources_changed.emit(resources)
    return true

func toggle_system(id: String) -> String:
    if not systems.has(id):
        return "UNKNOWN"
    var online := not bool(systems[id])
    set_system(id, online)
    return "ONLINE" if online else "STANDBY"

func advance_phase(next_phase: String) -> void:
    if phase == next_phase:
        return
    phase = next_phase
    mission_phase_changed.emit(phase)

func set_objective(title: String, description: String) -> void:
    objective_title = title
    objective_description = description
    objective_changed.emit(title, description)

func analyze_signal() -> bool:
    if not has_system("science") or not has_system("comms"):
        interaction_denied.emit("Laboratório e comunicações precisam estar online.")
        log_added.emit("Análise bloqueada: ative laboratório e comunicações.", "warning")
        return false
    scans_completed = mini(scans_completed + 1, scan_goal)
    anomaly_progress = minf(100.0, float(scans_completed) / float(scan_goal) * 100.0)
    resources.signal = minf(100.0, resources.signal + 12.0)
    mission_flags["signal_decoded"] = anomaly_progress >= 100.0
    anomaly_changed.emit(anomaly_progress)
    log_added.emit("SINAL DECODIFICADO." if mission_flags.signal_decoded else "Leitura %d/%d concluída." % [scans_completed, scan_goal], "critical" if mission_flags.signal_decoded else "good")
    return true

func snapshot() -> Dictionary:
    return {"phase": phase, "objective_title": objective_title, "objective_description": objective_description, "resources": resources.duplicate(true), "systems": systems.duplicate(true), "anomaly_progress": anomaly_progress, "scans_completed": scans_completed, "scan_goal": scan_goal, "mission_flags": mission_flags.duplicate(true)}

func restore(data: Dictionary) -> bool:
    if data.is_empty():
        return false
    phase = str(data.get("phase", phase))
    objective_title = str(data.get("objective_title", objective_title))
    objective_description = str(data.get("objective_description", objective_description))
    var saved_resources: Dictionary = data.get("resources", {})
    var saved_systems: Dictionary = data.get("systems", {})
    for id in resources:
        if saved_resources.has(id):
            resources[id] = float(saved_resources[id])
    for id in systems:
        if saved_systems.has(id):
            systems[id] = bool(saved_systems[id])
    anomaly_progress = clampf(float(data.get("anomaly_progress", anomaly_progress)), 0.0, 100.0)
    scans_completed = maxi(0, int(data.get("scans_completed", scans_completed)))
    scan_goal = maxi(1, int(data.get("scan_goal", scan_goal)))
    mission_flags = data.get("mission_flags", {}).duplicate(true)
    _announce_state()
    return true
