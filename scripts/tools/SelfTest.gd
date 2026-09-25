extends Node
class_name LL_SelfTest

var results: Array[Dictionary] = []

func run() -> Array[Dictionary]:
    results.clear()
    _test_resources()
    _test_content()
    _test_routes()
    _test_signal()
    _test_save_shape()
    var passed := 0
    for result in results:
        if result.ok:
            passed += 1
    EventBus.post("Self-test: %d/%d testes aprovados." % [passed, results.size()], "good" if passed == results.size() else "warning")
    return results.duplicate(true)

func _test_resources() -> void:
    var ok := ResourceSystem.values.has("energy") and ResourceSystem.values.has("oxygen")
    _add("resources", ok)

func _test_content() -> void:
    _add("content_locations", ContentDatabase.all_location_ids().size() >= 4)

func _test_routes() -> void:
    _add("navigation_routes", NavigationSystem.destinations.size() >= 3)

func _test_signal() -> void:
    _add("alien_alphabet", AlienSignal.alphabet.size() >= 4)

func _test_save_shape() -> void:
    _add("save_version", SaveManager.VERSION >= 1)

func _add(id: String, ok: bool) -> void:
    results.append({"id": id, "ok": ok})
