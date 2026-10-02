extends Control
## The hand: stones laid out in a gentle arc. Click a stone to select it (max 5),
## drag it sideways to reorder. Keeps one StoneView per stone so they can animate.

signal selection_changed
signal stone_moved(from: int, to: int)
## The stone under the mouse changed (null when the mouse left every stone).
signal hover_changed(view: StoneView)

const Stone = preload("res://scripts/core/stone.gd")
const StoneView = preload("res://scripts/ui/stone_view.gd")

const MAX_SPACING: float = 168.0
const ARC_DEPTH: float = 34.0
const ARC_TILT: float = 0.09
const DRAG_THRESHOLD: float = 14.0

## Clicks and drags (hovering always works, so the player can always read the stones).
var enabled: bool = true
var max_selection: int = 5
## Optional filter: func(stone) -> bool. Stones it rejects cannot be selected.
var can_select: Callable = Callable()

var _views: Array[StoneView] = []
var _pressed: StoneView = null
var _press_position: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _hovered: StoneView = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


## Shows these stones in this order. Views of stones still in hand are kept (and slide).
func set_stones(stones: Array[Stone]) -> void:
	var by_uid: Dictionary = {}
	for view: StoneView in _views:
		by_uid[view.stone.uid] = view
	var next: Array[StoneView] = []
	for stone: Stone in stones:
		var view: StoneView = by_uid.get(stone.uid)
		if view == null:
			view = StoneView.new()
			view.setup(stone)
			add_child(view)
			# New stones rise from below the screen.
			view.position = Vector2(size.x * 0.5 - view.size.x * 0.5, size.y + 40.0)
		else:
			by_uid.erase(stone.uid)
		next.append(view)
	for view: StoneView in by_uid.values():
		view.queue_free()
	_views = next
	for i: int in _views.size():
		move_child(_views[i], i)


func selected_indices() -> Array[int]:
	var result: Array[int] = []
	for i: int in _views.size():
		if _views[i].selected:
			result.append(i)
	return result


func clear_selection() -> void:
	for view: StoneView in _views:
		view.selected = false
	selection_changed.emit()


func view_at(index: int) -> StoneView:
	return _views[index] if index >= 0 and index < _views.size() else null


## Every view showing this rune (the tutorial lights them up).
func views_with_rune(rune_id: String) -> Array[StoneView]:
	var result: Array[StoneView] = []
	for view: StoneView in _views:
		if view.stone.rune_id == rune_id:
			result.append(view)
	return result


## Lights the stones at these hand indices (the ones that would score) and fades the other
## selected stones; an empty list puts every stone back to normal.
func mark_scoring(indices: Array) -> void:
	for i: int in _views.size():
		var view: StoneView = _views[i]
		view.marked = indices.has(i)
		view.dimmed = not indices.is_empty() and view.selected and not view.marked


func view_for(stone: Stone) -> StoneView:
	for view: StoneView in _views:
		if view.stone == stone:
			return view
	return null


func _process(delta: float) -> void:
	var count: int = _views.size()
	for i: int in count:
		var view: StoneView = _views[i]
		if view == _pressed and _dragging:
			continue
		var slot: Dictionary = _slot(i, count)
		var target: Vector2 = slot["position"] + Vector2(0, view.lift_offset())
		view.position = view.position.lerp(target, minf(1.0, delta * 10.0))
		view.base_rotation = slot["rotation"]


func _slot(i: int, count: int) -> Dictionary:
	var stone_size: Vector2 = StoneView.STONE_SIZE
	var spacing: float = MAX_SPACING
	if count > 1:
		spacing = minf(MAX_SPACING, (size.x - stone_size.x) / float(count - 1))
	var total: float = spacing * float(count - 1)
	var x: float = size.x * 0.5 - total * 0.5 + spacing * float(i) - stone_size.x * 0.5
	var t: float = 0.0 if count <= 1 else (float(i) / float(count - 1)) * 2.0 - 1.0
	var y: float = size.y - stone_size.y - 14.0 - ARC_DEPTH * (1.0 - t * t)
	return {"position": Vector2(x, y), "rotation": ARC_TILT * t}


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event
		_update_hover(motion.position)
		if not enabled:
			return
		if _pressed != null:
			if not _dragging and motion.position.distance_to(_press_position) > DRAG_THRESHOLD:
				_dragging = true
				_pressed.z_index = 10
			if _dragging:
				_pressed.position = motion.position - _pressed.size * 0.5
	elif event is InputEventMouseButton:
		if not enabled:
			return
		var button: InputEventMouseButton = event
		if button.button_index != MOUSE_BUTTON_LEFT:
			return
		if button.pressed:
			_pressed = _view_under(button.position)
			_press_position = button.position
			_dragging = false
		elif _pressed != null:
			if _dragging:
				_finish_drag(button.position)
			else:
				_toggle(_pressed)
			_pressed = null
			_dragging = false
		accept_event()


func _toggle(view: StoneView) -> void:
	if not view.selected and selected_indices().size() >= max_selection:
		return
	if not view.selected and can_select.is_valid() and not bool(can_select.call(view.stone)):
		return
	view.selected = not view.selected
	selection_changed.emit()


func _finish_drag(at: Vector2) -> void:
	var from: int = _views.find(_pressed)
	_pressed.z_index = 0
	var to: int = 0
	for i: int in _views.size():
		var slot_center: float = _slot(i, _views.size())["position"].x + StoneView.STONE_SIZE.x * 0.5
		if at.x > slot_center:
			to = i
	if from != to and from >= 0:
		_views.remove_at(from)
		_views.insert(to, _pressed)
		stone_moved.emit(from, to)


func _update_hover(at: Vector2) -> void:
	var hovered: StoneView = _view_under(at)
	for view: StoneView in _views:
		view.hovered = view == hovered
	if hovered != _hovered:
		_hovered = hovered
		hover_changed.emit(hovered)


func _view_under(at: Vector2) -> StoneView:
	for i: int in range(_views.size() - 1, -1, -1):
		var view: StoneView = _views[i]
		if Rect2(view.position, view.size).has_point(at):
			return view
	return null


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		for view: StoneView in _views:
			view.hovered = false
		if _hovered != null:
			_hovered = null
			hover_changed.emit(null)
