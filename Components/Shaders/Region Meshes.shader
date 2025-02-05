// written by groverbuger for g3d
// may 2021
// MIT license












uniform mat4 projectionMatrix; // handled by the camera
uniform mat4 viewMatrix;       // handled by the camera
uniform mat4 modelMatrix;      // models send their own model matrices when drawn
uniform ArrayImage BlockTextureArray;

extern vec2 UVArray[4];



#ifdef VERTEX
	attribute vec4 VertInfo;
	varying float ao_value;
	varying vec2 uv;
	varying float tex_index;
	
	vec4 position(mat4 transformProjection, vec4 vertexPosition) {		
		ao_value = VertInfo.a;
		uv = UVArray[int(VertInfo.b * 255.0)];
		tex_index = floor(VertInfo.r * 255.0) - 1.0;
		return projectionMatrix * viewMatrix * modelMatrix * vertexPosition;;
	}
#endif

#ifdef PIXEL
	
	varying float ao_value;
	varying vec2 uv;
	varying float tex_index;

	
    vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
    {
        vec4 texcolor = Texel(BlockTextureArray, vec3(uv, tex_index));
		vec4 col = vec4(texcolor.r*ao_value, texcolor.g*ao_value, texcolor.b*ao_value, texcolor.a);

        return col;
    }
#endif