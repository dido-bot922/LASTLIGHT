extends Node3D
class_name Starfield

var particles: CPUParticles3D

func _ready() -> void:
    particles = CPUParticles3D.new()
    particles.amount = 200
    particles.lifetime = 10.0
    particles.preprocess = 2.0
    particles.emitting = true
    particles.one_shot = false
    particles.draw_order = CPUParticles3D.DRAW_ORDER_LIFETIME
    particles.fixed_fps = 30
    particles.initial_velocity_min = 0.2
    particles.initial_velocity_max = 1.2
    particles.gravity = Vector3.ZERO
    particles.position = Vector3.ZERO
    particles.rotation = Vector3.ZERO

    var material := StandardMaterial3D.new()
    material.emission_enabled = true
    material.emission = Color("dfeeff")
    material.emission_energy_multiplier = 2.0
    material.albedo_color = Color("dfeeff")
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    particles.material = material

    var mesh := SphereMesh.new()
    mesh.radius = 0.03
    mesh.height = 0.06
    particles.mesh = mesh
    add_child(particles)

func _process(_delta: float) -> void:
    rotation_y += 0.002
