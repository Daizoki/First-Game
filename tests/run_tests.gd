extends SceneTree
## Runs every logic test without a window:
##   godot --headless --script tests/run_tests.gd
## Exit code 0 = everything passed, 1 = at least one failure.

const TestCase = preload("res://tests/test_case.gd")

const TEST_FILES: Array = [
	"res://tests/test_data.gd",
	"res://tests/test_loc.gd",
	"res://tests/test_save.gd",
	"res://tests/test_words.gd",
	"res://tests/test_sentence.gd",
	"res://tests/test_spells.gd",
	"res://tests/test_scoring.gd",
	"res://tests/test_tutorial.gd",
	"res://tests/test_hints.gd",
	"res://tests/test_exam.gd",
]


func _initialize() -> void:
	var passed: int = 0
	var failed: int = 0
	for path: String in TEST_FILES:
		var script: GDScript = load(path)
		if script == null:
			printerr("FAIL  could not load %s" % path)
			failed += 1
			continue
		for method: Dictionary in script.get_script_method_list():
			var method_name: String = method["name"]
			if not method_name.begins_with("test_"):
				continue
			var test: TestCase = script.new()
			test.call(method_name)
			if test.failures.is_empty():
				passed += 1
				print("  ok    %s :: %s" % [path.get_file(), method_name])
			else:
				failed += 1
				printerr("  FAIL  %s :: %s" % [path.get_file(), method_name])
				for failure: String in test.failures:
					printerr("          - " + failure)
	print("")
	print("%d passed, %d failed" % [passed, failed])
	quit(0 if failed == 0 else 1)
