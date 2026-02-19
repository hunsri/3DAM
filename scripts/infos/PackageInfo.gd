class_name PackageInfo extends Object

var package_uuid: String = ""
var package_name: String = ""
var versions: Array = []

func _init(p_package_uuid: String, p_package_name: String, p_versions: Array):
	package_uuid = p_package_uuid
	package_name = p_package_name
	versions = p_versions

func to_dict() -> Dictionary:
	return {
		"package_uuid": package_uuid,
		"package_name": package_name,
		"versions": versions
	}

func to_json_string() -> String:
	var dict = to_dict()
	var json_string := JSON.stringify(dict, "\t")
	return json_string
	
static func from_json_string(json_string: String) -> PackageInfo:
	var parsed_json:Dictionary = JSON.parse_string(json_string)
	
	if parsed_json == null:
		push_error("Failed to parse JSON for reading in package_info")
		return null
	
	var ret := PackageInfo.new(parsed_json.package_uuid, parsed_json.package_name, parsed_json.versions)
	return ret
	
func is_given_package_newer(package: PackageInfo) -> bool:
	
	if package.package_uuid.to_lower() != self.package_uuid.to_lower():
		return false
	
	# will not work in case of diverging histories, but ok for now
	if package.versions.size() > self.versions.size():
		return true
	return false
