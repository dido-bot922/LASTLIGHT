extends Node
class_name LL_AlienSignal

signal pattern_detected(pattern: String, confidence: float)
signal translation_changed(text: String, certainty: float)

var alphabet := ["KAI", "KAI-KAI", "NUL", "VRA", "VRA-KAI", "HUSH"]
var observed: Array[String] = []
var associations := {}
var confidence := 0.0

func observe(sample: String) -> void:
    observed.append(sample)
    if observed.size() > 100:
        observed.pop_front()
    var pattern := _normalize(sample)
    associations[pattern] = int(associations.get(pattern, 0)) + 1
    confidence = clampf(confidence + 0.035, 0.0, 1.0)
    pattern_detected.emit(pattern, confidence)
    EventBus.alien_pattern_received.emit(pattern, confidence)
    EventBus.post("Padrão externo observado: %s (confiança %d%%)" % [pattern, int(confidence * 100.0)], "critical")

func test_response(response: String) -> Dictionary:
    var expected := _expected_response()
    var match_score := 0.2
    if response == expected:
        match_score = 0.95
        confidence = min(1.0, confidence + 0.1)
    elif response.length() == expected.length():
        match_score = 0.5
    translation_changed.emit(_translate(expected), match_score)
    return {"expected": expected, "score": match_score, "confidence": confidence}

func _normalize(sample: String) -> String:
    var clean := sample.strip_edges().to_upper()
    if clean.is_empty():
        return "HUSH"
    return alphabet[abs(hash(clean)) % alphabet.size()]

func _expected_response() -> String:
    if confidence < 0.25:
        return "HUSH"
    if confidence < 0.6:
        return "KAI"
    if confidence < 0.85:
        return "VRA"
    return "KAI-KAI"

func _translate(pattern: String) -> String:
    var translations := {"HUSH": "aguarde", "KAI": "observe", "VRA": "aproxime-se", "KAI-KAI": "compartilhe", "NUL": "perigo", "VRA-KAI": "responda"}
    return translations.get(pattern, "sem tradução")
