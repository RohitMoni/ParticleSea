Shader "Custom/GS Billboard" 
{
	Properties 
	{
		_SpriteTex ("Color (RGB) Alpha (A)", 2D) = "white" {}
		_Size ("Size", Range(0, 3)) = 0.5
		_Spacing ("Spacing", Float) = 0.3
		_NoiseScale ("Noise Scale", Float) = 0.05
		_HeightScale ("Height Scale", Float) = 3
		[HideInInspector] _Gradient ("Gradient", 2D) = "white" {}
		[HideInInspector] _PerlinNoiseTime ("PerlinNoiseTime", Float) = 0.0
		[HideInInspector] _SeaResolution ("SeaResolution", Int) = 100
	}

	SubShader 
	{
		Pass
		{
			Tags { "Queue"="Transparent" "RenderType"="Transparent" "ForceNoShadowCasting" = "True"}
			Blend One OneMinusSrcAlpha
			Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
			LOD 200
		
			CGPROGRAM
				#pragma vertex VS_Main
				#pragma fragment FS_Main
				#pragma geometry GS_Main
				#include "UnityCG.cginc" 

				// **************************************************************
				// Data structures												*
				// **************************************************************
				struct GS_INPUT
				{
					float4	pos		: POSITION;
					float3	normal	: NORMAL;
					float2  tex0	: TEXCOORD0;
				};

				struct FS_INPUT
				{
					float4	pos		: POSITION;
					float2  tex0	: TEXCOORD0;
				};


				// **************************************************************
				// Vars															*
				// **************************************************************

				float _Size;
				float4x4 _VP;
				
				// Particle Sprite Vars
				Texture2D _SpriteTex;
				SamplerState sampler_SpriteTex;

				// Gradient Vars
				Texture2D _Gradient;
				SamplerState sampler_Gradient;
				
				// Positioning and Perlin Noise Vars
				float _PerlinNoiseTime;
				int _SeaResolution;
				float _Spacing;
				float _NoiseScale;
				float _HeightScale;

				// **************************************************************
				// Support Functions											*
				// **************************************************************

				//noise function taken from https://www.shadertoy.com/view/XslGRr

				float hash( float n )
				{
					return (sin(n)*43758.5453 - floor(sin(n)*43758.5453));
				}
				
				float noise( float2 uv )
				{
					float3 x = float3(uv, 0);
					// The noise function returns a value in the range -1.0f -> 1.0f
					float3 p = floor(x);
					float3 f = x - floor(x);
					
					f       = f*f*(3.0-2.0*f);
					float n = p.x + p.y*57.0 + 113.0*p.z;
					
					return lerp(lerp(lerp( hash(n+0.0), hash(n+1.0),f.x),
								   lerp( hash(n+57.0), hash(n+58.0),f.x),f.y),
							   lerp(lerp( hash(n+113.0), hash(n+114.0),f.x),
								   lerp( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
				}
				
				//t*vec2(.5, .5)
				//just offsets the noise lookup coordinate based on time
				//which is basically the same as having it move at a
				//constant speed in a specific direction
				//just pick a different direction for each layer
				//and we're good to go!
				float perlin_noise(float2 uv, float t)
				{
					float res = noise(uv     +t*float2(.5,  .5))*64.0 
						      + noise(uv*2.0 +t*float2(-.7, .2))*32.0
							  + noise(uv*4.0 +t*float2( 0,   1))*16.0
						  	  + noise(uv*8.0 +t*float2(1,    0))*8.0
							  + noise(uv*16.0+t*float2(-.5,-.5))*4.0
						   	  + noise(uv*32.0+t*float2(.1,  .1))*2.0
							  + noise(uv*64.0+t*float2(.9,  .9))*1.0;
					
					return res / (1.0+2.0+4.0+8.0+16.0+32.0+64.0);
				}

				// **************************************************************
				// Shader Programs												*
				// **************************************************************

				// Vertex Shader ------------------------------------------------
				GS_INPUT VS_Main(appdata_base v)
				{
					GS_INPUT output = (GS_INPUT)0;

					int i = v.vertex[0] / _Spacing + _SeaResolution / 2;
					int j = v.vertex[2] / _Spacing + _SeaResolution / 2;

					float yPos = perlin_noise(float2(i * _NoiseScale, j * _NoiseScale), _PerlinNoiseTime) * _HeightScale;

					v.vertex[1] = yPos;

					output.pos =  mul(_Object2World, v.vertex);
					output.normal = v.normal;
					output.tex0 = float2(0, 0);

					return output;
				}

				// Geometry Shader -----------------------------------------------------
				[maxvertexcount(12)]
				void GS_Main(triangle GS_INPUT p[3], inout TriangleStream<FS_INPUT> triStream)
				{
					for (int i = 0; i < 3; i++)
					{

						float3 look = normalize(_WorldSpaceCameraPos - p[i].pos);
						float3 up = float3(0, 1, 0);
						float3 right = normalize(cross(up, look));
						up = cross(look, right);
					
						float halfS = 0.5f * _Size;
							
						float4 v[4];
						v[0] = float4(p[i].pos + halfS * right - halfS * up, 1.0f);
						v[1] = float4(p[i].pos + halfS * right + halfS * up, 1.0f);
						v[2] = float4(p[i].pos - halfS * right - halfS * up, 1.0f);
						v[3] = float4(p[i].pos - halfS * right + halfS * up, 1.0f);

						float4x4 vp = mul(UNITY_MATRIX_MVP, _World2Object);
						FS_INPUT pIn;
						pIn.pos = mul(vp, v[0]);
						pIn.tex0 = float2(1.0f, 0.0f);
						triStream.Append(pIn);

						pIn.pos =  mul(vp, v[1]);
						pIn.tex0 = float2(1.0f, 1.0f);
						triStream.Append(pIn);

						pIn.pos =  mul(vp, v[2]);
						pIn.tex0 = float2(0.0f, 0.0f);
						triStream.Append(pIn);

						pIn.pos =  mul(vp, v[3]);
						pIn.tex0 = float2(0.0f, 1.0f);
						triStream.Append(pIn);

						triStream.RestartStrip();
					}
				}



				// Fragment Shader -----------------------------------------------
				float4 FS_Main(FS_INPUT input) : COLOR
				{
					fixed4 color = _SpriteTex.Sample(sampler_SpriteTex, input.tex0);

					color = color * _Gradient.Sample(sampler_Gradient, 0);
					
					return color;
				}

			ENDCG
		}
	} 
}
