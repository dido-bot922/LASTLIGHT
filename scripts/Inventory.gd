extends Node
class_name Inventory

signal inventory_changed(items: Dictionary)

var items := {
    "repair_kit": 2,
    "sample_container": 3,
    "thermal_cell": 1,
    "sensor_filter": 1,
    "research_notes": 0
}

func has_item(id: String, amount := 1) -> bool:
    return items.get(id, 0) >= amount

func add_item(id: String, amount := 1) -> void:
    items[id] = items.get(id, 0) + amount
    inventory_changed.emit(items)
    GameState.log_added.emit("Inventário: +%d %s" % [amount, id], "good")

func remove_item(id: String, amount := 1) -> bool:
    if not has_item(id, amount):
        return false
    items[id] -= amount
    inventory_changed.emit(items)
    return true
