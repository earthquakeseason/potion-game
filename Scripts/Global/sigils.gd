extends Node

var flame_sigil: Sigil = Sigil.new()
var frost_sigil: Sigil = Sigil.new()
var all_sigils: Array[Sigil] = [frost_sigil, flame_sigil]

const FIRE = preload("uid://cvhcnpsndm6o5")
const FROST = preload("uid://8badmp1twug3")

func _ready() -> void:
	flame_sigil.point_cloud = [Vector2(61.0, 130.0), Vector2(68.15457, 148.3091), Vector2(75.0, 167.468), Vector2(82.44778, 188.0), Vector2(91.03428, 188.9657), Vector2(102.6972, 173.9542), Vector2(108.0476, 165.1401), Vector2(113.5019, 156.5254), Vector2(124.7002, 142.0283), Vector2(127.1594, 138.7769), Vector2(136.8578, 123.9272), Vector2(142.2918, 115.1915), Vector2(147.5354, 107.3939), Vector2(157.9016, 89.09734), Vector2(161.7215, 82.23737), Vector2(171.1731, 67.51935), Vector2(177.439, 57.36943), Vector2(184.0158, 45.98418), Vector2(191.7926, 32.04698), Vector2(176.8961, 42.11783), Vector2(161.3954, 48.78441), Vector2(145.764, 53.32449), Vector2(127.7603, 62.05795), Vector2(130.5208, 75.20612), Vector2(133.9171, 84.56772), Vector2(138.3506, 103.0779), Vector2(139.8735, 108.6206), Vector2(144.2247, 121.7791), Vector2(148.3955, 137.9373), Vector2(152.0314, 151.3911), Vector2(158.295, 166.489), Vector2(161.1589, 179.1736)]
	flame_sigil.match_threshold = 55.0
	flame_sigil.icon = FIRE
	frost_sigil.acceptable_next = [TypingOptions.cutting]
	flame_sigil.minigame_name = "flame"
	
	frost_sigil.point_cloud = [Vector2(125.9514, -0.000015), Vector2(106.0591, 8.702545), Vector2(85.98946, 20.46722), Vector2(60.6573, 34.06866), Vector2(40.2567, 44.80083), Vector2(16.44083, 57.60953), Vector2(-6.85022, 72.14488), Vector2(-28.7266, 85.1311), Vector2(-54.46312, 99.42308), Vector2(-72.44944, 112.0595), Vector2(-91.43367, 119.3556), Vector2(-84.12502, 103.0986), Vector2(-75.34995, 82.95413), Vector2(-70.18944, 63.6189), Vector2(-59.05615, 41.46761), Vector2(-51.35269, 19.00475), Vector2(-43.92113, -0.340088), Vector2(-36.54868, -21.30882), Vector2(-27.64557, -44.01826), Vector2(-21.08634, -66.63531), Vector2(-12.95332, -87.2072), Vector2(-3.860161, -111.1728), Vector2(4.198875, -130.6444), Vector2(18.97289, -113.5176), Vector2(38.35223, -87.18414), Vector2(47.25667, -72.66975), Vector2(67.98213, -49.9721), Vector2(42.78552, -60.42206), Vector2(18.37187, -61.29617), Vector2(14.12227, -43.08735), Vector2(21.31317, -19.7877), Vector2(31.30126, 5.356155)]
	frost_sigil.match_threshold = 45.0
	frost_sigil.icon = FROST
	frost_sigil.acceptable_next = [TypingOptions.cutting]
	flame_sigil.minigame_name = "frost"
