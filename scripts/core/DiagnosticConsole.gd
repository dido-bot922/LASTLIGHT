extends Node
class_name LL_DiagnosticConsole

var checks := {}
var last_run := 0

func run_all() -> Dictionary:
    checks.clear()
    checks["game_state"] = _check_game_state()
    checks["resource_system"] = _check_resource_system()
    checks["failure_system"] = _check_failure_system()
    checks["science_lab"] = _check_science_lab()
    checks["navigation"] = _check_navigation()
    checks["ai"] = _check_ai()
    checks["alien_signal"] = _check_alien_signal()
    checks["campaign"] = _check_campaign()
    checks["save_manager"] = _check_save_manager()
    last_run = Time.get_ticks_msec()
    var passed := 0
    for key in checks:
        if checks[key].ok:
            passed += 1
    EventBus.post("Diagnóstico: %d/%d subsistemas aprovados." % [passed, checks.size()], "good" if passed == checks.size() else "warning")
    return checks.duplicate(true)

func _check_game_state() -> Dictionary:
    var ok := GameState != null and GameState.resources is Dictionary and GameState.systems is Dictionary
    return _result(ok, "estado global disponível")

func _check_resource_system() -> Dictionary:
    var before := ResourceSystem.get_value("energy")
    var ok := ResourceSystem.set_value("energy", before)
    return _result(ok and ResourceSystem.values.has("oxygen"), "recursos registrados")

func _check_failure_system() -> Dictionary:
    var id := "diagnostic_probe"
    var existed := FailureSystem.definitions.has(id)
    return _result(not existed or FailureSystem.count_active() >= 0, "falhas operacionais")

func _check_science_lab() -> Dictionary:
    var ok := ScienceLab.experiments.size() >= 3
    return _result(ok, "experimentos carregados")

func _check_navigation() -> Dictionary:
    return _result(NavigationSystem.destinations.size() >= 3, "rotas carregadas")

func _check_ai() -> Dictionary:
    return _result(ShipAI.memory is Array and ShipAI.trust >= 0.0, "IA disponível")

func _check_alien_signal() -> Dictionary:
    return _result(AlienSignal.alphabet.size() >= 4, "decodificador disponível")

func _check_campaign() -> Dictionary:
    return _result(Campaign.chapters.size() >= 4, "capítulos carregados")

func _check_save_manager() -> Dictionary:
    return _result(SaveManager.VERSION >= 1, "save versionado")

func _result(ok: bool, detail: String) -> Dictionary:
    return {"ok": ok, "detail": detail}
