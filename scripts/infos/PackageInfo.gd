## Class for representing package information.
##
## Used for representing the information of a package, which can contain multiple asset-versions, each having a [AssetInfo]
class_name PackageInfo extends Object

var package_uuid: String = ""	## the uuid of the package, unique for each package
var package_name: String = ""	## the name of the package
var versions: Array = []		## array of the versions of the package, represented as Strings

## Initializer for PackageInfo [br]
##
## [param p_package_uuid] the uuid of the package, unique for each package [br]
## [param p_package_name] the name of the package [br]
## [param p_versions] an array of asset versions contained in the package
func _init(p_package_uuid: String, p_package_name: String, p_versions: Array):
	package_uuid = p_package_uuid
	package_name = p_package_name
	versions = p_versions

## Converts the PackageInfo to a dictionary for serialization [br]
## Returns a dictionary with all members used in the serialization of PackageInfo
func to_dict() -> Dictionary:
	return {
		"package_uuid": package_uuid,
		"package_name": package_name,
		"versions": versions
	}

## Converts the PackageInfo to a json string for serialization [br]
## Returns a json string with all members used in the serialization of PackageInfo
func to_json_string() -> String:
	var dict = to_dict()
	var json_string := JSON.stringify(dict, "\t")
	return json_string

## Static function to create a PackageInfo from a json string [br]
## [param json_string] the json string to parse [br]
## Returns a PackageInfo object created from the json string, or null if parsing fails	
static func from_json_string(json_string: String) -> PackageInfo:
	var parsed_json:Dictionary = JSON.parse_string(json_string)
	
	if parsed_json == null:
		push_error("Failed to parse JSON for reading in package_info")
		return null
	
	var ret := PackageInfo.new(parsed_json.package_uuid, parsed_json.package_name, parsed_json.versions)
	return ret

## Compares if the given package has more versions than the current package, if they have the same uuid [br]
## [param package] the package to compare with [br]
## Returns true if the given package has more versions than the current package and they have the same uuid, false otherwise	
func is_given_package_newer(package: PackageInfo) -> bool:
	
	if package.package_uuid.to_lower() != self.package_uuid.to_lower():
		return false
	
	# will not work in case of diverging histories, but ok for now
	if package.versions.size() > self.versions.size():
		return true
	return false
