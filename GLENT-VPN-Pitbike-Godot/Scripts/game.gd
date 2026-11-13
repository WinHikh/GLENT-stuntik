extends Node3D
var bike
var cams: Array[Camera3D] = []
var cam_index := 0
var speed_label: Label

func _ready():
    var world = WorldEnvironment.new()
    var env = Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.025,0.025,0.045)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.6,0.6,0.7)
    world.environment = env
    add_child(world)
    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-45,-25,0)
    add_child(sun)
    make_box(Vector3(0,-0.35,-18),Vector3(24,0.5,90),Color(0.10,0.10,0.13))
    make_box(Vector3(-11.7,0.3,-18),Vector3(0.4,1,90),Color(0.8,0.03,0.07))
    make_box(Vector3(11.7,0.3,-18),Vector3(0.4,1,90),Color(0.8,0.03,0.07))
    for z in [-9.0,-23.0,-39.0]:
        var ramp = StaticBody3D.new()
        ramp.position = Vector3(0,0,z)
        ramp.rotation_degrees.x = -18
        var mesh = MeshInstance3D.new()
        var bm = BoxMesh.new()
        bm.size = Vector3(5.5,1.1,4)
        mesh.mesh = bm
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0.9,0.035,0.07)
        mesh.material_override = mat
        ramp.add_child(mesh)
        var cs = CollisionShape3D.new()
        var bs = BoxShape3D.new()
        bs.size = bm.size
        cs.shape = bs
        ramp.add_child(cs)
        add_child(ramp)
    bike = preload("res://Scripts/pitbike.gd").new()
    bike.position = Vector3(0,1.2,3)
    add_child(bike)
    for i in 3:
        var c = Camera3D.new()
        add_child(c)
        cams.append(c)
    cams[0].current = true
    build_hud()

func make_box(pos:Vector3, size:Vector3, color:Color):
    var b = StaticBody3D.new()
    b.position = pos
    var m = MeshInstance3D.new()
    var bm = BoxMesh.new()
    bm.size = size
    m.mesh = bm
    var mat = StandardMaterial3D.new()
    mat.albedo_color = color
    m.material_override = mat
    b.add_child(m)
    var cs = CollisionShape3D.new()
    var bs = BoxShape3D.new()
    bs.size = size
    cs.shape = bs
    b.add_child(cs)
    add_child(b)

func _process(_delta):
    if not is_instance_valid(bike): return
    var offsets = [Vector3(0,3,7),Vector3(0,1,-0.2),Vector3(5,4,8)]
    var cam = cams[cam_index]
    cam.global_position = cam.global_position.lerp(bike.global_position+offsets[cam_index],0.13)
    cam.look_at(bike.global_position+Vector3(0,1,-3),Vector3.UP)
    speed_label.text = "GLENT  |  SPEED  %03d" % int(bike.speed*3.2)

func build_hud():
    var layer = CanvasLayer.new()
    add_child(layer)
    var title = Label.new()
    title.text = "GLENT VPN  •  PITBIKE STUNT"
    title.position = Vector2(24,18)
    title.add_theme_font_size_override("font_size",25)
    title.add_theme_color_override("font_color",Color(1,0.12,0.16))
    layer.add_child(title)
    speed_label = Label.new()
    speed_label.position = Vector2(24,55)
    speed_label.add_theme_font_size_override("font_size",20)
    layer.add_child(speed_label)
    var hint = Label.new()
    hint.text = "TOUCH CONTROLS  •  C = CAMERA"
    hint.position = Vector2(24,86)
    layer.add_child(hint)
    add_button(layer,"LEFT",Vector2(25,-100),"steer_left",false)
    add_button(layer,"RIGHT",Vector2(145,-100),"steer_right",false)
    add_button(layer,"BRAKE",Vector2(-280,-100),"brake",true)
    add_button(layer,"GAS",Vector2(-155,-100),"accelerate",true)
    add_button(layer,"JUMP",Vector2(-155,-205),"jump",true)
    var cam = Button.new()
    cam.text = "CAM"
    cam.position = Vector2(-280,-205)
    cam.size = Vector2(110,75)
    cam.anchor_left=1; cam.anchor_right=1; cam.anchor_top=1; cam.anchor_bottom=1
    cam.pressed.connect(switch_camera)
    style_button(cam)
    layer.add_child(cam)

func add_button(layer, caption, offset, action, right_side):
    var b = Button.new()
    b.text = caption
    b.position = offset
    b.size = Vector2(110,75)
    b.anchor_left = 1 if right_side else 0
    b.anchor_right = 1 if right_side else 0
    b.anchor_top=1; b.anchor_bottom=1
    b.button_down.connect(func(): Input.action_press(action))
    b.button_up.connect(func(): Input.action_release(action))
    style_button(b)
    layer.add_child(b)

func style_button(b):
    b.add_theme_font_size_override("font_size",18)
    var sb = StyleBoxFlat.new()
    sb.bg_color = Color(0.55,0.02,0.06,0.9)
    sb.border_color = Color(1,0.12,0.16)
    sb.set_border_width_all(2)
    sb.set_corner_radius_all(14)
    b.add_theme_stylebox_override("normal",sb)
    b.add_theme_stylebox_override("pressed",sb)

func switch_camera():
    cams[cam_index].current=false
    cam_index=(cam_index+1)%cams.size()
    cams[cam_index].current=true

func _unhandled_input(event):
    if event.is_action_pressed("camera_switch"): switch_camera()
