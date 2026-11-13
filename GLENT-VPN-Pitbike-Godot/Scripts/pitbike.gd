extends CharacterBody3D
var speed := 0.0
var steer := 0.0

func _ready():
    var shape = CollisionShape3D.new()
    var capsule = CapsuleShape3D.new()
    capsule.radius=0.48
    capsule.height=1.2
    shape.shape=capsule
    shape.position.y=0.55
    add_child(shape)
    var visual = Node3D.new()
    add_child(visual)
    # Two chunky wheels and red frame
    add_cylinder(visual,Vector3(-0.68,0.35,0),0.38,Color(0.02,0.02,0.025))
    add_cylinder(visual,Vector3(0.68,0.35,0),0.38,Color(0.02,0.02,0.025))
    add_beam(visual,Vector3(-0.68,0.35,0),Vector3(0,0.8,0),0.09,Color(0.95,0.03,0.08))
    add_beam(visual,Vector3(0,0.8,0),Vector3(0.68,0.35,0),0.09,Color(0.95,0.03,0.08))
    add_beam(visual,Vector3(-0.18,0.78,0),Vector3(0.48,0.9,0),0.09,Color(0.1,0.1,0.12))
    add_beam(visual,Vector3(-0.12,0.85,0),Vector3(0.12,1.48,0),0.13,Color(0.08,0.08,0.1))
    add_sphere(visual,Vector3(0.12,1.58,0),Vector3(0.25,0.29,0.23),Color(0.9,0.03,0.08))
    add_beam(visual,Vector3(-0.12,1.25,0),Vector3(0.42,0.98,0),0.11,Color(0.9,0.9,0.95))
    add_beam(visual,Vector3(0.42,0.98,0),Vector3(0.66,0.55,0),0.1,Color(0.9,0.9,0.95))

func _physics_process(delta):
    var gas=Input.get_action_strength("accelerate")
    var brake=Input.get_action_strength("brake")
    var steer_input=Input.get_action_strength("steer_right")-Input.get_action_strength("steer_left")
    speed=move_toward(speed,gas*24.0,15.0*delta)
    if brake>0: speed=move_toward(speed,0.0,28.0*delta)
    if gas==0 and brake==0: speed=move_toward(speed,0.0,2.0*delta)
    steer=move_toward(steer,steer_input,4.0*delta)
    rotation.y-=steer*delta*clamp(speed/9.0,0.25,1.7)
    var fwd=-global_transform.basis.z
    velocity.x=fwd.x*speed
    velocity.z=fwd.z*speed
    if not is_on_floor(): velocity.y-=22.0*delta
    elif Input.is_action_just_pressed("jump"): velocity.y=8.5
    else: velocity.y=-0.5
    move_and_slide()
    if global_position.y < -8:
        global_position=Vector3(0,2,3)
        velocity=Vector3.ZERO
        speed=0

func add_cylinder(parent,pos,radius,color):
    var n=MeshInstance3D.new()
    var m=CylinderMesh.new()
    m.top_radius=radius
    m.bottom_radius=radius
    m.height=0.18
    n.mesh=m
    n.position=pos
    n.rotation.z=PI/2
    var mat=StandardMaterial3D.new()
    mat.albedo_color=color
    n.material_override=mat
    parent.add_child(n)

func add_beam(parent,a,b,radius,color):
    var n=MeshInstance3D.new()
    var m=CylinderMesh.new()
    m.top_radius=radius
    m.bottom_radius=radius
    m.height=a.distance_to(b)
    n.mesh=m
    n.position=(a+b)/2
    n.look_at_from_position(n.position,b,Vector3.UP)
    n.rotate_object_local(Vector3.RIGHT,PI/2)
    var mat=StandardMaterial3D.new()
    mat.albedo_color=color
    n.material_override=mat
    parent.add_child(n)

func add_sphere(parent,pos,scl,color):
    var n=MeshInstance3D.new()
    n.mesh=SphereMesh.new()
    n.position=pos
    n.scale=scl
    var mat=StandardMaterial3D.new()
    mat.albedo_color=color
    n.material_override=mat
    parent.add_child(n)
