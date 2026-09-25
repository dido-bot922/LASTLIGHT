extends Node
class_name LL_LineCounter

func count_project_lines() -> Dictionary:
    var result := {"gdscript": 0, "files": 0, "non_empty": 0, "comments": 0, "code": 0}
    _walk("res://scripts", result)
    return result

func _walk(path: String, result: Dictionary) -> void:
    var directory := DirAccess.open(path)
    if directory == null:
        return
    directory.list_dir_begin()
    var entry := directory.get_next()
    while entry != "":
        if not entry.begins_with("."):
            var full := path.path_join(entry)
            if directory.current_is_dir():
                _walk(full, result)
            elif entry.ends_with(".gd"):
                _count_file(full, result)
        entry = directory.get_next()
    directory.list_dir_end()

func _count_file(path: String, result: Dictionary) -> void:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return
    result.files += 1
    var lines := file.get_as_text().split("\n", false)
    file.close()
    for line in lines:
        result.gdscript += 1
        var clean := line.strip_edges()
        if clean.is_empty():
            continue
        result.non_empty += 1
        if clean.begins_with("#"):
            result.comments += 1
        else:
            result.code += 1

func report() -> String:
    var counts := count_project_lines()
    return "GDScript: %d | código: %d | não vazias: %d | comentários: %d | arquivos: %d" % [counts.gdscript, counts.code, counts.non_empty, counts.comments, counts.files]
