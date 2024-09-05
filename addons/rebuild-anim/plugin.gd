@tool
extends EditorPlugin

var checkbox = Button.new()
var settings = get_editor_interface().get_editor_settings()

func _enter_tree():
    checkbox.text = "Rebuild Anims"
    checkbox.pressed.connect(_on_btn_pressed)
    add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, checkbox)

func _exit_tree():
    remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, checkbox)
    checkbox.free()

func _on_btn_pressed():
    var path = "res://assets/anim"

    print("Crawling {path} for animation folders.".format({ path = path }))

    var dir = DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        var exported = []
        while file_name != "":
            if dir.current_is_dir():
                var anim_path = path.path_join(file_name)
                print("\t", "Found directory: ", file_name, " Full path: ", anim_path)
                var f = build_anims(anim_path, file_name)
                exported.append(f)
            else:
                print("\t", "Found file: ", file_name, " ignoring")
            file_name = dir.get_next()


        var fs := EditorInterface.get_resource_filesystem()
        fs.scan()
        await get_tree().create_timer(0.25).timeout
        fs.reimport_files(exported)
    else:
        print("\t", "An error occurred when trying to access the path.")

static func is_xml(file):
    return file.ends_with(".xml")

func build_anims(path, anim):
    var dir = DirAccess.open(path)
    if not dir:
        print("\t", "An error occurred when trying to access the path: ", path)
        return

    var output_fname = "{anim}.xml".format({ anim=anim })
    var output_path = path.path_join(output_fname)
    var files = Array(dir.get_files())
    files = files.filter(is_xml)
    files.erase(output_fname)
    var lines = []
    for fpath in files:
        var file = FileAccess.open(path.path_join(fpath), FileAccess.READ)
        if file:
            lines.append("\n")
            lines.append(file.get_as_text())

    var file = FileAccess.open(output_path, FileAccess.WRITE)

    var content = "".join(lines)
    file.store_string(content)
    printt("\t", "Wrote combined anims for {anim} to: {output_path}".format({anim=anim, output_path=output_path}))

    return output_path
