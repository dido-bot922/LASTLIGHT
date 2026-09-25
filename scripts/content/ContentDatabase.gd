extends Node
class_name LL_ContentDatabase

const LOCATIONS := {
    "earth": {"title": "Terra", "gravity": 1.0, "atmosphere": "nitrogen_oxygen", "risk": 0.05},
    "luna": {"title": "Órbita lunar", "gravity": 0.16, "atmosphere": "vacuum", "risk": 0.25},
    "ceres": {"title": "Ceres Relay", "gravity": 0.03, "atmosphere": "thin", "risk": 0.42},
    "kepler": {"title": "Portão Kepler", "gravity": 0.0, "atmosphere": "vacuum", "risk": 0.68},
    "veil9": {"title": "Veil-9", "gravity": 0.62, "atmosphere": "unknown", "risk": 0.92}
}

const EXPERIMENT_NOTES := [
    "A medição deve ser repetível antes de virar evidência.",
    "Um sinal pode ser ruído até responder a uma intervenção.",
    "A ausência de resposta também altera a hipótese.",
    "Amostras desconhecidas não devem ser abertas sem contenção.",
    "O instrumento mede o fenômeno e também interfere nele.",
    "Uma correlação não estabelece causalidade.",
    "A nave é o laboratório e o limite da missão.",
    "Toda decisão energética é uma decisão científica.",
    "Uma comunicação precisa de contexto compartilhado.",
    "A interpretação mais simples não é necessariamente a correta."
]

const INCIDENTS := [
    {"id": "ic01", "title": "Ruído térmico", "response": "reduzir_reactor", "severity": 1},
    {"id": "ic02", "title": "Queda de pressão", "response": "seal_bulkhead", "severity": 3},
    {"id": "ic03", "title": "Eco impossível", "response": "repeat_scan", "severity": 1},
    {"id": "ic04", "title": "Deriva orbital", "response": "correct_course", "severity": 2},
    {"id": "ic05", "title": "Sombra sem fonte", "response": "observe", "severity": 2},
    {"id": "ic06", "title": "Falha de sincronização", "response": "reset_comms", "severity": 2}
]

func location(id: String) -> Dictionary:
    return LOCATIONS.get(id, {})

func note(index: int) -> String:
    if EXPERIMENT_NOTES.is_empty():
        return ""
    return EXPERIMENT_NOTES[abs(index) % EXPERIMENT_NOTES.size()]

func incident(index: int) -> Dictionary:
    if INCIDENTS.is_empty():
        return {}
    return INCIDENTS[abs(index) % INCIDENTS.size()].duplicate(true)

func all_location_ids() -> Array[String]:
    var result: Array[String] = []
    for id in LOCATIONS:
        result.append(id)
    return result
