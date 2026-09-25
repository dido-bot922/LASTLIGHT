extends Node

signal resources_changed(resources: Dictionary)
signal log_added(message: String, severity: String)
signal anomaly_changed(value: float)

var resources := {"energy": 82.0, "oxygen": 96.0, "fuel": 74.0, "temperature": 21.0, "radiation": 3.0, "signal": 0.0}
var systems := {"power": false, "life_support": false, "comms": false, "science": false}
var mission_time := 0.0
var anomaly_progress := 0.0

func _process(delta: float) -> void:
    mission_time += delta
    if systems.power:
        resources.energy = max(0.0, resources.energy - delta * 0.012)
    if systems.life_support:
        resources.oxygen = min(100.0, resources.oxygen + delta * 0.018)
        resources.temperature = move_toward(resources.temperature, 21.0, delta * 0.025)
    else:
        resources.oxygen = max(0.0, resources.oxygen - delta * 0.008)
        resources.temperature = move_toward(resources.temperature, 14.0, delta * 0.012)
    resources.radiation = clamp(resources.radiation + sin(mission_time * 0.17) * delta * 0.05, 0.0, 100.0)
    resources.signal = clamp(resources.signal - delta * 0.006, 0.0, 100.0)
    resources_changed.emit(resources)

func operate(system: String) -> String:
    if not systems.has(system):
        return "UNKNOWN"
    systems[system] = not systems[system]
    var state := "ONLINE" if systems[system] else "STANDBY"
    var names := {"power": "REATOR", "life_support": "SUPORTE DE VIDA", "comms": "COMUNICAÇÕES", "science": "LABORATÓRIO"}
    log_added.emit("%s: protocolos %s" % [names[system], state], "good")
    resources_changed.emit(resources)
    return state

func scan_anomaly() -> void:
    if not systems.science or not systems.comms:
        log_added.emit("Leitura inconclusiva. Ative LABORATÓRIO e COMUNICAÇÕES.", "warning")
        return
    anomaly_progress = min(100.0, anomaly_progress + 18.0)
    resources.signal = min(100.0, resources.signal + 24.0)
    anomaly_changed.emit(anomaly_progress)
    if anomaly_progress >= 100.0:
        log_added.emit("PADRÃO DECODIFICADO: a última luz não é uma estrela.", "critical")
    else:
        log_added.emit("Padrão ressonante isolado: %d%% analisado." % int(anomaly_progress), "good")
