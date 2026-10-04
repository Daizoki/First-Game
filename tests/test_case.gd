extends RefCounted
## Tiny base class for logic tests. Every method whose name starts with test_
## is run by tests/run_tests.gd on a fresh instance.

var failures: Array[String] = []


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func check_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if not _equal(actual, expected):
		failures.append("%s expected %s, got %s" % [message, var_to_str(expected), var_to_str(actual)])


## True when any error line contains every given piece of text.
func has_error(errors: Array[String], parts: Array) -> bool:
	for line: String in errors:
		var matches: bool = true
		for part: Variant in parts:
			if not line.contains(str(part)):
				matches = false
				break
		if matches:
			return true
	return false


func _equal(a: Variant, b: Variant) -> bool:
	var a_is_number: bool = a is int or a is float
	var b_is_number: bool = b is int or b is float
	if a_is_number and b_is_number:
		return a == b
	if typeof(a) != typeof(b):
		return false
	return a == b
