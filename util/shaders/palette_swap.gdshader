shader_type canvas_item;

uniform sampler2D palette_image : filter_nearest;
uniform int palette_index = 0;
uniform float maximum_similarity = 0.01;

varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
	vec4 src = texture(TEXTURE, UV);
	vec4 result = src * modulate;

	ivec2 palsize = textureSize(palette_image, 0);
	for (int i = 0; i < palsize.x; i++) {
		vec4 base = texelFetch(palette_image, ivec2(i, 0), 0);
		if (base.a < 0.5)
			continue;

		if (distance(base.rgb, src.rgb) < maximum_similarity) {
			vec4 replacement = texelFetch(palette_image, ivec2(i, palette_index), 0);
			result = vec4(replacement.rgb, src.a) * modulate;
			break;
		}
	}

	COLOR = result;
}