extends Node
class_name PlanetProbe

func scan_surface(body_name: String) -> String:
    var profile := "Superfície %s: presença de minerais, vento ínfimo e sinais de atividade microbiana." % body_name
    GameState.add_journal_entry(profile)
    GameState.resources.signal = min(100.0, GameState.resources.signal + 12.0)
    return profile
