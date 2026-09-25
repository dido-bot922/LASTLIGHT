extends StaticBody3D

func setup(position_3d: Vector3) -> void:
    position = position_3d

    var collision := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(1.8, 1.2, 0.5)
    collision.shape = box
    add_child(collision)

    var mesh := MeshInstance3D.new()
    var cube := BoxMesh.new()
    cube.size = Vector3(1.8, 1.2, 0.5)
    mesh.mesh = cube
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("102d3a")
    material.metallic = 0.75
    mesh.material_override = material
    add_child(mesh)

    var screen := Label3D.new()
    screen.text = "◈  LASTLIGHT\nE  ANALISAR"
    screen.font_size = 34
    screen.modulate = Color("61d9ff")
    screen.position = Vector3(0.0, 0.15, -0.28)
    screen.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    screen.no_depth_test = true
    add_child(screen)

func interact() -> void:
    GameState.scan_anomaly()
