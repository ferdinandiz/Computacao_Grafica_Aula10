extends MeshInstance3D

func _ready() -> void:
	# Carrega a textura original (quadrada)
	var orig_tex: Texture2D = load("res://texture/metal_box.png")
	if orig_tex == null:
		push_error("Textura original não encontrada!")
		return

	# Obtém image data da textura original
	var orig_img: Image = orig_tex.get_image()

	# Dimensões originais
	var w := orig_img.get_width()
	var h := orig_img.get_height()

	# Criar atlas 3×2 → largura = 3 * w, altura = 2 * h
	var atlas := Image.create(w * 3, h * 2, false, Image.FORMAT_RGBA8)
	atlas.fill(Color(0, 0, 0, 0))

	# Colar a imagem original 6 vezes (3 colunas x 2 linhas)
	for row in 2:
		for col in 3:
			atlas.blit_rect(orig_img, Rect2(0, 0, w, h), Vector2(col * w, row * h))

	# Criar textura a partir da imagem atlas
	var final_tex := ImageTexture.create_from_image(atlas)

	# Criar material e aplicar a nova textura
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = final_tex

	material_override = mat
