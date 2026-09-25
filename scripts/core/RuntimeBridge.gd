extends Node
class_name LL_RuntimeBridge

var booted := false
var elapsed := 0.0
var event_count := 0

func _ready() -> void:
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
    booted = true
    EventBus.post("Núcleo de integração LASTLIGHT online.", "good")

func _process(delta: float) -> void:
    if not booted:
        return
    elapsed += delta
    if Input.is_action_just_pressed("quick_save"):
        SaveManager.save_profile({"runtime_seconds": elapsed, "events": event_count})
    if Input.is_action_just_pressed("quick_load"):
        SaveManager.load_profile()
    _balance_resource_rates()
    _run_safety_checks()

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
    EventBus.remember("failure_opened", {"id": id})

func _on_experiment_completed(id: String, quality: float) -> void:
    EventBus.remember("science_result", {"id": id, "quality": quality})

func _on_transfer_started(destination: String) -> void:
    EventBus.remember("transfer_started", {"destination": destination})

func _on_ai_spoken(text: String) -> void:
    EventBus.remember("ai_message", {"text": text})

func _on_pattern_detected(pattern: String, confidence: float) -> void:
    EventBus.remember("alien_pattern", {"pattern": pattern, "confidence": confidence})
