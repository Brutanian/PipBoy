shader_type canvas_item;

uniform vec3 PaletteColour1 : source_color = vec3(0);
uniform vec3 PaletteColour2 : source_color = vec3(0);
uniform vec3 PaletteColour3 : source_color = vec3(0);
uniform vec3 PaletteColour4 : source_color = vec3(0);

uniform float TintAmount : hint_range(0,1);
uniform vec3 TintColour : source_color;

vec4 Tint(vec3 Init){
	lowp float Lumin = 0.3 * Init.r + 0.59 * Init.g + 0.11 * Init.b;
	lowp vec4 Color = vec4(mix(Init, TintColour * Lumin, TintAmount),1);
	Color = round(Color * 8.0) / 8.0;
	return Color;
}

void fragment(){
	lowp vec3 Screen = texture(SCREEN_TEXTURE,SCREEN_UV).rgb;
	if(Screen == vec3(1)){
		COLOR = Tint(PaletteColour2);
	} else if(Screen == vec3(1,0,0)) {
		COLOR = Tint(PaletteColour3);
	} else if(Screen == vec3(0,1,0)) {
		COLOR = Tint(PaletteColour4);
	} else {
		COLOR = Tint(PaletteColour1);
	}
}