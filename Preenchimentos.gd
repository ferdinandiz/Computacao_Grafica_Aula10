extends Node2D

# posições e tamanhos
const SZ := Vector2(110, 110)
const P1 := Vector2(30, 30)  # contorno
const P2 := Vector2(160, 30) # sólido
const P3 := Vector2(30, 160) # por-vértice (gradiente)
const P4 := Vector2(160, 160)# área do "padrão" (tiles)

# cores
var c_line: Color = Color(0.6, 0.1, 0.9)
var c_fill: Color = Color(0.1, 0.8, 0.2)
var c_v0: Color = Color(1, 0, 0)
var c_v1: Color = Color(0, 1, 0)
var c_v2: Color = Color(0, 0, 1)
var c_v3: Color = Color(1, 0, 1)

@export var pattern_tex: Texture2D
@export var tiles_x: int = 1
@export var tiles_y: int = 1

# tint único aplicado aos tiles do padrão (coerente com a “paleta” do clique)
var pattern_tint: Color = Color(1, 1, 1, 1)

func _ready() -> void:
	randomize()
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_randomize_palette()
		queue_redraw()

func _randomize_palette() -> void:
	# gera um conjunto de cores
	c_line = Color(randf(), randf(), randf())
	c_fill = Color(randf(), randf(), randf())
	c_v0 = Color(randf(), 0.0, 0.0)
	c_v1 = Color(0.0, randf(), 0.0)
	c_v2 = Color(0.0, 0.0, randf())
	c_v3 = Color(randf(), randf(), randf())
	# usa o mesmo “tom” do preenchimento para o padrão (coerência visual)
	pattern_tint = c_fill

func _draw() -> void:
	# 1) Contorno
	var r1 := Rect2(P1, SZ)
	draw_rect(r1, Color.TRANSPARENT, false, 2.0, true)
	_stroke_rect(r1, c_line, 2.0)

	# 2) Sólido
	var r2 := Rect2(P2, SZ)
	draw_rect(r2, c_fill, true)

	# 3) Interpolação por vértice
	var p0 := P3
	var p1 := P3 + Vector2(SZ.x, 0)
	var p2 := P3 + SZ
	var p3 := P3 + Vector2(0, SZ.y)
	draw_polygon(
		PackedVector2Array([p0, p1, p2, p3]),
		PackedColorArray([c_v0, c_v1, c_v2, c_v3])
	)

	# 4) Padrão em grid — todos os tiles com o mesmo tint (pattern_tint)
	if pattern_tex:
		_draw_pattern_grid(Rect2(P4, SZ))

func _stroke_rect(r: Rect2, col: Color, w: float) -> void:
	var tl := r.position
	var tr := r.position + Vector2(r.size.x, 0)
	var br := r.position + r.size
	var bl := r.position + Vector2(0, r.size.y)
	draw_polyline(PackedVector2Array([tl, tr, br, bl, tl]), col, w, true)

# desenha o padrão como grade N×M
func _draw_pattern_grid(r: Rect2) -> void:
	var cell_w: float = r.size.x / float(tiles_x)
	var cell_h: float = r.size.y / float(tiles_y)
	for j in range(tiles_y):
		for i in range(tiles_x):
			var pos := r.position + Vector2(i * cell_w, j * cell_h)
			var rect := Rect2(pos, Vector2(cell_w, cell_h))
			draw_texture_rect(pattern_tex, rect, false, pattern_tint)
