extends Node

var flame_sigil: Sigil = Sigil.new()

var all_sigils: Array[Sigil] = [flame_sigil]

func _ready() -> void:
	flame_sigil.point_cloud = [Vector2(61.0, 130.0), Vector2(68.15457, 148.3091), Vector2(75.0, 167.468), Vector2(82.44778, 188.0), Vector2(91.03428, 188.9657), Vector2(102.6972, 173.9542), Vector2(108.0476, 165.1401), Vector2(113.5019, 156.5254), Vector2(124.7002, 142.0283), Vector2(127.1594, 138.7769), Vector2(136.8578, 123.9272), Vector2(142.2918, 115.1915), Vector2(147.5354, 107.3939), Vector2(157.9016, 89.09734), Vector2(161.7215, 82.23737), Vector2(171.1731, 67.51935), Vector2(177.439, 57.36943), Vector2(184.0158, 45.98418), Vector2(191.7926, 32.04698), Vector2(176.8961, 42.11783), Vector2(161.3954, 48.78441), Vector2(145.764, 53.32449), Vector2(127.7603, 62.05795), Vector2(130.5208, 75.20612), Vector2(133.9171, 84.56772), Vector2(138.3506, 103.0779), Vector2(139.8735, 108.6206), Vector2(144.2247, 121.7791), Vector2(148.3955, 137.9373), Vector2(152.0314, 151.3911), Vector2(158.295, 166.489), Vector2(161.1589, 179.1736)]
	flame_sigil.match_threshold = 55.0
