extends CanvasLayer

var resource_labels: Array[Label] = []
var phase_label: Label
var objective_label: RichTextLabel
var log_label: RichTextLabel
var signal_bar: ProgressBar

func _ready() -> void:
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(root)
    _build_header(root)
    _build_objective(root)
    _build_status(root)
    _build_signal(root)
    _build_log(root)
    GameState.resources_changed.connect(_on_resources_changed)
    GameState.objective_changed.connect(_on_objective_changed)
    GameState.mission_phase_changed.connect(_on_phase_changed)
    GameState.anomaly_changed.connect(_on_anomaly_changed)
    GameState.log_added.connect(_on_log_added)
    _on_resources_changed(GameState.resources)
    _on_objective_changed(GameState.objective_title, GameState.objective_description)
    _on_phase_changed(GameState.phase)

func _build_header(root: Control) -> void:
    var title := Label.new()
    title.text = "LASTLIGHT"
    title.position = Vector2(28, 24)
    title.add_theme_font_size_override("font_size", 24)
    title.add_theme_color_override("font_color", Color("bcecff"))
    root.add_child(title)
    phase_label = Label.new()
    phase_label.position = Vector2(28, 58)
    phase_label.add_theme_font_size_override("font_size", 11)
    phase_label.add_theme_color_override("font_color", Color("7bb7d3"))
    root.add_child(phase_label)

func _build_objective(root: Control) -> void:
    objective_label = RichTextLabel.new()
    objective_label.position = Vector2(28, 100)
    objective_label.size = Vector2(420, 110)
    objective_label.bbcode_enabled = true
    objective_label.fit_content = true
    root.add_child(objective_label)

func _build_status(root: Control) -> void:
    var panel := ColorRect.new()
    panel.position = Vector2(28, 225)
    panel.size = Vector2(280, 210)
    panel.color = Color(0.02, 0.05, 0.08, 0.9)
    root.add_child(panel)
    var title := Label.new()
    title.text = "SYSTEMS MONITOR"
    title.position = Vector2(46, 242)
    title.add_theme_font_size_override("font_size", 13)
    title.add_theme_color_override("font_color", Color("62dfff"))
    root.add_child(title)

    var names := ["ENERGIA", "OXIGÊNIO", "COMBUSTÍVEL", "TEMPERATURA", "RADIAÇÃO"]
    for i in range(names.size()):
        var row := Label.new()
        row.position = Vector2(46, 272 + i * 24)
        row.add_theme_font_size_override("font_size", 12)
        row.add_theme_color_override("font_color", Color("dfeaf4"))
        root.add_child(row)
        resource_labels.append(row)

func _build_signal(root: Control) -> void:
    var label := Label.new()
    label.text = "ANOMALIA / LASTLIGHT"
    label.position = Vector2(912, 24)
    label.add_theme_font_size_override("font_size", 12)
    label.add_theme_color_override("font_color", Color("62dfff"))
    root.add_child(label)
    signal_bar = ProgressBar.new()
    signal_bar.position = Vector2(910, 48)
    signal_bar.size = Vector2(320, 16)
    signal_bar.max_value = 100.0
    signal_bar.show_percentage = false
    root.add_child(signal_bar)

func _build_log(root: Control) -> void:
    log_label = RichTextLabel.new()
    log_label.position = Vector2(28, 600)
    log_label.size = Vector2(760, 90)
    log_label.bbcode_enabled = true
    log_label.fit_content = true
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
    phase_label.text = "FASE / %s" % phase

func _on_anomaly_changed(value: float) -> void:
    signal_bar.value = value

func _on_log_added(message: String, severity: String) -> void:
    var color := "#8fffc9" if severity == "good" else ("#ffc76b" if severity == "warning" else "#ff7a8a")
    log_label.append_text("[color=%s]› %s[/color]\n" % [color, message])
