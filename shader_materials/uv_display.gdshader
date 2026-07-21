shader_type spatial;
render_mode unshaded;

void fragment() {
    vec2 uv = fract(UV * 10.0);
    float check = step(uv.x, 0.5) == step(uv.y, 0.5) ? 1.0 : 0.2;
    ALBEDO = vec3(check);
}