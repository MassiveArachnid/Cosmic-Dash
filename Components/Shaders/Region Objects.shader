	#pragma language glsl3
	
	// written by groverbuger for g3d
	// may 2021
	// MIT license
	
	uniform mat4 projectionMatrix; // handled by the camera
	uniform mat4 viewMatrix;       // handled by the camera
	uniform mat4 modelMatrix;      // models send their own model matrices when drawn
	
	// Holds the y positions for positions on the planet
	extern Image PlanetHeightMap;
	// Holds the x,z positions for instances 
	extern Image InstanceData;
	extern Image InstanceFlagData;
	extern int InstanceStartIndex;
	extern float InstanceImgSize;
	
	extern vec3 RegionPos;
	varying vec4 relativeWorldPosition;
	
	extern float Time;

	#ifdef VERTEX
		vec4 position(mat4 transformProjection, vec4 vertexPosition) {
			
			int DataIndex = InstanceStartIndex + love_InstanceID;
			
			int pixelX = int(mod(DataIndex, InstanceImgSize));
			int pixelY = int(DataIndex / InstanceImgSize);
			
			float ScaleValue = texelFetch(InstanceFlagData, ivec2(pixelX, pixelY), 0).r * 2.0;
			
			vec4 InstData = texelFetch(InstanceData, ivec2(pixelX, pixelY), 0);
			

			float PosX = RegionPos.x + (InstData.r * 255.0);
			float PosZ = RegionPos.z + (InstData.g * 255.0);
			
			
			vec4 ff = texelFetch(InstanceFlagData, ivec2(PosZ, PosX), 0);
			
			
			mat4 TransModelMatrix = modelMatrix; 
			TransModelMatrix[3][0] = PosX + 0.5 + (mod(PosZ, 2)*0.1);
			TransModelMatrix[3][1] = RegionPos.y - (255.0 - (-texelFetch(PlanetHeightMap, ivec2(PosZ, PosX), 0).r * 255.0)) + 1 - (1 * ScaleValue);
			TransModelMatrix[3][2] = PosZ + 0.5 + (mod(PosX, 2)*0.1);
			
			
			mat4 ModelView = viewMatrix*-TransModelMatrix;
			
			ModelView[0][0] = 1;
			ModelView[0][1] = 0;
			ModelView[0][2] = 0;

			// Column 1:
			//ModelView[1][0] = 0;
			//ModelView[1][1] = 1;
			//ModelView[1][2] = 0;

			// Column 2:
			ModelView[2][0] = 0;
			ModelView[2][1] = 0;
			ModelView[2][2] = 1;
			
			
			
			
			
			vertexPosition.x += sin(PosX + Time * 1.25 + VertexTexCoord.y) * ( 1.0 - VertexTexCoord.y) * 0.2;
			vertexPosition.y += cos(PosZ + Time * 0.45 + VertexTexCoord.y) * ( 1.0 - VertexTexCoord.y) * 0.15;
			
			vec4 scaleverts = vec4(vertexPosition.xy * vec2(ScaleValue, ScaleValue), vertexPosition.z, vertexPosition.w);
			
			relativeWorldPosition = projectionMatrix * -ModelView * (scaleverts);
			
			
			return relativeWorldPosition;
		}
	#endif

	#ifdef PIXEL
		vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
		{
			vec4 texcolor = Texel(tex, texcoord);
			
			// discard see-through bits
			if (texcolor.a < 0.001) { discard; }
			
			//  color
			vec4 col = texcolor;
			
			// return the end color
			return col;
		}
	#endif
