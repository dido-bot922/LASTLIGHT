extends Node
class_name LL_RuntimeBridge

var booted := false
var elapsed := 0.0
var event_count := 0
var sync_timer := 0.0

func _ready() -> void:
    if not EventBus.notification.is_connected(_on_notification):
        EventBus.notification.connect(_on_notification)
    booted = true
    EventBus.post("Núcleo de integração LASTLIGHT online.", "good")

func _process(delta: float) -> void:
    if not booted:
        return
    elapsed += delta
    sync_timer += delta
    if Input.is_action_just_pressed("quick_save"):
        _save_runtime()
    if Input.is_action_just_pressed("quick_load"):
        _load_runtime()
    _balance_resource_rates()
    _run_safety_checks()
    if sync_timer >= 0.25:
        sync_timer = 0.0
        _sync_resource_state()

func _save_runtime() -> void:
    var payload := {"runtime_seconds": elapsed, "events": event_count, "mission": GameState.snapshot(), "resources": ResourceSystem.snapshot()}
    if SaveManager.has_method("save_profile"):
        SaveManager.save_profile(payload)
    EventBus.post("Progresso salvo.", "good")

func _load_runtime() -> void:
    if not SaveManager.has_method("load_profile"):
        return
    var loaded = SaveManager.load_profile()
    if loaded is Dictionary:
        if loaded.has("mission"):
            GameState.restore(loaded.mission)
        if loaded.has("resources"):
            ResourceSystem.restore(loaded.resources)
        EventBus.post("Progresso restaurado.", "good")

func _balance_resource_rates() -> void:
    var reactor := GameState.has_system("reactor")
    var life_support := GameState.has_system("life_support")
    var comms := GameState.has_system("comms")
    ResourceSystem.set_rate("energy", -0.12 if reactor else 0.02)
    ResourceSystem.set_rate("oxygen", 0.04 if life_support else -0.025)
    ResourceSystem.set_rate("fuel", -0.018 if reactor else 0.0)
    ResourceSystem.set_rate("signal", 0.035 if comms else -0.018)
    ResourceSystem.set_rate("temperature", 0.0 if life_support else -0.02)
    ResourceSystem.set_rate("radiation", 0.006 if NavigationSystem.travelling else 0.0)

func _sync_resource_state() -> void:
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
    if NavigationSystem.travelling and not GameState.has_system("navigation"):
        NavigationSystem.travelling = false
        EventBus.post("Transferência interrompida: navegação offline.", "critical")

func _on_notification(_text: String, _severity: String) -> void:
    event_count += 1
