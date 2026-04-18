// NOTE: Shader automatically converted from Godot Engine 4.6.2.stable's CanvasItemMaterial.

shader_type canvas_item;
render_mode blend_mix;

uniform float saturation = 1.0;

void fragment(){
  COLOR = texture(TEXTURE, UV); // Read from texture
  COLOR.r *= saturation;
  COLOR.g *= saturation;
  COLOR.b *= saturation;
}
