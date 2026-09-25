extends Node
class_name LL_RuntimeBridge

var booted := false
var elapsed := 0.0
var event_count := 0
var last_sync := 0.0
var sync_interval := 0.25
var last_player_position := Vector3.ZERO
var has_player_position := false

func _ready() -> void:
    _connect_runtime_signals()
    booted = true
    EventBus.post("Núcleo de integração LASTLIGHT online.", "good")

func _process(delta: float) -> void:
    if not booted:
        return
    elapsed += delta
    last_sync += delta
    _track_player()
    if Input.is_action_just_pressed("quick_save"):
        SaveManager.save_profile({"runtime_seconds": elapsed, "events": event_count, "mission": GameState.snapshot()})
    if Input.is_action_just_pressed("quick_load"):
        SaveManager.load_profile()
    _balance_resource_rates()
    _run_safety_checks()
    if last_sync >= sync_interval:
        last_sync = 0.0
        _sync_legacy_state()

func _connect_runtime_signals() -> void:
    if not EventBus.notification.is_connected(_on_notification):
        EventBus.notification.connect(_on_notification)
    if not ResourceSystem.critical.is_connected(_on_resource_critical):
        ResourceSystem.critical.connect(_on_resource_critical)
    if not FailureSystem.failure_opened.is_connected(_on_failure_opened):
        FailureSystem.failure_opened.connect(_on_failure_opened)
    if not ScienceLab.experiment_completed.is_connected(_on_experiment_completed):
        ScienceLab.experiment_completed.connect(_on_experiment_completed)
    if not NavigationSystem.jump_started.is_connected(_on_transfer_started):
        NavigationSystem.jump_started.connect(_on_transfer_started)
    if not ShipAI.spoken.is_connected(_on_ai_spoken):
        ShipAI.spoken.connect(_on_ai_spoken)
    if not AlienSignal.pattern_detected.is_connected(_on_pattern_detected):
        AlienSignal.pattern_detected.connect(_on_pattern_detected)
    if not EnvironmentalHazardSystem.hazard_entered.is_connected(_on_hazard_entered):
        EnvironmentalHazardSystem.hazard_entered.connect(_on_hazard_entered)
    if not EnvironmentalHazardSystem.hazard_exited.is_connected(_on_hazard_exited):
        EnvironmentalHazardSystem.hazard_exited.connect(_on_hazard_exited)

func _track_player() -> void:
    var player := get_tree().current_scene.get_node_or_null("Player") if get_tree().current_scene != null else null
    if player == null or not player is Node3D:
        return
    var position_3d: Vector3 = player.global_position
    if has_player_position and position_3d.distance_to(last_player_position) > 0.001:
        MissionTelemetry.track_position(position_3d)
    elif not has_player_position:
        MissionTelemetry.track_position(position_3d)
    last_player_position = position_3d
    has_player_position = true

func _balance_resource_rates() -> void:
    var reactor_online: bool = GameState.systems.get("reactor", false)
    var life_support_online: bool = GameState.systems.get("life_support", false)
    var comms_online: bool = GameState.systems.get("comms", false)
    ResourceSystem.set_rate("energy", -0.12 if reactor_online else 0.02)
    ResourceSystem.set_rate("oxygen", 0.04 if life_support_online else -0.025)
    ResourceSystem.set_rate("fuel", -0.018 if reactor_online else 0.0)
    ResourceSystem.set_rate("signal", 0.035 if comms_online else -0.018)
    ResourceSystem.set_rate("temperature", 0.0 if life_support_online else -0.02)
    ResourceSystem.set_rate("radiation", 0.006 if NavigationSystem.travelling else 0.0)

func _sync_legacy_state() -> void:
    for id in ResourceSystem.values:
        if GameState.resources.has(id):
            GameState.resources[id] = ResourceSystem.get_value(id)
    GameState.resources_changed.emit(GameState.resources)
    GameState.anomaly_progress = ResourceSystem.get_value("signal")
    GameState.anomaly_changed.emit(GameState.anomaly_progress)

func _run_safety_checks() -> void:
    if ResourceSystem.get_value("oxygen") < 30.0 and not FailureSystem.has("oxygen_scrubber"):
        FailureSystem.create_failure("oxygen_scrubber")
    if ResourceSystem.get_value("energy") < 20.0 and not FailureSystem.has("coolant_leak"):
        FailureSystem.create_failure("coolant_leak")
    if NavigationSystem.travelling and not GameState.systems.get("navigation", false):
        NavigationSystem.travelling = false
        EventBus.post("Transferência interrompida: navegação offline.", "critical")

func _on_notification(_text: String, _severity: String) -> void:
    event_count += 1

func _on_resource_critical(id: String, value: float) -> void:
    EventBus.post("Limite crítico: %s = %.1f" % [id, value], "warning")

func _on_failure_opened(id: String, _description: String) -> void:
    MissionTelemetry.increment("failures_resolved", 0.0)
    EventBus.remember("failure_opened", {"id": id})

func _on_experiment_completed(id: String, quality: float) -> void:
    MissionTelemetry.increment("experiments")
    EventBus.remember("science_result", {"id": id, "quality": quality})

func _on_transfer_started(destination: String) -> void:
    AtmosphereDirector.set_phase("uneasy")
    EventBus.post("Transferência iniciada para " + destination + ".", "critical")
    EventBus.remember("transfer_started", {"destination": destination})

func _on_ai_spoken(text: String) -> void:
    EventBus.remember("ai_message", {"text": text})

func _on_pattern_detected(pattern: String, confidence: float) -> void:
    MissionTelemetry.increment("signals_observed")
    EventBus.remember("alien_pattern", {"pattern": pattern, "confidence": confidence})

func _on_hazard_entered(id: String) -> void:
    EventBus.remember("hazard_entered", {"id": id})

func _on_hazard_exited(id: String) -> void:
    EventBus.remember("hazard_exited", {"id": id})
