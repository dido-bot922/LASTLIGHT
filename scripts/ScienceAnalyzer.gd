extends Node
class_name ScienceAnalyzer

var sample_count := 0

func _ready() -> void:
    GameState.log_added.emit("Analista científico online. Preparando protocolo de amostragem.", "good")

func run_experiment(sample_name: String, intensity: float) -> void:
    sample_count += 1
    GameState.anomaly_progress = min(100.0, GameState.anomaly_progress + intensity)
    GameState.analyze_signal()
    GameState.add_journal_entry("Experimento %s realizado. Leitura primária: %0.1f%% de coerência." % [sample_name, GameState.anomaly_progress])

func run_diagnostics() -> String:
    var state := "SINAL STABLE" if GameState.anomaly_progress > 60.0 else "SINAL INTERMITENTE"
    GameState.diagnostic_report.emit(state)
    return state
