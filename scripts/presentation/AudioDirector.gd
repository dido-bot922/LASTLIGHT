extends Node
class_name LL_AudioDirector

var channels := {}
var ambience := "ship_hum"
var volume := 0.8
var muted := false

func register_channel(id: String, initial := 0.0) -> void:
    channels[id] = {"volume": initial, "playing": false, "time": 0.0}

func play(id: String) -> void:
    if not channels.has(id):
        register_channel(id, 0.5)
    channels[id].playing = true
    channels[id].time = 0.0

func stop(id: String) -> void:
    if channels.has(id):
        channels[id].playing = false

func set_channel_volume(id: String, value: float) -> void:
    if not channels.has(id):
        register_channel(id)
    channels[id].volume = clampf(value, 0.0, 1.0)

func set_ambience(id: String) -> void:
    ambience = id
    EventBus.post("Ambiente sonoro: " + id, "info")

func play_alert(kind: String) -> void:
    var channel := "alert_" + kind
    play(channel)
    EventBus.remember("audio_alert", {"kind": kind})

func _process(delta: float) -> void:
    if muted:
        return
    for id in channels:
        if channels[id].playing:
            channels[id].time += delta
