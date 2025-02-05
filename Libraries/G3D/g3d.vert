// written by groverbuger for g3d
// may 2021
// MIT license

// this vertex shader is what projects 3d vertices in models onto your 2d screen

uniform mat4 projectionMatrix; // handled by the camera
uniform mat4 viewMatrix;       // handled by the camera
uniform mat4 modelMatrix;      // models send their own model matrices when drawn



varying vec3 worldPos;
varying vec4 relativeWorldPosition;






#ifdef VERTEX

	vec4 position(mat4 transformProjection, vec4 vertexPosition) {
		relativeWorldPosition = projectionMatrix * viewMatrix * modelMatrix * vertexPosition;
		

		return relativeWorldPosition;
	}
#endif

#ifdef PIXEL
    vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
    {
        vec4 texcolor = Texel(tex, texcoord);
		
		// discard see-through bits
		if (texcolor.a < .005) { discard; }
		
		//  color
		vec4 col = texcolor;
		
		vec4 dither = vec4(texture2D(tex, texcoord.xy / 8.0).r / 32.0 - (1.0 / 128.0));


		// return the end color
        return col;
    }
#endif