extends "res://tests/test_case.gd"
## The Night Market (DESIGN 3.9): the stall, prices, buying, selling, rearranging, Bags.

const Fixtures = preload("res://tests/fixtures.gd")
const ExamState = preload("res://scripts/core/exam_state.gd")
const ShopLogic = preload("res://scripts/core/shop_logic.gd")


func _shop(seed_value: int = 9, money: int = 100) -> ShopLogic:
	var exam: ExamState = ExamState.new()
	exam.setup(Fixtures.data(), seed_value)
	exam.money = money
	var shop: ShopLogic = ShopLogic.new()
	shop.setup(exam, Fixtures.data())
	return shop


func _count(shop: ShopLogic, type: String) -> int:
	var n: int = 0
	for item: Dictionary in shop.offer:
		if str(item["type"]) == type:
			n += 1
	return n


func test_the_stall() -> void:
	var shop: ShopLogic = _shop()
	check_eq(_count(shop, "talisman"), 2, "two Talismans:")
	check_eq(_count(shop, "lesson") + _count(shop, "engraving"), 2, "two Lessons or Engravings:")
	check_eq(_count(shop, "pack"), 2, "two Bags:")
	var lessons: Dictionary = Fixtures.data()["lessons"]
	check_eq(lessons.size(), 8, "one Lesson per Element:")


func test_buying_a_talisman() -> void:
	var shop: ShopLogic = _shop()
	var index: int = 0
	var price: int = int(shop.offer[index]["price"])
	check(shop.buy(index)["ok"], "bought")
	check_eq(shop.exam.money, 100 - price, "paid:")
	check_eq(shop.exam.talismans.size(), 1, "on the string:")
	check(not shop.can_buy(index), "sold out")
	var poor: ShopLogic = _shop(9, 0)
	check(not poor.can_buy(0), "no Coins, no Talisman")


func test_rearranging_costs_more_each_time() -> void:
	var shop: ShopLogic = _shop()
	var first: int = shop.reroll_price()
	check(shop.reroll(), "rearranged")
	check_eq(shop.reroll_price(), first + 1, "one Coin more:")
	check_eq(shop.exam.money, 100 - first, "paid:")


func test_the_granny_gives_a_discount() -> void:
	var shop: ShopLogic = _shop()
	var before: int = shop.price_of("lesson", "lesson_pair")
	shop.exam.add_talisman("market_granny")
	check_eq(shop.price_of("lesson", "lesson_pair"), before - 1, "one Coin off:")


func test_sun_and_day_into_the_talismans_shape_the_next_stall() -> void:
	var exam: ExamState = ExamState.new()
	exam.setup(Fixtures.data(), 4)
	exam.carry["shop_rare"] = 1
	exam.carry["shop_extra"] = 1
	var shop: ShopLogic = ShopLogic.new()
	shop.setup(exam, Fixtures.data())
	check_eq(_count(shop, "talisman"), 3, "one more Talisman:")
	check_eq(str(Fixtures.data()["talismans"][shop.offer[0]["id"]]["rarity"]), "rare", "the first one is rare:")
	shop.reroll()
	check_eq(_count(shop, "talisman"), 2, "only for that stall:")


func test_bags() -> void:
	var shop: ShopLogic = _shop()
	var stones: Dictionary = shop.open_pack("stones")
	check_eq((stones["items"] as Array).size(), 3, "three stones to pick from:")
	check_eq(stones["pick"], 1, "pick one:")
	var size: int = shop.exam.bag.size()
	check(shop.take_from_pack(stones["items"][0]), "taken")
	check_eq(shop.exam.bag.size(), size + 1, "into the bag:")
	var big: Dictionary = shop.open_pack("talismans_big")
	check_eq((big["items"] as Array).size(), 5, "a big Bag: five:")
	check_eq(big["pick"], 2, "pick two:")
	var lessons: Dictionary = shop.open_pack("lessons")
	var element: String = str(Fixtures.data()["lessons"][lessons["items"][0]["id"]]["element"])
	check(shop.take_from_pack(lessons["items"][0]), "a Lesson from a Bag")
	check_eq(shop.exam.element_level(element), 2, "is learned at once:")


func test_torn_pages() -> void:
	var data: Dictionary = Fixtures.data()
	var known: Array[String] = []
	for id: String in data["spells"]:
		if id != "isaz_tiwaz":
			known.append(id)
	var found: bool = false
	for seed_value: int in range(1, 40):
		var exam: ExamState = ExamState.new()
		exam.setup(data, seed_value)
		exam.money = 50
		var shop: ShopLogic = ShopLogic.new()
		shop.setup(exam, data, known)
		for i: int in shop.offer.size():
			if str(shop.offer[i]["type"]) != "page":
				continue
			found = true
			check_eq(str(shop.offer[i]["id"]), "isaz_tiwaz", "the only spell not known:")
			check_eq(int(shop.offer[i]["price"]), int(data["economy"]["price_page"]), "price:")
			var bought: Dictionary = shop.buy(i)
			check_eq(str(bought.get("page", "")), "isaz_tiwaz", "the page shows its spell:")
			check(shop.known_spells.has("isaz_tiwaz"), "not offered again")
			shop.reroll()
			for item: Dictionary in shop.offer:
				check(str(item["type"]) != "page", "no page left to offer")
	check(found, "a Torn Page shows up on some stalls")
	# Every spell known: never a page.
	known.append("isaz_tiwaz")
	for seed_value: int in range(1, 20):
		var exam: ExamState = ExamState.new()
		exam.setup(data, seed_value)
		var shop: ShopLogic = ShopLogic.new()
		shop.setup(exam, data, known)
		for item: Dictionary in shop.offer:
			check(str(item["type"]) != "page", "no page when every spell is known")


func test_every_spell_has_a_verse() -> void:
	for id: String in Fixtures.data()["spells"]:
		var verse: Dictionary = Fixtures.data()["spells"][id].get("verse", {})
		check(not str(verse.get("ro", "")).is_empty() and not str(verse.get("en", "")).is_empty(), "%s has a verse" % id)
