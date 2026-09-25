extends CanvasLayer

var resource_labels: Array[Label] = []
var phase_label: Label
var objective_label: RichTextLabel
var log_label: RichTextLabel
var signal_bar: ProgressBar
var prompt_label: Label

func _ready() -> void:
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(root)
    _build_header(root)
    _build_objective(root)
    _build_status(root)
    _build_signal(root)
    _build_prompt(root)
    _build_log(root)
    GameState.resources_changed.connect(_on_resources_changed)
    GameState.objective_changed.connect(_on_objective_changed)
    GameState.mission_phase_changed.connect(_on_phase_changed)
    GameState.anomaly_changed.connect(_on_anomaly_changed)
    GameState.log_added.connect(_on_log_added)
    _on_resources_changed(GameState.resources)
    _on_objective_changed(GameState.objective_title, GameState.objective_description)
    _on_phase_changed(GameState.phase)
    var player := get_parent().get_node_or_null("Player")
    if player != null and player.has_signal("interaction_target_changed"):
        player.interaction_target_changed.connect(_on_prompt_changed)

func _label(root: Control, text: String, position: Vector2, size: int, color: Color) -> Label:
    var node := Label.new()
    node.text = text
    node.position = position
    node.add_theme_font_size_override("font_size", size)
    node.add_theme_color_override("font_color", color)
    root.add_child(node)
    return node

func _build_header(root: Control) -> void:
    _label(root, "LASTLIGHT", Vector2(28, 24), 24, Color("bcecff"))
    phase_label = _label(root, "", Vector2(30, 58), 11, Color("7bb7d3"))
    _label(root, "AURORA-7  /  PESQUISA DE FRONTEIRA", Vector2(30, 77), 11, Color("71899e"))

func _build_objective(root: Control) -> void:
    objective_label = RichTextLabel.new()
    objective_label.position = Vector2(28, 105)
    objective_label.size = Vector2(430, 95)
    objective_label.bbcode_enabled = true
    objective_label.add_theme_font_size_override("normal_font_size", 15)
    root.add_child(objective_label)

func _build_status(root: Control) -> void:
    var panel := ColorRect.new()
    panel.position = Vector2(28, 225)
    panel.size = Vector2(280, 210)
    panel.color = Color(0.02, 0.05, 0.08, 0.90)
    root.add_child(panel)
    _label(root, "SYSTEMS MONITOR", Vector2(46, 242), 13, Color("62dfff"))
    for i in range(5):
        resource_labels.append(_label(root, "", Vector2(46, 272 + i * 24), 12, Color("dfeaf4")))

func _build_signal(root: Control) -> void:
    _label(root, "ANOMALIA / LASTLIGHT", Vector2(912, 24), 12, Color("62dfff"))
    signal_bar = ProgressBar.new()
    signal_bar.position = Vector2(910, 48)
    signal_bar.size = Vector2(320, 16)
    signal_bar.max_value = 100.0
    signal_bar.show_percentage = false
    root.add_child(signal_bar)

func _build_prompt(root: Control) -> void:
    prompt_label = _label(root, "", Vector2(505, 615), 15, Color("bcecff"))
    prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prompt_label.size.x = 270

func _build_log(root: Control) -> void:
    log_label = RichTextLabel.new()
    log_label.position = Vector2(28, 600)
    log_label.size = Vector2(450, 90)
    log_label.bbcode_enabled = true
    log_label.add_theme_font_size_override("normal_font_size", 12)
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

func _on_prompt_changed(text: String) -> void:
    prompt_label.text = text

func _on_log_added(message: String, severity: String) -> void:
    var color := "#8fffc9" if severity == "good" else ("#ffc76b" if severity == "warning" else "#ff7a8a")
    log_label.append_text("[color=%s]› %s[/color]\n" % [color, message])
