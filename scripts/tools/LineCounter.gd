extends Node
class_name LL_LineCounter

func count_project_lines() -> Dictionary:
    var result := {"gdscript": 0, "files": 0, "non_empty": 0, "comments": 0}
    _walk("res://scripts", result)
    return result

func _walk(path: String, result: Dictionary) -> void:
    var directory := DirAccess.open(path)
    if directory == null:
        return
    directory.list_dir_begin()
    var name := directory.get_next()
    while name != "":
        if name.begins_with("."):
            name = directory.get_next()
            continue
        var full := path.path_join(name)
        if directory.current_is_dir():
            _walk(full, result)
        elif name.ends_with(".gd"):
            _count_file(full, result)
        name = directory.get_next()
    directory.list_dir_end()

func _count_file(path: String, result: Dictionary) -> void:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return
    result.files += 1
    while not file.eof_reached():
        var line := file.get_line()
        result.gdscript += 1
        var clean := line.strip_edges()
        if not clean.is_empty():
            result.non_empty += 1
        if clean.begins_with("#"):
            result.comments += 1
    file.close()

func report() -> String:
    var counts := count_project_lines()
    return "GDScript: %d linhas | não vazias: %d | comentários: %d | arquivos: %d" % [counts.gdscript, counts.non_empty, counts.comments, counts.files]
