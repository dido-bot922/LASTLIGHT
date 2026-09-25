extends CanvasLayer

var resource_labels := {}
var log_label: RichTextLabel
var anomaly_bar: ProgressBar

func _ready() -> void:
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(root)
    var title := Label.new()
    title.text = "LASTLIGHT  //  VIGÍLIA ZERO"
    title.position = Vector2(32, 26)
    title.add_theme_font_size_override("font_size", 22)
    title.add_theme_color_override("font_color", Color("b9e9ff"))
    root.add_child(title)
    var status := Label.new()
    status.text = "MISSÃO 01  ·  MÓDULO DE PREPARAÇÃO  ·  T−00:17:42"
    status.position = Vector2(34, 57)
    status.add_theme_font_size_override("font_size", 12)
    status.add_theme_color_override("font_color", Color("66889a"))
    root.add_child(status)
    var panel := ColorRect.new()
    panel.position = Vector2(30, 105)
    panel.size = Vector2(245, 205)
    panel.color = Color(0.025, 0.06, 0.09, 0.88)
    root.add_child(panel)
    var header := Label.new()
    header.text = "STATUS DA NAVE"
    header.position = Vector2(48, 122)
    header.add_theme_font_size_override("font_size", 13)
    header.add_theme_color_override("font_color", Color("61d9ff"))
    root.add_child(header)
    for item in ["energy", "oxygen", "fuel", "temperature", "radiation"]:
        var label := Label.new()
        label.position = Vector2(49, 151 + resource_labels.size() * 27)
        label.add_theme_font_size_override("font_size", 14)
        root.add_child(label)
        resource_labels[item] = label
    var cross := Label.new()
    cross.text = "+"
    cross.position = Vector2(635, 347)
    cross.add_theme_font_size_override("font_size", 25)
    cross.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0, 0.7))
    root.add_child(cross)
    log_label = RichTextLabel.new()
    log_label.position = Vector2(32, 585)
    log_label.size = Vector2(620, 100)
    log_label.bbcode_enabled = true
    log_label.fit_content = true
    log_label.add_theme_font_size_override("normal_font_size", 14)
    root.add_child(log_label)
    var anomaly_title := Label.new()
    anomaly_title.text = "ANÁLISE DO SINAL // LASTLIGHT"
    anomaly_title.position = Vector2(930, 28)
    anomaly_title.add_theme_font_size_override("font_size", 13)
    anomaly_title.add_theme_color_override("font_color", Color("61d9ff"))
    root.add_child(anomaly_title)
    anomaly_bar = ProgressBar.new()
    anomaly_bar.position = Vector2(930, 56)
    anomaly_bar.size = Vector2(300, 14)
    anomaly_bar.show_percentage = false
    root.add_child(anomaly_bar)
    GameState.resources_changed.connect(_on_resources_changed)
    GameState.log_added.connect(_on_log)
    GameState.anomaly_changed.connect(_on_anomaly)
    _on_resources_changed(GameState.resources)
    _on_log("Sistema inicializado. A nave aguarda sua primeira decisão.", "good")

func _on_resources_changed(values: Dictionary) -> void:
    resource_labels.energy.text = "ENERGIA        %05.1f %%" % values.energy
    resource_labels.oxygen.text = "OXIGÊNIO       %05.1f %%" % values.oxygen
    resource_labels.fuel.text = "COMBUSTÍVEL    %05.1f %%" % values.fuel
    resource_labels.temperature.text = "TEMPERATURA    %05.1f °C" % values.temperature
    resource_labels.radiation.text = "RADIAÇÃO       %05.1f mSv" % values.radiation

func _on_anomaly(value: float) -> void:
    anomaly_bar.value = value

func _on_log(message: String, severity: String) -> void:
    var color := "#8fffc9" if severity == "good" else ("#ffbd68" if severity == "warning" else "#ff6d8e")
    log_label.append_text("[color=#66889a]LOG[/color] [color=%s]%s[/color]\n" % [color, message])
