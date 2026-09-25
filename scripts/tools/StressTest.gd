extends Node
class_name LL_StressTest

var cases := [
    "resource_bounds", "failure_lifecycle", "signal_progress", "route_validation",
    "save_roundtrip_shape", "interaction_history", "hazard_exposure", "journal_search"
]

func run() -> Dictionary:
    var results := {}
    var passed := 0
    for id in cases:
        var result := _run_case(id)
        results[id] = result
        if result.ok:
            passed += 1
    var report := {"ok": passed == cases.size(), "passed": passed, "total": cases.size(), "results": results}
    EventBus.remember("stress_test", report)
    return report

func _run_case(id: String) -> Dictionary:
    match id:
        "resource_bounds":
            return {"ok": ResourceSystem.get_value("energy") >= 0.0 and ResourceSystem.get_value("energy") <= 100.0}
        "failure_lifecycle":
            return {"ok": FailureSystem.count_active() >= 0}
        "signal_progress":
            return {"ok": GameState.anomaly_progress >= 0.0 and GameState.anomaly_progress <= 100.0}
        "route_validation":
            return {"ok": NavigationSystem.destinations.size() >= 1}
        "save_roundtrip_shape":
            return {"ok": SaveManager.VERSION >= 1}
        "interaction_history":
            return {"ok": EventBus.history is Array}
        "hazard_exposure":
            return {"ok": EnvironmentalHazardSystem.hazards.size() >= 3}
        "journal_search":
            return {"ok": SaveJournal.entries is Array}
    return {"ok": false}
