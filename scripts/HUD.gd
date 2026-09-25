extends CanvasLayer

var section_title: Label
var mission_label: Label
var phase_label: Label
var log_label: RichTextLabel
var objective_label: RichTextLabel
var radar_value: ProgressBar

func _ready() -> void:
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(root)

    section_title = Label.new()
    section_title.text = "LASTLIGHT // MISSÃO"
    section_title.position = Vector2(28, 24)
    section_title.add_theme_font_size_override("font_size", 20)
    section_title.add_theme_color_override("font_color", Color("BEE6FF"))
    root.add_child(section_title)

    phase_label = Label.new()
    phase_label.position = Vector2(30, 52)
    phase_label.add_theme_font_size_override("font_size", 11)
    phase_label.add_theme_color_override("font_color", Color("7BB7D1"))
    root.add_child(phase_label)

    mission_label = Label.new()
    mission_label.position = Vector2(30, 78)
    mission_label.add_theme_font_size_override("font_size", 11)
    mission_label.add_theme_color_override("font_color", Color("97A9C3"))
    root.add_child(mission_label)

    objective_label = RichTextLabel.new()
    objective_label.position = Vector2(30, 105)
    objective_label.size = Vector2(400, 120)
    objective_label.bbcode_enabled = true
    objective_label.fit_content = true
    root.add_child(objective_label)

    var status_panel := ColorRect.new()
    status_panel.position = Vector2(30, 220)
    status_panel.size = Vector2(260, 220)
    status_panel.color = Color(0.04, 0.07, 0.09, 0.8)
    root.add_child(status_panel)

    var status_title := Label.new()
    status_title.text = "STATUS DA NAVE"
    status_title.position = Vector2(48, 236)
    status_title.add_theme_font_size_override("font_size", 13)
    status_title.add_theme_color_override("font_color", Color("7FE7FF"))
    root.add_child(status_title)

    var resource_names := ["ENERGIA", "OXIGÊNIO", "COMBUSTÍVEL", "TEMPERATURA", "RADIAÇÃO"]
    for i in range(resource_names.size()):
        var r := Label.new()
        r.position = Vector2(48, 262 + i * 24)
        r.add_theme_font_size_override("font_size", 12)
        r.name = "res_%d" % i
        root.add_child(r)

    radar_value = ProgressBar.new()
    radar_value.position = Vector2(920, 38)
    radar_value.size = Vector2(300, 14)
    radar_value.min_value = 0
    radar_value.max_value = 100
    radar_value.show_percentage = false
    root.add_child(radar_value)

    var radar_label := Label.new()
    radar_label.text = "SINAL / LASTLIGHT"
    radar_label.position = Vector2(920, 18)
    radar_label.add_theme_font_size_override("font_size", 11)
    radar_label.add_theme_color_override("font_color", Color("7FE7FF"))
    root.add_child(radar_label)

    log_label = RichTextLabel.new()
    log_label.position = Vector2(30, 600)
    log_label.size = Vector2(700, 90)
    log_label.bbcode_enabled = true
    log_label.fit_content = true
    root.add_child(log_label)

    GameState.resources_changed.connect(_on_resources_changed)
    GameState.objective_changed.connect(_on_objective_changed)
    GameState.mission_phase_changed.connect(_on_phase_changed)
    GameState.log_added.connect(_on_log)
    GameState.anomaly_changed.connect(_on_anomaly)
    _on_resources_changed(GameState.resources)
    _on_phase_changed(GameState.phase)
    _on_objective_changed(GameState.objective_title, GameState.objective_description)

func _on_resources_changed(resources: Dictionary) -> void:
    var labels := ["res_0", "res_1", "res_2", "res_3", "res_4"]
    var values := [
        "ENERGIA       %05.1f %%" % resources.energy,
        "OXIGÊNIO      %05.1f %%" % resources.oxygen,
        "COMBUSTÍVEL   %05.1f %%" % resources.fuel,
        "TEMPERATURA   %05.1f °C" % resources.temperature,
        "RADIAÇÃO      %05.1f mSv" % resources.radiation,
    ]
    for i in range(labels.size()):
        var label := get_node_or_null("%s" % labels[i])
        if label != null:
            label.text = values[i]

func _on_objective_changed(title: String, description: String) -> void:
    objective_label.clear()
    objective_label.append_text("[b]%s[/b]\n%s" % [title, description])

func _on_phase_changed(phase: String) -> void:
    phase_label.text = "FASE: %s" % phase
    mission_label.text = "MISSÃO // LASTLIGHT"

func _on_anomaly(value: float) -> void:
    radar_value.value = value

func _on_log(message: String, severity: String) -> void:
    var color := "#8FFFC9" if severity == "good" else ("#FFCC70" if severity == "warning" else "#FF7B90")
    log_label.append_text("[color=%s]%s[/color]\n" % [color, message])
