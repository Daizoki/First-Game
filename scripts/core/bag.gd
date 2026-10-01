extends RefCounted
## The Săculeț: every stone the player owns, plus the shuffled draw pile of the current round.
## All randomness goes through the exam RNG passed in, so a seed replays the same draws.

const Stone = preload("res://scripts/core/stone.gd")

## Every stone owned during this exam.
var stones: Array[Stone] = []
## Stones still waiting to be drawn this round (the end of the array is the top).
var draw_pile: Array[Stone] = []

var _rng: RandomNumberGenerator
var _next_uid: int = 1


func _init(rng: RandomNumberGenerator) -> void:
	_rng = rng


## Starting bag: every rune `copies` times (48 stones with 2 copies of the 24 runes).
func fill_with_runes(runes: Dictionary, copies: int) -> void:
	stones.clear()
	for id: String in runes:
		for i: int in copies:
			stones.append(Stone.from_rune(runes[id], _take_uid()))


## Puts every owned stone back into the draw pile and shuffles it (start / end of a round).
func reset_round() -> void:
	draw_pile.assign(stones)
	_shuffle(draw_pile)


## Takes up to `count` stones from the top of the pile (fewer if the bag runs out).
func draw(count: int) -> Array[Stone]:
	var drawn: Array[Stone] = []
	for i: int in count:
		if draw_pile.is_empty():
			break
		drawn.append(draw_pile.pop_back())
	return drawn


## The next `count` stones that would be drawn, top first (Kenaz). Does not change the pile.
func peek(count: int) -> Array[Stone]:
	var result: Array[Stone] = []
	for i: int in mini(count, draw_pile.size()):
		result.append(draw_pile[draw_pile.size() - 1 - i])
	return result


## Adds a new stone to the bag and to the current draw pile at a random place (Berkanan).
func add_copy_of(stone: Stone) -> Stone:
	var copy: Stone = stone.duplicate_stone(_take_uid())
	stones.append(copy)
	draw_pile.insert(_rng.randi_range(0, draw_pile.size()), copy)
	return copy


## Permanently removes a stone (Sfărâmarea, Focul, broken glass).
func remove(stone: Stone) -> void:
	stones.erase(stone)
	draw_pile.erase(stone)


func size() -> int:
	return stones.size()


func remaining() -> int:
	return draw_pile.size()


func _take_uid() -> int:
	_next_uid += 1
	return _next_uid - 1


## Fisher-Yates with the exam RNG (Array.shuffle() would use the global RNG).
func _shuffle(pile: Array[Stone]) -> void:
	for i: int in range(pile.size() - 1, 0, -1):
		var j: int = _rng.randi_range(0, i)
		var tmp: Stone = pile[i]
		pile[i] = pile[j]
		pile[j] = tmp
