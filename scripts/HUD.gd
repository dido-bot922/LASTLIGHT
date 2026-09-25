extends CanvasLayer

var root: Control
var resource_labels: Array[Label] = []
var system_labels: Array[Label] = []
var phase_label: Label
var objective_label: RichTextLabel
var log_label: RichTextLabel
var signal_bar: ProgressBar
var stamina_bar: ProgressBar
var prompt_label: Label
var subtitle_label: RichTextLabel
var log_lines: Array[String] = []

func _ready() -> void:
    root = Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(root)
    _build_header()
    _build_objective()
    _build_status()
    _build_signal()
    _build_prompt()
    _build_subtitles()
    _build_log()
    GameState.resources_changed.connect(_on_resources_changed)
    GameState.objective_changed.connect(_on_objective_changed)
    GameState.mission_phase_changed.connect(_on_phase_changed)
    GameState.anomaly_changed.connect(_on_anomaly_changed)
    GameState.log_added.connect(_on_log_added)
    var player := get_parent().get_node_or_null("Player")
    if player != null:
        if player.has_signal("interaction_target_changed"):
            player.interaction_target_changed.connect(_on_prompt_changed)
        if player.has_signal("stamina_changed"):
            player.stamina_changed.connect(_on_stamina_changed)
    _on_resources_changed(GameState.resources)
    _on_objective_changed(GameState.objective_title, GameState.objective_description)
    _on_phase_changed(GameState.phase)
    _on_anomaly_changed(GameState.anomaly_progress)

func _label(text: String, position: Vector2, size: int, color: Color) -> Label:
    var node := Label.new()
    node.text = text
    node.position = position
    node.add_theme_font_size_override("font_size", size)
    node.add_theme_color_override("font_color", color)
    root.add_child(node)
    return node

func _panel(position: Vector2, size: Vector2, color := Color(0.02, 0.05, 0.08, 0.9)) -> ColorRect:
    var panel := ColorRect.new()
    panel.position = position
    panel.size = size
    panel.color = color
    root.add_child(panel)
    return panel

func _build_header() -> void:
    _label("LASTLIGHT", Vector2(28, 20), 25, Color("bcecff"))
    phase_label = _label("", Vector2(30, 57), 11, Color("7bb7d3"))
    _label("AURORA-7  /  PESQUISA DE FRONTEIRA", Vector2(30, 76), 11, Color("71899e"))

func _build_objective() -> void:
    objective_label = RichTextLabel.new()
    objective_label.position = Vector2(28, 104)
    objective_label.size = Vector2(430, 102)
    objective_label.bbcode_enabled = true
    objective_label.fit_content = true
    objective_label.add_theme_font_size_override("normal_font_size", 15)
    root.add_child(objective_label)

func _build_status() -> void:
    _panel(Vector2(28, 222), Vector2(310, 260))
    _label("SYSTEMS MONITOR", Vector2(46, 239), 13, Color("62dfff"))
    for id in ["energy", "oxygen", "fuel", "temperature", "radiation", "pressure"]:
        resource_labels.append(_label("", Vector2(46, 268 + resource_labels.size() * 23), 12, Color("dfeaf4")))
    for id in ["reactor", "life_support", "comms", "science"]:
        system_labels.append(_label("", Vector2(190, 268 + system_labels.size() * 23), 10, Color("8fffc9")))

func _build_signal() -> void:
    _label("ANOMALIA / LASTLIGHT", Vector2(912, 24), 12, Color("62dfff"))
    signal_bar = ProgressBar.new()
    signal_bar.position = Vector2(910, 48)
    signal_bar.size = Vector2(320, 16)
    signal_bar.max_value = 100.0
    signal_bar.show_percentage = false
    root.add_child(signal_bar)
    _label("STAMINA", Vector2(1035, 78), 10, Color("7894a4"))
    stamina_bar = ProgressBar.new()
    stamina_bar.position = Vector2(1035, 94)
    stamina_bar.size = Vector2(195, 9)
    stamina_bar.max_value = 100.0
    stamina_bar.show_percentage = false
    root.add_child(stamina_bar)

func _build_prompt() -> void:
    prompt_label = _label("", Vector2(505, 615), 15, Color("bcecff"))
    prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prompt_label.size = Vector2(270, 34)

func _build_subtitles() -> void:
    subtitle_label = RichTextLabel.new()
    subtitle_label.position = Vector2(360, 520)
    subtitle_label.size = Vector2(560, 70)
    subtitle_label.bbcode_enabled = true
    subtitle_label.fit_content = true
    subtitle_label.add_theme_font_size_override("normal_font_size", 17)
    root.add_child(subtitle_label)
    if SubtitleDirector.subtitle_started.is_connected(_on_subtitle):
        return
    SubtitleDirector.subtitle_started.connect(_on_subtitle)

func _build_log() -> void:
    log_label = RichTextLabel.new()
    log_label.position = Vector2(28, 600)
    log_label.size = Vector2(450, 90)
    log_label.bbcode_enabled = true
    log_label.scroll_active = false
    log_label.add_theme_font_size_override("normal_font_size", 12)
    root.add_child(log_label)

func _on_resources_changed(values: Dictionary) -> void:
    if resource_labels.size() < 6:
        return
    resource_labels[0].text = "ENERGIA       %05.1f %%" % float(values.get("energy", 0.0))
    resource_labels[1].text = "OXIGÊNIO      %05.1f %%" % float(values.get("oxygen", 0.0))
    resource_labels[2].text = "COMBUSTÍVEL   %05.1f %%" % float(values.get("fuel", 0.0))
    resource_labels[3].text = "TEMPERATURA   %05.1f °C" % float(values.get("temperature", 0.0))
    resource_labels[4].text = "RADIAÇÃO      %05.1f mSv" % float(values.get("radiation", 0.0))
    resource_labels[5].text = "PRESSÃO       %05.2f atm" % float(values.get("pressure", 0.0))
    for index in system_labels.size():
        var id := ["reactor", "life_support", "comms", "science"][index]
        system_labels[index].text = "%s %s" % [id.to_upper(), "●" if GameState.has_system(id) else "○"]
        system_labels[index].modulate = Color("8fffc9") if GameState.has_system(id) else Color("71899e")

func _on_objective_changed(title: String, description: String) -> void:
    objective_label.clear()
    objective_label.append_text("[b]%s[/b]\n%s" % [title, description])

func _on_phase_changed(phase: String) -> void:
    phase_label.text = "FASE / %s" % phase

func _on_anomaly_changed(value: float) -> void:
    signal_bar.value = value

func _on_stamina_changed(value: float, maximum: float) -> void:
    stamina_bar.max_value = maximum
    stamina_bar.value = value

func _on_prompt_changed(text: String) -> void:
    prompt_label.text = text

func _on_subtitle(text: String) -> void:
    subtitle_label.clear()
    subtitle_label.append_text("[center][color=#bcecff]%s[/color][/center]" % text)

func _on_log_added(message: String, severity: String) -> void:
    var color := "#8fffc9" if severity == "good" else ("#ffc76b" if severity == "warning" else "#ff7a8a")
    log_lines.append("[color=%s]› %s[/color]" % [color, message])
    if log_lines.size() > 5:
        log_lines.pop_front()
    log_label.text = "\n".join(log_lines)
