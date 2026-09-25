extends CanvasLayer

var root: Control
var resource_labels: Array[Label] = []
var phase_label: Label
var objective_label: RichTextLabel
var log_label: RichTextLabel
var anomaly_bar: ProgressBar

func _ready() -> void:
    root = Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(root)
    _build_header()
    _build_objective()
    _build_status()
    _build_signal_panel()
    _build_log()
    GameState.resources_changed.connect(_on_resources_changed)
    GameState.objective_changed.connect(_on_objective_changed)
    GameState.mission_phase_changed.connect(_on_phase_changed)
    GameState.anomaly_changed.connect(_on_anomaly_changed)
    GameState.log_added.connect(_on_log_added)
    _on_resources_changed(GameState.resources)
    _on_objective_changed(GameState.objective_title, GameState.objective_description)
    _on_phase_changed(GameState.phase)

func _label(text: String, position: Vector2, size: int, color: Color) -> Label:
    var node := Label.new()
    node.text = text
    node.position = position
    node.add_theme_font_size_override("font_size", size)
    node.add_theme_color_override("font_color", color)
    root.add_child(node)
    return node

func _build_header() -> void:
    _label("LASTLIGHT", Vector2(30, 24), 24, Color("b9ecff"))
    phase_label = _label("", Vector2(32, 56), 12, Color("73b8d3"))
    _label("AURORA-7  /  PESQUISA DE FRONTEIRA", Vector2(32, 76), 11, Color("71899e"))

func _build_objective() -> void:
    objective_label = RichTextLabel.new()
    objective_label.position = Vector2(30, 112)
    objective_label.size = Vector2(430, 92)
    objective_label.bbcode_enabled = true
    objective_label.add_theme_font_size_override("normal_font_size", 15)
    root.add_child(objective_label)

func _build_status() -> void:
    var panel := ColorRect.new()
    panel.position = Vector2(30, 225)
    panel.size = Vector2(270, 205)
    panel.color = Color(0.025, 0.055, 0.08, 0.90)
    root.add_child(panel)
    _label("SYSTEMS MONITOR", Vector2(48, 241), 13, Color("62dfff"))
    var names := ["ENERGIA", "OXIGÊNIO", "COMBUSTÍVEL", "TEMPERATURA", "RADIAÇÃO"]
    for i in names.size():
        var row := _label(names[i], Vector2(48, 270 + i * 27), 12, Color("b3c8d3"))
        resource_labels.append(row)

func _build_signal_panel() -> void:
    _label("ANOMALIA // LASTLIGHT", Vector2(910, 27), 12, Color("62dfff"))
    anomaly_bar = ProgressBar.new()
    anomaly_bar.position = Vector2(910, 52)
    anomaly_bar.size = Vector2(310, 16)
    anomaly_bar.max_value = 100.0
    anomaly_bar.show_percentage = false
    root.add_child(anomaly_bar)
    _label("E: operar equipamentos   |   ESC: liberar cursor", Vector2(910, 80), 11, Color("71899e"))

func _build_log() -> void:
    log_label = RichTextLabel.new()
    log_label.position = Vector2(30, 600)
    log_label.size = Vector2(760, 90)
    log_label.bbcode_enabled = true
    log_label.add_theme_font_size_override("normal_font_size", 13)
    root.add_child(log_label)

func _on_resources_changed(values: Dictionary) -> void:
    if resource_labels.size() < 5:
        return
    resource_labels[0].text = "ENERGIA       %05.1f %%" % values.energy
    resource_labels[1].text = "OXIGÊNIO      %05.1f %%" % values.oxygen
    resource_labels[2].text = "COMBUSTÍVEL   %05.1f %%" % values.fuel
    resource_labels[3].text = "TEMPERATURA   %05.1f °C" % values.temperature
    resource_labels[4].text = "RADIAÇÃO      %05.1f mSv" % values.radiation

func _on_objective_changed(title: String, description: String) -> void:
    objective_label.clear()
    objective_label.append_text("[b]%s[/b]\n%s" % [title, description])

func _on_phase_changed(phase: String) -> void:
    phase_label.text = "FASE  /  %s" % phase

func _on_anomaly_changed(value: float) -> void:
    anomaly_bar.value = value

func _on_log_added(message: String, severity: String) -> void:
    var color := "#8fffc9" if severity == "good" else ("#ffca6b" if severity == "warning" else "#ff718c")
    log_label.append_text("[color=%s]› %s[/color]\n" % [color, message])
