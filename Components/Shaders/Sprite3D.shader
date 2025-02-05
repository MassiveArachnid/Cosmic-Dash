	#pragma language glsl3
	
	// written by groverbuger for g3d
	// may 2021
	// MIT license
	

	uniform mat4 projectionMatrix; // handled by the camera
	uniform mat4 viewMatrix;       // handled by the camera
	uniform mat4 modelMatrix;      // models send their own model matrices when drawn
	
	extern vec4 fillColor;
	extern vec2 textureDimensions;

	extern Image InstancePositions;
	extern Image InstanceAlpha_Frames;
	
	extern float AspectScale;
	
	extern int InstanceStartIndex;
	extern float InstanceImgSize;
	
	uniform ArrayImage InstanceArrayTexture;

	
	varying vec4 relativeWorldPosition;

	#ifdef VERTEX
	
		varying float Alpha;
		varying float Frame;
		
		vec4 position(mat4 transformProjection, vec4 vertexPosition) {
			
			
			vertexPosition.x /= AspectScale;
			
			int DataIndex = InstanceStartIndex + love_InstanceID;
			
			//vec2 resolutionOfTexture = vec2(InstanceImgSize, InstanceImgSize);
			int pixelX = int(mod(DataIndex, InstanceImgSize));
			int pixelY = int(DataIndex / InstanceImgSize);

			//vec2 uv = (vec2(pixelX, pixelY) + .5) / resolutionOfTexture;
			vec4 InstData = texelFetch(InstancePositions, ivec2(pixelX, pixelY), 0);
			vec4 InstData2 = texelFetch(InstanceAlpha_Frames, ivec2(pixelX, pixelY), 0);
			
			// Scale verts per instance
			vertexPosition.x *= InstData.a;
			vertexPosition.y *= InstData.a;
			
			Alpha = InstData2.r;
			Frame = (InstData2.g * 255.0) - 1.0;
			
			//float DataIndex = InstanceStartIndex + love_InstanceID;
			//vec4 InstData = Texel(InstancePositions, vec2(mod(DataIndex, InstanceImgSize), DataIndex / InstanceImgSize));
			
			mat4 TransModelMatrix = modelMatrix; 
			TransModelMatrix[3][0] = InstData.r;
			TransModelMatrix[3][1] = -InstData.g+0.5;
			TransModelMatrix[3][2] = InstData.b;
			
			
			mat4 ModelView = viewMatrix*-TransModelMatrix;
			
			ModelView[0][0] = 1;
			ModelView[0][1] = 0;
			ModelView[0][2] = 0;

			// Column 1:
			ModelView[1][0] = 0;
			ModelView[1][1] = 1;
			ModelView[1][2] = 0;

			// Column 2:
			ModelView[2][0] = 0;
			ModelView[2][1] = 0;
			ModelView[2][2] = 1;

			relativeWorldPosition = projectionMatrix * -ModelView * (vertexPosition);
			
			
			return relativeWorldPosition;
		}
	#endif

	#ifdef PIXEL
		
		varying float Alpha;
		varying float Frame;		
		
		vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
		{
			
			vec4 texcolor = Texel(InstanceArrayTexture, vec3(texcoord, Frame));
			
			texcolor.a = texcolor.a * Alpha;
			
			// discard see-through bits
			if (texcolor.a < .005) { discard; }
			
			//  color
			vec4 col = texcolor;
			
			
			// return the end color
			return col;
		}
	#endif
