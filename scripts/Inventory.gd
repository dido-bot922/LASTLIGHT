extends Node
class_name Inventory

signal inventory_changed(items: Dictionary)

var items := {
    "repair_kit": 2,
    "antenna_filter": 1,
    "sample_vial": 3,
    "thermal_cell": 1,
    "research_notes": 0
}

func acquire(id: String, amount := 1) -> void:
    items[id] = items.get(id, 0) + amount
    inventory_changed.emit(items)
    GameState.log_added.emit("Inventário: +%d %s" % [amount, id], "good")

func consume(id: String, amount := 1) -> bool:
    if items.get(id, 0) < amount:
        return false
    items[id] -= amount
    inventory_changed.emit(items)
    return true

func has(id: String, amount := 1) -> bool:
    return items.get(id, 0) >= amount
