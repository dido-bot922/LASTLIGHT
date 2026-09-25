extends Node
class_name LL_GameBootstrap

var initialized := false
var diagnostic_timer := 0.0

func _ready() -> void:
    _connect_runtime_signals()
    _seed_research_database()
    _seed_samples()
    initialized = true
    EventBus.post("BOOT: subsistemas científicos, navegação e manutenção verificados.", "good")

func _process(delta: float) -> void:
    if not initialized:
        return
    diagnostic_timer += delta
    if diagnostic_timer >= 30.0:
        diagnostic_timer = 0.0
        _periodic_diagnostics()

func _connect_runtime_signals() -> void:
    if not FailureSystem.failure_opened.is_connected(_on_failure):
        FailureSystem.failure_opened.connect(_on_failure)
    if not ResourceSystem.depleted.is_connected(_on_depleted):
        ResourceSystem.depleted.connect(_on_depleted)
    if not NavigationSystem.jump_started.is_connected(_on_jump_started):
        NavigationSystem.jump_started.connect(_on_jump_started)
    if not NavigationSystem.navigation_updated.is_connected(_on_navigation_updated):
        NavigationSystem.navigation_updated.connect(_on_navigation_updated)
    if not ScienceLab.experiment_completed.is_connected(_on_experiment_completed):
        ScienceLab.experiment_completed.connect(_on_experiment_completed)

func _seed_research_database() -> void:
    ResearchArchive.record("mission_brief", "Diretriz Aurora", "A missão deve observar antes de interpretar.", "briefing")
    ResearchArchive.record("sun_variance", "Variação solar", "A luminosidade apresenta uma queda progressiva que não segue o ciclo previsto.", "astronomy")
    ResearchArchive.record("signal_01", "Primeiro padrão", "A repetição possui intervalo regular e resposta mensurável.", "anomaly")
    ResearchArchive.add_tag("signal_01", "first-contact")
    ResearchArchive.add_tag("signal_01", "resonance")

func _seed_samples() -> void:
    ScienceLab.add_sample("dust_aurora", {"silicates": 0.42, "iron": 0.11, "unknown": 0.47})
    ScienceLab.add_sample("ice_luna", {"water": 0.73, "organics": 0.02, "unknown": 0.25})

func _periodic_diagnostics() -> void:
    var oxygen := ResourceSystem.get_value("oxygen")
    var energy := ResourceSystem.get_value("energy")
    if oxygen < 50.0:
        EventBus.post("Diagnóstico periódico: margem de oxigênio reduzida.", "warning")
    if energy < 40.0:
        EventBus.post("Diagnóstico periódico: economize energia antes da transferência.", "warning")
    EventBus.remember("periodic_diagnostic", {"oxygen": oxygen, "energy": energy})

func _on_failure(id: String, description: String) -> void:
    AudioDirector.play_alert("failure")
    ResearchArchive.record("failure_" + id, "Falha registrada", description, "maintenance")

func _on_depleted(id: String) -> void:
    EventBus.post("RECURSO ESGOTADO: " + id, "critical")
    AudioDirector.play_alert("depletion")

func _on_jump_started(destination: String) -> void:
    AtmosphereDirector.set_phase("uneasy")
    EventBus.post("Transferência iniciada para " + destination + ".", "critical")

func _on_navigation_updated(progress: float) -> void:
    if progress > 75.0:
        AtmosphereDirector.set_phase("contact")

func _on_experiment_completed(id: String, quality: float) -> void:
    ResearchArchive.record("result_" + id, "Resultado científico", "Qualidade experimental: %d%%" % int(quality * 100.0), "science")
